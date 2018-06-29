CREATE VIEW [dbo].[vyuICGetInventoryTransfer]
	AS 

SELECT intInventoryTransferId
	, strTransferNo
	, dtmTransferDate
	, strTransferType
	, intSourceType
	, strSourceType = (CASE WHEN intSourceType = 0 THEN 'None'
			WHEN intSourceType = 1 THEN 'Scale'
			WHEN intSourceType = 2 THEN 'Inbound Shipment'
			WHEN intSourceType = 3 THEN 'Transports' END)
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
FROM tblICInventoryTransfer InvTransfer
	LEFT JOIN tblEMEntity Entity ON Entity.intEntityId = InvTransfer.intTransferredById
	LEFT JOIN tblSMCompanyLocation FromLocation ON FromLocation.intCompanyLocationId = InvTransfer.intFromLocationId
	LEFT JOIN tblSMCompanyLocation ToLocation ON ToLocation.intCompanyLocationId = InvTransfer.intToLocationId
	LEFT JOIN tblICStatus InvStatus ON InvStatus.intStatusId = InvTransfer.intStatusId
	LEFT JOIN tblEMEntity UserEntity ON UserEntity.intEntityId = InvTransfer.intEntityId