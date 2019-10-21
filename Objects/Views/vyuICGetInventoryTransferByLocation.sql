CREATE VIEW [dbo].[vyuICGetInventoryTransferByLocation]
	AS 

SELECT intInventoryTransferId
	, strTransferNo
	, dtmTransferDate
	, strTransferType
	, intSourceType
	, strSourceType = (CASE WHEN intSourceType = 0 THEN 'None'
			WHEN intSourceType = 1 THEN 'Scale'
			WHEN intSourceType = 2 THEN 'Inbound Shipment'
			WHEN intSourceType = 3 THEN 'Transports' END) COLLATE Latin1_General_CI_AS
	, intTransferredById
	, strTransferredBy = Entity.strName
	, strDescription
	, intFromLocationId
	, strFromLocation = FromLocation.strLocationName
	, intToLocationId
	, strToLocation = ToLocation.strLocationName
	, ysnShipmentRequired
	, InvTransfer.intStatusId
	, InvStatus.strStatus
	, ysnPosted
	, strUser = InvTransfer.intEntityId
	, UserEntity.strName
	, InvTransfer.intSort
	, InvTransfer.intConcurrencyId
	, ShipVia.strShipVia
	, InvTransfer.intShipViaId
    , permission.intEntityId intUserId
    , permission.intUserRoleID intRoleId
FROM tblICInventoryTransfer InvTransfer
	LEFT JOIN tblEMEntity Entity ON Entity.intEntityId = InvTransfer.intTransferredById
	LEFT JOIN tblSMCompanyLocation FromLocation ON FromLocation.intCompanyLocationId = InvTransfer.intFromLocationId
	LEFT JOIN tblSMCompanyLocation ToLocation ON ToLocation.intCompanyLocationId = InvTransfer.intToLocationId
	LEFT JOIN tblICStatus InvStatus ON InvStatus.intStatusId = InvTransfer.intStatusId
	LEFT JOIN tblEMEntity UserEntity ON UserEntity.intEntityId = InvTransfer.intEntityId
	LEFT JOIN tblSMShipVia ShipVia ON ShipVia.intEntityId = InvTransfer.intShipViaId
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = InvTransfer.intFromLocationId