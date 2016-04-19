print('/*******************  BEGIN Update tblSOSalesOrder Quote Order *******************/')
GO

UPDATE tblSOSalesOrder 
	SET strQuoteType = 'Price Quantity' 
WHERE ISNULL(strQuoteType , '') = '' 
  AND ysnQuote = 1
  AND strTransactionType = 'Quote'

GO
print('/*******************  END Update tblSOSalesOrder Quote Order  *******************/')