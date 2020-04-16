﻿CREATE VIEW [dbo].[vyuAPPrepayHistory]

AS 

SELECT *

FROM (
    --Voucher
    SELECT
    b.intEntityVendorId
    ,v.strVendorId
    ,e.strName
    ,b.intBillId
    ,b.strBillId
    ,b.dtmDate
    ,sum(bd.dblTotal+bd.dblTax) AS dblTotal
    ,b.strBillId AS strTransactionId
    ,b.dtmDate AS dtmTransactionDate
    ,1 intSequence
    FROM tblAPBill b
    JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId
	  JOIN (tblAPVendor v JOIN tblEMEntity e ON v.intEntityId = e.intEntityId)
		ON b.intEntityVendorId = v.intEntityId
    WHERE b.intTransactionType IN (13,2)
    AND b.ysnPosted = 1
    GROUP BY b.intEntityVendorId, v.strVendorId, e.strName, b.intBillId, b.strBillId, b.dtmDate

    UNION
    --Voucher Payment
    SELECT
    b.intEntityVendorId
	  ,v.strVendorId
    ,e.strName
    ,b.intBillId
    ,b.strBillId
    ,b.dtmDate
    ,pd.dblPayment
    ,p.strPaymentRecordNum
    ,p.dtmDatePaid
    ,2
    FROM tblAPPaymentDetail pd 
    JOIN tblAPPayment p ON p.intPaymentId = pd.intPaymentId
    JOIN tblAPBill b ON pd.intBillId = b.intBillId
    JOIN (tblAPVendor v JOIN tblEMEntity e ON v.intEntityId = e.intEntityId)
		ON b.intEntityVendorId = v.intEntityId
    WHERE pd.ysnOffset = 0
    AND p.ysnPosted = 1

    UNION
    --Applied to Payments
    SELECT 
    b.intEntityVendorId
	  ,v.strVendorId
    ,e.strName
    ,b.intBillId
    ,b.strBillId
    ,b.dtmDate
    ,pd.dblPayment
    ,p.strPaymentRecordNum
    ,p.dtmDatePaid
    ,3
    FROM tblAPPaymentDetail pd 
    JOIN tblAPPayment p ON p.intPaymentId = pd.intPaymentId
    JOIN tblAPBill b ON pd.intBillId = b.intBillId
    JOIN (tblAPVendor v JOIN tblEMEntity e ON v.intEntityId = e.intEntityId)
		ON b.intEntityVendorId = v.intEntityId
    WHERE pd.ysnOffset = 1
    AND p.ysnPosted = 1
    AND b.intTransactionType IN (13,2)

    UNION
    --Applied to voucher
    SELECT 
    b.intEntityVendorId
	  ,v.strVendorId
    ,e.strName
    ,b.intBillId
    ,b.strBillId
    ,b.dtmDate
    ,o.dblAmountApplied*-1
    ,b1.strBillId
    ,b1.dtmDate
    ,4
    FROM tblAPAppliedPrepaidAndDebit o
    JOIN tblAPBill b ON o.intTransactionId = b.intBillId
    JOIN tblAPBill b1 ON o.intBillId = b1.intBillId
    JOIN (tblAPVendor v JOIN tblEMEntity e ON v.intEntityId = e.intEntityId)
		ON b.intEntityVendorId = v.intEntityId
    WHERE b.ysnPosted = 1

    UNION
    --Applied to AR Receive Payments
    SELECT
    b.intEntityVendorId
	  ,v.strVendorId
    ,e.strName
    ,b.intBillId
    ,b.strBillId
    ,b.dtmDate
    ,pd.dblPayment*-1
    ,p.strRecordNumber
    ,p.dtmDatePaid
    ,5
    FROM tblARPayment p
    JOIN tblARPaymentDetail pd ON p.intPaymentId = pd.intPaymentId
    JOIN tblAPBill b ON pd.intBillId = b.intBillId
    JOIN (tblAPVendor v JOIN tblEMEntity e ON v.intEntityId = e.intEntityId)
		ON b.intEntityVendorId = v.intEntityId
    WHERE p.ysnPosted = 1
) h