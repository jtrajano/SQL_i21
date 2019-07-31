CREATE VIEW [dbo].[vyuICLotHistoryByLocation]
AS

SELECT history.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICLotHistory history
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = history.intLocationId