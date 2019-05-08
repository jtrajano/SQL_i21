CREATE VIEW vyuSTLocationItems
AS
SELECT DISTINCT
	I.intItemId -- Unique by intItemId
    , I.strItemNo
    , I.strDescription
    , I.strLotTracking
    , I.intCategoryId
    , IL.intLocationId
    , CL.strLocationName
    , I.ysnFuelItem
    , I.strType
    , I.strStatus
FROM tblICItem I
JOIN tblICItemLocation IL
	ON I.intItemId = IL.intItemId
JOIN tblSMCompanyLocation CL
    ON IL.intLocationId = CL.intCompanyLocationId