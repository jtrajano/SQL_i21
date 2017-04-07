CREATE PROCEDURE [dbo].[uspARUpdateInTransit]
	 @TransactionId		INT
	,@Negate			BIT	= 0
	,@IsShipped			BIT = 0
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @tblItemsToUpdate InTransitTableType

	IF @IsShipped = 0
		BEGIN
			INSERT INTO @tblItemsToUpdate
				 ([intItemId]
				, [intItemLocationId]
				, [intItemUOMId]
				, [intLotId]
				, [intSubLocationId]
				, [intStorageLocationId]
				, [dblQty]
				, [intTransactionId]
				, [strTransactionId]
				, [intTransactionTypeId]
				, [intFOBPointId]
			) 
			SELECT ID.intItemId
				 , IL.intItemLocationId
				 , ID.intItemUOMId
				 , NULL
				 , NULL
				 , NULL
				 , ID.dblQtyShipped
				 , I.intInvoiceId
				 , I.strInvoiceNumber
				 , 7
				 , fp.intFobPointId
			FROM 
				(SELECT intInvoiceId, intItemId, dblQtyShipped, intItemUOMId, intInventoryShipmentItemId FROM tblARInvoiceDetail WITH (NOLOCK)) ID
			INNER JOIN 
				(SELECT intInvoiceId, strInvoiceNumber, intCompanyLocationId, intFreightTermId FROM tblARInvoice WITH (NOLOCK)) I ON ID.intInvoiceId = I.intInvoiceId
			INNER JOIN 
				(SELECT intItemId, intLocationId, intItemLocationId FROM tblICItemLocation WITH (NOLOCK)) IL ON ID.intItemId = IL.intItemId AND I.intCompanyLocationId = IL.intLocationId
			LEFT JOIN 
				(SELECT intFreightTermId, strFobPoint FROM tblSMFreightTerms WITH (NOLOCK)) ft ON I.intFreightTermId = ft.intFreightTermId
			LEFT JOIN 
				(SELECT intFobPointId, strFobPoint FROM tblICFobPoint WITH (NOLOCK)) fp ON fp.strFobPoint = ft.strFobPoint
            WHERE ID.intInvoiceId = @TransactionId 
               AND ISNULL(ID.intInventoryShipmentItemId, 0) > 0

			 
	  END
	ELSE
		BEGIN
			INSERT INTO @tblItemsToUpdate
				 ([intItemId]
				, [intItemLocationId]
				, [intItemUOMId]
				, [intLotId]
				, [intSubLocationId]
				, [intStorageLocationId]
				, [dblQty]
				, [intTransactionId]
				, [strTransactionId]
				, [intTransactionTypeId]
				, [intFOBPointId]
			)
			SELECT ISHI.intItemId
				, IL.intItemLocationId
				, ISHI.intItemUOMId
				, NULL
				, NULL
				, NULL
				, ISHI.dblQuantity
				, ISH.intInventoryShipmentId
				, ISH.strShipmentNumber
				, 5
				, fp.intFobPointId
			FROM 
				(SELECT intItemId, intItemUOMId, dblQuantity, intInventoryShipmentId, intLineNo FROM tblICInventoryShipmentItem WITH (NOLOCK)) ISHI
			INNER JOIN 
				(SELECT intInventoryShipmentId, strShipmentNumber, intFreightTermId FROM tblICInventoryShipment WITH (NOLOCK)) ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId
			INNER JOIN 
				(SELECT intSalesOrderId, intSalesOrderDetailId FROM tblSOSalesOrderDetail WITH (NOLOCK)) SOD ON ISHI.intLineNo = SOD.intSalesOrderDetailId
			INNER JOIN 
				(SELECT intSalesOrderId, intCompanyLocationId FROM tblSOSalesOrder WITH (NOLOCK)) SO ON SOD.intSalesOrderId = SO.intSalesOrderId
			INNER JOIN 
				(SELECT intItemId, intItemLocationId, intLocationId FROM tblICItemLocation WITH (NOLOCK)) IL ON ISHI.intItemId = IL.intItemId AND SO.intCompanyLocationId = IL.intLocationId
			LEFT JOIN 
				(SELECT intFreightTermId, strFobPoint FROM tblSMFreightTerms WITH (NOLOCK)) ft ON ISH.intFreightTermId = ft.intFreightTermId
			LEFT JOIN 
				(SELECT strFobPoint, intFobPointId FROM tblICFobPoint WITH (NOLOCK)) fp ON fp.strFobPoint = ft.strFobPoint
            WHERE ISHI.intInventoryShipmentId = @TransactionId
			 
		END

	UPDATE @tblItemsToUpdate
	SET dblQty = 
			CASE	WHEN @IsShipped = 0 THEN (CASE WHEN @Negate = 0 THEN dblQty ELSE -dblQty END)
					ELSE (CASE WHEN @Negate = 0 THEN -dblQty ELSE dblQty END)
			END  

	EXEC dbo.uspICIncreaseInTransitOutBoundQty @tblItemsToUpdate
END

GO