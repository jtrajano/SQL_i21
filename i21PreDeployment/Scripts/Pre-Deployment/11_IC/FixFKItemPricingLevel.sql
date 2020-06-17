IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICItemPricingLevel]') AND type in (N'U')) 
BEGIN 
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'intCompanyLocationPricingLevelId' AND OBJECT_ID = OBJECT_ID(N'tblICItemPricingLevel')) 
    BEGIN
		EXEC('ALTER TABLE [tblICItemPricingLevel] ADD [intCompanyLocationPricingLevelId] INT NULL')
    END

	IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[vyuICGetItemPricingLevel]') AND type in (N'V')) 
	BEGIN 
		EXEC('
			ALTER VIEW [dbo].[vyuICGetItemPricingLevel]
			AS
			SELECT	intItemPricingLevelId	= PricingLevel.intItemPricingLevelId
					,col.intCompanyLocationPricingLevelId
					,intItemId				= PricingLevel.intItemId
					,strItemNo				= Item.strItemNo
					,strDescription			= Item.strDescription
					,strType				= Item.strType
					,strStatus				= Item.strStatus
					,intCommodityId			= Item.intCommodityId
					,strCommodity			= Commodity.strCommodityCode
					,intCategoryId			= Item.intCategoryId
					,strCategory			= Category.strCategoryCode
					,strLotTracking			= Item.strLotTracking			
					,intLocationId			= ItemLocation.intLocationId
					,strLocationName		= CompanyLocation.strLocationName
					,strPriceLevel			= col.strPricingLevelName
					,intItemUnitMeasureId	= PricingLevel.intItemUnitMeasureId
					,strUnitMeasure			= um.strUnitMeasure
					,strUPC					= ItemUOM.strUpcCode
					,dblMin					= PricingLevel.dblMin
					,dblMax					= PricingLevel.dblMax
					,strPricingMethod		= PricingLevel.strPricingMethod
					,dblUnit				= PricingLevel.dblUnit
					,dtmEffectiveDate		= PricingLevel.dtmEffectiveDate
					,dblAmountRate			= PricingLevel.dblAmountRate
					,dblUnitPrice			= PricingLevel.dblUnitPrice
					,strCommissionOn		= PricingLevel.strCommissionOn
					,dblCommissionRate		= PricingLevel.dblCommissionRate
					,intCurrencyId			= PricingLevel.intCurrencyId
					,strCurrency			= Currency.strCurrency
					,intSort				= PricingLevel.intSort
					,dtmDateChanged			= PricingLevel.dtmDateChanged
					,intConcurrencyId		= PricingLevel.intConcurrencyId
			FROM tblICItemPricingLevel PricingLevel
			INNER JOIN tblICItem Item
				ON Item.intItemId = PricingLevel.intItemId
			INNER JOIN tblICItemLocation ItemLocation
				ON ItemLocation.intItemLocationId = PricingLevel.intItemLocationId
			INNER JOIN tblSMCompanyLocation CompanyLocation
				ON CompanyLocation.intCompanyLocationId = ItemLocation.intLocationId
			LEFT OUTER JOIN tblSMCompanyLocationPricingLevel col 
				ON col.intCompanyLocationPricingLevelId = PricingLevel.intCompanyLocationPricingLevelId
				--ON col.intCompanyLocationId =  CompanyLocation.intCompanyLocationId
				--AND LOWER(PricingLevel.strPriceLevel) = LOWER(col.strPricingLevelName)
			LEFT JOIN tblSMCurrency Currency
				ON Currency.intCurrencyID = PricingLevel.intCurrencyId
			LEFT JOIN (
					tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure um
						ON ItemUOM.intUnitMeasureId = um.intUnitMeasureId
				) ON ItemUOM.intItemUOMId = PricingLevel.intItemUnitMeasureId
			LEFT JOIN tblICCategory Category
				ON Category.intCategoryId = Item.intCategoryId
			LEFT JOIN tblICCommodity Commodity
				ON Commodity.intCommodityId = Item.intCommodityId		
		')
	END 

	-- Special fix for Fort books: 
	IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblSMCompanySetup]') AND type in (N'U')) 	
	BEGIN 
		EXEC ('
			IF EXISTS (SELECT TOP 1 1 FROM tblSMCompanySetup WHERE strCompanyName = LTRIM(RTRIM(''iRely LLC.'')))
			BEGIN
				UPDATE tblICItemPricingLevel
				SET strPriceLevel = 
					CASE 
						WHEN strPriceLevel = ''Level 1'' THEN ''Level 1 (1-10 Users)''
						WHEN strPriceLevel = ''Level 2'' THEN ''Level 2 (11-20 Users)''
						WHEN strPriceLevel = ''Level 3'' THEN ''Level 3 (21-50 Users)''
						else 
							strPriceLevel
					END
			END
		')
	END 

	-- Generic data fix: 
	BEGIN 
		EXEC ('
			UPDATE ipl
			SET 
				ipl.[intCompanyLocationPricingLevelId] = spl.intCompanyLocationPricingLevelId	
			FROM 
				tblICItemPricingLevel ipl LEFT JOIN tblICItemLocation il
					ON ipl.intItemLocationId = il.intItemLocationId	
				LEFT JOIN tblSMCompanyLocation cl
					ON cl.intCompanyLocationId = il.intLocationId
				LEFT JOIN tblSMCompanyLocationPricingLevel spl 
					ON spl.strPricingLevelName = ipl.strPriceLevel
					AND spl.intCompanyLocationId = il.intLocationId
			WHERE
				ipl.intCompanyLocationPricingLevelId IS NULL 
				AND spl.strPricingLevelName IS NOT NULL 		
		')
	END 


END 
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICItemPricingLevel]') AND type in (N'U')) 
BEGIN 
	EXEC(
		'IF EXISTS (SELECT TOP 1 1 FROM tblICItemPricingLevel WHERE intCompanyLocationPricingLevelId IS NULL)
		RAISERROR(''Please contact IC team. Auto data fix for item pricing failed. It needs a custom data fix before upgrading to this build.'', 16, 1);'
	)
END

GO
