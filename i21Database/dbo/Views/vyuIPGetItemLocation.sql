CREATE VIEW [dbo].[vyuIPGetItemLocation]
AS
SELECT IL.intItemId
	,IL.strDescription
	,intCostingMethod
	,intAllowNegativeInventory
	,intGrossUOMId
	,intFamilyId
	,intClassId
	,intProductCodeId
	,intFuelTankId
	,IL.strPassportFuelId1
	,IL.strPassportFuelId2
	,IL.strPassportFuelId3
	,IL.ysnTaxFlag1
	,IL.ysnTaxFlag2
	,IL.ysnTaxFlag3
	,IL.ysnTaxFlag4
	,IL.ysnPromotionalItem
	,intMixMatchId
	,IL.ysnDepositRequired
	,intDepositPLUId
	,intBottleDepositNo
	,IL.ysnSaleable
	,IL.ysnQuantityRequired
	,IL.ysnScaleItem
	,IL.ysnFoodStampable
	,IL.ysnReturnable
	,IL.ysnPrePriced
	,IL.ysnOpenPricePLU
	,IL.ysnLinkedItem
	,IL.strVendorCategory
	,IL.ysnCountBySINo
	,IL.strSerialNoBegin
	,IL.strSerialNoEnd
	,IL.ysnIdRequiredLiquor
	,IL.ysnIdRequiredCigarette
	,intMinimumAge
	,IL.ysnApplyBlueLaw1
	,IL.ysnApplyBlueLaw2
	,IL.ysnCarWash
	,intItemTypeCode
	,intItemTypeSubCode
	,IL.ysnAutoCalculateFreight
	,intFreightMethodId
	,IL.dblFreightRate
	,intShipViaId
	,intNegativeInventory
	,IL.dblReorderPoint
	,IL.dblMinOrder
	,IL.dblSuggestedQty
	,IL.dblLeadTime
	,IL.strCounted
	,IL.ysnCountedDaily
	,intAllowZeroCostTypeId
	,IL.ysnLockedInventory
	,IL.ysnStorageUnitRequired
	,IL.strStorageUnitNo
	,intCostAdjustmentType
	,IL.intSort
	,IL.intConcurrencyId
	,IL.dtmDateCreated
	,IL.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
	,V.strVendorId
	,SM.strLocationName
	,IUM.strUnitMeasure AS strIssueUnitMeasure
	,RUM.strUnitMeasure AS strReceiveUnitMeasure
	,CG.strCountGroup
	,SV.strName AS strShipVia
	,SL.strName AS strStorageLocation
	,SubL.strSubLocationName
	,DS.strSourceName
FROM tblICItemLocation IL
JOIN tblSMCompanyLocation SM ON SM.intCompanyLocationId = IL.intLocationId
LEFT JOIN tblAPVendor V ON V.intEntityId = IL.intVendorId
LEFT JOIN tblICItemUOM IIU ON IIU.intItemUOMId = IL.intIssueUOMId
LEFT JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IIU.intUnitMeasureId
LEFT JOIN tblICItemUOM RIU ON RIU.intItemUOMId = IL.intReceiveUOMId
LEFT JOIN tblICUnitMeasure RUM ON RUM.intUnitMeasureId = RIU.intUnitMeasureId
LEFT JOIN tblICCountGroup CG ON CG.intCountGroupId = IL.intCountGroupId
LEFT JOIN tblSMShipVia SV ON SV.intEntityId = IL.intShipViaId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = IL.intStorageLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SubL ON SubL.intCompanyLocationSubLocationId = IL.intSubLocationId
LEFT JOIN tblICDataSource DS ON DS.intDataSourceId = IL.intDataSourceId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IL.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IL.intModifiedByUserId
