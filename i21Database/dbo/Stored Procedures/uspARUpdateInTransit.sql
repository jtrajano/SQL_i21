﻿CREATE PROCEDURE [dbo].[uspARUpdateInTransit]
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
				, [intTransactionTypeId])
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
			FROM tblARInvoiceDetail ID
				INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
				INNER JOIN tblICItemLocation IL ON ID.intItemId = IL.intItemId AND I.intCompanyLocationId = IL.intLocationId
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
				, [intTransactionTypeId])
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
			FROM tblICInventoryShipmentItem ISHI
				INNER JOIN tblICInventoryShipment ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId
				INNER JOIN tblSOSalesOrderDetail SOD ON ISHI.intLineNo = SOD.intSalesOrderDetailId
				INNER JOIN tblSOSalesOrder SO ON SOD.intSalesOrderId = SO.intSalesOrderId
				INNER JOIN tblICItemLocation IL ON ISHI.intItemId = IL.intItemId AND SO.intCompanyLocationId = IL.intLocationId
			WHERE ISHI.intInventoryShipmentId = @TransactionId
		END

	UPDATE @tblItemsToUpdate
	SET dblQty = dblQty * (CASE WHEN @IsShipped = 0
								THEN (CASE WHEN @Negate = 0 THEN 1 ELSE -1 END)
								ELSE (CASE WHEN @Negate = 0 THEN -1 ELSE 1 END)
							END)  

	EXEC dbo.uspICIncreaseInTransitOutBoundQty @tblItemsToUpdate
END

GO