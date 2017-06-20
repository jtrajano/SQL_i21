CREATE PROCEDURE [dbo].[uspCFCreateDebitMemo](
	 @entityId					INT			   = NULL
	,@ErrorMessage				NVARCHAR(250)  = NULL OUTPUT
	,@CreatedIvoices			NVARCHAR(MAX)  = NULL OUTPUT
	,@UpdatedIvoices			NVARCHAR(MAX)  = NULL OUTPUT
	,@ysnDevMode				BIT = 0
)
AS
BEGIN

	BEGIN TRY 
		----------------VARIABLES---------------
		DECLARE @EntriesForInvoice		AS InvoiceStagingTable
		DECLARE @TaxDetails				AS LineItemTaxDetailStagingTable 
		DECLARE @companyLocationId		INT = 0
		DECLARE @accountId				INT = 0
		DECLARE @executedLine			INT = 0 
		----------------------------------------

		---------CREATE TEMPORARY TABLE---------
		
		
		SET @executedLine = 1
		CREATE TABLE #tblCFInvoiceResult	
		(
			intDebitMemoId					INT
		)
		----------------------------------------

		-----------COMPANY PREFERENCE-----------
		SET @executedLine = 2
		SELECT TOP 1 
		 @companyLocationId = intARLocationId 
		,@accountId = intGLAccountId
		FROM tblCFCompanyPreference
		----------------------------------------

		--------------INVOICE LIST--------------
		SET @executedLine = 3
		
		----------------------------------------

		--------------INVOICE FEE LIST--------------
		--SET @executedLine = 4
		
		----------------------------------------

		----------ENTRIES FOR INVOICE-----------
		SET @executedLine = 4
		INSERT INTO @EntriesForInvoice(
			 [strTransactionType]
			,[strSCInvoiceNumber]		
			,[intSalesAccountId]
			,[strSourceTransaction]
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
			,[ysnUseOriginIdAsInvoiceNumber]
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
			,[strType]
			,[ysnUpdateAvailableDiscount]
			,[strItemTermDiscountBy]
			,[dblItemTermDiscount]
			,[strDocumentNumber]
		)
		SELECT
			 [strTransactionType]					= 'Debit Memo'
			,[strSCInvoiceNumber]					= ''
			,[intSalesAccountId]					= @accountId
			,[strSourceTransaction]					= 'CF Invoice'
			,[intSourceId]							= 1											-- TEMPORARY
			,[strSourceId]							= strTempInvoiceReportNumber
			,[intInvoiceId]							= NULL 
			,[intEntityCustomerId]					= intCustomerId
			,[intCompanyLocationId]					= @companyLocationId						--CF Company Configuration
			,[intCurrencyId]						= NULL
			,[intTermId]							= intTermID
			,[dtmDate]								= dtmInvoiceDate								
			,[dtmDueDate]							= NULL
			,[dtmShipDate]							= dtmInvoiceDate							-- TEMPORARY
			,[intEntitySalespersonId]				= intSalesPersonId										-- TEMPORARY
			,[intFreightTermId]						= NULL 
			,[intShipViaId]							= NULL 
			,[intPaymentMethodId]					= NULL
			,[strInvoiceOriginId]					= strTempInvoiceReportNumber
			,[ysnUseOriginIdAsInvoiceNumber]		= 1
			,[strPONumber]							= NULL
			,[strBOLNumber]							= ''
			,[strDeliverPickup]						= NULL
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
			,[intTransactionId]						= NULL
			,[intEntityId]							= @entityId											-- TEMPORARY
			,[ysnResetDetails]						= 0
			,[ysnPost]								= 1
			,[intInvoiceDetailId]					= NULL
			,[intItemId]							= NULL
			,[ysnInventory]							= 0
			,[strItemDescription]					= NULL
			,[intItemUOMId]							= NULL
			,[dblQtyOrdered]						= NULL
			,[dblQtyShipped]						= 1 -- DEFAULT TO 1
			,[dblDiscount]							= NULL
			,[dblPrice]								= dblAccountTotalAmount
			,[ysnRefreshPrice]						= 0
			,[strMaintenanceType]					= ''
			,[strFrequency]							= ''
			,[dtmMaintenanceDate]					= NULL
			,[dblMaintenanceAmount]					= NULL
			,[dblLicenseAmount]						= NULL
			,[intTaxGroupId]						= NULL
			,[ysnRecomputeTax]						= 0
			,[intSCInvoiceId]						= NULL
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
			,[intTempDetailIdForTaxes]				= NULL
			,[strType]								= 'CF Invoice'
			,[ysnUpdateAvailableDiscount]			= 1
			,[strItemTermDiscountBy]				= 'Amount'
			,[dblItemTermDiscount]					= dblAccountTotalDiscount
			,[strDocumentNumber]					= strTempInvoiceReportNumber
		FROM tblCFInvoiceStagingTable
		GROUP BY 
		intCustomerId
		,strTempInvoiceReportNumber
		,dblAccountTotalAmount
		,dblAccountTotalDiscount
		,intTermID
		,dtmInvoiceDate
		,intSalesPersonId
		----------------------------------------

		----------FEE ENTRIES FOR INVOICE-----------
		SET @executedLine = 5
		INSERT INTO @EntriesForInvoice(
			 [strTransactionType]
			,[strSCInvoiceNumber]		
			,[intSalesAccountId]
			,[strSourceTransaction]
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
			,[ysnUseOriginIdAsInvoiceNumber]
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
			,[strType]
			,[ysnUpdateAvailableDiscount]
			,[strItemTermDiscountBy]
			,[dblItemTermDiscount]
			,[strDocumentNumber]
		)
		SELECT
			 [strTransactionType]					= 'Debit Memo'
			,[strSCInvoiceNumber]					= ''
			,[intSalesAccountId]					= (SELECT TOP 1 intGeneralAccountId 
														FROM vyuARGetItemAccount 
														WHERE intItemId = intItemId 
														AND intLocationId = intARLocationId)--178--@accountId
			,[strSourceTransaction]					= 'CF Invoice'
			,[intSourceId]							= 1											-- TEMPORARY
			,[strSourceId]							= strInvoiceReportNumber
			,[intInvoiceId]							= NULL --(SELECT TOP 1 intInvoiceId FROM tblARInvoice WHERE strInvoiceNumber COLLATE Latin1_General_CI_AS = strInvoiceReportNumber COLLATE Latin1_General_CI_AS) 
			,[intEntityCustomerId]					= intCustomerId
			,[intCompanyLocationId]					= @companyLocationId						--CF Company Configuration
			,[intCurrencyId]						= NULL
			,[intTermId]							= intTermID
			,[dtmDate]								= dtmInvoiceDate								
			,[dtmDueDate]							= NULL
			,[dtmShipDate]							= dtmInvoiceDate							-- TEMPORARY
			,[intEntitySalespersonId]				= intSalesPersonId										-- TEMPORARY
			,[intFreightTermId]						= NULL 
			,[intShipViaId]							= NULL 
			,[intPaymentMethodId]					= NULL
			,[strInvoiceOriginId]					= strInvoiceReportNumber
			,[ysnUseOriginIdAsInvoiceNumber]		= 1
			,[strPONumber]							= NULL
			,[strBOLNumber]							= ''
			,[strDeliverPickup]						= NULL
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
			,[intTransactionId]						= NULL
			,[intEntityId]							= @entityId											-- TEMPORARY
			,[ysnResetDetails]						= 0
			,[ysnPost]								= 1
			,[intInvoiceDetailId]					= NULL
			,[intItemId]							= intItemId
			,[ysnInventory]							= 0
			,[strItemDescription]					= NULL
			,[intItemUOMId]							= NULL
			,[dblQtyOrdered]						= NULL
			,[dblQtyShipped]						= 1 -- DEFAULT TO 1
			,[dblDiscount]							= NULL
			,[dblPrice]								= dblFeeAmount--dblFeeTotalAmount
			,[ysnRefreshPrice]						= 0
			,[strMaintenanceType]					= ''
			,[strFrequency]							= ''
			,[dtmMaintenanceDate]					= NULL
			,[dblMaintenanceAmount]					= NULL
			,[dblLicenseAmount]						= NULL
			,[intTaxGroupId]						= NULL
			,[ysnRecomputeTax]						= 0
			,[intSCInvoiceId]						= NULL
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
			,[intTempDetailIdForTaxes]				= NULL
			,[strType]								= 'CF Invoice'
			,[ysnUpdateAvailableDiscount]			= 1
			,[strItemTermDiscountBy]				= ''
			,[dblItemTermDiscount]					= 0
			,[strDocumentNumber]					= strInvoiceReportNumber
		FROM tblCFInvoiceFeeStagingTable
		--GROUP BY 
		--intCustomerId
		--,strTempInvoiceReportNumber
		--,dblAccountTotalAmount
		--,dblTotalQuantity
		--,dblAccountTotalDiscount
		--,intTermID
		--,dtmInvoiceDate
		--,intSalesPersonId
		----------------------------------------

		
		SET @executedLine = 6
		DECLARE @InvoiceEntriesTEMP	InvoiceStagingTable
		INSERT INTO @InvoiceEntriesTEMP(
		[intId]
		,[strTransactionType]
		,[strSourceTransaction]
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
		,[ysnUseOriginIdAsInvoiceNumber]
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
		,[strType]
		,[ysnUpdateAvailableDiscount]
		,[strItemTermDiscountBy]
		,[dblItemTermDiscount]
		,[dtmPostDate])
		SELECT 
		ROW_NUMBER() OVER(ORDER BY intEntityCustomerId ASC)
		,[strTransactionType]
		,[strSourceTransaction]
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
		,[ysnUseOriginIdAsInvoiceNumber]
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
		,[strType]
		,[ysnUpdateAvailableDiscount]
		,[strItemTermDiscountBy]
		,[dblItemTermDiscount]
		,[dtmPostDate]
		FROM @EntriesForInvoice


		SELECT dblPrice,dblQtyShipped,* FROM @EntriesForInvoice
		SELECT dblPrice,dblQtyShipped,* FROM @InvoiceEntriesTEMP

		----------CREATE DEBIT MEMOS------------

		DECLARE @LogId INT

		SET @executedLine = 7
		EXEC [dbo].[uspARProcessInvoicesByBatch]
		 @InvoiceEntries	= @InvoiceEntriesTEMP
		,@LineItemTaxEntries = @TaxDetails
		,@UserId			= 1
		,@GroupingOption	= 11
		,@RaiseError		= 1
		,@ErrorMessage		= @ErrorMessage OUTPUT
		,@LogId				= @LogId OUTPUT

		
		--EXEC [dbo].[uspARProcessInvoices]
		-- @InvoiceEntries	 = @InvoiceEntriesTEMP
		--,@LineItemTaxEntries = @TaxDetails
		--,@UserId			= 1
		--,@GroupingOption	= 11
		--,@RaiseError		= 1
		--,@ErrorMessage		= @ErrorMessage		OUTPUT
		--,@CreatedIvoices	= @CreatedIvoices	OUTPUT
		--,@UpdatedIvoices	= @UpdatedIvoices	OUTPUT
		----------------------------------------

		
		SET @executedLine = 8
		DECLARE @intInvoiceResultId			INT
		DECLARE @dblTotalQuantity			NUMERIC(18,6)
		DECLARE @strInvoiceReportNumber		NVARCHAR(MAX)
		DECLARE @strInvoiceNumber			NVARCHAR(MAX)
		DECLARE @intEntityCustomerId		INT
		DECLARE @dblAccountTotalDiscount	NUMERIC(18,6)
		DECLARE @dblAccountTotalAmount		NUMERIC(18,6)
		DECLARE @dblFeeAmount				NUMERIC(18,6)

		---------INVOICE PROCESS RESULT---------
		
		SET @executedLine = 9
		DECLARE @SuccessfulCount INT

		SET @SuccessfulCount = 0;

		INSERT INTO #tblCFInvoiceResult
		(
			intDebitMemoId
		)
		SELECT intInvoiceId FROM tblARInvoiceIntegrationLogDetail WHERE intIntegrationLogId = @LogId AND ISNULL(ysnSuccess,0) = 1 AND ysnHeader = 1 

		SELECT @SuccessfulCount = Count(*) FROM #tblCFInvoiceResult

		--INSERT INTO #tblCFInvoiceResult
		--(
		--	intId,
		--	intDebitMemoId
		--)
		--SELECT RecordKey , Record 
		--FROM fnCFSplitString(@CreatedIvoices,',')

		------------LOOP CUST GROUP------------
		SET @executedLine = 10
		WHILE (EXISTS(SELECT 1 FROM #tblCFInvoiceResult))
		---------------------------------------
		BEGIN
			
			
			SET @executedLine = 11
			SELECT	TOP 1 
			@intInvoiceResultId = intDebitMemoId
			FROM #tblCFInvoiceResult

			SET @executedLine = 12
			SELECT TOP 1 
			 @strInvoiceNumber = strInvoiceNumber
			,@intEntityCustomerId = intEntityCustomerId	
			FROM tblARInvoice 
			WHERE intInvoiceId = @intInvoiceResultId

			SET @executedLine = 13
			SELECT TOP 1 
			 @strInvoiceReportNumber = strTempInvoiceReportNumber 
			,@dblTotalQuantity = SUM(dblQuantity)
			,@dblAccountTotalAmount = dblAccountTotalAmount
			,@dblAccountTotalDiscount = dblAccountTotalDiscount
			FROM tblCFInvoiceStagingTable 
			WHERE intCustomerId = @intEntityCustomerId
			GROUP BY
			 intCustomerId
			,strTempInvoiceReportNumber
			,dblAccountTotalAmount
			,dblAccountTotalDiscount
			,intTermID
			,dtmInvoiceDate
			,intSalesPersonId

			SET @executedLine = 14
			SELECT TOP 1 
			@dblFeeAmount = dblFeeTotalAmount
			FROM tblCFInvoiceFeeStagingTable 
			WHERE intCustomerId = @intEntityCustomerId
			
			SET @executedLine = 15
			UPDATE tblCFInvoiceProcessResult
			SET 
			 strInvoiceId				= @strInvoiceNumber
			,intInvoiceId				= @intInvoiceResultId
			,ysnStatus					= 1
			,strRunProcessId			= ''
			,intCustomerId				= @intEntityCustomerId
			,strInvoiceReportNumber		= @strInvoiceReportNumber
			,dblInvoiceQuantity			= ISNULL(@dblTotalQuantity,0)
			,dblInvoiceDiscount			= ISNULL(@dblAccountTotalDiscount,0)
			,dblInvoiceAmount			= (ISNULL(@dblAccountTotalAmount,0) + ISNULL(@dblFeeAmount,0))
			,dblInvoiceFee				= ISNULL(@dblFeeAmount,0)
			WHERE intCustomerId = @intEntityCustomerId
			

			SET @executedLine = 16
			DELETE FROM #tblCFInvoiceResult 
			WHERE intDebitMemoId = @intInvoiceResultId
		END


		----------------------------------------
		
		----------DROP TEMPORARY TABLE----------
		--SET @executedLine = 12
		----------------------------------------

	END TRY
	BEGIN CATCH

		------------SET ERROR MESSAGE-----------
		--SET @executedLine = 13
		DECLARE @CatchErrorMessage NVARCHAR(4000);  
		DECLARE @CatchErrorSeverity INT;  
		DECLARE @CatchErrorState INT;  
  
		--SET @executedLine = 14
		SELECT   
			@CatchErrorMessage = 'Line:' + (LTRIM(RTRIM(STR(@executedLine)))) + ' Process Debit Memo  > ' + ERROR_MESSAGE(),  
			@CatchErrorSeverity = ERROR_SEVERITY(),  
			@CatchErrorState = ERROR_STATE();  
  
		RAISERROR (
			@CatchErrorMessage, 
			@CatchErrorSeverity, 
			@CatchErrorState   
		);  
		----------------------------------------

		----------DROP TEMPORARY TABLE----------
		--SET @executedLine = 15
		--DROP TABLE tblCFInvoiceStagingTable
		----------------------------------------
	
	END CATCH

END