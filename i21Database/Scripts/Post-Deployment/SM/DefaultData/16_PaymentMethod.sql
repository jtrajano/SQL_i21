GO
	SET IDENTITY_INSERT tblSMPaymentMethod ON

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Write Off')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(1, 'Write Off', NULL, NULL, NULL, 1, 0)
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strPaymentMethod = 'Write Off' WHERE strPaymentMethod = 'Write Off'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'ACH')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(2, 'ACH', NULL, NULL, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Debit Memos and Payments')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(3, 'Debit Memos and Payments', NULL, NULL, NULL, 1, 0)
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strPaymentMethod = 'Debit Memos and Payments' WHERE strPaymentMethod = 'Debit Memos and Payments'
	END

	UPDATE tblSMPaymentMethod SET strPaymentMethod = 'Manual Credit Card' WHERE (strPaymentMethod = 'Credit' OR strPaymentMethod = 'Manual CC')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Manual Credit Card')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(4, 'Manual Credit Card', NULL, NULL, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Refund')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(5, 'Refund', NULL, NULL, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'eCheck')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(6, 'eCheck', NULL, NULL, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Check')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(7, 'Check', NULL, NULL, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Prepay')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(8, 'Prepay', NULL, NULL, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'CF Invoice')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(9, 'CF Invoice', NULL, NULL, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Cash')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(10, 'Cash', NULL, NULL, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Credit Card')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(11, 'Credit Card', NULL, NULL, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Bank Transfer')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES((SELECT IDENT_CURRENT('tblSMPaymentMethod') + 1), 'Bank Transfer', NULL, NULL, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Deduction')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES((SELECT IDENT_CURRENT('tblSMPaymentMethod') + 1), 'Deduction', NULL, NULL, NULL, 1,0 )
	END

	SET IDENTITY_INSERT tblSMPaymentMethod OFF
GO