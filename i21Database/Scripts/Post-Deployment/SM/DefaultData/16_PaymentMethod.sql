GO
	SET IDENTITY_INSERT tblSMPaymentMethod ON

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Write Off')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strDescription], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(1, 'Write Off', 'Cancel a portion or entire invoice', NULL, NULL, NULL, 1, 0)
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strDescription = 'Cancel a portion or entire invoice' WHERE strPaymentMethod = 'Write Off'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'ACH')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strDescription], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(2, 'ACH', 'Electronically move money between bank accounts', NULL, NULL, NULL, 1, 0)
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strDescription = 'Electronically move money between bank accounts' WHERE strPaymentMethod = 'ACH'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Debit Memos and Payments')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strDescription], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(3, 'Debit Memos and Payments', 'Adjustment to the customers account', NULL, NULL, NULL, 1, 0)
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strDescription = 'Adjustment to the customers account' WHERE strPaymentMethod = 'Debit Memos and Payments'
	END

	UPDATE tblSMPaymentMethod SET strPaymentMethod = 'Manual Credit Card' WHERE (strPaymentMethod = 'Credit' OR strPaymentMethod = 'Manual CC')
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Manual Credit Card')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strDescription], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(4, 'Manual Credit Card', 'Borrow money from card issuer', NULL, NULL, NULL, 1, 0)
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strDescription = 'Borrow money from card issuer' WHERE strPaymentMethod = 'Manual Credit Card'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Refund')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strDescription], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(5, 'Refund','Reimbursement of payment', NULL, NULL, NULL, 1, 0)
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strDescription = 'Reimbursement of payment' WHERE strPaymentMethod = 'Refund'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'eCheck')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strDescription], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(6, 'eCheck', 'Electronic version of paper check', NULL, NULL, NULL, 1, 0)
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strDescription = 'Electronic version of paper check' WHERE strPaymentMethod = 'eCheck'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Check')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strDescription], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(7, 'Check', 'Draw money from a checking account', NULL, NULL, NULL, 1, 0)
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strDescription = 'Draw money from a checking account' WHERE strPaymentMethod = 'Check'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Prepay')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strDescription], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(8, 'Prepay', 'Advance payment of customer', NULL, NULL, NULL, 1, 0)
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strDescription = 'Advance payment of customer' WHERE strPaymentMethod = 'Prepay'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'CF Invoice')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strDescription], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(9, 'CF Invoice', 'Payment for Card Fueling invoice (System Generated)', NULL, NULL, NULL, 1, 0)
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strDescription = 'Payment for Card Fueling invoice (System Generated)' WHERE strPaymentMethod = 'CF Invoice'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Cash')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strDescription], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(10, 'Cash', 'Bills or coins', NULL, NULL, NULL, 1, 0)
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strDescription = 'Bills or coins' WHERE strPaymentMethod = 'Cash'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Credit Card')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strDescription], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES(11, 'Credit Card', 'Borrow money from card issuer automatically', NULL, NULL, NULL, 1, 0)
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strDescription = 'Borrow money from card issuer automatically' WHERE strPaymentMethod = 'Credit Card'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Debit Card')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strDescription], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES((SELECT IDENT_CURRENT('tblSMPaymentMethod') + 1), 'Debit Card', 'Direct deducting from a deposit account', NULL, NULL, NULL, 1, 0)
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strDescription = 'Direct deducting from a deposit account' WHERE strPaymentMethod = 'Debit Card'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Bank Transfer')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strDescription], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES((SELECT IDENT_CURRENT('tblSMPaymentMethod') + 1), 'Bank Transfer', '	Transfer money from a bank account', NULL, NULL, NULL, 1, 0)
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strDescription = 'Transfer money from a bank account' WHERE strPaymentMethod = 'Bank Transfer'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'Deduction')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strDescription], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES((SELECT IDENT_CURRENT('tblSMPaymentMethod') + 1), 'Deduction', 'Cash received for Weight Claims', NULL, NULL, NULL, 1,0 )
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strDescription = 'Cash received for Weight Claims' WHERE strPaymentMethod = 'Deduction'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = 'NSF')
	BEGIN
		INSERT INTO tblSMPaymentMethod([intPaymentMethodID], [strPaymentMethod], [strDescription], [strPaymentMethodCode], [intAccountId], [strPrintOption], [ysnActive], [intSort])
		VALUES((SELECT IDENT_CURRENT('tblSMPaymentMethod') + 1), 'NSF', 'Previous payment had an insufficient fund', NULL, NULL, NULL, 1, 0)
	END
	ELSE
	BEGIN
		UPDATE tblSMPaymentMethod SET strDescription = 'Previous payment had an insufficient fund' WHERE strPaymentMethod = 'NSF'
	END

	SET IDENTITY_INSERT tblSMPaymentMethod OFF
GO