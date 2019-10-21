CREATE VIEW [dbo].[vyuICGetInventoryValuationByLocation]
AS

SELECT v.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICGetInventoryValuation v
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = v.intLocationId