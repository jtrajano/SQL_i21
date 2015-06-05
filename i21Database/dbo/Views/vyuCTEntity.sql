CREATE VIEW vyuCTEntity
AS

	SELECT	E.intEntityId,
			E.strName,
			'Customer' AS strEntity,
			C.strCustomerNumber strNumber,
			L.strAddress,
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
			E.intDefaultLocationId
	FROM	tblEntity			E
	JOIN	tblEntityLocation	L	ON	E.intEntityId = L.intEntityId AND L.ysnDefaultLocation = 1
	JOIN	tblLGShippingLine	S	ON	S.[intEntityId] = E.intEntityId