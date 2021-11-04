CREATE PROCEDURE [dbo].[uspAPAddPaymentSchedules]
	@paySchedules AS PaymentSchedule READONLY,
	@error NVARCHAR(500) OUTPUT
AS

--VALIDATIONS
DECLARE @invalidPaySchedules AS TABLE(intBillId INT, strError NVARCHAR(500))

INSERT INTO @invalidPaySchedules
--INSERT THOSE PAYMENT NOT EQUAL WITH AMOUNT DUE
SELECT
	A.intBillId,
	'Payment Schedule not equal with the voucher (' + B.strBillId + ') amount due.'
FROM @paySchedules A
INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
GROUP BY A.intBillId, B.strBillId
HAVING SUM(A.dblPayment) != max(B.dblTotal)
UNION ALL
SELECT --EXCLUDE PAID
	A.intBillId,
	'Voucher (' + B.strBillId + ') is already paid.'
FROM @paySchedules A
INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
WHERE B.ysnPaid = 1

INSERT INTO tblAPVoucherPaymentSchedule
(
	intBillId,
	intTermsId,
	strPaymentScheduleNumber,
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
	strPaymentScheduleNumber,
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
