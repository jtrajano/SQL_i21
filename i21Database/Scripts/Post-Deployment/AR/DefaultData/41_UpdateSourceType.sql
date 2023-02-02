PRINT('/*******************  BEGIN Update Source Type *******************/')
GO
	UPDATE tblARInvoice
	SET strType = 'Store End of Day'
	WHERE strType = 'Store Checkout'
GO
PRINT('/*******************  END Update Source Type ********************/')