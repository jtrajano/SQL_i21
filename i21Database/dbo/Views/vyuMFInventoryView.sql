CREATE VIEW vyuMFInventoryView
AS
SELECT l.intLotId
	,l.strLotNumber
	,Case When CP.ysnCostEnabled =1 Then dbo.fnGetLotUnitCost(l.intLotId) Else l.dblLastCost End AS dblLastCost
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
	,l.strContainerNo
	,ISNULL(S.dblWeight, 0) AS dblReservedQty
	,Convert(DECIMAL(18, 4), ISNULL(S.dblWeight, 0) / CASE 
			WHEN ISNULL(l.dblWeightPerQty, 0) = 0
				THEN 1
			ELSE l.dblWeightPerQty
			END) AS dblReservedNoOfPacks
	,CASE 
		WHEN l.intWeightUOMId IS NULL
			THEN l.dblQty
		ELSE l.dblWeight
		END - ISNULL(S.dblWeight, 0) dblAvailableQty
	,Convert(DECIMAL(18, 4), (
			(
				CASE 
					WHEN l.intWeightUOMId IS NULL
						THEN l.dblQty
					ELSE l.dblWeight
					END - ISNULL(S.dblWeight, 0)
				) / CASE 
				WHEN ISNULL(l.dblWeightPerQty, 0) = 0
					THEN 1
				ELSE l.dblWeightPerQty
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
					AND (l.dblQty % (i.intUnitPerLayer * i.intLayerPerPallet) > 0)
					AND (l.dblQty <= (i.intUnitPerLayer * i.intLayerPerPallet))
					)
				THEN 1
			ELSE 0
			END AS BIT) AS ysnPartialPallet
	,l.intUnitPallet
	,LI.intWorkOrderId
	,mp.intAttributeTypeId
	,ISNULL(RC.strReportName, 'LotLabel') AS strReportName
	,ISNULL(RC.intNoOfLabel, 1) AS intNoOfLabel
	,ISNULL(RCC.strReportName, 'PalletTag') AS strPlacardReportName
FROM tblICLot l
JOIN tblICItem i ON i.intItemId = l.intItemId
JOIN tblICCategory ic ON ic.intCategoryId = i.intCategoryId
JOIN tblICLotStatus ls ON ls.intLotStatusId = l.intLotStatusId
LEFT JOIN tblSMUserSecurity us ON us.[intEntityId] = l.intCreatedUserId
JOIN tblICItemUOM ium ON ium.intItemUOMId = l.intItemUOMId
JOIN tblICUnitMeasure um ON um.intUnitMeasureId = ium.intUnitMeasureId
LEFT JOIN tblSMCompanyLocationSubLocation clsl ON clsl.intCompanyLocationSubLocationId = l.intSubLocationId
LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = l.intStorageLocationId
LEFT JOIN dbo.tblICRestriction R ON R.intRestrictionId = sl.intRestrictionId
LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = clsl.intCompanyLocationId
LEFT JOIN tblICItemUOM ium1 ON ium1.intItemUOMId = ISNULL(l.intWeightUOMId, l.intItemUOMId)
LEFT JOIN tblICUnitMeasure um1 ON um1.intUnitMeasureId = ium1.intUnitMeasureId
LEFT JOIN tblICParentLot pl ON pl.intParentLotId = l.intParentLotId
LEFT JOIN tblEMEntity e ON e.intEntityId = l.intEntityVendorId
LEFT JOIN vyuMFStockReservation S ON S.intLotId = l.intLotId
LEFT JOIN dbo.tblICCommodityAttribute CA ON CA.intCommodityAttributeId = l.intGradeId
LEFT JOIN tblMFLotInventory LI ON LI.intLotId = l.intLotId
LEFT JOIN tblICItemOwner ito1 ON ito1.intItemOwnerId = l.intItemOwnerId
LEFT JOIN tblEMEntity e2 ON e2.intEntityId = ito1.intOwnerId
LEFT JOIN dbo.tblICLotStatus LS1 ON LS1.intLotStatusId = LI.intBondStatusId
LEFT JOIN tblMFManufacturingProcess mp ON LI.intManufacturingProcessId = mp.intManufacturingProcessId
Left JOIN tblMFCompanyPreference CP on 1=1
LEFT JOIN tblMFReportCategory RC ON RC.intCategoryId = ic.intCategoryId
LEFT JOIN tblMFReportCategoryByCustomer RCC ON RCC.intCategoryId = ic.intCategoryId
