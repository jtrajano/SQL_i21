CREATE PROCEDURE [dbo].[uspARInsertToInvoice]
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
		@SalesOrderComment		NVARCHAR(MAX),
		@InvoiceComment			NVARCHAR(MAX),
		@SoftwareComment		NVARCHAR(MAX),
		@SalesOrderNumber		NVARCHAR(100),
		@ShipToLocationId		INT,
		@BillToLocationId		INT,
		@SplitId				INT,
		@EntityContactId		INT

DECLARE @tblItemsToInvoice TABLE (intItemToInvoiceId	INT IDENTITY (1, 1),
							intItemId					INT, 
							ysnIsInventory				BIT,
							ysnBlended					BIT,
							strItemDescription			NVARCHAR(100),
							intItemUOMId				INT,
							intContractHeaderId			INT,
							intContractDetailId			INT,
							dblQtyOrdered				NUMERIC(18,6),
							dblQtyRemaining				NUMERIC(18,6),
							dblMaintenanceAmount		NUMERIC(18,6),
							dblDiscount					NUMERIC(18,6),
							dblItemTermDiscount			NUMERIC(18,6),
							strItemTermDiscountBy		NVARCHAR(50),
							dblPrice					NUMERIC(18,6),
							strPricing					NVARCHAR(250),
							intTaxGroupId				INT,
							intSalesOrderDetailId		INT,
							intInventoryShipmentItemId	INT,
							intRecipeItemId				INT,
							intRecipeId					INT,
							intSubLocationId			INT,
							intCostTypeId				INT,
							intMarginById				INT,
							intCommentTypeId			INT,
							dblMargin					NUMERIC(18,6),
							dblRecipeQuantity			NUMERIC(18,6),
							strMaintenanceType			NVARCHAR(100),
							strFrequency				NVARCHAR(100),
							dtmMaintenanceDate			DATETIME,
							strItemType					NVARCHAR(100),
							strSalesOrderNumber			NVARCHAR(100),
							strShipmentNumber			NVARCHAR(100),
							dblContractBalance			INT,
							dblContractAvailable		INT,
							intEntityContactId			INT)
									
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
SELECT intItemId					= SI.intItemId
	 , ysnIsInventory				= dbo.fnIsStockTrackingItem(SI.intItemId)
	 , ysnBlended					= SOD.ysnBlended
	 , strItemDescription			= SI.strItemDescription
	 , intItemUOMId					= SI.intItemUOMId
	 , intContractHeaderId			= SOD.intContractHeaderId
	 , intContractDetailId			= SOD.intContractDetailId
	 , dblQtyOrdered				= SI.dblQtyOrdered
	 , dblQtyRemaining				= CASE WHEN ISNULL(ISHI.intLineNo, 0) > 0 THEN SOD.dblQtyOrdered - ISHI.dblQuantity ELSE SI.dblQtyRemaining END
	 , dblMaintenanceAmount			= CASE WHEN I.strType = 'Software' THEN SOD.dblMaintenanceAmount ELSE @dblZeroAmount END
	 , dblDiscount					= SI.dblDiscount
	 , dblItemTermDiscount			= SOD.dblItemTermDiscount
	 , strItemTermDiscountBy		= SOD.strItemTermDiscountBy
	 , dblPrice						= CASE WHEN I.strType = 'Software' THEN SOD.dblLicenseAmount ELSE SI.dblPrice END
	 , strPricing					= SOD.strPricing 
	 , intTaxGroupId				= SI.intTaxGroupId
	 , intSalesOrderDetailId		= SI.intSalesOrderDetailId
	 , intInventoryShipmentItemId	= NULL
	 , intRecipeItemId				= NULL
	 , intRecipeId					= SOD.intRecipeId
	 , intSubLocationId				= SOD.intSubLocationId
	 , intCostTypeId				= SOD.intCostTypeId
	 , intMarginById				= SOD.intMarginById
	 , intCommentTypeId				= SOD.intCommentTypeId
	 , dblMargin					= SOD.dblMargin
	 , dblRecipeQuantity			= SOD.dblRecipeQuantity
	 , strMaintenanceType			= SOD.strMaintenanceType
	 , strFrequency					= SOD.strFrequency
	 , dtmMaintenanceDate			= SOD.dtmMaintenanceDate
	 , strItemType					= I.strType
	 , strSalesOrderNumber			= SI.strSalesOrderNumber
	 , strShipmentNumber			= NULL
	 , dblContractBalance			= SOD.dblContractBalance
	 , dblContractAvailable			= SOD.dblContractAvailable
	 , intEntityContactId			= SO.intEntityContactId
FROM tblSOSalesOrder SO 
	INNER JOIN vyuARShippedItems SI ON SO.intSalesOrderId = SI.intSalesOrderId
	LEFT JOIN tblSOSalesOrderDetail SOD ON SI.intSalesOrderDetailId = SOD.intSalesOrderDetailId
	LEFT JOIN tblICItem I ON SI.intItemId = I.intItemId
	LEFT JOIN tblICInventoryShipmentItem ISHI ON SOD.intSalesOrderDetailId = ISHI.intLineNo
WHERE ISNULL(I.strLotTracking, 'No') = 'No'
	AND SO.intSalesOrderId = @SalesOrderId
	AND SI.dblQtyRemaining <> @dblZeroAmount
	AND (ISNULL(ISHI.intLineNo, 0) = 0 OR ISHI.dblQuantity < SOD.dblQtyOrdered)
	AND (ISNULL(SI.intRecipeItemId, 0) = 0)	

--GET COMMENT ITEMS FROM SALES ORDER
INSERT INTO @tblItemsToInvoice
SELECT intItemId					= SOD.intItemId
	 , ysnIsInventory				= dbo.fnIsStockTrackingItem(SOD.intItemId)
	 , ysnBlended					= SOD.ysnBlended
	 , strItemDescription			= SOD.strItemDescription
	 , intItemUOMId					= NULL
	 , intContractHeaderId			= SOD.intContractHeaderId
	 , intContractDetailId			= SOD.intContractDetailId
	 , dblQtyOrdered				= 0
	 , dblQtyRemaining				= 0
	 , dblMaintenanceAmount			= 0
	 , dblDiscount					= 0
	 , dblItemTermDiscount			= 0
	 , strItemTermDiscountBy		= 0
	 , dblPrice						= 0
	 , strPricing					= NULL 
	 , intTaxGroupId				= NULL
	 , intSalesOrderDetailId		= SOD.intSalesOrderDetailId
	 , intInventoryShipmentItemId	= NULL
	 , intRecipeItemId				= NULL
	 , intRecipeId					= SOD.intRecipeId
	 , intSubLocationId				= SOD.intSubLocationId
	 , intCostTypeId				= SOD.intCostTypeId
	 , intMarginById				= SOD.intMarginById
	 , intCommentTypeId				= SOD.intCommentTypeId
	 , dblMargin					= SOD.dblMargin
	 , dblRecipeQuantity			= SOD.dblRecipeQuantity
	 , strMaintenanceType			= NULL
	 , strFrequency					= NULL
	 , dtmMaintenanceDate			= NULL
	 , strItemType					= 'Comment'
	 , strSalesOrderNumber			= NULL
	 , strShipmentNumber			= NULL 
	 , dblContractBalance			= SOD.dblContractBalance
	 , dblContractAvailable			= SOD.dblContractAvailable
	 , intEntityContactId			= SO.intEntityContactId
FROM tblSOSalesOrderDetail SOD
INNER JOIN tblSOSalesOrder SO ON SO.intSalesOrderId = SOD.intSalesOrderId
WHERE SO.intSalesOrderId = @SalesOrderId 
AND ISNULL(intCommentTypeId, 0) <> 0

--GET ITEMS FROM POSTED SHIPMENT
INSERT INTO @tblItemsToInvoice
SELECT intItemId					= ICSI.intItemId
	 , ysnIsInventory				= dbo.fnIsStockTrackingItem(ICSI.intItemId)
	 , ysnBlended					= SOD.ysnBlended
	 , strItemDescription			= SOD.strItemDescription
	 , intItemUOMId					= ICSI.intItemUOMId
	 , intContractHeaderId			= SOD.intContractHeaderId
	 , intContractDetailId			= SOD.intContractDetailId
	 , dblQtyOrdered				= SOD.dblQtyOrdered
	 , dblQtyRemaining				= ICSI.dblQuantity
	 , dblMaintenanceAmount			= @dblZeroAmount
	 , dblDiscount					= SOD.dblDiscount
	 , dblItemTermDiscount			= SOD.dblItemTermDiscount
	 , strItemTermDiscountBy		= SOD.strItemTermDiscountBy
	 , dblPrice						= ICSI.dblUnitPrice
	 , strPricing					= SOD.strPricing 
	 , intTaxGroupId				= SOD.intTaxGroupId
	 , intSalesOrderDetailId		= SOD.intSalesOrderDetailId
	 , intInventoryShipmentItemId	= ICSI.intInventoryShipmentItemId
	 , intRecipeItemId				= NULL
	 , intRecipeId					= SOD.intRecipeId
	 , intSubLocationId				= SOD.intSubLocationId
	 , intCostTypeId				= SOD.intCostTypeId
	 , intMarginById				= SOD.intMarginById
	 , intCommentTypeId				= SOD.intCommentTypeId
	 , dblMargin					= SOD.dblMargin
	 , dblRecipeQuantity			= SOD.dblRecipeQuantity
	 , strMaintenanceType			= SOD.strMaintenanceType
	 , strFrequency					= SOD.strFrequency
	 , dtmMaintenanceDate			= SOD.dtmMaintenanceDate
	 , strItemType					= ICI.strType
	 , strSalesOrderNumber			= SO.strSalesOrderNumber
	 , strShipmentNumber			= ICS.strShipmentNumber
	 , dblContractBalance			= SOD.dblContractBalance
	 , dblContractAvailable			= SOD.dblContractAvailable
	 , intEntityContactId			= SO.intEntityContactId
FROM tblICInventoryShipmentItem ICSI 
INNER JOIN tblICInventoryShipment ICS ON ICS.intInventoryShipmentId = ICSI.intInventoryShipmentId
INNER JOIN tblSOSalesOrderDetail SOD ON SOD.intSalesOrderDetailId = ICSI.intLineNo
INNER JOIN tblSOSalesOrder SO ON SOD.intSalesOrderId = SO.intSalesOrderId
LEFT JOIN tblICItem ICI ON ICSI.intItemId = ICI.intItemId
WHERE ICSI.intOrderId = @SalesOrderId
AND ICS.ysnPosted = 1

--GET ITEMS FROM Manufacturing - Other Charges
INSERT INTO @tblItemsToInvoice
SELECT intItemId					= ARSI.intItemId
	 , ysnIsInventory				= dbo.fnIsStockTrackingItem(ARSI.intItemId)
	 , ysnBlended					= ARSI.ysnBlended
	 , strItemDescription			= ARSI.strItemDescription
	 , intItemUOMId					= ARSI.intItemUOMId
	 , intContractHeaderId			= ARSI.intContractHeaderId
	 , intContractDetailId			= ARSI.intContractDetailId
	 , dblQtyOrdered				= 0
	 , dblQtyRemaining				= ARSI.dblQtyRemaining  
	 , dblMaintenanceAmount			= 0 
	 , dblDiscount					= ARSI.dblDiscount
	 , dblItemTermDiscount			= 0
	 , strItemTermDiscountBy		= NULL
	 , dblPrice						= ARSI.dblPrice 
	 , strPricing					= ''
	 , intTaxGroupId				= NULL
	 , intSalesOrderDetailId		= NULL
	 , intInventoryShipmentItemId	= NULL
	 , intRecipeItemId				= NULL
	 , intRecipeId					= NULL
	 , intSubLocationId				= NULL
	 , intCostTypeId				= NULL
	 , intMarginById				= NULL
	 , intCommentTypeId				= NULL
	 , dblMargin					= NULL
	 , dblRecipeQuantity			= NULL
	 , strMaintenanceType			= ''
	 , strFrequency					= NULL
	 , dtmMaintenanceDate			= NULL
	 , strItemType					= I.strType
	 , strSalesOrderNumber			= ARSI.strSalesOrderNumber
	 , strShipmentNumber			= ARSI.strShipmentNumber
	 , dblContractBalance			= 0
	 , dblContractAvailable			= 0
	 , intEntityCustomerId			= NULL
	
FROM vyuARShippedItems ARSI
LEFT JOIN tblICItem I ON ARSI.intItemId = I.intItemId
WHERE
	ARSI.intSalesOrderId = @SalesOrderId
	AND ISNULL(ARSI.intRecipeItemId,0) <> 0

--GET SOFTWARE ITEMS
IF @FromShipping = 0
	BEGIN --MAINTENANCE/SAAS/LICENSEORMAINTENANCE SOFTWARE ITEMS
		INSERT INTO @tblSODSoftware (intSalesOrderDetailId, dblDiscount, dblTotalTax, dblPrice, dblTotal)
		SELECT intSalesOrderDetailId
				, @dblZeroAmount
				, @dblZeroAmount
				, dblMaintenanceAmount
				, dblMaintenanceAmount * dblQtyRemaining				
		FROM @tblItemsToInvoice 
		WHERE strItemType = 'Software' AND strMaintenanceType IN ('Maintenance Only', 'SaaS', 'License/Maintenance')
			ORDER BY intSalesOrderDetailId
	END
	
--COMPUTE INVOICE TOTAL AMOUNTS FOR SOFTWARE
SELECT @dblSalesOrderSubtotal	  = SUM(dblPrice)
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
		@Date					=	@DateOnly,
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
		@SplitId				=	intSplitId,
		@SalesOrderComment		=   strComments,
		@EntityContactId		=	intEntityContactId
FROM tblSOSalesOrder WHERE intSalesOrderId = @SalesOrderId
	
EXEC dbo.[uspARGetDefaultComment] @CompanyLocationId, @EntityCustomerId, 'Invoice', 'Software', @SoftwareComment OUT
EXEC dbo.[uspARGetDefaultComment] @CompanyLocationId, @EntityCustomerId, 'Invoice', 'Standard', @InvoiceComment OUT

IF EXISTS (SELECT NULL FROM tblSOSalesOrderDetail WHERE intSalesOrderId = @SalesOrderId AND ISNULL(intRecipeId, 0) <> 0)
	BEGIN
		SET @InvoiceComment = ISNULL(@InvoiceComment, '') + ' ' + ISNULL(@SalesOrderComment, '')
	END

--BEGIN TRANSACTION
IF ISNULL(@RaiseError,0) = 0
	BEGIN TRANSACTION

--CHECK IF THERE IS SOFTWARE ITEMS (NON-STOCK / STOCK ITEMS)
IF EXISTS(SELECT NULL FROM @tblSODSoftware)
	BEGIN
		SELECT TOP 1 @SoftwareInvoiceId = intInvoiceId FROM tblARInvoice WHERE intEntityCustomerId = @EntityCustomerId AND ysnRecurring = 1 AND strType = 'Software'
		
		IF ISNULL(@SoftwareInvoiceId, 0) > 0
			BEGIN
				--UPDATE EXISTING RECURRING INVOICE
				UPDATE tblARInvoice 
				SET dblInvoiceSubtotal	= dblInvoiceSubtotal + @dblSalesOrderSubtotal
				  , dblTax				= dblTax + @dblTax
				  , dblInvoiceTotal		= dblInvoiceTotal + @dblSalesOrderTotal
				  , dblDiscount			= dblDiscount + @dblDiscount
				  , dtmDate				= @DateOnly
				  , ysnRecurring		= 1
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
					,[ysnRecurring]
					,[ysnPosted]
					,[intEntityContactId]
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
					,[intEntityContactId]
				FROM
				tblSOSalesOrder
				WHERE intSalesOrderId = @SalesOrderId

				SET @SoftwareInvoiceId = SCOPE_IDENTITY()
				SET @NewInvoiceId = @SoftwareInvoiceId
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
					,[intOrderUOMId]
					,[dblQtyOrdered]
					,[intItemUOMId]					
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
					,[intItemUOMId]				--[intOrderUOMId]					
					,[dblQtyOrdered]			--[dblQtyOrdered]
					,[intItemUOMId]				--[intItemUOMId]					
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
					,0
				FROM
					tblSOSalesOrderDetail
				WHERE
					[intSalesOrderDetailId] = @SalesOrderDetailId
												
				SET @SoftwareInvoiceDetailId = SCOPE_IDENTITY()
				
				DELETE FROM @tblSODSoftware WHERE [intSalesOrderDetailId] = @SalesOrderDetailId
			END

		EXEC dbo.uspARReComputeInvoiceTaxes @SoftwareInvoiceId
	END

--CHECK IF THERE IS NON STOCK ITEMS
IF EXISTS (SELECT NULL FROM @tblItemsToInvoice WHERE strMaintenanceType NOT IN ('Maintenance Only', 'SaaS'))
	BEGIN
		DELETE FROM @tblItemsToInvoice WHERE strMaintenanceType IN ('Maintenance Only', 'SaaS')
		SET @NewInvoiceId = NULL

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
					,@EntityContactId				= @EntityContactId

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
						@ItemIsBlended			BIT,
						@NewDetailId			INT,
						@ItemDescription		NVARCHAR(100),
						@OrderUOMId				INT,
						@ItemUOMId				INT,
						@ItemContractHeaderId	INT,
						@ItemContractDetailId	INT,
						@ItemQtyOrdered			NUMERIC(18,6),
						@ItemQtyShipped			NUMERIC(18,6),
						@ItemDiscount			NUMERIC(18,6),
						@ItemTermDiscount		NUMERIC(18,6),
						@ItemTermDiscountBy		NVARCHAR(50),
						@ItemPrice				NUMERIC(18,6),
						@ItemPricing			NVARCHAR(250),
						@ItemTaxGroupId			INT,		
						@ItemSalesOrderDetailId	INT,
						@ItemShipmentDetailId	INT,
						@ItemRecipeItemId		INT,
						@ItemSalesOrderNumber	NVARCHAR(100),
						@ItemShipmentNumber		NVARCHAR(100),
						@ItemMaintenanceType	NVARCHAR(100),
						@ItemFrequency			NVARCHAR(100),
						@ItemMaintenanceDate	DATETIME,
						@ItemRecipeId			INT,
						@ItemSublocationId		INT,
						@ItemCostTypeId			INT,
						@ItemMarginById			INT,
						@ItemCommentTypeId		INT,
						@ItemMargin				NUMERIC(18,6),
						@ItemRecipeQty			NUMERIC(18,6),
						@ContractBalance		INT,
						@ContractAvailable		INT

				SELECT TOP 1
						@intItemToInvoiceId		= intItemToInvoiceId,
						@ItemId					= intItemId,
						@ItemIsInventory		= ysnIsInventory,
						@ItemIsBlended			= ysnBlended,
						@ItemDescription		= strItemDescription,
						@OrderUOMId				= intItemUOMId,	
						@ItemUOMId				= intItemUOMId,
						@ItemContractHeaderId	= intContractHeaderId,
						@ItemContractDetailId	= intContractDetailId,
						@ItemQtyOrdered			= dblQtyOrdered,
						@ItemQtyShipped			= dblQtyRemaining,
						@ItemDiscount			= dblDiscount,
						@ItemTermDiscount		= dblItemTermDiscount,
						@ItemTermDiscountBy		= strItemTermDiscountBy,
						@ItemPrice				= dblPrice,
						@ItemPricing			= strPricing,
						@ItemTaxGroupId			= intTaxGroupId,
						@ItemSalesOrderDetailId	= intSalesOrderDetailId,						
						@ItemShipmentDetailId	= intInventoryShipmentItemId,
						@ItemRecipeItemId		= intRecipeItemId,
						@ItemRecipeId			= intRecipeId,
						@ItemSublocationId		= intSubLocationId,
						@ItemCostTypeId			= intCostTypeId,
						@ItemMarginById			= intMarginById,
						@ItemCommentTypeId		= intCommentTypeId,
						@ItemMargin				= dblMargin,
						@ItemRecipeQty			= dblRecipeQuantity,
						@ItemSalesOrderNumber	= strSalesOrderNumber,
						@ItemShipmentNumber		= strShipmentNumber,
						@ItemMaintenanceType	= strMaintenanceType,
						@ItemFrequency			= strFrequency,
						@ItemMaintenanceDate	= dtmMaintenanceDate,
						@ContractBalance		= dblContractBalance,
						@ContractAvailable		= dblContractAvailable,	
						@EntityContactId		= intEntityContactId											
				FROM @tblItemsToInvoice ORDER BY intSalesOrderDetailId ASC
				
				EXEC [dbo].[uspARAddItemToInvoice]
							 @InvoiceId						= @NewInvoiceId	
							,@ItemId						= @ItemId
							,@ItemIsInventory				= @ItemIsInventory
							,@ItemIsBlended					= @ItemIsBlended
							,@NewInvoiceDetailId			= @NewDetailId			OUTPUT 
							,@ErrorMessage					= @CurrentErrorMessage	OUTPUT
							,@RaiseError					= @RaiseError
							,@ItemDescription				= @ItemDescription
							,@ItemDocumentNumber			= @ItemSalesOrderNumber
							,@OrderUOMId					= @OrderUOMId
							,@ItemUOMId						= @ItemUOMId
							,@ItemContractHeaderId			= @ItemContractHeaderId
							,@ItemContractDetailId		    = @ItemContractDetailId
							,@ItemQtyOrdered				= @ItemQtyOrdered
							,@ItemQtyShipped				= @ItemQtyShipped
							,@ItemDiscount					= @ItemDiscount
							,@ItemTermDiscount				= @ItemTermDiscount
							,@ItemTermDiscountBy			= @ItemTermDiscountBy
							,@ItemPrice						= @ItemPrice
							,@ItemPricing					= @ItemPricing
							,@RefreshPrice					= 0
							,@ItemTaxGroupId				= @ItemTaxGroupId
							,@RecomputeTax					= 0
							,@ItemSalesOrderDetailId		= @ItemSalesOrderDetailId							
							,@ItemInventoryShipmentItemId	= @ItemShipmentDetailId
							,@ItemRecipeItemId				= @ItemRecipeItemId
							,@ItemRecipeId					= @ItemRecipeId
							,@ItemSublocationId				= @ItemSublocationId
							,@ItemCostTypeId				= @ItemCostTypeId
							,@ItemMarginById				= @ItemMarginById
							,@ItemCommentTypeId				= @ItemCommentTypeId
							,@ItemMargin					= @ItemMargin
							,@ItemRecipeQty					= @ItemRecipeQty
							,@ItemSalesOrderNumber			= @ItemSalesOrderNumber
							,@ItemShipmentNumber			= @ItemShipmentNumber
							,@EntitySalespersonId			= @EntitySalespersonId
							,@ItemMaintenanceType			= @ItemMaintenanceType
							,@ItemFrequency					= @ItemFrequency
							,@ItemMaintenanceDate			= @ItemMaintenanceDate

				UPDATE tblARInvoiceDetail SET dblContractBalance = @ContractBalance, dblContractAvailable = @ContractAvailable
				FROM @tblItemsToInvoice 
				WHERE intInvoiceId = @NewInvoiceId AND tblARInvoiceDetail.intItemId = @ItemId AND tblARInvoiceDetail.intContractHeaderId = @ItemContractHeaderId AND tblARInvoiceDetail.intContractDetailId = @ItemContractDetailId

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
					BEGIN
						IF ISNULL(@NewDetailId, 0) > 0
							BEGIN
								DELETE FROM tblARInvoiceDetailTax WHERE intInvoiceDetailId =  @NewDetailId

								INSERT INTO [tblARInvoiceDetailTax]
									([intInvoiceDetailId]
									,[intTaxGroupId]
									,[intTaxCodeId]
									,[intTaxClassId]
									,[strTaxableByOtherTaxes]
									,[strCalculationMethod]
									,[dblRate]
									,[dblExemptionPercent]
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
									 @NewDetailId
									,[intTaxGroupId]
									,[intTaxCodeId]
									,[intTaxClassId]
									,[strTaxableByOtherTaxes]
									,[strCalculationMethod]
									,[dblRate]
									,[dblExemptionPercent]
									,[intSalesTaxAccountId]
									,[dblTax]
									,[dblAdjustedTax]
									,[ysnTaxAdjusted]
									,[ysnSeparateOnInvoice]
									,[ysnCheckoffTax]
									,[ysnTaxExempt]
									,[strNotes]
									,0
								FROM
									[tblSOSalesOrderDetailTax]
								WHERE
									[intSalesOrderDetailId] = @ItemSalesOrderDetailId

								INSERT INTO tblARInvoiceDetailComponent
									([intInvoiceDetailId]
									,[intComponentItemId]
									,[strComponentType]
									,[intItemUOMId]
									,[dblQuantity]
									,[dblUnitQuantity]
									,[intConcurrencyId])
								SELECT 
									 [intInvoiceDetailId]	= @NewDetailId
									,[intComponentItemId]	= [intComponentItemId]
									,[strComponentType]		= [strComponentType]
									,[intItemUOMId]			= [intItemUOMId]
									,[dblQuantity]			= [dblQuantity]
									,[dblUnitQuantity]		= [dblUnitQuantity]
									,[intConcurrencyId]		= 1
								FROM
									tblSOSalesOrderDetailComponent
								WHERE
									[intSalesOrderDetailId] = @ItemSalesOrderDetailId								
						END

						DELETE FROM @tblItemsToInvoice WHERE intItemToInvoiceId = @intItemToInvoiceId
					END
			END	
	END

--UPDATE OTHER TABLE INTEGRATIONS
IF ISNULL(@RaiseError,0) = 0
	BEGIN

		IF ISNULL(@NewInvoiceId, 0) <> 0
		BEGIN
			DECLARE @InvoiceNumber NVARCHAR(250)
					,@SourceScreen NVARCHAR(250)
			SELECT @InvoiceNumber = strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @NewInvoiceId
			SET	@SourceScreen = 'Sales Order to Invoice'
			EXEC dbo.uspSMAuditLog 
				 @keyValue			= @NewInvoiceId						-- Primary Key Value of the Invoice. 
				,@screenName		= 'AccountsReceivable.view.Invoice'	-- Screen Namespace
				,@entityId			= @UserId							-- Entity Id.
				,@actionType		= 'Processed'						-- Action Type
				,@changeDescription	= @SourceScreen						-- Description
				,@fromValue			= @SalesOrderNumber					-- Previous Value
				,@toValue			= @InvoiceNumber					-- New Value	
		END	

		EXEC dbo.uspARInsertTransactionDetail @NewInvoiceId	
		EXEC dbo.uspARUpdateInvoiceIntegrations @NewInvoiceId, 0, @UserId
		EXEC dbo.uspSOUpdateOrderShipmentStatus @SalesOrderId
		EXEC dbo.[uspARReComputeInvoiceAmounts] @NewInvoiceId
		
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
			
		IF EXISTS(SELECT TOP 1 1 FROM tblSOSalesOrderDetail SOD INNER JOIN tblICItem ICI ON SOD.intItemId = ICI.intItemId AND ICI.strType = 'Software' WHERE SOD.intSalesOrderId = @SalesOrderId) AND ISNULL(@NewInvoiceId, 0) > 0
			BEGIN
				DECLARE @invoiceToPost NVARCHAR(MAX)
				SET @invoiceToPost = CONVERT(NVARCHAR(MAX), @NewInvoiceId)
				UPDATE tblARInvoice SET strType = 'Software' WHERE intInvoiceId = @NewInvoiceId

				EXEC dbo.uspARPostInvoice @post = 1, @recap = 0, @param = @invoiceToPost, @userId = @UserId, @transType = N'Invoice'
			END

		SET @NewInvoiceId = ISNULL(@NewInvoiceId, @SoftwareInvoiceId)
	END

IF (@SalesOrderNumber IS NULL OR @SalesOrderNumber = '')
BEGIN
	SELECT @SalesOrderNumber = strSalesOrderNumber FROM tblSOSalesOrder WHERE intSalesOrderId = @SalesOrderId
END

IF (@SalesOrderNumber IS NOT NULL)
BEGIN
	UPDATE tblARInvoice SET dblTotalWeight = CopySO.dblTotalWeight, dblTotalTermDiscount = CopySO.dblTotalTermDiscount
	FROM(
		SELECT SO.intSalesOrderId, SO.strSalesOrderNumber, SO.dblTotalWeight, SOD.intItemId, SOD.intItemUOMId,  SOD.intItemWeightUOMId, SOD.dblItemWeight, SOD.dblOriginalItemWeight,
			SO.dblTotalTermDiscount
		FROM tblSOSalesOrder SO 
		INNER JOIN (SELECT intSalesOrderId, intItemWeightUOMId, dblItemWeight, dblOriginalItemWeight, intItemId, intItemUOMId 
					FROM tblSOSalesOrderDetail) SOD ON SO.intSalesOrderId = SOD.intSalesOrderId 
		LEFT JOIN (SELECT strDocumentNumber FROM tblARInvoiceDetail) ID ON SO.strSalesOrderNumber = ID.strDocumentNumber
		WHERE strSalesOrderNumber = @SalesOrderNumber
	) CopySO
	WHERE intInvoiceId = @NewInvoiceId

	UPDATE tblARInvoiceDetail SET intItemWeightUOMId = CopySO.intItemWeightUOMId, dblItemWeight = CopySO.dblItemWeight, dblOriginalItemWeight = CopySO.dblOriginalItemWeight,
		dblItemTermDiscount = CopySO.dblItemTermDiscount
	FROM(
		SELECT SO.intSalesOrderId, SO.strSalesOrderNumber, SO.dblTotalWeight, SOD.intItemId, SOD.intItemUOMId,  SOD.intItemWeightUOMId, SOD.dblItemWeight, SOD.dblOriginalItemWeight,
			SOD.dblItemTermDiscount
		FROM tblSOSalesOrder SO 
		INNER JOIN (SELECT intSalesOrderId, intItemWeightUOMId, dblItemWeight, dblOriginalItemWeight, intItemId, intItemUOMId, dblItemTermDiscount
					FROM tblSOSalesOrderDetail) SOD ON SO.intSalesOrderId = SOD.intSalesOrderId 
		LEFT JOIN (SELECT strDocumentNumber FROM tblARInvoiceDetail) ID ON SO.strSalesOrderNumber = ID.strDocumentNumber
		WHERE strSalesOrderNumber = @SalesOrderNumber
	) CopySO
	WHERE intInvoiceId = @NewInvoiceId AND tblARInvoiceDetail.intItemId = CopySO.intItemId AND tblARInvoiceDetail.intItemUOMId = CopySO.intItemUOMId AND tblARInvoiceDetail.strSalesOrderNumber = CopySO.strSalesOrderNumber
END

 

--COMMIT TRANSACTION
IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION 

END