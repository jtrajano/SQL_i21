﻿CREATE PROCEDURE [dbo].[uspARInsertToInvoice]
	@SalesOrderId	     INT = 0,
	@UserId			     INT = 0,
	@ShipmentId			 INT = 0,
	@FromShipping		 BIT = 0,
	@NewInvoiceId		 INT = 0 OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

--GLOBAL VARIABLES
DECLARE @DateOnly				DATETIME,
		@SoftwareInvoiceId		INT,
		@dblSalesOrderSubtotal	NUMERIC(18, 6),			
		@dblTax					NUMERIC(18, 6),
		@dblSalesOrderTotal		NUMERIC(18, 6),
		@dblDiscount			NUMERIC(18, 6),
		@dblZeroAmount			NUMERIC(18, 6),
		@RaiseError				BIT,
		@ErrorMessage			NVARCHAR(MAX),
		@CurrentErrorMessage	NVARCHAR(MAX)

--VARIABLES FOR INVOICE HEADER
DECLARE @EntityCustomerId		INT,
		@CompanyLocationId		INT,
		@CurrencyId				INT,
		@TermId					INT,
		@EntityId				INT,
		@Date					DATETIME,
		@DueDate				DATETIME,				
		@EntitySalespersonId	INT,
		@FreightTermId			INT,
		@ShipViaId				INT,
		@PaymentMethodId		INT,
		@InvoiceOriginId		INT,
		@PONumber				NVARCHAR(100),
		@BOLNumber				NVARCHAR(100),
		@DeliverPickup			NVARCHAR(100),
		@InvoiceComment			NVARCHAR(MAX),
		@SoftwareComment		NVARCHAR(MAX),
		@SalesOrderNumber		NVARCHAR(100),
		@ShipToLocationId		INT,
		@BillToLocationId		INT,
		@SplitId				INT

DECLARE @tblItemsToInvoice TABLE (intItemToInvoiceId	INT IDENTITY (1, 1),
							intItemId					INT, 
							ysnIsInventory				BIT,
							strItemDescription			NVARCHAR(100),
							intItemUOMId				INT,
							dblQtyOrdered				NUMERIC(18,6),
							dblQtyRemaining				NUMERIC(18,6),
							dblMaintenanceAmount		NUMERIC(18,6),
							dblDiscount					NUMERIC(18,6),
							dblPrice					NUMERIC(18,6),
							intTaxGroupId				INT,
							intSalesOrderDetailId		INT,
							intInventoryShipmentItemId	INT,
							strItemType					NVARCHAR(100),
							strSalesOrderNumber			NVARCHAR(100),
							strShipmentNumber			NVARCHAR(100))
									
DECLARE @tblSODSoftware TABLE(intSalesOrderDetailId		INT,
							intInventoryShipmentItemId	INT,
							strShipmentNumber			NVARCHAR(50),	 
							dblDiscount					NUMERIC(18,6), 
							dblTotalTax					NUMERIC(18,6), 
							dblPrice					NUMERIC(18,6), 
							dblTotal					NUMERIC(18,6))

SELECT @DateOnly = CAST(GETDATE() AS DATE), @dblZeroAmount = 0.000000

--GET ITEMS FROM SALES ORDER
INSERT INTO @tblItemsToInvoice
SELECT SI.intItemId
	 , dbo.fnIsStockTrackingItem(SI.intItemId)
	 , SI.strItemDescription
	 , SI.intItemUOMId
	 , SI.dblQtyOrdered
	 , SI.dblQtyRemaining
	 , CASE WHEN I.strType = 'Software' THEN SOD.dblMaintenanceAmount ELSE @dblZeroAmount END
	 , SI.dblDiscount
	 , CASE WHEN I.strType = 'Software' THEN SOD.dblLicenseAmount ELSE SI.dblPrice END
	 , SI.intTaxGroupId
	 , SI.intSalesOrderDetailId
	 , NULL
	 , I.strType
	 , SI.strSalesOrderNumber
	 , NULL
FROM tblSOSalesOrder SO 
	INNER JOIN vyuARShippedItems SI ON SO.intSalesOrderId = SI.intSalesOrderId
	LEFT JOIN tblSOSalesOrderDetail SOD ON SI.intSalesOrderDetailId = SOD.intSalesOrderDetailId
	LEFT JOIN tblICItem I ON SI.intItemId = I.intItemId
WHERE ISNULL(I.strLotTracking, 'No') = 'No'
	AND SO.intSalesOrderId = @SalesOrderId
	AND SI.dblQtyRemaining > 0

--GET ITEMS FROM POSTED SHIPMENT
INSERT INTO @tblItemsToInvoice
SELECT ICSI.intItemId
	 , dbo.fnIsStockTrackingItem(ICSI.intItemId)
	 , SOD.strItemDescription
	 , ICSI.intItemUOMId
	 , ICSI.dblQuantity
	 , ICSI.dblQuantity
	 , @dblZeroAmount
	 , SOD.dblDiscount
	 , ICSI.dblUnitPrice
	 , SOD.intTaxGroupId
	 , SOD.intSalesOrderDetailId
	 , ICSI.intInventoryShipmentItemId
	 , ICI.strType
	 , SO.strSalesOrderNumber
	 , ICS.strShipmentNumber
FROM tblICInventoryShipmentItem ICSI 
INNER JOIN tblICInventoryShipment ICS ON ICS.intInventoryShipmentId = ICSI.intInventoryShipmentId
INNER JOIN tblSOSalesOrderDetail SOD ON SOD.intSalesOrderDetailId = ICSI.intLineNo
INNER JOIN tblSOSalesOrder SO ON SOD.intSalesOrderId = SO.intSalesOrderId
LEFT JOIN tblICItem ICI ON ICSI.intItemId = ICI.intItemId
WHERE ICSI.intOrderId = @SalesOrderId
AND ICS.ysnPosted = 1

--GET SOFTWARE ITEMS
IF @FromShipping = 0
	BEGIN --NON STOCK SOFTWARE
		INSERT INTO @tblSODSoftware (intSalesOrderDetailId, dblDiscount, dblTotalTax, dblPrice, dblTotal)
		SELECT intSalesOrderDetailId
				, @dblZeroAmount
				, @dblZeroAmount
				, dblMaintenanceAmount
				, dblMaintenanceAmount * dblQtyRemaining
		FROM @tblItemsToInvoice WHERE strItemType = 'Software'
			ORDER BY intSalesOrderDetailId
	END
	
--COMPUTE INVOICE TOTAL AMOUNTS FOR SOFTWARE
SELECT @dblSalesOrderSubtotal = SUM(dblPrice)
	    , @dblTax				  = SUM(dblTotalTax)
		, @dblSalesOrderTotal	  = SUM(dblTotal)
		, @dblDiscount			  = SUM(dblDiscount)
FROM @tblSODSoftware

--GET EXISTING RECURRING INVOICE RECORD OF CUSTOMER
SELECT TOP 1
		@EntityCustomerId		=	intEntityCustomerId,
		@CompanyLocationId		=	intCompanyLocationId,
		@CurrencyId				=	intCurrencyId,
		@TermId					=	intTermId,
		@EntityId				=	@UserId,
		@Date					=	dtmDate,
		@DueDate				=	dtmDueDate,
		@EntitySalespersonId	=	intEntitySalespersonId,
		@FreightTermId			=	intFreightTermId,
		@ShipViaId				=	intShipViaId,  	   
		@PONumber				=	strPONumber,
		@BOLNumber				=	strBOLNumber,
		@DeliverPickup			=	'',
		@SalesOrderNumber		=	strSalesOrderNumber,
		@ShipToLocationId		=	intShipToLocationId,
		@BillToLocationId		=	intBillToLocationId,
		@SplitId				=	intSplitId
FROM tblSOSalesOrder WHERE intSalesOrderId = @SalesOrderId
	
EXEC dbo.[uspARGetDefaultComment] @CompanyLocationId, @EntityCustomerId, 'Invoice', 'Software', @SoftwareComment OUT
EXEC dbo.[uspARGetDefaultComment] @CompanyLocationId, @EntityCustomerId, 'Invoice', 'Standard', @InvoiceComment OUT

--GET NEW COMMENT FOR NEW INVOICE
SET @InvoiceComment = 'ORIGIN: ' + @SalesOrderNumber + '; ' + @InvoiceComment

--BEGIN TRANSACTION
IF ISNULL(@RaiseError,0) = 0
	BEGIN TRANSACTION

--CHECK IF THERE IS SOFTWARE ITEMS (NON-STOCK / STOCK ITEMS)
IF EXISTS(SELECT NULL FROM @tblSODSoftware)
	BEGIN
		SELECT TOP 1 @SoftwareInvoiceId = intInvoiceId FROM tblARInvoice WHERE intEntityCustomerId = @EntityCustomerId AND ysnTemplate = 1 AND strType = 'Software'
		
		IF ISNULL(@SoftwareInvoiceId, 0) <> 0
			BEGIN
				--UPDATE EXISTING RECURRING INVOICE
				UPDATE tblARInvoice 
				SET dblInvoiceSubtotal	= dblInvoiceSubtotal + @dblSalesOrderSubtotal
				  , dblTax				= dblTax + @dblTax
				  , dblInvoiceTotal		= dblInvoiceTotal + @dblSalesOrderTotal
				  , dblDiscount			= dblDiscount + @dblDiscount
				  , dtmDate				= @DateOnly
				  , ysnTemplate			= 1
				  , strType				= 'Software'
				  , ysnPosted			= 1
				WHERE intInvoiceId = @SoftwareInvoiceId
			END
		ELSE
			BEGIN
				--INSERT TO INVOICE HEADER FOR RECURRING
				INSERT INTO tblARInvoice
					([intEntityCustomerId]
					,[strInvoiceOriginId]
					,[dtmDate]
					,[dtmDueDate]
					,[dtmPostDate]
					,[intCurrencyId]
					,[intCompanyLocationId]
					,[intEntitySalespersonId]
					,[dtmShipDate]
					,[intShipViaId]
					,[strPONumber]
					,[intTermId]
					,[dblInvoiceSubtotal]
					,[dblShipping]
					,[dblTax]
					,[dblInvoiceTotal]
					,[dblDiscount]
					,[dblAmountDue]
					,[dblPayment]
					,[strTransactionType]
					,[strType]
					,[intPaymentMethodId]
					,[intAccountId]
					,[intFreightTermId]
					,[intEntityId]
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
					,[ysnTemplate]
					,[ysnPosted]
				)
				SELECT
					[intEntityCustomerId]
					,[strSalesOrderNumber] --origin Id
					,@DateOnly --Date		
					,[dbo].fnGetDueDateBasedOnTerm(@DateOnly,intTermId) --Due Date
					,@DateOnly --Post Date
					,[intCurrencyId]
					,[intCompanyLocationId]
					,[intEntitySalespersonId]
					,@DateOnly --Ship Date
					,[intShipViaId]
					,[strPONumber]
					,[intTermId]
					,@dblSalesOrderSubtotal --ROUND([dblSalesOrderSubtotal],2)
					,[dblShipping]
					,@dblTax--ROUND([dblTax],2)
					,@dblSalesOrderTotal--ROUND([dblSalesOrderTotal],2)
					,@dblDiscount--ROUND([dblDiscount],2)
					,[dblAmountDue]
					,[dblPayment]
					,'Invoice'
					,'Software'
					,0 --Payment Method
					,[intAccountId]
					,[intFreightTermId]
					,@UserId
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
					,1
					,1
				FROM
				tblSOSalesOrder
				WHERE intSalesOrderId = @SalesOrderId

				SET @SoftwareInvoiceId = SCOPE_IDENTITY()
			END		
	
		--INSERT TO RECURRING INVOICE DETAIL AND INVOICE DETAIL TAX						
		WHILE EXISTS(SELECT TOP 1 NULL FROM @tblSODSoftware)
			BEGIN
				DECLARE @SalesOrderDetailId INT
					   ,@SoftwareInvoiceDetailId INT
					
				SELECT TOP 1 @SalesOrderDetailId = [intSalesOrderDetailId] FROM @tblSODSoftware ORDER BY [intSalesOrderDetailId]
			
				INSERT INTO [tblARInvoiceDetail]
					([intInvoiceId]
					,[intItemId]
					,[strItemDescription]
					,[intItemUOMId]
					,[dblQtyOrdered]
					,[dblQtyShipped]
					,[dblDiscount]
					,[dblPrice]
					,[dblTotalTax]
					,[dblTotal]
					,[intAccountId]
					,[intCOGSAccountId]
					,[intSalesAccountId]
					,[intInventoryAccountId]
					,[intSalesOrderDetailId]
					,[intContractHeaderId]
					,[intContractDetailId]
					,[strMaintenanceType]
					,[strFrequency]
					,[dblMaintenanceAmount]
					,[dblLicenseAmount]
					,[dtmMaintenanceDate]
					,[intTaxGroupId]
					,[intConcurrencyId])
				SELECT 	
					 @SoftwareInvoiceId			--[intInvoiceId]
					,[intItemId]				--[intItemId]
					,[strItemDescription]		--[strItemDescription]
					,[intItemUOMId]				--[intItemUOMId]
					,[dblQtyOrdered]			--[dblQtyOrdered]
					,[dblQtyOrdered]			--[dblQtyShipped]
					,0							--[dblDiscount]
					,[dblMaintenanceAmount]		--[dblPrice]
					,0							--[dblTotalTax]
					,[dblMaintenanceAmount] * [dblQtyOrdered] --[dblTotal]
					,[intAccountId]				--[intAccountId]
					,[intCOGSAccountId]			--[intCOGSAccountId]
					,[intSalesAccountId]		--[intSalesAccountId]
					,[intInventoryAccountId]	--[intInventoryAccountId]
					,[intSalesOrderDetailId]    --[intSalesOrderDetailId]
					,[intContractHeaderId]		--[intContractHeaderId]
					,[intContractDetailId]		--[intContractDetailId]
					,[strMaintenanceType]		--[strMaintenanceType]
					,[strFrequency]		        --[strFrequency]
					,[dblMaintenanceAmount]		--[dblMaintenanceAmount]
					,0							--[dblLicenseAmount]
					,[dtmMaintenanceDate]		--[dtmMaintenanceDate]
					,[intTaxGroupId]			--[intTaxGroupId]
					,0							--[intConcurrencyId]
				FROM
					tblSOSalesOrderDetail
				WHERE
					[intSalesOrderDetailId] = @SalesOrderDetailId
												
				SET @SoftwareInvoiceDetailId = SCOPE_IDENTITY()
				
				DELETE FROM @tblSODSoftware WHERE [intSalesOrderDetailId] = @SalesOrderDetailId
			END
	END

--CHECK IF THERE IS NON STOCK ITEMS
IF EXISTS (SELECT NULL FROM @tblItemsToInvoice)
	BEGIN
		--INSERT INVOICE HEADER
		BEGIN TRY
			EXEC uspARCreateCustomerInvoice
					 @EntityCustomerId				= @EntityCustomerId
					,@CompanyLocationId				= @CompanyLocationId
					,@CurrencyId					= @CurrencyId
					,@TermId						= @TermId
					,@EntityId						= @EntityId
					,@InvoiceDate					= @Date
					,@DueDate						= @DueDate
					,@ShipDate						= @Date
					,@PostDate						= NULL
					,@TransactionType				= 'Invoice'
					,@Type							= 'Standard'
					,@NewInvoiceId					= @NewInvoiceId			OUTPUT 
					,@ErrorMessage					= @CurrentErrorMessage	OUTPUT
					,@RaiseError					= @RaiseError
					,@EntitySalespersonId			= @EntitySalespersonId
					,@FreightTermId					= @FreightTermId
					,@ShipViaId						= @ShipViaId
					,@PaymentMethodId				= @PaymentMethodId
					,@InvoiceOriginId				= @InvoiceOriginId
					,@PONumber						= @PONumber
					,@BOLNumber						= @BOLNumber
					,@DeliverPickUp					= @DeliverPickup
					,@Comment						= @InvoiceComment
					,@ShipToLocationId				= @ShipToLocationId
					,@BillToLocationId				= @BillToLocationId
					,@SplitId						= @SplitId

			IF LEN(ISNULL(@CurrentErrorMessage,'')) > 0 
				BEGIN
					IF ISNULL(@RaiseError,0) = 0
						ROLLBACK TRANSACTION
					SET @ErrorMessage = @CurrentErrorMessage;
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

		--INSERT TO INVOICE DETAIL
		WHILE EXISTS(SELECT NULL FROM @tblItemsToInvoice)
			BEGIN
				DECLARE @intItemToInvoiceId		INT,
						@ItemId					INT,
						@ItemIsInventory		BIT,
						@NewDetailId			INT,
						@ItemDescription		NVARCHAR(100),
						@ItemUOMId				INT,
						@ItemQtyOrdered			NUMERIC(18,6),
						@ItemQtyShipped			NUMERIC(18,6),
						@ItemDiscount			NUMERIC(18,6),
						@ItemPrice				NUMERIC(18,6),
						@ItemTaxGroupId			INT,		
						@ItemSalesOrderDetailId	INT,
						@ItemShipmentDetailId	INT,
						@ItemSalesOrderNumber	NVARCHAR(100),
						@ItemShipmentNumber		NVARCHAR(100)

				SELECT TOP 1
						@intItemToInvoiceId		= intItemToInvoiceId,
						@ItemId					= intItemId,
						@ItemIsInventory		= ysnIsInventory,
						@ItemDescription		= strItemDescription,
						@ItemUOMId				= intItemUOMId,
						@ItemQtyOrdered			= dblQtyOrdered,
						@ItemQtyShipped			= dblQtyRemaining,
						@ItemDiscount			= dblDiscount,
						@ItemPrice				= dblPrice,
						@ItemTaxGroupId			= intTaxGroupId,
						@ItemSalesOrderDetailId	= intSalesOrderDetailId,						
						@ItemShipmentDetailId	= intInventoryShipmentItemId,
						@ItemSalesOrderNumber	= strSalesOrderNumber,
						@ItemShipmentNumber		= strShipmentNumber
				FROM @tblItemsToInvoice ORDER BY intItemToInvoiceId ASC

				EXEC [dbo].[uspARAddItemToInvoice]
							 @InvoiceId						= @NewInvoiceId	
							,@ItemId						= @ItemId
							,@ItemIsInventory				= @ItemIsInventory
							,@NewInvoiceDetailId			= @NewDetailId			OUTPUT 
							,@ErrorMessage					= @CurrentErrorMessage	OUTPUT
							,@RaiseError					= @RaiseError
							,@ItemDescription				= @ItemDescription
							,@ItemUOMId						= @ItemUOMId
							,@ItemQtyOrdered				= @ItemQtyOrdered
							,@ItemQtyShipped				= @ItemQtyShipped
							,@ItemDiscount					= @ItemDiscount
							,@ItemPrice						= @ItemPrice
							,@RefreshPrice					= 0
							,@ItemTaxGroupId				= @ItemTaxGroupId
							,@RecomputeTax					= 0
							,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId							
							,@ItemInventoryShipmentItemId	= @ItemShipmentDetailId
							,@ItemSalesOrderNumber			= @ItemSalesOrderNumber
							,@ItemShipmentNumber			= @ItemShipmentNumber

				IF LEN(ISNULL(@CurrentErrorMessage,'')) > 0
					BEGIN
						IF ISNULL(@RaiseError,0) = 0
							ROLLBACK TRANSACTION
						SET @ErrorMessage = @CurrentErrorMessage;
						IF ISNULL(@RaiseError,0) = 1
							RAISERROR(@ErrorMessage, 16, 1);
						RETURN 0;
					END
				ELSE
					DELETE FROM @tblItemsToInvoice WHERE intItemToInvoiceId = @intItemToInvoiceId				
			END	
	END

--UPDATE OTHER TABLE INTEGRATIONS
IF ISNULL(@RaiseError,0) = 0
	BEGIN
		EXEC dbo.uspARInsertTransactionDetail @NewInvoiceId	
		EXEC dbo.uspARUpdateInvoiceIntegrations @NewInvoiceId, 0, @UserId
		EXEC dbo.uspSOUpdateOrderShipmentStatus @SalesOrderId
		EXEC dbo.uspARReComputeInvoiceTaxes @NewInvoiceId
		
		UPDATE
			tblSOSalesOrder
		SET
			dtmProcessDate = GETDATE()
			, ysnProcessed = 1
		WHERE
			intSalesOrderId = @SalesOrderId
	END

--INSERT TO RECURRING TRANSACTION
IF ISNULL(@SoftwareInvoiceId, 0) > 0
	BEGIN
		IF NOT EXISTS (SELECT NULL FROM tblSMRecurringTransaction WHERE intTransactionId = @SoftwareInvoiceId AND strTransactionType = 'Invoice')
			BEGIN
				EXEC dbo.uspARInsertRecurringInvoice @SoftwareInvoiceId, @UserId
			END

		DECLARE @ysnSOSoftwareType BIT
		SELECT TOP 1 @ysnSOSoftwareType = CASE WHEN strType = 'Software' THEN 1 ELSE 0 END
		FROM tblSOSalesOrder WHERE intSalesOrderId = @SalesOrderId

		IF @ysnSOSoftwareType = 1 AND ISNULL(@NewInvoiceId, 0) > 0
			BEGIN
				DECLARE @invoiceToPost NVARCHAR(MAX)
				SET @invoiceToPost = CONVERT(NVARCHAR(MAX), @NewInvoiceId)
				UPDATE tblARInvoice SET strType = 'Software' WHERE intInvoiceId = @NewInvoiceId

				EXEC dbo.uspARPostInvoice @post = 1, @recap = 0, @param = @invoiceToPost, @userId = @UserId, @transType = N'Invoice'
			END			
	END

--COMMIT TRANSACTION
IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION 

END