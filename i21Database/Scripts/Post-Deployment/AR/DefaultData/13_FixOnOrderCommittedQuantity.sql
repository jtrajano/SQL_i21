﻿print('/*******************  BEGIN Update tblICItemStock.dblOrderCommitted  *******************/')
GO

UPDATE tblICItemStock SET dblOrderCommitted = 0

UPDATE tblICItemStock 
SET dblOrderCommitted = ISNULL(SALES.dblCommitted, 0)
FROM (
	SELECT SO.intItemId
		 , IIL.intItemLocationId
		 , CASE WHEN SO.dblCommitted < 0 THEN 0 ELSE SO.dblCommitted END dblCommitted
	FROM (
		SELECT intItemId
			 , intCompanyLocationId
			 , dblCommitted = SUM(ISNULL(dblCommitted, 0))
		FROM (
			SELECT SOD.intItemId
				 , SO.intCompanyLocationId		
				 , dblCommitted = SUM(dbo.fnICConvertUOMtoStockUnit(SOD.intItemId, SOD.intItemUOMId, SOD.dblQtyOrdered) - ISNULL(ID.dblQtyShipped, 0) - ISNULL(ISHI.dblQuantity, 0))
			FROM tblSOSalesOrderDetail SOD 
			INNER JOIN tblSOSalesOrder SO ON SOD.intSalesOrderId = SO.intSalesOrderId
			LEFT JOIN (
				SELECT ID.intSalesOrderDetailId
					 , dblQtyShipped = dbo.fnICConvertUOMtoStockUnit(ID.intItemId, ID.intItemUOMId, ID.dblQtyShipped)
				FROM tblARInvoiceDetail ID 
				INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
				LEFT JOIN (
					SELECT ISHI.intLineNo 
					FROM tblICInventoryShipmentItem ISHI
					INNER JOIN tblICInventoryShipment ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId
					WHERE dbo.fnIsStockTrackingItem(ISHI.intItemId) = 1
					  AND ISH.ysnPosted = 1
					  AND ISNULL(ISHI.intLineNo, 0) > 0
				) SHIP ON ID.intSalesOrderDetailId = SHIP.intLineNo
				WHERE I.ysnPosted = 1
					AND ISNULL(SHIP.intLineNo, 0) = 0
			) ID ON SOD.intSalesOrderDetailId = ID.intSalesOrderDetailId
			LEFT JOIN (
				SELECT intLineNo
					 , dblQuantity = dbo.fnICConvertUOMtoStockUnit(ISHI.intItemId, ISHI.intItemUOMId, ISHI.dblQuantity)
				FROM tblICInventoryShipmentItem ISHI 
				INNER JOIN tblICInventoryShipment ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId 
				WHERE ISH.ysnPosted = 1
			) ISHI ON SOD.intSalesOrderDetailId = ISHI.intLineNo
			WHERE dbo.fnIsStockTrackingItem(SOD.intItemId) = 1		  
			  AND SO.strTransactionType = 'Order'
			GROUP BY SOD.intItemId, SO.intCompanyLocationId

			UNION ALL

            SELECT ID.intItemId
                    , I.intCompanyLocationId
                    , dblCommitted = SUM(dbo.fnICConvertUOMtoStockUnit(ID.intItemId, ID.intItemUOMId, ID.dblQtyShipped))
            FROM tblARInvoiceDetail ID
                INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
            WHERE dbo.fnIsStockTrackingItem(ID.intItemId) = 1
                AND I.ysnPosted = 0
                AND I.strTransactionType NOT IN ('Service Charge', 'Credit Memo')
                AND ISNULL(ID.intInventoryShipmentItemId, 0) = 0
                AND ISNULL(ID.intSalesOrderDetailId, 0) = 0
            GROUP BY ID.intItemId, I.intCompanyLocationId
		) TBL
		GROUP BY intItemId, intCompanyLocationId
	) AS SO
	LEFT JOIN tblICItemLocation IIL ON SO.intItemId = IIL.intItemId AND SO.intCompanyLocationId = IIL.intLocationId
) SALES
WHERE tblICItemStock.intItemId = SALES.intItemId
  AND tblICItemStock.intItemLocationId = SALES.intItemLocationId


GO
print('/*******************  END Update tblICItemStock.dblOrderCommitted  *******************/')


print('/*******************  BEGIN Update tblICItemStockUOM.dblOrderCommitted  *******************/')
GO

UPDATE tblICItemStockUOM SET dblOrderCommitted = 0

UPDATE tblICItemStockUOM 
SET dblOrderCommitted = ISNULL(SALES.dblCommitted, 0)
FROM (
	SELECT intItemId			= SO.intItemId
		 , intItemLocationId	= IIL.intItemLocationId		 
		 , intStorageLocationId	= SO.intStorageLocationId
		 , intSubLocationId		= SO.intSubLocationId
		 , dblCommitted			= CASE WHEN SO.dblCommitted < 0 THEN 0 ELSE SO.dblCommitted END
	FROM (
		SELECT intItemId			= TBL.intItemId
			 , intCompanyLocationId	= TBL.intCompanyLocationId
			 , intStorageLocationId	= TBL.intStorageLocationId
		 	 , intSubLocationId		= TBL.intSubLocationId
			 , dblCommitted 		= SUM(ISNULL(dblCommitted, 0))
		FROM (
			SELECT intItemId			= SOD.intItemId
				 , intCompanyLocationId	= SO.intCompanyLocationId		
				 , intStorageLocationId	= SOD.intStorageLocationId
				 , intSubLocationId		= SOD.intSubLocationId	
				 , dblCommitted = SUM(dbo.fnICConvertUOMtoStockUnit(SOD.intItemId, SOD.intItemUOMId, SOD.dblQtyOrdered) - ISNULL(ID.dblQtyShipped, 0) - ISNULL(ISHI.dblQuantity, 0))
			FROM tblSOSalesOrderDetail SOD 
			INNER JOIN tblSOSalesOrder SO ON SOD.intSalesOrderId = SO.intSalesOrderId
			LEFT JOIN (
				SELECT ID.intSalesOrderDetailId
					 , dblQtyShipped = dbo.fnICConvertUOMtoStockUnit(ID.intItemId, ID.intItemUOMId, ID.dblQtyShipped)
				FROM tblARInvoiceDetail ID 
				INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
				LEFT JOIN (
					SELECT ISHI.intLineNo 
					FROM tblICInventoryShipmentItem ISHI
					INNER JOIN tblICInventoryShipment ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId
					WHERE dbo.fnIsStockTrackingItem(ISHI.intItemId) = 1
					  AND ISH.ysnPosted = 1
					  AND ISNULL(ISHI.intLineNo, 0) > 0
				) SHIP ON ID.intSalesOrderDetailId = SHIP.intLineNo
				WHERE I.ysnPosted = 1
					AND ISNULL(SHIP.intLineNo, 0) = 0
			) ID ON SOD.intSalesOrderDetailId = ID.intSalesOrderDetailId
			LEFT JOIN (
				SELECT intLineNo
					 , dblQuantity = dbo.fnICConvertUOMtoStockUnit(ISHI.intItemId, ISHI.intItemUOMId, ISHI.dblQuantity)
				FROM tblICInventoryShipmentItem ISHI 
				INNER JOIN tblICInventoryShipment ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId 
				WHERE ISH.ysnPosted = 1
			) ISHI ON SOD.intSalesOrderDetailId = ISHI.intLineNo
			WHERE dbo.fnIsStockTrackingItem(SOD.intItemId) = 1		  
			  AND SO.strTransactionType = 'Order'
			GROUP BY SOD.intItemId, SO.intCompanyLocationId, SOD.intStorageLocationId, SOD.intSubLocationId

			UNION ALL

            SELECT intItemId			= ID.intItemId
                 , intCompanyLocationId	= I.intCompanyLocationId
				 , intStorageLocationId	= ID.intStorageLocationId
				 , intSubLocationId		= ID.intSubLocationId
                 , dblCommitted 		= SUM(dbo.fnICConvertUOMtoStockUnit(ID.intItemId, ID.intItemUOMId, ID.dblQtyShipped))
            FROM tblARInvoiceDetail ID
                INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
            WHERE dbo.fnIsStockTrackingItem(ID.intItemId) = 1
                AND I.ysnPosted = 0
                AND I.strTransactionType NOT IN ('Service Charge', 'Credit Memo')
                AND ISNULL(ID.intInventoryShipmentItemId, 0) = 0
                AND ISNULL(ID.intSalesOrderDetailId, 0) = 0
            GROUP BY ID.intItemId, I.intCompanyLocationId, ID.intStorageLocationId, ID.intSubLocationId
		) TBL
		GROUP BY intItemId, intCompanyLocationId, intStorageLocationId, intSubLocationId
	) AS SO
	LEFT JOIN tblICItemLocation IIL ON SO.intItemId = IIL.intItemId AND SO.intCompanyLocationId = IIL.intLocationId
) SALES
WHERE tblICItemStockUOM.intItemId = SALES.intItemId
  AND tblICItemStockUOM.intItemLocationId = SALES.intItemLocationId
  AND ISNULL(tblICItemStockUOM.intStorageLocationId, 0) = ISNULL(SALES.intStorageLocationId, 0)
  AND ISNULL(tblICItemStockUOM.intSubLocationId, 0) = ISNULL(SALES.intSubLocationId, 0)
  	
GO
print('/*******************  END Update tblICItemStockUOM.dblOrderCommitted  *******************/')