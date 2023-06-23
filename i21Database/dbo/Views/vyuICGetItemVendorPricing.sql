CREATE VIEW vyuICGetItemVendorPricing
AS

SELECT	vp.intVendorPricingId
		,i.intItemId 
		,i.strItemNo	
		,i.strDescription
		,e.strName
		,strEntityLocation = el.strLocationName			
		,vp.dtmBeginDate
		,vp.dtmEndDate
		,vp.dblUnit
		,u.strUnitMeasure
		,c.strCurrency
		,vp.intEntityVendorId
		,i.strStatus
		,i.strLotTracking
		,i.strType
		,co.strCommodityCode AS strCommodity
		,cat.strCategoryCode AS strCategory
FROM	tblICItem i INNER JOIN tblAPVendorPricing vp 
			ON i.intItemId = vp.intItemId 
		left outer join tblICCommodity co on co.intCommodityId = i.intCommodityId
		left outer join tblICCategory cat on cat.intCategoryId = i.intCategoryId
		LEFT JOIN tblEMEntity e
			ON e.intEntityId = vp.intEntityVendorId
		LEFT JOIN tblEMEntityLocation el
			ON el.intEntityLocationId = vp.intEntityLocationId 
		LEFT JOIN (
			tblICItemUOM iu INNER JOIN tblICUnitMeasure u
				ON iu.intUnitMeasureId = u.intUnitMeasureId
		)
			ON iu.intItemUOMId = vp.intItemUOMId
		LEFT JOIN tblSMCurrency c
			ON c.intCurrencyID = vp.intCurrencyId