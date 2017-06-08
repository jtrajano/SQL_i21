print('/*******************  BEGIN Update tblARCustomer Total AR Balance  *******************/')
GO

EXEC dbo.uspARUpdateCustomerTotalAR

print('/*******************  END Update tblARCustomer Total AR Balance  *******************/')
GO