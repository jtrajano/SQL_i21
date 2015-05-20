﻿CREATE VIEW vyuCTEntity
AS

	SELECT	E.intEntityId,
			E.strName,
			'Customer' AS strEntity,
			C.strCustomerNumber strNumber 
	FROM	tblEntity		E
	JOIN	tblARCustomer	C	ON	C.[intEntityCustomerId] = E.intEntityId
	
	UNION ALL
	
	SELECT	E.intEntityId,
			E.strName,
			'Vendor' AS strEntity,
			V.strVendorId 
	FROM	tblEntity		E
	JOIN	tblAPVendor		V	ON	V.[intEntityVendorId] = E.intEntityId
	
	UNION ALL
	
	SELECT	E.intEntityId,
			E.strName,
			'ShippingLine' AS strEntity,
			NULL 
	FROM	tblEntity			E
	JOIN	tblLGShippingLine	S	ON	S.[intEntityId] = E.intEntityId