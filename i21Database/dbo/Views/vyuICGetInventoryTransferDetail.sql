﻿CREATE VIEW [dbo].[vyuICGetInventoryTransferDetail]
AS

	SELECT TransferDetail.intInventoryTransferId
	, TransferDetail.intInventoryTransferDetailId
	, [Transfer].intFromLocationId
	, [Transfer].intToLocationId
	, [Transfer].strTransferNo
	, TransferDetail.intSourceId
	, strSourceNumber = (
		CASE WHEN [Transfer].intSourceType = 1 -- Scale
				THEN (SELECT TOP 1
			strTicketNumber
		FROM tblSCTicket
		WHERE intTicketId = TransferDetail.intSourceId)
			WHEN [Transfer].intSourceType = 2 -- Inbound Shipment
				THEN (SELECT TOP 1
			CAST(ISNULL(intTrackingNumber, 'Inbound Shipment not found!')AS NVARCHAR(50))
		FROM tblLGShipment
		WHERE intShipmentId = TransferDetail.intSourceId)
			WHEN [Transfer].intSourceType = 3 -- Transports
				THEN (SELECT TOP 1
			CAST(ISNULL(TransportView.strTransaction, 'Transport not found!')AS NVARCHAR(50))
		FROM vyuTRGetLoadReceipt TransportView
		WHERE TransportView.intLoadReceiptId = TransferDetail.intSourceId)
			ELSE NULL
			END
	)
	, TransferDetail.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, Item.strLotTracking
	, Item.intCommodityId
	, TransferDetail.intLotId
	, Lot.strLotNumber
	, ParentLot.intParentLotId
	, ParentLot.strParentLotNumber
	, Item.intLifeTime
	, Item.strLifeTimeType
	, TransferDetail.intFromSubLocationId
	, strFromSubLocationName = FromSubLocation.strSubLocationName
	, TransferDetail.intToSubLocationId
	, strToSubLocationName = ToSubLocation.strSubLocationName
	, TransferDetail.intFromStorageLocationId
	, strFromStorageLocationName = FromStorageLocation.strName
	, TransferDetail.intToStorageLocationId
	, strToStorageLocationName = ToStorageLocation.strName
	, TransferDetail.intItemUOMId
	, strUnitMeasure = ItemUOM.strUnitMeasure
	, strUnitMeasureSymbol = COALESCE(NULLIF(ItemUOM.strSymbol, ''), NULLIF(ItemUOM.strUnitMeasure, ''))
	, dblItemUOMCF = ItemUOM.dblUnitQty
	, intWeightUOMId = TransferDetail.intItemWeightUOMId
	, strWeightUOM = ItemWeightUOM.strUnitMeasure
	, dblWeightUOMCF = ItemWeightUOM.dblUnitQty
	, TaxCode.strTaxCode
	, strAvailableUOM = CASE WHEN ISNULL(Lot.intLotId, '') = '' THEN StockFrom.strUnitMeasure ELSE Lot.strItemUOM END
	, StockFrom.dblLastCost
	, StockFrom.dblOnHand
	, StockFrom.dblOnOrder
	, StockFrom.dblReservedQty
	, dblAvailableQty = 
			CASE	WHEN [Transfer].ysnPosted = 1 THEN 						
						CASE	WHEN TransferDetail.intOwnershipType = 1 THEN -- Own
									TransferDetail.dblOriginalAvailableQty
								WHEN TransferDetail.intOwnershipType = 2 THEN -- Storage
									TransferDetail.dblOriginalStorageQty
								ELSE	-- Consigned Purchase
									TransferDetail.dblOriginalAvailableQty
						END
					ELSE	
						CASE	WHEN Lot.intLotId IS NOT NULL THEN 
										Lot.dblQty										
								ELSE	
									CASE WHEN TransferDetail.intOwnershipType = 1 THEN 
											StockFrom.dblAvailableQty
										ELSE 
											StockFrom.dblStorageQty
									END 
						END
			END 
	, TransferDetail.dblQuantity
	, TransferDetail.intOwnershipType
	, strOwnershipType = (CASE WHEN TransferDetail.intOwnershipType = 1 THEN 'Own'
								WHEN TransferDetail.intOwnershipType = 2 THEN 'Storage'
								WHEN TransferDetail.intOwnershipType = 3 THEN 'Consigned Purchase'
								ELSE NULL END)
	, [Transfer].ysnPosted
	, ysnWeights
	, [Transfer].strDescription
	, COALESCE(TransferDetail.strItemType, Item.strType) AS strItemType
	, TransferDetail.dblGross
	, TransferDetail.dblNet
	, TransferDetail.dblTare
	, TransferDetail.intNewLotStatusId
	, TransferDetail.intGrossNetUOMId
	, strGrossNetUOM = GrossNetUOM.strUnitMeasure
	, strGrossNetUOMSymbol = COALESCE(GrossNetUOM.strSymbol, GrossNetUOM.strUnitMeasure)
	, dblGrossNetUnitQty = TransferDetail.dblGrossNetUnitQty
	, dblItemUnitQty = TransferDetail.dblItemUnitQty
	, [Transfer].dtmTransferDate
	, [Transfer].ysnShipmentRequired
	, strTransferredBy = e.strName
	, strFromLocationName = FromLoc.strLocationName
	, strToLocationName = ToLoc.strLocationName
	, stat.strStatus
	, strTransferFromAddress = [dbo].[fnARFormatCustomerAddress](
		DEFAULT
		,DEFAULT 
		,DEFAULT 
		,FromLoc.strAddress
		,FromLoc.strCity
		,FromLoc.strStateProvince
		,FromLoc.strZipPostalCode
		,FromLoc.strCountry
		,DEFAULT 
		,DEFAULT 
	)
	, strTransferToAddress = [dbo].[fnARFormatCustomerAddress](
		DEFAULT
		,DEFAULT 
		,DEFAULT 
		,ToLoc.strAddress
		,ToLoc.strCity
		,ToLoc.strStateProvince
		,ToLoc.strZipPostalCode
		,ToLoc.strCountry
		,DEFAULT 
		,DEFAULT 
	)
	, Receipt.strWarehouseRefNo
	, TransferDetail.strLotCondition
	, TransferDetail.dblWeightPerQty
	FROM tblICInventoryTransferDetail TransferDetail
		LEFT JOIN tblICInventoryTransfer [Transfer] ON [Transfer].intInventoryTransferId = TransferDetail.intInventoryTransferId
		LEFT JOIN tblEMEntity e ON e.intEntityId = [Transfer].intTransferredById
		LEFT JOIN tblICItem Item ON Item.intItemId = TransferDetail.intItemId
		LEFT JOIN tblICStatus stat ON stat.intStatusId = [Transfer].intStatusId
		LEFT JOIN vyuICGetLot Lot ON Lot.intLotId = TransferDetail.intLotId
		LEFT JOIN tblSMCompanyLocation FromLoc ON FromLoc.intCompanyLocationId = [Transfer].intFromLocationId
		LEFT JOIN tblSMCompanyLocation ToLoc ON ToLoc.intCompanyLocationId = [Transfer].intToLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation FromSubLocation ON FromSubLocation.intCompanyLocationSubLocationId = TransferDetail.intFromSubLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation ToSubLocation ON ToSubLocation.intCompanyLocationSubLocationId = TransferDetail.intToSubLocationId
		LEFT JOIN tblICStorageLocation FromStorageLocation ON FromStorageLocation.intStorageLocationId = TransferDetail.intFromStorageLocationId
		LEFT JOIN tblICStorageLocation ToStorageLocation ON ToStorageLocation.intStorageLocationId = TransferDetail.intToStorageLocationId
		LEFT JOIN vyuICGetItemUOM ItemUOM ON ItemUOM.intItemUOMId = TransferDetail.intItemUOMId
		LEFT JOIN vyuICGetItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = TransferDetail.intItemWeightUOMId
		LEFT JOIN vyuICGetItemUOM GrossNetUOM ON GrossNetUOM.intItemUOMId = TransferDetail.intGrossNetUOMId
		LEFT JOIN tblSMTaxCode TaxCode ON TaxCode.intTaxCodeId = TransferDetail.intTaxCodeId
		LEFT JOIN vyuICGetItemStockUOM StockFrom ON StockFrom.intItemId = TransferDetail.intItemId
			AND StockFrom.intLocationId = [Transfer].intFromLocationId
			AND StockFrom.intItemUOMId = TransferDetail.intItemUOMId
			AND ISNULL(StockFrom.intSubLocationId, 0) = ISNULL(TransferDetail.intFromSubLocationId, 0)
			AND ISNULL(StockFrom.intStorageLocationId, 0) = ISNULL(TransferDetail.intFromStorageLocationId, 0)
			AND StockFrom.intLotId = Lot.intLotId
		LEFT JOIN (tblICInventoryReceiptItem ReceiptItem INNER JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId)
			ON ReceiptItem.intOrderId = [Transfer].intInventoryTransferId AND Receipt.strReceiptType = 'Transfer Order'
		LEFT JOIN tblICParentLot ParentLot ON ParentLot.intParentLotId = Lot.intParentLotId 
			AND ParentLot.intItemId = TransferDetail.intItemId 
			AND TransferDetail.intLotId = Lot.intLotId

