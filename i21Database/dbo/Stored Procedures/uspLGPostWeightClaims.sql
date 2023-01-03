﻿CREATE PROCEDURE [dbo].[uspLGPostWeightClaims]
	@intWeightClaimsId INT,
	@intEntityUserSecurityId INT,
	@ysnPost BIT,
	@ysnRecap BIT = 0,
	@strBatchId NVARCHAR(40) = NULL OUTPUT
AS
BEGIN
DECLARE @strErrMsg NVARCHAR(MAX)
DECLARE @intBillId INT
DECLARE @intPurchaseSale INT
DECLARE @intLoadId INT
DECLARE @strTransactionId NVARCHAR(100)
DECLARE @actionType NVARCHAR(10)
DECLARE @intFunctionalCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

/* Get Weight Claims Info */
SELECT 
	@intPurchaseSale = intPurchaseSale
	,@intLoadId = intLoadId
	,@strTransactionId = WC.strReferenceNumber
FROM tblLGWeightClaim WC
WHERE intWeightClaimId = @intWeightClaimsId


/* Weight Claims No GL */
IF EXISTS(SELECT TOP 1 1 FROM tblLGCompanyPreference WHERE ISNULL(ysnWeightClaimsImpactGL, 0) = 0)
BEGIN
	IF(@ysnPost = 0 AND @ysnRecap = 0) 
	BEGIN
		IF EXISTS (SELECT 1 FROM tblLGWeightClaimDetail WHERE intWeightClaimId = @intWeightClaimsId AND intBillId IS NOT NULL)
		BEGIN 
			SELECT @intBillId = intBillId FROM tblLGWeightClaimDetail WHERE intWeightClaimId = @intWeightClaimsId
			IF EXISTS(SELECT 1 FROM tblAPBill WHERE intBillId = @intBillId)
			BEGIN 
				RAISERROR('Voucher has been created for the weight claim. Cannot unpost.',16,1)
			END
		END
	END

	UPDATE tblLGWeightClaim
	SET ysnPosted = @ysnPost
		,dtmPosted = GETDATE()
	WHERE intWeightClaimId = @intWeightClaimsId

	SET @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted' WHEN @ysnPost = 0 THEN 'Unposted' END
	EXEC uspSMAuditLog
        @keyValue = @intWeightClaimsId,
        @screenName = 'Logistics.view.WeightClaims',
        @entityId = @intEntityUserSecurityId,
        @actionType = @actionType

	RETURN;
END
/* Weight Claims Impact GL */
/*
Inbound Claims
	-ve Claim = Received is less than agreed qty, asking money from vendor (Debit Memo)
	+ve Claim = Received is more than agreed qty, sending money to vendor (Normal Voucher)
Outbound Claims
	+ve Claim = Shipped is more than the agreed qty; asking money from customer (Normal Invoice)
	-ve Claim = Shipped is less than the agreed qty; sending money to customer (Credit Memo)
*/

/* Validations */
--Standard Validations
--Check for missing GL setup

/* Generate GL Entries */
DECLARE @GLEntries AS RecapTableType;
DECLARE @RecapTable AS RecapTableType;
DECLARE @APClearing AS APClearing;

-- Create a unique transaction name. 
DECLARE @TransactionName AS VARCHAR(500) = 'Weight Claim Transaction' + CAST(NEWID() AS NVARCHAR(100));
BEGIN TRAN @TransactionName
SAVE TRAN @TransactionName

-- Get the batch post Id. 
IF (@strBatchId IS NULL)
BEGIN
	IF (@ysnRecap = 0)
		EXEC dbo.uspSMGetStartingNumber 3, @strBatchId OUTPUT 
	ELSE
		SELECT @strBatchId = NEWID()
END

--Construct Data for generating GL Entries
IF (@intPurchaseSale = 2) 
BEGIN /* Outbound Claims */
	RETURN;
END
ELSE
BEGIN /* Inbound Claims */
	IF (@ysnPost = 1)
	BEGIN
		--Post
		WITH ForGLEntries_CTE (
			dtmDate
			,intItemId
			,intItemLocationId
			,intTransactionId
			,strTransactionId
			,intTransactionDetailId
			,strTransactionTypeName
			,strTransactionForm
			,dblCost
			,intCurrencyId
			,dblExchangeRate
			,dblForexRate
			,strRateType
			,strItemNo
			,intEntityId
			,intAPAccountId
			,intAPClearingAccountId
			)
		AS (SELECT 
			dtmDate = GETDATE()
			,intItemId = WCD.intItemId
			,intItemLocationId = IL.intItemLocationId
			,intTransactionId = WC.intWeightClaimId
			,strTransactionId = WC.strReferenceNumber
			,intTransactionDetailId = WCD.intWeightClaimDetailId
			,strTransactionTypeName = 'Weight Claim'
			,strTransactionForm = 'Weight Claims'
			,dblCost = WCD.dblClaimAmount / (CASE WHEN (CUR.ysnSubCurrency = 1) THEN ISNULL(CUR.intCent, 100) ELSE 1 END)
			,intCurrencyId = ISNULL(CUR.intMainCurrencyId, CUR.intCurrencyID)
			,dblExchangeRate = ISNULL(1, 1)
			,dblForexRate = CASE WHEN (@intFunctionalCurrencyId <> ISNULL(CUR.intMainCurrencyId, CUR.intCurrencyID)) 
								THEN ISNULL(FX.dblFXRate, 1) ELSE 1 END
			,strRateType = FX.strRateType
			,strItemNo = I.strItemNo
			,intEntityId = WCD.intPartyEntityId
			,intAPAccountId = CL.intAPAccount
			,intAPClearingAccountId = dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, 'AP Clearing')
		FROM tblLGWeightClaimDetail WCD
			INNER JOIN tblLGWeightClaim WC ON WC.intWeightClaimId = WCD.intWeightClaimId
			INNER JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
			INNER JOIN tblICItem I ON I.intItemId = WCD.intItemId
			LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = WCD.intCurrencyId
			OUTER APPLY (
				SELECT TOP 1 intLoadDetailId, intPCompanyLocationId 
				FROM tblLGLoadDetail WHERE intLoadId = L.intLoadId AND intPContractDetailId = WCD.intContractDetailId) LD
			LEFT JOIN tblICItemLocation IL ON IL.intItemId = WCD.intItemId AND IL.intLocationId = LD.intPCompanyLocationId
			LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = LD.intPCompanyLocationId
			OUTER APPLY (
				SELECT	TOP 1  
					intForexRateTypeId = ERD.intRateTypeId
					,strRateType = ERT.strCurrencyExchangeRateType
					,dblFXRate = CASE WHEN ER.intFromCurrencyId = @intFunctionalCurrencyId  
								THEN 1/ERD.[dblRate] 
								ELSE ERD.[dblRate] END 
					FROM tblSMCurrencyExchangeRate ER JOIN tblSMCurrencyExchangeRateDetail ERD ON ERD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
					LEFT JOIN tblSMCurrencyExchangeRateType ERT ON ERT.intCurrencyExchangeRateTypeId = ERD.intRateTypeId
					WHERE @intFunctionalCurrencyId <> WCD.intCurrencyId
						AND ((ER.intFromCurrencyId = ISNULL(CUR.intMainCurrencyId, CUR.intCurrencyID) AND ER.intToCurrencyId = @intFunctionalCurrencyId) 
							OR (ER.intFromCurrencyId = @intFunctionalCurrencyId AND ER.intToCurrencyId = ISNULL(CUR.intMainCurrencyId, CUR.intCurrencyID)))
					ORDER BY ERD.dtmValidFromDate DESC) FX
		WHERE WCD.intWeightClaimId = @intWeightClaimsId
		)

		INSERT INTO @GLEntries (
			[dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[strRateType]
			)
		-------------------------------------------------------------------------------------------
		-- Inbound Claim Weight Loss Impact
		-- Dr...... AP 
		-- Cr.................... AP Clearing	
		-------------------------------------------------------------------------------------------
		SELECT dtmDate = ForGLEntries_CTE.dtmDate
			,strBatchId = @strBatchId
			,intAccountId = GLAccount.intAccountId
			,dblDebit = Debit.Value
			,dblCredit = 0
			,dblDebitUnit = 0
			,dblCreditUnit = 0
			,strDescription = ISNULL(GLAccount.strDescription, '') + ', ' + ForGLEntries_CTE.strItemNo
			,strCode = 'LG'
			,strReference = ''
			,intCurrencyId = ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate = ForGLEntries_CTE.dblForexRate
			,dtmDateEntered = GETDATE()
			,dtmTransactionDate = ForGLEntries_CTE.dtmDate
			,strJournalLineDescription = ''
			,intJournalLineNo = ForGLEntries_CTE.intTransactionDetailId
			,ysnIsUnposted = 0
			,intUserId = @intEntityUserSecurityId
			,intEntityId = ForGLEntries_CTE.intEntityId
			,strTransactionId = ForGLEntries_CTE.strTransactionId
			,intTransactionId = ForGLEntries_CTE.intTransactionId
			,strTransactionType = ForGLEntries_CTE.strTransactionTypeName
			,strTransactionForm = ForGLEntries_CTE.strTransactionForm
			,strModuleName = 'Logistics'
			,intConcurrencyId = 1
			,dblDebitForeign = CASE 
				WHEN intCurrencyId <> @intFunctionalCurrencyId
					THEN DebitForeign.Value
				ELSE 0
				END
			,dblDebitReport = NULL
			,dblCreditForeign = 0
			,dblCreditReport = NULL
			,dblReportingRate = NULL
			,dblForeignRate = ForGLEntries_CTE.dblForexRate
			,strRateType = ForGLEntries_CTE.strRateType
		FROM ForGLEntries_CTE
		INNER JOIN dbo.tblGLAccount GLAccount ON GLAccount.intAccountId = ForGLEntries_CTE.intAPAccountId
		CROSS APPLY dbo.fnGetDebitFunctional(ForGLEntries_CTE.dblCost, ForGLEntries_CTE.intCurrencyId, @intFunctionalCurrencyId, ForGLEntries_CTE.dblForexRate) Debit
		CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) DebitForeign
		WHERE ForGLEntries_CTE.intItemId IS NOT NULL
	
		UNION ALL
	
		SELECT dtmDate = ForGLEntries_CTE.dtmDate
			,strBatchId = @strBatchId
			,intAccountId = GLAccount.intAccountId
			,dblDebit = 0
			,dblCredit = Credit.Value
			,dblDebitUnit = 0
			,dblCreditUnit = 0
			,strDescription = ISNULL(GLAccount.strDescription, '') + ', ' + ForGLEntries_CTE.strItemNo
			,strCode = 'LG'
			,strReference = ''
			,intCurrencyId = ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate = ForGLEntries_CTE.dblForexRate
			,dtmDateEntered = GETDATE()
			,dtmTransactionDate = ForGLEntries_CTE.dtmDate
			,strJournalLineDescription = ''
			,intJournalLineNo = ForGLEntries_CTE.intTransactionDetailId
			,ysnIsUnposted = 0
			,intUserId = @intEntityUserSecurityId
			,intEntityId = ForGLEntries_CTE.intEntityId
			,strTransactionId = ForGLEntries_CTE.strTransactionId
			,intTransactionId = ForGLEntries_CTE.intTransactionId
			,strTransactionType = ForGLEntries_CTE.strTransactionTypeName
			,strTransactionForm = ForGLEntries_CTE.strTransactionForm
			,strModuleName = 'Logistics'
			,intConcurrencyId = 1
			,dblDebitForeign = 0
			,dblDebitReport = NULL
			,dblCreditForeign = CASE 
				WHEN intCurrencyId <> @intFunctionalCurrencyId
					THEN CreditForeign.Value
				ELSE 0
				END
			,dblCreditReport = NULL
			,dblReportingRate = NULL
			,dblForeignRate = ForGLEntries_CTE.dblForexRate
			,strRateType = ForGLEntries_CTE.strRateType
		FROM ForGLEntries_CTE
		INNER JOIN dbo.tblGLAccount GLAccount ON GLAccount.intAccountId = ForGLEntries_CTE.intAPClearingAccountId
		CROSS APPLY dbo.fnGetCreditFunctional(-ForGLEntries_CTE.dblCost, ForGLEntries_CTE.intCurrencyId, @intFunctionalCurrencyId, ForGLEntries_CTE.dblForexRate) Credit
		CROSS APPLY dbo.fnGetCredit(-ForGLEntries_CTE.dblCost) CreditForeign
		WHERE ForGLEntries_CTE.intItemId IS NOT NULL
	END
	ELSE
	BEGIN
		--Unpost
		SELECT	@strBatchId = MAX(strBatchId)
		FROM tblGLDetail
		WHERE strTransactionId = @strTransactionId
				AND intTransactionId = @intWeightClaimsId
				AND strTransactionType = 'Weight Claim'
				AND strModuleName = 'Logistics'
				AND ysnIsUnposted = 0
				AND strCode = ISNULL('LG', strCode)

		INSERT INTO @GLEntries (
			[dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[strRateType]
			)
		SELECT	
			[dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit] = [dblCredit]
			,[dblCredit] = [dblDebit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered] = GETDATE()
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted] = 1
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign] = [dblCreditForeign]
			,[dblDebitReport] = [dblCreditReport]
			,[dblCreditForeign] = [dblDebitForeign]
			,[dblCreditReport] = [dblDebitReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[strRateType] = ''
		FROM tblGLDetail 
		WHERE strTransactionId = @strTransactionId
				AND intTransactionId = @intWeightClaimsId
				AND strTransactionType = 'Weight Claim'
				AND strModuleName = 'Logistics'
				AND ysnIsUnposted = 0
				AND strCode = ISNULL('LG', strCode)
		ORDER BY intGLDetailId

		UPDATE tblGLDetail
		SET ysnIsUnposted = 1
		WHERE strTransactionId = @strTransactionId
		AND strBatchId = @strBatchId
	END

END

/* Recap or Book GL */
IF @ysnRecap = 1
BEGIN 
	ROLLBACK TRAN @TransactionName
	EXEC dbo.uspGLPostRecap @GLEntries, @intEntityUserSecurityId
	COMMIT TRAN @TransactionName
END  
ELSE
BEGIN
	EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost

	--Insert AP Clearing
	INSERT INTO @APClearing (
		intTransactionId
		,strTransactionId
		,intTransactionType
		,strReferenceNumber
		,dtmDate
		,intEntityVendorId
		,intLocationId
		,intTransactionDetailId
		,intAccountId
		,intItemId
		,intItemUOMId
		,dblQuantity
		,dblAmount
		,intOffsetId
		,strOffsetId
		,intOffsetDetailId
		,intOffsetDetailTaxId
		,strCode)
	SELECT DISTINCT
		intTransactionId = GL.intTransactionId
		,strTransactionId = GL.strTransactionId
		,intTransactionType = 11
		,strReferenceNumber = L.strBLNumber
		,dtmDate = GL.dtmDate
		,intEntityVendorId = WCD.intPartyEntityId
		,intLocationId = GL.intCompanyLocationId
		,intTransactionDetailId = WCD.intWeightClaimDetailId
		,intAccountId = GL.intAccountId
		,intItemId = WCD.intItemId
		,intItemUOMId = IUOM.intItemUOMId
		,dblQuantity = ABS(WCD.dblClaimableWt)
		,dblAmount = ABS(GL.dblDebit - GL.dblCredit)
		,intOffsetId = NULL
		,strOffsetId = NULL
		,intOffsetDetailId = NULL
		,intOffsetDetailTaxId = NULL
		,strCode = GL.strCode
	FROM tblLGWeightClaim WC
		INNER JOIN tblLGWeightClaimDetail WCD ON WCD.intWeightClaimId = WC.intWeightClaimId
		INNER JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
		INNER JOIN @GLEntries GL ON GL.intTransactionId = L.intLoadId AND GL.intJournalLineNo = WCD.intWeightClaimDetailId
		LEFT JOIN tblICItemLocation IL ON IL.intItemId = WCD.intItemId AND GL.intCompanyLocationId = IL.intLocationId
		LEFT JOIN tblICItemUOM IUOM ON IUOM.intItemId = WCD.intItemId AND IUOM.intUnitMeasureId = L.intWeightUnitMeasureId
	WHERE GL.intAccountId = dbo.fnGetItemGLAccount(WCD.intItemId, IL.intItemLocationId, 'AP Clearing')

	EXEC uspAPClearing @APClearing, @ysnPost

	COMMIT TRAN @TransactionName
END

/* Create Payables */

/* Audit Log, etc. */
IF (@ysnRecap = 0)
BEGIN
	SET @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted' WHEN @ysnPost = 0 THEN 'Unposted' END
	EXEC uspSMAuditLog
		@keyValue = @intWeightClaimsId,
		@screenName = 'Logistics.view.WeightClaims',
		@entityId = @intEntityUserSecurityId,
		@actionType = @actionType
END

END 