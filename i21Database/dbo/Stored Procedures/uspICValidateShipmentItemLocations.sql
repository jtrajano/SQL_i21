CREATE PROCEDURE [dbo].[uspICValidateShipmentItemLocations]
	@intInventoryShipmentId INT,
	@ysnValid BIT OUTPUT
AS
IF EXISTS(
	SELECT s.intInventoryShipmentId
	FROM tblICInventoryShipment s
		LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = s.intShipFromLocationId
		LEFT JOIN tblICInventoryShipmentItem si ON si.intInventoryShipmentId = s.intInventoryShipmentId
		LEFT JOIN tblSMCompanyLocationSubLocation sc ON sc.intCompanyLocationSubLocationId = si.intSubLocationId
			AND sc.intCompanyLocationId <> c.intCompanyLocationId
		LEFT JOIN tblICItem i ON i.intItemId = si.intItemId
		LEFT OUTER JOIN tblICInventoryShipmentItemLot shl ON shl.intInventoryShipmentItemId = si.intInventoryShipmentItemId
		LEFT OUTER JOIN tblICInventoryReceiptItemLot lot ON lot.intLotId = shl.intLotId
			AND lot.intStorageLocationId <> si.intStorageLocationId
	WHERE s.intInventoryShipmentId = @intInventoryShipmentId
		AND (lot.intLotId IS NOT NULL OR (sc.intCompanyLocationSubLocationId IS NOT NULL AND s.intShipFromLocationId <> sc.intCompanyLocationId))
)
	SET @ysnValid = 0
ELSE
	SET @ysnValid = 1
