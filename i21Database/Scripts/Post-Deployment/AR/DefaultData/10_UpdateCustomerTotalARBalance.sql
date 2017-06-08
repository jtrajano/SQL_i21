print('/*******************  BEGIN Update NULL dblQtyShipped in tblSOSalesOrderDetail with zero  *******************/')
GO

EXEC dbo.uspARUpdateCustomerTotalAR

print('/*******************  END Update tblARCustomer Total AR Balance  *******************/')
GO