PRINT('/*******************  BEGIN Update Sales Order Quote Types *******************/')
GO
	UPDATE tblSOSalesOrder
	SET strType = strType + ' - Quote'
	WHERE ysnQuote = 1 
	AND strType NOT IN('Standard - Quote','Software - Quote')
GO
PRINT('/*******************  END Update Sales Order Quote Types *******************/')