CREATE VIEW [dbo].[vyuAPVendorDefault]
AS 
SELECT 
	A.intEntityId,
	A.strName, 
	strVendorId= CASE WHEN B.strVendorId = '' THEN A.strEntityNo ELSE B.strVendorId END,
	A.str1099Form,
	A.str1099Name,
	A.str1099Type,
	B.intCurrencyId,
	E.strCurrency,
	B.intTermsId,
	J.strTerm,
	D.intEntityId AS intDefaultContactId,
	D.strName AS strDefaultContactName,
	C.intEntityLocationId AS intDefaultLocationId,
	C.strLocationName AS strDefaultLocationName,
	C.strAddress,
	C.strCity,
	C.strCountry,
	C.strState,
	C.strZipCode,
	C.intShipViaId,
	ShipVia.strShipVia,
	C.intFreightTermId,
	Freight.strFreightTerm,
	B.intGLAccountExpenseId,
	K.strAccountId,
	B.intBillToId,
	C2.strLocationName AS strPayTo
FROM
		dbo.tblEMEntity A
	INNER JOIN dbo.tblAPVendor B
		ON A.intEntityId = B.[intEntityId]
	INNER JOIN dbo.tblEMEntityType EntType
		ON EntType.intEntityId = B.intEntityId
			AND EntType.strType = 'Vendor'
	INNER JOIN dbo.[tblEMEntityLocation] C
		ON B.intEntityId = C.intEntityId and C.ysnDefaultLocation = 1
	INNER JOIN dbo.[tblEMEntityToContact] G
		ON G.intEntityId = A.intEntityId
	INNER JOIN dbo.tblEMEntity D
		ON G.intEntityContactId = D.[intEntityId] AND G.ysnDefaultContact = 1
	LEFT JOIN dbo.tblEMEntityLocation C2
		ON B.intBillToId = C2.intEntityLocationId
	LEFT JOIN dbo.tblSMCurrency E
		ON B.intCurrencyId = E.intCurrencyID
	LEFT JOIN dbo.tblSMShipVia ShipVia
		ON C.intShipViaId = ShipVia.intEntityId
	LEFT JOIN dbo.tblSMFreightTerms Freight
		ON C.intFreightTermId = Freight.intFreightTermId
	LEFT JOIN dbo.tblSMTerm J
		ON B.intTermsId = J.intTermID
	LEFT JOIN dbo.tblGLAccount K
		ON B.intGLAccountExpenseId = K.intAccountId
GO


