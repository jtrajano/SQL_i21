﻿CREATE PROCEDURE [dbo].[uspARDuplicateInvoice]
	 @InvoiceId			INT
	,@InvoiceDate		DATETIME		= NULL
	,@PostDate			DATETIME		= NULL
	,@UserId			INT				= NULL
	,@NewInvoiceNumber	NVARCHAR(25)	= NULL	OUTPUT
	,@NewInvoiceId		INT				= NULL	OUTPUT
	,@IsCancel			BIT				= 0
	,@RaiseError		BIT				= 0
	,@ErrorMessage		NVARCHAR(250)	= NULL	OUTPUT
	,@ForRecurring		BIT				= 0	
AS

BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON

DECLARE @CurrentErrorMessage NVARCHAR(250)
		,@ZeroDecimal NUMERIC(18, 6)
		,@InitTranCount INT
		,@Savepoint NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARDuplicateInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)
SET @InvoiceDate = CAST(ISNULL(@InvoiceDate, GETDATE()) AS DATE)
SET @PostDate = ISNULL(@PostDate, @InvoiceDate)		
SET @ZeroDecimal = 0.000000

		
IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END
	

DECLARE	 @OriginalInvoiceId			INT
		,@CreatedInvoiceId			INT
		,@InvoiceNumber				NVARCHAR(25)
		,@TransactionType			NVARCHAR(25)
		,@Type						NVARCHAR(100)
		,@EntityCustomerId			INT
		,@CompanyLocationId			INT
		,@CurrencyId				INT
		,@TermId					INT
		,@Date						DATETIME
		,@DueDate					DATETIME
		,@ShipDate					DATETIME
		,@PeriodsToAccrue			INT
		,@EntitySalespersonId		INT
		,@FreightTermId				INT
		,@ShipViaId					INT
		,@PaymentMethodId			INT
		,@InvoiceOriginId			NVARCHAR(8)
		,@PONumber					NVARCHAR(25)
		,@BOLNumber					NVARCHAR(50)
		,@Comments					NVARCHAR(MAX)
		,@FooterComments			NVARCHAR(MAX)
		,@ShipToLocationId			INT
		,@BillToLocationId			INT
		,@Template					BIT
		,@Forgiven					BIT
		,@Calculated				BIT
		,@Splitted					BIT
		,@PaymentId					INT
		,@SplitId					INT
		,@LoadDistributionHeaderId	INT
		,@LoadId					INT
		,@ActualCostId				NVARCHAR(50)
		,@ShipmentId				INT
		,@TransactionId				INT
		,@EntityId					INT
		,@OldInvoiceRecurring		BIT
		,@IsImpactInventory			BIT
		,@TotalWeight				NUMERIC(18,6)
		,@EntityContactId			INT
		,@TotalTermDiscount			NUMERIC(18,6)
		,@StorageScheduleTypeId		INT
		,@ItemSubCurrencyId			INT
		,@ItemSubCurrencyRate		NUMERIC(18,6)
		,@ysnRecurringDuplicate		BIT = 0
		,@intDocumentMaintenanceId		INT = NULL
		,@intLineOfBusinessId		INT = NULL
		,@intICTId					INT = NULL
		
SELECT 
	 @InvoiceNumber					= [strInvoiceNumber]
	,@TransactionType				= [strTransactionType]
	,@Type							= [strType]
	,@EntityCustomerId				= [intEntityCustomerId]
	,@CompanyLocationId				= [intCompanyLocationId]
	,@CurrencyId					= [intCurrencyId]
	,@TermId						= [intTermId]
	,@Date							= @InvoiceDate
	,@DueDate						= NULL
	,@ShipDate						= @InvoiceDate
	,@PeriodsToAccrue				= [intPeriodsToAccrue]
	,@EntitySalespersonId			= [intEntitySalespersonId]
	,@FreightTermId					= [intFreightTermId]
	,@ShipViaId						= [intShipViaId]
	,@PaymentMethodId				= [intPaymentMethodId]
	,@InvoiceOriginId				= ''	--[strInvoiceOriginId]
	,@PONumber						= [strPONumber]
	,@BOLNumber						= [strBOLNumber]
	,@Comments						= CASE WHEN [ysnRecurring] = 1 AND @ForRecurring = 1
												THEN [strComments]
										   WHEN @IsCancel = 1
												THEN 'Invoice Cancelled: ' + [strInvoiceNumber] 
										ELSE 
											[strComments]
									  END
	,@FooterComments				= [strFooterComments]
	,@ShipToLocationId				= [intShipToLocationId]
	,@BillToLocationId				= [intBillToLocationId]
	,@Template						= 0		--[ysnTemplate]
	,@Forgiven						= 0		--[ysnForgiven]
	,@Calculated					= 0		--[ysnCalculated]
	,@Splitted						= 0		--[ysnSplitted]
	,@PaymentId						= NULL	--[intPaymentId]
	,@SplitId						= [intSplitId]
	,@LoadDistributionHeaderId		= NULL	--[intLoadDistributionHeaderId]
	,@LoadId						= CASE WHEN @IsCancel = 1 THEN [intLoadId] ELSE NULL END
	,@ActualCostId					= NULL	--[strActualCostId]
	,@ShipmentId					= NULL	--[intShipmentId]
	,@TransactionId					= NULL	--[intTransactionId]
	,@OriginalInvoiceId				= NULL	--[intOriginalInvoiceId]
	,@EntityId						= @UserId
	,@OldInvoiceRecurring			= [ysnRecurring]
	,@IsImpactInventory				= ISNULL([ysnImpactInventory], CAST( 1AS BIT))
	,@TotalWeight					= [dblTotalWeight]
	,@EntityContactId				= [intEntityContactId]
	,@TotalTermDiscount				= [dblTotalTermDiscount]	
	,@intDocumentMaintenanceId		= [intDocumentMaintenanceId]
	,@intLineOfBusinessId			= [intLineOfBusinessId]
	,@intICTId						= [intICTId]
FROM
	tblARInvoice
WHERE
	[intInvoiceId] = @InvoiceId

--VALIDATE INVOICE TYPES
IF @TransactionType NOT IN ('Invoice', 'Credit Memo') AND @Type NOT IN ('Standard', 'Credit Memo')
	BEGIN			
		IF ISNULL(@RaiseError,0) = 0
			ROLLBACK TRANSACTION		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Unable to duplicate %s Invoice Type.', 16, 1, @Type)
		RETURN 0;
	END

IF ISNULL(@LoadDistributionHeaderId, 0) > 0 OR @Type = 'Transport Delivery'
	BEGIN	
		IF ISNULL(@RaiseError,0) = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
		END
		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Duplicating of Transport Delivery Invoice type is not allowed.', 16, 1)
		RETURN 0;
	END
	
IF @Type = 'CF Tran'
    BEGIN    
		IF ISNULL(@RaiseError,0) = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
		END
	      
        IF ISNULL(@RaiseError,0) = 1
            RAISERROR('Duplicating of CF Tran Invoice type is not allowed.', 16, 1)
        RETURN 0;
    END
      
IF @Type = 'CF Invoice'
    BEGIN    
		IF ISNULL(@RaiseError,0) = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
		END
	       
        IF ISNULL(@RaiseError,0) = 1
            RAISERROR('Duplicating of CF Invoice Invoice type is not allowed.', 16, 1)
        RETURN 0;
    END
  
IF @Type = 'Meter Billing'
    BEGIN    
		IF ISNULL(@RaiseError,0) = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
		END
	     
        IF ISNULL(@RaiseError,0) = 1
            RAISERROR('Duplicating of Meter Billing Invoice type is not allowed.', 16, 1)
        RETURN 0;
    END

IF @Type = 'CF Tran'
	BEGIN	
		IF ISNULL(@RaiseError,0) = 0
			ROLLBACK TRANSACTION		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120077, 16, 1)
		RETURN 0;
	END
	
IF @Type = 'CF Invoice'
	BEGIN	
		IF ISNULL(@RaiseError,0) = 0
			ROLLBACK TRANSACTION		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120078, 16, 1)
		RETURN 0;
	END

IF @Type = 'Meter Billing'
	BEGIN	
		IF ISNULL(@RaiseError,0) = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
		END
			
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120079, 16, 1)
		RETURN 0;
	END

IF @IsCancel = 0
	BEGIN
		--VALIDATE INVOICES THAT HAS CONTRACTS
		IF EXISTS(SELECT NULL FROM tblARInvoiceDetail ID 
					INNER JOIN tblCTContractDetail CD ON ID.intContractDetailId = CD.intContractDetailId
					INNER JOIN tblCTContractHeader CH ON ID.intContractHeaderId = CH.intContractHeaderId
					WHERE ID.intInvoiceId = @InvoiceId
						AND CH.ysnUnlimitedQuantity = 0
						AND ISNULL(CD.dblBalance, @ZeroDecimal) - ID.dblQtyShipped < @ZeroDecimal)
			BEGIN
				IF ISNULL(@RaiseError,0) = 0
					ROLLBACK TRANSACTION		
				IF ISNULL(@RaiseError,0) = 1
					RAISERROR('There are items that will exceed the contract quantity.', 16, 1)
				RETURN 0;
			END
	
		BEGIN TRY
			EXEC [dbo].[uspARCreateCustomerInvoice]
				@EntityCustomerId						= @EntityCustomerId
				,@CompanyLocationId						= @CompanyLocationId
				,@CurrencyId							= @CurrencyId
				,@TermId								= @TermId
				,@EntityId								= @EntityId
				,@InvoiceDate							= @Date
				,@DueDate								= @DueDate
				,@ShipDate								= @ShipDate
				,@PostDate								= @PostDate
				,@TransactionType						= @TransactionType
				,@Type									= @Type
				,@NewInvoiceId							= @CreatedInvoiceId		OUTPUT
				,@ErrorMessage							= @CurrentErrorMessage	OUTPUT
				,@RaiseError							= @RaiseError
				,@EntitySalespersonId					= @EntitySalespersonId
				,@FreightTermId							= @FreightTermId
				,@ShipViaId								= @ShipViaId
				,@PaymentMethodId						= @PaymentMethodId
				,@InvoiceOriginId						= @InvoiceOriginId
				,@PONumber								= @PONumber
				,@BOLNumber								= @BOLNumber
				,@Comment								= @Comments
				,@ShipToLocationId						= @ShipToLocationId
				,@BillToLocationId						= @BillToLocationId
				,@Template								= @Template
				,@Forgiven								= @Forgiven
				,@Calculated							= @Calculated		
				,@Splitted								= @Splitted	
				,@PaymentId								= @PaymentId
				,@SplitId								= @SplitId
				,@LoadDistributionHeaderId				= @LoadDistributionHeaderId
				,@LoadId								= @LoadId
				,@ActualCostId							= @ActualCostId		
				,@ShipmentId							= @ShipmentId
				,@TransactionId							= @TransactionId
				,@OriginalInvoiceId						= @OriginalInvoiceId
				,@PeriodsToAccrue						= @PeriodsToAccrue		
				,@ItemId								= NULL
				,@ItemIsInventory						= 0
				,@ItemDocumentNumber					= NULL			
				,@ItemDescription						= NULL
				,@ItemUOMId								= NULL
				,@ItemQtyOrdered						= 0.000000
				,@ItemQtyShipped						= 0.000000
				,@ItemDiscount							= 0.000000
				,@ItemPrice								= 0.000000	
				,@RefreshPrice							= 0
				,@ItemMaintenanceType					= NULL
				,@ItemFrequency							= NULL
				,@ItemMaintenanceDate					= NULL
				,@ItemMaintenanceAmount					= 0.000000
				,@ItemLicenseAmount						= 0.000000
				,@ItemTaxGroupId						= NULL
				,@RecomputeTax							= 0
				,@ItemSCInvoiceId						= NULL
				,@ItemSCInvoiceNumber					= NULL
				,@ItemInventoryShipmentItemId			= NULL
				,@ItemShipmentNumber					= NULL
				,@ItemSalesOrderDetailId				= NULL												
				,@ItemSalesOrderNumber					= NULL
				,@ItemContractHeaderId					= NULL
				,@ItemContractDetailId					= NULL			
				,@ItemShipmentPurchaseSalesContractId	= NULL	
				,@ItemWeightUOMId						= NULL	
				,@ItemWeight							= 0.000000		
				,@ItemShipmentGrossWt					= 0.000000		
				,@ItemShipmentTareWt					= 0.000000		
				,@ItemShipmentNetWt						= 0.000000			
				,@ItemTicketId							= NULL		
				,@ItemTicketHoursWorkedId				= NULL		
				,@ItemOriginalInvoiceDetailId			= NULL		
				,@ItemSiteId							= NULL												
				,@ItemBillingBy							= NULL
				,@ItemPercentFull						= 0.000000
				,@ItemNewMeterReading					= 0.000000
				,@ItemPreviousMeterReading				= 0.000000
				,@ItemConversionFactor					= 0.00000000
				,@ItemPerformerId						= NULL
				,@ItemLeaseBilling						= 0
				,@ItemVirtualMeterReading				= 0
				,@ItemSubCurrencyId						= @ItemSubCurrencyId
				,@ItemSubCurrencyRate					= @ItemSubCurrencyRate
				,@EntityContactId						= @EntityContactId
				,@ItemStorageScheduleTypeId					= @StorageScheduleTypeId
				,@DocumentMaintenanceId					= @intDocumentMaintenanceId
				,@intLineOfBusinessId					= @intLineOfBusinessId
				,@intICTId								= @intICTId

		END TRY
		BEGIN CATCH
			IF ISNULL(@RaiseError,0) = 0
			BEGIN
				IF @InitTranCount = 0
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION
				ELSE
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION @Savepoint
			END

			SET @ErrorMessage = ERROR_MESSAGE()
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN 0;
		END CATCH


		SET @NewInvoiceId = @CreatedInvoiceId
		SET @NewInvoiceNumber = (SELECT strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @NewInvoiceId)

		--INSERT INVOICE DETAILS
		BEGIN TRY
			INSERT INTO tblARInvoiceDetail
				([intInvoiceId]
				,[strDocumentNumber]
				,[intItemId]
				,[strItemDescription]		
				,[intOrderUOMId]
				,[dblQtyOrdered]
				,[intItemUOMId]
				,[intPriceUOMId]
				,[dblQtyShipped]
				,[dblUnitQuantity]
				,[dblDiscount]
				,[dblItemTermDiscount]
				,[dblPrice]
				,[dblBasePrice]
				,[dblUnitPrice]
				,[dblBaseUnitPrice]
				,[strPricing]
				,[dblTotalTax]
				,[dblBaseTotalTax]
				,[dblTotal]
				,[dblBaseTotal]
				,[intSubCurrencyId]
				,[dblSubCurrencyRate]
				,[intAccountId]
				,[intCOGSAccountId]
				,[intSalesAccountId]
				,[intInventoryAccountId]
				,[intServiceChargeAccountId]
				,[strMaintenanceType]
				,[strFrequency]
				,[dtmMaintenanceDate]
				,[dblMaintenanceAmount]
				,[dblBaseMaintenanceAmount]
				,[dblLicenseAmount]
				,[dblBaseLicenseAmount]
				,[intTaxGroupId]
				,[intSCInvoiceId]
				,[intSCBudgetId]
				,[strSCInvoiceNumber]
				,[strSCBudgetDescription]
				,[intInventoryShipmentItemId]
				,[intInventoryShipmentChargeId]
				,[strShipmentNumber]
				,[intSalesOrderDetailId]
				,[strSalesOrderNumber]
				,[intContractHeaderId]
				,[intContractDetailId]
				,[intShipmentId]
				,[intLoadDetailId]
				,[intShipmentPurchaseSalesContractId]
				,[intItemWeightUOMId]
				,[dblItemWeight]
				,[dblShipmentGrossWt]
				,[dblShipmentTareWt]
				,[dblShipmentNetWt]
				,[intTicketId]
				,[intTicketHoursWorkedId]
				,[intOriginalInvoiceDetailId]
				,[intEntitySalespersonId]
				,[intSiteId]
				,[strBillingBy]
				,[dblPercentFull]
				,[dblNewMeterReading]
				,[dblPreviousMeterReading]
				,[dblConversionFactor]
				,[intPerformerId]
				,[ysnLeaseBilling]
				,[ysnVirtualMeterReading]
				,[intConcurrencyId]
				,[dblOriginalItemWeight]
				,[intStorageScheduleTypeId]
				,[intPrepayTypeId]
				,[intStorageLocationId]
				,[strVFDDocumentNumber]
				,[intCompanyLocationSubLocationId]
				,[intCurrencyExchangeRateTypeId]
				,[dblCurrencyExchangeRate]
				,[strAddonDetailKey]
				,[ysnAddonParent]
				,[dblAddOnQuantity]
				,[dblStandardWeight])
			SELECT 
				[intInvoiceId]					= @CreatedInvoiceId
				,[strDocumentNumber]			= ''
				,[intItemId]					= ARID.[intItemId]
				,[strItemDescription]			= CONVERT(NVARCHAR(100), ARID.[intInvoiceDetailId])		
				,[intOrderUOMId]				= NULL --ARID.[intOrderUOMId] 																							
				,[dblQtyOrdered]				= NULL --ARID.[dblQtyOrdered] 
				,[intItemUOMId]					= ARID.[intItemUOMId]
				,[intPriceUOMId]				= ARID.[intPriceUOMId] 
				,[dblQtyShipped]				= CASE	WHEN (ISNULL(SOSOD.intSalesOrderDetailId,0) = 0 AND ISNULL(ICISI.intInventoryShipmentItemId,0) = 0)
															THEN ARID.[dblQtyShipped]
														WHEN ISNULL(SOSOD.intSalesOrderDetailId,0) <> 0 AND @ForRecurring = 0
															THEN dbo.fnCalculateQtyBetweenUOM(SOSOD.intItemUOMId, ARID.intItemUOMId, (dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOSOD.intItemUOMId, ARID.dblQtyShipped) - SOSOD.dblQtyShipped))
														WHEN ISNULL(ICISI.intInventoryShipmentItemId,0) <> 0
															THEN dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ARID.intItemUOMId, (dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, ICISI.intItemUOMId, ARID.dblQtyShipped) - ICISI.dblQuantity))
														ELSE ARID.[dblQtyShipped]
												END
				,[dblUnitQuantity]				= ARID.[dblUnitQuantity]
				,[dblDiscount]					= ARID.[dblDiscount]
				,[dblItemTermDiscount]			= ARID.[dblItemTermDiscount]
				,[dblPrice]						= ARID.[dblPrice]
				,[dblBasePrice]					= ARID.[dblBasePrice]
				,[dblUnitPrice]					= ARID.[dblUnitPrice]
				,[dblBaseUnitPrice]				= ARID.[dblBaseUnitPrice]
				,[strPricing]					= ARID.[strPricing]
				,[dblTotalTax]					= ARID.[dblTotalTax]
				,[dblBaseTotalTax]				= ARID.[dblBaseTotalTax]
				,[dblTotal]						= ARID.[dblTotal]
				,[dblBaseTotal]					= ARID.[dblBaseTotal]
				,[intSubCurrencyId]				= ARID.[intSubCurrencyId]
				,[dblSubCurrencyRate]			= ARID.[dblSubCurrencyRate]
				,[intAccountId]					= ARID.[intAccountId]
				,[intCOGSAccountId]				= ARID.[intCOGSAccountId]
				,[intSalesAccountId]			= ARID.[intSalesAccountId]
				,[intInventoryAccountId]		= ARID.[intInventoryAccountId]
				,[intServiceChargeAccountId]	= ARID.[intServiceChargeAccountId]
				,[strMaintenanceType]			= ARID.[strMaintenanceType]
				,[strFrequency]					= ARID.[strFrequency]
				,[dtmMaintenanceDate]			= ARID.[dtmMaintenanceDate]
				,[dblMaintenanceAmount]			= ARID.[dblMaintenanceAmount]
				,[dblBaseMaintenanceAmount]		= ARID.[dblBaseMaintenanceAmount]
				,[dblLicenseAmount]				= ARID.[dblLicenseAmount]
				,[dblBaseLicenseAmount]			= ARID.[dblBaseLicenseAmount]
				,[intTaxGroupId]				= ARID.[intTaxGroupId]
				,[intSCInvoiceId]				= NULL
				,[intSCBudgetId]				= NULL
				,[strSCInvoiceNumber]			= ''
				,[strSCBudgetDescription]		= ''
				,[intInventoryShipmentItemId]	= NULL
				,[intInventoryShipmentChargeId]	= NULL
				,[strShipmentNumber]			= NULL
				,[intSalesOrderDetailId]		= NULL
				,[strSalesOrderNumber]			= NULL
				,[intContractHeaderId]			= ARID.[intContractHeaderId]
				,[intContractDetailId]			= ARID.[intContractDetailId]
				,[intShipmentId]				= NULL
				,[intLoadDetailId]				= NULL
				,[intShipmentPurchaseSalesContractId] = NULL
				,[intItemWeightUOMId]			= ARID.[intItemWeightUOMId]
				,[dblItemWeight]				= ARID.[dblItemWeight]
				,[dblShipmentGrossWt]			= ARID.[dblShipmentGrossWt]
				,[dblShipmentTareWt]			= ARID.[dblShipmentTareWt]
				,[dblShipmentNetWt]				= ARID.[dblShipmentNetWt]
				,[intTicketId]					= NULL
				,[intTicketHoursWorkedId]		= NULL
				,[intOriginalInvoiceDetailId]	= NULL
				,[intEntitySalespersonId]		= ARID.[intEntitySalespersonId]
				,[intSiteId]					= NULL
				,[strBillingBy]					= ''
				,[dblPercentFull]				= @ZeroDecimal
				,[dblNewMeterReading]			= @ZeroDecimal
				,[dblPreviousMeterReading]		= @ZeroDecimal
				,[dblConversionFactor]			= @ZeroDecimal
				,[intPerformerId]				= NULL
				,[ysnLeaseBilling]				= 0
				,[ysnVirtualMeterReading]		= 0
				,[intConcurrencyId]				= 1
				,[dblOriginalItemWeight]		= ARID.dblOriginalItemWeight
				,[intStorageScheduleTypeId]		= ARID.intStorageScheduleTypeId
				,[intPrepayTypeId]				= ARID.intPrepayTypeId
				,[intStorageLocationId]			= ARID.intStorageLocationId
				,[strVFDDocumentNumber]			= ARID.strVFDDocumentNumber
				,[intCompanyLocationSubLocationId] = ARID.intCompanyLocationSubLocationId
				,[intCurrencyExchangeRateTypeId]	= ARID.[intCurrencyExchangeRateTypeId]
				,[dblCurrencyExchangeRate]		= ARID.[dblCurrencyExchangeRate]
				,[strAddonDetailKey]			= ARID.[strAddonDetailKey]
				,[ysnAddonParent]				= ARID.[ysnAddonParent]
				,[dblAddOnQuantity]				= ARID.[dblAddOnQuantity]
				,[dblStandardWeight]		    = ARID.[dblStandardWeight]
			FROM
				tblARInvoiceDetail ARID
			LEFT OUTER JOIN
				tblICInventoryShipmentItem ICISI 
					ON ARID.intInventoryShipmentItemId = ICISI.intInventoryShipmentItemId
			LEFT OUTER JOIN
				tblSOSalesOrderDetail SOSOD 
					ON ARID.intSalesOrderDetailId = SOSOD.intSalesOrderDetailId
					AND ARID.intInventoryShipmentItemId IS NULL		
			WHERE
				[intInvoiceId] = @InvoiceId
		END TRY
		BEGIN CATCH
			IF ISNULL(@RaiseError,0) = 0
			BEGIN
				IF @InitTranCount = 0
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION
				ELSE
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION @Savepoint
			END

			SET @ErrorMessage = ERROR_MESSAGE();
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN 0;
		END CATCH

		--INSERT INVOICE TAX DETAILS
		BEGIN TRY
			IF ISNULL(@ForRecurring, 0) = 1
				BEGIN
					--UPDATE tblARInvoiceDetail SET intTaxGroupId = NULL WHERE intInvoiceId = @CreatedInvoiceId
					EXEC [dbo].[uspARReComputeInvoiceTaxes]
						@InvoiceId	= @CreatedInvoiceId
						,@DetailId	= NULL
				END
			ELSE	
				INSERT INTO [tblARInvoiceDetailTax]
					([intInvoiceDetailId]
					,[intTaxGroupId]
					,[intTaxCodeId]
					,[intTaxClassId]
					,[strTaxableByOtherTaxes]
					,[strCalculationMethod]
					,[dblRate]
					,[dblBaseRate]
					,[intSalesTaxAccountId]
					,[dblTax]
					,[dblAdjustedTax]
					,[dblBaseAdjustedTax]
					,[ysnTaxAdjusted]
					,[ysnSeparateOnInvoice]
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnTaxOnly]
					,[strNotes]
					,[intConcurrencyId])
				SELECT 
					[intInvoiceDetailId]		= ARID1.[intInvoiceDetailId]
					,[intTaxGroupId]			= ARIDT.[intTaxGroupId]
					,[intTaxCodeId]				= ARIDT.[intTaxCodeId]
					,[intTaxClassId]			= ARIDT.[intTaxClassId]
					,[strTaxableByOtherTaxes]	= ARIDT.[strTaxableByOtherTaxes]
					,[strCalculationMethod]		= ARIDT.[strCalculationMethod]
					,[dblRate]					= ARIDT.[dblRate]
					,[dblBaseRate]				= ISNULL(ARIDT.[dblBaseRate], ARIDT.[dblRate])
					,[intSalesTaxAccountId]		= ARIDT.[intSalesTaxAccountId]
					,[dblTax]					= ARIDT.[dblTax]
					,[dblAdjustedTax]			= ARIDT.[dblAdjustedTax]
					,[dblBaseAdjustedTax]		= ARIDT.[dblBaseAdjustedTax]
					,[ysnTaxAdjusted]			= ARIDT.[ysnTaxAdjusted]
					,[ysnSeparateOnInvoice]		= ARIDT.[ysnSeparateOnInvoice]
					,[ysnCheckoffTax]			= ARIDT.[ysnCheckoffTax]
					,[ysnTaxExempt]				= ARIDT.[ysnTaxExempt]
					,[ysnTaxOnly]				= ARIDT.[ysnTaxOnly]
					,[strNotes]					= ARIDT.[strNotes]
					,[intConcurrencyId]			= 1
				FROM
					tblARInvoiceDetailTax ARIDT
				INNER JOIN
					tblARInvoiceDetail ARID
						ON ARIDT.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
				INNER JOIN
					tblARInvoiceDetail ARID1
						ON ARID.[intInvoiceDetailId] = CAST(ARID1.[strItemDescription] AS INT)
				WHERE
					ARID.[intInvoiceId] = @InvoiceId
					AND ARID1.[intInvoiceId] = @CreatedInvoiceId
				
				
			UPDATE
				ARID
			SET
				ARID.[strItemDescription] = ARID1.[strItemDescription]
			FROM
				tblARInvoiceDetail ARID
			INNER JOIN
				tblARInvoiceDetail ARID1
					ON CAST(ARID.[strItemDescription] AS INT) = ARID1.[intInvoiceDetailId]
			WHERE
				ARID.[intInvoiceId] = @CreatedInvoiceId
				AND ARID1.[intInvoiceId] = @InvoiceId
				
				
			EXEC [dbo].[uspARReComputeInvoiceAmounts]
				@InvoiceId = @CreatedInvoiceId
				
			EXEC [dbo].uspARUpdateInvoiceIntegrations 
				@InvoiceId	= @CreatedInvoiceId
				,@ForDelete	= 0
				,@UserId	= @UserId
						
		END TRY
		BEGIN CATCH
			IF ISNULL(@RaiseError,0) = 0
			BEGIN
				IF @InitTranCount = 0
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION
				ELSE
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION @Savepoint
			END

			SET @ErrorMessage = ERROR_MESSAGE();
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN 0;
		END CATCH

		BEGIN TRY
			UPDATE tblARInvoice 
			SET ysnRecurring =  CASE WHEN @OldInvoiceRecurring = 1 AND @ForRecurring = 1 THEN 0 ELSE @OldInvoiceRecurring  END
			, intOriginalInvoiceId = @InvoiceId 
			, ysnImpactInventory = @IsImpactInventory
			, dblTotalWeight = @TotalWeight
			WHERE intInvoiceId = @NewInvoiceId
		END TRY
		BEGIN CATCH
			IF ISNULL(@RaiseError,0) = 0
			BEGIN
				IF @InitTranCount = 0
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION
				ELSE
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION @Savepoint
			END

			SET @ErrorMessage = @CurrentErrorMessage
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN 0;
		END CATCH

		BEGIN TRY
			SELECT 
				@ysnRecurringDuplicate = ysnRecurring 
			FROM 
				tblARInvoice 
			WHERE
				intInvoiceId = @NewInvoiceId

			IF (@ysnRecurringDuplicate = 1)
			BEGIN
				IF NOT EXISTS(SELECT NULL FROM tblSMRecurringTransaction WHERE intTransactionId = @NewInvoiceId)
				BEGIN
					EXEC dbo.[uspARInsertRecurringInvoice] @NewInvoiceId, @UserId
				END		
			END
		END TRY
		BEGIN CATCH
			IF ISNULL(@RaiseError,0) = 0
			BEGIN
				IF @InitTranCount = 0
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION
				ELSE
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION @Savepoint
			END

			SET @ErrorMessage = @CurrentErrorMessage
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN 0;
		END CATCH

END

--UPDATE INVOICE IF CREDIT NOTE
IF @IsCancel = 1
	BEGIN
		EXEC dbo.uspARReturnInvoice @intInvoiceId			= @InvoiceId	
									,@intUserId				= @UserId	
									,@strInvoiceDetailIds	= NULL
									,@ysnRaiseError			= @RaiseError
									,@intNewInvoiceId		= @NewInvoiceId	OUT
									,@strErrorMessage		= @ErrorMessage	OUT

		UPDATE tblARInvoice 
		SET ysnCancelled = 1 
		WHERE intInvoiceId = @InvoiceId
	END

IF ISNULL(@RaiseError,0) = 0
BEGIN

	IF @InitTranCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION
			IF (XACT_STATE()) = 1
				COMMIT TRANSACTION
		END		
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION  @Savepoint
			--IF (XACT_STATE()) = 1
			--	COMMIT TRANSACTION  @Savepoint
		END	
END
	
RETURN 1;

END
GO