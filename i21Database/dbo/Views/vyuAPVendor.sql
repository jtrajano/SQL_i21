﻿CREATE VIEW [dbo].[vyuAPVendor]
WITH SCHEMABINDING
	AS 
SELECT 
	A.intEntityId,
	A.strName, 
	A.strWebsite,
	A.strInternalNotes,
	B.intVendorId,
	B.intCurrencyId,
	B.intGLAccountExpenseId,
	B.intDefaultContactId,
	B.intDefaultLocationId,
	F.strAccountId AS strExpenseAccountId,
	B.intPaymentMethodId,
	A.str1099Form,
	A.str1099Name,
	A.str1099Type,
	A.dtmW9Signed,
	A.ysnPrint1099,
	A.strFederalTaxId,
	B.strTaxState,
	B.strVendorAccountNum,
	B.strVendorId,
	B.strVendorPayToId,
	B.ysnPymtCtrlActive,
	B.ysnPymtCtrlAlwaysDiscount,
	B.ysnPymtCtrlEFTActive,
	B.ysnPymtCtrlHold,
	B.ysnWithholding,
	B.dblCreditLimit,
	C.intShipViaId,
	C.intTaxCodeId,
	ISNULL(C.intTermsId, 0) intTermsId,
	--C.strContactName,
	C.strAddress,
	C.strCity,
	C.strCountry,
	C.strNotes,
	C.strState,
	C.strZipCode,
	D2.strEmail,
	D.strEmail2,
	D.strFax,
	--D.strLocationName,
	D.strMobile,
	D.strPhone,
	D.strPhone2,
	D.strTitle,
	E.strCurrency,
	ysnHasPayables = CAST((CASE WHEN EXISTS(SELECT 1 FROM dbo.tblAPBill G WHERE G.ysnPosted = 1 AND G.ysnPaid = 0 AND G.intVendorId = B.intVendorId) 
						THEN 1 ELSE 0 END) AS BIT)
FROM
		dbo.tblEntity A
	INNER JOIN dbo.tblAPVendor B
		ON A.intEntityId = B.intEntityId
	INNER JOIN dbo.tblEntityLocation C
		ON B.intDefaultLocationId = C.intEntityLocationId
	INNER JOIN (dbo.tblEntityContact D INNER JOIN dbo.tblEntity D2 ON D.intEntityId = D2.intEntityId)
		ON B.intDefaultContactId = D.intContactId
	LEFT JOIN dbo.tblSMCurrency E
		ON B.intCurrencyId = E.intCurrencyID
	LEFT JOIN dbo.tblGLAccount F 
		ON B.intGLAccountExpenseId = F.intAccountId
