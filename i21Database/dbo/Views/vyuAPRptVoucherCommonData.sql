CREATE VIEW vyuAPRptVoucherCommonData
AS

SELECT DISTINCT
A.intBillId
,companySetup.strCompanyName AS strCompanyName
,strCompanyAddress = ISNULL(RTRIM(companySetup.strCompanyName) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(companySetup.strAddress) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(companySetup.strZip),'') + ' ' + ISNULL(RTRIM(companySetup.strCity), '') + ' ' + ISNULL(RTRIM(companySetup.strState), '') + CHAR(13) + char(10)
				 + ISNULL('' + RTRIM(companySetup.strCountry) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(companySetup.strPhone)+ CHAR(13) + char(10), '')
,strShipFrom = [dbo].[fnAPFormatAddress](B2.strName,NULL, A.strShipFromAttention, A.strShipFromAddress, A.strShipFromCity, A.strShipFromState, A.strShipFromZipCode, A.strShipFromCountry, A.strShipFromPhone) COLLATE Latin1_General_CI_AS
,strShipTo = [dbo].[fnAPFormatAddress](NULL,companySetup.strCompanyName, A.strShipToAttention, A.strShipToAddress, A.strShipToCity, A.strShipToState, A.strShipToZipCode, A.strShipToCountry, A.strShipToPhone) COLLATE Latin1_General_CI_AS
,dbo.fnTrim(ISNULL(B.strVendorId, B2.strEntityNo) + ' - ' + ISNULL(B2.strName,'')) COLLATE Latin1_General_CI_AS as strVendorIdName 
,ISNULL(B2.strName,'') COLLATE Latin1_General_CI_AS AS strVendorName 
,ISNULL(B.strVendorId, B2.strEntityNo) COLLATE Latin1_General_CI_AS AS strVendorId
,ContactEntity.strName AS strContactName
,ContactEntity.strEmail AS strContactEmail
,strDateLocation = TranLoc.strLocationName + ', ' + CONVERT(VARCHAR(12), GETDATE(), 106)
,strLocationName = TranLoc.strLocationName
,Bank.strBankName
,BankAccount.strBankAccountHolder
,dbo.fnAPMaskBankAccountNos(dbo.fnAESDecryptASym(BankAccount.strBankAccountNo)) COLLATE Latin1_General_CI_AS AS strBankAccountNo
,BankAccount.strIBAN
,BankAccount.strSWIFT
,Term.strTerm
,A.strRemarks
,A.strBillId
,A.dtmDate
,A.dtmDueDate--CONVERT(VARCHAR(10), A.dtmDueDate, 103) AS dtmDueDate
,Bank.strCity + ', ' + Bank.strState +  ' ' + Bank.strCountry AS strBankAddress
FROM tblAPBill A 
INNER JOIN (tblAPVendor B INNER JOIN tblEMEntity B2 ON B.intEntityId = B2.intEntityId)
	ON A.intEntityVendorId = B.intEntityId
CROSS JOIN tblSMCompanySetup companySetup
LEFT JOIN tblEMEntityToContact EntityToContact ON A.intEntityId = EntityToContact.intEntityId AND EntityToContact.ysnDefaultContact = 1
LEFT JOIN tblEMEntity ContactEntity ON EntityToContact.intEntityContactId = ContactEntity.intEntityId
LEFT JOIN tblSMCompanyLocation TranLoc ON A.intStoreLocationId = TranLoc.intCompanyLocationId
LEFT JOIN tblCMBankAccount BankAccount ON BankAccount.intBankAccountId = A.intBankInfoId
LEFT JOIN tblCMBank Bank ON BankAccount.intBankId = Bank.intBankId
LEFT JOIN tblSMTerm Term ON A.intTermsId = Term.intTermID

