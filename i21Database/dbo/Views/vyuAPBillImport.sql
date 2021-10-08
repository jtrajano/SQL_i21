CREATE VIEW [dbo].[vyuAPBillImport]
as
SELECT
	dbo.fnAPGetVoucherTransactionType2(A.intTransactionType) strTransactionType,
	E.strName,
	A.dtmBillDate,
	A.strVendorOrderNumber,
	A.ysnRecurring,
	A.strComment,
	A.dtmDate,
	Term.strTerm,
	A.dtmDueDate,
	A.strReference,
	ShipVia.strShipVia,
	Contact.strName strContactName,
	ShipFrom.strLocationName strShipFrom,
	ShipTo.strLocationName strShipTo,
	Location.strLocationName strUserLocation,
	PayTo.strLocationName strPayTo,
	A.strBillId,
	C.strAccountId,
	0.00 dblWithheld ,
	Currency.strCurrency,
	OrderBy.strFullName strOrderedBy,
	A.intBillId
FROM
	dbo.tblAPBill A
	INNER JOIN (tblAPVendor V INNER JOIN tblEMEntity E ON E.intEntityId = V.intEntityId) ON V.intEntityId = A.intEntityVendorId
	LEFT JOIN dbo.[tblGLAccount] C ON A.intAccountId = C.intAccountId
	LEFT JOIN dbo.[tblSMCurrency] Currency ON Currency.intCurrencyID = A.intCurrencyId
	LEFT JOIN dbo.[tblEMEntityCredential] F ON A.intEntityId = F.intEntityId
	LEFT JOIN dbo.[tblSMTerm] Term ON Term.intTermID = A.intTermsId
	LEFT JOIN dbo.[tblSMShipVia] ShipVia ON ShipVia.intEntityId = A.intShipViaId
	LEFT JOIN dbo.[tblEMEntity] Contact ON Contact.intEntityId = A.intContactId
	LEFT JOIN dbo.[tblEMEntityLocation] ShipFrom ON ShipFrom.intEntityLocationId = A.intShipFromId
	LEFT JOIN dbo.[tblSMCompanyLocation] ShipTo ON ShipTo.intCompanyLocationId = A.intShipToId
	LEFT JOIN dbo.[tblSMCompanyLocation] Location ON Location.intCompanyLocationId = A.intStoreLocationId
	LEFT JOIN dbo.[tblEMEntityLocation] PayTo ON PayTo.intEntityLocationId = A.intPayToAddressId
	LEFT JOIN dbo.[tblSMUserSecurity] OrderBy ON OrderBy.intEntityId = A.intOrderById
	