CREATE VIEW [dbo].[vyuICGetLocationBinsByLocation]
AS
SELECT b.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICGetLocationBins b
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = b.intLocationId