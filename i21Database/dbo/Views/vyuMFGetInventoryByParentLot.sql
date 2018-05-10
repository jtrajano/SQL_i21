CREATE VIEW [dbo].[vyuMFGetInventoryByParentLot]
	AS 
Select 
v.intParentLotId,
v.strParentLotNumber,
v.strItemNo,
v.strItemDescription AS strDescription,
SUM(ISNULL(v.dblQty,0)) AS dblQty,
MAX(v.strQtyUOM) AS strQtyUOM,
SUM(ISNULL(v.dblWeight,0)) AS dblWeight,
MAX(v.strWeightUOM) AS strWeightUOM,
v.intLocationId,
v.strCompanyLocationName AS strLocationName,
v.strSubLocationName,
v.intSubLocationId
FROM vyuMFInventoryView v 
Where v.dblQty>0 AND v.intParentLotId>0
Group By v.intParentLotId,v.intLocationId,v.strItemNo,v.strItemDescription,strParentLotNumber,v.strCompanyLocationName,v.strSubLocationName,v.intSubLocationId
