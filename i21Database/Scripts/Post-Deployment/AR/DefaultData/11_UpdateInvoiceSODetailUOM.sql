print('/*******************  BEGIN Update tblARInvoiceDetail.intItemUOMId  *******************/')
GO

UPDATE
	tblARInvoiceDetail
SET
	tblARInvoiceDetail.intItemUOMId = (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId = ARID.intItemId ORDER BY ISNULL(ysnStockUnit,0) DESC, intItemUOMId)
FROM
	tblARInvoiceDetail ARID
INNER JOIN
	tblICItem ICI
		ON ARID.intItemId = ICI.intItemId
WHERE
	ISNULL(ARID.intItemUOMId, 0) = 0
	
GO
print('/*******************  END Update tblARInvoiceDetail.intItemUOMId  *******************/')



print('/*******************  BEGIN Update tblSOSalesOrderDetail.intItemUOMId  *******************/')
GO

UPDATE
	tblSOSalesOrderDetail
SET
	tblSOSalesOrderDetail.intItemUOMId = (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId = SOID.intItemId ORDER BY ISNULL(ysnStockUnit,0) DESC, intItemUOMId)
FROM
	tblSOSalesOrderDetail SOID
INNER JOIN
	tblICItem ICI
		ON SOID.intItemId = ICI.intItemId
WHERE
	ISNULL(SOID.intItemUOMId, 0) = 0
	
GO
print('/*******************  END Update tblSOSalesOrderDetail.intItemUOMId  *******************/')