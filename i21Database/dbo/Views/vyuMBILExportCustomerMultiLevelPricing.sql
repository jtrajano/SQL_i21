CREATE VIEW [dbo].[vyuMBILExportCustomerMultiLevelPricing]
 AS   
	SELECT
		ROW_NUMBER() OVER(ORDER BY intItemPricingLevelId) AS intCustomerMultiLevelPricingId,        
		intEntityId =  null,      
		strCustomerNumber = null ,      
		strLevel = CLEVEL.strPricingLevelName,  
		PLEVEL.intItemPricingLevelId,      
		CLEVEL.intCompanyLocationId as intCompanyLocationPricingLevelId,      
		PLEVEL.intItemId,      
		ICITEM.strItemNo,      
		PLEVEL.intItemLocationId,      
		PLEVEL.strPriceLevel,      
		PLEVEL.intItemUnitMeasureId,      
		PLEVEL.dblUnit,      
		PLEVEL.dtmEffectiveDate,      
		PLEVEL.dblMin,      
		PLEVEL.dblMax,      
		PLEVEL.strPricingMethod,      
		PLEVEL.dblAmountRate,      
		PLEVEL.dblUnitPrice,      
		PLEVEL.strCommissionOn,      
		PLEVEL.dblCommissionRate,      
		PLEVEL.intCurrencyId 
	FROM 
		tblETExportFilterItem ITEM
	INNER JOIN
		tblICItem ICITEM ON ITEM.intItemId = ICITEM.intItemId
	INNER JOIN
		tblICItemPricingLevel PLEVEL ON ITEM.intItemId = PLEVEL.intItemId
	INNER JOIN 
		tblSMCompanyLocationPricingLevel CLEVEL ON PLEVEL.intCompanyLocationPricingLevelId = CLEVEL.intCompanyLocationPricingLevelId
	--INNER JOIN tblARCustomer CUSTOMER WITH (NOLOCK) ON CLEVEL.strPricingLevelName = CUSTOMER.strLevel
	