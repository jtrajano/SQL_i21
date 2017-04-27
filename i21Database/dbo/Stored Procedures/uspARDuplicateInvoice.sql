CREATE PROCEDURE [dbo].[uspARDuplicateInvoice]
	 @InvoiceId			INT
	,@InvoiceDate		DATETIME		= NULL
	,@UserId			INT				= NULL
	,@NewInvoiceNumber	NVARCHAR(25)	= NULL	OUTPUT
	,@NewInvoiceId		INT				= NULL	OUTPUT
	,@RaiseError		BIT				= 0
	,@ErrorMessage		NVARCHAR(250)	= NULL	OUTPUT
	,@ForRecurring		BIT				= 0	
AS

BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

DECLARE @CurrentErrorMessage NVARCHAR(250)
		,@ZeroDecimal NUMERIC(18, 6)
		
SET @ZeroDecimal = 0.000000

		
IF ISNULL(@RaiseError,0) = 0
	BEGIN TRANSACTION
	

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
		,@PostDate					DATETIME
		,@PeriodsToAccrue			INT
		,@EntitySalespersonId		INT
		,@FreightTermId				INT
		,@ShipViaId					INT
		,@PaymentMethodId			INT
		,@InvoiceOriginId			NVARCHAR(8)
		,@PONumber					NVARCHAR(25)
		,@BOLNumber					NVARCHAR(50)
		,@DeliverPickup				NVARCHAR(100)
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
		
SELECT 
	 @InvoiceNumber					= [strInvoiceNumber]
	,@TransactionType				= [strTransactionType]
	,@Type							= [strType]
	,@EntityCustomerId				= [intEntityCustomerId]
	,@CompanyLocationId				= [intCompanyLocationId]
	,@CurrencyId					= [intCurrencyId]
	,@TermId						= [intTermId]
	,@Date							= CAST(ISNULL(@InvoiceDate, GETDATE()) AS DATE)
	,@DueDate						= NULL	--[dtmDueDate]
	,@ShipDate						= CAST(GETDATE() AS DATE)
	,@PostDate						= NULL	--[dtmPostDate]
	,@PeriodsToAccrue				= [intPeriodsToAccrue]
	,@EntitySalespersonId			= [intEntitySalespersonId]
	,@FreightTermId					= [intFreightTermId]
	,@ShipViaId						= [intShipViaId]
	,@PaymentMethodId				= [intPaymentMethodId]
	,@InvoiceOriginId				= ''	--[strInvoiceOriginId]
	,@PONumber						= [strPONumber]
	,@BOLNumber						= [strBOLNumber]
	,@DeliverPickup					= [strDeliverPickup]
	,@Comments						= CASE WHEN [ysnRecurring] = 1 AND @ForRecurring = 1
										THEN [strComments]
										ELSE [strComments] + ' DUP: ' + [strInvoiceNumber] 
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
	,@ActualCostId					= NULL	--[strActualCostId]
	,@ShipmentId					= NULL	--[intShipmentId]
	,@TransactionId					= NULL	--[intTransactionId]
	,@OriginalInvoiceId				= NULL	--[intOriginalInvoiceId]
	,@EntityId						= @UserId
	,@OldInvoiceRecurring			= [ysnRecurring]
	,@IsImpactInventory				= [ysnImpactInventory]
	,@TotalWeight					= [dblTotalWeight]
	,@EntityContactId				= [intEntityContactId]
	,@TotalTermDiscount				= [dblTotalTermDiscount]	
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
			ROLLBACK TRANSACTION		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Duplicating of Transport Delivery Invoice type is not allowed.', 16, 1)
		RETURN 0;
	END
	
IF @Type = 'CF Tran'
    BEGIN    
        IF ISNULL(@RaiseError,0) = 0
            ROLLBACK TRANSACTION        
        IF ISNULL(@RaiseError,0) = 1
            RAISERROR('Duplicating of CF Tran Invoice type is not allowed.', 16, 1)
        RETURN 0;
    END
      
IF @Type = 'CF Invoice'
    BEGIN    
        IF ISNULL(@RaiseError,0) = 0
            ROLLBACK TRANSACTION        
        IF ISNULL(@RaiseError,0) = 1
            RAISERROR('Duplicating of CF Invoice Invoice type is not allowed.', 16, 1)
        RETURN 0;
    END
  
IF @Type = 'Meter Billing'
    BEGIN    
        IF ISNULL(@RaiseError,0) = 0
            ROLLBACK TRANSACTION        
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
			ROLLBACK TRANSACTION		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120079, 16, 1)
		RETURN 0;
	END

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

----VALIDATE INVOICES THAT WILL EXCEED SHIPPED QTY - Inventory Shipment
--IF EXISTS(	SELECT 
--				NULL
--			FROM
--				tblARInvoiceDetail ARID
--			INNER JOIN
--				tblICInventoryShipmentItem ICISI 
--					ON ARID.intInventoryShipmentItemId = ICISI.intInventoryShipmentItemId
--			WHERE 
--				ARID.intInvoiceId = @InvoiceId
--				AND ISNULL(dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, ICISI.intItemUOMId, ARID.dblQtyShipped),0) > ISNULL(ICISI.dblQuantity, @ZeroDecimal))
--	BEGIN
--		IF ISNULL(@RaiseError,0) = 0
--			ROLLBACK TRANSACTION		
--		IF ISNULL(@RaiseError,0) = 1
--			RAISERROR(120039, 16, 1)
--		RETURN 0;
--	END

----VALIDATE INVOICES THAT WILL EXCEED SHIPPED QTY - Sales Order
--IF EXISTS(	SELECT
--				NULL 
--			FROM
--				tblARInvoiceDetail ARID
--			INNER JOIN
--				tblSOSalesOrderDetail SOSOD 
--					ON ARID.intSalesOrderDetailId = SOSOD.intSalesOrderDetailId
--					AND ARID.intInventoryShipmentItemId IS NULL
--			WHERE
--				ARID.intInvoiceId = @InvoiceId
--				AND ISNULL(dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOSOD.intItemUOMId, ARID.dblQtyShipped),0) > ISNULL(SOSOD.dblQtyOrdered - SOSOD.dblQtyShipped, @ZeroDecimal))
--	BEGIN
--		IF ISNULL(@RaiseError,0) = 0
--			ROLLBACK TRANSACTION		
--		IF ISNULL(@RaiseError,0) = 1
--			RAISERROR(120040, 16, 1)
--		RETURN 0;
--	END


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
		,@DeliverPickUp							= @DeliverPickup
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

END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = @CurrentErrorMessage
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH


SET @NewInvoiceId = @CreatedInvoiceId
SET @NewInvoiceNumber = (SELECT strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @NewInvoiceId)


BEGIN TRY
	INSERT INTO tblARInvoiceDetail
		([intInvoiceId]
		,[strDocumentNumber]
		,[intItemId]
		,[strItemDescription]		
		,[intOrderUOMId]
		,[dblQtyOrdered]
		,[intItemUOMId]
		,[dblQtyShipped]
		,[dblDiscount]
		,[dblItemTermDiscount]
		,[dblPrice]
		,[strPricing]
		,[dblTotalTax]
		,[dblTotal]
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
		,[dblLicenseAmount]
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
		,[intCompanyLocationSubLocationId])
	SELECT 
		 [intInvoiceId]					= @CreatedInvoiceId
		,[strDocumentNumber]			= ''
		,[intItemId]					= ARID.[intItemId]
		,[strItemDescription]			= CONVERT(NVARCHAR(100), ARID.[intInvoiceDetailId])		
		,[intOrderUOMId]				= NULL --ARID.[intOrderUOMId] 																							
		,[dblQtyOrdered]				= NULL --ARID.[dblQtyOrdered] 
		,[intItemUOMId]					= ARID.[intItemUOMId]
		,[dblQtyShipped]				= CASE	WHEN ISNULL(SOSOD.intSalesOrderDetailId,0) = 0 AND ISNULL(ICISI.intInventoryShipmentItemId,0) = 0
													THEN ARID.[dblQtyShipped]
												WHEN ISNULL(SOSOD.intSalesOrderDetailId,0) <> 0
													THEN dbo.fnCalculateQtyBetweenUOM(SOSOD.intItemUOMId, ARID.intItemUOMId, (dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, SOSOD.intItemUOMId, ARID.dblQtyShipped) - SOSOD.dblQtyShipped))
												WHEN ISNULL(ICISI.intInventoryShipmentItemId,0) <> 0
													THEN dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ARID.intItemUOMId, (dbo.fnCalculateQtyBetweenUOM(ARID.intItemUOMId, ICISI.intItemUOMId, ARID.dblQtyShipped) - ICISI.dblQuantity))
												ELSE ARID.[dblQtyShipped]
										  END
		,[dblDiscount]					= ARID.[dblDiscount]
		,[dblItemTermDiscount]			= ARID.[dblItemTermDiscount]
		,[dblPrice]						= ARID.[dblPrice]
		,[strPricing]					= ARID.[strPricing]
		,[dblTotalTax]					= ARID.[dblTotalTax]
		,[dblTotal]						= ARID.[dblTotal]
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
		,[dblLicenseAmount]				= ARID.[dblLicenseAmount]
		,[intTaxGroupId]				= ARID.[intTaxGroupId]
		,[intSCInvoiceId]				= NULL
		,[intSCBudgetId]				= NULL
		,[strSCInvoiceNumber]			= ''
		,[strSCBudgetDescription]		= ''
		,[intInventoryShipmentItemId]	= NULL-- ARID.[intInventoryShipmentItemId]
		,[intInventoryShipmentChargeId]	= NULL
		,[strShipmentNumber]			= ''
		,[intSalesOrderDetailId]		=  NULL --ARID.[intSalesOrderDetailId]
		,[strSalesOrderNumber]			= '' --ARID.[strSalesOrderNumber]
		,[intContractHeaderId]			= ARID.[intContractHeaderId]
		,[intContractDetailId]			= ARID.[intContractDetailId]
		,[intShipmentId]				= NULL
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
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH


BEGIN TRY
	INSERT INTO [tblARInvoiceDetailTax]
		([intInvoiceDetailId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[intSalesTaxAccountId]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[ysnTaxExempt]
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
		,[intSalesTaxAccountId]		= ARIDT.[intSalesTaxAccountId]
		,[dblTax]					= ARIDT.[dblTax]
		,[dblAdjustedTax]			= ARIDT.[dblAdjustedTax]
		,[ysnTaxAdjusted]			= ARIDT.[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]		= ARIDT.[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]			= ARIDT.[ysnCheckoffTax]
		,[ysnTaxExempt]				= ARIDT.[ysnTaxExempt]
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
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

BEGIN TRY
	UPDATE tblARInvoice SET ysnRecurring =  CASE WHEN @OldInvoiceRecurring = 1 AND @ForRecurring = 1 THEN 0 ELSE @OldInvoiceRecurring  END, 
	ysnImpactInventory = @IsImpactInventory, dblTotalWeight = @TotalWeight
	WHERE intInvoiceId = @NewInvoiceId
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
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
		ROLLBACK TRANSACTION
	SET @ErrorMessage = @CurrentErrorMessage
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION 
	
RETURN 1;

END
GO


