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
	SELECT * FROM fnPATValidateAssociatedTransaction((SELECT intCustomerStockId FROM #tempCustomerStock), @type)

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
		INSERT INTO @GLEntries
		SELECT * FROM [dbo].[fnPATCreateRetireStockGLEntries](@intCustomerStockId, 0, @intUserId, @batchId)

	END
	ELSE
	BEGIN
	------------------------REVERSE GL ENTRIES---------------------
		INSERT INTO @GLEntries
		SELECT * FROM [dbo].[fnPATReverseRetireStockGLEntries](@intCustomerStockId, @dateToday, @intUserId, @batchId)

		UPDATE tblGLDetail SET ysnIsUnposted = 1
		WHERE intTransactionId = @intCustomerStockId 
			AND strModuleName = N'Patronage' AND strTransactionForm = N'Retire Stock'
	END
END
ELSE
BEGIN
	IF(@ysnPosted = 1)
	BEGIN

	------------------------CREATE GL ENTRIES---------------------
		INSERT INTO @GLEntries
		SELECT * FROM [dbo].[fnPATCreateIssueStockGLEntries](@intCustomerStockId, @intUserId, @batchId)

	END
	ELSE
	BEGIN

	------------------------REVERSE GL ENTRIES---------------------
		INSERT INTO @GLEntries
		SELECT * FROM [dbo].[fnPATReverseIssueStockGLEntries](@intCustomerStockId, @dateToday, @intUserId, @batchId)

		UPDATE tblGLDetail SET ysnIsUnposted = 1
		WHERE intTransactionId = @intCustomerStockId 
			AND strModuleName = N'Patronage' AND strTransactionForm = N'Issue Stock'
	END
END
BEGIN TRY
IF(ISNULL(@ysnRecap, 0) = 0)
BEGIN
	SELECT * FROM @GLEntries;
	EXEC uspGLBookEntries @GLEntries, @ysnPosted;

	SET @isGLSucces = 1;

END
ELSE
BEGIN
			SELECT * FROM @GLEntries
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

			UPDATE tblPATCustomerStock SET intBillId = @intCreatedId WHERE intCustomerStockId = @intCustomerStockId

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
				@batchId = @intCreatedId,
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
			DELETE FROM tblAPBill WHERE intBillId IN (SELECT intBillId FROM #tempCustomerStock) AND ysnPaid <> 1;
			EXEC uspPATProcessVoid @intCustomerStockId, @intUserId;
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
				,[strComments]							= ''
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
				,[dblQtyOrdered]						= 1
				,[dblQtyShipped]						= 1
				,[dblDiscount]							= 0
				,[dblPrice]								= ROUND(CS.dblFaceValue,2)
				,[ysnRefreshPrice]						= 0
				,[strMaintenanceType]					= ''
				,[strFrequency]							= ''
				,[dtmMaintenanceDate]					= NULL
				,[dblMaintenanceAmount]					= NULL
				,[dblLicenseAmount]						= NULL
				,[intTaxGroupId]						= NULL
				,[ysnRecomputeTax]						= 1
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
				ON ARC.intEntityCustomerId = CS.intCustomerPatronId
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
IF @@ERROR <> 0	GOTO Post_Rollback;

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