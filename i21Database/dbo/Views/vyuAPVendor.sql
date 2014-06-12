CREATE VIEW [dbo].[vyuAPVendor]
	AS 
SELECT 
	A.intEntityId,
	A.strName, 
	A.strWebsite,
	A.strInternalNotes,
	B.intCurrencyId,
	B.intGLAccountExpenseId,
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
	D.strEmail,
	D.strEmail2,
	D.strFax,
	--D.strLocationName,
	D.strMobile,
	D.strPhone,
	D.strPhone2,
	D.strTitle,
	E.strCurrency
FROM
		tblEntity A
	INNER JOIN tblAPVendor B
		ON A.intEntityId = B.intEntityId
	INNER JOIN tblEntityLocation C
		ON B.intDefaultLocationId = C.intEntityLocationId
	INNER JOIN tblEntityContact D
		ON B.intDefaultContactId = D.intEntityId
	LEFT JOIN tblSMCurrency E
		ON B.intCurrencyId = E.intCurrencyID
	LEFT JOIN tblGLAccount F 
		ON B.intGLAccountExpenseId = F.intAccountId
	