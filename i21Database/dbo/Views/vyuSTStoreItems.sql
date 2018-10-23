CREATE VIEW vyuSTStoreItems
AS
SELECT 
	I.intItemId
    , I.strItemNo
    , I.strDescription
    , I.strLotTracking
    , I.intCategoryId
    , IL.intLocationId
    , CL.strLocationName
    , I.ysnFuelItem
    , I.strType
    , I.strStatus
	, ST.intStoreId
FROM tblICItem I
JOIN tblICItemLocation IL
	ON I.intItemId = IL.intItemId
JOIN tblSMCompanyLocation CL
    ON IL.intLocationId = CL.intCompanyLocationId
JOIN tblSTStore ST
	ON CL.intCompanyLocationId = ST.intCompanyLocationId