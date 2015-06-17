CREATE VIEW vyuCTEntity
AS

	SELECT	E.intEntityId,
			E.strName			AS strEntityName,
			'Customer'			AS strEntityType,
			C.strCustomerNumber AS strEntityNumber,
			L.strAddress		AS strEntityAddress,
			L.strCity			AS strEntityCity,
			L.strState			AS strEntityState,
			L.strZipCode		AS strEntityZipCode,
			L.strCountry		AS strEntityCountry,
			L.strPhone			AS strEntityPhone,
			E.intDefaultLocationId 
	FROM	tblEntity			E
	JOIN	tblEntityLocation	L	ON	E.intEntityId = L.intEntityId AND L.ysnDefaultLocation = 1
	JOIN	tblARCustomer		C	ON	C.[intEntityCustomerId] = E.intEntityId
	
	UNION ALL
	
	SELECT	E.intEntityId,
			E.strName,
			'Vendor' AS strEntity,
			V.strVendorId ,
			L.strAddress,
			L.strCity,
			L.strState,
			L.strZipCode,
			L.strCountry,
			L.strPhone,
			E.intDefaultLocationId
	FROM	tblEntity			E
	JOIN	tblEntityLocation	L	ON	E.intEntityId = L.intEntityId AND L.ysnDefaultLocation = 1
	JOIN	tblAPVendor			V	ON	V.[intEntityVendorId] = E.intEntityId
	
	UNION ALL
	
	SELECT	E.intEntityId,
			E.strName,
			'ShippingLine' AS strEntity,
			NULL ,
			L.strAddress,
			L.strCity,
			L.strState,
			L.strZipCode,
			L.strCountry,
			L.strPhone,
			E.intDefaultLocationId
	FROM	tblEntity			E
	JOIN	tblEntityLocation	L	ON	E.intEntityId = L.intEntityId AND L.ysnDefaultLocation = 1
	JOIN	tblLGShippingLine	S	ON	S.[intEntityId] = E.intEntityId