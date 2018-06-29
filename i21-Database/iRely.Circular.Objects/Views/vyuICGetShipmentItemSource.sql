﻿CREATE VIEW [dbo].[vyuICGetShipmentItemSource]
	AS 

SELECT
	ShipmentItem.intInventoryShipmentItemId,
	ShipmentItem.intOrderId,
	intContractSeq = CASE Shipment.intOrderType WHEN 1 THEN ContractView.intContractSeq ELSE NULL END,
	strOrderNumber = 
		(
			CASE WHEN Shipment.intOrderType = 1 -- Sales Contract
				THEN ContractView.strContractNumber
			WHEN Shipment.intOrderType = 2 -- Sales Order
				THEN SODetail.strSalesOrderNumber
			WHEN Shipment.intOrderType = 3 -- Transfer Order
				THEN NULL
			ELSE NULL
			END
		),
	strSourceNumber =
		CASE WHEN Shipment.intSourceType = 1 -- Scale
				THEN ScaleView.strTicketNumber
			WHEN Shipment.intSourceType = 2 -- Inbound Shipment
				THEN CONVERT(NVARCHAR(100), LogisticView.intTrackingNumber)
			WHEN Shipment.intSourceType = 3 -- Pick Lot
				THEN CONVERT(NVARCHAR(100), PickLot.[strPickLotNumber])
			WHEN Shipment.intSourceType = 4
				THEN DeliverySheetView.strDeliverySheetNumber COLLATE Latin1_General_CI_AS
			ELSE NULL
			END,
	strOrderUOM = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN (
					CASE WHEN Shipment.intSourceType = 0 -- None
						THEN CASE WHEN ContractView.ysnLoad = 1 THEN 'Load' ELSE ContractView.strItemUOM END
					WHEN Shipment.intSourceType = 1 -- Scale
						THEN NULL
					WHEN Shipment.intSourceType = 2 -- Inbound Shipment
						THEN NULL
					WHEN Shipment.intSourceType = 3 -- Pick Lot
						THEN PickLotUOM.strUnitMeasure
					ELSE NULL
					END
				)
			WHEN Shipment.intOrderType = 2
				THEN SODetail.strUnitMeasure
			WHEN Shipment.intOrderType = 3
				THEN NULL
			ELSE NULL
			END
		),
	dblQtyOrdered = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN (
					CASE WHEN Shipment.intSourceType = 0 -- None
						THEN ISNULL(ContractView.dblDetailQuantity, 0)
					WHEN Shipment.intSourceType = 1 -- Scale
						THEN 0
					WHEN Shipment.intSourceType = 2 -- Inbound Shipment
						THEN 0
					--WHEN Shipment.intSourceType = 3 -- Transport
						--THEN ISNULL(TransportView.dblOrderedQuantity, 0)
					WHEN Shipment.intSourceType = 3 -- Pick Lot
						THEN ISNULL(PickLotAllocation.dblSAllocatedQty, 0)
					ELSE NULL
					END
				)
			WHEN Shipment.intOrderType = 2
				THEN ISNULL(SODetail.dblQtyOrdered, 0.00)
			WHEN Shipment.intOrderType = 3
				THEN 0.00
			ELSE 0.00
			END
		),
	dblQtyAllocated = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN 0.00
			WHEN Shipment.intOrderType = 2
				THEN ISNULL(SODetail.dblQtyAllocated, 0.00)
			WHEN Shipment.intOrderType = 3
				THEN 0.00
			ELSE 0.00
			END
		),
	dblUnitPrice = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN 0.00
			WHEN Shipment.intOrderType = 2
				THEN ISNULL(SODetail.dblPrice, 0.00)
			WHEN Shipment.intOrderType = 3
				THEN 0.00
			ELSE 0.00
			END
		),
	dblDiscount = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN 0.00
			WHEN Shipment.intOrderType = 2
				THEN ISNULL(SODetail.dblDiscount, 0.00)
			WHEN Shipment.intOrderType = 3
				THEN 0.00
			ELSE 0.00
			END
		),
	dblTotal = 
		(
			CASE WHEN Shipment.intOrderType = 1
				THEN 0.00
			WHEN Shipment.intOrderType = 2
				THEN ISNULL(SODetail.dblTotal, 0.00)
			WHEN Shipment.intOrderType = 3
				THEN 0.00
			ELSE 0.00
			END
		),
	dblCost = ItemPricing.dblLastCost,
	strFieldNo = 
		CASE Shipment.intSourceType
			-- None
			WHEN 0 THEN ContractFarm.strFieldNumber
			-- Scale
			WHEN 1 THEN ScaleFarm.strFieldNumber
			ELSE NULL 
		END,
	ContractView.ysnLoad,
	ContractView.intNoOfLoad,
	ContractView.dblBalance,
	ContractView.dblQuantityPerLoad
FROM	tblICInventoryShipmentItem ShipmentItem LEFT JOIN tblICInventoryShipment Shipment 
			ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId

		LEFT JOIN vyuICGetItemPricing ItemPricing 
			ON ItemPricing.intUnitMeasureId = ShipmentItem.intItemUOMId 
			AND ItemPricing.intItemId = ShipmentItem.intItemId
			AND ItemPricing.intLocationId = Shipment.intShipFromLocationId			

		LEFT JOIN vyuSOSalesOrderDetail SODetail
			ON SODetail.intSalesOrderId = ShipmentItem.intOrderId 
			AND SODetail.intSalesOrderDetailId = ShipmentItem.intLineNo
			AND Shipment.intOrderType = 2

		LEFT JOIN vyuCTCompactContractDetailView ContractView -- Resolution. 
			ON ContractView.intContractDetailId = ShipmentItem.intLineNo
			AND ContractView.intContractHeaderId = ShipmentItem.intOrderId
			AND Shipment.intOrderType = 1
			
		LEFT JOIN tblCTContractDetail ContractDetail ON ContractDetail.intContractDetailId = ContractView.intContractDetailId
		--LEFT JOIN vyuTRGetLoadReceipt TransportView
		--	ON TransportView.intLoadReceiptId = ShipmentItem.intSourceId
		--	AND Shipment.intSourceType = 3

		LEFT JOIN tblSCTicket ScaleView
			ON ScaleView.intTicketId = ShipmentItem.intSourceId
			AND Shipment.intSourceType = 1
		LEFT JOIN tblEMEntityFarm ContractFarm ON ContractFarm.intFarmFieldId = ContractDetail.intFarmFieldId
		LEFT JOIN tblSCTicket ticket ON ticket.intTicketId = ShipmentItem.intSourceId
		LEFT JOIN tblEMEntityFarm ScaleFarm ON ScaleFarm.intFarmFieldId = ticket.intFarmFieldId
		LEFT JOIN tblSCDeliverySheet DeliverySheetView
			ON DeliverySheetView.intDeliverySheetId = ShipmentItem.intSourceId
			AND Shipment.intSourceType = 4

		LEFT JOIN tblLGShipment LogisticView
			ON LogisticView.intShipmentId = ShipmentItem.intSourceId
			AND Shipment.intSourceType = 2

		LEFT JOIN (
			tblLGPickLotHeader PickLot LEFT JOIN tblLGPickLotDetail PickLotDetail
				ON PickLotDetail.intPickLotHeaderId = PickLot.intPickLotHeaderId			
			LEFT JOIN tblLGAllocationDetail PickLotAllocation
				ON PickLotAllocation.intAllocationDetailId = PickLotDetail.intAllocationDetailId
			LEFT JOIN tblICUnitMeasure PickLotUOM
				ON PickLotUOM.intUnitMeasureId = PickLotDetail.intSaleUnitMeasureId
		)
			ON PickLot.intPickLotHeaderId = ShipmentItem.intSourceId
			 AND Shipment.intSourceType = 3		
GO