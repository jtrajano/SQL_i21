CREATE VIEW [dbo].[vyuApiVendorRebateCustomer]
AS

SELECT
      xc.intCustomerXrefId
    , xc.intEntityId
    , e.strName strEntityName
    , xc.intVendorSetupId
    , xc.strVendorCustomer
    , xc.intConcurrencyId
    , xc.guiApiUniqueId
FROM tblVRCustomerXref xc
LEFT JOIN tblEMEntity e ON e.intEntityId = xc.intEntityId