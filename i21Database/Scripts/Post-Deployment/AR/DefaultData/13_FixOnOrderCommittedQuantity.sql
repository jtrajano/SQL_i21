print('/*******************  BEGIN Update tblICItemStock.dblOrderCommitted  *******************/')
GO

UPDATE tblICItemStock 
SET dblOrderCommitted = SALES.dblCommitted
FROM (
	SELECT SO.intItemId
		 , IIL.intItemLocationId
		 , SO.dblCommitted 
	FROM (
		SELECT SOD.intItemId
			 , SO.intCompanyLocationId			 
			 , dblCommitted = SUM(dbo.fnICConvertUOMtoStockUnit(SOD.intItemId, SOD.intItemUOMId, SOD.dblQtyOrdered)) - SUM(dbo.fnICConvertUOMtoStockUnit(SOD.intItemId, SOD.intItemUOMId, SOD.dblQtyShipped))
		FROM tblSOSalesOrderDetail SOD
			INNER JOIN tblSOSalesOrder SO ON SOD.intSalesOrderId = SO.intSalesOrderId
			LEFT JOIN (tblARInvoiceDetail ID INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId)
				ON SOD.intSalesOrderDetailId = ID.intSalesOrderDetailId
			LEFT JOIN (tblICInventoryShipmentItem ISHI INNER JOIN tblICInventoryShipment ISH ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId) 
				ON SOD.intSalesOrderDetailId = ISHI.intLineNo
		WHERE dbo.fnIsStockTrackingItem(SOD.intItemId) = 1
		AND ISNULL(ISH.ysnPosted, 0) = 0
		AND SO.strOrderStatus IN ('Open', 'Pending', 'Partial')
		AND SO.strTransactionType = 'Order'
		AND SOD.dblQtyOrdered - SOD.dblQtyShipped > 0
		GROUP BY SOD.intItemId, SO.intCompanyLocationId
	) AS SO
	LEFT JOIN tblICItemLocation IIL ON SO.intItemId = IIL.intItemId AND SO.intCompanyLocationId = IIL.intLocationId
) SALES
WHERE tblICItemStock.intItemId = SALES.intItemId
  AND tblICItemStock.intItemLocationId = SALES.intItemLocationId
  	
GO
print('/*******************  END Update tblICItemStock.dblOrderCommitted  *******************/')