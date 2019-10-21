CREATE VIEW [dbo].[vyuICGetInventoryShipmentByLocation]
AS 

SELECT shipment.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICGetInventoryShipment shipment
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = shipment.intShipFromLocationId