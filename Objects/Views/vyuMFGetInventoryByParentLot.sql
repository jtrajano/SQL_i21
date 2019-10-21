CREATE VIEW vyuMFGetInventoryByParentLot
AS
SELECT CAST(ROW_NUMBER() OVER (
			ORDER BY V.intParentLotId
				,V.intItemId
			) AS INT) intKey
	,V.dblLastCost
	,MIN(V.dtmDateCreated) AS dtmDateCreated
	,V.dtmExpiryDate
	,V.strLotAlias
	,SUM(ISNULL(V.dblQty, 0)) AS dblQty
	,V.dblWeightPerQty
	,V.strVendorLotNo
	,V.intItemId
	,V.intLocationId
	,V.intItemUOMId
	,V.intSubLocationId
	,V.intStorageLocationId
	,V.intLotStatusId
	,V.intParentLotId
	,SUM(ISNULL(V.dblWeight, 0)) AS dblWeight
	,V.intWeightUOMId
	,V.strBOLNo
	,V.strVessel
	,V.strMarkings
	,V.strNotes
	,V.strGarden
	,V.strContractNo
	,V.dtmManufacturedDate
	,V.strOwnershipType
	--,V.intConcurrencyId
	,V.strItemNo
	,V.strItemDescription
	,V.strItemType
	,V.strItemCategory
	,V.intCategoryId
	,V.strVendor
	,V.strPrimaryStatus
	,V.strSecondaryStatus
	,V.strUserName
	,V.strQtyUOM
	,V.strSubLocationName
	,V.intCompanyLocationSubLocationId
	,V.strStorageLocationName
	,V.strCompanyLocationName
	,V.intCompanyLocationId
	,V.strWeightUOM
	,V.strParentLotNumber
	,V.strOwner
	,V.intEntityId
	,V.strCurrency
	,V.strCostUOM
	,V.strContainerNo
	,SUM(ISNULL(V.dblReservedQty, 0)) AS dblReservedQty
	,SUM(ISNULL(V.dblReservedNoOfPacks, 0)) AS dblReservedNoOfPacks
	,SUM(ISNULL(V.dblAvailableQty, 0)) AS dblAvailableQty
	,SUM(ISNULL(V.dblAvailableNoOfPacks, 0)) AS dblAvailableNoOfPacks
	,V.strReservedQtyUOM
	,V.strGrade
	,V.strRestrictionType
	,V.strBondStatus
	,V.strVendorRefNo
	,V.strWarehouseRefNo
	,V.strReceiptNo
	,V.dtmReceiptDate
	,V.intUnitPallet
	,MIN(V.intAge) AS intAge
	,MIN(V.intRemainingLife) AS intRemainingLife
	,MAX(V.dtmLastMoveDate) AS dtmLastMoveDate
	,V.intCropYear
	,V.strProducer
	,V.strCertification
	,V.strCertificationId
	,V.strTrackingNumber
FROM dbo.vyuMFInventoryView V
WHERE V.dblQty > 0
GROUP BY V.dblLastCost
	,V.dtmExpiryDate
	,V.strLotAlias
	,V.dblWeightPerQty
	,V.strVendorLotNo
	,V.intItemId
	,V.intLocationId
	,V.intItemUOMId
	,V.intSubLocationId
	,V.intStorageLocationId
	,V.intLotStatusId
	,V.intParentLotId
	,V.intWeightUOMId
	,V.strBOLNo
	,V.strVessel
	,V.strMarkings
	,V.strNotes
	,V.strGarden
	,V.strContractNo
	,V.dtmManufacturedDate
	,V.strOwnershipType
	--,V.intConcurrencyId
	,V.strItemNo
	,V.strItemDescription
	,V.strItemType
	,V.strItemCategory
	,V.intCategoryId
	,V.strVendor
	,V.strPrimaryStatus
	,V.strSecondaryStatus
	,V.strUserName
	,V.strQtyUOM
	,V.strSubLocationName
	,V.intCompanyLocationSubLocationId
	,V.strStorageLocationName
	,V.strCompanyLocationName
	,V.intCompanyLocationId
	,V.strWeightUOM
	,V.strParentLotNumber
	,V.strOwner
	,V.intEntityId
	,V.strCurrency
	,V.strCostUOM
	,V.strContainerNo
	,V.strReservedQtyUOM
	,V.strGrade
	,V.strRestrictionType
	,V.strBondStatus
	,V.strVendorRefNo
	,V.strWarehouseRefNo
	,V.strReceiptNo
	,V.dtmReceiptDate
	,V.intUnitPallet
	,V.intCropYear
	,V.strProducer
	,V.strCertification
	,V.strCertificationId
	,V.strTrackingNumber
