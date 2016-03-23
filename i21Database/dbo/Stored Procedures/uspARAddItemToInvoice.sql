﻿CREATE PROCEDURE [dbo].[uspARAddItemToInvoice]
	 @InvoiceId						INT	
	,@ItemId						INT				= NULL
	,@ItemIsInventory				BIT				= 0
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
	,@RecomputeTax					BIT				= 1
	,@ItemSCInvoiceId				INT				= NULL
	,@ItemSCInvoiceNumber			NVARCHAR(50)	= NULL
	,@ItemInventoryShipmentItemId	INT				= NULL
	,@ItemShipmentNumber			NVARCHAR(50)	= NULL
	,@ItemSalesOrderDetailId		INT				= NULL												
	,@ItemSalesOrderNumber			NVARCHAR(50)	= NULL
	,@ItemContractHeaderId			INT				= NULL
	,@ItemContractDetailId			INT				= NULL			
	,@ItemShipmentId				INT				= NULL			
	,@ItemShipmentPurchaseSalesContractId	INT		= NULL	
	,@ItemShipmentUOMId				INT				= NULL	
	,@ItemShipmentQtyShipped		NUMERIC(18,6)	= 0.000000		
	,@ItemShipmentGrossWt			NUMERIC(18,6)	= 0.000000		
	,@ItemShipmentTareWt			NUMERIC(18,6)	= 0.000000		
	,@ItemShipmentNetWt				NUMERIC(18,6)	= 0.000000			
	,@ItemTicketId					INT				= NULL		
	,@ItemTicketHoursWorkedId		INT				= NULL		
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
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
	
DECLARE  @ZeroDecimal NUMERIC(18, 6)
		,@NewDetailId INT
		,@AddDetailError NVARCHAR(MAX)		

SET @ZeroDecimal = 0.000000

IF ISNULL(@RaiseError,0) = 0
	BEGIN TRANSACTION

IF (ISNULL(@ItemIsInventory,0) = 1)
	BEGIN
		BEGIN TRY
		EXEC [dbo].[uspARAddInventoryItemToInvoice]
			 @InvoiceId						= @InvoiceId	
			,@ItemId						= @ItemId
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
			,@ItemPrice						= @ItemPrice
			,@ItemPricing					= @ItemPricing
			,@RefreshPrice					= @RefreshPrice
			,@ItemMaintenanceType			= @ItemMaintenanceType
			,@ItemFrequency					= @ItemFrequency
			,@ItemMaintenanceDate			= @ItemMaintenanceDate
			,@ItemMaintenanceAmount			= @ItemMaintenanceAmount
			,@ItemLicenseAmount				= @ItemLicenseAmount
			,@ItemTaxGroupId				= @ItemTaxGroupId
			,@RecomputeTax					= @RecomputeTax
			,@ItemSCInvoiceId				= @ItemSCInvoiceId
			,@ItemSCInvoiceNumber			= @ItemSCInvoiceNumber
			,@ItemInventoryShipmentItemId	= @ItemInventoryShipmentItemId
			,@ItemShipmentNumber			= @ItemShipmentNumber
			,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId
			,@ItemSalesOrderNumber			= @ItemSalesOrderNumber
			,@ItemContractHeaderId			= @ItemContractHeaderId
			,@ItemContractDetailId			= @ItemContractDetailId
			,@ItemShipmentId				= @ItemShipmentId
			,@ItemShipmentPurchaseSalesContractId	= @ItemShipmentPurchaseSalesContractId
			,@ItemShipmentUOMId				= @ItemShipmentUOMId
			,@ItemShipmentQtyShipped		= @ItemShipmentQtyShipped
			,@ItemShipmentGrossWt			= @ItemShipmentGrossWt
			,@ItemShipmentTareWt			= @ItemShipmentTareWt
			,@ItemShipmentNetWt				= @ItemShipmentNetWt
			,@ItemTicketId					= @ItemTicketId
			,@ItemTicketHoursWorkedId		= @ItemTicketHoursWorkedId
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
			,@SubCurrency					= @SubCurrency

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
ELSE IF ISNULL(@ItemId, 0) > 0
	BEGIN
		BEGIN TRY
			INSERT INTO tblARInvoiceDetail
				([intInvoiceId]
				,[intItemId]
				,[strItemDescription]
				,[strDocumentNumber]
				,[intOrderUOMId]
				,[intItemUOMId]
				,[intContractHeaderId]
				,[intContractDetailId]
				,[dblQtyOrdered]
				,[dblQtyShipped]
				,[dblDiscount]
				,[dblPrice]
				,[intSiteId]
				,[strBillingBy]
				,[dblNewMeterReading]
				,[dblPercentFull]
				,[intPerformerId]
				,[intTaxGroupId]
				,[intEntitySalespersonId]
				,[intSalesOrderDetailId]
				,[strSalesOrderNumber]
				,[ysnSubCurrency])
			SELECT TOP 1
				 @InvoiceId
				,intItemId
				,@ItemDescription
				,@ItemDocumentNumber
				,@OrderUOMId
				,@ItemUOMId
				,@ItemContractHeaderId
				,@ItemContractDetailId
				,@ItemQtyOrdered
				,@ItemQtyShipped
				,@ItemDiscount
				,@ItemPrice	
				,@ItemSiteId
				,@ItemBillingBy
				,@ItemNewMeterReading
				,@ItemPercentFull
				,@ItemPerformerId							
				,@ItemTaxGroupId
				,@EntitySalespersonId					
				,@ItemSalesOrderDetailId
				,@ItemSalesOrderNumber
				,@SubCurrency
			FROM tblICItem WHERE intItemId = @ItemId

			SET @NewDetailId = SCOPE_IDENTITY()

			BEGIN TRY
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
ELSE IF(LEN(RTRIM(LTRIM(@ItemDescription))) > 0 OR ISNULL(@ItemPrice,@ZeroDecimal) <> 0 )
	BEGIN
		BEGIN TRY
		EXEC [dbo].[uspARAddMiscItemToInvoice]
			 @InvoiceId						= @InvoiceId
			,@NewInvoiceDetailId			= @NewDetailId		OUTPUT 
			,@ErrorMessage					= @AddDetailError	OUTPUT
			,@RaiseError					= @RaiseError
			,@ItemDescription				= @ItemDescription
			,@ItemDocumentNumber			= @ItemDocumentNumber
			,@ItemQtyOrdered				= @ItemQtyOrdered
			,@ItemQtyShipped				= @ItemQtyShipped
			,@ItemDiscount					= @ItemDiscount
			,@ItemPrice						= @ItemPrice
			,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId
			,@ItemTaxGroupId				= @ItemTaxGroupId
			,@EntitySalespersonId			= @EntitySalespersonId
			,@SubCurrency					= @SubCurrency

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

IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION
SET @ErrorMessage = NULL;
RETURN 1;
	
	
END