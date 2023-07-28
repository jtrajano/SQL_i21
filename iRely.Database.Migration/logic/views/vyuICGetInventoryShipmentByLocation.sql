--liquibase formatted sql

-- changeset Von:vyuICGetInventoryShipmentByLocation.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetInventoryShipmentByLocation]
AS 

SELECT shipment.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICGetInventoryShipment shipment
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = shipment.intShipFromLocationId



