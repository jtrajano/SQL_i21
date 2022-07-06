CREATE VIEW vyuMFInventoryTransferInTransitLots
AS
SELECT cl.intCompanyLocationId
	,cl.strLocationName strCompanyLocationName
	,clsl.strSubLocationName
	,l.intStorageLocationId
	,sl.strName strStorageLocationName
	,R.strDisplayMember AS strRestrictionType
	,l.intItemId
	,i.strItemNo
	,i.strDescription strItemDescription
	,i.strManufactureType strItemManufactureType
	,ic.strCategoryCode strItemCategory
	,ic.intCategoryId
	,Com.strCommodityCode
	,strOwnershipType = (
		CASE 
			WHEN l.intOwnershipType = 1
				THEN 'Own'
			WHEN l.intOwnershipType = 2
				THEN 'Storage'
			WHEN l.intOwnershipType = 3
				THEN 'Consigned Purchase'
			WHEN l.intOwnershipType = 4
				THEN 'Consigned Sale'
			END
		) COLLATE Latin1_General_CI_AS
	,e2.strEntityNo + ' - ' + e2.strName AS strOwner
	,e2.intEntityId AS intEntityId
	,pl.strParentLotNumber
	,l.intLotId
	,l.strLotNumber
	,l.strLotAlias
	,l.dtmDateCreated
	,ITD.dblQuantity dblTransferQty
	,um.strUnitMeasure AS strTransferQtyUOM
	,l.dblWeightPerQty
	,ITD.dblNet AS dblTransferWeight
	,um1.strUnitMeasure AS strTransferWeightUOM
	,ITD.dblCost dblTransferCost
	,l.dtmManufacturedDate
	,l.dtmExpiryDate
	,ls.strPrimaryStatus
	,ls.strSecondaryStatus
	,l.strContractNo
	,l.strContainerNo
	,LI.strReceiptNumber AS strReceiptNo
	,LI.dtmReceiptDate
	,e.strName strVendor
	,l.strVendorLotNo
	,l.strBOLNo
	,l.strVessel
	,l.strMarkings
	,l.strNotes
	,l.intEntityVendorId
	,l.strGarden
	,CA.strDescription AS strGrade
	,l.intSeasonCropYear AS intCropYear
	,LI.strVendorRefNo
	,LI.strWarehouseRefNo
	,ls.strBackColor
	,IT.strTransferNo
	,IT.dtmTransferDate
	,ShipVia.strName strShipVia
	,ToCL.strLocationName strToLocationName
	,ToCSL.strSubLocationName strToSubLocationName
	,ToSL.strName strToStorageLocationName
	,S.strStatus strTransferStatus
	,LI.ysnPrinted
	,LI.dtmLastPrinted
	,e3.strName AS strPrintedBy
	,ITD.intInventoryTransferDetailId
FROM dbo.tblICInventoryTransferDetail ITD
JOIN dbo.tblICInventoryTransfer IT ON IT.intInventoryTransferId = ITD.intInventoryTransferId
	AND ysnShipmentRequired = 1
	AND IT.intStatusId = 2
JOIN dbo.tblICStatus S ON S.intStatusId = IT.intStatusId
JOIN dbo.tblICLot l ON l.intLotId = ITD.intLotId
JOIN dbo.tblICItem i ON i.intItemId = l.intItemId
JOIN dbo.tblICCategory ic ON ic.intCategoryId = i.intCategoryId
JOIN dbo.tblICCommodity Com ON Com.intCommodityId = i.intCommodityId
JOIN dbo.tblICLotStatus ls ON ls.intLotStatusId = l.intLotStatusId
JOIN dbo.tblICItemUOM ium ON ium.intItemUOMId = ITD.intItemUOMId
JOIN dbo.tblICUnitMeasure um ON um.intUnitMeasureId = ium.intUnitMeasureId
JOIN dbo.tblSMCompanyLocation cl ON cl.intCompanyLocationId = l.intLocationId
JOIN dbo.tblSMCompanyLocationSubLocation clsl ON clsl.intCompanyLocationSubLocationId = l.intSubLocationId
JOIN dbo.tblICStorageLocation sl ON sl.intStorageLocationId = l.intStorageLocationId
JOIN dbo.tblSMCompanyLocation ToCL ON ToCL.intCompanyLocationId = IT.intToLocationId
JOIN dbo.tblSMCompanyLocationSubLocation ToCSL ON ToCSL.intCompanyLocationSubLocationId = ITD.intToSubLocationId
JOIN dbo.tblICStorageLocation ToSL ON ToSL.intStorageLocationId = ITD.intToStorageLocationId
JOIN dbo.tblICParentLot pl ON pl.intParentLotId = l.intParentLotId
JOIN dbo.tblMFLotInventory LI ON LI.intLotId = l.intLotId
JOIN dbo.tblEMEntity ShipVia ON ShipVia.intEntityId = IT.intShipViaId
LEFT JOIN dbo.tblICRestriction R ON R.intRestrictionId = sl.intRestrictionId
LEFT JOIN dbo.tblICItemUOM ium1 ON ium1.intItemUOMId = ISNULL(ITD.intItemWeightUOMId, ITD.intItemUOMId)
LEFT JOIN dbo.tblICUnitMeasure um1 ON um1.intUnitMeasureId = ium1.intUnitMeasureId
LEFT JOIN dbo.tblEMEntity e ON e.intEntityId = l.intEntityVendorId
LEFT JOIN dbo.tblICCommodityAttribute CA ON CA.intCommodityAttributeId = l.intGradeId
LEFT JOIN dbo.tblICItemOwner ito1 ON ito1.intItemOwnerId = l.intItemOwnerId
LEFT JOIN dbo.tblEMEntity e2 ON e2.intEntityId = ito1.intOwnerId
LEFT JOIN dbo.tblEMEntity e3 ON e3.intEntityId = LI.intPrintedById
