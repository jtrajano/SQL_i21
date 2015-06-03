CREATE VIEW vyuCTEntity
AS

	SELECT	E.intEntityId,
			E.strName,
			'Customer' AS strEntity,
			C.strCustomerNumber strNumber,
			L.strAddress,
			E.intDefaultLocationId 
	FROM	tblEntity			E
	JOIN	tblEntityLocation	L	ON	E.intEntityId = L.intEntityId
	JOIN	tblARCustomer		C	ON	C.[intEntityCustomerId] = E.intEntityId
	
	UNION ALL
	
	SELECT	E.intEntityId,
			E.strName,
			'Vendor' AS strEntity,
			V.strVendorId ,
			L.strAddress,
			E.intDefaultLocationId
	FROM	tblEntity			E
	JOIN	tblEntityLocation	L	ON	E.intEntityId = L.intEntityId
	JOIN	tblAPVendor			V	ON	V.[intEntityVendorId] = E.intEntityId
	
	UNION ALL
	
	SELECT	E.intEntityId,
			E.strName,
			'ShippingLine' AS strEntity,
			NULL ,
			L.strAddress,
			E.intDefaultLocationId
	FROM	tblEntity			E
	JOIN	tblEntityLocation	L	ON	E.intEntityId = L.intEntityId
	JOIN	tblLGShippingLine	S	ON	S.[intEntityId] = E.intEntityId