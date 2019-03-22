CREATE VIEW [dbo].[vyuSTInventoryItem]
AS 
SELECT        
	I.intItemId
	, IL.intLocationId
	, UOM.intItemUOMId
	, ST.intStoreId
	, I.ysnFuelItem
	, I.strDescription
	, IL.intVendorId
	, IL.intFamilyId
	, IL.intClassId
	, IP.dblSalePrice
	, UM.strUnitMeasure
	, UOM.strUpcCode
	, UOM.strLongUPCCode
	,  V.strVendorId
	, CL.strLocationName
FROM dbo.tblICItem AS I 
INNER JOIN dbo.tblICItemUOM AS UOM 
	ON I.intItemId = UOM.intItemId 
INNER JOIN dbo.tblICUnitMeasure AS UM 
	ON UOM.intUnitMeasureId = UM.intUnitMeasureId 
INNER JOIN dbo.tblICItemLocation AS IL 
	ON I.intItemId = IL.intItemId 
LEFT JOIN dbo.tblAPVendor AS V 
	ON IL.intVendorId = V.intEntityId 
INNER JOIN dbo.tblSMCompanyLocation AS CL 
	ON IL.intLocationId = CL.intCompanyLocationId 
INNER JOIN dbo.tblSTStore AS ST 
	ON CL.intCompanyLocationId = ST.intCompanyLocationId 
INNER JOIN dbo.tblICItemPricing AS IP 
	ON I.intItemId = IP.intItemId 
	AND IL.intItemLocationId = IP.intItemLocationId