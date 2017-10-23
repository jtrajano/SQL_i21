CREATE PROCEDURE [dbo].[uspPATPostIssueStock]
	@intCustomerStockId INT = NULL,
	@ysnPosted BIT = NULL,
	@ysnRecap BIT = NULL,
	@ysnRetired BIT = NULL,
	@intCompanyLocationId INT = NULL,
	@intUserId INT = NULL,
	@batchIdUsed NVARCHAR(40) = NULL OUTPUT,
	@error NVARCHAR(200) = NULL OUTPUT,
	@successfulCount INT = 0 OUTPUT,
	@invalidCount INT = 0 OUTPUT,
	@success BIT = 0 OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION -- START TRANSACTION

DECLARE @dateToday AS DATETIME = GETDATE();
DECLARE @GLEntries AS RecapTableType;
DECLARE @totalRecords INT;
DECLARE @batchId NVARCHAR(40);
DECLARE @isGLSucces AS BIT = 0;
DECLARE @intCreatedId INT;
DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage';
DECLARE @RETIRE_STOCK NVARCHAR(25) = 'Retire Stock';
DECLARE @ISSUE_STOCK NVARCHAR(25) = 'Issue Stock';
DECLARE @MODULE_CODE NVARCHAR(5)  = 'PAT';
DECLARE @batchId2 AS NVARCHAR(40);
DECLARE @voidRetire AS BIT = 0;
DECLARE @voucherId as Id;

CREATE TABLE #tempValidateTable (
	[strError] [NVARCHAR](MAX),
	[strTransactionType] [NVARCHAR](50),
	[strTransactionNo] [NVARCHAR](50),
	[intTransactionId] INT
);

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId;

	SELECT	CS.intCustomerStockId,
			CS.intCustomerPatronId,
			CS.intStockId,
			CS.strCertificateNo,
			CS.strStockStatus,
			CS.dblSharesNo,
			CS.dtmIssueDate,
			CS.strActivityStatus,
			CS.dtmRetireDate,
			CS.intTransferredFrom,
			CS.dtmTransferredDate,
			CS.dblParValue,
			CS.dblFaceValue,
			CS.intBillId,
			CS.intInvoiceId,
			CS.ysnPosted,
			CS.ysnRetiredPosted
	INTO #tempCustomerStock
	FROM tblPATCustomerStock CS
		WHERE intCustomerStockId = @intCustomerStockId
		

IF(ISNULL(@ysnPosted,0) = 0)
BEGIN
	-------- VALIDATE IF CAN BE UNPOSTED
	DECLARE @type AS INT = CASE WHEN @ysnRetired = 0 THEN 1 ELSE 2 END;

	INSERT INTO #tempValidateTable
	SELECT * FROM fnPATValidateAssociatedTransaction((SELECT intCustomerStockId FROM #tempCustomerStock), @type, @MODULE_NAME)

	SELECT * FROM #tempValidateTable
	IF EXISTS(SELECT 1 FROM #tempValidateTable)
	BEGIN
		SELECT @error = V.strError FROM #tempValidateTable V
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback;
	END
END


IF (@ysnRetired = 1)
BEGIN
	IF(@ysnPosted = 1)
	BEGIN

	------------------------CREATE GL ENTRIES---------------------
		INSERT INTO @GLEntries(
			[dtmDate], 
			[strBatchId], 
			[intAccountId],
			[dblDebit],
			[dblCredit],
			[dblDebitUnit],
			[dblCreditUnit],
			[strDescription],
			[strCode],
			[strReference],
			[intCurrencyId],
			[dtmDateEntered],
			[dtmTransactionDate],
			[strJournalLineDescription],
			[intJournalLineNo],
			[ysnIsUnposted],
			[intUserId],
			[intEntityId],
			[strTransactionId],
			[intTransactionId],
			[strTransactionType],
			[strTransactionForm],
			[strModuleName],
			[dblDebitForeign],
			[dblDebitReport],
			[dblCreditForeign],
			[dblCreditReport],
			[dblReportingRate],
			[dblForeignRate],
			[strRateType]
		)
		--VOTING STOCK/NON-VOTING STOCK/OTHER ISSUED
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmIssueDate), 0),
			[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
			[intAccountId]					=	CASE WHEN A.strStockStatus = 'Voting' THEN ComPref.intVotingStockId ELSE ComPref.intNonVotingStockId END,
			[dblDebit]						=	ROUND(A.dblFaceValue, 2),
			[dblCredit]						=	0,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	CASE WHEN A.strStockStatus = 'Voting' THEN 'Posted Voting Retired Stock' ELSE 'Posted Non-Voting/Other Retired Stock' END,
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strCertificateNo,
			[intCurrencyId]					=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	CASE WHEN A.strStockStatus = 'Voting' THEN 'Posted Voting Retired Stock' ELSE 'Posted Non-Voting/Other Retired Stock' END,
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.intCustomerStockId, 
			[intTransactionId]				=	A.intCustomerStockId, 
			[strTransactionType]			=	CASE WHEN A.strStockStatus = 'Voting' THEN 'Voting' ELSE 'Non-Voting/Other' END,
			[strTransactionForm]			=	@RETIRE_STOCK,
			[strModuleName]					=	@MODULE_NAME,
			[dblDebitForeign]				=	0,      
			[dblDebitReport]				=	0,
			[dblCreditForeign]				=	0,
			[dblCreditReport]				=	0,
			[dblReportingRate]				=	0,
			[dblForeignRate]				=	0,
			[strRateType]					=	NULL
		FROM	[dbo].[tblPATCustomerStock] A
				CROSS JOIN tblPATCompanyPreference ComPref
		WHERE	A.intCustomerStockId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intCustomerStockId))
		UNION ALL
		--AP CLEARING
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmIssueDate), 0),
			[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
			[intAccountId]					=	ComPref.intAPClearingGLAccount,
			[dblDebit]						=	0,
			[dblCredit]						=	ROUND(A.dblFaceValue,2),
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	'Posted AP Clearing for Retire Stock',
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strCertificateNo,
			[intCurrencyId]					=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	'Posted AP Clearing for Retire Stock',
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.intCustomerStockId, 
			[intTransactionId]				=	A.intCustomerStockId, 
			[strTransactionType]			=	'Retire Stock',
			[strTransactionForm]			=	@RETIRE_STOCK,
			[strModuleName]					=	@MODULE_NAME,
			[dblDebitForeign]				=	0,      
			[dblDebitReport]				=	0,
			[dblCreditForeign]				=	0,
			[dblCreditReport]				=	0,
			[dblReportingRate]				=	0,
			[dblForeignRate]				=	0,
			[strRateType]					=	NULL
		FROM	[dbo].[tblPATCustomerStock] A
				CROSS JOIN tblPATCompanyPreference ComPref
		WHERE	A.intCustomerStockId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intCustomerStockId))
		

	END
	ELSE
	BEGIN
	------------------------REVERSE GL ENTRIES---------------------
		INSERT INTO @GLEntries(
			[strTransactionId]
			,[intTransactionId]
			,[dtmDate]
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
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[dblDebitForeign]           
			,[dblDebitReport]            
			,[dblCreditForeign]          
			,[dblCreditReport]           
			,[dblReportingRate]          
			,[dblForeignRate]
			,[strRateType]
		)
		SELECT	
			[strTransactionId]
			,[intTransactionId]
			,[dtmDate]
			,strBatchId = @batchId COLLATE Latin1_General_CI_AS
			,[intAccountId]
			,[dblDebit] = [dblCredit]		-- (Debit -> Credit)
			,[dblCredit] = [dblDebit]		-- (Debit <- Credit)
			,[dblDebitUnit] = [dblCreditUnit]	-- (Debit Unit -> Credit Unit)
			,[dblCreditUnit] = [dblDebitUnit]	-- (Debit Unit <- Credit Unit)
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,dtmDateEntered = GETDATE()
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,ysnIsUnposted = 1
			,intUserId = @intUserId
			,[intEntityId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[dblDebitForeign]           
			,[dblDebitReport]            
			,[dblCreditForeign]          
			,[dblCreditReport]           
			,[dblReportingRate]          
			,[dblForeignRate]
			,NULL
		FROM	tblGLDetail 
		WHERE	intTransactionId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intCustomerStockId))
		AND ysnIsUnposted = 0 AND strTransactionForm = @RETIRE_STOCK AND strModuleName = @MODULE_NAME
		ORDER BY intGLDetailId

		UPDATE tblGLDetail SET ysnIsUnposted = 1
		WHERE intTransactionId = @intCustomerStockId 
			AND strModuleName = @MODULE_NAME AND strTransactionForm = @RETIRE_STOCK
	END
END
ELSE
BEGIN
	IF(@ysnPosted = 1)
	BEGIN

	------------------------CREATE GL ENTRIES---------------------
		INSERT INTO @GLEntries(
			[dtmDate], 
			[strBatchId], 
			[intAccountId],
			[dblDebit],
			[dblCredit],
			[dblDebitUnit],
			[dblCreditUnit],
			[strDescription],
			[strCode],
			[strReference],
			[intCurrencyId],
			[dtmDateEntered],
			[dtmTransactionDate],
			[strJournalLineDescription],
			[intJournalLineNo],
			[ysnIsUnposted],
			[intUserId],
			[intEntityId],
			[strTransactionId],
			[intTransactionId],
			[strTransactionType],
			[strTransactionForm],
			[strModuleName],
			[dblDebitForeign],
			[dblDebitReport],
			[dblCreditForeign],
			[dblCreditReport],
			[dblReportingRate],
			[dblForeignRate],
			[strRateType]
		)
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmIssueDate), 0),
			[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
			[intAccountId]					=	SADef.intSalesAccount,
			[dblDebit]						=	0,
			[dblCredit]						=	ROUND(A.dblFaceValue,2),
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	GL.strDescription,
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strCertificateNo,
			[intCurrencyId]					=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	GL.strDescription,
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.intCustomerStockId, 
			[intTransactionId]				=	A.intCustomerStockId, 
			[strTransactionType]			=	CASE WHEN A.strStockStatus = 'Voting' THEN 'Voting Stock' ELSE 'Non-Voting/Other' END,
			[strTransactionForm]			=	@ISSUE_STOCK,
			[strModuleName]					=	@MODULE_NAME,
			[dblDebitForeign]				=	0,      
			[dblDebitReport]				=	0,
			[dblCreditForeign]				=	0,
			[dblCreditReport]				=	0,
			[dblReportingRate]				=	0,
			[dblForeignRate]				=	0,
			[strRateType]					=	NULL
		FROM	[dbo].[tblPATCustomerStock] A
		CROSS JOIN (SELECT intSalesAccount FROM tblSMCompanyLocation where intCompanyLocationId = @intCompanyLocationId) SADef
		INNER JOIN tblGLAccount GL ON GL.intAccountId = SADef.intSalesAccount
		WHERE	A.intCustomerStockId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intCustomerStockId))
		UNION ALL
		--AR Account
		SELECT	
			[dtmDate]						=	DATEADD(dd, DATEDIFF(dd, 0, A.dtmIssueDate), 0),
			[strBatchID]					=	@batchId COLLATE Latin1_General_CI_AS,
			[intAccountId]					=	ComPref.intARAccountId, 
			[dblDebit]						=	ROUND(A.dblFaceValue,2),
			[dblCredit]						=	0,
			[dblDebitUnit]					=	0,
			[dblCreditUnit]					=	0,
			[strDescription]				=	GL.strDescription,
			[strCode]						=	@MODULE_CODE,
			[strReference]					=	A.strCertificateNo,
			[intCurrencyId]					=	1,
			[dtmDateEntered]				=	GETDATE(),
			[dtmTransactionDate]			=	NULL,
			[strJournalLineDescription]		=	GL.strDescription,
			[intJournalLineNo]				=	1,
			[ysnIsUnposted]					=	0,
			[intUserId]						=	@intUserId,
			[intEntityId]					=	@intUserId,
			[strTransactionId]				=	A.intCustomerStockId, 
			[intTransactionId]				=	A.intCustomerStockId, 
			[strTransactionType]			=	'Voting Stock',
			[strTransactionForm]			=	@ISSUE_STOCK,
			[strModuleName]					=	@MODULE_NAME,
			[dblDebitForeign]				=	0,      
			[dblDebitReport]				=	0,
			[dblCreditForeign]				=	0,
			[dblCreditReport]				=	0,
			[dblReportingRate]				=	0,
			[dblForeignRate]				=	0,
			[strRateType]					=	NULL
		FROM	[dbo].[tblPATCustomerStock] A
		CROSS APPLY tblARCompanyPreference ComPref
		INNER JOIN tblGLAccount GL
			ON ComPref.intARAccountId = GL.intAccountId
		WHERE	A.intCustomerStockId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@intCustomerStockId))

	END
END

BEGIN TRY
IF(ISNULL(@ysnRecap, 0) = 0)
BEGIN
	IF(@ysnRetired = 1)
	BEGIN
		SELECT * FROM @GLEntries;
		EXEC uspGLBookEntries @GLEntries, @ysnPosted;
	END
	SET @isGLSucces = 1;

END
ELSE
BEGIN
		INSERT INTO tblGLPostRecap(
			 [strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strJournalLineDescription]
			,[strReference]	
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[dblExchangeRate]
			,[intUserId]
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]
			,[strModuleName]
			,[strTransactionForm]
			,[strTransactionType]
			,[strAccountId]
			,[strAccountGroup]
		)
		SELECT
			[strTransactionId]
			,A.[intTransactionId]
			,A.[intAccountId]
			,A.[strDescription]
			,A.[strJournalLineDescription]
			,A.[strReference]	
			,A.[dtmTransactionDate]
			,A.[dblDebit]
			,A.[dblCredit]
			,A.[dblDebitUnit]
			,A.[dblCreditUnit]
			,A.[dtmDate]
			,A.[ysnIsUnposted]
			,A.[intConcurrencyId]	
			,A.[dblExchangeRate]
			,A.[intUserId]
			,A.[dtmDateEntered]
			,A.[strBatchId]
			,A.[strCode]
			,A.[strModuleName]
			,A.[strTransactionForm]
			,A.[strTransactionType]
			,B.strAccountId
			,C.strAccountGroup
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B 
			ON A.intAccountId = B.intAccountId
		INNER JOIN dbo.tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId
END
END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE()
	RAISERROR(@error, 16, 1);
	GOTO Post_Rollback
END CATCH




IF(@isGLSucces = 1)
BEGIN

	IF(@batchId2 IS NULL)
		EXEC uspSMGetStartingNumber 3, @batchId2 OUT

	--------------------- RETIRED STOCKS ------------------	
	IF(@ysnRetired = 1)
	BEGIN
		IF(@ysnPosted = 1)
		BEGIN
			DECLARE @voucherDetailNonInventory AS VoucherDetailNonInventory;
			DECLARE @intCustomerId AS INT;
			DECLARE @dblFaceValue AS NUMERIC(18,6);
			DECLARE @strVenderOrderNumber AS NVARCHAR(50);
			DECLARE @apClearing AS INT;

			SELECT 
				@intCustomerId = tempCS.intCustomerPatronId,
				@dblFaceValue = ROUND(tempCS.dblFaceValue,2),
				@strVenderOrderNumber = tempCS.strCertificateNo,
				@apClearing = ComPref.intAPClearingGLAccount
			FROM #tempCustomerStock tempCS
			CROSS APPLY tblPATCompanyPreference ComPref

			INSERT INTO @voucherDetailNonInventory([intAccountId], [strMiscDescription],[dblQtyReceived],[dblDiscount],[dblCost])
			VALUES(@apClearing, 'Patronage Retired Stock', 1, 0, @dblFaceValue);

			EXEC [dbo].[uspAPCreateBillData]
				@userId	= @intUserId
				,@vendorId = @intCustomerId
				,@type = 1	
				,@voucherNonInvDetails = @voucherDetailNonInventory
				,@shipTo = NULL
				,@vendorOrderNumber = @strVenderOrderNumber
				,@voucherDate = @dateToday
				,@billId = @intCreatedId OUTPUT

			UPDATE tblPATCustomerStock SET intBillId = @intCreatedId WHERE intCustomerStockId = @intCustomerStockId;
			UPDATE tblAPBillDetail set intCurrencyId = [dbo].[fnSMGetDefaultCurrency]('FUNCTIONAL') WHERE intBillId = @intCreatedId;

			IF EXISTS(SELECT 1 FROM tblAPBillDetailTax WHERE intBillDetailId IN (SELECT intBillDetailId FROM tblAPBillDetail WHERE intBillId = @intCreatedId))
			BEGIN
				INSERT INTO @voucherId SELECT intBillId FROM tblAPBill where intBillId = @intCreatedId;

				EXEC [dbo].[uspAPDeletePatronageTaxes] @voucherId;

				UPDATE tblAPBill SET dblTax = 0 WHERE intBillId IN (SELECT intBillId FROM @voucherId);
				UPDATE tblAPBillDetail SET dblTax = 0 WHERE intBillId IN (SELECT intBillId FROM @voucherId);

				EXEC uspAPUpdateVoucherTotal @voucherId;
				DELETE FROM @voucherId;
			END

			EXEC [dbo].[uspAPPostBill]
				@batchId = @batchId2,
				@billBatchId = NULL,
				@transactionType = NULL,
				@post = 1,
				@recap = 0,
				@isBatch = 0,
				@param = NULL,
				@userId = @intUserId,
				@beginTransaction = @intCreatedId,
				@endTransaction = @intCreatedId,
				@success = @success OUTPUT


		END
		ELSE
		BEGIN

			DECLARE @voucher AS NVARCHAR(MAX);
			SELECT @voucher = intBillId FROM tblPATCustomerStock WHERE intCustomerStockId = @intCustomerStockId;

			EXEC [dbo].[uspAPPostBill]
					@batchId = NULL,
					@billBatchId = NULL,
					@transactionType = @MODULE_NAME,
					@post = 0,
					@recap = 0,
					@isBatch = 0,
					@param = @voucher,
					@userId = @intUserId,
					@beginTransaction = NULL,
					@endTransaction = NULL,
					@success = @success OUTPUT

			IF(@success = 0)
			BEGIN
				SET @error = 'Unable to unpost transaction';
				RAISERROR(@error, 16, 1);
				GOTO Post_Rollback;
			END
			
			DELETE FROM tblAPBill WHERE intBillId IN (SELECT intBillId FROM #tempCustomerStock) AND ysnPaid <> 1;
			UPDATE tblPATCustomerStock
			SET strActivityStatus = 'Open',
				dtmRetireDate = null,
				intBillId = null
			WHERE intCustomerStockId = @intCustomerStockId
		END
		---------- UPDATE CUSTOMER STOCK TABLE ---------------
		UPDATE tblPATCustomerStock SET ysnRetiredPosted = @ysnPosted WHERE intCustomerStockId = @intCustomerStockId;

	END
	ELSE
	BEGIN
		IF(@ysnPosted = 1)
		BEGIN
			DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable;

			INSERT INTO @EntriesForInvoice(
				[strSourceTransaction]
				,[intSourceId]
				,[strSourceId]
				,[intInvoiceId]
				,[intEntityCustomerId]
				,[intCompanyLocationId]
				,[intCurrencyId]
				,[intTermId]
				,[dtmDate]
				,[dtmDueDate]
				,[dtmShipDate]
				,[intEntitySalespersonId]
				,[intFreightTermId]
				,[intShipViaId]
				,[intPaymentMethodId]
				,[strInvoiceOriginId]
				,[strPONumber]
				,[strBOLNumber]
				,[strDeliverPickup]
				,[strComments]
				,[intShipToLocationId]
				,[intBillToLocationId]
				,[ysnTemplate]
				,[ysnForgiven]
				,[ysnCalculated]
				,[ysnSplitted]
				,[intPaymentId]
				,[intSplitId]
				,[intLoadDistributionHeaderId]
				,[strActualCostId]
				,[intShipmentId]
				,[intTransactionId]
				,[intEntityId]
				,[ysnResetDetails]
				,[ysnPost]
				,[intInvoiceDetailId]
				,[intItemId]
				,[ysnInventory]
				,[strItemDescription]
				,[intItemUOMId]
				,[dblQtyOrdered]
				,[dblQtyShipped]
				,[dblDiscount]
				,[dblPrice]
				,[ysnRefreshPrice]
				,[strMaintenanceType]
				,[strFrequency]
				,[dtmMaintenanceDate]
				,[dblMaintenanceAmount]
				,[dblLicenseAmount]
				,[intTaxGroupId]
				,[ysnRecomputeTax]
				,[intSCInvoiceId]
				,[strSCInvoiceNumber]
				,[intInventoryShipmentItemId]
				,[strShipmentNumber]
				,[intSalesOrderDetailId]
				,[strSalesOrderNumber]
				,[intContractHeaderId]
				,[intContractDetailId]
				,[intShipmentPurchaseSalesContractId]
				,[intTicketId]
				,[intTicketHoursWorkedId]
				,[intSiteId]
				,[strBillingBy]
				,[dblPercentFull]
				,[dblNewMeterReading]
				,[dblPreviousMeterReading]
				,[dblConversionFactor]
				,[intPerformerId]
				,[ysnLeaseBilling]
				,[ysnVirtualMeterReading]
				,[ysnClearDetailTaxes]					
				,[intTempDetailIdForTaxes]
				,[intSalesAccountId]
			)
			SELECT
				[strSourceTransaction]					= 'Patronage'
				,[intSourceId]							= CS.intCustomerStockId
				,[strSourceId]							= CS.strCertificateNo
				,[intInvoiceId]							= NULL
				,[intEntityCustomerId]					= CS.intCustomerPatronId
				,[intCompanyLocationId]					= @intCompanyLocationId
				,[intCurrencyId]						= ARC.intCurrencyId
				,[intTermId]							= ARC.intTermsId
				,[dtmDate]								= CS.dtmIssueDate
				,[dtmDueDate]							= NULL
				,[dtmShipDate]							= CS.dtmIssueDate
				,[intEntitySalespersonId]				= NULL
				,[intFreightTermId]						= NULL 
				,[intShipViaId]							= NULL 
				,[intPaymentMethodId]					= NULL
				,[strInvoiceOriginId]					= ''
				,[strPONumber]							= ''
				,[strBOLNumber]							= ''
				,[strDeliverPickup]						= ''
				,[strComments]							= CS.strCertificateNo
				,[intShipToLocationId]					= NULL
				,[intBillToLocationId]					= NULL
				,[ysnTemplate]							= 0
				,[ysnForgiven]							= 0
				,[ysnCalculated]						= 0
				,[ysnSplitted]							= 0
				,[intPaymentId]							= NULL
				,[intSplitId]							= NULL
				,[intLoadDistributionHeaderId]			= NULL
				,[strActualCostId]						= ''
				,[intShipmentId]						= NULL
				,[intTransactionId]						= CS.intCustomerStockId
				,[intEntityId]							= @intUserId
				,[ysnResetDetails]						= 0
				,[ysnPost]								= 1
				,[intInvoiceDetailId]					= NULL
				,[intItemId]							= NULL
				,[ysnInventory]							= 0
				,[strItemDescription]					= 'Patronage - Issued Stock' 
				,[intItemUOMId]							= NULL
				,[dblQtyOrdered]						= 0
				,[dblQtyShipped]						= CS.dblSharesNo
				,[dblDiscount]							= 0
				,[dblPrice]								= ROUND(CS.dblParValue,2)
				,[ysnRefreshPrice]						= 0
				,[strMaintenanceType]					= ''
				,[strFrequency]							= ''
				,[dtmMaintenanceDate]					= NULL
				,[dblMaintenanceAmount]					= NULL
				,[dblLicenseAmount]						= NULL
				,[intTaxGroupId]						= NULL
				,[ysnRecomputeTax]						= 0
				,[intSCInvoiceId]						= NULL
				,[strSCInvoiceNumber]					= ''
				,[intInventoryShipmentItemId]			= NULL
				,[strShipmentNumber]					= ''
				,[intSalesOrderDetailId]				= NULL
				,[strSalesOrderNumber]					= ''
				,[intContractHeaderId]					= NULL 
				,[intContractDetailId]					= NULL 
				,[intShipmentPurchaseSalesContractId]	= NULL
				,[intTicketId]							= NULL
				,[intTicketHoursWorkedId]				= NULL
				,[intSiteId]							= NULL
				,[strBillingBy]							= ''
				,[dblPercentFull]						= NULL
				,[dblNewMeterReading]					= NULL
				,[dblPreviousMeterReading]				= NULL
				,[dblConversionFactor]					= NULL
				,[intPerformerId]						= NULL
				,[ysnLeaseBilling]						= NULL
				,[ysnVirtualMeterReading]				= NULL
				,[ysnClearDetailTaxes]					= 1
				,[intTempDetailIdForTaxes]				= @intCustomerStockId
				,[intSalesAccountId]					= SADef.intSalesAccount

			FROM tblPATCustomerStock CS
			INNER JOIN tblARCustomer ARC
				ON ARC.[intEntityId] = CS.intCustomerPatronId
			CROSS JOIN (SELECT intSalesAccount FROM tblSMCompanyLocation where intCompanyLocationId = @intCompanyLocationId) SADef
			WHERE CS.intCustomerStockId = @intCustomerStockId

			EXEC [dbo].[uspARProcessInvoices]
				@InvoiceEntries = @EntriesForInvoice,
				@UserId = @intUserId,
				@GroupingOption = 11,
				@RaiseError		= 1,
				@ErrorMessage	= @error OUTPUT,
				@CreatedIvoices	= @intCreatedId OUTPUT

			UPDATE tblPATCustomerStock SET intInvoiceId = @intCreatedId WHERE intCustomerStockId = @intCustomerStockId

		END
		ELSE
		BEGIN
			BEGIN TRY

				SET ANSI_WARNINGS ON;
				DECLARE @invoiceIds AS NVARCHAR(MAX);
				SELECT @invoiceIds = STUFF((SELECT ',' + CONVERT(NVARCHAR(MAX),intInvoiceId)  FROM #tempCustomerStock 
				FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,'');
				SET ANSI_WARNINGS OFF;

				EXEC [dbo].[uspARPostInvoice]
					@batchId			= NULL,
					@post				= 0,
					@recap				= 0,
					@param				= @invoiceIds,
					@userId				= @intUserId,
					@beginDate			= NULL,
					@endDate			= NULL,
					@beginTransaction	= NULL,
					@endTransaction		= NULL,
					@exclude			= NULL,
					@successfulCount	= @successfulCount OUTPUT,
					@invalidCount		= @invalidCount OUTPUT,
					@success			= @success OUTPUT,
					@batchIdUsed		= @batchIdUsed OUTPUT,
					@transType			= N'all',
					@raiseError			= @error

			END TRY
			BEGIN CATCH
				RAISERROR(@error,16,1);
				GOTO Post_Rollback;
			END CATCH


			DELETE FROM tblARInvoice WHERE intInvoiceId IN (SELECT intInvoiceId FROM #tempCustomerStock) AND ysnPaid <> 1;
			UPDATE tblPATCustomerStock SET intInvoiceId = null WHERE intCustomerStockId = @intCustomerStockId;
		END
		---------- UPDATE CUSTOMER STOCK TABLE ---------------
		UPDATE tblPATCustomerStock SET ysnPosted = @ysnPosted WHERE intCustomerStockId = @intCustomerStockId;
	END
END


---------------------------------------------------------------------------------------------------------------------------------------
IF @@ERROR <> 0 GOTO Post_Rollback;

GOTO Post_Commit;

Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	SET @successfulCount = @totalRecords
	
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION	
	SET @success = 0
	GOTO Post_Exit

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempCustomerStock')) DROP TABLE #tempCustomerStock
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempValidateTable')) DROP TABLE #tempValidateTable
END