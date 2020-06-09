CREATE VIEW vyuCMAPRemittanceAdviceReport
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
		, strInvoice = BILL.strVendorOrderNumber
		, dtmDetailDate = BILL.dtmBillDate
		, strComment = BILL.strComment
		, dblDetailAmount = PYMTDTL.dblTotal
		, dblDiscount = PYMTDTL.dblDiscount
		, dblNet = PYMTDTL.dblPayment
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
FROM dbo.tblCMBankTransaction CHK 
LEFT JOIN tblAPPayment PYMT ON CHK.strTransactionId = PYMT.strPaymentRecordNum 
INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId 
INNER JOIN tblAPBill BILL ON PYMTDTL.intBillId = BILL.intBillId 
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
WHERE CHK.intBankTransactionTypeId IN (22, 23, 123)
