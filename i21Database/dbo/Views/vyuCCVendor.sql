﻿
CREATE VIEW [dbo].[vyuCCVendor]
WITH SCHEMABINDING
	AS 
SELECT 
    A.intVendorDefaultId,
	B.intEntityVendorId as intEntityId,	
	B.intEntityVendorId as intVendorId,
	B.intDefaultLocationId,
	D.strLocationName,
	B.intPaymentMethodId,
    F.strPaymentMethod,
	B.strVendorId,	
	C.strName, 
	E.strTerm,
    E.intTermID

FROM
     dbo.tblCCVendorDefault A
	INNER JOIN dbo.tblAPVendor B
		ON A.intVendorId = B.intEntityVendorId
	INNER JOIN dbo.tblEntity C
		ON B.intEntityVendorId = C.intEntityId
	LEFT JOIN dbo.tblEntityLocation D
		ON B.intDefaultLocationId = D.intEntityLocationId
    LEFT Join dbo.tblSMTerm E
	    on D.intTermsId = E.intTermID
    LEFT Join dbo.tblSMPaymentMethod F
	    on B.intPaymentMethodId = F.intPaymentMethodID
	
	
	

