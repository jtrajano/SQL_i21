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
			FROM tblARInvoiceDetail ID
				INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
				INNER JOIN tblICItemLocation IL ON ID.intItemId = IL.intItemId AND I.intCompanyLocationId = IL.intLocationId
				LEFT JOIN tblSMFreightTerms ft
					ON I.intFreightTermId = ft.intFreightTermId
				LEFT JOIN tblICFobPoint fp
					ON fp.strFobPoint = ft.strFobPoint
			WHERE ID.intInvoiceId = @TransactionId 
			  AND ISNULL(ID.intInventoryShipmentItemId, 0) > 0
			  AND I.[strType] <> 'Provisional'
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
			FROM tblICInventoryShipmentItem ISHI
				INNER JOIN tblICInventoryShipment ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId
				INNER JOIN tblSOSalesOrderDetail SOD ON ISHI.intLineNo = SOD.intSalesOrderDetailId
				INNER JOIN tblSOSalesOrder SO ON SOD.intSalesOrderId = SO.intSalesOrderId
				INNER JOIN tblICItemLocation IL ON ISHI.intItemId = IL.intItemId AND SO.intCompanyLocationId = IL.intLocationId
				LEFT JOIN tblSMFreightTerms ft
					ON ISH.intFreightTermId = ft.intFreightTermId
				LEFT JOIN tblICFobPoint fp
					ON fp.strFobPoint = ft.strFobPoint
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