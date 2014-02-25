CREATE VIEW [dbo].[vyuAPVendor]
	AS 
SELECT 
	A.intEntityId,
	A.strName, 
	A.strWebsite,
	A.strInternalNotes,
	B.intCurrencyId,
	B.intGLAccountExpenseId,
	B.intPaymentMethodId,
	B.str1099Category,
	B.str1099Name,
	B.str1099Type,
	B.strFederalTaxId,
	B.strTaxState,
	B.strVendorAccountNum,
	B.strVendorId,
	B.strVendorPayToId,
	B.ysnPrint1099,
	B.ysnPymtCtrlActive,
	B.ysnPymtCtrlAlwaysDiscount,
	B.ysnPymtCtrlEFTActive,
	B.ysnPymtCtrlHold,
	B.ysnW9Signed,
	B.ysnWithholding,
	B.dblCreditLimit,
	C.intShipViaId,
	C.intTaxCodeId,
	ISNULL(C.intTermsId, 0) intTermsId,
	C.strContactName,
	C.strCountry,
	C.strNotes,
	C.strState,
	C.strZipCode,
	D.strEmail,
	D.strEmail2,
	D.strFax,
	D.strLocationName,
	D.strMobile,
	D.strPhone,
	D.strPhone2,
	D.strTitle,
	E.strCurrency
FROM
		tblEntities A
	INNER JOIN tblAPVendor B
		ON A.intEntityId = B.intEntityId
	INNER JOIN tblEntityLocations C
		ON B.intEntityLocationId = C.intEntityLocationId
	INNER JOIN tblEntityContacts D
		ON B.intEntityContactId = D.intEntityContactId
	LEFT JOIN tblSMCurrency E
		ON B.intCurrencyId = E.intCurrencyID
