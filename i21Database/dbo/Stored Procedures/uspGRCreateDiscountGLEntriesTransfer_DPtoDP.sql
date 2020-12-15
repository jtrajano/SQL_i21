CREATE PROCEDURE [dbo].[uspGRCreateDiscountGLEntriesTransfer_DPtoDP]
	@strBatchId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT
	,@intTransactionDetailId INT
	,@intSourceTransactionDetailId INT = NULL
	,@ysnUnpost BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Get the default currency ID
DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
DECLARE @strTransactionForm NVARCHAR(255)
DECLARE @strBatchId2 AS NVARCHAR(40)

-- Initialize the module name
DECLARE @ModuleName AS NVARCHAR(50) = 'Grain';

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END

IF @ysnUnpost = 1
BEGIN
	SELECT TOP 1 @strBatchId2 = strBatchId FROM tblGRTransferGLEntriesCTE WHERE intSourceTransactionDetailId = @intTransactionDetailId
END
;

-- Generate the G/L Entries here: 
WITH ForGLEntries_CTE (
	intSourceTransactionId
	,intSourceTransactionDetailId
	,strSourceTransactionId
	,intTransactionId
	,intTransactionDetailId
	,strTransactionId
	,dblCost
	,dblQty
	,intCurrencyId
	,dblUOMQty
	,strRateType
	,dtmDate
	,intAccountId
	,strTransactionType
	,strItemNo
)
AS
(
	SELECT
		intSourceTransactionId
		,intSourceTransactionDetailId
		,strSourceTransactionId
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,CASE WHEN QM.strDiscountChargeType = 'Percent' THEN (QM.dblDiscountDue - QM.dblDiscountPaid) * dblCost ELSE (QM.dblDiscountDue - QM.dblDiscountPaid) END
		,CASE WHEN QM.strCalcMethod = 3 /*GROSS*/ THEN (dblQty / CS.dblOriginalBalance) * CS.dblGrossQuantity ELSE dblQty END
		,CS.intCurrencyId
		,A.dblUOMQty
		,A.strRateType
		,A.dtmDate
		,0
		,A.strTransactionType
		,DItem.strItemNo
	FROM tblGRTransferGLEntriesCTE A
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intTransferStorageReferenceId = A.intSourceTransactionDetailId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = TSR.intSourceCustomerStorageId
	INNER JOIN tblQMTicketDiscount QM 
		ON QM.intTicketFileId = CS.intCustomerStorageId 
			AND QM.strSourceType = 'Storage'
	INNER JOIN tblGRDiscountScheduleCode DSC
		ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
	INNER JOIN tblGRDiscountCalculationOption DCO
		ON DCO.intDiscountCalculationOptionId = DSC.intDiscountCalculationOptionId
	INNER JOIN tblICItem DItem 
		ON DItem.intItemId = DSC.intItemId
	WHERE (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0 
		AND intSourceTransactionDetailId = @intTransactionDetailId
		AND strTransactionType = 'Source'

	UNION ALL

	SELECT
		intSourceTransactionId
		,intSourceTransactionDetailId
		,strSourceTransactionId
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,CASE WHEN QM.strDiscountChargeType = 'Percent' THEN (QM.dblDiscountDue - QM.dblDiscountPaid) * dblCost ELSE (QM.dblDiscountDue - QM.dblDiscountPaid) END
		,CASE WHEN QM.strCalcMethod = 3 /*GROSS*/ THEN (dblQty / CS.dblOriginalBalance) * CS.dblGrossQuantity ELSE dblQty END
		,CS.intCurrencyId
		,A.dblUOMQty
		,A.strRateType
		,A.dtmDate
		,dbo.fnGetItemGLAccount(DItem.intItemId, IL.intItemLocationId, 'AP Clearing')
		,'To'
		,DItem.strItemNo
	FROM tblGRTransferGLEntriesCTE A
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intTransferStorageReferenceId = A.intSourceTransactionDetailId
	INNER JOIN tblGRCustomerStorage CS_TO
		ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = TSR.intSourceCustomerStorageId
	INNER JOIN tblQMTicketDiscount QM 
		ON QM.intTicketFileId = CS.intCustomerStorageId 
			AND QM.strSourceType = 'Storage'
	INNER JOIN tblGRDiscountScheduleCode DSC
		ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
	INNER JOIN tblGRDiscountCalculationOption DCO
		ON DCO.intDiscountCalculationOptionId = DSC.intDiscountCalculationOptionId
	INNER JOIN tblICItem DItem 
		ON DItem.intItemId = DSC.intItemId
	INNER JOIN tblICItemLocation IL
		ON IL.intItemId = DItem.intItemId
			AND IL.intLocationId = CS_TO.intCompanyLocationId
	WHERE (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0 
		AND intSourceTransactionDetailId = @intTransactionDetailId
		AND strTransactionType = 'Source'
)

------------------------------------------------------------------------------------------
--OFFSET APC FROM SOURCE
-------------------------------------------------------------------------------------------
SELECT	
	dtmDate						= ForGLEntries_CTE.dtmDate
	,strBatchId					= @strBatchId
	,intAccountId				= C.intAccountId
	,dblDebit					= Credit.Value
	,dblCredit					= Debit.Value
	,dblDebitUnit				= DebitUnit.Value
	,dblCreditUnit				= CreditUnit.Value
	,strDescription				= GL.strDescription --+ ' A'--ISNULL(C.strDescription, '') + ', Charges from ' + ForGLEntries_CTE.strItemNo + ' a'
	,strCode					= 'TRA'
	,strReference				= '' 
	,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	,dblExchangeRate			= 1--GL.dblExchangeRate
	,dtmDateEntered				= GETDATE()
	,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
    ,strJournalLineDescription  = '' 
	,intJournalLineNo			= ForGLEntries_CTE.intTransactionDetailId
	,ysnIsUnposted				= 0
	,intUserId					= @intEntityUserSecurityId
	,intEntityId				= GL.intEntityId 
	,strTransactionId			= ForGLEntries_CTE.strTransactionId
	,intTransactionId			= ForGLEntries_CTE.intTransactionId
	,strTransactionType			= 'Transfer Storage'
	,strTransactionForm			= 'Transfer Storage'
	,strModuleName				= @ModuleName
	,intConcurrencyId			= 1
	,dblDebitForeign			= DebitForeign.Value
	,dblDebitReport				= NULL--CASE WHEN GL.dblDebitReport = 0 THEN GL.dblCreditReport ELSE 0 END
	,dblCreditForeign			= CreditForeign.Value
	,dblCreditReport			= NULL--CASE WHEN GL.dblCreditReport = 0 THEN GL.dblDebitReport ELSE 0 END
	,dblReportingRate			= NULL--GL.dblReportingRate
	,dblForeignRate				= GL.dblForeignRate
	,strRateType				= ForGLEntries_CTE.strRateType 
FROM tblGLDetail GL
INNER JOIN ForGLEntries_CTE
	ON ForGLEntries_CTE.intTransactionId = GL.intTransactionId
		AND ForGLEntries_CTE.strTransactionId = GL.strTransactionId
		AND ForGLEntries_CTE.strItemNo = REPLACE(SUBSTRING(GL.strDescription, CHARINDEX('Charges from ', GL.strDescription), LEN(GL.strDescription) -1),'Charges from ','')
INNER JOIN vyuGLAccountDetail C
	ON C.intAccountId = GL.intAccountId
		AND C.intAccountCategoryId = 45 --AP CLEARING ONLY
CROSS APPLY dbo.fnGetDebit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0))) Debit
CROSS APPLY dbo.fnGetCredit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0))) Credit
CROSS APPLY dbo.fnGetDebitUnit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblUOMQty, 1))) DebitUnit
CROSS APPLY dbo.fnGetCreditUnit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblUOMQty, 1))) CreditUnit
CROSS APPLY dbo.fnGetDebitForeign(
	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)), 0)	
	,ForGLEntries_CTE.intCurrencyId
	,@intFunctionalCurrencyId
	,1--,ForGLEntries_CTE.dblForexRate
) DebitForeign
CROSS APPLY dbo.fnGetCreditForeign(
	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)), 0) 			
	,ForGLEntries_CTE.intCurrencyId
	,@intFunctionalCurrencyId
	,1--,ForGLEntries_CTE.dblForexRate
) CreditForeign
WHERE GL.strDescription LIKE '%Charges from%'
	AND GL.ysnIsUnposted = 0
	AND ForGLEntries_CTE.strTransactionType = 'Source'

UNION ALL

-------------------------------------------------------------------------------------------
--OPEN CLEARING FOR NEW DP STORAGE
-------------------------------------------------------------------------------------------
SELECT	
	dtmDate						= ForGLEntries_CTE.dtmDate
	,strBatchId					= @strBatchId
	,intAccountId				= ForGLEntries_CTE.intAccountId
	,dblDebit					= CASE WHEN GL.dblDebit = 0 THEN 0 ELSE Debit.Value END
	,dblCredit					= CASE WHEN GL.dblCredit = 0 THEN 0 ELSE Credit.Value END
	,dblDebitUnit				= CASE WHEN GL.dblDebitUnit = 0 THEN 0 ELSE DebitUnit.Value END
	,dblCreditUnit				= CASE WHEN GL.dblCreditUnit = 0 THEN 0 ELSE CreditUnit.Value END
	,strDescription				= ISNULL(GLA.strDescription, '') + ', Charges from ' + ForGLEntries_CTE.strItemNo --+ ' B'
	,strCode					= 'TRA'
	,strReference				= '' 
	,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	,dblExchangeRate			= 1--GL.dblExchangeRate
	,dtmDateEntered				= GETDATE()
	,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
    ,strJournalLineDescription  = '' 
	,intJournalLineNo			= ForGLEntries_CTE.intSourceTransactionDetailId
	,ysnIsUnposted				= 0
	,intUserId					= @intEntityUserSecurityId
	,intEntityId				= GL.intEntityId 
	,strTransactionId			= ForGLEntries_CTE.strSourceTransactionId
	,intTransactionId			= ForGLEntries_CTE.intSourceTransactionId
	,strTransactionType			= 'Transfer Storage'
	,strTransactionForm			= 'Transfer Storage'
	,strModuleName				= @ModuleName
	,intConcurrencyId			= 1
	,dblDebitForeign			= DebitForeign.Value
	,dblDebitReport				= NULL--CASE WHEN GL.dblDebitReport = 0 THEN GL.dblCreditReport ELSE 0 END
	,dblCreditForeign			= CreditForeign.Value
	,dblCreditReport			= NULL--CASE WHEN GL.dblCreditReport = 0 THEN GL.dblDebitReport ELSE 0 END
	,dblReportingRate			= NULL--GL.dblReportingRate
	,dblForeignRate				= GL.dblForeignRate
	,strRateType				= ForGLEntries_CTE.strRateType 
FROM tblGLDetail GL
INNER JOIN ForGLEntries_CTE
	ON ForGLEntries_CTE.intTransactionId = GL.intTransactionId
		AND ForGLEntries_CTE.strTransactionId = GL.strTransactionId
		AND ForGLEntries_CTE.strItemNo = REPLACE(SUBSTRING(GL.strDescription, CHARINDEX('Charges from ', GL.strDescription), LEN(GL.strDescription) -1),'Charges from ','')
INNER JOIN vyuGLAccountDetail C
	ON C.intAccountId = GL.intAccountId
		AND C.intAccountCategoryId = 45 --AP CLEARING ONLY
CROSS APPLY dbo.fnGetDebit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0))) Debit
CROSS APPLY dbo.fnGetCredit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0))) Credit
CROSS APPLY dbo.fnGetDebitUnit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblUOMQty, 1))) DebitUnit
CROSS APPLY dbo.fnGetCreditUnit(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblUOMQty, 1))) CreditUnit
CROSS APPLY dbo.fnGetDebitForeign(
	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)), 0)	
	,ForGLEntries_CTE.intCurrencyId
	,@intFunctionalCurrencyId
	,1--,ForGLEntries_CTE.dblForexRate
) DebitForeign
CROSS APPLY dbo.fnGetCreditForeign(
	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)), 0) 			
	,ForGLEntries_CTE.intCurrencyId
	,@intFunctionalCurrencyId
	,1--,ForGLEntries_CTE.dblForexRate
) CreditForeign
CROSS APPLY (SELECT strDescription FROM tblGLAccount GLA WHERE intAccountId = ForGLEntries_CTE.intAccountId) GLA
WHERE GL.strDescription LIKE '%Charges from%'
	AND GL.ysnIsUnposted = 0
	AND ForGLEntries_CTE.strTransactionType = 'To'
;