
--Make sure column already exists
IF EXISTS(SELECT * FROM sys.columns WHERE [name] = N'intVendorId' AND [object_id] = OBJECT_ID(N'tblAPPayment'))
BEGIN
	EXEC('
		IF EXISTS(SELECT  * FROM tblAPPayment WHERE NOT EXISTS(SELECT * FROM tblAPVendor WHERE intVendorId = tblAPPayment.intVendorId))
		BEGIN

			--Delete payment without vendor id and unposted to work with additional foreign key
			DELETE FROM tblAPPayment
			WHERE ISNULL(intVendorId, 0) = 0 AND ysnPosted = 0

			UPDATE A
				SET A.intVendorId = C.intVendorId
			FROM tblAPPayment A
				INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = (SELECT TOP 1 intPaymentId FROM tblAPPaymentDetail WHERE tblAPPaymentDetail.intPaymentId = A.intPaymentId)
				INNER JOIN tblAPBill C ON B.intBillId = (SELECT TOP 1 intBillId FROM tblAPBill WHERE  tblAPBill.intBillId = B.intBillId)
			WHERE EXISTS(
				SELECT  * FROM tblAPPayment Payments
					WHERE NOT EXISTS(SELECT * FROM tblAPVendor WHERE intVendorId = Payments.intVendorId)
					AND A.intPaymentId = Payments.intPaymentId
			)
		END
	');
END