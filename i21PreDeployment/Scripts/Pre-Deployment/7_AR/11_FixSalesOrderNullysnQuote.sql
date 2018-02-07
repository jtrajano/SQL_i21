PRINT '********************** BEGIN updating null ysnQuote For SalesOrder - Quote Type **********************'
GO
IF EXISTS(SELECT NULL FROM tblSOSalesOrder WHERE ysnQuote IS NULL)	
	BEGIN
		UPDATE tblSOSalesOrder 
		SET ysnQuote = CASE WHEN (strType = 'Standard - Quote' OR strType = 'Software - Quote') THEN 1 ELSE 0 END
		WHERE ysnQuote IS NULL
	END
GO
PRINT ' ********************** END updating null ysnQuote For SalesOrder - Quote Type **********************'