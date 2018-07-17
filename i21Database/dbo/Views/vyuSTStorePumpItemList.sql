CREATE VIEW vyuSTStorePumpItemList
AS
SELECT 
	I.intItemId
	,I.strItemNo
	,I.strShortName
	,I.strDescription as strPumpItemDescription
	,I.intCategoryId
	,C.strCategoryCode
	,C.strDescription as strCategoryDescription
	,UOM.strUpcCode
	,UOM.strLongUPCCode
	,UOM.intItemUOMId
	,CL.intCompanyLocationId
	,CL.strLocationName 
	,I.ysnFuelItem
	,IP.dblSalePrice as dblPrice
	,IL.intFamilyId
	,IL.intClassId
	,SPI.intStorePumpItemId
	,SPI.intStoreId
	,I.strType
	,I.strStatus
	,I.strLotTracking
FROM tblICItem I
INNER JOIN tblICItemUOM UOM 
	ON I.intItemId = UOM.intItemId
INNER JOIN tblICItemLocation IL 
	ON UOM.intItemId =  IL.intItemId
INNER JOIN tblICItemPricing IP 
	ON IP.intItemLocationId = IL.intItemLocationId
INNER JOIN tblSMCompanyLocation CL 
	ON IL.intLocationId = CL.intCompanyLocationId
INNER JOIN tblSTStore ST 
	ON CL.intCompanyLocationId = ST.intCompanyLocationId
INNER JOIN tblSTPumpItem SPI 
	ON ST.intStoreId = SPI.intStoreId
LEFT JOIN tblICCategory C 
	ON SPI.intCategoryId = C.intCategoryId
--where I.strType = 'Inventory'
--and I.strStatus = 'Active'
WHERE SPI.intItemUOMId =  UOM.intItemUOMId