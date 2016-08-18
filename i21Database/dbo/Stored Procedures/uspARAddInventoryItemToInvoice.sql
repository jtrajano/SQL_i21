CREATE PROCEDURE [dbo].[uspARAddInventoryItemToInvoice]
	 @InvoiceId						INT	
	,@ItemId						INT
	,@ItemPrepayTypeId				INT				= 0
	,@ItemPrepayRate				NUMERIC(18,6)	= 0.000000
	,@NewInvoiceDetailId			INT				= NULL			OUTPUT 
	,@ErrorMessage					NVARCHAR(250)	= NULL			OUTPUT
	,@RaiseError					BIT				= 0	
	,@ItemDocumentNumber			NVARCHAR(100)	= NULL		
	,@ItemDescription				NVARCHAR(500)	= NULL
	,@OrderUOMId					INT				= NULL
	,@ItemQtyOrdered				NUMERIC(18,6)	= 0.000000
	,@ItemUOMId						INT				= NULL
	,@ItemQtyShipped				NUMERIC(18,6)	= 0.000000
	,@ItemDiscount					NUMERIC(18,6)	= 0.000000
	,@ItemPrice						NUMERIC(18,6)	= 0.000000	
	,@ItemPricing					NVARCHAR(250)	= NULL
	,@RefreshPrice					BIT				= 0
	,@ItemMaintenanceType			NVARCHAR(50)	= NULL
	,@ItemFrequency					NVARCHAR(50)	= NULL
	,@ItemMaintenanceDate			DATETIME		= NULL
	,@ItemMaintenanceAmount			NUMERIC(18,6)	= 0.000000
	,@ItemLicenseAmount				NUMERIC(18,6)	= 0.000000
	,@ItemTaxGroupId				INT				= NULL
	,@ItemStorageLocationId			INT				= NULL
	,@ItemCompanyLocationSubLocationId	INT				= NULL
	,@RecomputeTax					BIT				= 1
	,@ItemSCInvoiceId				INT				= NULL
	,@ItemSCInvoiceNumber			NVARCHAR(50)	= NULL
	,@ItemInventoryShipmentItemId	INT				= NULL
	,@ItemRecipeItemId				INT				= NULL
	,@ItemShipmentNumber			NVARCHAR(50)	= NULL
	,@ItemSalesOrderDetailId		INT				= NULL												
	,@ItemSalesOrderNumber			NVARCHAR(50)	= NULL
	,@ItemContractHeaderId			INT				= NULL
	,@ItemContractDetailId			INT				= NULL			
	,@ItemShipmentId				INT				= NULL			
	,@ItemShipmentPurchaseSalesContractId	INT		= NULL
	,@ItemWeightUOMId				INT				= NULL	
	,@ItemWeight					NUMERIC(18,6)	= 0.000000		
	,@ItemShipmentGrossWt			NUMERIC(18,6)	= 0.000000		
	,@ItemShipmentTareWt			NUMERIC(18,6)	= 0.000000		
	,@ItemShipmentNetWt				NUMERIC(18,6)	= 0.000000		
	,@ItemTicketId					INT				= NULL		
	,@ItemTicketHoursWorkedId		INT				= NULL	
	,@ItemCustomerStorageId			INT				= NULL		
	,@ItemSiteDetailId				INT				= NULL		
	,@ItemLoadDetailId				INT				= NULL		
	,@ItemOriginalInvoiceDetailId	INT				= NULL		
	,@ItemSiteId					INT				= NULL												
	,@ItemBillingBy					NVARCHAR(200)	= NULL
	,@ItemPercentFull				NUMERIC(18,6)	= 0.000000
	,@ItemNewMeterReading			NUMERIC(18,6)	= 0.000000
	,@ItemPreviousMeterReading		NUMERIC(18,6)	= 0.000000
	,@ItemConversionFactor			NUMERIC(18,8)	= 0.00000000
	,@ItemPerformerId				INT				= NULL
	,@ItemLeaseBilling				BIT				= 0
	,@ItemVirtualMeterReading		BIT				= 0
	,@EntitySalespersonId			INT				= NULL
	,@SubCurrency					BIT				= 0
	,@ItemIsBlended					BIT				= 0
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal			NUMERIC(18, 6)
		,@EntityCustomerId		INT
		,@CompanyLocationId		INT
		,@InvoiceDate			DATETIME
		,@TermDiscount			NUMERIC(18, 6)
		,@SubCurrencyCents		INT
		,@existingInvoiceDetail INT

SET @ZeroDecimal = 0.000000

IF NOT EXISTS(SELECT NULL FROM tblARInvoice WHERE intInvoiceId = @InvoiceId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120001, 16, 1);
		RETURN 0;
	END

SELECT 
	 @EntityCustomerId	= [intEntityCustomerId]
	,@CompanyLocationId = [intCompanyLocationId]
	,@InvoiceDate		= [dtmDate]
	,@SubCurrencyCents	= ISNULL([intSubCurrencyCents], 1)
FROM
	tblARInvoice
WHERE
	intInvoiceId = @InvoiceId
	
	
IF NOT EXISTS(SELECT NULL FROM tblICItem IC WHERE IC.[intItemId] = @ItemId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120002, 16, 1);
		RETURN 0;
	END
	
IF NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120003, 16, 1);
		RETURN 0;
	END		
	
IF NOT EXISTS(	SELECT NULL 
				FROM tblICItem IC INNER JOIN tblICItemLocation IL ON IC.intItemId = IL.intItemId
				WHERE IC.[intItemId] = @ItemId AND IL.[intLocationId] = @CompanyLocationId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(120004, 16, 1);
		RETURN 0;
	END
	
IF ISNULL(@RaiseError,0) = 0	
	BEGIN TRANSACTION
	
	
IF (ISNULL(@RefreshPrice,0) = 1)
	BEGIN
		DECLARE  @ContractNumber	INT
				,@ContractSeq		INT
				,@InvoiceType		NVARCHAR(200)
				,@TermId			INT

		BEGIN TRY
		SELECT TOP 1 @InvoiceType = strType, @TermId = intTermId FROM tblARInvoice WHERE intInvoiceId = @InvoiceId 
		EXEC dbo.[uspARGetItemPrice]  
			 @ItemId					= @ItemId
			,@CustomerId				= @EntityCustomerId
			,@LocationId				= @CompanyLocationId
			,@ItemUOMId					= @ItemUOMId
			,@TransactionDate			= @InvoiceDate
			,@Quantity					= @ItemQtyShipped
			,@Price						= @ItemPrice			OUTPUT
			,@Pricing					= @ItemPricing			OUTPUT
			,@ContractHeaderId			= @ItemContractHeaderId	OUTPUT
			,@ContractDetailId			= @ItemContractDetailId	OUTPUT
			,@ContractNumber			= @ContractNumber		OUTPUT
			,@ContractSeq				= @ContractSeq			OUTPUT
			,@TermDiscount				= @TermDiscount			OUTPUT
			--,@AvailableQuantity			= NULL OUTPUT
			--,@UnlimitedQuantity			= 0    OUTPUT
			--,@OriginalQuantity			= NULL
			--,@CustomerPricingOnly		= 0
			--,@VendorId					= NULL
			--,@SupplyPointId				= NULL
			--,@LastCost					= NULL
			--,@ShipToLocationId			= NULL
			--,@VendorLocationId			= NULL
			--,@PricingLevelId			= NULL
			--,@AllowQtyToExceedContract	= 0
			,@InvoiceType				= @InvoiceType
			,@TermId					= @TermId
		END TRY
		BEGIN CATCH
			SET @ErrorMessage = ERROR_MESSAGE();
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN 0;
		END CATCH
	END	

BEGIN TRY
	SELECT TOP 1 @existingInvoiceDetail = intInvoiceDetailId 
		FROM tblARInvoiceDetail 
		WHERE intSalesOrderDetailId = @ItemSalesOrderDetailId 
		  AND strSalesOrderNumber = @ItemSalesOrderNumber 
		  AND intInvoiceId = @InvoiceId		  

	IF ISNULL(@existingInvoiceDetail, 0) > 0
		BEGIN
			UPDATE tblARInvoiceDetail 
				SET dblQtyOrdered = dblQtyOrdered,
					dblQtyShipped = dblQtyShipped + ISNULL(@ItemQtyShipped ,0.000000)
			WHERE intInvoiceDetailId = @existingInvoiceDetail
		END
	ELSE
		BEGIN
			INSERT INTO [tblARInvoiceDetail]
				([intInvoiceId]
				,[intItemId]
				,[intPrepayTypeId]
				,[dblPrepayRate]
				,[strDocumentNumber]
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
				,[ysnSubCurrency]
				,[ysnBlended]
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
				,[intCompanyLocationSubLocationId]
				,[intStorageLocationId]
				,[intSCInvoiceId]
				,[strSCInvoiceNumber]
				,[intInventoryShipmentItemId]
				,[strShipmentNumber]
				,[intRecipeItemId] 
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
				,[intCustomerStorageId]
				,[intSiteDetailId]
				,[intLoadDetailId]
				,[intOriginalInvoiceDetailId]
				,[intSiteId]
				,[strBillingBy]
				,[dblPercentFull]
				,[dblNewMeterReading]
				,[dblPreviousMeterReading]
				,[dblConversionFactor]
				,[intPerformerId]
				,[ysnLeaseBilling]
				,[ysnVirtualMeterReading]
				,[intEntitySalespersonId]
				,[intConcurrencyId])
			SELECT
				 [intInvoiceId]						= @InvoiceId
				,[intItemId]						= IC.[intItemId]
				,[intPrepayTypeId]					= @ItemPrepayTypeId 
				,[dblPrepayRate]					= @ItemPrepayRate
				,[strDocumentNumber]				= @ItemDocumentNumber
				,[strItemDescription]				= (CASE WHEN ISNULL(@ItemDescription, '') = '' THEN IC.[strDescription] ELSE ISNULL(@ItemDescription, '') END)
				,[intOrderUOMId]					= @OrderUOMId
				,[dblQtyOrdered]					= ISNULL(@ItemQtyOrdered, @ZeroDecimal)
				,[intItemUOMId]						= ISNULL(ISNULL(@ItemUOMId, IL.intIssueUOMId), (SELECT TOP 1 [intItemUOMId] FROM tblICItemUOM WHERE [intItemId] = IC.[intItemId] ORDER BY [ysnStockUnit] DESC, [intItemUOMId]))
				,[dblQtyShipped]					= ISNULL(@ItemQtyShipped, @ZeroDecimal)
				,[dblDiscount]						= ISNULL(@ItemDiscount, @ZeroDecimal)
				,[dblItemTermDiscount]				= ISNULL(@TermDiscount, @ZeroDecimal)
				,[dblPrice]							= (CASE WHEN (ISNULL(@SubCurrency,0) = 1 AND ISNULL(@RefreshPrice,0) = 1) THEN ISNULL(@ItemPrice, @ZeroDecimal) * @SubCurrency ELSE ISNULL(@ItemPrice, @ZeroDecimal) END)
				,[strPricing]						= @ItemPricing 
				,[dblTotalTax]						= @ZeroDecimal
				,[dblTotal]							= @ZeroDecimal
				,[ysnSubCurrency]					= @SubCurrency
				,[ysnBlended]						= @ItemIsBlended
				,[intAccountId]						= Acct.[intAccountId] 
				,[intCOGSAccountId]					= Acct.[intCOGSAccountId] 
				,[intSalesAccountId]				= Acct.[intSalesAccountId]
				,[intInventoryAccountId]			= Acct.[intInventoryAccountId]
				,[intServiceChargeAccountId]		= Acct.[intAccountId]
				,[strMaintenanceType]				= @ItemMaintenanceType
				,[strFrequency]						= @ItemFrequency
				,[dtmMaintenanceDate]				= @ItemMaintenanceDate
				,[dblMaintenanceAmount]				= @ItemMaintenanceAmount
				,[dblLicenseAmount]					= @ItemLicenseAmount
				,[intTaxGroupId]					= @ItemTaxGroupId
				,[intCompanyLocationSubLocationId]	= @ItemCompanyLocationSubLocationId
				,[intStorageLocationId]				= @ItemStorageLocationId
				,[intSCInvoiceId]					= @ItemSCInvoiceId
				,[strSCInvoiceNumber]				= @ItemSCInvoiceNumber 
				,[intInventoryShipmentItemId]		= @ItemInventoryShipmentItemId 
				,[strShipmentNumber]				= @ItemShipmentNumber 
				,[intRecipeItemId]					= @ItemRecipeItemId 
				,[intSalesOrderDetailId]			= @ItemSalesOrderDetailId 
				,[strSalesOrderNumber]				= @ItemSalesOrderNumber 
				,[intContractHeaderId]				= @ItemContractHeaderId
				,[intContractDetailId]				= @ItemContractDetailId
				,[intShipmentId]					= @ItemShipmentId
				,[intShipmentPurchaseSalesContractId] =	@ItemShipmentPurchaseSalesContractId 
				,[intItemWeightUOMId]				= @ItemWeightUOMId
				,[dblItemWeight]					= @ItemWeight
				,[dblShipmentGrossWt]				= @ItemShipmentGrossWt
				,[dblShipmentTareWt]				= @ItemShipmentTareWt
				,[dblShipmentNetWt]					= @ItemShipmentNetWt
				,[intTicketId]						= @ItemTicketId
				,[intTicketHoursWorkedId]			= @ItemTicketHoursWorkedId 
				,[intCustomerStorageId]				= @ItemCustomerStorageId
				,[intSiteDetailId]					= @ItemSiteDetailId
				,[intLoadDetailId]					= @ItemLoadDetailId
				,[intOriginalInvoiceDetailId]		= @ItemOriginalInvoiceDetailId 
				,[intSiteId]						= @ItemSiteId
				,[strBillingBy]						= @ItemBillingBy
				,[dblPercentFull]					= @ItemPercentFull
				,[dblNewMeterReading]				= @ItemNewMeterReading
				,[dblPreviousMeterReading]			= @ItemPreviousMeterReading
				,[dblConversionFactor]				= @ItemConversionFactor
				,[intPerformerId]					= @ItemPerformerId
				,[ysnLeaseBilling]					= @ItemLeaseBilling
				,[ysnVirtualMeterReading]			= @ItemVirtualMeterReading
				,[intEntitySalespersonId]			= @EntitySalespersonId
				,[intConcurrencyId]					= 0
			FROM
				tblICItem IC
			INNER JOIN
				tblICItemLocation IL
					ON IC.intItemId = IL.intItemId
			LEFT OUTER JOIN
				vyuARGetItemAccount Acct
					ON IC.[intItemId] = Acct.[intItemId]
					AND IL.[intLocationId] = Acct.[intLocationId]
			WHERE
				IC.[intItemId] = @ItemId
				AND IL.[intLocationId] = @CompanyLocationId
		END
			
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0	
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH
	
DECLARE @NewId INT
SET @NewId = SCOPE_IDENTITY()
		
BEGIN TRY
	IF @RecomputeTax = 1
		EXEC dbo.[uspARReComputeInvoiceTaxes] @InvoiceId  
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0	
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

SET @NewInvoiceDetailId = ISNULL(@existingInvoiceDetail, @NewId)

IF ISNULL(@RaiseError,0) = 0	
	COMMIT TRANSACTION
SET @ErrorMessage = NULL;
RETURN 1;
	
	
END
GO


