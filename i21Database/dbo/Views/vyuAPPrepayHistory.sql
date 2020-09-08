CREATE VIEW [dbo].[vyuAPPrepayHistory]

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
    ,b.dtmDateCreated AS dtmTransactionDate
    ,1 intSequence
    FROM tblAPBill b
    JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId
	  JOIN (tblAPVendor v JOIN tblEMEntity e ON v.intEntityId = e.intEntityId)
		ON b.intEntityVendorId = v.intEntityId
    --WHERE (b.intTransactionType IN (13,2) AND b.ysnPosted = 1) OR (b.intTransactionType IN (3) AND b.ysnPosted = 1 AND b.dblAmountDue != 0)
    WHERE b.intTransactionType IN (13, 2, 3)
    AND b.ysnPosted = 1
    GROUP BY b.intEntityVendorId, v.strVendorId, e.strName, b.intBillId, b.strBillId, b.dtmDate, b.dtmDateCreated

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
    ,p.dtmDateCreated
    ,2
    FROM tblAPPaymentDetail pd 
    JOIN tblAPPayment p ON p.intPaymentId = pd.intPaymentId
    JOIN tblAPBill b ON pd.intBillId = b.intBillId
    JOIN (tblAPVendor v JOIN tblEMEntity e ON v.intEntityId = e.intEntityId)
		ON b.intEntityVendorId = v.intEntityId
    WHERE pd.ysnOffset = 0
    AND p.ysnPosted = 1
    AND b.intTransactionType IN (13, 2, 3)

    UNION
    --Applied to Payments
    SELECT 
    b.intEntityVendorId
	  ,v.strVendorId
    ,e.strName
    ,b.intBillId
    ,b.strBillId
    ,b.dtmDate
    ,pd.dblPayment*-1
    ,p.strPaymentRecordNum
    ,p.dtmDateCreated
    ,3
    FROM tblAPPaymentDetail pd 
    JOIN tblAPPayment p ON p.intPaymentId = pd.intPaymentId
    JOIN tblAPBill b ON pd.intBillId = b.intBillId
    JOIN (tblAPVendor v JOIN tblEMEntity e ON v.intEntityId = e.intEntityId)
		ON b.intEntityVendorId = v.intEntityId
    WHERE pd.ysnOffset = 1
    AND p.ysnPosted = 1
    AND b.intTransactionType IN (13, 2, 3)

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
    ,b1.dtmDateCreated
    ,4
    FROM tblAPAppliedPrepaidAndDebit o
    JOIN tblAPBill b ON o.intTransactionId = b.intBillId
    JOIN tblAPBill b1 ON o.intBillId = b1.intBillId
    JOIN (tblAPVendor v JOIN tblEMEntity e ON v.intEntityId = e.intEntityId)
		ON b.intEntityVendorId = v.intEntityId
    WHERE b.ysnPosted = 1
    AND b.intTransactionType IN (13, 2, 3)

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
    AND b.intTransactionType IN (13, 2, 3)
) h