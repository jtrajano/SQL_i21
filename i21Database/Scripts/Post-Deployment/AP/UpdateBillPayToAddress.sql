--THIS WILL UPDATE EXISTING VOUCHER'S PAY TO ADDRESS
GO
IF (EXISTS(SELECT 1 FROM tblAPBill WHERE dblPayment = 0 AND intPayToAddressId IS NULL AND ysnPaid = 0))
BEGIN
	UPDATE A
		SET A.intPayToAddressId = A.intShipFromId
	FROM tblAPBill A
	WHERE A.dblPayment = 0 AND intPayToAddressId IS NULL AND ysnPaid = 0
END
GO