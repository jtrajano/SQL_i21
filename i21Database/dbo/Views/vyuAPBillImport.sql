CREATE VIEW [dbo].[vyuAPBillImport]
as
SELECT
	TransactionType.strText COLLATE Latin1_General_CI_AS AS strTransactionType,
	Vendor.strName,
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
	OUTER APPLY(
		SELECT TOP 1 C.strName FROM  [tblAPVendor] B 
		LEFT JOIN dbo.[tblEMEntity] C ON C.intEntityId = B.intEntityId
		
		WHERE B.intEntityId = A.intEntityVendorId
	) Vendor
	OUTER APPLY (
		SELECT TOP 1 strText from dbo.fnAPGetVoucherTransactionType() WHERE intId = A.intTransactionType
	)TransactionType
	
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
	