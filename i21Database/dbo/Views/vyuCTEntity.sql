CREATE VIEW vyuCTEntity
AS

	SELECT	E.intEntityId,
			E.strName,
			'Customer' AS strEntity,
			C.strCustomerNumber strNumber 
	FROM	tblEntity		E
	JOIN	tblARCustomer	C	ON	C.intEntityId = E.intEntityId
	
	UNION ALL
	
	SELECT	E.intEntityId,
			E.strName,
			'Vendor' AS strEntity,
			V.strVendorId 
	FROM	tblEntity		E
	JOIN	tblAPVendor		V	ON	V.intEntityVendorId = E.intEntityId
	