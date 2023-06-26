﻿CREATE VIEW vyuCMAPRemittanceAdviceReport
AS
SELECT CHK.dtmDate
		, strCheckNumber = CHK.strReferenceNo
		, CHK.dblAmount, CHK.strPayee, strAmountInWords = LTRIM (RTRIM(REPLACE (CHK.strAmountInWords, '*', ''))) + REPLICATE (' *',30)
		, CHK.strMemo, CHK.strTransactionId, CHK.intTransactionId
		, CHK.intBankAccountId, strCompanyName = COMPANY.strCompanyName
		, strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress
		, COMPANY.strCity
		, COMPANY.strState
		, COMPANY.strZip) COLLATE Latin1_General_CI_AS
		, strBank = UPPER (Bank.strBankName)
		, strBankAddress = dbo.fnConvertToFullAddress (Bank.strAddress, Bank.strCity, Bank.strState, Bank.strZipCode) COLLATE Latin1_General_CI_AS
		, strVendorId = ISNULL (VENDOR.strVendorId, '--')
		, strVendorName = ISNULL (ENTITY.strName, CHK.strPayee)
		, strVendorAccount = ISNULL (F.strAccountNumber, '') COLLATE Latin1_General_CI_AS
		, strVendorAddress = 
			CASE WHEN ISNULL (dbo.fnConvertToFullAddress(LOCATION.strAddress, LOCATION.strCity, LOCATION.strState,LOCATION.strZipCode), '') <> '' 
			THEN dbo.fnConvertToFullAddress(LOCATION.strAddress, LOCATION.strCity, LOCATION.strState,LOCATION.strZipCode) 
			ELSE dbo.fnConvertToFullAddress(CHK.strAddress, CHK.strCity, CHK.strState, CHK.strZipCode)
	       END COLLATE Latin1_General_CI_AS
		, CHK.intBankTransactionTypeId --DETAIL PART
		, strBillId = BILL.strBillId
		, strInvoice = CASE WHEN BILL.intBillId IS NOT NULL THEN  BILL.strVendorOrderNumber ELSE INVOICE.strInvoiceNumber END
		, dtmDetailDate = CASE WHEN BILL.intBillId IS NOT NULL THEN BILL.dtmBillDate ELSE INVOICE.dtmDate END
		, strComment = CASE WHEN BILL.intBillId IS NOT NULL THEN  BILL.strComment ELSE 
				CASE WHEN INVOICE.strTransactionType = 'Cash Refund' THEN 'Cash Refund' ELSE '' END
		  END
		, dblDetailAmount = PYMTDTL.dblTotal-- as of 19.2 PYMTDetail.dblTotal / dblPayment will reflect negative sign appropriately
		, dblDiscount = PYMTDTL.dblDiscount
		, dblNet = PYMTDTL.dblTotal - ISNULL(PYMTDTL.dblDiscount,0)-- as of 19.2 PYMTDetail.dblTotal / dblPayment will reflect negative sign appropriately
		, strBankAccountNo = STUFF(ACCT.strBankAccountNo, 1, LEN (ACCT.strBankAccountNo) - 4
		, REPLICATE ('x', LEN (ACCT.strBankAccountNo) - 4))
		, strMessage = 'The following items(s) will be presented to ' + 
			ISNULL ((SELECT TOP 1 strBankName 
						FROM [tblEMEntityEFTInformation] EFTInfo 
						WHERE EFTInfo.ysnActive = 1 
						AND dtmEffectiveDate < = DATEADD (dd, DATEDIFF (dd, 0, GETDATE()), 0) 
						AND intEntityId = ENTITY.intEntityId ORDER BY dtmEffectiveDate desc), '') 
			+ ' account ending ' 
			+ ISNULL ((SELECT TOP 1 RIGHT (RTRIM (dbo.fnAESDecryptASym (strAccountNumber)), 4) 
						FROM [tblEMEntityEFTInformation]EFTInfo 
						WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate < = DATEADD (dd, DATEDIFF (dd, 0, GETDATE ()),0) 
						AND intEntityId = ENTITY.intEntityId ORDER BY dtmEffectiveDate desc), '') 
			+ ' on ' + 
			CONVERT(varchar(11), PYMT.dtmDatePaid,106)
		, PYMTDTL.intPaymentDetailId
		, CP.ysnDisplayVendorAccountNumber
		, CASE WHEN O.intUTCOffset IS NULL THEN GETDATE() ELSE DATEADD(MINUTE, O.intUTCOffset * -1, GETUTCDATE()) END dtmCurrent
		
FROM dbo.tblCMBankTransaction CHK 
LEFT JOIN tblAPPayment PYMT ON CHK.strTransactionId = PYMT.strPaymentRecordNum 
JOIN
(
	SELECT A.intPaymentId, intBillId, dblTotal ,dblDiscount, intInvoiceId,intPaymentDetailId
	FROM tblAPPayment A JOIN tblAPPaymentDetail B on A.intPaymentId = B.intPaymentId
	UNION
	SELECT intPaymentId, B.intTransactionId, B.dblTotal * -1 ,dblDiscount = 0,  PD.intInvoiceId,intPaymentDetailId 
	FROM tblAPAppliedPrepaidAndDebit B JOIN tblAPBill A ON A.intBillId = B.intBillId
	JOIN tblAPBill C ON C.intBillId = B.intTransactionId
	JOIN tblAPBillDetail BD ON BD.intBillId = A.intBillId
	JOIN tblAPPaymentDetail PD ON PD.intBillId = A.intBillId where B.ysnApplied = 1
) PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId 
LEFT JOIN tblAPBill BILL ON PYMTDTL.intBillId = BILL.intBillId 
LEFT JOIN tblARInvoice INVOICE on INVOICE.intInvoiceId = PYMTDTL.intInvoiceId  
INNER JOIN tblCMBankAccount BA ON BA.intBankAccountId = CHK.intBankAccountId 
INNER JOIN tblCMBank Bank ON Bank.intBankId = BA.intBankId 
LEFT JOIN tblAPVendor VENDOR ON VENDOR.[intEntityId] = ISNULL (PYMT.[intEntityVendorId], CHK.intEntityId) 
LEFT JOIN tblEMEntity ENTITY ON VENDOR.[intEntityId] = ENTITY.intEntityId 
LEFT JOIN tblEMEntityLocation LOCATION ON VENDOR.intEntityId = LOCATION.intEntityId 
AND ysnDefaultLocation = 1 
LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = 
	(SElECT TOP 1 intCompanySetupID FROM tblSMCompanySetup) 
LEFT JOIN vyuCMBankAccount ACCT ON ACCT.intBankAccountId = BA.intBankAccountId
OUTER APPLY (
	SELECT TOP 1 RIGHT (RTRIM (dbo.fnAESDecryptASym (strAccountNumber)),4) strAccountNumber 
	FROM [tblEMEntityEFTInformation] EFTInfo 
	WHERE EFTInfo.ysnActive = 1 
	AND dtmEffectiveDate < = DATEADD(dd, DATEDIFF (dd, 0, GETDATE ()), 0) 
	AND intEntityId = ENTITY.intEntityId ORDER BY dtmEffectiveDate desc
) F 
OUTER APPLY(
	SELECT intUTCOffset from [tblCMCompanyPreferenceOption]
)O
OUTER APPLY(
	SELECT TOP 1 ysnRemittanceAdvice_DisplayVendorAccountNumber ysnDisplayVendorAccountNumber FROM tblAPCompanyPreference
)CP
WHERE CHK.intBankTransactionTypeId IN (22, 23, 123)
