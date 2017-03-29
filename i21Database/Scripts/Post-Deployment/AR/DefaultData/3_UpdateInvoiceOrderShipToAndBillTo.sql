---------------------------------------------------------
-- IMPORTANT NOTE: REMOVE THIS SCRIPT ON 1530
-- Purpose: To Set Invoice/Order Ship To and Bill to Location 
---------------------------------------------------------
print('/*******************  BEGIN Update Ship To Location in tblSOSalesOrder  *******************/')
GO

Update
	tblSOSalesOrder
SET
	 intShipToLocationId = (CASE WHEN C.intShipToId IS NULL OR C.intShipToId = 0 THEN C.intDefaultLocationId ELSE C.intShipToId END)
FROM
	tblSOSalesOrder SO
INNER JOIN
	tblARCustomer C
		ON SO.intEntityCustomerId = C.[intEntityId] 
WHERE
	intSalesOrderId = SO.intSalesOrderId 
	AND (intShipToLocationId IS NULL OR intShipToLocationId = 0)


GO
print('/*******************  END Update Ship To Location in tblSOSalesOrder  *******************/')

print('/*******************  BEGIN Update Bill To Location in tblSOSalesOrder  *******************/')
GO

Update
	tblSOSalesOrder
SET
	 intBillToLocationId = (CASE WHEN C.intBillToId IS NULL OR C.intBillToId = 0 THEN C.intDefaultLocationId ELSE C.intBillToId END)
FROM
	tblSOSalesOrder SO
INNER JOIN
	tblARCustomer C
		ON SO.intEntityCustomerId = C.[intEntityId] 
WHERE
	intSalesOrderId = SO.intSalesOrderId 
	AND (intBillToLocationId IS NULL OR intBillToLocationId = 0)


GO
print('/*******************  END Update Bill To Location in tblSOSalesOrder  *******************/')

print('/*******************  BEGIN Update Ship To Location in tblARInvoice  *******************/')
GO

Update
	tblARInvoice
SET
	 intShipToLocationId = (CASE WHEN C.intShipToId IS NULL OR C.intShipToId = 0 THEN C.intDefaultLocationId ELSE C.intShipToId END)
FROM
	tblARInvoice I
INNER JOIN
	tblARCustomer C
		ON I.intEntityCustomerId = C.[intEntityId] 
WHERE
	intInvoiceId = I.intInvoiceId 
	AND (intShipToLocationId IS NULL OR intShipToLocationId = 0)


GO
print('/*******************  END Update Ship To Location in tblARInvoice  *******************/')

print('/*******************  BEGIN Update Bill To Location in tblARInvoice  *******************/')
GO

Update
	tblARInvoice
SET
	 intBillToLocationId = (CASE WHEN C.intBillToId IS NULL OR C.intBillToId = 0 THEN C.intDefaultLocationId ELSE C.intBillToId END)
FROM
	tblARInvoice I
INNER JOIN
	tblARCustomer C
		ON I.intEntityCustomerId = C.[intEntityId] 
WHERE
	intInvoiceId = I.intInvoiceId 
	AND (intBillToLocationId IS NULL OR intBillToLocationId = 0)


GO
print('/*******************  END Update Bill To Location in tblARInvoice  *******************/')