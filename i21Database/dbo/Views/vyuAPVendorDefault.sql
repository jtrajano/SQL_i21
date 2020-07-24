CREATE VIEW [dbo].[vyuAPVendorDefault]
AS 
SELECT 
	A.intEntityId,
	A.strName, 
	strVendorId= CASE WHEN B.strVendorId = '' THEN A.strEntityNo ELSE B.strVendorId END,
	A.str1099Form,
	A.str1099Name,
	A.str1099Type,
	intCurrencyId = ISNULL(C.intDefaultCurrencyId,B.intCurrencyId),
	strCurrency = ISNULL(E1.strCurrency, E.strCurrency),
	ISNULL(C.intTermsId,B.intTermsId) AS intTermsId,
	ISNULL(J.strTerm,J2.strTerm) AS strTerm,
	D.intEntityId AS intDefaultContactId,
	D.strName AS strDefaultContactName,
	D.strEmail AS strDefaultContactEmail,
	C.intEntityLocationId AS intDefaultLocationId,
	C.strLocationName AS strDefaultLocationName,
	C.strAddress,
	C.strCity,
	C.strCountry,
	C.strState,
	C.strZipCode,
	ShipVia.intEntityId AS intShipViaId,
	ShipVia.strShipVia,
	C.intFreightTermId,
	Freight.strFreightTerm,
	B.intGLAccountExpenseId,
	K.strAccountId,
	B.intBillToId,
	B.ysnPymtCtrlAlwaysDiscount,
	CASE WHEN B.intBillToId > 0 THEN C2.strCheckPayeeName ELSE C.strCheckPayeeName END AS strPayTo,
	CASE WHEN B.intBillToId > 0 THEN C2.strLocationName ELSE C.strLocationName END AS strPayToLocationName,
	strCheckPayeeAddress = CASE WHEN B.intBillToId > 0 
			THEN ISNULL(dbo.fnConvertToFullAddress(C2.strAddress, C2.strCity, C2.strState, C.strZipCode), '')
			ELSE ISNULL(dbo.fnConvertToFullAddress(C.strAddress, C.strCity, C.strState, C.strZipCode), '')
		END COLLATE Latin1_General_CI_AS,
	intBookId,
	strBook,
	intSubBookId,
	strSubBook,
	B.intShipFromId,
	SF.strLocationName as strShipFromName
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
	LEFT JOIN dbo.tblEMEntityLocation SF
		ON B.intShipFromId = SF.intEntityLocationId
	LEFT JOIN dbo.tblSMCurrency E1 ON C.intDefaultCurrencyId = E1.intCurrencyID
	LEFT JOIN dbo.tblSMCurrency E
		ON B.intCurrencyId = E.intCurrencyID
	LEFT JOIN dbo.tblSMShipVia ShipVia
		ON C.intShipViaId = ShipVia.intEntityId
	LEFT JOIN dbo.tblSMFreightTerms Freight
		ON C.intFreightTermId = Freight.intFreightTermId
	LEFT JOIN dbo.tblSMTerm J
		ON C.intTermsId = J.intTermID
	LEFT JOIN dbo.tblSMTerm J2
		ON B.intTermsId = J2.intTermID
	LEFT JOIN dbo.tblGLAccount K
		ON B.intGLAccountExpenseId = K.intAccountId
	OUTER APPLY (
		SELECT TOP 1
			bookEntity.intEntityId
			,bookEntity.intBookId
			,ctbook.strBook
			,bookEntity.intSubBookId
			,ctsubbook.strSubBook
		FROM tblCTBookVsEntity bookEntity
		INNER JOIN tblCTBook ctbook ON bookEntity.intBookId = ctbook.intBookId
		INNER JOIN tblCTSubBook ctsubbook ON bookEntity.intSubBookId = ctsubbook.intSubBookId
		WHERE bookEntity.intEntityId = A.intEntityId
	) ctBookEntities

GO


