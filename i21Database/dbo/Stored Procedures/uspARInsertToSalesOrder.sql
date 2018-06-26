﻿CREATE PROCEDURE [dbo].[uspARInsertToSalesOrder]
	@SalesOrderId    INT = 0,
	@UserId		     INT = 0,
	@NewSalesOrderId INT = NULL OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
BEGIN TRY
	BEGIN TRANSACTION
		DECLARE @strErrorMessage	NVARCHAR(MAX)
		DECLARE @NewTransactionId	INT,
				@DateOnly			DATETIME,
				@Type				NVARCHAR(25) = 'Standard',
				@ZeroDecimal		NUMERIC(18, 6) = 0.000000

			SELECT @DateOnly = CAST(GETDATE() AS DATE)

			IF EXISTS (SELECT NULL FROM tblSOSalesOrderDetail SOD INNER JOIN tblICItem ICI ON SOD.intItemId = ICI.intItemId 
						WHERE intSalesOrderId = @SalesOrderId AND ICI.strType = 'Software')
				BEGIN
					SET @Type = 'Software'
				END
			--HEADER
			INSERT INTO tblSOSalesOrder
				([strSalesOrderOriginId]
				,[intEntityCustomerId]
				,[dtmDate]
				,[dtmDueDate]
				,[intCurrencyId]
				,[intCompanyLocationId]
				,[intEntitySalespersonId]
				,[intEntityContactId]
				,[intShipViaId]
				,[strPONumber]
				,[intTermId]
				,[dblSalesOrderSubtotal]
				,[dblShipping]
				,[dblTax]
				,[dblSalesOrderTotal]
				,[dblDiscount]
				,[dblAmountDue]
				,[dblPayment]
				,[strTransactionType]
				,[strType]
				,[strOrderStatus]
				,[intAccountId]
				,[dtmProcessDate]
				,[ysnProcessed]
				,[strComments]
				,[intShipToLocationId]
				,[strShipToLocationName]
				,[strShipToAddress]
				,[strShipToCity]
				,[strShipToState]
				,[strShipToZipCode]
				,[strShipToCountry]
				,[intBillToLocationId]
				,[strBillToLocationName]
				,[strBillToAddress]
				,[strBillToCity]
				,[strBillToState]
				,[strBillToZipCode]
				,[strBillToCountry]
				,[intConcurrencyId]
				,[intEntityId]
				,[intOrderedById]
				,[strBOLNumber]
				,[intSplitId]
				,[dblTotalWeight])
			SELECT 
				[strSalesOrderNumber]
				,[intEntityCustomerId]
				,@DateOnly
				,[dtmDueDate]
				,[intCurrencyId]
				,[intCompanyLocationId]
				,[intEntitySalespersonId]
				,[intEntityContactId]
				,[intShipViaId]
				,[strPONumber]
				,[intTermId]
				,[dblSalesOrderSubtotal]
				,[dblShipping]
				,[dblTax]
				,[dblSalesOrderTotal]
				,[dblDiscount]
				,[dblAmountDue]
				,[dblPayment]
				,'Order'
				,@Type
				,'Open'
				,[intAccountId]
				,[dtmProcessDate]
				,0
				,[strComments]
				,[intShipToLocationId]
				,[strShipToLocationName]
				,[strShipToAddress]
				,[strShipToCity]
				,[strShipToState]
				,[strShipToZipCode]
				,[strShipToCountry]
				,[intBillToLocationId]
				,[strBillToLocationName]
				,[strBillToAddress]
				,[strBillToCity]
				,[strBillToState]
				,[strBillToZipCode]
				,[strBillToCountry]
				,0
				,@UserId
				,[intOrderedById]
				,[strBOLNumber]
				,[intSplitId]
				,[dblTotalWeight]
			FROM tblSOSalesOrder
			WHERE intSalesOrderId = @SalesOrderId

			SET @NewTransactionId = SCOPE_IDENTITY()

			--DETAILS
			DECLARE @OrderDetails TABLE(intSalesOrderDetailId	INT, 
										dblDiscount				NUMERIC(18,6), 
										dblDiscountAmount		NUMERIC(18,6),
										dblPrice				NUMERIC(18,6),
										dblQtyOrdered			NUMERIC(18,6),
										strVFDDocumentNumber	NVARCHAR(100))
				
			INSERT INTO @OrderDetails
				([intSalesOrderDetailId]
				,[dblDiscount]
				,[dblDiscountAmount]
				,[dblPrice]
				,[dblQtyOrdered]
				,[strVFDDocumentNumber])
			SELECT 	
				[intSalesOrderDetailId]
				,ISNULL([dblDiscount], @ZeroDecimal)
				,ISNULL([dblItemTermDiscount], @ZeroDecimal)
				,ISNULL([dblPrice], @ZeroDecimal)
				,ISNULL([dblQtyOrdered], @ZeroDecimal)
				,[strVFDDocumentNumber]
			FROM
				tblSOSalesOrderDetail
			WHERE
				[intSalesOrderId] = @SalesOrderId
			ORDER BY
				[intSalesOrderDetailId]

			WHILE EXISTS(SELECT TOP 1 NULL FROM @OrderDetails)
			BEGIN
				DECLARE @SalesOrderDetailId		INT,
						@NewSalesOrderDetailId	INT,				
						@QtyOrdered				NUMERIC(18,6),
						@Price					NUMERIC(18,6)

				SELECT TOP 1 @SalesOrderDetailId = [intSalesOrderDetailId]
				FROM @OrderDetails ORDER BY [intSalesOrderDetailId]
				
				INSERT INTO tblSOSalesOrderDetail
					([intSalesOrderId]
					,[intItemId]
					,[strItemDescription]
					,[intItemUOMId]
					,[dblQtyOrdered]
					,[dblQtyAllocated]
					,[dblQtyShipped]
					,[dblDiscount]
					,[dblItemTermDiscount]
					,[intTaxId]
					,[dblPrice]
					,[dblBasePrice]
					,[dblTotalTax]
					,[dblBaseTotalTax]
					,[dblTotal]
					,[dblBaseTotal]
					,[strComments]
					,[intAccountId]
					,[intCOGSAccountId]
					,[intSalesAccountId]
					,[intInventoryAccountId]
					,[intStorageLocationId]
					,[intConcurrencyId]
					,[strMaintenanceType]
					,[strFrequency]
					,[dtmMaintenanceDate]
					,[dblMaintenanceAmount]
					,[dblBaseMaintenanceAmount]
					,[dblLicenseAmount]
					,[dblBaseLicenseAmount]
					,[intContractHeaderId]
					,[intTaxGroupId]
					,[intContractDetailId]
					,[intItemWeightUOMId]
					,[dblItemWeight]
					,[dblOriginalItemWeight]
					,[intSubCurrencyId]
					,[dblSubCurrencyRate]
					,[strVFDDocumentNumber]
					,[intCurrencyExchangeRateTypeId]
					,[dblCurrencyExchangeRate])
				SELECT 
					@NewTransactionId
					,[intItemId]
					,[strItemDescription]
					,[intItemUOMId]
					,[dblQtyOrdered]
					,[dblQtyAllocated]
					,[dblQtyShipped]
					,[dblDiscount]
					,[dblItemTermDiscount]
					,[intTaxId]
					,[dblPrice]
					,[dblBasePrice]
					,[dblTotalTax]
					,[dblBaseTotalTax]
					,[dblTotal]
					,[dblBaseTotal]
					,[strComments]
					,[intAccountId]
					,[intCOGSAccountId]
					,[intSalesAccountId]
					,[intInventoryAccountId]
					,[intStorageLocationId]
					,0
					,[strMaintenanceType]
					,[strFrequency]
					,[dtmMaintenanceDate]
					,[dblMaintenanceAmount]
					,[dblBaseMaintenanceAmount]
					,[dblLicenseAmount]
					,[dblBaseLicenseAmount]
					,NULL
					,[intTaxGroupId]
					,NULL
					,[intItemWeightUOMId]
					,[dblItemWeight]
					,[dblOriginalItemWeight]
					,[intSubCurrencyId]
					,[dblSubCurrencyRate]
					,[strVFDDocumentNumber]
					,[intCurrencyExchangeRateTypeId]
					,[dblCurrencyExchangeRate]
				FROM tblSOSalesOrderDetail		
				WHERE [intSalesOrderDetailId] = @SalesOrderDetailId

				SET @NewSalesOrderDetailId = SCOPE_IDENTITY()

				--TAX DETAIL
				INSERT INTO tblSOSalesOrderDetailTax
					([intSalesOrderDetailId]
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
					,[dblExemptionPercent]
					,[ysnTaxExempt]
					,[ysnTaxOnly]
					,[ysnTaxAdjusted]
					,[ysnSeparateOnInvoice]
					,[ysnCheckoffTax]
					,[strNotes] 
					,[intConcurrencyId])
				SELECT
					@NewSalesOrderDetailId
					,[intTaxGroupId]
					,[intTaxCodeId]
					,[intTaxClassId]
					,[strTaxableByOtherTaxes]
					,[strCalculationMethod]
					,[dblRate]
					,ISNULL([dblBaseRate], [dblRate])
					,[intSalesTaxAccountId]
					,[dblTax]
					,[dblAdjustedTax]
					,[dblBaseAdjustedTax]
					,[dblExemptionPercent]
					,[ysnTaxExempt]
					,[ysnTaxOnly]
					,[ysnTaxAdjusted]
					,[ysnSeparateOnInvoice]
					,[ysnCheckoffTax]
					,[strNotes] 
					,1
				FROM tblSOSalesOrderDetailTax
				WHERE intSalesOrderDetailId = @SalesOrderDetailId
					
				DELETE FROM @OrderDetails WHERE [intSalesOrderDetailId] = @SalesOrderDetailId
			END

			UPDATE tblSOSalesOrder SET ysnProcessed = 1, strOrderStatus = 'Won' WHERE intSalesOrderId = @SalesOrderId

			SET @NewSalesOrderId = @NewTransactionId

			EXEC dbo.[uspSOUpdateOrderIntegrations] @NewSalesOrderId, 0, 0, @UserId
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION      

		SET @strErrorMessage = ERROR_MESSAGE()
		RAISERROR(@strErrorMessage, 11, 1)
		RETURN
END CATCH
END