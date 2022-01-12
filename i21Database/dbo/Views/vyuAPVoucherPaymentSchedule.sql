CREATE VIEW [dbo].[vyuAPVoucherPaymentSchedule]

AS

SELECT
	S.intId,
	CASE B.intTransactionType
		 WHEN 1 THEN 'Voucher'
		 WHEN 2 THEN 'Vendor Prepayment'
		 WHEN 3 THEN 'Debit Memo'
		 WHEN 7 THEN 'Invalid Type'
		 WHEN 9 THEN '1099 Adjustment'
		 WHEN 11 THEN 'Claim'
		 WHEN 12 THEN 'Prepayment Reversal'
		 WHEN 13 THEN 'Basis Advance'
		 WHEN 14 THEN 'Deferred Interest'
		 ELSE 'Invalid Type'
	END COLLATE Latin1_General_CI_AS AS strTransactionType,
	B.intBillId,
	B.intShipToId,
	B.intEntityVendorId,
	E.strName, 													--intEntityVendorId
	B.strVendorOrderNumber,
	B.dtmBillDate,
	T.strTerm,
	S.strPaymentScheduleNumber,
	B.dtmDueDate,
	E2.strName AS strFromEntityName, 							--intShipFromEntityId
	L.strLocationName, 											--intStoreLocationId
	B.strBillId,
	A.strAccountId,
	T2.strTerm AS strScheduleTerm,
	S.dtmDueDate AS dtmScheduleDueDate,
	S.dtmDiscountDate AS dtmScheduleDiscountDate,
	S.ysnScheduleDiscountOverride,
	S.dblDiscount AS dblScheduleDiscount,
	S.dblPayment AS dblSchedulePayment,
	S.ysnPaid AS ysnSchedulePaid
FROM tblAPBill B
INNER JOIN (tblAPVendor V INNER JOIN tblEMEntity E ON E.intEntityId = V.intEntityId) ON V.intEntityId = B.intEntityVendorId
INNER JOIN tblSMTerm T ON T.intTermID = B.intTermsId
INNER JOIN (tblAPVendor V2 INNER JOIN tblEMEntity E2 ON E2.intEntityId = V2.intEntityId) ON V2.intEntityId = B.intShipFromEntityId
INNER JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = B.intStoreLocationId
INNER JOIN tblGLAccount A ON A.intAccountId = B.intAccountId
INNER JOIN tblAPVoucherPaymentSchedule S ON S.intBillId = B.intBillId
INNER JOIN tblSMTerm T2 ON T2.intTermID = S.intTermsId
