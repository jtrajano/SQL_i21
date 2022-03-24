CREATE VIEW [dbo].[vyuSTInventoryItem]
AS 
SELECT        
	I.intItemId
	, I.ysnFuelItem
	, I.strDescription
	, I.strStatus
	, IL.intLocationId
	, UOM.intItemUOMId
	, ST.intStoreId	
	, IL.intVendorId
	, IL.intFamilyId
	, subFamily.strSubcategoryId	AS strFamily
	, IL.intClassId
	, subClass.strSubcategoryId		AS strClass
	--, IP.dblSalePrice
	, ISNULL(
		(
			(CASE
					WHEN (CAST(GETDATE() AS DATE) BETWEEN SplPrc.dtmBeginDate AND SplPrc.dtmEndDate)
						THEN SplPrc.dblUnitAfterDiscount -- Promotion Price ,  Inventory > Items > Pricing > Promotional Pricing & Exemptions Tab > Retail Price Columns
					WHEN (CAST(GETDATE() AS DATE) >= effectivePrice.dtmEffectiveRetailPriceDate)
						THEN effectivePrice.dblRetailPrice -- Effective Retail Price , Inventory > Items > Pricing > With Effective Date Tab > Price Group >  Retail Price column
				END)
		  ) , 0 
	    ) AS dblSalePrice
	, UM.strUnitMeasure
	, UOM.strUpcCode
	, UOM.strLongUPCCode
	, V.strVendorId
	, CL.strLocationName
FROM dbo.tblICItem AS I 
INNER JOIN dbo.tblICItemUOM AS UOM 
	ON I.intItemId = UOM.intItemId 
INNER JOIN dbo.tblICUnitMeasure AS UM 
	ON UOM.intUnitMeasureId = UM.intUnitMeasureId 
INNER JOIN dbo.tblICItemLocation AS IL 
	ON I.intItemId = IL.intItemId 
LEFT JOIN dbo.tblSTSubcategory subFamily
	ON IL.intFamilyId = subFamily.intSubcategoryId
LEFT JOIN dbo.tblSTSubcategory subClass
	ON IL.intClassId = subClass.intSubcategoryId
LEFT JOIN dbo.tblAPVendor AS V 
	ON IL.intVendorId = V.intEntityId 
INNER JOIN dbo.tblSMCompanyLocation AS CL 
	ON IL.intLocationId = CL.intCompanyLocationId 
INNER JOIN dbo.tblSTStore AS ST 
	ON CL.intCompanyLocationId = ST.intCompanyLocationId 
INNER JOIN dbo.tblICItemPricing AS IP 
	ON I.intItemId = IP.intItemId 
	AND IL.intItemLocationId = IP.intItemLocationId
LEFT JOIN 
(
	SELECT * FROM (
		SELECT 
				intItemId,
				intItemLocationId,
				dtmBeginDate,
				dtmEndDate,
				dblUnitAfterDiscount,
				row_number() over (partition by intItemId order by intItemLocationId asc) as intRowNum
		FROM tblICItemSpecialPricing
		WHERE CAST(GETDATE() AS DATE) BETWEEN dtmBeginDate AND dtmEndDate
	) AS tblSTItemOnFirstLocation WHERE intRowNum = 1
) AS SplPrc
	ON I.intItemId = SplPrc.intItemId
	AND IL.intItemLocationId = SplPrc.intItemLocationId
LEFT JOIN 
(
	SELECT * FROM (
		SELECT 
				intItemId,
				intItemLocationId,
				dtmEffectiveRetailPriceDate,
				dblRetailPrice,
				ROW_NUMBER() OVER (PARTITION BY intItemId ORDER BY dtmEffectiveRetailPriceDate DESC) AS intRowNum
		FROM tblICEffectiveItemPrice
		WHERE CAST(GETDATE() AS DATE) >= dtmEffectiveRetailPriceDate
	) AS tblSTItemOnFirstLocation WHERE intRowNum = 1
) AS effectivePrice
	ON I.intItemId = effectivePrice.intItemId
	AND effectivePrice.intItemLocationId = IL.intItemLocationId
GO


