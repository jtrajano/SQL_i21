print('/*******************  BEGIN Update tblICItemStock.dblOrderCommitted  *******************/')
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
		FROM (SELECT SOD.intItemId
					, SO.intCompanyLocationId			 
					, dblCommitted = SUM(dbo.fnICConvertUOMtoStockUnit(SOD.intItemId, SOD.intItemUOMId, SOD.dblQtyOrdered)) 
									- ISNULL(SUM(dbo.fnICConvertUOMtoStockUnit(ID.intItemId, ID.intItemUOMId, ID.dblQtyShipped)), 0)
									- ISNULL(SUM(dbo.fnICConvertUOMtoStockUnit(ISHI.intItemId, ISHI.intItemUOMId, ISHI.dblQuantity)), 0)
			FROM tblSOSalesOrderDetail SOD INNER JOIN tblSOSalesOrder SO 
					ON SOD.intSalesOrderId = SO.intSalesOrderId
				LEFT JOIN (tblARInvoiceDetail ID INNER JOIN tblARInvoice I 
								ON ID.intInvoiceId = I.intInvoiceId 
								AND I.ysnPosted = 1
								AND ID.intSalesOrderDetailId NOT IN (SELECT ISHI.intLineNo FROM tblICInventoryShipmentItem ISHI
												INNER JOIN tblICInventoryShipment ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId
											WHERE dbo.fnIsStockTrackingItem(ISHI.intItemId) = 1
												AND ISH.ysnPosted = 1
												AND ISNULL(ISHI.intLineNo, 0) > 0))
					ON SOD.intSalesOrderDetailId = ID.intSalesOrderDetailId
				LEFT JOIN (tblICInventoryShipmentItem ISHI INNER JOIN tblICInventoryShipment ISH 
								ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId AND ISH.ysnPosted = 1) 
					ON SOD.intSalesOrderDetailId = ISHI.intLineNo
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
			GROUP BY ID.intItemId, I.intCompanyLocationId) TBL
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
	SELECT SO.intItemId
		 , IIL.intItemLocationId
		 , SO.intSubLocationId
		 , SO.intStorageLocationId
		 , CASE WHEN SO.dblCommitted < 0 THEN 0 ELSE SO.dblCommitted END dblCommitted
	FROM (
		SELECT intItemId
			 , intCompanyLocationId
			 , intSubLocationId
			 , intStorageLocationId
			 , dblCommitted = SUM(ISNULL(dblCommitted, 0))
		FROM (SELECT SOD.intItemId
				   , SO.intCompanyLocationId
				   , SOD.intSubLocationId
			 	   , SOD.intStorageLocationId
				   , dblCommitted = SUM(dbo.fnICConvertUOMtoStockUnit(SOD.intItemId, SOD.intItemUOMId, SOD.dblQtyOrdered)) 
									- ISNULL(SUM(dbo.fnICConvertUOMtoStockUnit(ID.intItemId, ID.intItemUOMId, ID.dblQtyShipped)), 0)
									- ISNULL(SUM(dbo.fnICConvertUOMtoStockUnit(ISHI.intItemId, ISHI.intItemUOMId, ISHI.dblQuantity)), 0)
			FROM tblSOSalesOrderDetail SOD INNER JOIN tblSOSalesOrder SO 
					ON SOD.intSalesOrderId = SO.intSalesOrderId
				LEFT JOIN (tblARInvoiceDetail ID INNER JOIN tblARInvoice I 
								ON ID.intInvoiceId = I.intInvoiceId 
								AND I.ysnPosted = 1
								AND ID.intSalesOrderDetailId NOT IN (SELECT ISHI.intLineNo FROM tblICInventoryShipmentItem ISHI
												INNER JOIN tblICInventoryShipment ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId
											WHERE dbo.fnIsStockTrackingItem(ISHI.intItemId) = 1
												AND ISH.ysnPosted = 1
												AND ISNULL(ISHI.intLineNo, 0) > 0))
					ON SOD.intSalesOrderDetailId = ID.intSalesOrderDetailId
				LEFT JOIN (tblICInventoryShipmentItem ISHI INNER JOIN tblICInventoryShipment ISH 
								ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId AND ISH.ysnPosted = 1) 
					ON SOD.intSalesOrderDetailId = ISHI.intLineNo
			WHERE dbo.fnIsStockTrackingItem(SOD.intItemId) = 1		  
				AND SO.strTransactionType = 'Order'
			GROUP BY SOD.intItemId, SO.intCompanyLocationId, SOD.intSubLocationId, SOD.intStorageLocationId

			UNION ALL

			SELECT ID.intItemId
				 , I.intCompanyLocationId
				 , ID.intSubLocationId
				 , ID.intStorageLocationId
				 , dblCommitted = SUM(dbo.fnICConvertUOMtoStockUnit(ID.intItemId, ID.intItemUOMId, ID.dblQtyShipped))
			FROM tblARInvoiceDetail ID
				INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
			WHERE dbo.fnIsStockTrackingItem(ID.intItemId) = 1
				AND I.ysnPosted = 0
				AND I.strTransactionType NOT IN ('Service Charge', 'Credit Memo')
				AND ISNULL(ID.intInventoryShipmentItemId, 0) = 0
				AND ISNULL(ID.intSalesOrderDetailId, 0) = 0
			GROUP BY ID.intItemId, I.intCompanyLocationId, ID.intSubLocationId, ID.intStorageLocationId) TBL
		GROUP BY intItemId, intCompanyLocationId, intSubLocationId, intStorageLocationId
	) AS SO
	LEFT JOIN tblICItemLocation IIL ON SO.intItemId = IIL.intItemId AND SO.intCompanyLocationId = IIL.intLocationId
) SALES
WHERE tblICItemStockUOM.intItemId = SALES.intItemId
  AND tblICItemStockUOM.intItemLocationId = SALES.intItemLocationId
  AND ISNULL(tblICItemStockUOM.intSubLocationId, 0) = ISNULL(SALES.intSubLocationId, 0)
  AND ISNULL(tblICItemStockUOM.intStorageLocationId, 0) = ISNULL(SALES.intStorageLocationId, 0)
  	
GO
print('/*******************  END Update tblICItemStockUOM.dblOrderCommitted  *******************/')