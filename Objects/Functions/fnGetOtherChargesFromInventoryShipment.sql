-- This function returns the cost per lot item. 
CREATE FUNCTION [dbo].[fnGetOtherChargesFromInventoryShipment] ( 
	@intInventoryShipmentItemId AS INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN 
	DECLARE @totalOtherCharges AS NUMERIC(18,6)
			,@units AS NUMERIC(18,6)

	SELECT	@totalOtherCharges= SUM(ItemOtherCharges.dblAmount)
	FROM	dbo.tblICInventoryShipmentItem ShipmentItems INNER JOIN dbo.tblICInventoryShipmentItemAllocatedCharge ItemOtherCharges 
				ON ShipmentItems.intInventoryShipmentItemId = ItemOtherCharges.intInventoryShipmentItemId
	WHERE	ShipmentItems.intInventoryShipmentItemId = @intInventoryShipmentItemId

	SELECT	@units = ShipmentItems.dblQuantity
	FROM	dbo.tblICInventoryShipmentItem ShipmentItems 
	WHERE	ShipmentItems.intInventoryShipmentItemId = @intInventoryShipmentItemId

	IF @units <> 0 
		RETURN ISNULL(@totalOtherCharges / @units, 0);

	RETURN 0
	;
END