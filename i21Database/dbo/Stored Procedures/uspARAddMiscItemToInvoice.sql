CREATE PROCEDURE [dbo].[uspARAddMiscItemToInvoice]
	 @InvoiceId						INT
	,@ItemId						INT				= NULL
	,@ItemPrepayTypeId				INT				= 0
	,@ItemPrepayRate				NUMERIC(18,6)	= 0.000000
	,@NewInvoiceDetailId			INT				= NULL			OUTPUT 
	,@ErrorMessage					NVARCHAR(250)	= NULL			OUTPUT
	,@RaiseError					BIT				= 0			
	,@ItemDescription				NVARCHAR(500)	= NULL
	,@ItemDocumentNumber			NVARCHAR(100)	= NULL
	,@ItemQtyOrdered				NUMERIC(18,6)	= 0.000000
	,@ItemQtyShipped				NUMERIC(18,6)	= 0.000000
	,@ItemDiscount					NUMERIC(18,6)	= 0.000000
	,@ItemPrice						NUMERIC(18,6)	= 0.000000
	,@ItemTermDiscount				NUMERIC(18,6)	= 0.000000
	,@ItemTermDiscountBy			NVARCHAR(50)	= NULL
	,@ItemSalesOrderDetailId		INT				= NULL	
	,@ItemTaxGroupId				INT				= NULL
	,@EntitySalespersonId			INT				= NULL	
	,@ItemCurrencyExchangeRateTypeId	INT				= NULL
	,@ItemCurrencyExchangeRateId	INT				= NULL
	,@ItemCurrencyExchangeRate		NUMERIC(18,8)	= 1.000000
	,@ItemSubCurrencyId				INT				= NULL
	,@ItemSubCurrencyRate			NUMERIC(18,8)	= 1.000000
	,@ItemRecipeItemId				INT				= NULL
	,@ItemRecipeId					INT				= NULL
	,@ItemSublocationId				INT				= NULL
	,@ItemCostTypeId				INT				= NULL
	,@ItemMarginById				INT				= NULL
	,@ItemCommentTypeId				INT				= NULL
	,@ItemMargin					NUMERIC(18,6)	= NULL
	,@ItemRecipeQty					NUMERIC(18,6)	= NULL
	,@RecomputeTax					BIT				= 1
	,@ItemConversionAccountId		INT				= NULL
	,@ItemSalesAccountId			INT				= NULL
	,@ItemStorageScheduleTypeId		INT				= NULL
	,@ItemDestinationGradeId		INT				= NULL
	,@ItemDestinationWeightId		INT				= NULL
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal				NUMERIC(18, 6)
		,@EntityCustomerId			INT
		,@CompanyLocationId			INT
		,@InvoiceDate				DATETIME
		,@ServiceChargesAccountId	INT
		,@CurrencyId				INT
		
SET @ZeroDecimal = 0.000000

IF NOT EXISTS(SELECT NULL FROM tblARInvoice WHERE intInvoiceId = @InvoiceId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Invoice does not exists!', 16, 1);
		RETURN 0;
	END

SELECT 
	 @EntityCustomerId	= [intEntityCustomerId]
	,@CompanyLocationId = [intCompanyLocationId]
	,@InvoiceDate		= [dtmDate]
	,@CurrencyId		= [intCurrencyId]
FROM
	tblARInvoice
WHERE
	intInvoiceId = @InvoiceId		
	
IF NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('The company location from the target Invoice does not exists!', 16, 1);
		SET @ErrorMessage = 'The company location from the target Invoice does not exists!'	
		RETURN 0;
	END	

IF ISNULL(@ItemConversionAccountId,0) <> 0 AND NOT EXISTS(SELECT NULL FROM vyuGLAccountDetail WHERE [strAccountCategory] = 'General' AND [strAccountType] = 'Asset' AND [intAccountId] = @ItemConversionAccountId)
	BEGIN
		SET @ErrorMessage = 'Invalid Conversion Account Id! Must be of type ''Asset'' and of category ''General'''
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR(@ErrorMessage, 16, 1);
		RETURN 0;
	END
		
	
SET @ServiceChargesAccountId = (SELECT TOP 1 intServiceChargeAccountId FROM tblARCompanyPreference WHERE intServiceChargeAccountId IS NOT NULL AND intServiceChargeAccountId <> 0)	
--IF ISNULL(@ServiceChargesAccountId,0) = 0
--	BEGIN
--		SET @ErrorMessage = 'The Service Charge account in the Company Preferences was not set.'
--		RETURN 0;
--	END	
		
IF ISNULL(@RaiseError,0) = 0	
	BEGIN TRANSACTION		

BEGIN TRY
	INSERT INTO [tblARInvoiceDetail]
		([intInvoiceId]
		,[intItemId]
		,[intPrepayTypeId]
		,[dblPrepayRate]
		,[strItemDescription]
		,[strDocumentNumber]
		,[intItemUOMId]
		,[dblQtyOrdered]
		,[dblQtyShipped]
		,[dblDiscount]
		,[dblPrice]
		,[dblTotalTax]
		,[dblTotal]
		,[intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]
		,[intSubCurrencyId]
		,[dblSubCurrencyRate]
		,[intAccountId]
		,[intCOGSAccountId]
		,[intInventoryAccountId]
		,[intServiceChargeAccountId]
		,[strMaintenanceType]
		,[strFrequency]
		,[dtmMaintenanceDate]
		,[dblMaintenanceAmount]
		,[dblLicenseAmount]
		,[intTaxGroupId]
		,[intSCInvoiceId]
		,[strSCInvoiceNumber]
		,[intInventoryShipmentItemId]
		,[strShipmentNumber]
		,[intSalesOrderDetailId]
		,[strSalesOrderNumber]
		,[intContractHeaderId]
		,[intContractDetailId]
		,[intShipmentId]
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
		,[intEntitySalespersonId]
		,[intRecipeItemId]
		,[intRecipeId]
		,[intSubLocationId]
		,[intCostTypeId]
		,[intMarginById]
		,[intCommentTypeId]
		,[dblMargin]
		,[dblRecipeQuantity]
		,[intConversionAccountId]
		,[intSalesAccountId]
		,[intConcurrencyId]
		,[intStorageScheduleTypeId]
		,[intDestinationGradeId]
		,[intDestinationWeightId]
		,[dblItemTermDiscount]
		,[strItemTermDiscountBy])
	SELECT
		 [intInvoiceId]						= @InvoiceId
		,[intItemId]						= @ItemId
		,[intPrepayTypeId]					= @ItemPrepayTypeId 
		,[dblPrepayRate]					= @ItemPrepayRate 
		,[strItemDescription]				= ISNULL(@ItemDescription, '')
		,[strDocumentNumber]				= @ItemDocumentNumber
		,[intItemUOMId]						= NULL
		,[dblQtyOrdered]					= ISNULL(@ItemQtyOrdered, @ZeroDecimal)
		,[dblQtyShipped]					= ISNULL(@ItemQtyShipped, @ZeroDecimal)
		,[dblDiscount]						= ISNULL(@ItemDiscount, @ZeroDecimal)
		,[dblPrice]							= ISNULL(@ItemPrice, @ZeroDecimal)			
		,[dblTotalTax]						= @ZeroDecimal
		,[dblTotal]							= @ZeroDecimal
		,[intCurrencyExchangeRateTypeId]	= @ItemCurrencyExchangeRateTypeId
		,[intCurrencyExchangeRateId]		= @ItemCurrencyExchangeRateId
		,[dblCurrencyExchangeRate]			= CASE WHEN ISNULL(@ItemCurrencyExchangeRate, 0) = 0 THEN 1 ELSE ISNULL(@ItemCurrencyExchangeRate, 1) END
		,[intSubCurrencyId]					= ISNULL(@ItemSubCurrencyId, @CurrencyId)
		,[dblSubCurrencyRate]				= CASE WHEN ISNULL(@ItemSubCurrencyId, 0) = 0 THEN 1 ELSE ISNULL(@ItemSubCurrencyRate, 1) END
		,[intAccountId]						= NULL 
		,[intCOGSAccountId]					= NULL
		,[intInventoryAccountId]			= NULL
		,[intServiceChargeAccountId]		= NULL
		,[strMaintenanceType]				= NULL
		,[strFrequency]						= NULL
		,[dtmMaintenanceDate]				= NULL
		,[dblMaintenanceAmount]				= NULL
		,[dblLicenseAmount]					= NULL
		,[intTaxGroupId]					= @ItemTaxGroupId
		,[intSCInvoiceId]					= NULL
		,[strSCInvoiceNumber]				= NULL 
		,[intInventoryShipmentItemId]		= NULL 
		,[strShipmentNumber]				= NULL 
		,[intSalesOrderDetailId]			= @ItemSalesOrderDetailId 
		,[strSalesOrderNumber]				= NULL 
		,[intContractHeaderId]				= NULL
		,[intContractDetailId]				= NULL
		,[intShipmentId]					= NULL
		,[intShipmentPurchaseSalesContractId] =	NULL 
		,[intTicketId]						= NULL
		,[intTicketHoursWorkedId]			= NULL 
		,[intSiteId]						= NULL
		,[strBillingBy]						= NULL
		,[dblPercentFull]					= NULL
		,[dblNewMeterReading]				= NULL
		,[dblPreviousMeterReading]			= NULL
		,[dblConversionFactor]				= NULL
		,[intPerformerId]					= NULL
		,[ysnLeaseBilling]					= NULL
		,[ysnVirtualMeterReading]			= NULL
		,[intEntitySalespersonId]			= @EntitySalespersonId
		,[intRecipeItemId]					= @ItemRecipeItemId
		,[intRecipeId]						= @ItemRecipeId
		,[intSubLocationId]					= @ItemSublocationId
		,[intCostTypeId]					= @ItemCostTypeId
		,[intMarginById]					= @ItemMarginById
		,[intCommentTypeId]					= @ItemCommentTypeId
		,[dblMargin]						= @ItemMargin
		,[dblRecipeQuantity]				= @ItemRecipeQty
		,[intConversionAccountId]			= @ItemConversionAccountId
		,[intSalesAccountId]				= @ItemSalesAccountId
		,[intConcurrencyId]					= 0
		,[intStorageScheduleTypeId]			= @ItemStorageScheduleTypeId
		,[intDestinationGradeId]			= @ItemDestinationGradeId
		,[intDestinationWeightId]			= @ItemDestinationWeightId
		,[dblItemTermDiscount]				= @ItemTermDiscount
		,[strItemTermDiscountBy]			= @ItemTermDiscountBy
			
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
	EXEC dbo.[uspARReComputeInvoiceTaxes] @InvoiceId = @InvoiceId, @DetailId = @NewId
ELSE
	EXEC dbo.[uspARReComputeInvoiceAmounts] @InvoiceId = @InvoiceId
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0	
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

SET @NewInvoiceDetailId = @NewId

IF ISNULL(@RaiseError,0) = 0	
	COMMIT TRANSACTION
SET @ErrorMessage = NULL;
RETURN 1;
	
	
END