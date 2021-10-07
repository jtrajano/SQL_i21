CREATE VIEW vyuAPRptVoucherCommonData
AS

SELECT
A.intBillId
,companySetup.strCompanyName AS strCompanyName
,strCompanyAddress = ISNULL(RTRIM(companySetup.strCompanyName) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(companySetup.strAddress) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(companySetup.strZip),'') + ' ' + ISNULL(RTRIM(companySetup.strCity), '') + ' ' + ISNULL(RTRIM(companySetup.strState), '') + CHAR(13) + char(10)
				 + ISNULL('' + RTRIM(companySetup.strCountry) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(companySetup.strPhone)+ CHAR(13) + char(10), '')
,strCompanyAddressNoPhone = ISNULL(RTRIM(companySetup.strCompanyName) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(companySetup.strAddress) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(companySetup.strZip),'') + ' ' + ISNULL(RTRIM(companySetup.strCity), '') + ' ' + ISNULL(RTRIM(companySetup.strState), '') + CHAR(13) + char(10)
				 + ISNULL('' + RTRIM(companySetup.strCountry) + CHAR(13) + char(10), '')
,strShipFrom = [dbo].[fnAPFormatAddress](B2.strName,NULL, A.strShipFromAttention, A.strShipFromAddress, A.strShipFromCity, A.strShipFromState, A.strShipFromZipCode, A.strShipFromCountry, A.strShipFromPhone) COLLATE Latin1_General_CI_AS
,strShipFrom2 = ISNULL(RTRIM(A.strShipFromAddress) + CHAR(13) + char(10), '')
				+ ISNULL('' + RTRIM(A.strShipFromZipCode) + ' ', '')
				+ ISNULL(RTRIM(A.strShipFromCity) + CHAR(10), '')
				+ ISNULL(RTRIM(A.strShipFromState) + CHAR(13) + char(10), '')
				+ ISNULL('' + RTRIM(A.strShipFromCountry) + CHAR(13) + char(10), '')
,strShipTo = [dbo].[fnAPFormatAddress](NULL,companySetup.strCompanyName, A.strShipToAttention, A.strShipToAddress, A.strShipToCity, A.strShipToState, A.strShipToZipCode, A.strShipToCountry, A.strShipToPhone) COLLATE Latin1_General_CI_AS
,dbo.fnTrim(ISNULL(B.strVendorId, B2.strEntityNo) + ' - ' + ISNULL(B2.strName,'')) as strVendorIdName 
,ISNULL(B2.strName,'') AS strVendorName 
,ISNULL(B.strVendorId, B2.strEntityNo) AS strVendorId
,ContactEntity.strName AS strContactName
,ContactEntity.strEmail AS strContactEmail
,strDateLocation = TranLoc.strLocationName + ', ' + CONVERT(VARCHAR(12), GETDATE(), 106)
,strLocationName = TranLoc.strLocationName
,Bank.strBankName
,BankAccount.strBankAccountHolder
,dbo.fnAPMaskBankAccountNos(dbo.fnAESDecryptASym(BankAccount.strBankAccountNo)) AS strBankAccountNo
,BankAccount.strIBAN
,BankAccount.strSWIFT
,strBankAccountOrReference = CASE WHEN A.intBankInfoId > 0 
								THEN 'Bank Name: ' + Bank.strBankName + CHAR(10) +
									 'Bank Account: ' + dbo.fnAPMaskBankAccountNos(dbo.fnAESDecryptASym(BankAccount.strBankAccountNo)) + CHAR(10) +
									 'Bank Account Holder: ' + BankAccount.strBankAccountHolder + CHAR(10) +
									 'IBAN: ' + BankAccount.strIBAN + CHAR(10) +
									 'SWIFT: ' + BankAccount.strSWIFT
								ELSE A.strReference
							END
,Term.strTerm
,A.strRemarks
,A.strBillId
,A.dtmDate
,A.dtmDueDate--CONVERT(VARCHAR(10), A.dtmDueDate, 103) AS dtmDueDate
,CONVERT(NVARCHAR(10), A.dtmBillDate, 103) dtmBillDate
,ISNULL(A.strVendorOrderNumber, '') strVendorOrderNumber
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
CROSS JOIN tblSMCompanyPreference CP

