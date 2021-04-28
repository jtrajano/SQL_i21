﻿CREATE PROCEDURE [dbo].[uspAPAddPaymentSchedules]
	@paySchedules AS PaymentSchedule,
	@error NVARCHAR(500) OUTPUT
AS

--VALIDATIONS
DECLARE @invalidPaySchedules AS TABLE(intBillId INT, strError NVARCHAR(500))

INSERT INTO @invalidPaySchedules
--INSERT THOSE PAYMENT NOT EQUAL WITH AMOUNT DUE
SELECT
	A.inBillId,
	'Payment Schedule not equal with the voucher (' + B.strBillId + ') amount due.'
FROM @invalidPaySchedules A
INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
GROUP BY A.intBillId
HAVING SUM(A.dblPayment) != B.dblTotal
UNION ALL
SELECT --EXCLUDE PAID
	A.inBillId,
	'Voucher (' + B.strBillId + ') is already paid.'
FROM @invalidPaySchedules A
INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
WHERE B.ysnPaid = 1

INSERT INTO tblAPVoucherPaymentSchedule
(
	intBillId,
	intTermsId,
	dtmDueDate,
	dtmDiscountDate,
	dblPayment,
	dblDiscount,
	ysnPaid,
	ysnScheduleDiscountOverride
)
SELECT
	intBillId,
	intTermsId,
	dtmDueDate,
	dtmDiscountDate,
	dblPayment,
	dblDiscount,
	ysnPaid,
	ysnScheduleDiscountOverride
FROM @paySchedules A
WHERE A.intBillId NOT IN (SELECT intBillId FROM @invalidPaySchedules)

SELECT TOP 1 
	@error = strError
FROM @invalidPaySchedules
