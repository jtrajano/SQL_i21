CREATE VIEW vyuICGetItemVendorPricing
AS

SELECT	vp.intVendorPricingId
		,i.intItemId 
		,i.strItemNo	
		,e.strName
		,strEntityLocation = el.strLocationName			
		,vp.dtmBeginDate
		,vp.dtmEndDate
		,vp.dblUnit
		,u.strUnitMeasure
		,c.strCurrency
FROM	tblICItem i INNER JOIN tblAPVendorPricing vp 
			ON i.intItemId = vp.intItemId 
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