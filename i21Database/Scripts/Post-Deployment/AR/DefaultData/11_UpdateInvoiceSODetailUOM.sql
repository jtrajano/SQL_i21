print('/*******************  BEGIN Update tblARInvoiceDetail.intItemUOMId  *******************/')
GO

UPDATE
	tblARInvoiceDetail
SET
	tblARInvoiceDetail.intItemUOMId = ICIU.intItemUOMId
FROM
	tblARInvoiceDetail ARID
INNER JOIN
	tblICItem ICI
		ON ARID.intItemId = ICI.intItemId
INNER JOIN
	tblICItemUOM ICIU
		ON ICI.intItemId = ICIU.intItemId
		AND ICIU.ysnStockUnit = 1
WHERE
	ISNULL(ARID.intItemUOMId, 0) = 0
	
GO
print('/*******************  END Update tblARInvoiceDetail.intItemUOMId  *******************/')



print('/*******************  BEGIN Update tblSOSalesOrderDetail.intItemUOMId  *******************/')
GO

UPDATE
	tblSOSalesOrderDetail
SET
	tblSOSalesOrderDetail.intItemUOMId = ICIU.intItemUOMId
FROM
	tblSOSalesOrderDetail SOID
INNER JOIN
	tblICItem ICI
		ON SOID.intItemId = ICI.intItemId
INNER JOIN
	tblICItemUOM ICIU
		ON ICI.intItemId = ICIU.intItemId
		AND ICIU.ysnStockUnit = 1
WHERE
	ISNULL(SOID.intItemUOMId, 0) = 0
	
GO
print('/*******************  END Update tblSOSalesOrderDetail.intItemUOMId  *******************/')