﻿CREATE PROCEDURE [dbo].[uspARApplyScaleTicketWeight]
	  @intSalesOrderId	INT
	, @intTicketId		INT
	, @intScaleUOMId    INT = NULL
	, @intUserId		INT = NULL	
	, @dblNetWeight		NUMERIC(18, 6) = 0
	, @intNewInvoiceId	INT = NULL OUTPUT
AS
BEGIN
	DECLARE @intScaleItem			INT = NULL
		  , @intStockUOMId			INT = NULL
		  , @intItemUOMId			INT = NULL
		  , @intSalesOrderDetailId	INT = NULL
		  , @dblTotalTreatment		NUMERIC(18, 6) = 0

	SELECT TOP 1 @intScaleItem			= SOD.intItemId
			   , @intStockUOMId			= I.intUnitMeasureId
			   , @intItemUOMId			= SOD.intItemUOMId
			   , @intSalesOrderDetailId = SOD.intSalesOrderDetailId
	FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
	INNER JOIN (
		SELECT I.intItemId
			 , IUOM.intUnitMeasureId
		FROM dbo.tblICItem I WITH (NOLOCK)
		INNER JOIN (
			SELECT intItemId
				 , intUnitMeasureId
			FROM dbo.tblICItemUOM WITH (NOLOCK)
			WHERE ysnStockUnit = 1
		) IUOM ON I.intItemId = IUOM.intItemId
		WHERE I.ysnUseWeighScales = 1
	) I ON SOD.intItemId = I.intItemId
	WHERE intSalesOrderId = @intSalesOrderId

	IF ISNULL(@intSalesOrderId, 0) = 0
		BEGIN
			RAISERROR('Sales Order ID is required.', 16, 1)
			RETURN;
		END

	IF ISNULL(@intTicketId, 0) = 0
		BEGIN
			RAISERROR('Scale Ticket ID is required.', 16, 1)
			RETURN;
		END

	IF ISNULL(@dblNetWeight, 0) = 0
		BEGIN
			RAISERROR('Net Weight should not be zero.', 16, 1)
			RETURN;
		END

	IF NOT EXISTS (SELECT NULL FROM tblSOSalesOrder WHERE intSalesOrderId = @intSalesOrderId)
		BEGIN
			RAISERROR('Sales Order is not existing.', 16, 1)
			RETURN;
		END

	IF ISNULL(@intScaleItem, 0) = 0
		BEGIN
			RAISERROR('Sales Order doesn''t have scale item.', 16, 1)
			RETURN;
		END

	SELECT @dblTotalTreatment = ISNULL(dbo.fnCalculateQtyBetweenUOM(@intScaleUOMId, SOD.intItemUOMId, SUM(dblQtyOrdered)), 0)
	FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
	INNER JOIN (
		SELECT intItemId
		FROM dbo.tblICItem WITH (NOLOCK)
		WHERE ysnUseWeighScales = 0
	) ITEM ON SOD.intItemId = ITEM.intItemId
	WHERE SOD.intSalesOrderId = @intSalesOrderId
	GROUP BY SOD.intItemUOMId

	EXEC dbo.uspSOProcessToInvoice @SalesOrderId = @intSalesOrderId
								 , @UserId = @intUserId
								 , @NewInvoiceId = @intNewInvoiceId OUT

	IF ISNULL(@intNewInvoiceId, 0) = 0
		BEGIN
			RAISERROR('Failed to Create Invoice.', 16, 1)
			RETURN;
		END	
	ELSE
		BEGIN
			DECLARE @ItemUOMId AS INT, @QtyShipped AS NUMERIC(18, 6), @ContractDetailId AS INT, @ItemPrice NUMERIC(18,6)	= 0.000000	

			SELECT TOP 1
				 @ItemUOMId			= intItemUOMId
				,@QtyShipped		= dblQtyShipped
				,@ContractDetailId	= intContractDetailId 
				,@ItemPrice			= dblPrice
			FROM
				tblARInvoiceDetail
			WHERE
				intSalesOrderDetailId = @intSalesOrderDetailId
				AND intInvoiceId = @intNewInvoiceId
				

			IF ISNULL(@ContractDetailId, 0) <> 0 AND (@dblNetWeight - @dblTotalTreatment) > ISNULL(dbo.fnCalculateQtyBetweenUOM(@ItemUOMId, @intScaleUOMId, @QtyShipped), 0)
				BEGIN
					UPDATE tblARInvoiceDetail
					SET dblQtyShipped = ISNULL(dbo.fnCalculateQtyBetweenUOM(@ItemUOMId, @intScaleUOMId, dblQtyShipped), 0)
						, intItemUOMId = @intScaleUOMId
						, intTicketId = @intTicketId
					WHERE intSalesOrderDetailId = @intSalesOrderDetailId
						AND intInvoiceId = @intNewInvoiceId

					DECLARE @ItemId						INT
						,@ItemPrepayTypeId				INT
						,@ItemPrepayRate				NUMERIC(18,6)
						,@ItemIsBlended					BIT				= 0
						,@ErrorMessage					NVARCHAR(250)
						,@RaiseError					BIT				= 0		
						,@ItemDocumentNumber			NVARCHAR(100)	= NULL			
						,@ItemDescription				NVARCHAR(500)	= NULL
						,@ItemQtyShipped				NUMERIC(18,6)	= 0.000000
						,@ItemOrderUOMId				INT				= NULL
						,@ItemPriceUOMId				INT				= NULL
						,@ItemQtyOrdered				NUMERIC(18,6)	= 0.000000
						,@ItemUnitQuantity				NUMERIC(18,6)	= 1.000000
						,@ItemDiscount					NUMERIC(18,6)	= 0.000000
						,@ItemTermDiscount				NUMERIC(18,6)	= 0.000000
						,@ItemTermDiscountBy			NVARCHAR(50)	= NULL
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
						,@ItemCompanyLocationSubLocationId	INT			= NULL
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
						,@ItemCurrencyExchangeRateTypeId	INT			= NULL
						,@ItemCurrencyExchangeRateId	INT				= NULL
						,@ItemCurrencyExchangeRate		NUMERIC(18,8)	= 1.000000
						,@ItemSubCurrencyId				INT				= NULL
						,@ItemSubCurrencyRate			NUMERIC(18,8)	= 1.000000
						,@ItemStorageScheduleTypeId		INT				= NULL
						,@ItemDestinationGradeId		INT				= NULL
						,@ItemDestinationWeightId		INT				= NULL

					SELECT TOP 1
						 @ItemId						= intItemId
						,@ItemPrepayTypeId				= intPrepayTypeId
						,@ItemPrepayRate				= dblPrepayRate
						,@ItemIsBlended					= ysnBlended
						,@ItemDocumentNumber			= strDocumentNumber
						,@ItemDescription				= strItemDescription
						,@ItemQtyShipped				= (@dblNetWeight - @dblTotalTreatment) - ISNULL(dbo.fnCalculateQtyBetweenUOM(@ItemUOMId, @intScaleUOMId, @QtyShipped), 0)
						,@ItemOrderUOMId				= NULL
						,@ItemPriceUOMId				= intPriceUOMId
						,@ItemQtyOrdered				= 0.00000000
						,@ItemUnitQuantity				= dblUnitQuantity
						,@ItemDiscount					= dblDiscount
						,@ItemTermDiscount				= dblItemTermDiscount
						,@ItemTermDiscountBy			= strItemTermDiscountBy
						,@ItemUnitPrice					= dblUnitPrice
						,@ItemPricing					= strPricing
						,@ItemVFDDocumentNumber			= strVFDDocumentNumber
						,@ItemMaintenanceType			= strMaintenanceType
						,@ItemFrequency					= strFrequency
						,@ItemMaintenanceDate			= dtmMaintenanceDate
						,@ItemMaintenanceAmount			= dblMaintenanceAmount
						,@ItemLicenseAmount				= dblLicenseAmount
						,@ItemTaxGroupId				= intTaxGroupId
						,@ItemStorageLocationId			= intStorageLocationId
						,@ItemCompanyLocationSubLocationId	= intCompanyLocationSubLocationId
						,@ItemSCInvoiceId				= intSCInvoiceId
						,@ItemSCInvoiceNumber			= strSCInvoiceNumber
						,@ItemInventoryShipmentItemId	= NULL
						,@ItemInventoryShipmentChargeId	= NULL
						,@ItemShipmentNumber			= strShipmentNumber
						,@ItemRecipeItemId				= intRecipeItemId
						,@ItemRecipeId					= intRecipeId
						,@ItemCostTypeId				= intCostTypeId
						,@ItemMarginById				= intMarginById
						,@ItemCommentTypeId				= intCommentTypeId
						,@ItemMargin					= dblMargin
						,@ItemSalesOrderDetailId		= NULL
						,@ItemSalesOrderNumber			= ''
						,@ItemContractHeaderId			= NULL
						,@ItemContractDetailId			= NULL
						,@ItemShipmentId				= NULL
						,@ItemShipmentPurchaseSalesContractId	= NULL
						,@ItemWeight					= 1
						,@ItemShipmentGrossWt			= 0.000000
						,@ItemShipmentTareWt			= 0.000000
						,@ItemShipmentNetWt				= 0.000000		
						,@ItemTicketId					= @intTicketId
						,@ItemTicketHoursWorkedId		= NULL
						,@ItemCustomerStorageId			= intCustomerStorageId
						,@ItemSiteDetailId				= intSiteDetailId
						,@ItemLoadDetailId				= NULL
						,@ItemLotId						= NULL
						,@ItemOriginalInvoiceDetailId	= NULL
						,@ItemConversionAccountId		= NULL
						,@ItemSalesAccountId			= NULL
						,@ItemSiteId					= NULL
						,@ItemBillingBy					= ''
						,@ItemPercentFull				= 0.000000
						,@ItemNewMeterReading			= 0.000000
						,@ItemPreviousMeterReading		= 0.000000
						,@ItemConversionFactor			= 0.00000000
						,@ItemPerformerId				= NULL
						,@ItemLeaseBilling				= 0
						,@ItemVirtualMeterReading		= 0
						,@EntitySalespersonId			= NULL
						,@ItemCurrencyExchangeRateTypeId	= intCurrencyExchangeRateTypeId
						,@ItemCurrencyExchangeRateId	= intCurrencyExchangeRateId
						,@ItemCurrencyExchangeRate		= dblCurrencyExchangeRate
						,@ItemSubCurrencyId				= intSubCurrencyId
						,@ItemSubCurrencyRate			= dblSubCurrencyRate
						,@ItemStorageScheduleTypeId		= intStorageScheduleTypeId
						,@ItemDestinationGradeId		= intDestinationGradeId
						,@ItemDestinationWeightId		= intDestinationWeightId
					FROM
						tblARInvoiceDetail
					WHERE
						intSalesOrderDetailId = @intSalesOrderDetailId
						AND intInvoiceId = @intNewInvoiceId


					EXEC [uspARAddItemToInvoice]
						 @InvoiceId						= @intNewInvoiceId
						,@ItemId						= @ItemId
						,@ItemPrepayTypeId				= @ItemPrepayTypeId
						,@ItemPrepayRate				= @ItemPrepayRate
						,@ItemIsBlended					= @ItemIsBlended
						,@RaiseError					= 1		
						,@ItemDocumentNumber			= @ItemDocumentNumber
						,@ItemDescription				= @ItemDescription
						,@ItemOrderUOMId				= @ItemOrderUOMId
						,@ItemPriceUOMId				= @ItemPriceUOMId
						,@ItemQtyOrdered				= @ItemQtyOrdered
						,@ItemUOMId						= @intScaleUOMId
						,@ItemQtyShipped				= @ItemQtyShipped
						,@ItemUnitQuantity				= @ItemUnitQuantity
						,@ItemDiscount					= @ItemDiscount
						,@ItemTermDiscount				= @ItemTermDiscount
						,@ItemTermDiscountBy			= @ItemTermDiscountBy
						,@ItemPrice						= @ItemPrice
						,@ItemUnitPrice					= @ItemUnitPrice
						,@ItemPricing					= @ItemPricing
						,@ItemVFDDocumentNumber			= @ItemVFDDocumentNumber
						,@RefreshPrice					= 0
						,@ItemMaintenanceType			= @ItemMaintenanceType
						,@ItemFrequency					= @ItemFrequency
						,@ItemMaintenanceDate			= @ItemMaintenanceDate
						,@ItemMaintenanceAmount			= @ItemMaintenanceAmount
						,@ItemLicenseAmount				= @ItemLicenseAmount
						,@ItemTaxGroupId				= @ItemTaxGroupId
						,@ItemStorageLocationId			= @ItemStorageLocationId
						,@ItemCompanyLocationSubLocationId	= @ItemCompanyLocationSubLocationId
						,@RecomputeTax					= 1
						,@ItemSCInvoiceId				= @ItemSCInvoiceId
						,@ItemSCInvoiceNumber			= @ItemSCInvoiceNumber
						,@ItemInventoryShipmentItemId	= @ItemInventoryShipmentItemId
						,@ItemInventoryShipmentChargeId	= @ItemInventoryShipmentChargeId
						,@ItemShipmentNumber			= @ItemShipmentNumber
						,@ItemRecipeItemId				= @ItemRecipeItemId
						,@ItemRecipeId					= @ItemRecipeId
						,@ItemSublocationId				= @ItemSublocationId
						,@ItemCostTypeId				= @ItemCostTypeId
						,@ItemMarginById				= @ItemMarginById
						,@ItemCommentTypeId				= @ItemCommentTypeId
						,@ItemMargin					= @ItemMargin
						,@ItemRecipeQty					= @ItemRecipeQty
						,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId
						,@ItemSalesOrderNumber			= @ItemSalesOrderNumber
						,@ItemContractHeaderId			= @ItemContractHeaderId
						,@ItemContractDetailId			= @ItemContractDetailId
						,@ItemShipmentId				= @ItemShipmentId
						,@ItemShipmentPurchaseSalesContractId = @ItemShipmentPurchaseSalesContractId
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
						,@ItemConversionAccountId		= @ItemConversionAccountId
						,@ItemSalesAccountId			= @ItemSalesAccountId
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
						,@ItemCurrencyExchangeRateTypeId= @ItemCurrencyExchangeRateTypeId
						,@ItemCurrencyExchangeRateId	= @ItemCurrencyExchangeRateId
						,@ItemCurrencyExchangeRate		= @ItemCurrencyExchangeRate
						,@ItemSubCurrencyId				= @ItemSubCurrencyId
						,@ItemSubCurrencyRate			= @ItemSubCurrencyRate
						,@ItemStorageScheduleTypeId		= @ItemStorageScheduleTypeId
						,@ItemDestinationGradeId		= @ItemDestinationGradeId
						,@ItemDestinationWeightId		= @ItemDestinationWeightId
				END
			ELSE
				BEGIN
					UPDATE tblARInvoiceDetail
					SET dblQtyShipped = @dblNetWeight - @dblTotalTreatment
						, intItemUOMId = @intScaleUOMId
						, intTicketId = @intTicketId
					WHERE intSalesOrderDetailId = @intSalesOrderDetailId
						AND intInvoiceId = @intNewInvoiceId
				END
			

			EXEC dbo.uspARUpdateInvoiceIntegrations @InvoiceId = @intNewInvoiceId, @UserId = @intUserId
			EXEC dbo.uspARReComputeInvoiceTaxes @intNewInvoiceId

			UPDATE SO 
			SET SO.strOrderStatus = CASE WHEN SOD.dblQtyShipped >= SOD.dblQtyOrdered THEN 'Closed' ELSE 'Short Closed' END
			FROM tblSOSalesOrder SO
			CROSS APPLY (
				SELECT dblQtyOrdered = SUM(DETAIL.dblQtyOrdered)
					 , dblQtyShipped = SUM(DETAIL.dblQtyShipped)
				FROM tblSOSalesOrderDetail DETAIL
				WHERE DETAIL.intSalesOrderId = SO.intSalesOrderId
				GROUP BY DETAIL.intSalesOrderId
			) SOD
			WHERE SO.intSalesOrderId = @intSalesOrderId
		END
END