CREATE VIEW [dbo].[vyuEMCustomerHasTransaction]
	AS 

	select intEntityCustomerId from tblARInvoice
	union 
	select intEntityCustomerId from tblSOSalesOrder