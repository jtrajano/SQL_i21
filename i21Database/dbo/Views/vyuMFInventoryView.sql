CREATE VIEW vyuMFInventoryView
AS
SELECT l.intLotId
	,l.strLotNumber
	,l.dblLastCost
	,l.dtmDateCreated
	,l.dtmExpiryDate
	,l.strLotAlias
	,l.dblQty
	,l.dblWeightPerQty
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
		WHEN l.intWeightUOMId IS NULL
			THEN l.dblQty
		ELSE l.dblWeight
		END AS dblWeight
	,l.intWeightUOMId
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
	,(Select Top 1 RL.strContainerNo from tblICInventoryReceiptItemLot RL Where RL.strLotNumber =l.strLotNumber) AS strContainerNo
	,ISNULL(S.dblQty, 0) AS dblReservedQty
	,Convert(DECIMAL(18, 4), ISNULL(S.dblQty, 0) / CASE 
			WHEN ISNULL(l.dblWeightPerQty, 0) = 0
				THEN 1
			ELSE l.dblWeightPerQty
			END) AS dblReservedNoOfPacks
	,CASE 
		WHEN l.intWeightUOMId IS NULL
			THEN l.dblQty
		ELSE l.dblWeight
		END - ISNULL(S.dblQty, 0) dblAvailableQty
	,Convert(DECIMAL(18, 4), (
			(
				CASE 
					WHEN l.intWeightUOMId IS NULL
						THEN l.dblQty
					ELSE l.dblWeight
					END - ISNULL(S.dblQty, 0)
				) / CASE 
				WHEN ISNULL(l.dblWeightPerQty, 0) = 0
					THEN 1
				ELSE l.dblWeightPerQty
				END
			)) dblAvailableNoOfPacks
	,um1.strUnitMeasure AS strReservedQtyUOM
	,CA.strDescription as strGrade
	,LI.intItemOwnerId
	,R.strDisplayMember As strRestrictionType
	,LS1.strSecondaryStatus As strBondStatus
	,LI.strVendorRefNo
	,LI.strWarehouseRefNo 
	,LI.strReceiptNumber As strReceiptNo
	,LI.dtmReceiptDate
	,CAST(0 AS BIT) AS ysnPartialPallet
FROM tblICLot l
JOIN tblICItem i ON i.intItemId = l.intItemId
JOIN tblICCategory ic ON ic.intCategoryId = i.intCategoryId
JOIN tblICLotStatus ls ON ls.intLotStatusId = l.intLotStatusId
LEFT JOIN tblSMUserSecurity us ON us.[intEntityUserSecurityId] = l.intCreatedUserId
JOIN tblICItemUOM ium ON ium.intItemUOMId = l.intItemUOMId
JOIN tblICUnitMeasure um ON um.intUnitMeasureId = ium.intUnitMeasureId
LEFT JOIN tblSMCompanyLocationSubLocation clsl ON clsl.intCompanyLocationSubLocationId = l.intSubLocationId
LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = l.intStorageLocationId
Left JOIN dbo.tblICRestriction R on R.intRestrictionId =sl.intRestrictionId 
LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = clsl.intCompanyLocationId
LEFT JOIN tblICItemUOM ium1 ON ium1.intItemUOMId = ISNULL(l.intWeightUOMId, l.intItemUOMId)
LEFT JOIN tblICUnitMeasure um1 ON um1.intUnitMeasureId = ium1.intUnitMeasureId
LEFT JOIN tblICParentLot pl ON pl.intParentLotId = l.intParentLotId
LEFT JOIN tblEMEntity e ON e.intEntityId = l.intEntityVendorId
LEFT JOIN vyuMFStockReservation S ON S.intLotId = l.intLotId
Left JOIN dbo.tblICCommodityAttribute CA on CA.intCommodityAttributeId =l.intGradeId 
LEFT JOIN tblMFLotInventory LI ON LI.intLotId = l.intLotId
LEFT JOIN tblICItemOwner ito1 ON ito1.intItemOwnerId = LI.intItemOwnerId 
LEFT JOIN tblEMEntity e2 ON e2.intEntityId = ito1.intOwnerId
Left JOIN dbo.tblICLotStatus LS1 ON LS1.intLotStatusId =LI.intBondStatusId