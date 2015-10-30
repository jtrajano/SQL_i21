GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'ACH')
	BEGIN
		INSERT INTO tblSMPaymentMethod([strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES('ACH', NULL, 0, NULL, 1, 0)
	END
GO