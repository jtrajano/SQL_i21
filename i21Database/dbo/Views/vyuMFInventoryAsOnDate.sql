CREATE VIEW vyuMFInventoryAsOnDate
AS
SELECT IA.guidSessionId
	,CAST(ROW_NUMBER() OVER (
			ORDER BY IA.intCommodityId
				,IA.intItemId
			) AS INT) AS intKey
	,IA.intCommodityId
	,IA.strCommodityCode
	,IA.dtmFromDate
	,IA.dtmToDate
	,IV.intCategoryId
	,IV.strItemCategory strCategoryCode
	,IA.intLocationId
	,IA.strLocationName
	,IA.intItemId
	,IA.strItemNo
	,IA.strDescription
	,IV.intParentLotId
	,IV.strParentLotNumber
	,IV.strLotNumber
	,IV.strLotAlias
	,IV.strSecondaryStatus
	,IA.intItemUOMId
	,IA.strItemUOM
	,IA.dblOpeningQty
	,IA.dblReceivedQty
	,IA.dblInvoicedQty
	,IA.dblAdjustments
	,IA.dblTransfersReceived
	,IA.dblTransfersShipped
	,IA.dblInTransitInbound
	,IA.dblInTransitOutbound
	,IA.dblConsumed
	,IA.dblProduced
	,IA.dblClosingQty
	,IA.intConcurrencyId
	--,IA.dtmDateCreated  
	,IA.intCreatedByUserId
	--,IA.strVendorRefNo  
	,IA.strWarehouseRefNo
	,IA.strBondStatus
	,IA.strContainerNo
	,IV.strCertification
	,IV.strCertificationId
	,IV.dtmDateCreated
	,IV.intCropYear
	,IV.strProducer
	,IV.strGrade
	,IV.strNotes
	,IV.dtmManufacturedDate
	,IV.strOwner
	,IV.strOwnershipType
	,IV.strReceiptNumber
	,IV.strRestrictionType
	,IV.strSubLocationName
	,IV.dtmExpiryDate
	,IV.strStorageLocationName
	,IV.strTrackingNumber
	,IV.intUnitPallet
	,IV.strVendorLotNo
	,IV.strVendorRefNo
	,IV.dblWeightPerQty
FROM dbo.tblMFInventoryAsOnDate IA
JOIN dbo.vyuMFInventoryView IV ON IV.intLotId = IA.intLotId
	--Select *from vyuMFInventoryAsOnDate
