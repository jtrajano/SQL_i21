
print('/*******************  BEGIN Update Ship Via in tblSOSalesOrder  *******************/')
GO

Update
	tblSOSalesOrder
SET
	 intShipViaId = NULL
WHERE
	intShipViaId NOT IN (SELECT [intEntityId] FROM tblSMShipVia)


GO
print('/*******************  END Update Ship Via in tblSOSalesOrder  *******************/')


print('/*******************  BEGIN Update Ship Via in tblARInvoice  *******************/')
GO

Update
	tblARInvoice
SET
	 intShipViaId = NULL
WHERE
	intShipViaId NOT IN (SELECT [intEntityId] FROM tblSMShipVia)


GO
print('/*******************  END Update Ship Via in tblARInvoice  *******************/')