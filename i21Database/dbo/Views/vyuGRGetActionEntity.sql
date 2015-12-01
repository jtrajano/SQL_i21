CREATE VIEW vyuGRGetActionEntity
AS
	SELECT	E.intEntityId,
			E.strName			AS strEntityName,
			Y.strType			AS strEntityType,
			E.strEntityNo		AS strEntityNumber,
			L.strAddress		AS strEntityAddress,
			L.strCity			AS strEntityCity,
			L.strState			AS strEntityState,
			L.strZipCode		AS strEntityZipCode,
			L.strCountry		AS strEntityCountry,
			T.strPhone			AS strEntityPhone,
			E.intDefaultLocationId,
			V.ysnPymtCtrlActive ysnActive,
			CASE 
				WHEN ISNULL(V.intCurrencyId,0)=0 THEN (SELECT intDefaultCurrencyId FROm tblSMCompanyPreference) ELSE V.intCurrencyId 
			END	intCurrencyId		
	FROM	tblEntity			E
	JOIN	tblEntityLocation	L	ON	E.intEntityId			=	L.intEntityId AND L.ysnDefaultLocation = 1
	JOIN	tblEntityType		Y	ON	Y.intEntityId			=	E.intEntityId
	JOIN	tblEntityToContact	C	ON	C.intEntityId			=	E.intEntityId AND C.ysnDefaultContact = 1
	JOIN	tblEntity			T	ON	T.intEntityId			=	C.intEntityContactId	LEFT 
	JOIN	tblAPVendor			V	ON	V.intEntityVendorId		=	E.intEntityId
	WHERE Y.strType = 'Vendor'
