CREATE VIEW dbo.vyuIPGetItemSpecialPricing
AS
SELECT ISP.intItemId
	,CL.strLocationName
	,ISP.strPromotionType
	,ISP.dtmBeginDate
	,ISP.dtmEndDate
	,UM.strUnitMeasure
	,ISP.dblUnit
	,ISP.strDiscountBy
	,ISP.dblDiscount
	,ISP.dblUnitAfterDiscount
	,ISP.dblDiscountThruQty
	,ISP.dblDiscountThruAmount
	,ISP.dblAccumulatedQty
	,ISP.dblAccumulatedAmount
	,C.strCurrency
	,ISP.intSort
	,ISP.intConcurrencyId
	,ISP.dtmDateCreated
	,ISP.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemSpecialPricing ISP
LEFT JOIN tblICItemLocation IL ON IL.intItemLocationId = ISP.intItemLocationId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = ISP.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = ISP.intModifiedByUserId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = ISP.intItemUnitMeasureId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = ISP.intCurrencyId
