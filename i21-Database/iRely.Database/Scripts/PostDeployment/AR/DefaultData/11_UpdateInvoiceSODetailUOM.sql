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


print('/*******************  BEGIN Update tblARInvoiceDetail.intOrderUOMId  *******************/')
GO

UPDATE
	tblARInvoiceDetail
SET
	intOrderUOMId = CASE WHEN ISNULL(intContractDetailId,0) <> 0
						THEN (SELECT TOP 1 intItemUOMId FROM tblCTContractDetail WHERE intContractDetailId = tblARInvoiceDetail.intContractDetailId)
						ELSE (SELECT TOP 1 intItemUOMId FROM tblSOSalesOrderDetail WHERE intSalesOrderDetailId = tblARInvoiceDetail.intSalesOrderDetailId)
					END							
WHERE
	ISNULL(intOrderUOMId,0) = 0
	AND (ISNULL(intSalesOrderDetailId,0) <> 0 OR ISNULL(intContractDetailId,0) <> 0)
	
GO
print('/*******************  END Update tblARInvoiceDetail.intOrderUOMId  *******************/')



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