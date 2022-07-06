CREATE VIEW [dbo].[vyuApiVendorRebateUom]
AS

SELECT
      vx.intUOMXrefId
    , vx.intVendorSetupId
    , vx.intUnitMeasureId
    , u.strUnitMeasure
    , vx.strVendorUOM
    , vx.strEquipmentType
    , vx.intConcurrencyId
    , vx.guiApiUniqueId
FROM tblVRUOMXref vx
LEFT JOIN tblICUnitMeasure u ON u.intUnitMeasureId = vx.intUnitMeasureId