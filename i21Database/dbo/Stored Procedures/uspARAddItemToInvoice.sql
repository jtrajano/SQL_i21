CREATE PROCEDURE [dbo].[uspARAddItemToInvoice]
	 @InvoiceId						INT	
	,@ItemId						INT				= NULL
	,@ItemPrepayTypeId				INT				= 0
	,@ItemPrepayRate				NUMERIC(18,6)	= 0.000000
	,@ItemIsInventory				BIT				= 0
	,@ItemIsBlended					BIT				= 0
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
	,@ItemShipmentNumber			NVARCHAR(50)	= NULL
	,@ItemRecipeItemId				INT				= NULL
	,@ItemRecipeId					INT				= NULL
	,@ItemSublocationId				INT				= NULL
	,@ItemCostTypeId				INT				= NULL
	,@ItemMarginById				INT				= NULL
	,@ItemCommentTypeId				INT				= NULL
	,@ItemMargin					NUMERIC(18,6)	= NULL
	,@ItemRecipeQty					NUMERIC(18,6)	= NULL
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
	,@ItemConversionAccountId		INT				= NULL
	,@ItemSalesAccountId			INT				= NULL
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
	,@ItemCurrencyExchangeRateTypeId	INT				= NULL
	,@ItemCurrencyExchangeRateId	INT				= NULL
	,@ItemCurrencyExchangeRate		NUMERIC(18,8)	= 1.000000
	,@ItemSubCurrencyId				INT				= NULL
	,@ItemSubCurrencyRate			NUMERIC(18,8)	= 1.000000
	,@ItemStorageScheduleTypeId		INT				= NULL
	,@ItemDestinationGradeId		INT				= NULL
	,@ItemDestinationWeightId		INT				= NULL
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON
	
DECLARE  @ZeroDecimal			NUMERIC(18, 6)
		,@NewDetailId			INT
		,@AddDetailError		NVARCHAR(MAX)
		,@CompanyLocationId		INT
		,@CurrencyId			INT
		,@InitTranCount			INT
		,@Savepoint				NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARAddItemToInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

	 
SET @ZeroDecimal = 0.000000

SELECT 
	 @CompanyLocationId = [intCompanyLocationId]
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

IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END
	

IF (ISNULL(@ItemIsInventory,0) = 1) OR [dbo].[fnIsStockTrackingItem](@ItemId) = 1
	BEGIN
		BEGIN TRY		

		EXEC [dbo].[uspARAddInventoryItemToInvoice]
			 @InvoiceId						= @InvoiceId	
			,@ItemId						= @ItemId
			,@ItemPrepayTypeId				= @ItemPrepayTypeId
			,@ItemPrepayRate				= @ItemPrepayRate
			,@NewInvoiceDetailId			= @NewDetailId		OUTPUT 
			,@ErrorMessage					= @AddDetailError	OUTPUT
			,@RaiseError					= @RaiseError
			,@ItemDocumentNumber			= @ItemDocumentNumber
			,@ItemDescription				= @ItemDescription
			,@ItemOrderUOMId				= @ItemOrderUOMId
			,@ItemPriceUOMId				= @ItemPriceUOMId
			,@ItemQtyOrdered				= @ItemQtyOrdered
			,@ItemUOMId						= @ItemUOMId
			,@ItemQtyShipped				= @ItemQtyShipped
			,@ItemUnitQuantity				= @ItemUnitQuantity
			,@ItemDiscount					= @ItemDiscount
			,@ItemTermDiscount				= @ItemTermDiscount
			,@ItemTermDiscountBy			= @ItemTermDiscountBy
			,@ItemPrice						= @ItemPrice
			,@ItemUnitPrice					= @ItemUnitPrice
			,@ItemPricing					= @ItemPricing
			,@ItemVFDDocumentNumber			= @ItemVFDDocumentNumber
			,@RefreshPrice					= @RefreshPrice
			,@ItemMaintenanceType			= @ItemMaintenanceType
			,@ItemFrequency					= @ItemFrequency
			,@ItemMaintenanceDate			= @ItemMaintenanceDate
			,@ItemMaintenanceAmount			= @ItemMaintenanceAmount
			,@ItemLicenseAmount				= @ItemLicenseAmount
			,@ItemTaxGroupId				= @ItemTaxGroupId
			,@ItemStorageLocationId			= @ItemStorageLocationId 
			,@ItemCompanyLocationSubLocationId	= @ItemCompanyLocationSubLocationId 
			,@RecomputeTax					= @RecomputeTax
			,@ItemSCInvoiceId				= @ItemSCInvoiceId
			,@ItemSCInvoiceNumber			= @ItemSCInvoiceNumber
			,@ItemInventoryShipmentItemId	= @ItemInventoryShipmentItemId
			,@ItemInventoryShipmentChargeId	= @ItemInventoryShipmentChargeId
			,@ItemRecipeItemId				= @ItemRecipeItemId
			,@ItemRecipeId					= @ItemRecipeId
			,@ItemSublocationId				= @ItemSublocationId
			,@ItemCostTypeId				= @ItemCostTypeId
			,@ItemMarginById				= @ItemMarginById
			,@ItemCommentTypeId				= @ItemCommentTypeId
			,@ItemMargin					= @ItemMargin
			,@ItemRecipeQty					= @ItemRecipeQty
			,@ItemShipmentNumber			= @ItemShipmentNumber
			,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId
			,@ItemSalesOrderNumber			= @ItemSalesOrderNumber
			,@ItemContractHeaderId			= @ItemContractHeaderId
			,@ItemContractDetailId			= @ItemContractDetailId
			,@ItemShipmentId				= @ItemShipmentId
			,@ItemShipmentPurchaseSalesContractId	= @ItemShipmentPurchaseSalesContractId
			,@ItemWeightUOMId				= @ItemWeightUOMId
			,@ItemWeight					= @ItemWeight
			,@ItemShipmentGrossWt			= @ItemShipmentGrossWt
			,@ItemShipmentTareWt			= @ItemShipmentTareWt
			,@ItemShipmentNetWt				= @ItemShipmentNetWt
			,@ItemTicketId					= @ItemTicketId
			,@ItemTicketHoursWorkedId		= @ItemTicketHoursWorkedId
			,@ItemCustomerStorageId			= @ItemCustomerStorageId
			,@ItemSiteDetailId				= @ItemSiteDetailId
			,@ItemLoadDetailId				= @ItemLoadDetailId
			,@ItemLotId						= @ItemLotId
			,@ItemOriginalInvoiceDetailId	= @ItemOriginalInvoiceDetailId
			,@ItemSiteId					= @ItemSiteId
			,@ItemBillingBy					= @ItemBillingBy
			,@ItemPercentFull				= @ItemPercentFull
			,@ItemNewMeterReading			= @ItemNewMeterReading
			,@ItemPreviousMeterReading		= @ItemPreviousMeterReading
			,@ItemConversionFactor			= @ItemConversionFactor
			,@ItemPerformerId				= @ItemPerformerId
			,@ItemLeaseBilling				= @ItemLeaseBilling
			,@ItemVirtualMeterReading		= @ItemVirtualMeterReading
			,@EntitySalespersonId			= @EntitySalespersonId
			,@ItemCurrencyExchangeRateTypeId	= @ItemCurrencyExchangeRateTypeId
			,@ItemCurrencyExchangeRateId	= @ItemCurrencyExchangeRateId
			,@ItemCurrencyExchangeRate		= @ItemCurrencyExchangeRate
			,@ItemSubCurrencyId				= @ItemSubCurrencyId
			,@ItemSubCurrencyRate			= @ItemSubCurrencyRate
			,@ItemIsBlended					= @ItemIsBlended
			,@ItemStorageScheduleTypeId		= @ItemStorageScheduleTypeId
			,@ItemDestinationGradeId		= @ItemDestinationGradeId
			,@ItemDestinationWeightId		= @ItemDestinationWeightId
			,@ItemSalesAccountId			= @ItemSalesAccountId

			IF LEN(ISNULL(@AddDetailError,'')) > 0
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

					SET @ErrorMessage = @AddDetailError;
					IF ISNULL(@RaiseError,0) = 1
						RAISERROR(@ErrorMessage, 16, 1);
					RETURN 0;
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
	END
ELSE IF ISNULL(@ItemId, 0) > 0 AND ISNULL(@ItemCommentTypeId, 0) = 0
	BEGIN
		BEGIN TRY

		DECLARE @ContractNumber					INT
				,@ContractSeq					INT
				,@InvoiceType					NVARCHAR(200)
				,@TermId						INT
				,@Pricing						NVARCHAR(250)	= NULL
				,@ContractHeaderId				INT				= NULL
				,@ContractDetailId				INT				= NULL
				,@EntityCustomerId				INT
				,@InvoiceDate					DATETIME
				,@SpecialPrice					NUMERIC(18,6)	= 0.000000
				,@ContractUOMId					INT
				,@PriceUOMId					INT
				,@PriceUOMQuantity				NUMERIC(18,6)
				,@CurrencyExchangeRateTypeId	INT
				,@CurrencyExchangeRate			NUMERIC(18,6)
				,@SubCurrencyId					INT
				,@SubCurrencyRate				NUMERIC(18,6)

		BEGIN TRY
		SELECT 
			 @EntityCustomerId	= [intEntityCustomerId]
			,@CompanyLocationId = [intCompanyLocationId]
			,@InvoiceDate		= [dtmDate]
			,@CurrencyId		= [intCurrencyId]
			,@InvoiceType		= strType
			,@TermId			= intTermId
		FROM
			tblARInvoice
		WHERE
			intInvoiceId = @InvoiceId

		IF ISNULL(@ItemUOMId, 0) = 0
		BEGIN
			SELECT TOP 1 @ItemUOMId = [intItemUOMId] FROM tblICItemUOM WHERE [intItemId] = @ItemId ORDER BY [ysnStockUnit] DESC, [intItemUOMId] 
		END



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
			,@ContractUOMId					= @ContractUOMId				OUTPUT
			,@PriceUOMId					= @PriceUOMId					OUTPUT
			,@PriceUOMQuantity				= @PriceUOMQuantity				OUTPUT
			,@CurrencyExchangeRateTypeId	= @CurrencyExchangeRateTypeId	OUTPUT
			,@CurrencyExchangeRate			= @CurrencyExchangeRate			OUTPUT
			,@SubCurrencyId					= @SubCurrencyId				OUTPUT
			,@SubCurrencyRate				= @SubCurrencyRate				OUTPUT
			--,@AvailableQuantity			= NULL OUTPUT
			--,@UnlimitedQuantity			= 0    OUTPUT
			--,@OriginalQuantity			= NULL
			--,@CustomerPricingOnly			= 0
			--,@ItemPricingOnly				= 0
			--,@VendorId					= NULL
			--,@SupplyPointId				= NULL
			--,@LastCost					= NULL
			--,@ShipToLocationId			= NULL
			--,@VendorLocationId			= NULL
			--,@PricingLevelId			= NULL
			--,@AllowQtyToExceedContract	= 0
			,@InvoiceType				= @InvoiceType
			,@TermId					= @TermId

		IF (ISNULL(@RefreshPrice,0) = 1)
			BEGIN
				SET @ItemPrice				= @SpecialPrice
				SET @ItemUnitPrice			= @SpecialPrice
				SET @ItemPricing			= @Pricing
				SET @ItemContractHeaderId	= @ContractHeaderId
				SET @ItemContractDetailId	= @ContractDetailId
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

			INSERT INTO tblARInvoiceDetail
				([intInvoiceId]
				,[intItemId]
				,[intPrepayTypeId]
				,[dblPrepayRate]
				,[strItemDescription]
				,[strDocumentNumber]
				,[intOrderUOMId]
				,[intItemUOMId]
				,[intPriceUOMId]
				,[intContractHeaderId]
				,[intContractDetailId]
				,[dblQtyOrdered]
				,[dblQtyShipped]
				,[dblUnitQuantity]
				,[dblDiscount]
				,[dblItemTermDiscount]
				,[strItemTermDiscountBy]
				,[dblMaintenanceAmount]
				,[dblLicenseAmount]
				,[dblPrice]
				,[dblUnitPrice]
				,[strPricing]
				,[strVFDDocumentNumber]
				,[intSiteId]
				,[strBillingBy]
				,[dblNewMeterReading]
				,[dblPercentFull]
				,[intPerformerId]
				,[intTaxGroupId]
				,[intCompanyLocationSubLocationId] 
				,[intStorageLocationId] 
				,[intEntitySalespersonId]
				,[intSalesOrderDetailId]
				,[strSalesOrderNumber]
				,[strMaintenanceType]
				,[strFrequency]
				,[dtmMaintenanceDate]
				,[intCurrencyExchangeRateTypeId]
				,[intCurrencyExchangeRateId]
				,[dblCurrencyExchangeRate]		
				,[intSubCurrencyId]
				,[dblSubCurrencyRate]
				,[ysnBlended]
				,[intRecipeId]
				,[intSubLocationId]
				,[intCostTypeId]
				,[intMarginById]
				,[intCommentTypeId]
				,[dblMargin]
				,[dblRecipeQuantity]
				,[intStorageScheduleTypeId]
				,[intDestinationGradeId]
				,[intDestinationWeightId]
				,[intSalesAccountId]
				,[intTicketId]
				,[intTicketHoursWorkedId])
			SELECT TOP 1
				 @InvoiceId
				,intItemId
				,@ItemPrepayTypeId
				,@ItemPrepayRate 
				,@ItemDescription
				,@ItemDocumentNumber
				,@ItemOrderUOMId
				,@ItemPriceUOMId
				,ISNULL(ISNULL(@ItemUOMId, (SELECT TOP 1 [intIssueUOMId] FROM tblICItemLocation WHERE [intItemId] = @ItemId AND [intLocationId] = @CompanyLocationId ORDER BY [intItemLocationId] )), (SELECT TOP 1 [intItemUOMId] FROM tblICItemUOM WHERE [intItemId] = @ItemId ORDER BY [ysnStockUnit] DESC, [intItemUOMId]))
				,@ItemContractHeaderId
				,@ItemContractDetailId
				,@ItemQtyOrdered
				,@ItemQtyShipped
				,@ItemUnitQuantity
				,@ItemDiscount
				,@ItemTermDiscount
				,@ItemTermDiscountBy
				,@ItemMaintenanceAmount
				,@ItemLicenseAmount
				,@ItemPrice
				,@ItemUnitPrice
				,@ItemPricing
				,@ItemVFDDocumentNumber
				,@ItemSiteId
				,@ItemBillingBy
				,@ItemNewMeterReading
				,@ItemPercentFull
				,@ItemPerformerId							
				,@ItemTaxGroupId
				,@ItemCompanyLocationSubLocationId
				,@ItemStorageLocationId
				,@EntitySalespersonId					
				,@ItemSalesOrderDetailId
				,@ItemSalesOrderNumber
				,@ItemMaintenanceType
				,@ItemFrequency
				,@ItemMaintenanceDate
				,@ItemCurrencyExchangeRateTypeId
				,@ItemCurrencyExchangeRateId
				,@ItemCurrencyExchangeRate
				,ISNULL(@ItemSubCurrencyId, @CurrencyId)
				,@ItemSubCurrencyRate
				,@ItemIsBlended
				,@ItemRecipeId
				,@ItemSublocationId
				,@ItemCostTypeId
				,@ItemMarginById
				,@ItemCommentTypeId
				,@ItemMargin
				,@ItemRecipeQty
				,@ItemStorageScheduleTypeId
				,@ItemDestinationGradeId
				,@ItemDestinationWeightId
				,@ItemSalesAccountId
				,@ItemTicketId
				,@ItemTicketHoursWorkedId
			FROM tblICItem WHERE intItemId = @ItemId

			SET @NewDetailId = SCOPE_IDENTITY()

			BEGIN TRY
				IF @RecomputeTax = 1
					EXEC dbo.[uspARReComputeInvoiceTaxes] @InvoiceId = @InvoiceId  
 					IF @RecomputeTax = 1
						EXEC dbo.[uspARReComputeInvoiceTaxes] @InvoiceId = @InvoiceId, @DetailId = @NewDetailId				 
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
	END
ELSE IF((LEN(RTRIM(LTRIM(@ItemDescription))) > 0 OR ISNULL(@ItemPrice,@ZeroDecimal) <> 0 )) AND (ISNULL(@ItemCommentTypeId, 0) IN (0,1,3))
	BEGIN
		SET @ItemId = CASE WHEN (ISNULL(@ItemCommentTypeId, 0) <> 0) THEN @ItemId ELSE NULL END
		
		BEGIN TRY
		EXEC [dbo].[uspARAddMiscItemToInvoice]
			 @InvoiceId						= @InvoiceId
			,@ItemId						= @ItemId
			,@ItemPrepayTypeId				= @ItemPrepayTypeId
			,@ItemPrepayRate				= @ItemPrepayRate
			,@NewInvoiceDetailId			= @NewDetailId		OUTPUT 
			,@ErrorMessage					= @AddDetailError	OUTPUT
			,@RaiseError					= @RaiseError
			,@ItemDescription				= @ItemDescription
			,@ItemDocumentNumber			= @ItemDocumentNumber
			,@ItemQtyOrdered				= @ItemQtyOrdered
			,@ItemQtyShipped				= @ItemQtyShipped
			,@ItemDiscount					= @ItemDiscount
			,@ItemPrice						= @ItemPrice
			,@ItemUnitPrice					= @ItemUnitPrice
			,@ItemTermDiscount				= @ItemTermDiscount
			,@ItemTermDiscountBy			= @ItemTermDiscountBy
			,@RecomputeTax					= @RecomputeTax
			,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId
			,@ItemTaxGroupId				= @ItemTaxGroupId
			,@EntitySalespersonId			= @EntitySalespersonId
			,@ItemCurrencyExchangeRateTypeId	= @ItemCurrencyExchangeRateTypeId
			,@ItemCurrencyExchangeRateId	= @ItemCurrencyExchangeRateId
			,@ItemCurrencyExchangeRate		= @ItemCurrencyExchangeRate
			,@ItemSubCurrencyId				= @ItemSubCurrencyId
			,@ItemSubCurrencyRate			= @ItemSubCurrencyRate
			,@ItemRecipeItemId				= @ItemRecipeItemId
			,@ItemRecipeId					= @ItemRecipeId
			,@ItemSublocationId				= @ItemSublocationId
			,@ItemCostTypeId				= @ItemCostTypeId
			,@ItemMarginById				= @ItemMarginById
			,@ItemCommentTypeId				= @ItemCommentTypeId
			,@ItemMargin					= @ItemMargin
			,@ItemRecipeQty					= @ItemRecipeQty
			,@ItemConversionAccountId		= @ItemConversionAccountId
			,@ItemSalesAccountId			= @ItemSalesAccountId
			,@ItemStorageScheduleTypeId		= @ItemStorageScheduleTypeId
			,@ItemTicketId					= @ItemTicketId

			IF LEN(ISNULL(@AddDetailError,'')) > 0
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

					SET @ErrorMessage = @AddDetailError;
					IF ISNULL(@RaiseError,0) = 1
						RAISERROR(@ErrorMessage, 16, 1);
					RETURN 0;
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
	END
	
		
SET @NewInvoiceDetailId = @NewDetailId

UPDATE tblARInvoiceDetail SET intStorageScheduleTypeId = ABC.intStorageScheduleTypeId, intCompanyLocationSubLocationId = ABC.intSubLocationId, intStorageLocationId = ABC.intStorageLocationId
FROM tblARInvoiceDetail
INNER JOIN
(
SELECT intInvoiceId, intStorageScheduleTypeId, intStorageLocationId, intSubLocationId FROM tblICInventoryShipment  ICIS
INNER JOIN (SELECT intInventoryShipmentId, intItemId, intItemUOMId, intOrderId, intStorageLocationId, intSubLocationId FROM tblICInventoryShipmentItem) ICISI ON ICIS.intInventoryShipmentId = ICISI.intInventoryShipmentId
INNER JOIN (SELECT SO.intSalesOrderId, SO.strSalesOrderNumber, intStorageScheduleTypeId, intItemId, intItemUOMId FROM tblSOSalesOrder SO 
			INNER JOIN (SELECT intSalesOrderId, intStorageScheduleTypeId, intItemId, intItemUOMId  FROM tblSOSalesOrderDetail) SOD ON SO.intSalesOrderId = SOD.intSalesOrderId) SO ON ICIS.strReferenceNumber = SO.strSalesOrderNumber AND ICISI.intItemId = SO.intItemId AND ICISI.intItemUOMId = SO.intItemUOMId
INNER JOIN (SELECT ARI.intInvoiceId, ARID.strDocumentNumber, strInvoiceNumber, intItemId, intItemUOMId FROM tblARInvoice ARI  
			INNER JOIN (SELECT intInvoiceId, strDocumentNumber, intItemId, intItemUOMId FROM tblARInvoiceDetail) ARID ON ARI.intInvoiceId = ARID.intInvoiceId 
						WHERE strDocumentNumber IS NOT NULL AND ISNULL(strDocumentNumber,'') <> '' AND ARI.intInvoiceId = @InvoiceId ) ARI ON ICIS.strShipmentNumber = ARI.strDocumentNumber AND ICISI.intItemId = ARI.intItemId AND ICISI.intItemUOMId = ARI.intItemUOMId
) ABC ON tblARInvoiceDetail.intInvoiceId = ABC.intInvoiceId
WHERE tblARInvoiceDetail.intInvoiceId = @InvoiceId


EXEC [dbo].[uspARReComputeInvoiceAmounts] @InvoiceId

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