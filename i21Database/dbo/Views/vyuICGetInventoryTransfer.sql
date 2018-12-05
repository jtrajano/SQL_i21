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
			COLLATE Latin1_General_CI_AS
	, intTransferredById
	, strTransferredBy = Entity.strName
	, strDescription
	, intFromLocationId
	, strFromLocation = FromLocation.strLocationName
	, intToLocationId
	, strToLocation = ToLocation.strLocationName
	, ysnShipmentRequired
	, Transfer.intStatusId
	, Status.strStatus
	, ysnPosted
	, strUser = Transfer.intEntityId
	, UserEntity.strName
	, Transfer.intSort
FROM tblICInventoryTransfer Transfer
	LEFT JOIN tblEMEntity Entity ON Entity.intEntityId = Transfer.intTransferredById
	LEFT JOIN tblSMCompanyLocation FromLocation ON FromLocation.intCompanyLocationId = Transfer.intFromLocationId
	LEFT JOIN tblSMCompanyLocation ToLocation ON ToLocation.intCompanyLocationId = Transfer.intToLocationId
	LEFT JOIN tblICStatus Status ON Status.intStatusId = Transfer.intStatusId
	LEFT JOIN tblEMEntity UserEntity ON UserEntity.intEntityId = Transfer.intEntityId