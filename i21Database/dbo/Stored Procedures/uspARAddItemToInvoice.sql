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
	,@OrderUOMId					INT				= NULL
	,@ItemQtyOrdered				NUMERIC(18,6)	= 0.000000
	,@ItemUOMId						INT				= NULL
	,@ItemQtyShipped				NUMERIC(18,6)	= 0.000000
	,@ItemDiscount					NUMERIC(18,6)	= 0.000000
	,@ItemTermDiscount				NUMERIC(18,6)	= 0.000000
	,@ItemTermDiscountBy			NVARCHAR(50)	= NULL
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
	,@ItemOriginalInvoiceDetailId	INT				= NULL		
	,@ItemConversionAccountId		INT				= NULL
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
	,@ItemSubCurrencyId				INT				= NULL
	,@ItemSubCurrencyRate			NUMERIC(18,8)	= NULL
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
	
DECLARE  @ZeroDecimal			NUMERIC(18, 6)
		,@NewDetailId			INT
		,@AddDetailError		NVARCHAR(MAX)
		,@CompanyLocationId		INT
		,@CurrencyId			INT

		 
SET @ZeroDecimal = 0.000000

SELECT 
	 @CompanyLocationId = [intCompanyLocationId]
	 ,@CurrencyId		= [intCurrencyId]	
FROM
	tblARInvoice WITH (NOLOCK)
WHERE
	intInvoiceId = @InvoiceId

IF ISNULL(@RaiseError,0) = 0
	BEGIN TRANSACTION
	

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
			,@OrderUOMId					= @OrderUOMId
			,@ItemQtyOrdered				= @ItemQtyOrdered
			,@ItemUOMId						= @ItemUOMId
			,@ItemQtyShipped				= @ItemQtyShipped
			,@ItemDiscount					= @ItemDiscount
			,@ItemTermDiscount				= @ItemTermDiscount
			,@ItemTermDiscountBy			= @ItemTermDiscountBy
			,@ItemPrice						= @ItemPrice
			,@ItemPricing					= @ItemPricing
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
			,@ItemSubCurrencyId				= @ItemSubCurrencyId
			,@ItemSubCurrencyRate			= @ItemSubCurrencyRate
			,@ItemIsBlended					= @ItemIsBlended
			,@ItemStorageScheduleTypeId		= @ItemStorageScheduleTypeId
			,@ItemDestinationGradeId		= @ItemDestinationGradeId
			,@ItemDestinationWeightId		= @ItemDestinationWeightId

			IF LEN(ISNULL(@AddDetailError,'')) > 0
				BEGIN
					IF ISNULL(@RaiseError,0) = 0
						ROLLBACK TRANSACTION
					SET @ErrorMessage = @AddDetailError;
					IF ISNULL(@RaiseError,0) = 1
						RAISERROR(@ErrorMessage, 16, 1);
					RETURN 0;
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
	END
ELSE IF ISNULL(@ItemId, 0) > 0 AND ISNULL(@ItemCommentTypeId, 0) = 0
	BEGIN
		BEGIN TRY
			INSERT INTO tblARInvoiceDetail
				([intInvoiceId]
				,[intItemId]
				,[intPrepayTypeId]
				,[dblPrepayRate]
				,[strItemDescription]
				,[strDocumentNumber]
				,[intOrderUOMId]
				,[intItemUOMId]
				,[intContractHeaderId]
				,[intContractDetailId]
				,[dblQtyOrdered]
				,[dblQtyShipped]
				,[dblDiscount]
				,[dblItemTermDiscount]
				,[strItemTermDiscountBy]
				,[dblLicenseAmount]
				,[dblPrice]
				,[strPricing]
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
				,[intDestinationWeightId])
			SELECT TOP 1
				 @InvoiceId
				,intItemId
				,@ItemPrepayTypeId
				,@ItemPrepayRate 
				,@ItemDescription
				,@ItemDocumentNumber
				,@OrderUOMId
				,ISNULL(ISNULL(@ItemUOMId, (SELECT TOP 1 [intIssueUOMId] FROM tblICItemLocation WITH (NOLOCK) WHERE [intItemId] = @ItemId AND [intLocationId] = @CompanyLocationId ORDER BY [intItemLocationId] )), (SELECT TOP 1 [intItemUOMId] FROM tblICItemUOM WHERE [intItemId] = @ItemId ORDER BY [ysnStockUnit] DESC, [intItemUOMId]))
				,@ItemContractHeaderId
				,@ItemContractDetailId
				,@ItemQtyOrdered
				,@ItemQtyShipped
				,@ItemDiscount
				,@ItemTermDiscount
				,@ItemTermDiscountBy
				,@ItemLicenseAmount
				,@ItemPrice
				,@ItemPricing
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
				,ISNULL(@ItemSubCurrencyId, @CurrencyId)
				,CASE WHEN ISNULL(@ItemSubCurrencyId, 0) = 0 THEN 1 ELSE ISNULL(@ItemSubCurrencyRate, 1) END
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
			FROM tblICItem WITH (NOLOCK)
			WHERE intItemId = @ItemId

			SET @NewDetailId = SCOPE_IDENTITY()

			BEGIN TRY
				IF @RecomputeTax = 1
					EXEC dbo.[uspARReComputeInvoiceTaxes] @InvoiceId = @InvoiceId  
			END TRY
			BEGIN CATCH
				IF ISNULL(@RaiseError,0) = 0	
					ROLLBACK TRANSACTION
				SET @ErrorMessage = ERROR_MESSAGE();
				IF ISNULL(@RaiseError,0) = 1
					RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
			END CATCH
		END TRY
		BEGIN CATCH			
			IF ISNULL(@RaiseError,0) = 0
				ROLLBACK TRANSACTION
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
			,@RecomputeTax					= @RecomputeTax
			,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId
			,@ItemTaxGroupId				= @ItemTaxGroupId
			,@EntitySalespersonId			= @EntitySalespersonId
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
			,@ItemStorageScheduleTypeId		= @ItemStorageScheduleTypeId

			IF LEN(ISNULL(@AddDetailError,'')) > 0
				BEGIN
					IF ISNULL(@RaiseError,0) = 0
						ROLLBACK TRANSACTION
					SET @ErrorMessage = @AddDetailError;
					IF ISNULL(@RaiseError,0) = 1
						RAISERROR(@ErrorMessage, 16, 1);
					RETURN 0;
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
	END
	
		
SET @NewInvoiceDetailId = @NewDetailId

UPDATE tblARInvoiceDetail SET intStorageScheduleTypeId = ABC.intStorageScheduleTypeId, intCompanyLocationSubLocationId = ABC.intSubLocationId, intStorageLocationId = ABC.intStorageLocationId
FROM 
(SELECT intInvoiceId FROM tblARInvoiceDetail) ARID
INNER JOIN
(
SELECT intInvoiceId, intStorageScheduleTypeId, intStorageLocationId, intSubLocationId FROM tblICInventoryShipment ICIS WITH (NOLOCK)
INNER JOIN (SELECT intInventoryShipmentId, intItemId, intItemUOMId, intOrderId, intStorageLocationId, intSubLocationId FROM tblICInventoryShipmentItem WITH (NOLOCK)) ICISI ON ICIS.intInventoryShipmentId = ICISI.intInventoryShipmentId
INNER JOIN (SELECT SO.intSalesOrderId, SO.strSalesOrderNumber, intStorageScheduleTypeId, intItemId, intItemUOMId FROM tblSOSalesOrder SO  WITH (NOLOCK)
			INNER JOIN (SELECT intSalesOrderId, intStorageScheduleTypeId, intItemId, intItemUOMId  FROM tblSOSalesOrderDetail WITH (NOLOCK)) SOD ON SO.intSalesOrderId = SOD.intSalesOrderId) SO ON ICIS.strReferenceNumber = SO.strSalesOrderNumber AND ICISI.intItemId = SO.intItemId AND ICISI.intItemUOMId = SO.intItemUOMId
INNER JOIN (SELECT ARI.intInvoiceId, ARID.strDocumentNumber, strInvoiceNumber, intItemId, intItemUOMId FROM tblARInvoice ARI   WITH (NOLOCK)
			INNER JOIN (SELECT intInvoiceId, strDocumentNumber, intItemId, intItemUOMId FROM tblARInvoiceDetail WITH (NOLOCK)) ARID ON ARI.intInvoiceId = ARID.intInvoiceId 
						WHERE strDocumentNumber IS NOT NULL AND ISNULL(strDocumentNumber,'') <> '' AND ARI.intInvoiceId = @InvoiceId ) ARI ON ICIS.strShipmentNumber = ARI.strDocumentNumber AND ICISI.intItemId = ARI.intItemId AND ICISI.intItemUOMId = ARI.intItemUOMId
) ABC ON ARID.intInvoiceId = ABC.intInvoiceId
WHERE ARID.intInvoiceId = @InvoiceId

IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION
SET @ErrorMessage = NULL;
RETURN 1;
	
	
END