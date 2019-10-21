CREATE VIEW [dbo].[vyuICGetItemSubLocation]
AS 
SELECT
      intItemId              = i.intItemId
    , strItemNo              = i.strItemNo 
    , intSubLocationId       = subloc.intCompanyLocationSubLocationId
	, intLocationId          = il.intLocationId
	, strSubLocationName     = subloc.strSubLocationName
	, strClassification      = subloc.strClassification
FROM tblICItem i
    INNER JOIN tblICItemLocation il ON i.intItemId = il.intItemId
    INNER JOIN tblSMCompanyLocationSubLocation subloc ON	subloc.intCompanyLocationId = il.intLocationId