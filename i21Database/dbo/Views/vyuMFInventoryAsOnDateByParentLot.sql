CREATE VIEW vyuMFInventoryAsOnDateByParentLot
AS
SELECT IA.guidSessionId
	,CAST(ROW_NUMBER() OVER (
			ORDER BY IA.intCommodityId
				,IA.intItemId
			) AS INT) intKey
	,IA.intCommodityId
	,IA.strCommodityCode
	,IA.dtmFromDate
	,IA.dtmToDate
	,IV.intCategoryId
	,IV.strItemCategory AS strCategoryCode
	,IA.intLocationId
	,IA.strLocationName
	,IA.intItemId
	,IA.strItemNo
	,IA.strDescription
	,IV.intParentLotId
	,IV.strParentLotNumber
	,IV.strLotAlias
	,IV.strSecondaryStatus
	,IA.intItemUOMId
	,IA.strItemUOM
	,Sum(IA.dblOpeningQty) AS dblOpeningQty
	,Sum(IA.dblReceivedQty) AS dblReceivedQty
	,Sum(IA.dblInvoicedQty) AS dblInvoicedQty
	,Sum(IA.dblAdjustments) AS dblAdjustments
	,Sum(IA.dblTransfersReceived) AS dblTransfersReceived
	,Sum(IA.dblTransfersShipped) AS dblTransfersShipped
	,Sum(IA.dblInTransitInbound) AS dblInTransitInbound
	,Sum(IA.dblInTransitOutbound) AS dblInTransitOutbound
	,Sum(IA.dblConsumed) AS dblConsumed
	,Sum(IA.dblProduced) AS dblProduced
	,Sum(IA.dblClosingQty) AS dblClosingQty
	,IA.intConcurrencyId
	,IA.intCreatedByUserId
	,IA.strWarehouseRefNo
	,IA.strBondStatus
	,IA.strContainerNo
	,IV.strCertification
	,IV.strCertificationId
	,IV.dtmDateCreated
	,IV.intCropYear
	,IV.strProducer
	,IV.strGrade
	,IV.strMarkings
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
GROUP BY IA.guidSessionId
	,IA.intCommodityId
	,IA.strCommodityCode
	,IA.dtmFromDate
	,IA.dtmToDate
	,IV.intCategoryId
	,IV.strItemCategory
	,IA.intLocationId
	,IA.strLocationName
	,IA.intItemId
	,IA.strItemNo
	,IA.strDescription
	,IV.intParentLotId
	,IV.strParentLotNumber
	,IV.strLotAlias
	,IV.strSecondaryStatus
	,IA.intItemUOMId
	,IA.strItemUOM
	,IA.intConcurrencyId
	,IA.intCreatedByUserId
	,IA.strWarehouseRefNo
	,IA.strBondStatus
	,IA.strContainerNo
	,IV.strCertification
	,IV.strCertificationId
	,IV.dtmDateCreated
	,IV.intCropYear
	,IV.strProducer
	,IV.strGrade
	,IV.strMarkings
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
