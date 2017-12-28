--THIS SCRIPT WILL UPDATE INVALID PAYMENT METHOD USED IN PAYMENT
IF(EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intPaymentMethodId' and object_id = OBJECT_ID(N'tblAPPayment'))
AND EXISTS(SELECT 1 FROM sys.columns WHERE name = N'intPaymentMethodID' and object_id = OBJECT_ID(N'tblSMPaymentMethod')))
BEGIN
	IF (EXISTS(SELECT 1 FROM tblAPPayment WHERE intPaymentMethodId NOT IN (SELECT intPaymentMethodID FROM tblSMPaymentMethod)))
	BEGIN
		UPDATE A
			SET A.intPaymentMethodId = ISNULL((SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = 'check'),
												(SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod))
		FROM tblAPPayment A
		WHERE intPaymentMethodId NOT IN (SELECT intPaymentMethodID FROM tblSMPaymentMethod)
	END
END