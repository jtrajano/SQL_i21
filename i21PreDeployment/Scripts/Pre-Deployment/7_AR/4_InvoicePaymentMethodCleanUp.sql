IF(EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARInvoice') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intPaymentMethodId' AND [object_id] = OBJECT_ID(N'tblARInvoice'))
			AND EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblSMPaymentMethod') AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intPaymentMethodID' AND [object_id] = OBJECT_ID(N'tblSMPaymentMethod')))
BEGIN
	UPDATE
		tblARInvoice
	SET
		intPaymentMethodId = NULL
	WHERE
		intPaymentMethodId NOT IN (SELECT intPaymentMethodID FROM tblSMPaymentMethod)
END