CREATE PROCEDURE [dbo].[uspPATPostIssueStock]
	@intIssueStockId INT = NULL,
	@ysnPosted BIT = NULL,
	@ysnRecap BIT = NULL,
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
DECLARE @intCreatedId INT;
DECLARE @intCreatedCustomerStockId INT;
DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage';
DECLARE @ISSUE_STOCK NVARCHAR(25) = 'Issue Stock';
DECLARE @MODULE_CODE NVARCHAR(5)  = 'PAT';
DECLARE @batchId2 AS NVARCHAR(40);

CREATE TABLE #tempValidateTable (
	[strError] [NVARCHAR](MAX),
	[strTransactionType] [NVARCHAR](50),
	[strTransactionNo] [NVARCHAR](50),
	[intTransactionId] INT
);

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId;

	SELECT	IssueStk.intIssueStockId,
			IssueStk.strIssueNo,
			IssueStk.dtmIssueDate,
			IssueStk.intCustomerStockId,
			IssueStk.intCustomerPatronId,
			IssueStk.intStockId,
			IssueStk.strCertificateNo,
			IssueStk.strStockStatus,
			IssueStk.dblSharesNo,
			IssueStk.dblParValue,
			IssueStk.dblFaceValue,
			IssueStk.intInvoiceId,
			IssueStk.ysnPosted
	INTO #tempCustomerStock
	FROM tblPATIssueStock IssueStk
	WHERE intIssueStockId = @intIssueStockId
		

IF(ISNULL(@ysnPosted,0) = 0)
BEGIN
	-------- VALIDATE IF CAN BE UNPOSTED

	INSERT INTO #tempValidateTable
	SELECT * FROM fnPATValidateAssociatedTransaction((SELECT intIssueStockId FROM #tempCustomerStock), 1, @MODULE_NAME)

	SELECT * FROM #tempValidateTable
	IF EXISTS(SELECT 1 FROM #tempValidateTable)
	BEGIN
		SELECT @error = V.strError FROM #tempValidateTable V
		RAISERROR(@error, 16, 1);
		GOTO Post_Rollback;
	END
END


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
			[intAccountId]					=	GL.intAccountId,
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
			[strTransactionId]				=	A.strIssueNo, 
			[intTransactionId]				=	A.intIssueStockId, 
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
		FROM	#tempCustomerStock A
		CROSS JOIN tblPATCompanyPreference ComPref
		INNER JOIN tblGLAccount GL ON GL.intAccountId = CASE WHEN A.strStockStatus = 'Voting' THEN ComPref.intVotingStockId ELSE ComPref.intNonVotingStockId END
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
			[strTransactionId]				=	A.strIssueNo, 
			[intTransactionId]				=	A.intIssueStockId, 
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
		FROM	#tempCustomerStock A
		CROSS APPLY tblARCompanyPreference ComPref
		INNER JOIN tblGLAccount GL
			ON ComPref.intARAccountId = GL.intAccountId
	END


IF(ISNULL(@ysnRecap, 0) = 1)
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
ELSE
BEGIN

	IF(@batchId2 IS NULL)
		EXEC uspSMGetStartingNumber 3, @batchId2 OUT

	--------------------- ISSUE STOCKS ------------------	
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
				,[intSourceId]							= CS.intIssueStockId
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
				,[intTransactionId]						= CS.intIssueStockId
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
				,[intTempDetailIdForTaxes]				= @intIssueStockId
				,[intSalesAccountId]					= CASE WHEN CS.strStockStatus = 'Voting' THEN ComPref.intVotingStockId
																ELSE ComPref.intNonVotingStockId
															END
			FROM #tempCustomerStock CS
			INNER JOIN tblARCustomer ARC
				ON ARC.intEntityId = CS.intCustomerPatronId
			CROSS JOIN tblPATCompanyPreference ComPref

			EXEC [dbo].[uspARProcessInvoices]
				@InvoiceEntries = @EntriesForInvoice,
				@UserId = @intUserId,
				@GroupingOption = 11,
				@RaiseError		= 1,
				@ErrorMessage	= @error OUTPUT,
				@CreatedIvoices	= @intCreatedId OUTPUT

			UPDATE tblPATIssueStock SET intInvoiceId = @intCreatedId WHERE intIssueStockId = @intIssueStockId;

			INSERT INTO tblPATCustomerStock(
				[intCustomerPatronId],
				[intStockId],
				[strCertificateNo],
				[strStockStatus],
				[strActivityStatus],
				[dblSharesNo],
				[dblParValue],
				[dblFaceValue]
			)
			SELECT	CS.intCustomerPatronId,
					CS.intStockId,
					CS.strCertificateNo,
					CS.strStockStatus,
					'Open',
					CS.dblSharesNo,
					CS.dblParValue,
					CS.dblFaceValue
			FROM #tempCustomerStock CS

			SET @intCreatedCustomerStockId = SCOPE_IDENTITY();

			UPDATE tblPATIssueStock SET [intCustomerStockId] = @intCreatedCustomerStockId WHERE intIssueStockId = @intIssueStockId;
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

			DECLARE @intInvoiceId INT, @intTotalInvoice INT;

			SELECT	intCustomerStockId,
					intInvoiceId
			INTO #tempInvoiceTbl
			FROM #tempCustomerStock
			WHERE intInvoiceId IS NOT NULL;

			WHILE EXISTS(SELECT 1 FROM #tempInvoiceTbl)
			BEGIN
				SELECT TOP 1 @intInvoiceId = intInvoiceId FROM #tempInvoiceTbl;

				EXEC [dbo].[uspARDeleteInvoice]
					@InvoiceId = @intInvoiceId,
					@UserId = @intUserId

				DELETE FROM #tempInvoiceTbl WHERE intInvoiceId = @intInvoiceId;
			END					
			
			DELETE FROM tblPATRetireStock WHERE intCustomerStockId IN (SELECT intCustomerStockId FROM #tempCustomerStock);
			DELETE FROM tblPATCustomerStock WHERE intCustomerStockId IN (SELECT intCustomerStockId FROM #tempCustomerStock);
			
		END
		---------- UPDATE CUSTOMER STOCK TABLE ---------------
		UPDATE tblPATIssueStock SET ysnPosted = @ysnPosted WHERE intIssueStockId = @intIssueStockId;
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