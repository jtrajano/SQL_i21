CREATE VIEW [dbo].[vyuICGetStorageBinsByLocation]
AS

SELECT b.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICGetStorageBins b
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = b.intCompanyLocationId