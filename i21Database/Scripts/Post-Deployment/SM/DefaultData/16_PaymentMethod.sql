﻿GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Write Off')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(1, 'Write Off', NULL, 0, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'ACH')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(2, 'ACH', NULL, 0, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Debit memos and Payments')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(3, 'Debit memos and Payments', NULL, 0, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Credit')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(4, 'Credit', NULL, 0, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Refund')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(5, 'Refund', NULL, 0, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'eCheck')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(6, 'eCheck', NULL, 0, NULL, 1, 0)
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Check')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(7, 'Check', NULL, 0, NULL, 1, 0)
	END
GO