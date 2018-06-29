CREATE VIEW vyuMFInventoryViewAsonDate
AS
SELECT l.intLotId
	,l.strLotNumber
	,l.dblLastCost
	,l.dtmDateCreated
	,l.dtmExpiryDate
	,l.strLotAlias
	,SD.dblQty
	,SD.dblWeightPerQty
	,l.strVendorLotNo
	,l.intItemId
	,l.intLocationId
	,l.intItemLocationId
	,l.intItemUOMId
	,l.intSubLocationId
	,l.intStorageLocationId
	,l.intLotStatusId
	,l.intParentLotId
	,l.intSplitFromLotId
	,CASE 
		WHEN SD.intWeightUOMId IS NULL
			THEN SD.dblQty
		ELSE SD.dblWeight
		END AS dblWeight
	,SD.intWeightUOMId
	,l.intOriginId
	,l.strBOLNo
	,l.strVessel
	,l.strReceiptNumber
	,l.strMarkings
	,l.strNotes
	,l.intEntityVendorId
	,l.strGarden
	,l.strContractNo
	,l.dtmManufacturedDate
	,l.ysnReleasedToWarehouse
	,l.ysnProduced
	,l.ysnStorage
	,l.intOwnershipType
	,strOwnershipType = (CASE WHEN l.intOwnershipType = 1 THEN 'Own'
						WHEN l.intOwnershipType = 2 THEN 'Storage'
						WHEN l.intOwnershipType = 3 THEN 'Consigned Purchase'
						WHEN l.intOwnershipType = 4 THEN 'Consigned Sale'
						END)
	,l.intGradeId
	,l.intCreatedUserId
	,l.intConcurrencyId
	,i.strItemNo
	,i.strDescription strItemDescription
	,i.strType strItemType
	,ic.strCategoryCode strItemCategory
	,ic.intCategoryId
	,e.strName strVendor
	,ls.strPrimaryStatus
	,ls.strSecondaryStatus
	,us.strUserName
	,um.strUnitMeasure AS strQtyUOM
	,clsl.strSubLocationName
	,clsl.intCompanyLocationSubLocationId
	,sl.strName strStorageLocationName
	,cl.strLocationName strCompanyLocationName
	,cl.intCompanyLocationId
	,um1.strUnitMeasure AS strWeightUOM
	,pl.strParentLotNumber
	,e2.strEntityNo + ' - ' + e2.strName AS strOwner
	,e2.intEntityId AS intEntityId
	,'' AS strCurrency
	,'' AS strCostUOM
	,0 AS intContainerId
	,l.strContainerNo AS strContainerNo
	,ISNULL(S.dblWeight, 0) AS dblReservedQty
	,Convert(DECIMAL(18, 4), ISNULL(S.dblWeight, 0) / CASE 
			WHEN ISNULL(SD.dblWeightPerQty, 0) = 0
				THEN 1
			ELSE SD.dblWeightPerQty
			END) AS dblReservedNoOfPacks
	,CASE 
		WHEN SD.intWeightUOMId IS NULL
			THEN SD.dblQty
		ELSE SD.dblWeight
		END - ISNULL(S.dblWeight, 0) dblAvailableQty
	,Convert(DECIMAL(18, 4), (
			(
				CASE 
					WHEN SD.intWeightUOMId IS NULL
						THEN SD.dblQty
					ELSE SD.dblWeight
					END - ISNULL(S.dblWeight, 0)
				) / CASE 
				WHEN ISNULL(SD.dblWeightPerQty, 0) = 0
					THEN 1
				ELSE SD.dblWeightPerQty
				END
			)) dblAvailableNoOfPacks
	,um1.strUnitMeasure AS strReservedQtyUOM
	,CA.strDescription AS strGrade
	,l.intItemOwnerId
	,R.strDisplayMember AS strRestrictionType
	,LS1.strSecondaryStatus AS strBondStatus
	,LI.strVendorRefNo
	,LI.strWarehouseRefNo
	,LI.strReceiptNumber AS strReceiptNo
	,LI.dtmReceiptDate
	,CAST(CASE 
			WHEN (
					(i.intUnitPerLayer * i.intLayerPerPallet > 0)
					AND (SD.dblQty % (i.intUnitPerLayer * i.intLayerPerPallet) > 0)
					)
				THEN 1
			ELSE 0
			END AS BIT) AS ysnPartialPallet
	,SH.dtmDate dtmSnapshotDate
	,SD.intLotSnapshotDetail
	,l.intUnitPallet
	,ls.strBackColor
FROM tblICLot l
JOIN tblMFLotSnapshotDetail SD ON SD.intLotId = l.intLotId
JOIN tblMFLotSnapshot SH ON SD.intLotSnapshotId = SH.intLotSnapshotId
JOIN tblICItem i ON i.intItemId = SD.intItemId
JOIN tblICCategory ic ON ic.intCategoryId = i.intCategoryId
JOIN tblICLotStatus ls ON ls.intLotStatusId = SD.intLotStatusId
LEFT JOIN tblSMUserSecurity us ON us.intEntityId = l.intCreatedUserId
JOIN tblICItemUOM ium ON ium.intItemUOMId = SD.intItemUOMId
JOIN tblICUnitMeasure um ON um.intUnitMeasureId = ium.intUnitMeasureId
LEFT JOIN tblSMCompanyLocationSubLocation clsl ON clsl.intCompanyLocationSubLocationId = SD.intSubLocationId
LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = SD.intStorageLocationId
LEFT JOIN dbo.tblICRestriction R ON R.intRestrictionId = sl.intRestrictionId
LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = clsl.intCompanyLocationId
LEFT JOIN tblICItemUOM ium1 ON ium1.intItemUOMId = ISNULL(l.intWeightUOMId, l.intItemUOMId)
LEFT JOIN tblICUnitMeasure um1 ON um1.intUnitMeasureId = ium1.intUnitMeasureId
LEFT JOIN tblICParentLot pl ON pl.intParentLotId = SD.intParentLotId
LEFT JOIN tblEMEntity e ON e.intEntityId = l.intEntityVendorId
LEFT JOIN vyuMFStockReservation S ON S.intLotId = l.intLotId
LEFT JOIN dbo.tblICCommodityAttribute CA ON CA.intCommodityAttributeId = l.intGradeId
LEFT JOIN tblMFLotInventory LI ON LI.intLotId = l.intLotId
LEFT JOIN tblICItemOwner ito1 ON ito1.intItemOwnerId = l.intItemOwnerId
LEFT JOIN tblEMEntity e2 ON e2.intEntityId = ito1.intOwnerId
LEFT JOIN dbo.tblICLotStatus LS1 ON LS1.intLotStatusId = SD.intBondStatusId
