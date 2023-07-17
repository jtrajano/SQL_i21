﻿CREATE VIEW vyuAPPaymentDetailSearch
AS

SELECT 
	A.intPaymentId,
	A.dtmDatePaid,
	B.intPaymentDetailId,
	C.strLocationName,
	D.strBankAccountNo,
	D.strNickname,
	F.strName AS strVendor,
	G.strLocationName  AS strPayTo,
	H.strPaymentMethod,
	A.strPaymentInfo AS strCheckNo,
	A.strPaymentRecordNum,
	ISNULL(ISNULL(I.dtmBillDate, BA.dtmBillDate), J.dtmDate) AS dtmVoucherDate,
	ISNULL(ISNULL(I.dtmDueDate, BA.dtmDueDate), J.dtmDueDate) AS dtmDueDate,
	ISNULL(I.strBillId, J.strInvoiceNumber) AS strVoucherId,
	F2.strName AS strVoucherVendor,
	I.strVendorOrderNumber AS strInvoice,
	K.strCommodityCode,
	L.strTerm,
	B.dblTotal,
	M.strAccountId,
	B.dblAmountDue,
	B.dblDiscount,
	B.dblInterest,
	B.dblPayment,
	N.strCurrency,
	P.strPeriod,
	O.strPaymentScheduleNumber
FROM tblAPPayment A
INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
INNER JOIN (tblAPVendor E INNER JOIN tblEMEntity F ON E.intEntityId = F.intEntityId)
	ON E.intEntityId = A.intEntityVendorId
LEFT JOIN tblAPBill I ON ISNULL(B.intBillId, B.intOrigBillId) = I.intBillId
LEFT JOIN tblAPBillArchive BA ON ISNULL(B.intBillId, B.intOrigBillId) = BA.intBillId
LEFT JOIN tblARInvoice J ON ISNULL(B.intInvoiceId, B.intOrigInvoiceId) = J.intInvoiceId
LEFT JOIN (tblAPVendor E2 INNER JOIN tblEMEntity F2 ON E2.intEntityId = F2.intEntityId)
	ON E2.intEntityId = ISNULL(I.intEntityVendorId, J.intEntityCustomerId)
LEFT JOIN tblEMEntityLocation G ON G.intEntityLocationId = A.intPayToAddressId
LEFT JOIN tblSMCompanyLocation C ON A.intCompanyLocationId = C.intCompanyLocationId
LEFT JOIN vyuCMBankAccount D ON A.intBankAccountId = D.intBankAccountId
LEFT JOIN tblSMPaymentMethod H ON H.intPaymentMethodID = A.intPaymentMethodId
LEFT JOIN vyuAPVoucherCommodity K ON K.intBillId = I.intBillId
LEFT JOIN tblSMTerm L ON ISNULL(I.intTermsId, J.intTermId) = L.intTermID
LEFT JOIN tblGLAccount M ON M.intAccountId = B.intAccountId
LEFT JOIN tblSMCurrency N ON N.intCurrencyID = A.intCurrencyId
LEFT JOIN vyuAPFiscalPeriod P ON MONTH(A.dtmDatePaid) = P.intMonth AND YEAR(A.dtmDatePaid) = P.intYear
LEFT JOIN tblAPVoucherPaymentSchedule O ON O.intId = B.intPayScheduleId
WHERE ISNULL(ISNULL(I.dtmBillDate, BA.dtmBillDate), J.dtmDate) IS NOT NULL
AND ISNULL(ISNULL(I.dtmDueDate, BA.dtmDueDate), J.dtmDueDate) IS NOT NULL