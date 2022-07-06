CREATE VIEW [dbo].[vyuApiVendorRebatesSetup]
AS

SELECT 
      vrs.intVendorSetupId
    , vrs.intEntityId
    , e.strName strEntityName
    , vrs.strExportFileType
    , vrs.strExportFilePath
    , vrs.strBuybackExportFileType
    , vrs.strBuybackExportFilePath
    , vrs.strCompany1Id
    , vrs.strCompany2Id
    , vrs.strMarketerAccountNo
    , vrs.strMarketerEmail
    , vrs.strDataFileTemplate
    , vrs.strReimbursementType
    , vrs.intAccountId
    , vrs.intConcurrencyId
    , vrs.guiApiUniqueId
FROM tblVRVendorSetup vrs
LEFT JOIN tblEMEntity e ON e.intEntityId = vrs.intEntityId