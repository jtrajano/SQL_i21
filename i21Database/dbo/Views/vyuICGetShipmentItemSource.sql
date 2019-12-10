CREATE VIEW [dbo].[vyuICGetShipmentItemSource]
AS 

SELECT
	ShipmentItem.intInventoryShipmentItemId,
	ShipmentItem.intOrderId,
	intContractSeq = CASE Shipment.intOrderType WHEN 1 THEN ContractView.intContractSeq ELSE NULL END,
	strOrderNumber = 
		(
			CASE 
				WHEN Shipment.intOrderType = 1 THEN -- Sales Contract
					ContractView.strContractNumber
				WHEN Shipment.intOrderType = 5 THEN -- Item Contract
					ItemContract.strContractNumber
				WHEN Shipment.intOrderType = 2 THEN -- Sales Order
					SODetail.strSalesOrderNumber
				WHEN Shipment.intOrderType = 3 THEN -- Transfer Order
					NULL	
				ELSE 
					NULL
			END
		),
	strSourceNumber =
		CASE WHEN Shipment.intSourceType = 1 -- Scale
				THEN ScaleView.strTicketNumber
			--WHEN Shipment.intSourceType = 2 -- Inbound Shipment
				--	THEN CONVERT(NVARCHAR(100), LogisticView.intTrackingNumber)
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
					CASE WHEN Shipment.intSourceType = 0 OR Shipment.intSourceType = 1 -- None OR Scale
						THEN CASE WHEN ContractView.ysnLoad = 1 THEN 'Load' ELSE ContractView.strItemUOM END
					--WHEN Shipment.intSourceType = 1 -- Scale
						--THEN NULL
					--WHEN Shipment.intSourceType = 2 -- Inbound Shipment
						--THEN NULL
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
					CASE WHEN Shipment.intSourceType = 0 OR Shipment.intSourceType = 1 -- None OR Scale
						THEN ISNULL(ContractView.dblDetailQuantity, 0)
					--WHEN Shipment.intSourceType = 1 -- Scale
					--	THEN 0
					--WHEN Shipment.intSourceType = 2 -- Inbound Shipment
						--THEN 0
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
	dblCost = retroactiveCost.dblCost,
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
FROM	
	tblICInventoryShipmentItem ShipmentItem 

	INNER JOIN tblICItem i 
		ON i.intItemId = ShipmentItem.intItemId		
	
	LEFT JOIN tblICInventoryShipment Shipment 
		ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId

	LEFT JOIN vyuSOSalesOrderDetail SODetail
		ON SODetail.intSalesOrderId = ShipmentItem.intOrderId 
		AND SODetail.intSalesOrderDetailId = ShipmentItem.intLineNo
		AND Shipment.intOrderType = 2

	LEFT JOIN vyuCTCompactContractDetailView ContractView 
		ON ContractView.intContractDetailId = ShipmentItem.intLineNo
		AND ContractView.intContractHeaderId = ShipmentItem.intOrderId
		AND Shipment.intOrderType = 1
			
	LEFT JOIN tblCTContractDetail ContractDetail 
		ON ContractDetail.intContractDetailId = ContractView.intContractDetailId

	LEFT JOIN tblCTItemContractHeader ItemContract 
		ON ItemContract.intItemContractHeaderId = ShipmentItem.intItemContractHeaderId

	LEFT JOIN tblSCTicket ScaleView
		ON ScaleView.intTicketId = ShipmentItem.intSourceId
		AND Shipment.intSourceType = 1

	LEFT JOIN tblEMEntityFarm ContractFarm 
		ON ContractFarm.intFarmFieldId = ContractDetail.intFarmFieldId

	LEFT JOIN tblSCTicket ticket 
		ON ticket.intTicketId = ShipmentItem.intSourceId

	LEFT JOIN tblEMEntityFarm ScaleFarm 
		ON ScaleFarm.intFarmFieldId = ticket.intFarmFieldId

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

	LEFT JOIN tblICItemUOM stockUOM
		ON stockUOM.intItemId = i.intItemId
		AND stockUOM.ysnStockUnit = 1

	OUTER APPLY (
		SELECT 
			il.intCostingMethod
			,il.intItemLocationId
		FROM 
			tblICItemLocation il 
		WHERE
			il.intItemId = i.intItemId
			AND il.intLocationId = Shipment.intShipFromLocationId	
	) costingMethod

	OUTER APPLY (
		SELECT 
			t.intItemUOMId
			,t.intInventoryTransactionId
			,dblCost = dbo.fnDivide(SUM(t.dblQty * t.dblCost), SUM(t.dblQty)) 
		FROM
			tblICInventoryTransaction t
		WHERE
			t.intItemId = i.intItemId
			AND t.strTransactionId = Shipment.strShipmentNumber
			AND t.intTransactionDetailId = ShipmentItem.intInventoryShipmentItemId
			AND t.dblQty < 0 
		GROUP BY 
			t.intItemUOMId
			,t.intInventoryTransactionId
	) postedTransaction	

	OUTER APPLY (
		SELECT TOP 1 
			t.intItemUOMId
			,dblLastCost = t.dblCost
			,t.intInventoryTransactionId
		FROM
			tblICInventoryTransaction t
		WHERE
			postedTransaction.intInventoryTransactionId IS NULL 
			AND t.intItemId = i.intItemId
			AND t.intItemLocationId = costingMethod.intItemLocationId
			AND dbo.fnDateLessThanEquals(t.dtmDate, Shipment.dtmShipDate) = 1
			AND t.dblQty > 0 
		ORDER BY
			t.intInventoryTransactionId DESC 	
	) invTransactions	

	OUTER APPLY(
		SELECT TOP 1
			dblCost
			, intItemUOMId
		FROM	
			tblICInventoryFIFO FIFO
		WHERE	
			costingMethod.intCostingMethod = 2
			AND FIFO.intItemId = i.intItemId 			
			AND FIFO.intItemLocationId = costingMethod.intItemLocationId 
			AND FIFO.dblStockIn - FIFO.dblStockOut > 0
			AND dbo.fnDateLessThanEquals(FIFO.dtmDate, Shipment.dtmShipDate) = 1
		ORDER BY FIFO.dtmDate ASC
	) FIFO

	OUTER APPLY(
		SELECT TOP 1
			dblCost
			, intItemUOMId
		FROM	
			tblICInventoryLIFO LIFO
		WHERE	
			costingMethod.intCostingMethod = 3
			AND LIFO.intItemId = i.intItemId 
			AND LIFO.intItemLocationId = costingMethod.intItemLocationId 
			AND LIFO.dblStockIn - LIFO.dblStockOut > 0
			AND dbo.fnDateLessThanEquals(LIFO.dtmDate, Shipment.dtmShipDate) = 1
		ORDER BY LIFO.dtmDate DESC
	) LIFO

	OUTER APPLY (
		SELECT 
			dblCost = CASE 
				WHEN postedTransaction.intInventoryTransactionId IS NOT NULL THEN 
					dbo.fnCalculateCostBetweenUOM(
						postedTransaction.intItemUOMId
						, ISNULL(ShipmentItem.intPriceUOMId, ShipmentItem.intItemUOMId)
						, postedTransaction.dblCost
					)				


				WHEN costingMethod.intCostingMethod = 1 AND invTransactions.intInventoryTransactionId IS NOT NULL THEN 
					dbo.fnCalculateCostBetweenUOM(
						stockUOM.intItemUOMId
						, ISNULL(ShipmentItem.intPriceUOMId, ShipmentItem.intItemUOMId)
						, dbo.fnICGetMovingAverageCost(
							i.intItemId
							,costingMethod.intItemLocationId
							,invTransactions.intInventoryTransactionId
						)
					)					

				WHEN costingMethod.intCostingMethod = 1 AND invTransactions.intInventoryTransactionId IS NULL THEN 
					dbo.fnCalculateCostBetweenUOM(
						stockUOM.intItemUOMId
						, ISNULL(ShipmentItem.intPriceUOMId, ShipmentItem.intItemUOMId)
						, dbo.fnGetItemAverageCost(
							i.intItemId
							, costingMethod.intItemLocationId
							, ISNULL(ShipmentItem.intPriceUOMId, ShipmentItem.intItemUOMId)
						)						
					)

				WHEN costingMethod.intCostingMethod = 2 THEN 
					dbo.fnCalculateCostBetweenUOM(
						FIFO.intItemUOMId
						, ISNULL(ShipmentItem.intPriceUOMId, ShipmentItem.intItemUOMId)
						, FIFO.dblCost
					)
				WHEN costingMethod.intCostingMethod = 3 THEN 
					dbo.fnCalculateCostBetweenUOM(
						LIFO.intItemUOMId
						, ISNULL(ShipmentItem.intPriceUOMId, ShipmentItem.intItemUOMId)
						, LIFO.dblCost
					)

				ELSE 
					dbo.fnCalculateCostBetweenUOM(
						invTransactions.intItemUOMId
						, ISNULL(ShipmentItem.intPriceUOMId, ShipmentItem.intItemUOMId)
						, invTransactions.dblLastCost
					)					
			END
	
	) retroactiveCost 

GO