CREATE VIEW [dbo].[vyuICGetStorageUnitByLocation]
AS

SELECT su.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICGetStorageLocation su
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = su.intLocationId