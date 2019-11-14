CREATE VIEW dbo.vyuIPGetItemPricingLevel
AS
SELECT IPL.intItemId
	,CL.strLocationName
	,IPL.strPriceLevel
	,UM.strUnitMeasure
	,IPL.dblUnit
	,IPL.dtmEffectiveDate
	,IPL.dblMin
	,IPL.dblMax
	,IPL.strPricingMethod
	,IPL.dblAmountRate
	,IPL.dblUnitPrice
	,IPL.strCommissionOn
	,IPL.dblCommissionRate
	,C.strCurrency
	,IPL.intSort
	,IPL.dtmDateChanged
	,IPL.intConcurrencyId
	,IPL.dtmDateCreated
	,IPL.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemPricingLevel IPL
LEFT JOIN tblICItemLocation IL ON IL.intItemLocationId = IPL.intItemLocationId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IPL.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IPL.intModifiedByUserId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = IPL.intItemUnitMeasureId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = IPL.intCurrencyId
