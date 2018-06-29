CREATE VIEW dbo.vyuICItemSubLocations
AS
SELECT sl.intItemSubLocationId, sl.intSubLocationId, sl.intItemLocationId,  sc.strSubLocationName, sl.intConcurrencyId
FROM tblICItemSubLocation sl
	INNER JOIN tblSMCompanyLocationSubLocation sc ON sc.intCompanyLocationSubLocationId = sl.intSubLocationId