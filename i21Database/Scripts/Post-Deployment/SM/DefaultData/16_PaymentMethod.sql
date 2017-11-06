﻿GO
	SET IDENTITY_INSERT tblSMPaymentMethod ON

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Write Off')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(1, 'Write Off', NULL, NULL, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'ACH')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(2, 'ACH', NULL, NULL, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Debit memos and Payments')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(3, 'Debit memos and Payments', NULL, NULL, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Credit')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(4, 'Credit', NULL, NULL, NULL, 1, 0)
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

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Cash Receipt')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(12, 'Cash Receipt', NULL, NULL, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Vendor Refund')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(13, 'Vendor Refund', NULL, NULL, NULL, 1, 0)
	END

	SET IDENTITY_INSERT tblSMPaymentMethod OFF
GO