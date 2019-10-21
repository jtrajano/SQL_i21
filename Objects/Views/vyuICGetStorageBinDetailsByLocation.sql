CREATE VIEW [dbo].[vyuICGetStorageBinDetailsByLocation]
AS
SELECT b.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICGetStorageBinDetails b
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = b.intCompanyLocationId