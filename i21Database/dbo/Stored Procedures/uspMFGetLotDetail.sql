CREATE PROCEDURE [dbo].[uspMFGetLotDetail] 
(
	@intLotId				INT
  , @intTransactionTypeId	INT = 0
) 
AS
BEGIN
	DECLARE @intReasonCodeId	INT
		  , @strReasonCode		NVARCHAR(50)

	SELECT @intReasonCodeId = intReasonCodeId
		 , @strReasonCode	= strReasonCode
	FROM vyuMFGetReasonCode
	WHERE strReasonName = 'Inventory' AND ysnDefault = 1 AND intTransactionTypeId = @intTransactionTypeId
	ORDER BY intReasonCodeId DESC

	SELECT intLotId
		 , strLotNumber
		 , strItemNo
		 , strItemDescription
		 , strSubLocationName
		 , strStorageLocationName
		 , intItemUOMId
		 , strQtyUOM
		 , intWeightUOMId
		 , strWeightUOM
		 , strVendor
		 , strCurrency
		 , strCostUOM
		 , intContainerId
		 , strContainerNo
		 , strItemCategory
		 , intItemId
		 , intLocationId
		 , intItemLocationId
		 , intSubLocationId
		 , intStorageLocationId
		 , dblQty
		 , dblLastCost
		 , dtmExpiryDate
		 , strLotAlias
		 , intLotStatusId
		 , intParentLotId
		 , intSplitFromLotId
		 , dblWeight
		 , dblWeightPerQty
		 , intOriginId
		 , strBOLNo
		 , strVessel
		 , strReceiptNumber
		 , strMarkings
		 , strNotes
		 , intEntityVendorId
		 , strVendorLotNo
		 , strGarden
		 , strContractNo
		 , dtmManufacturedDate
		 , ysnReleasedToWarehouse
		 , ysnProduced
		 , ysnStorage
		 , intOwnershipType
		 , intGradeId
		 , dtmDateCreated
		 , intCreatedUserId
		 , intConcurrencyId
		 , intItemOwnerId
		 , strOwner
		 , strSecondaryStatus
		 , strParentLotNumber
		 , strVendorRefNo
		 , strWarehouseRefNo
		 , @intReasonCodeId AS intReasonCodeId
		 , @strReasonCode AS strReasonCode
		 , intCropYear
		 , strProducer
		 , strCertification
		 , strCertificationId
		 , strTrackingNumber
		 , dtmDueDate
		 , intLoadId
		 , strLoadNumber
		 , null AS intWorkOrderId
		 , null AS ysnInCustody
	FROM vyuMFInventoryView
	WHERE intLotId = @intLotId
END