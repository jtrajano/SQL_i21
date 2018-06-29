CREATE PROCEDURE uspMFGetLotDetail @intLotId INT
	,@intTransactionTypeId INT = 0
AS
BEGIN
	DECLARE @intReasonCodeId INT
		,@strReasonCode NVARCHAR(50)

	SELECT @intReasonCodeId = intReasonCodeId
		,@strReasonCode = strReasonCode
	FROM vyuMFGetReasonCode
	WHERE strReasonName = 'Inventory'
		AND ysnDefault = 1
		AND intTransactionTypeId = @intTransactionTypeId
	ORDER BY intReasonCodeId DESC

	SELECT intLotId
		,strLotNumber
		,strItemNo
		,strItemDescription
		,strSubLocationName
		,strStorageLocationName
		,dtmDateCreated
		,dtmExpiryDate
		,dblQty
		,intItemUOMId
		,strQtyUOM
		,dblWeight
		,intWeightUOMId
		,strWeightUOM
		,dblWeightPerQty
		,strLotAlias
		,strVendor
		,strVendorLotNo
		,strCurrency
		,dblLastCost
		,strCostUOM
		,intContainerId
		,strContainerNo
		,intOwnershipType
		,strItemCategory
		,intItemId
		,intLocationId
		,intItemLocationId
		,strLotNumber
		,intSubLocationId
		,intStorageLocationId
		,dblQty
		,dblLastCost
		,dtmExpiryDate
		,strLotAlias
		,intLotStatusId
		,intParentLotId
		,intSplitFromLotId
		,dblWeight
		,dblWeightPerQty
		,intOriginId
		,strBOLNo
		,strVessel
		,strReceiptNumber
		,strMarkings
		,strNotes
		,intEntityVendorId
		,strVendorLotNo
		,strGarden
		,strContractNo
		,dtmManufacturedDate
		,ysnReleasedToWarehouse
		,ysnProduced
		,ysnStorage
		,intOwnershipType
		,intGradeId
		,dtmDateCreated
		,intCreatedUserId
		,intConcurrencyId
		,intItemOwnerId
		,strOwner
		,strSecondaryStatus
		,strParentLotNumber
		,strVendorRefNo
		,strWarehouseRefNo
		,@intReasonCodeId AS intReasonCodeId
		,@strReasonCode AS strReasonCode
		,intCropYear
		,strProducer
		,strCertification
		,strCertificationId
		,strTrackingNumber
		,dtmDueDate
	FROM vyuMFInventoryView
	WHERE intLotId = @intLotId
END
