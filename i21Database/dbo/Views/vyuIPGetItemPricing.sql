Create VIEW [dbo].[vyuIPGetItemPricing]
AS
SELECT ItemPricing.intItemId
	,CL.strLocationName
	,ItemPricing.[dblAmountPercent]
	,ItemPricing.[dblSalePrice]
	,ItemPricing.[dblMSRPPrice]
	,ItemPricing.[strPricingMethod]
	,ItemPricing.[dblLastCost]
	,ItemPricing.[dblStandardCost]
	,ItemPricing.[dblAverageCost]
	,ItemPricing.[dblEndMonthCost]
	,ItemPricing.[dblDefaultGrossPrice]
	,ItemPricing.[intSort]
	,ItemPricing.[ysnIsPendingUpdate]
	,ItemPricing.[dtmDateChanged]
	,ItemPricing.intConcurrencyId
	,ItemPricing.[intDataSourceId]
	,DS.strSourceName
	,ItemPricing.dtmDateCreated
	,ItemPricing.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemPricing ItemPricing
LEFT JOIN tblICDataSource DS ON DS.intDataSourceId = ItemPricing.intDataSourceId
LEFT JOIN tblICItemLocation IL ON IL.intItemLocationId = ItemPricing.intItemLocationId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = ItemPricing.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = ItemPricing.intModifiedByUserId
