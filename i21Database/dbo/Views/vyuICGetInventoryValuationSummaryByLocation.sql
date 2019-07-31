CREATE VIEW [dbo].[vyuICGetInventoryValuationSummaryByLocation]
AS 
SELECT v.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM tblICInventoryValuationSummary v
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = v.intLocationId