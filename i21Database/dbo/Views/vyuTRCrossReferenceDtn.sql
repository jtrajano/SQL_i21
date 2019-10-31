CREATE VIEW [dbo].[vyuTRCrossReferenceDtn]
AS 
SELECT CRB.intCrossReferenceDtnId,
    CRB.intCrossReferenceId,
    CRB.strType,
    CRB.strImportValue,
    CRB.intVendorId,
    EMV.strName strVendorName,
    CRB.intConcurrencyId
FROM tblTRCrossReferenceDtn CRB
LEFT JOIN tblEMEntity EMV ON EMV.intEntityId = CRB.intVendorId
