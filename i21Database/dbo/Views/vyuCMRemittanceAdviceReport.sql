CREATE VIEW vyuCMRemittanceAdviceReport
AS
SELECT 
CHK.strRecordNo, 
CHK.intTransactionId,
CHK.intBankAccountId, 
strCompanyName = COMPANY.strCompanyName,
strCompanyAddress = dbo.fnConvertToFullAddress(COMPANY.strAddress, COMPANY.strCity,COMPANY.strState,COMPANY.strZip) COLLATE Latin1_General_CI_AS,
strBank = UPPER (Bank.strBankName),
strCustomerName = CHK.strName, 
strCustomerAddress = 
    CASE WHEN ISNULL(dbo.fnConvertToFullAddress (LOCATION.strAddress,LOCATION.strCity, LOCATION.strState, 
        LOCATION.strZipCode),'') <> '' 
    THEN dbo.fnConvertToFullAddress (LOCATION.strAddress,LOCATION.strCity, LOCATION.strState, LOCATION.strZipCode) 
    ELSE '' 
    END COLLATE Latin1_General_CI_AS, 
INV.strInvoiceNumber,
dtmDetailDate = INV.dtmDate, 
strComment = INV.strComments,
dblDetailAmount =  dbo.fnARGetInvoiceAmountMultiplier(INV.strTransactionType)  *  INV.dblInvoiceTotal,
dblDiscount = ISNULL(PYMTDTL.dblDiscount,0), 
dblNet =  dbo.fnARGetInvoiceAmountMultiplier(INV.strTransactionType) * ABS(PYMTDTL.dblPayment),
strMessage = 'The following items(s) will be presented to ' + CHK.strPayeeBankName + ' account ending ' + ISNULL (RIGHT(RTRIM (COALESCE (CHK.strPayeeBankAccountNumber,CHK.strPayeeBankAccountNumber COLLATE Latin1_General_CI_AS, N'')), 4), '') + ' on ' + CONVERT (VARCHAR, PYMT.dtmDatePaid,107), 
strBankAccountNo = STUFF (ACCT.strBankAccountNo, 1, LEN(ACCT.strBankAccountNo) - 4, REPLICATE ('x', LEN(ACCT.strBankAccountNo) - 4)),
PYMTDTL.intPaymentDetailId
FROM dbo.vyuCMACHFromCustomer CHK 
LEFT JOIN tblARPayment PYMT ON CHK.strRecordNo = PYMT.strRecordNumber 
LEFT JOIN tblARPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId 
LEFT JOIN tblARInvoice INV ON PYMTDTL.intInvoiceId = INV.intInvoiceId 
INNER JOIN tblCMBankAccount BA ON BA.intBankAccountId = CHK.intBankAccountId 
INNER JOIN tblCMBank Bank ON Bank.intBankId = BA.intBankId 
LEFT JOIN tblEMEntity ENTITY ON CHK.intEntityId = ENTITY.intEntityId 
LEFT JOIN tblEMEntityLocation LOCATION ON CHK.intEntityCustomerId = LOCATION.intEntityId AND ysnDefaultLocation = 1 
LEFT JOIN tblSMCompanySetup COMPANY ON COMPANY.intCompanySetupID = (SElECT TOP 1 intCompanySetupID FROM tblSMCompanySetup) 
LEFT JOIN vyuCMBankAccount ACCT ON ACCT.intBankAccountId = BA.intBankAccountId