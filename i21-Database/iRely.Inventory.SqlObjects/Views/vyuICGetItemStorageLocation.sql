CREATE VIEW [dbo].[vyuICGetItemStorageLocation]
AS 
SELECT
      intItemId              = i.intItemId
    , strItemNo              = i.strItemNo 
    , intSubLocationId       = subloc.intCompanyLocationSubLocationId
	, intLocationId          = il.intLocationId
	, strSubLocationName     = subloc.strSubLocationName
	, intStorageLocationId   = sl.intStorageLocationId
	, strStorageLocationName = sl.strName
	, strStorageLocationDesc = sl.strDescription
FROM tblICItem i
    INNER JOIN tblICItemLocation il ON i.intItemId = il.intItemId
    INNER JOIN tblSMCompanyLocationSubLocation subloc ON subloc.intCompanyLocationId = il.intLocationId
	INNER JOIN tblICStorageLocation sl ON sl.intSubLocationId = subloc.intCompanyLocationSubLocationId