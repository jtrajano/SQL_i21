
print('/*******************  BEGIN Update Salesperson in tblARInvoice  *******************/')
GO

UPDATE
	tblARInvoice
SET
	tblARInvoice.intEntitySalespersonId = (	SELECT TOP 1 intSalespersonId FROM tblARCustomer 
											WHERE	tblARCustomer.[intEntityId] = tblARInvoice.intEntityCustomerId
													AND tblARCustomer.intSalespersonId IN (SELECT DISTINCT [intEntityId] FROM tblARSalesperson))
WHERE
	tblARInvoice.intEntitySalespersonId NOT IN (SELECT DISTINCT [intEntityId] FROM tblARSalesperson)

GO
print('/*******************  END Update Salesperson in tblARInvoice  *******************/')


print('/*******************  BEGIN Update Salesperson in tblSOSalesOrder  *******************/')
GO

UPDATE
	tblSOSalesOrder
SET
	tblSOSalesOrder.intEntitySalespersonId = (	SELECT TOP 1 intSalespersonId FROM tblARCustomer 
												WHERE	tblARCustomer.[intEntityId] = tblSOSalesOrder.intEntityCustomerId
														AND tblARCustomer.intSalespersonId IN (SELECT DISTINCT [intEntityId] FROM tblARSalesperson))
WHERE
	tblSOSalesOrder.intEntitySalespersonId NOT IN (SELECT DISTINCT [intEntityId] FROM tblARSalesperson)


GO
print('/*******************  END Update Salesperson in tblSOSalesOrder  *******************/')