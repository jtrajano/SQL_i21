CREATE VIEW vyuICShipmentInvoice2ByLocation
AS

SELECT Invoice.*
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM vyuICShipmentInvoice2 Invoice
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = Invoice.intLocationId