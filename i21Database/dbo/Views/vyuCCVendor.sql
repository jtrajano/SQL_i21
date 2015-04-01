
CREATE VIEW [dbo].[vyuCCVendor]
WITH SCHEMABINDING
	AS 
SELECT 
    A.intVendorDefaultId,
	B.intEntityId,	
	B.intVendorId,
	G.intCompanyLocationId,
	G.strLocationName,
	B.intPaymentMethodId,
    F.strPaymentMethod,
	B.strVendorId,	
	C.strName, 
	E.strTerm,
    E.intTermID,
	A.intBankAccountId,
	H.strCbkNo,
	A.strApType,
	A.strEnterTotalsAsGrossOrNet

FROM
     dbo.tblCCVendorDefault A
	INNER JOIN dbo.tblAPVendor B
		ON A.intVendorId = B.intVendorId
	INNER JOIN dbo.tblEntity C
		ON B.intEntityId = C.intEntityId
	LEFT JOIN dbo.tblEntityLocation D
		ON B.intDefaultLocationId = D.intEntityLocationId    
    LEFT Join dbo.tblSMTerm E
	    on D.intTermsId = E.intTermID
    LEFT Join dbo.tblSMPaymentMethod F
	    on B.intPaymentMethodId = F.intPaymentMethodID
	LEFT JOIN dbo.tblSMCompanyLocation G
		ON A.intCompanyLocationId = G.intCompanyLocationId
    LEFT JOIN dbo.tblCMBankAccount H
		ON A.intBankAccountId = H.intBankAccountId
	
	
	

