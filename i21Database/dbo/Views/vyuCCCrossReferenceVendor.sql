CREATE VIEW [dbo].[vyuCCCrossReferenceVendor]
AS
SELECT CRV.intCrossReferenceVendorId,
    CRV.intCrossReferenceId,
    CRV.strImportValue,
    CRV.intVendorDefaultId,
    EM.strName strVendorName,
	EM.strEntityNo strVendorNo,
    CRV.intConcurrencyId
FROM tblCCCrossReferenceVendor CRV
LEFT JOIN tblCCVendorDefault VD ON VD.intVendorDefaultId = CRV.intVendorDefaultId
LEFT JOIN tblEMEntity EM ON EM.intEntityId = VD.intVendorId
