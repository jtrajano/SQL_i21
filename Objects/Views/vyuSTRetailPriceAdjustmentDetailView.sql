CREATE VIEW [dbo].[vyuSTRetailPriceAdjustmentDetailView]
AS 

SELECT 
RetailPriceAdjustmentDetail.intRetailPriceAdjustmentId,
RetailPriceAdjustmentDetail.intRetailPriceAdjustmentDetailId,
RetailPriceAdjustmentDetail.intCompanyLocationId,
strLocationName = SMCompanyLocation.strLocationName,
RetailPriceAdjustmentDetail.strRegion,
RetailPriceAdjustmentDetail.strDistrict,
RetailPriceAdjustmentDetail.strState,
RetailPriceAdjustmentDetail.intEntityId,
strVendorName =  EMEntity.strName,
RetailPriceAdjustmentDetail.intCategoryId,
strCategoryCode  = ICCategory.strCategoryCode,
RetailPriceAdjustmentDetail.intManufacturerId,
RetailPriceAdjustmentDetail.intFamilyId,
strFamily = STSubcategoryFamily.strSubcategoryDesc,
RetailPriceAdjustmentDetail.intClassId,
strClass = STSubcategoryClass.strSubcategoryDesc,
RetailPriceAdjustmentDetail.intItemUOMId,
strCode  = ICItemUOM.strUpcCode,
RetailPriceAdjustmentDetail.strUpcDescription,
RetailPriceAdjustmentDetail.ysnPromo,
RetailPriceAdjustmentDetail.strPriceMethod,
RetailPriceAdjustmentDetail.dblFactor,
RetailPriceAdjustmentDetail.dblPrice,
RetailPriceAdjustmentDetail.dblLastCost,
--RetailPriceAdjustmentDetail.ysnActive,
--RetailPriceAdjustmentDetail.ysnOneTimeuse,
RetailPriceAdjustmentDetail.ysnChangeCost,
RetailPriceAdjustmentDetail.dblCost,
RetailPriceAdjustmentDetail.dtmSalesStartDate,
RetailPriceAdjustmentDetail.dtmSalesEndDate,
--RetailPriceAdjustmentDetail.ysnPosted,
RetailPriceAdjustmentDetail.strPriceType

FROM tblSTRetailPriceAdjustmentDetail RetailPriceAdjustmentDetail
LEFT JOIN tblICItemUOM ICItemUOM ON RetailPriceAdjustmentDetail.intItemUOMId = ICItemUOM.intItemUOMId
LEFT JOIN tblICCategory ICCategory ON RetailPriceAdjustmentDetail.intCategoryId = ICCategory.intCategoryId
LEFT JOIN tblSTSubcategory STSubcategoryFamily ON RetailPriceAdjustmentDetail.intFamilyId = STSubcategoryFamily.intSubcategoryId
LEFT JOIN tblSTSubcategory STSubcategoryClass ON RetailPriceAdjustmentDetail.intClassId = STSubcategoryClass.intSubcategoryId
LEFT JOIN tblSMCompanyLocation SMCompanyLocation ON RetailPriceAdjustmentDetail.intCompanyLocationId = SMCompanyLocation.intCompanyLocationId
LEFT JOIN tblEMEntity EMEntity ON RetailPriceAdjustmentDetail.intEntityId = EMEntity.intEntityId