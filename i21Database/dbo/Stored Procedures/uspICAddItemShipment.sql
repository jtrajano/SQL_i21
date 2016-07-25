/*
	Parameters:
		@ShipmentEntries	- Holds the line items with header info. There's a header per line item. 
						 	  If item is lotted, specify the intItemLotGroup field. 
							  (intItemLotGroup, intOrderType, intSourceType, intEntityCustomerId, 
							  dtmShipDate, intShipFromLocationId, intShipToLocationId, intFreightTermId) must be unique.
		@ShipmentCharges	- Holds the other charges info with header.
		@ShipmentItemLots	- Holds the lots of each lotted items in the @ShipmentEntries.
							  intItemLotGroup should be specified based on the intItemLotGroup of lotted item.
		@UserId				- The ID of the user.
*/
CREATE PROCEDURE [dbo].[uspICAddItemShipment]
	@Entries ShipmentStagingTable READONLY,
	@Charges ShipmentChargeStagingTable READONLY,
	@ItemLots ShipmentItemLotStagingTable READONLY,
	@intUserId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE 
	@ShipmentEntries ShipmentStagingTable,
	@ShipmentCharges ShipmentChargeStagingTable,
	@ShipmentItemLots ShipmentItemLotStagingTable,
	@StartingNumberId_InventoryShipment INT = 31,
	@ShipmentNumber NVARCHAR(20),

	@intEntityId INT,
	@CurrentShipmentId INT

-- Insert Raw Data
-- 1. Shipment Header and Items
INSERT INTO @ShipmentEntries(intOrderType, intSourceType, intEntityCustomerId, dtmShipDate, intShipFromLocationId, intShipToLocationId,
	intFreightTermId, strSourceScreenName, strReferenceNumber, dtmRequestedArrivalDate, intShipToCompanyLocationId, strBOLNumber,
	intShipViaId, strVessel, strProNumber, strDriverId, strSealNumber, strDeliveryInstruction, dtmAppointmentTime,
	dtmDepartureTime, dtmArrivalTime, dtmDeliveredDate, dtmFreeTime, strReceivedBy, strComment, intItemId, intOwnershipType,
	dblQuantity, intItemUOMId, intItemLotGroup, intOrderId, intSourceId, intLineNo, intSubLocationId, intStorageLocationId,
	intCurrencyId, intWeightUOMId, dblUnitPrice, intDockDoorId, strNotes, intGradeId, intDiscountSchedule)
SELECT intOrderType, intSourceType, intEntityCustomerId, dtmShipDate, intShipFromLocationId, intShipToLocationId,
	intFreightTermId, strSourceScreenName, strReferenceNumber, dtmRequestedArrivalDate, 
	intShipToCompanyLocationId, -- Sets to Default Company Location
	ISNULL(strBOLNumber, ''),
	intShipViaId, strVessel, strProNumber, strDriverId, strSealNumber, strDeliveryInstruction, dtmAppointmentTime,
	dtmDepartureTime, dtmArrivalTime, dtmDeliveredDate, dtmFreeTime, strReceivedBy, strComment, intItemId, intOwnershipType,
	dblQuantity, intItemUOMId, intItemLotGroup, intOrderId, intSourceId, intLineNo, intSubLocationId, intStorageLocationId,
	intCurrencyId, intWeightUOMId, dblUnitPrice, intDockDoorId, strNotes, intGradeId, intDiscountSchedule
FROM @Entries
-- 2. Charges
INSERT INTO @ShipmentCharges(intOrderType, intSourceType, intEntityCustomerId, dtmShipDate, intShipFromLocationId,
	intShipToLocationId, intFreightTermId, intContractId, intChargeId, strCostMethod, dblRate, intCostUOMId,
	intCurrency, dblAmount, ysnAccrue, intEntityVendorId, ysnPrice)
SELECT intOrderType, intSourceType, intEntityCustomerId, dtmShipDate, intShipFromLocationId,
	intShipToLocationId, intFreightTermId, intContractId, intChargeId, strCostMethod, dblRate, intCostUOMId,
	intCurrency, dblAmount, ysnAccrue, intEntityVendorId, ysnPrice
FROM @Charges
-- 3. Item Lots
INSERT INTO @ShipmentItemLots(intOrderType, intSourceType, intEntityCustomerId, dtmShipDate, intShipFromLocationId,
	intShipToLocationId, intFreightTermId, intItemLotGroup, intLotId, dblQuantityShipped, dblGrossWeight,
	dblTareWeight, dblWeightPerQty, strWarehouseCargoNumber)
SELECT intOrderType, intSourceType, intEntityCustomerId, dtmShipDate, intShipFromLocationId,
	intShipToLocationId, intFreightTermId, intItemLotGroup, intLotId, dblQuantityShipped, dblGrossWeight,
	dblTareWeight, dblWeightPerQty, strWarehouseCargoNumber
FROM @ItemLots

-- Get the entity id
SELECT	@intEntityId = intEntityUserSecurityId
FROM	dbo.tblSMUserSecurity 
WHERE	intEntityUserSecurityId = @intUserId

DECLARE @Header TABLE (
	intId INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
	intOrderType INT NOT NULL,
	intSourceType INT NOT NULL,
	intEntityCustomerId INT NULL,
	dtmShipDate DATETIME NOT NULL,
	intShipFromLocationId INT NOT NULL,
	intShipToLocationId INT NULL,
	intFreightTermId INT NOT NULL,
	intBaseId INT NOT NULL,
	strSourceScreenName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
)

-- Get Headers
;WITH headers (intId)
AS
(
	SELECT MIN(intId) intId
	FROM @ShipmentEntries
	GROUP BY intOrderType, intSourceType, intEntityCustomerId, dtmShipDate, intShipFromLocationId, intShipToLocationId, intFreightTermId
)
INSERT INTO @Header(intBaseId, intOrderType, intSourceType, intEntityCustomerId, dtmShipDate, intShipFromLocationId, intShipToLocationId, intFreightTermId, strSourceScreenName)
SELECT h.intId, se.intOrderType, se.intSourceType, se.intEntityCustomerId,
	se.dtmShipDate, se.intShipFromLocationId, se.intShipToLocationId, se.intFreightTermId, se.strSourceScreenName
FROM @ShipmentEntries se
	INNER JOIN headers h ON h.intId = se.intId
	
-- Merge shipment items
MERGE INTO @ShipmentEntries s
	USING @Header h
		ON h.intOrderType = s.intOrderType
			AND h.intSourceType = s.intSourceType
			AND h.intEntityCustomerId = s.intEntityCustomerId
			AND h.dtmShipDate = s.dtmShipDate
			AND h.intShipFromLocationId = s.intShipFromLocationId
			AND h.intShipToLocationId = s.intShipToLocationId
			AND h.intFreightTermId = s.intFreightTermId
WHEN MATCHED THEN
	UPDATE
	SET s.intHeaderId = h.intId;

-- Merge shipment charges
MERGE INTO @ShipmentCharges s
	USING @Header h
		ON h.intOrderType = s.intOrderType
			AND h.intSourceType = s.intSourceType
			AND h.intEntityCustomerId = s.intEntityCustomerId
			AND h.dtmShipDate = s.dtmShipDate
			AND h.intShipFromLocationId = s.intShipFromLocationId
			AND h.intShipToLocationId = s.intShipToLocationId
			AND h.intFreightTermId = s.intFreightTermId
WHEN MATCHED THEN
	UPDATE
	SET s.intHeaderId = h.intId 
WHEN NOT MATCHED BY SOURCE THEN DELETE;

------------------------------------------- CURSOR -------------------------------------------
-- Scan Headers
DECLARE cur CURSOR LOCAL FAST_FORWARD
	FOR 
		SELECT intId, intOrderType, intSourceType, intEntityCustomerId, dtmShipDate, 
			intShipFromLocationId, intShipToLocationId, intFreightTermId, intBaseId, strSourceScreenName
		FROM @Header

DECLARE @intId INT, @intOrderType INT, @intSourceType INT, @intEntityCustomerId INT, @dtmShipDate DATETIME, 
@intShipFromLocationId INT, @intShipToLocationId INT, @intFreightTermId INT, @intBaseId INT, @strSourceScreenName NVARCHAR(100)

OPEN cur

FETCH NEXT FROM cur INTO @intId, @intOrderType, @intSourceType, @intEntityCustomerId, @dtmShipDate, 
			@intShipFromLocationId, @intShipToLocationId, @intFreightTermId, @intBaseId, @strSourceScreenName

WHILE @@FETCH_STATUS = 0
BEGIN
	-- Generate Starting Number
	EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryShipment, @ShipmentNumber OUTPUT
	
	-- Insert New Shipment
	INSERT INTO tblICInventoryShipment(strShipmentNumber, dtmShipDate, intOrderType, intSourceType,
		intShipFromLocationId, intEntityCustomerId, intShipToLocationId, intFreightTermId, strBOLNumber)
	VALUES(@ShipmentNumber, @dtmShipDate, @intOrderType, @intSourceType, @intShipFromLocationId,
		@intEntityCustomerId, @intShipToLocationId, @intFreightTermId, '')

	-- Get Inserted Shipment ID
	SET @CurrentShipmentId = SCOPE_IDENTITY()

	-- Update Shipment ID of shipment items
	UPDATE @ShipmentEntries
	SET intShipmentId = @CurrentShipmentId
	WHERE intHeaderId = @intId

	-- Update Shipment ID of charges
	UPDATE @ShipmentCharges
	SET intShipmentId = @CurrentShipmentId
	WHERE intHeaderId = @intId

	-- Create an Audit Log
	BEGIN 
		DECLARE @StrDescription AS NVARCHAR(100) = @strSourceScreenName + ' to Inventory Shipment'

		EXEC	dbo.uspSMAuditLog
				 @keyValue = @CurrentShipmentId							-- Primary Key Value of the Inventory Shipment. 
				,@screenName = 'Inventory.view.InventoryShipment'       -- Screen Namespace
				,@entityId = @intEntityId                               -- Entity Id.
				,@actionType = 'Created'								-- Action Type
				,@changeDescription = @StrDescription					-- Description
				,@fromValue = ''			                            -- Previous Value
				,@toValue = @ShipmentNumber                             -- New Value
	END

	-- Get Next Header
	FETCH NEXT FROM cur INTO @intId, @intOrderType, @intSourceType, @intEntityCustomerId, @dtmShipDate, 
			@intShipFromLocationId, @intShipToLocationId, @intFreightTermId, @intBaseId, @strSourceScreenName
END

CLOSE cur
DEALLOCATE cur
---------------------------------------- END OF CURSOR -----------------------------------------

-- Insert shipment items
INSERT INTO tblICInventoryShipmentItem(intInventoryShipmentId, intItemId, intOwnershipType, dblQuantity, intItemUOMId, 
	intOrderId, intSourceId, intLineNo, intSubLocationId, intStorageLocationId, intCurrencyId, intWeightUOMId,
	dblUnitPrice, intDockDoorId, strNotes, intGradeId, intDiscountSchedule, intConcurrencyId)
SELECT se.intShipmentId, se.intItemId, se.intOwnershipType, se.dblQuantity, se.intItemUOMId, 
	se.intOrderId, se.intSourceId, se.intLineNo, se.intSubLocationId, se.intStorageLocationId, 
	se.intCurrencyId, se.intWeightUOMId, se.dblUnitPrice, se.intDockDoorId, se.strNotes, se.intGradeId, se.intDiscountSchedule, 1
FROM @ShipmentEntries se

-- Insert shipment charges
INSERT INTO tblICInventoryShipmentCharge(intInventoryShipmentId, intEntityVendorId, intChargeId, strCostMethod, dblAmount, dblRate, intConcurrencyId)
SELECT intShipmentId, intEntityVendorId, intChargeId, strCostMethod, dblAmount, dblRate, 1
FROM @ShipmentCharges

-- Insert item lots
INSERT INTO tblICInventoryShipmentItemLot(intInventoryShipmentItemId, intLotId, dblQuantityShipped, dblGrossWeight, dblTareWeight, dblWeightPerQty, strWarehouseCargoNumber)
SELECT si.intInventoryShipmentItemId, l.intLotId, l.dblQuantityShipped, l.dblGrossWeight, l.dblTareWeight, l.dblWeightPerQty, l.strWarehouseCargoNumber
FROM @ShipmentItemLots l
	INNER JOIN @ShipmentEntries se ON l.intItemLotGroup = se.intItemLotGroup
		AND se.intOrderType = l.intOrderType
		AND se.intSourceType = l.intSourceType
		AND se.intEntityCustomerId = l.intEntityCustomerId
		AND se.dtmShipDate = l.dtmShipDate
		AND se.intShipFromLocationId = l.intShipFromLocationId
		AND se.intShipToLocationId = l.intShipToLocationId
		AND se.intFreightTermId = l.intFreightTermId
	INNER JOIN tblICInventoryShipment s ON se.intOrderType = s.intOrderType
			AND se.intSourceType = s.intSourceType
			AND se.intEntityCustomerId = s.intEntityCustomerId
			AND se.dtmShipDate = s.dtmShipDate
			AND se.intShipFromLocationId = s.intShipFromLocationId
			AND se.intShipToLocationId = s.intShipToLocationId
			AND se.intFreightTermId = s.intFreightTermId
	INNER JOIN tblICInventoryShipmentItem si ON si.intInventoryShipmentId = s.intInventoryShipmentId
		AND si.intItemId = se.intItemId
	INNER JOIN tblICItem i ON i.intItemId = si.intItemId
WHERE i.strLotTracking <> 'No'