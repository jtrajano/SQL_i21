﻿CREATE PROCEDURE [dbo].[uspCFCreateFeeDebitMemo](
	 @xmlParam					NVARCHAR(MAX)  
	,@entityId					INT			   = NULL
	,@ErrorMessage				NVARCHAR(250)  = NULL OUTPUT
	,@CreatedIvoices			NVARCHAR(MAX)  = NULL OUTPUT
	,@UpdatedIvoices			NVARCHAR(MAX)  = NULL OUTPUT
	,@ysnDevMode				BIT = 0
)
AS
BEGIN

	BEGIN TRY 
		----------------VARIABLES---------------
		DECLARE @EntriesForInvoice		AS InvoiceIntegrationStagingTable
		DECLARE @TaxDetails				AS LineItemTaxDetailStagingTable 
		DECLARE @companyLocationId		INT = 0
		DECLARE @accountId				INT = 0
		DECLARE @executedLine			INT = 0 
		----------------------------------------

		---------CREATE TEMPORARY TABLE---------
		SET @executedLine = 1
		CREATE TABLE #tblCFInvoiceFee
		(
			 intFeeLoopId				INT
			,intAccountId				INT
			,strCalculationType			NVARCHAR(MAX)
			,dblFeeRate					NUMERIC(18,6)
			,intTransactionId			INT
			,dtmTransactionDate			DATETIME
			,dtmStartDate				DATETIME
			,dtmEndDate					DATETIME
			,dblQuantity				NUMERIC(18,6)
			,intCardId					INT
			,dblFeeAmount				NUMERIC(18,6)
			,strFeeDescription			NVARCHAR(MAX)
			,strFee						NVARCHAR(MAX)
			,strInvoiceFormat			NVARCHAR(MAX)
			,strInvoiceReportNumber		NVARCHAR(MAX)
			,intCustomerId				INT
			,intTermID					INT
			,intSalesPersonId			INT
			,dtmInvoiceDate				DATETIME
			,dblFeeTotalAmount 			NUMERIC(18,6)
		)

		SET @executedLine = 2
		CREATE TABLE #tblCFInvoiceResult	
		(
			 intId							INT
			,intDebitMemoId					INT
		)
		----------------------------------------

		-----------COMPANY PREFERENCE-----------
		SET @executedLine = 3
		SELECT TOP 1 
		 @companyLocationId = intARLocationId 
		,@accountId = intGLAccountId
		FROM tblCFCompanyPreference
		----------------------------------------

		--------------INVOICE LIST--------------
		SET @executedLine = 4
		INSERT INTO #tblCFInvoiceFee
		EXEC "dbo"."uspCFInvoiceReportFee" @xmlParam=@xmlParam
		----------------------------------------

		----------ENTRIES FOR INVOICE-----------
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
		SELECT TOP 1
			 [strTransactionType]					= 'Debit Memo'
			,[strSCInvoiceNumber]					= ''
			,[intSalesAccountId]					= @accountId
			,[strSourceTransaction]					= 'CF Invoice'
			,[intSourceId]							= 1											-- TEMPORARY
			,[strSourceId]							= strInvoiceReportNumber
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
			,[strInvoiceOriginId]					= NULL --strInvoiceReportNumber
			,[ysnUseOriginIdAsInvoiceNumber]		= 0
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
			,[dblPrice]								= dblFeeTotalAmount
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
		FROM #tblCFInvoiceFee
		--GROUP BY 
		--intCustomerId
		--,strInvoiceReportNumber
		--,dblAccountTotalAmount
		--,dblTotalQuantity
		--,dblAccountTotalDiscount
		--,intTermID
		--,dtmInvoiceDate
		--,intSalesPersonId
		----------------------------------------

		--SELECT * FROM @EntriesForInvoice

		----------CREATE DEBIT MEMOS------------
		SET @executedLine = 6
		EXEC [dbo].[uspARProcessInvoices]
		 @InvoiceEntries	 = @EntriesForInvoice
		,@LineItemTaxEntries = @TaxDetails
		,@UserId			= 1
		,@GroupingOption	= 11
		,@RaiseError		= 1
		,@ErrorMessage		= @ErrorMessage		OUTPUT
		,@CreatedIvoices	= @CreatedIvoices	OUTPUT
		,@UpdatedIvoices	= @UpdatedIvoices	OUTPUT
		----------------------------------------

		

		DECLARE @intInvoiceResultId	INT
		---------INVOICE PROCESS RESULT---------
		SET @executedLine = 7
		INSERT INTO #tblCFInvoiceResult
		(
			intId,
			intDebitMemoId
		)
		SELECT RecordKey , Record 
		FROM fnCFSplitString(@CreatedIvoices,',')

		------------LOOP CUST GROUP------------
		SET @executedLine = 8
		WHILE (EXISTS(SELECT 1 FROM #tblCFInvoiceResult))
		---------------------------------------
		BEGIN
			
			
			SET @executedLine = 9
			SELECT	TOP 1 
			@intInvoiceResultId = intDebitMemoId
			FROM #tblCFInvoiceResult
			
			SET @executedLine = 10
			INSERT INTO tblCFInvoiceProcessResult(
				 strInvoiceProcessResultId
				,intTransactionProcessId
				,ysnStatus
				,strRunProcessId
				,intCustomerId
				,strInvoiceReportNumber
			)
			SELECT TOP 1 
			(SELECT TOP 1 strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @intInvoiceResultId)
			,@intInvoiceResultId
			,1
			,''
			,intEntityCustomerId
			,(SELECT TOP 1 strInvoiceReportNumber FROM #tblCFInvoiceFee WHERE intCustomerId = arInv.intEntityCustomerId)
			FROM tblARInvoice AS arInv WHERE intInvoiceId = @intInvoiceResultId

			SET @executedLine = 11
			DELETE FROM #tblCFInvoiceResult 
			WHERE intDebitMemoId = @intInvoiceResultId
		END


		----------------------------------------
		
		----------DROP TEMPORARY TABLE----------
		SET @executedLine = 12
		DROP TABLE #tblCFInvoiceFee
		----------------------------------------

	END TRY
	BEGIN CATCH

		------------SET ERROR MESSAGE-----------
		SET @executedLine = 13
		DECLARE @CatchErrorMessage NVARCHAR(4000);  
		DECLARE @CatchErrorSeverity INT;  
		DECLARE @CatchErrorState INT;  
  
		SET @executedLine = 14
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
		SET @executedLine = 15
		DROP TABLE #tblCFInvoiceFee
		----------------------------------------
	
	END CATCH

END