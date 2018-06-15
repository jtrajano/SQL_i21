CREATE VIEW [dbo].[vyuSTCigaretteRebatePrograms]
AS
SELECT        
CRP.intCigaretteRebateProgramId
, CRP.strStoreIdList
, CRP.intEntityVendorId
, CRP.dtmStartDate
, CRP.dtmEndDate
, CRP.strPromotionType
, CRP.strProgramName
, CRP.dblManufacturerBuyDownAmount
, CRP.ysnMultipackFGI
, CRP.strManufacturerPromotionDescription
, CRP.dblManufacturerDiscountAmount
, CRP.intConcurrencyId
, UOM.intItemUOMId
, UM.strUnitMeasure
, UOM.strUpcCode
, (CASE WHEN LEN(UOM.strLongUPCCode) = 12 THEN '00' + UOM.strLongUPCCode WHEN LEN(UOM.strLongUPCCode) = 8 THEN '000000' + UOM.strLongUPCCode ELSE UOM.strLongUPCCode END)
    AS strLongUPCCode
, IC.strDescription AS strItemDescription
FROM dbo.tblSTCigaretteRebateProgramsDetails AS CRPD 
INNER JOIN dbo.tblSTCigaretteRebatePrograms AS CRP ON CRP.intCigaretteRebateProgramId = CRPD.intCigaretteRebateProgramId 
INNER JOIN dbo.tblICItemUOM AS UOM ON UOM.intItemUOMId = CRPD.intItemUOMId 
INNER JOIN dbo.tblICUnitMeasure AS UM ON UM.intUnitMeasureId = UOM.intUnitMeasureId 
INNER JOIN dbo.tblICItem AS IC ON IC.intItemId = UOM.intItemId