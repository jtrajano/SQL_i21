--THIS WILL UPDATE EXISTING tblAPPayment records
--IT WILL ONLY UPDATE THE UNPOSTED
--IF PAY TO ADDRESS IS DISTINCT WE WILL SET IT BY DEFAULT
IF OBJECT_ID('tblAPPayment') IS NOT NULL AND COL_LENGTH('tblAPPayment','intPayToAddressId') IS NULL
BEGIN

	EXEC ('
	ALTER TABLE tblAPPayment
		ADD intPayToAddressId INT NULL
	')
	EXEC ('
	UPDATE payment
		SET payment.intPayToAddressId = details.intPayToAddressId
	FROM tblAPPayment payment
	CROSS APPLY (
		SELECT 
			DISTINCT intPayToAddressId
		FROM tblAPPaymentDetail B
		INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
		CROSS APPLY (
			SELECT COUNT(DISTINCT intPayToAddressId) intTotal
			FROM tblAPPaymentDetail D
			INNER JOIN tblAPBill E ON D.intBillId = E.intBillId
			WHERE D.intPaymentId = B.intPaymentId
		) recordCount
		WHERE recordCount.intTotal = 1 AND B.intPaymentId = payment.intPaymentId
	) details
	WHERE payment.ysnPosted = 0
	')
END