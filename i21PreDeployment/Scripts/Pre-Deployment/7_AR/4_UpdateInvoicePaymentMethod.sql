print('/*******************  BEGIN Fix amounts for tblARInvoice.intEntityContactId *******************/')
GO

IF(EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARInvoice') 
	AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intPaymentMethodId' AND [object_id] = OBJECT_ID(N'tblARInvoice'))
)
BEGIN
	UPDATE 
		tblARInvoice
	SET 
		intPaymentMethodId = NULL
	WHERE
		intPaymentMethodId = 0
END

GO
print('/*******************  END Fix amounts for tblARInvoice.intEntityContactId  *******************/')