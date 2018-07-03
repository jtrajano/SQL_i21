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
	,@ItemOrderUOMId				INT				= NULL
	,@ItemPriceUOMId				INT				= NULL
	,@ItemQtyOrdered				NUMERIC(18,6)	= 0.000000
	,@ItemUOMId						INT				= NULL
	,@ItemQtyShipped				NUMERIC(18,6)	= 0.000000
	,@ItemUnitQuantity				NUMERIC(18,6)	= 1.000000
	,@ItemDiscount					NUMERIC(18,6)	= 0.000000
	,@ItemTermDiscount				NUMERIC(18,6)	= 0.000000
	,@ItemTermDiscountBy			NVARCHAR(50)	= NULL
	,@ItemPrice						NUMERIC(18,6)	= 0.000000	
	,@ItemUnitPrice					NUMERIC(18,6)	= 0.000000	
	,@ItemPricing					NVARCHAR(250)	= NULL
	,@ItemVFDDocumentNumber			NVARCHAR(100)	= NULL
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
	,@ItemInventoryShipmentChargeId	INT				= NULL
	,@ItemRecipeItemId				INT				= NULL
	,@ItemRecipeId					INT				= NULL
	,@ItemSublocationId				INT				= NULL
	,@ItemCostTypeId				INT				= NULL
	,@ItemMarginById				INT				= NULL
	,@ItemCommentTypeId				INT				= NULL
	,@ItemMargin					NUMERIC(18,6)	= NULL
	,@ItemRecipeQty					NUMERIC(18,6)	= NULL
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
	,@ItemLotId						INT				= NULL		
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
	,@ItemCurrencyExchangeRateTypeId	INT			= NULL
	,@ItemCurrencyExchangeRateId	INT				= NULL
	,@ItemCurrencyExchangeRate		NUMERIC(18, 8)	= 1.000000
	,@ItemSubCurrencyId				INT				= NULL
	,@ItemSubCurrencyRate			NUMERIC(18,8)	= 1.000000
	,@ItemIsBlended					BIT				= 0
	,@ItemStorageScheduleTypeId		INT				= NULL
	,@ItemDestinationGradeId		INT				= NULL
	,@ItemDestinationWeightId		INT				= NULL
	,@ItemSalesAccountId			INT				= NULL
	,@ItemstrAddonDetailKey			VARCHAR(MAX)    = NULL
	,@ItemysnAddonParent			BIT				= NULL
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON

DECLARE @ZeroDecimal			NUMERIC(18, 6)
		,@EntityCustomerId		INT
		,@CompanyLocationId		INT
		,@InvoiceDate			DATETIME
		,@existingInvoiceDetail INT
		,@CurrencyId			INT
		,@InitTranCount			INT
		,@Savepoint				NVARCHAR(32)

		,@ItemName				NVARCHAR(50)
		,@LocationName			NVARCHAR(50)
		,@ItemLocationError		NVARCHAR(255)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARAddInventoryItemToInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)
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


IF @ItemPriceUOMId IS NULL
BEGIN
	SET @ItemPriceUOMId		= @ItemUOMId
	SET @ItemUnitQuantity	= 1.000000
END

SET @ItemCurrencyExchangeRate = CASE WHEN ISNULL(@ItemCurrencyExchangeRate, 0) = 0 THEN 1.000000 ELSE ISNULL(@ItemCurrencyExchangeRate, 1.000000) END
SET @ItemSubCurrencyRate = CASE WHEN ISNULL(@ItemSubCurrencyId, 0) = 0 THEN 1.000000 ELSE ISNULL(@ItemSubCurrencyRate, 1.000000) END
	
	
IF NOT EXISTS(SELECT NULL FROM tblICItem IC WHERE IC.[intItemId] = @ItemId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('Item does not exists!', 16, 1);
		SET @ErrorMessage = 'Item does not exists!'
		RETURN 0;
	END
	
IF NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation WHERE intCompanyLocationId = @CompanyLocationId)
	BEGIN		
		IF ISNULL(@RaiseError,0) = 1
			RAISERROR('The company location from the target Invoice does not exists!', 16, 1);
		SET @ErrorMessage = 'The company location from the target Invoice does not exists!'
		RETURN 0;
	END		
	
IF NOT EXISTS(	SELECT NULL 
				FROM tblICItem IC INNER JOIN tblICItemLocation IL ON IC.intItemId = IL.intItemId
				WHERE IC.[intItemId] = @ItemId AND IL.[intLocationId] = @CompanyLocationId)
	BEGIN		
		IF (ISNULL(@RaiseError,0) = 1)
		begin
			set @ItemName = (SELECT top 1 ltrim(rtrim(strItemNo)) FROM tblICItem where intItemId = @ItemId);
			set @LocationName = (SELECT top 1 ltrim(rtrim(strLocationName)) FROM tblSMCompanyLocation where intCompanyLocationId = @CompanyLocationId);
			set @ItemLocationError = 'The item (' + @ItemName + ') was not set up to be available on the specified location (' + @LocationName + ')!';
			RAISERROR(@ItemLocationError, 16, 1);
			SET @ErrorMessage = @ItemLocationError;
			RETURN 0;
		end
	END


--IF EXISTS(	SELECT	NULL 
--			FROM	tblICItem IC 
--			WHERE	IC.[intItemId] = @ItemId AND ISNULL(IC.[strLotTracking], 'No') <> 'No'
--		)
--	BEGIN		
--		IF ISNULL(@RaiseError,0) = 1
--			RAISERROR(120076, 16, 1);
--		RETURN 0;
--	END
	
IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END
	
	
DECLARE  @ContractNumber				NVARCHAR(50)
		,@ContractSeq					INT
		,@InvoiceType					NVARCHAR(200)
		,@TermId						INT
		,@Pricing						NVARCHAR(250)	= NULL
		,@ContractHeaderId				INT				= NULL
		,@ContractDetailId				INT				= NULL
		,@SpecialPrice					NUMERIC(18,6)	= 0.000000
		,@ContractUOMId					INT
		,@PriceUOMId					INT
		,@PriceUOMQuantity				NUMERIC(18,6)	= 1.000000
		,@CurrencyExchangeRateTypeId	INT
		,@CurrencyExchangeRate			NUMERIC(18,6)
		,@SubCurrencyId					INT
		,@SubCurrencyRate				NUMERIC(18,6)
		,@TermDiscountExempt			BIT
		,@TermDiscountRate				NUMERIC(18,6)

BEGIN TRY
SELECT TOP 1 @InvoiceType = strType, @TermId = intTermId FROM tblARInvoice WHERE intInvoiceId = @InvoiceId 
EXEC dbo.[uspARGetItemPrice]  
		 @ItemId						= @ItemId
		,@CustomerId					= @EntityCustomerId
		,@LocationId					= @CompanyLocationId
		,@ItemUOMId						= @ItemUOMId
		,@TransactionDate				= @InvoiceDate
		,@Quantity						= @ItemQtyShipped
		,@Price							= @SpecialPrice					OUTPUT
		,@Pricing						= @Pricing						OUTPUT
		,@ContractHeaderId				= @ContractHeaderId				OUTPUT
		,@ContractDetailId				= @ContractDetailId				OUTPUT
		,@ContractNumber				= @ContractNumber				OUTPUT
		,@ContractSeq					= @ContractSeq					OUTPUT
		,@TermDiscount					= @ItemTermDiscount				OUTPUT
		,@TermDiscountBy				= @ItemTermDiscountBy			OUTPUT
		,@TermDiscountRate				= @TermDiscountRate				OUTPUT
		,@TermDiscountExempt			= @TermDiscountExempt			OUTPUT	
		,@ContractUOMId					= @ContractUOMId				OUTPUT
		,@PriceUOMId					= @PriceUOMId					OUTPUT
		,@PriceUOMQuantity				= @PriceUOMQuantity				OUTPUT
		,@CurrencyExchangeRateTypeId	= @CurrencyExchangeRateTypeId	OUTPUT
		,@CurrencyExchangeRate			= @CurrencyExchangeRate			OUTPUT
		,@SubCurrencyId					= @SubCurrencyId				OUTPUT
		,@SubCurrencyRate				= @SubCurrencyRate				OUTPUT
		,@InvoiceType					= @InvoiceType
		,@TermId						= @TermId 

IF (ISNULL(@RefreshPrice,0) = 1)
	BEGIN
		SET @ItemPrice = @SpecialPrice
		SET @ItemUnitPrice = @SpecialPrice
		SET @ItemPricing = @Pricing
		SET @ItemContractHeaderId = @ContractHeaderId
		SET @ItemContractDetailId = @ContractDetailId
		IF ISNULL(@ContractDetailId,0) <> 0
		BEGIN
			SET @ItemPrice						= @SpecialPrice * @PriceUOMQuantity
			SET @ItemPriceUOMId					= @PriceUOMId
			SET @ItemUOMId						= @ContractUOMId
			SET @ItemOrderUOMId					= @ContractUOMId
			SET @ItemUnitQuantity				= ISNULL(@PriceUOMQuantity, 1.000000)
			SET @ItemCurrencyExchangeRateTypeId	= @CurrencyExchangeRateTypeId
			SET @ItemCurrencyExchangeRate		= ISNULL(@CurrencyExchangeRate, 1.000000)
			SET @ItemSubCurrencyId				= @SubCurrencyId
			SET @ItemSubCurrencyRate			= ISNULL(@SubCurrencyRate, 1.000000)
		END
	END
		
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

BEGIN TRY
	SELECT TOP 1 @existingInvoiceDetail = intInvoiceDetailId 
		FROM tblARInvoiceDetail 
		WHERE intSalesOrderDetailId = @ItemSalesOrderDetailId 
		  AND strSalesOrderNumber = @ItemSalesOrderNumber 
		  AND intInvoiceId = @InvoiceId
		  AND intInventoryShipmentItemId = @ItemInventoryShipmentItemId

	IF ISNULL(@existingInvoiceDetail, 0) > 0
		BEGIN
			UPDATE tblARInvoiceDetail 
				SET dblQtyOrdered = dblQtyOrdered,
					dblQtyShipped = ISNULL(@ItemQtyShipped ,0.000000)
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
				,[intPriceUOMId]
				,[dblQtyOrdered]
				,[intItemUOMId]
				,[dblQtyShipped]
				,[dblUnitQuantity]
				,[dblDiscount]
				,[dblItemTermDiscount]
				,[strItemTermDiscountBy]
				,[dblItemTermDiscountAmount]
				,[dblBaseItemTermDiscountAmount]
				,[dblItemTermDiscountExemption]
				,[dblBaseItemTermDiscountExemption]
				,[dblTermDiscountRate]
				,[ysnTermDiscountExempt]
				,[dblPrice]
				,[dblUnitPrice]
				,[strPricing]
				,[dblTotalTax]
				,[dblTotal]
				,[intCurrencyExchangeRateTypeId]
				,[intCurrencyExchangeRateId]
				,[dblCurrencyExchangeRate]
				,[intSubCurrencyId]
				,[dblSubCurrencyRate]
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
				,[intInventoryShipmentChargeId]
				,[strShipmentNumber]
				,[intRecipeItemId] 
				,[intRecipeId]
				,[intSubLocationId]
				,[intCostTypeId]
				,[intMarginById]
				,[intCommentTypeId]
				,[dblMargin]
				,[dblRecipeQuantity]
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
				,[intLotId]
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
				,[intStorageScheduleTypeId]				
				,[intDestinationGradeId]
				,[intDestinationWeightId]
				,[strVFDDocumentNumber]
				,[strAddonDetailKey]
				,[ysnAddonParent]
				,[intConcurrencyId])
			SELECT
				 [intInvoiceId]						= @InvoiceId
				,[intItemId]						= IC.[intItemId]
				,[intPrepayTypeId]					= @ItemPrepayTypeId 
				,[dblPrepayRate]					= @ItemPrepayRate
				,[strDocumentNumber]				= @ItemDocumentNumber
				,[strItemDescription]				= (CASE WHEN ISNULL(@ItemDescription, '') = '' THEN IC.[strDescription] ELSE ISNULL(@ItemDescription, '') END)
				,[intOrderUOMId]					= @ItemOrderUOMId
				,[intPriceUOMId]					= @ItemPriceUOMId
				,[dblQtyOrdered]					= ISNULL(@ItemQtyOrdered, @ZeroDecimal)
				,[intItemUOMId]						= ISNULL(ISNULL(@ItemUOMId, IL.intIssueUOMId), (SELECT TOP 1 [intItemUOMId] FROM tblICItemUOM WHERE [intItemId] = IC.[intItemId] ORDER BY [ysnStockUnit] DESC, [intItemUOMId]))
				,[dblQtyShipped]					= ISNULL(@ItemQtyShipped, @ZeroDecimal)
				,[dblUnitQuantity]					= @ItemUnitQuantity
				,[dblDiscount]						= ISNULL(@ItemDiscount, @ZeroDecimal)
				,[dblItemTermDiscount]				= ISNULL(@ItemTermDiscount, @ZeroDecimal)
				,[strItemTermDiscountBy]			= @ItemTermDiscountBy
				,[dblItemTermDiscountAmount]		= [dbo].[fnARGetItemTermDiscount](	@ItemTermDiscountBy
																						,@ItemTermDiscount
																						,@ItemQtyShipped
																						,(CASE WHEN (ISNULL(@ItemSubCurrencyRate,0) = 1 AND ISNULL(@RefreshPrice,0) = 1) THEN ISNULL(@ItemPrice, @ZeroDecimal) * @ItemSubCurrencyRate ELSE ISNULL(@ItemPrice, @ZeroDecimal) END)
																						,1.000000)
				,[dblBaseItemTermDiscountAmount]	= [dbo].[fnARGetItemTermDiscount](	@ItemTermDiscountBy
																						,@ItemTermDiscount
																						,@ItemQtyShipped
																						,(CASE WHEN (ISNULL(@ItemSubCurrencyRate,0) = 1 AND ISNULL(@RefreshPrice,0) = 1) THEN ISNULL(@ItemPrice, @ZeroDecimal) * @ItemSubCurrencyRate ELSE ISNULL(@ItemPrice, @ZeroDecimal) END)
																						,(CASE WHEN ISNULL(@ItemCurrencyExchangeRate, 0) = 0 THEN 1 ELSE ISNULL(@ItemCurrencyExchangeRate, 1) END))
				,[dblItemTermDiscountExemption]		= [dbo].[fnARGetItemTermDiscountExemption](	@TermDiscountExempt
																								,@TermDiscountRate
																								,@ItemQtyShipped
																								,(CASE WHEN (ISNULL(@ItemSubCurrencyRate,0) = 1 AND ISNULL(@RefreshPrice,0) = 1) THEN ISNULL(@ItemPrice, @ZeroDecimal) * @ItemSubCurrencyRate ELSE ISNULL(@ItemPrice, @ZeroDecimal) END)
																								,1.000000)
				,[dblBaseItemTermDiscountExemption] = [dbo].[fnARGetItemTermDiscountExemption](	@TermDiscountExempt
																								,@TermDiscountRate
																								,@ItemQtyShipped
																								,(CASE WHEN (ISNULL(@ItemSubCurrencyRate,0) = 1 AND ISNULL(@RefreshPrice,0) = 1) THEN ISNULL(@ItemPrice, @ZeroDecimal) * @ItemSubCurrencyRate ELSE ISNULL(@ItemPrice, @ZeroDecimal) END)
																								,(CASE WHEN ISNULL(@ItemCurrencyExchangeRate, 0) = 0 THEN 1 ELSE ISNULL(@ItemCurrencyExchangeRate, 1) END))
				,[dblTermDiscountRate]				= @TermDiscountRate
				,[ysnTermDiscountExempt]			= @TermDiscountExempt
				,[dblPrice]							= (CASE WHEN (ISNULL(@ItemSubCurrencyRate,0) = 1 AND ISNULL(@RefreshPrice,0) = 1) THEN ISNULL(@ItemPrice, @ZeroDecimal) * @ItemSubCurrencyRate ELSE ISNULL(@ItemPrice, @ZeroDecimal) END)
				,[dblUnitPrice]						= (CASE WHEN (ISNULL(@ItemSubCurrencyRate,0) = 1 AND ISNULL(@RefreshPrice,0) = 1) THEN ISNULL(@ItemUnitPrice, @ZeroDecimal) * @ItemSubCurrencyRate ELSE ISNULL(@ItemUnitPrice, @ZeroDecimal) END)
				,[strPricing]						= @ItemPricing 
				,[dblTotalTax]						= @ZeroDecimal
				,[dblTotal]							= @ZeroDecimal
				,[intCurrencyExchangeRateTypeId]	= @ItemCurrencyExchangeRateTypeId
				,[intCurrencyExchangeRateId]		= @ItemCurrencyExchangeRateId
				,[dblCurrencyExchangeRate]			= CASE WHEN ISNULL(@ItemCurrencyExchangeRate, 0) = 0 THEN 1 ELSE ISNULL(@ItemCurrencyExchangeRate, 1) END
				,[intSubCurrencyId]					= ISNULL(@ItemSubCurrencyId, @CurrencyId)
				,[dblSubCurrencyRate]				= CASE WHEN ISNULL(@ItemSubCurrencyId, 0) = 0 THEN 1 ELSE ISNULL(@ItemSubCurrencyRate, 1) END
				,[ysnBlended]						= @ItemIsBlended
				,[intAccountId]						= NULL --Acct.[intAccountId] 
				,[intCOGSAccountId]					= NULL --Acct.[intCOGSAccountId] 
				,[intSalesAccountId]				= @ItemSalesAccountId --ISNULL(@ItemSalesAccountId, Acct.[intSalesAccountId])
				,[intInventoryAccountId]			= NULL --Acct.[intInventoryAccountId]
				,[intServiceChargeAccountId]		= NULL --Acct.[intAccountId]
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
				,[intInventoryShipmentChargeId]		= @ItemInventoryShipmentChargeId 
				,[strShipmentNumber]				= @ItemShipmentNumber 
				,[intRecipeItemId]					= @ItemRecipeItemId 
				,[intRecipeId]						= @ItemRecipeId
				,[intSubLocationId]					= @ItemSublocationId
				,[intCostTypeId]					= @ItemCostTypeId
				,[intMarginById]					= @ItemMarginById
				,[intCommentTypeId]					= @ItemCommentTypeId	
				,[dblMargin]						= @ItemMargin
				,[dblRecipeQuantity]				= @ItemRecipeQty
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
				,[intLotId]							= @ItemLotId
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
				,[intStorageScheduleTypeId]			= @ItemStorageScheduleTypeId
				,[intDestinationGradeId]			= @ItemDestinationGradeId
				,[intDestinationWeightId]			= @ItemDestinationWeightId
				,[strVFDDocumentNumber]				= @ItemVFDDocumentNumber
				,[strAddonDetailKey]				= @ItemstrAddonDetailKey
				,[ysnAddonParent]					= @ItemysnAddonParent
				,[intConcurrencyId]					= 0
			FROM
				tblICItem IC
			INNER JOIN
				tblICItemLocation IL
					ON IC.intItemId = IL.intItemId
			--No need for this; accounts are being updated during posting (uspARUpdateTransactionAccounts)
			--And this has been causing performance issue
			--LEFT OUTER JOIN
			--	vyuARGetItemAccount Acct
			--		ON IC.[intItemId] = Acct.[intItemId]
			--		AND IL.[intLocationId] = Acct.[intLocationId]
			WHERE
				IC.[intItemId] = @ItemId
				AND IL.[intLocationId] = @CompanyLocationId
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

	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH
	
DECLARE @NewId INT
SET @NewId = SCOPE_IDENTITY()


IF(@ItemLoadDetailId IS NOT NULL AND @ItemLotId IS NOT NULL)
BEGIN
	INSERT INTO tblARInvoiceDetailLot
		([intInvoiceDetailId]
		,[intLotId]
		,[dblQuantityShipped]
		,[dblGrossWeight]
		,[dblTareWeight]
		,[dblWeightPerQty]
		,[strWarehouseCargoNumber]
		,[intSort]
		,[dtmDateCreated]
		,[dtmDateModified]
		,[intCreatedByUserId]
		,[intModifiedByUserId]
		,[intConcurrencyId])
	SELECT
		 [intInvoiceDetailId]		= @NewId
		,[intLotId]					= [intLotId] 
		,[dblQuantityShipped]		= dbo.fnCalculateQtyBetweenUOM([intWeightUOMId], ISNULL([intItemUOMId], [intWeightUOMId]), [dblNet]	)
		,[dblGrossWeight]			= [dblGross] 
		,[dblTareWeight]			= [dblTare] 
		,[dblWeightPerQty]			= [dblNet]
		,[strWarehouseCargoNumber]	= [strWarehouseCargoNumber]
		,[intSort]					= 1
		,[dtmDateCreated]			= GETDATE()
		,[dtmDateModified]			= GETDATE()
		,[intCreatedByUserId]		= NULL
		,[intModifiedByUserId]		= NULL
		,[intConcurrencyId]			= 1
	FROM
		vyuLGLoadDetailLotsView
	WHERE
		intLoadDetailId = @ItemLoadDetailId 
		AND intLotId = @ItemLotId	
END
		
BEGIN TRY
 	IF @RecomputeTax = 1
		EXEC dbo.[uspARReComputeInvoiceTaxes] @InvoiceId = @InvoiceId, @DetailId = @NewId
 	ELSE
 		EXEC dbo.[uspARReComputeInvoiceAmounts] @InvoiceId = @InvoiceId
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

SET @NewInvoiceDetailId = ISNULL(@existingInvoiceDetail, @NewId)

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

SET @ErrorMessage = NULL;
RETURN 1;
	
	
END