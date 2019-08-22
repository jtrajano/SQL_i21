CREATE VIEW vyuCMRemittanceAdviceReport
AS
SELECT 
CHK.dtmDate, strCheckNumber = CHK.strReferenceNo,CHK.dblAmount, 
CHK.strName, strAmountInWords = LTRIM (RTRIM(REPLACE (CHK.strAmountInWords, '*', ''))) 
    + REPLICATE (' *',30), 
CHK.strRecordNo, 
CHK.intTransactionId,
CHK.intBankAccountId, 
strCompanyName = COMPANY.strCompanyName,
strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity,COMPANY.strState,COMPANY.strZip),
strBank = UPPER (Bank.strBankName),
strBankAddress = dbo.fnConvertToFullAddress (Bank.strAddress,Bank.strCity, Bank.strState, Bank.strZipCode),
strCustomerId = ISNULL (CHK.strEntityNo, '--'),
strCustomerName = CHK.strName, 
strCustomerAccount = ISNULL(RIGHT (CHK.strPayeeBankAccountNumber, 4), ''),
strCustomerAddress = 
    CASE WHEN ISNULL(dbo.fnConvertToFullAddress (LOCATION.strAddress,LOCATION.strCity, LOCATION.strState, 
        LOCATION.strZipCode),'') <> '' 
    THEN dbo.fnConvertToFullAddress (LOCATION.strAddress,LOCATION.strCity, LOCATION.strState, LOCATION.strZipCode) 
    ELSE '' 
    END, 
CHK.intBankTransactionTypeId, 
INV.strInvoiceNumber,dtmDetailDate = INV.dtmDate, 
strComment = INV.strComments,
dblDetailAmount = INV.dblInvoiceTotal, 
PYMT.dtmDatePaid,
dblDiscount = PYMTDTL.dblDiscount, 
dblNet = CASE WHEN INV.intPaymentId IS NULL  THEN PYMTDTL.dblPayment ELSE INV.dblInvoiceTotal END,
strMessage = 'The following items(s) will be presented to ' + 
CHK.strPayeeBankName + ' account ending ' + ISNULL (RIGHT(RTRIM (COALESCE (CHK.strPayeeBankAccountNumber,
CHK.strPayeeBankAccountNumber COLLATE Latin1_General_CI_AS, N'')), 4), '') + ' on ' + CONVERT (VARCHAR, PYMT.dtmDatePaid,107), 
strBankAccountNo = STUFF (ACCT.strBankAccountNo, 1, LEN(ACCT.strBankAccountNo) - 4, REPLICATE ('x', LEN(ACCT.strBankAccountNo) - 4)), 
CHK.strPayeeBankName,CHK.strPayeeBankAccountNumber 
FROM dbo.vyuCMACHFromCustomer CHK 
LEFT JOIN tblARPayment PYMT ON CHK.strRecordNo = PYMT.strRecordNumber 
LEFT JOIN tblARPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId 
LEFT JOIN tblARInvoice INV ON PYMT.intPaymentId = INV.intPaymentId 
INNER JOIN tblCMBankAccount BA ON BA.intBankAccountId = CHK.intBankAccountId 
INNER JOIN tblCMBank Bank ON Bank.intBankId = BA.intBankId 
LEFT JOIN tblEMEntity ENTITY ON CHK.intEntityId = ENTITY.intEntityId 
LEFT JOIN tblEMEntityLocation LOCATION ON CHK.intEntityCustomerId = LOCATION.intEntityId AND ysnDefaultLocation = 1 
LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = (SElECT TOP 1 intCompanySetupID FROM tblSMCompanySetup) 
LEFT JOIN vyuCMBankAccount ACCT ON ACCT.intBankAccountId = BA.intBankAccountId
		