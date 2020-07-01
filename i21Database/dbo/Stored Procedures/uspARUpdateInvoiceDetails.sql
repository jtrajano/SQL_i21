CREATE PROCEDURE [dbo].[uspARUpdateInvoiceDetails]
	@intInvoiceDetailId		INT,
	@intEntityId			INT,
	@intPriceUOMId			INT = NULL,
	@dblQtyShipped			NUMERIC(38, 20) = NULL,
	@dblPrice				NUMERIC(18, 6) = NULL
AS

IF ISNULL(@intInvoiceDetailId, 0) = 0 OR NOT EXISTS(SELECT TOP 1 NULL FROM tblARInvoiceDetail WHERE intInvoiceDetailId = @intInvoiceDetailId)
	BEGIN
		RAISERROR('Invoice Detail Id does not exists!', 16, 1)
		RETURN;
	END

IF ISNULL(@intEntityId, 0) = 0 OR NOT EXISTS(SELECT TOP 1 NULL FROM tblEMEntity WHERE intEntityId = @intEntityId)
	BEGIN
		RAISERROR('Entity Id does not exists!', 16, 1)
		RETURN;
	END

IF ISNULL(@intPriceUOMId, 0) <> 0 AND NOT EXISTS(SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemUOMId = @intPriceUOMId)
	BEGIN
		RAISERROR('Price UOM Id does not exists!', 16, 1)
		RETURN;
	END

DECLARE @intInvoiceId				INT = NULL
	  , @intItemId					INT = NULL
	  , @intOldPriceUOMId			INT = NULL
	  , @intNewPriceUOMId			INT = NULL
	  , @ysnPosted					BIT = 0
	  , @strInvoiceNumber			NVARCHAR(50) = ''
	  , @dblOldQtyShipped			NUMERIC(38, 20) = 0
	  , @dblOldPrice				NUMERIC(18, 6) = 0
	  , @dblOldTotal				NUMERIC(18, 6) = 0
	  , @dblOldItemTermDiscount		NUMERIC(18, 6) = 0
	  , @dblOldTotalTax				NUMERIC(18, 6) = 0
	  , @dblOldTax					NUMERIC(18, 6) = 0
	  , @dblOldInvoiceSubTotal		NUMERIC(18, 6) = 0
	  , @dblOldInvoiceTotal			NUMERIC(18, 6) = 0
	  , @dblOldAmountDue			NUMERIC(18, 6) = 0
	  , @dblOldTotalTermDiscount	NUMERIC(18, 6) = 0
	  , @dblOldDiscountAvailable	NUMERIC(18, 6) = 0
	  , @dblNewQtyShipped			NUMERIC(18, 6) = 0
	  , @dblNewPrice				NUMERIC(18, 6) = 0
	  , @dblNewTotal				NUMERIC(18, 6) = 0
	  , @dblNewItemTermDiscount		NUMERIC(18, 6) = 0
	  , @dblNewTotalTax				NUMERIC(18, 6) = 0
	  , @dblNewTax					NUMERIC(18, 6) = 0
	  , @dblNewInvoiceSubTotal		NUMERIC(18, 6) = 0
	  , @dblNewInvoiceTotal			NUMERIC(18, 6) = 0
	  , @dblNewAmountDue			NUMERIC(18, 6) = 0
	  , @dblNewTotalTermDiscount	NUMERIC(18, 6) = 0
	  , @dblNewDiscountAvailable	NUMERIC(18, 6) = 0

SELECT @intInvoiceId				= I.intInvoiceId
	 , @intItemId					= ID.intItemId
	 , @intOldPriceUOMId			= ID.intPriceUOMId
	 , @strInvoiceNumber			= I.strInvoiceNumber
	 , @dblOldQtyShipped			= ID.dblQtyShipped
	 , @dblOldPrice					= ID.dblPrice
	 , @dblOldTotal					= ID.dblTotal
	 , @dblOldItemTermDiscount		= ID.dblItemTermDiscount
	 , @dblOldTotalTax				= ID.dblTotalTax
	 , @dblOldTax					= I.dblTax
	 , @dblOldInvoiceSubTotal		= I.dblInvoiceSubtotal
	 , @dblOldInvoiceTotal			= I.dblInvoiceTotal
	 , @dblOldAmountDue				= I.dblAmountDue
	 , @dblOldTotalTermDiscount		= I.dblTotalTermDiscount
	 , @dblOldDiscountAvailable		= I.dblDiscountAvailable
	 , @ysnPosted					= I.ysnPosted
FROM tblARInvoiceDetail ID 
INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
WHERE ID.intInvoiceDetailId = @intInvoiceDetailId

IF @ysnPosted = 1
	BEGIN
		RAISERROR('Invoice is already Posted!', 16, 1)
		RETURN;
	END

EXEC [uspARInsertTransactionDetail] @intInvoiceId, @intEntityId

UPDATE tblARInvoiceDetail
SET dblQtyShipped = CASE WHEN @dblQtyShipped IS NOT NULL THEN @dblQtyShipped ELSE dblQtyShipped END
  , dblPrice	  = CASE WHEN @dblPrice IS NOT NULL THEN @dblPrice ELSE dblPrice END
  , intPriceUOMId = CASE WHEN @intPriceUOMId IS NOT NULL THEN @intPriceUOMId ELSE intPriceUOMId END  
WHERE intInvoiceDetailId = @intInvoiceDetailId

EXEC dbo.uspARUpdateInvoiceIntegrations @InvoiceId = @intInvoiceId, @UserId = @intEntityId
EXEC dbo.uspARReComputeInvoiceTaxes @InvoiceId = @intInvoiceId

SELECT @intNewPriceUOMId			= ID.intPriceUOMId
     , @dblNewQtyShipped			= ID.dblQtyShipped
	 , @dblNewPrice					= ID.dblPrice
	 , @dblNewTotal					= ID.dblTotal
	 , @dblNewItemTermDiscount		= ID.dblItemTermDiscount
	 , @dblNewTotalTax				= ID.dblTotalTax
	 , @dblNewTax					= I.dblTax
	 , @dblNewInvoiceSubTotal		= I.dblInvoiceSubtotal
	 , @dblNewInvoiceTotal			= I.dblInvoiceTotal
	 , @dblNewAmountDue				= I.dblAmountDue
	 , @dblNewTotalTermDiscount		= I.dblTotalTermDiscount
	 , @dblNewDiscountAvailable		= I.dblDiscountAvailable
FROM tblARInvoiceDetail ID 
INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
WHERE ID.intInvoiceDetailId = @intInvoiceDetailId

/****************** AUDIT LOG ******************/
BEGIN TRANSACTION [AUDITLOG]
BEGIN 
	DECLARE @strInvoiceId			VARCHAR(50) = CAST(@intInvoiceId AS VARCHAR(50))
		  , @strInvoiceDetailId		VARCHAR(50) = CAST(@intInvoiceDetailId AS VARCHAR(50))
		  , @strValueFrom			VARCHAR(50)
		  , @strValueTo				VARCHAR(50)
		  , @strHeaderData			NVARCHAR(MAX)
		  , @strDetailData			NVARCHAR(MAX)
 
	SET @strHeaderData = '{"action":"Updated","change":"Updated by Price Contracts - Record: ' + @strInvoiceId +'","keyValue":' + @strInvoiceId +',"iconCls":"small-tree-modified","children":['

	IF @dblOldTax <> @dblNewTax
		BEGIN
			SET @strValueFrom = CAST(CAST(@dblOldTax AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strValueTo = CAST(CAST(@dblNewTax AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strHeaderData = @strHeaderData + '{"change":"dblTax","from":"'+ @strValueFrom +'","to":"'+ @strValueTo +'","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + @strInvoiceId +',"changeDescription":"Tax","hidden":false},'
		END

	IF @dblOldInvoiceSubTotal <> @dblNewInvoiceSubTotal
		BEGIN
			SET @strValueFrom = CAST(CAST(@dblOldInvoiceSubTotal AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strValueTo = CAST(CAST(@dblNewInvoiceSubTotal AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strHeaderData = @strHeaderData + '{"change":"dblInvoiceSubtotal","from":"'+ @strValueFrom +'","to":"'+ @strValueTo +'","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + @strInvoiceId +',"changeDescription":"Subtotal","hidden":false},'
		END

	IF @dblOldInvoiceTotal <> @dblNewInvoiceTotal
		BEGIN
			SET @strValueFrom = CAST(CAST(@dblOldInvoiceTotal AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strValueTo = CAST(CAST(@dblNewInvoiceTotal AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strHeaderData = @strHeaderData + '{"change":"dblInvoiceTotal","from":"'+ @strValueFrom +'","to":"'+ @strValueTo +'","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + @strInvoiceId +',"changeDescription":"Invoice Total","hidden":false},'
		END

	IF @dblOldAmountDue <> @dblNewAmountDue
		BEGIN
			SET @strValueFrom = CAST(CAST(@dblOldAmountDue AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strValueTo = CAST(CAST(@dblNewAmountDue AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strHeaderData = @strHeaderData + '{"change":"dblAmountDue","from":"'+ @strValueFrom +'","to":"'+ @strValueTo +'","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + @strInvoiceId +',"changeDescription":"Amount Due","hidden":false},'
		END

	IF @dblOldTotalTermDiscount <> @dblNewTotalTermDiscount
		BEGIN
			SET @strValueFrom = CAST(CAST(@dblOldTotalTermDiscount AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strValueTo = CAST(CAST(@dblNewTotalTermDiscount AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strHeaderData = @strHeaderData + '{"change":"dblTotalTermDiscount","from":"'+ @strValueFrom +'","to":"'+ @strValueTo +'","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + @strInvoiceId +',"changeDescription":"Total Term Discount","hidden":false},'
		END

	IF @dblOldDiscountAvailable <> @dblNewDiscountAvailable
		BEGIN
			SET @strValueFrom = CAST(CAST(@dblOldDiscountAvailable AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strValueTo = CAST(CAST(@dblNewDiscountAvailable AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strHeaderData = @strHeaderData + '{"change":"dblDiscountAvailable","from":"'+ @strValueFrom +'","to":"'+ @strValueTo +'","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + @strInvoiceId +',"changeDescription":"Discount Available","hidden":false},'
		END

	SET @strDetailData = '{"change":"tblARInvoiceDetails","children":[{"action":"Updated","change":"Updated by Price Contracts - Record: ' + @strInvoiceDetailId + '","keyValue":' + @strInvoiceDetailId +',"iconCls":"small-tree-modified","children":['

	IF @intOldPriceUOMId <> @intNewPriceUOMId
		BEGIN
			SET @strValueFrom = (SELECT TOP 1 UOM.strUnitMeasure FROM tblICItemUOM IUOM INNER JOIN tblICUnitMeasure UOM ON IUOM.intUnitMeasureId = UOM.intUnitMeasureId  WHERE IUOM.intItemUOMId = @intOldPriceUOMId AND IUOM.intItemId = @intItemId)
			SET @strValueTo = (SELECT TOP 1 UOM.strUnitMeasure FROM tblICItemUOM IUOM INNER JOIN tblICUnitMeasure UOM ON IUOM.intUnitMeasureId = UOM.intUnitMeasureId  WHERE IUOM.intItemUOMId = @intNewPriceUOMId AND IUOM.intItemId = @intItemId)
			SET @strDetailData = @strDetailData + '{"change":"intPriceUOMId","from":"'+ @strValueFrom +'","to":"'+ @strValueTo +'","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + @strInvoiceDetailId +',"associationKey":"tblARInvoiceDetails","changeDescription":"Price UOM","hidden":false},'
		END

	IF @dblOldQtyShipped <> @dblNewQtyShipped
		BEGIN
			SET @strValueFrom = CAST(CAST(@dblOldQtyShipped AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strValueTo = CAST(CAST(@dblNewQtyShipped AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strDetailData = @strDetailData + '{"change":"dblQtyShipped","from":"'+ @strValueFrom +'","to":"'+ @strValueTo +'","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + @strInvoiceDetailId +',"associationKey":"tblARInvoiceDetails","changeDescription":"Qty Shipped","hidden":false},'
		END

	IF @dblOldPrice <> @dblNewPrice
		BEGIN
			SET @strValueFrom = CAST(CAST(@dblOldPrice AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strValueTo = CAST(CAST(@dblNewPrice AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strDetailData = @strDetailData + '{"change":"dblPrice","from":"'+ @strValueFrom +'","to":"'+ @strValueTo +'","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + @strInvoiceDetailId +',"associationKey":"tblARInvoiceDetails","changeDescription":"Price","hidden":false},'
		END

	IF @dblOldTotal <> @dblNewTotal
		BEGIN
			SET @strValueFrom = CAST(CAST(@dblOldTotal AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strValueTo = CAST(CAST(@dblNewTotal AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strDetailData = @strDetailData + '{"change":"dblTotal","from":"'+ @strValueFrom +'","to":"'+ @strValueTo +'","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + @strInvoiceDetailId +',"associationKey":"tblARInvoiceDetails","changeDescription":"Total","hidden":false},'
		END

	IF @dblOldItemTermDiscount <> @dblNewItemTermDiscount
		BEGIN
			SET @strValueFrom = CAST(CAST(@dblOldItemTermDiscount AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strValueTo = CAST(CAST(@dblNewItemTermDiscount AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strDetailData = @strDetailData + '{"change":"dblItemTermDiscount","from":"'+ @strValueFrom +'","to":"'+ @strValueTo +'","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + @strInvoiceDetailId +',"associationKey":"tblARInvoiceDetails","changeDescription":"Item Term Discount","hidden":true},'
		END

	IF @dblOldTotalTax <> @dblNewTotalTax
		BEGIN
			SET @strValueFrom = CAST(CAST(@dblOldTotalTax AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strValueTo = CAST(CAST(@dblNewTotalTax AS NUMERIC(18, 2)) AS VARCHAR(50))
			SET @strDetailData = @strDetailData + '{"change":"dblTotalTax","from":"'+ @strValueFrom +'","to":"'+ @strValueTo +'","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + @strInvoiceDetailId +',"associationKey":"tblARInvoiceDetails","changeDescription":"Total Tax","hidden":false},'
		END
	
	SET @strDetailData = @strDetailData + ']}],"iconCls":"small-tree-grid","changeDescription":"Details"}';

	SET @strHeaderData = CAST('' AS NVARCHAR(MAX)) + @strHeaderData + @strDetailData + ']}';

	INSERT INTO tblSMAuditLog (strActionType, strTransactionType, strRecordNo, strJsonData, dtmDate, intEntityId, intConcurrencyId)
	SELECT strActionType		= 'Updated'
		 , strTransactionType	= 'AccountsReceivable.view.Invoice'
		 , strRecordNo			= @strInvoiceId
		 , strJsonData			= @strHeaderData
		 , dtmDate				= GETDATE()
		 , intEntityId			= @intEntityId
		 , intConcurrencyId		= 1
	
COMMIT TRANSACTION [AUDITLOG]
END
/****************** AUDIT LOG ******************/
