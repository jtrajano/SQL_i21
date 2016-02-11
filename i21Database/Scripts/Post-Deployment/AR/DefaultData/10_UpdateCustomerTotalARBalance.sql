print('/*******************  BEGIN Update NULL dblQtyShipped in tblSOSalesOrderDetail with zero  *******************/')
GO

EXEC dbo.uspARUpdateCustomerTotalAR @InvoiceId = NULL, @CustomerId = NULL

print('/*******************  END Update tblARCustomer Total AR Balance  *******************/')
GO