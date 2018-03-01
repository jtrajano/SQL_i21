CREATE VIEW [dbo].[vyuICGetItemRunningStock]
	AS
SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY i.intItemId, ItemLocation.intLocationId, t.dtmDate) AS INT)
	,i.intItemId
	,i.strItemNo 
	,ItemLocation.intLocationId
	,strLocationName			= CompanyLocation.strLocationName
	,t.intSubLocationId
	,SubLocation.strSubLocationName
	,t.intStorageLocationId
	,strStorageLocationName		= strgLoc.strName
	,l.intLotId
	,l.strLotNumber
	,l.intOwnershipType
	,dtmAsOfDate				= dbo.fnRemoveTimeOnDate(t.dtmDate)
	,t.dblQty
FROM tblICInventoryTransaction t 
LEFT JOIN tblICItem i 
	ON i.intItemId = t.intItemId
LEFT JOIN tblICItemLocation ItemLocation 
	ON ItemLocation.intItemLocationId = t.intItemLocationId
LEFT JOIN tblSMCompanyLocation CompanyLocation 
	ON CompanyLocation.intCompanyLocationId = ItemLocation.intLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
	ON SubLocation.intCompanyLocationSubLocationId = t.intSubLocationId
LEFT JOIN tblICStorageLocation strgLoc 
	ON strgLoc.intStorageLocationId = t.intStorageLocationId
LEFT JOIN tblICLot l
	ON l.intLotId = t.intLotId