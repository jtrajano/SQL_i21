
CREATE VIEW [dbo].[vyuCCVendor]
WITH SCHEMABINDING
	AS 
SELECT DISTINCT
    A.intVendorDefaultId,
	B.intEntityVendorId intEntityId,	
	B.intEntityVendorId intVendorId,
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
	A.strEnterTotalsAsGrossOrNet,
	A.strImportFilePath,
	A.strImportFileName,
	A.strImportAuxiliaryFileName,
	A.intImportFileHeaderId,
	D.strAddress
FROM
     dbo.tblCCVendorDefault A
	INNER JOIN dbo.tblCCDealerSite AS I
	    ON I.intVendorDefaultId = A.intVendorDefaultId
	INNER JOIN dbo.tblAPVendor B
		ON A.intVendorId = B.intEntityVendorId
	INNER JOIN dbo.tblEMEntity C
		ON B.intEntityVendorId = C.intEntityId
	LEFT JOIN dbo.[tblEMEntityLocation] D
		ON D.intEntityId = C.intEntityId  and D.ysnActive = 1
    LEFT Join dbo.tblSMTerm E
	    on E.intTermID = D.intTermsId
    LEFT Join dbo.tblSMPaymentMethod F
	    on F.intPaymentMethodID = B.intPaymentMethodId
	LEFT JOIN dbo.tblSMCompanyLocation G
		ON G.intCompanyLocationId = A.intCompanyLocationId
    LEFT JOIN dbo.tblCMBankAccount H
		ON A.intBankAccountId = H.intBankAccountId
	
	
	

