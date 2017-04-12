print('/*******************  BEGIN Update tblARCustomer Total AR Balance *******************/')
GO

EXEC dbo.uspARUpdateCustomerTotalAR @InvoiceId = NULL, @CustomerId = NULL

print('/*******************  END Update tblARCustomer Total AR Balance  *******************/')
GO