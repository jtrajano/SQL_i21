CREATE VIEW [dbo].[vyuICItemUOMDetailByLocation]
AS
SELECT b.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICItemUOMDetail b
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = b.intLocationId