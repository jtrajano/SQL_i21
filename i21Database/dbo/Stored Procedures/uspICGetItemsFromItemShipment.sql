CREATE PROCEDURE [dbo].[uspICGetItemsFromItemShipment]
	@intShipmentId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT
		-- Header
		[intShipmentId]					= Shipment.intInventoryShipmentId
		,[strShipmentId]				= Shipment.strShipmentNumber
		,[intOrderType]					= Shipment.intOrderType
		,[intSourceType]				= Shipment.intSourceType
		,[dtmDate]						= Shipment.dtmShipDate
		,[intCurrencyId]				= NULL 
		,[dblExchangeRate]				= 1
		,[intEntityCustomerId]			= Shipment.intEntityCustomerId

		-- Detail 
		,[intInventoryShipmentItemId]	= ShipmentItem.intInventoryShipmentItemId
		,[intItemId]					= ShipmentItem.intItemId
		,[intLotId]						= Lot.intLotId
		,[strLotNumber]					= Lot.strLotNumber
		,[intLocationId]				= Shipment.intShipFromLocationId
		,[intItemLocationId]			= ItemLocation.intItemLocationId
		,[intSubLocationId]				= ShipmentItem.intSubLocationId
		,[intStorageLocationId]			= NULL 
		,[intItemUOMId]					= ShipmentItem.intItemUOMId
		,[intWeightUOMId]				= ShipmentItem.intWeightUOMId
		,[dblQty]						= --ShipmentItem.dblQuantity
		  CASE WHEN ShipmentItemLot.intInventoryShipmentItemLotId > 0
			   THEN ShipmentItemLot.dblQuantityShipped
			   ELSE ShipmentItem.dblQuantity
		  END
		,[dblUOMQty]					= ItemUOM.dblUnitQty
		,[dblNetWeight]					= ShipmentItemLot.dblGrossWeight - ShipmentItemLot.dblTareWeight
		,[dblSalesPrice]				= ShipmentItem.dblUnitPrice
		,[intDockDoorId]				= ShipmentItem.intDockDoorId
		,[intOwnershipType]				= ShipmentItem.intOwnershipType
		,[intOrderId]					= ShipmentItem.intOrderId
		,[intSourceId]					= ShipmentItem.intSourceId
		,[intLineNo]					= ISNULL(ShipmentItem.intLineNo, 0)
		,[intStorageScheduleTypeId]		= ShipmentItem.intStorageScheduleTypeId
		,[ysnLoad]						= ContractView.ysnLoad
		,[intLoadShipped]				= ShipmentItem.intLoadShipped
		,ShipmentItem.intItemContractHeaderId
		,ShipmentItem.intItemContractDetailId
FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem
			ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
		INNER JOIN dbo.tblICItemLocation ItemLocation
			ON ItemLocation.intItemId = ShipmentItem.intItemId
			AND ItemLocation.intLocationId = Shipment.intShipFromLocationId
		INNER JOIN dbo.tblICItemUOM	ItemUOM
			ON ItemUOM.intItemUOMId = ShipmentItem.intItemUOMId
		LEFT JOIN dbo.tblICItemUOM WeightUOM
			ON WeightUOM.intItemUOMId = ShipmentItem.intWeightUOMId
		LEFT JOIN dbo.tblICInventoryShipmentItemLot ShipmentItemLot
			ON ShipmentItemLot.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
		LEFT JOIN dbo.tblICLot Lot
			ON Lot.intLotId = ShipmentItemLot.intLotId
		LEFT JOIN vyuCTCompactContractDetailView ContractView 
			ON ContractView.intContractDetailId = ShipmentItem.intLineNo
			AND ContractView.intContractHeaderId = ShipmentItem.intOrderId
			AND Shipment.intOrderType = 1
WHERE	Shipment.intInventoryShipmentId = @intShipmentId