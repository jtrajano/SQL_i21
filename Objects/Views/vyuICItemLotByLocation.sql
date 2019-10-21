CREATE VIEW [dbo].[vyuICItemLotByLocation]
AS

SELECT lot.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICItemLot lot
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = lot.intLocationId