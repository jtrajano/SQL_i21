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
	@Items ShipmentStagingTable READONLY,
	@Charges ShipmentChargeStagingTable READONLY,
	@Lots ShipmentItemLotStagingTable READONLY,
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

DECLARE @intResult INT 
	
IF NOT EXISTS (SELECT TOP 1 1 FROM @Items)
	GOTO _Exit;

-- BEGIN VALIDATIONS
BEGIN 
	DECLARE @InvalidEntityId AS INT
			,@strCustomer AS NVARCHAR(50)
			,@strItemNo AS NVARCHAR(50)
			,@strItemType AS NVARCHAR(50)
			,@InvalidItemId AS INT 
			,@InvalidSubLocation AS INT 
			,@InvalidStorageLocation AS INT 
			,@InvalidVendorId AS INT 
			,@strCharge AS NVARCHAR(50)
			,@strChargeVendor AS NVARCHAR(50)
			,@InvalidChargeId AS INT 
			,@InvalidLotId AS INT
			,@strLotNumber AS NVARCHAR(50) 
			,@InvalidPriceUOMId AS INT 

	-- Validate Customer Id
	BEGIN
		
		SELECT	TOP 1 
				@InvalidEntityId = shipment.intEntityCustomerId
		FROM	@Items shipment LEFT JOIN tblEMEntity e
					ON shipment.intEntityCustomerId = e.intEntityId
		WHERE	e.intEntityId IS NULL 
				AND shipment.intEntityCustomerId IS NOT NULL

		IF @InvalidEntityId IS NOT NULL 
		BEGIN 
			-- 'Invalid customer record.'
			EXEC uspICRaiseError 80184;
			RETURN 80184
		END 
	END
	
	-- Validate Freight Term Id
	BEGIN
		-- Validate the freight terms for the shipment header.
		SELECT	TOP 1 
				@strCustomer = e.strName
		FROM	@Items shipment INNER JOIN tblEMEntity e
					ON shipment.intEntityCustomerId = e.intEntityId
				LEFT JOIN tblSMFreightTerms f
					ON f.intFreightTermId = shipment.intFreightTermId
		WHERE	f.intFreightTermId IS NULL 		

		IF @strCustomer IS NOT NULL 
		BEGIN 
			-- 'The Freight Terms for customer {Customer} is blank. Please add it at the Entity - Locations.'
			EXEC uspICRaiseError 80183, @strCustomer;
			RETURN 80183
		END 

		-- Validate the freight terms for the shipment charges.
		SELECT	TOP 1 
				@strCustomer = e.strName
		FROM	@Charges shipment INNER JOIN tblEMEntity e
					ON shipment.intEntityCustomerId = e.intEntityId
				LEFT JOIN tblSMFreightTerms f
					ON f.intFreightTermId = shipment.intFreightTermId
		WHERE	f.intFreightTermId IS NULL 		

		IF @strCustomer IS NOT NULL 
		BEGIN 
			-- 'The Freight Terms for customer {Customer} is blank. Please add it at the Entity - Locations.'
			EXEC uspICRaiseError 80183, @strCustomer;
			RETURN 80183
		END 
	END

	-- Validate Ship From Location Id
	BEGIN 		
		IF EXISTS (
			SELECT	TOP 1 1 
			FROM	@Items i LEFT JOIN tblSMCompanyLocation l
						ON l.intCompanyLocationId = i.intShipFromLocationId
			WHERE	l.intCompanyLocationId IS NULL 
		)
		BEGIN
			-- 'Ship From Location is missing or invalid.'
			EXEC uspICRaiseError 80198;
			RETURN 80198
		END
	END 

	-- Validate Ship To Location Id
	BEGIN 		
		IF EXISTS (
			SELECT	TOP 1 1 
			FROM	@Items i LEFT JOIN tblEMEntityLocation entityLocation
						ON entityLocation.intEntityLocationId = i.intShipToLocationId 
			WHERE	entityLocation.intEntityLocationId IS NULL 
		)
		BEGIN
			-- 'Ship To Location is missing or invalid.'
			EXEC uspICRaiseError 80199;
			RETURN 80199
		END
	END 

	-- Validate the items
	BEGIN 
		-- Check if item id is valid or not. 
		IF EXISTS(
			SELECT	TOP 1 1
			FROM	@Items e LEFT JOIN tblICItem i 
						ON i.intItemId = e.intItemId
			WHERE	i.intItemId IS NULL 
		)
		BEGIN
			-- 'Item id is invalid or missing.'
			EXEC uspICRaiseError 80001; 
			RETURN 80001
		END

		-- Check if item type is allowed for shipment. 
		SET @InvalidItemId = NULL 
		SELECT	TOP 1 
				@strItemNo = i.strItemNo
				,@strItemType = i.strType
				,@InvalidItemId = i.intItemId  
		FROM	@Items e INNER JOIN tblICItem i 
					ON i.intItemId = e.intItemId
		WHERE	i.strType NOT IN ('Inventory', 'Finished Good', 'Raw Material', 'Bundle')

		IF @InvalidItemId IS NOT NULL 
		BEGIN
			-- '{Item} is set as {Item Type} type and that type is not allowed for Shipment.'
			EXEC uspICRaiseError 80163, @strItemNo, @strItemType; 
			RETURN 80163 
		END

		-- Check if item is bundle type
		SET @InvalidItemId = NULL 
		SELECT	TOP 1 
				@strItemNo = i.strItemNo
				,@strItemType = i.strType
				,@InvalidItemId = i.intItemId  
		FROM	@Items e INNER JOIN tblICItem i 
					ON i.intItemId = e.intItemId
		WHERE	i.strBundleType IS NOT NULL

		IF @InvalidItemId IS NOT NULL 
		BEGIN
			-- 'Bundle item has to be received from "Add Orders" in the %s Screen.'
			EXEC uspICRaiseError 80203, 'Inventory Shipment';
			RETURN 80203 
		END

		-- Validate Item UOM Id
		SET @InvalidItemId = NULL

		SELECT TOP 1 
				@strItemNo = i.strItemNo
				,@strItemType = i.strType
				,@InvalidItemId = i.intItemId  
		FROM	@Items RawData INNER JOIN tblICItem i
					ON RawData.intItemId = i.intItemId
				LEFT JOIN tblICItemUOM iu 
					ON iu.intItemUOMId = RawData.intItemUOMId
		WHERE	iu.intItemUOMId IS NULL 

		IF @InvalidItemId IS NOT NULL 
		BEGIN
			-- 'Item UOM Id is invalid or missing for item {Item No}.'
			EXEC uspICRaiseError 80120, @strItemNo;
			RETURN 80120 
		END

		-- Validate Price UOM Id
		SET @InvalidItemId = NULL

		SELECT TOP 1 
				@strItemNo = i.strItemNo
				,@strItemType = i.strType
				,@InvalidItemId = i.intItemId  
				,@InvalidPriceUOMId = RawData.intPriceUOMId
		FROM	@Items RawData INNER JOIN tblICItem i
					ON RawData.intItemId = i.intItemId
				LEFT JOIN tblICItemUOM iu 
					ON iu.intItemUOMId = RawData.intPriceUOMId
		WHERE	iu.intItemUOMId IS NULL 
				AND RawData.intPriceUOMId IS NOT NULL 

		IF @InvalidItemId IS NOT NULL 
		BEGIN
			-- 'Price UOM Id is invalid or missing for item {Item No}.'
			EXEC uspICRaiseError 80120, @strItemNo;
			RETURN 80206 
		END

		-- Validate Sub Location Id
		SELECT TOP 1 
				@InvalidSubLocation = RawData.intSubLocationId
				,@strItemNo = i.strItemNo
		FROM	@Items RawData LEFT JOIN tblICItem i 
					ON RawData.intItemId = i.intItemId		
				LEFT JOIN tblSMCompanyLocationSubLocation sub 
					ON sub.intCompanyLocationSubLocationId = RawData.intSubLocationId
					AND sub.intCompanyLocationId = RawData.intShipFromLocationId 
		WHERE	sub.intCompanyLocationSubLocationId IS NULL 		
				AND RawData.intSubLocationId IS NOT NULL 		

		IF @InvalidSubLocation IS NOT NULL 
		BEGIN
			-- 'Sub Location is invalid or missing for item {Item No}.'
			EXEC uspICRaiseError 80097, @strItemNo
			RETURN 80097
		END

		-- Validate Storage Location Id
		SELECT TOP 1 
				@InvalidStorageLocation = RawData.intStorageLocationId
				,@strItemNo = i.strItemNo 
		FROM	@Items RawData LEFT JOIN tblICItem i 
					ON RawData.intItemId = i.intItemId
				LEFT JOIN tblICStorageLocation storage 
					ON storage.intStorageLocationId = RawData.intStorageLocationId
					AND storage.intSubLocationId = RawData.intSubLocationId -- Sub-location for the storage location must match too. 
					AND storage.intLocationId = RawData.intShipFromLocationId
		WHERE	storage.intStorageLocationId IS NULL 
				AND RawData.intStorageLocationId IS NOT NULL 

		IF @InvalidStorageLocation IS NOT NULL 
		BEGIN
			-- Storage Unit is invalid or missing for item {Item No}.
			EXEC uspICRaiseError 80098, @strItemNo
			RETURN 80098
		END

		-- Validate Gross/Net UOM Id
		SET @InvalidItemId = NULL

		SELECT TOP 1 
				@InvalidItemId = RawData.intItemId
				,@strItemNo = i.strItemNo
		FROM	@Items RawData INNER JOIN tblICItem i 
					ON RawData.intItemId = i.intItemId
				LEFT JOIN tblICItemUOM iu 
					ON iu.intItemUOMId = RawData.intWeightUOMId
		WHERE	iu.intItemUOMId IS NULL 
				AND RawData.intWeightUOMId IS NOT NULL 

		IF @InvalidItemId IS NOT NULL 
		BEGIN
			-- Gross/Net UOM is invalid for item {Item}.
			EXEC uspICRaiseError 80121, @strItemNo;
			RETURN 80121
		END
	END

	-- Validate the Other Charges
	BEGIN 
		-- Check if item id is valid or not. 
		IF EXISTS(
			SELECT	TOP 1 1
			FROM	@Charges c LEFT JOIN tblICItem i 
						ON i.intItemId = c.intChargeId
						AND i.strType = 'Other Charge'
			WHERE	i.intItemId IS NULL 
		)
		BEGIN
			-- 'Charge is missing or invalid.'
			EXEC uspICRaiseError 80200; 
			RETURN 80200
		END

		-- Validate Other Charge Entity Id
		BEGIN 
			SET @InvalidVendorId = NULL 
			SELECT	TOP 1 
					@InvalidVendorId = RawData.intChargeId
					,@strCharge = charge.strItemNo 
			FROM	@Charges RawData INNER JOIN tblICItem charge
						ON RawData.intChargeId = charge.intItemId 
					LEFT JOIN tblEMEntity e 
						ON e.intEntityId = RawData.intEntityVendorId
			WHERE	e.intEntityId IS NULL 
					AND RawData.intEntityVendorId IS NOT NULL 

			IF @InvalidVendorId IS NOT NULL
			BEGIN
				-- Entity Id is invalid or missing for other charge item {Other Charge Item No.}.
				-- The vendor, {Entity name}, for {Other Charge} is invalid. Entity must be a Vendor type.
				EXEC uspICRaiseError 80140, @strCharge;
				RETURN 80140;
			END
		END 

		-- Validate Other Charge Entity Id
		BEGIN 
			SET @InvalidVendorId = NULL 
			SELECT	TOP 1 
					@InvalidVendorId = RawData.intChargeId
					,@strCharge = charge.strItemNo 
			FROM	@Charges RawData INNER JOIN tblICItem charge
						ON RawData.intChargeId = charge.intItemId 
					LEFT JOIN tblEMEntity e 
						ON e.intEntityId = RawData.intEntityVendorId
			WHERE	e.intEntityId IS NULL 
					AND RawData.intEntityVendorId IS NOT NULL 

			IF @InvalidVendorId IS NOT NULL
			BEGIN
				-- Entity Id is invalid or missing for other charge item {Other Charge Item No.}.
				EXEC uspICRaiseError 80140, @strCharge;
				RETURN 80140;
			END
		END 

		-- Validate Other Charge Entity Id against the Vendor table. 
		BEGIN 
			SET @InvalidVendorId = NULL 
			SELECT	TOP 1 
					@InvalidVendorId = RawData.intChargeId
					,@strCharge = charge.strItemNo 
					,@strChargeVendor = e.strName
			FROM	@Charges RawData INNER JOIN tblICItem charge
						ON RawData.intChargeId = charge.intItemId 
					LEFT JOIN tblAPVendor v 
						ON v.intEntityId = RawData.intEntityVendorId
					LEFT JOIN tblEMEntity e 
						ON e.intEntityId = RawData.intEntityVendorId
			WHERE	v.intEntityId IS NULL 
					AND RawData.intEntityVendorId IS NOT NULL 

			IF @InvalidVendorId IS NOT NULL
			BEGIN
				-- The entity used for {Other Charge Item No.} must be a Vendor type.
				EXEC uspICRaiseError 80205, @strChargeVendor, @strCharge, @strChargeVendor;
				RETURN 80205;
			END
		END 

		-- Validate Other Charge Location Id
		SET @InvalidChargeId = NULL 
		SELECT TOP 1 
				@InvalidChargeId = RawData.intChargeId
				,@strCharge = charge.strItemNo 
		FROM	@Charges RawData INNER JOIN tblICItem charge
					ON RawData.intChargeId = charge.intItemId 
				LEFT JOIN tblSMCompanyLocation loc 
					ON loc.intCompanyLocationId = RawData.intShipFromLocationId
		WHERE	loc.intCompanyLocationId IS NULL 
		
		IF @InvalidChargeId IS NOT NULL
		BEGIN
			-- Location Id is invalid or missing for other charge item {Other Charge Item No.}.
			EXEC uspICRaiseError 80142, @strCharge;
			RETURN 80142
		END		
	END 

	-- Validate the Lots 
	BEGIN 
		-- Validate Lot Id
		SET @InvalidLotId = NULL

		SELECT	TOP 1 
				@InvalidLotId = ItemLot.intLotId
				,@strItemNo = i.strItemNo  
		FROM	@Lots ItemLot INNER JOIN @Items Item
					ON ItemLot.intItemLotGroup = Item.intItemLotGroup
				INNER JOIN tblICItem i
					ON i.intItemId = Item.intItemId
				LEFT JOIN tblICLot l
					ON ItemLot.intLotId = l.intLotId 
					AND Item.intItemId = l.intItemId
		WHERE	l.intLotId IS NULL 

		IF @InvalidLotId IS NOT NULL 
		BEGIN
			-- 'Lot Id provided for {Item No} is invalid.'
			EXEC uspICRaiseError 80201, @strItemNo;
			RETURN 80201
		END
	END 
END 
-- END VALIDATIONS

-- Insert Raw Data
-- 1. Shipment Header and Items
INSERT INTO @ShipmentEntries(
		intOrderType
		, intSourceType
		, intEntityCustomerId
		, dtmShipDate
		, intShipFromLocationId
		, intShipToLocationId
		, intFreightTermId
		, strSourceScreenName
		, strReferenceNumber
		, dtmRequestedArrivalDate
		, intShipToCompanyLocationId
		, strBOLNumber
		, intShipViaId
		, strVessel
		, strProNumber
		, strDriverId
		, strSealNumber
		, strDeliveryInstruction
		, dtmAppointmentTime
		, dtmDepartureTime
		, dtmArrivalTime
		, dtmDeliveredDate
		, dtmFreeTime
		, strFreeTime
		, strReceivedBy
		, strComment
		, intCurrencyId
		, intItemId
		, intOwnershipType
		, dblQuantity
		, intItemUOMId
		, intItemLotGroup
		, intOrderId
		, intSourceId
		, intLineNo
		, intSubLocationId
		, intStorageLocationId
		, intItemCurrencyId
		, intWeightUOMId
		, dblUnitPrice
		, intDockDoorId
		, strNotes
		, intGradeId
		, intDiscountSchedule
		, intStorageScheduleTypeId
		, intDestinationGradeId
		, intDestinationWeightId
		, intForexRateTypeId
		, dblForexRate
		, strChargesLink
		, intPriceUOMId
		, dblGross
		, dblTare
		, dblNet
)
SELECT 
		intOrderType
		, intSourceType
		, intEntityCustomerId
		, dtmShipDate
		, intShipFromLocationId
		, intShipToLocationId
		, intFreightTermId
		, strSourceScreenName
		, strReferenceNumber
		, dtmRequestedArrivalDate
		, intShipToCompanyLocationId -- Sets to Default Company Location
		, ISNULL(strBOLNumber, '')
		, intShipViaId
		, strVessel
		, strProNumber
		, strDriverId
		, strSealNumber
		, strDeliveryInstruction
		, dtmAppointmentTime
		, dtmDepartureTime
		, dtmArrivalTime
		, dtmDeliveredDate
		, dtmFreeTime
		, strFreeTime
		, strReceivedBy
		, strComment
		, intCurrencyId
		, intItemId
		, intOwnershipType
		, dblQuantity
		, intItemUOMId
		, intItemLotGroup
		, intOrderId
		, intSourceId
		, intLineNo
		, intSubLocationId
		, intStorageLocationId
		, intItemCurrencyId
		, intWeightUOMId
		, dblUnitPrice
		, intDockDoorId
		, strNotes
		, intGradeId
		, intDiscountSchedule
		, intStorageScheduleTypeId
		, intDestinationGradeId
		, intDestinationWeightId
		, intForexRateTypeId
		, dblForexRate
		, strChargesLink
		, intPriceUOMId
		, dblGross
		, dblTare
		, dblNet
FROM @Items

-- 2. Charges
INSERT INTO @ShipmentCharges(
		intOrderType
		, intSourceType
		, intEntityCustomerId
		, dtmShipDate
		, intShipFromLocationId
		, intShipToLocationId
		, intFreightTermId
		, intContractId
		, intContractDetailId
		, intChargeId
		, strCostMethod
		, dblRate
		, intCostUOMId
		, intCurrency
		, dblAmount
		, ysnAccrue
		, intEntityVendorId
		, ysnPrice
		, intForexRateTypeId 
		, dblForexRate 
		, strChargesLink
)
SELECT 
		intOrderType
		, intSourceType
		, intEntityCustomerId
		, dtmShipDate
		, intShipFromLocationId
		, intShipToLocationId
		, intFreightTermId
		, intContractId
		, intContractDetailId
		, intChargeId
		, strCostMethod
		, dblRate
		, intCostUOMId
		, intCurrency
		, dblAmount
		, ysnAccrue
		, intEntityVendorId
		, ysnPrice
		, intForexRateTypeId 
		, dblForexRate 
		, strChargesLink
FROM @Charges

-- 3. Item Lots
INSERT INTO @ShipmentItemLots(
		intOrderType
		, intSourceType
		, intEntityCustomerId
		, dtmShipDate
		, intShipFromLocationId
		, intShipToLocationId
		, intFreightTermId
		, intItemLotGroup
		, intLotId
		, dblQuantityShipped
		, dblGrossWeight
		, dblTareWeight
		, dblWeightPerQty
		, strWarehouseCargoNumber
)
SELECT	intOrderType
		, intSourceType
		, intEntityCustomerId
		, dtmShipDate
		, intShipFromLocationId
		, intShipToLocationId
		, intFreightTermId
		, intItemLotGroup
		, intLotId
		, dblQuantityShipped
		, dblGrossWeight
		, dblTareWeight
		, dblWeightPerQty
		, strWarehouseCargoNumber
FROM @Lots

-- Get the entity id
SELECT	@intEntityId = [intEntityId]
FROM	dbo.tblSMUserSecurity 
WHERE	[intEntityId] = @intUserId

-- Get the functional currency and default Forex Rate Type Id 
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	DECLARE @intDefaultForexRateTypeId AS INT 
	 
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 

	SELECT	TOP 1 
			@intDefaultForexRateTypeId = intInventoryRateTypeId 
	FROM	tblSMMultiCurrency
END 

-- Create the temp table if it does not exists. 
IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemShipmentResult')) 
BEGIN 
	CREATE TABLE #tmpAddItemShipmentResult (
		intInventoryShipmentId INT

	)
END 

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
	strSourceScreenName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	intCurrencyId INT NULL,
	strReferenceNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
)

-- Get Headers
;WITH headers (intId)
AS
(
	SELECT	MIN(intId) intId
	FROM	@ShipmentEntries
	GROUP BY intOrderType, intSourceType, intEntityCustomerId, dtmShipDate, intShipFromLocationId, intShipToLocationId, intFreightTermId
)
INSERT INTO @Header(
		intBaseId
		, intOrderType
		, intSourceType
		, intEntityCustomerId
		, dtmShipDate
		, intShipFromLocationId
		, intShipToLocationId
		, intFreightTermId
		, strSourceScreenName
		, intCurrencyId
		, strReferenceNumber
)
SELECT 
		h.intId
		, se.intOrderType
		, se.intSourceType
		, se.intEntityCustomerId
		, se.dtmShipDate
		, se.intShipFromLocationId
		, se.intShipToLocationId
		, se.intFreightTermId
		, se.strSourceScreenName
		, se.intCurrencyId
		, se.strReferenceNumber 
FROM	@ShipmentEntries se INNER JOIN headers h 
		ON h.intId = se.intId
	
-- Merge shipment items
MERGE INTO @ShipmentEntries s
	USING @Header h
		ON ISNULL(h.intOrderType, 0) = ISNULL(s.intOrderType, 0)
			AND ISNULL(h.intSourceType, 0) = ISNULL(s.intSourceType, 0)
			AND ISNULL(h.intEntityCustomerId, 0) = ISNULL(s.intEntityCustomerId, 0)
			AND ISNULL(h.dtmShipDate, 0) = ISNULL(s.dtmShipDate, 0)
			AND ISNULL(h.intShipFromLocationId, 0) = ISNULL(s.intShipFromLocationId, 0)
			AND ISNULL(h.intShipToLocationId, 0) = ISNULL(s.intShipToLocationId, 0)
			AND ISNULL(h.intFreightTermId, 0) = ISNULL(s.intFreightTermId, 0)
WHEN MATCHED THEN
	UPDATE
	SET s.intHeaderId = h.intId;

-- Merge shipment charges
MERGE INTO @ShipmentCharges s
	USING @Header h
		ON ISNULL(h.intOrderType, 0) = ISNULL(s.intOrderType, 0)
			AND ISNULL(h.intSourceType, 0) = ISNULL(s.intSourceType, 0)
			AND ISNULL(h.intEntityCustomerId, 0) = ISNULL(s.intEntityCustomerId, 0)
			AND ISNULL(h.dtmShipDate, 0) = ISNULL(s.dtmShipDate, 0)
			AND ISNULL(h.intShipFromLocationId, 0) = ISNULL(s.intShipFromLocationId, 0)
			AND ISNULL(h.intShipToLocationId, 0) = ISNULL(s.intShipToLocationId, 0)
			AND ISNULL(h.intFreightTermId, 0) = ISNULL(s.intFreightTermId, 0)
WHEN MATCHED THEN
	UPDATE
	SET s.intHeaderId = h.intId 
WHEN NOT MATCHED BY SOURCE THEN DELETE;

------------------------------------------- CURSOR -------------------------------------------
-- Scan Headers
DECLARE @intId INT
		, @intOrderType INT
		, @intSourceType INT
		, @intEntityCustomerId INT
		, @dtmShipDate DATETIME
		, @intShipFromLocationId INT
		, @intShipToLocationId INT
		, @intFreightTermId INT
		, @intBaseId INT
		, @strSourceScreenName NVARCHAR(100)
		, @intCurrencyId INT
		, @strReferenceNumber NVARCHAR(50) 

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR 
	SELECT 
		intId
		, intOrderType
		, intSourceType
		, intEntityCustomerId
		, dtmShipDate
		, intShipFromLocationId
		, intShipToLocationId
		, intFreightTermId
		, intBaseId
		, strSourceScreenName
		, intCurrencyId
		, strReferenceNumber 
	FROM @Header

OPEN cur

FETCH NEXT FROM cur INTO 
	@intId
	, @intOrderType
	, @intSourceType
	, @intEntityCustomerId
	, @dtmShipDate
	, @intShipFromLocationId
	, @intShipToLocationId
	, @intFreightTermId
	, @intBaseId
	, @strSourceScreenName
	, @intCurrencyId
	, @strReferenceNumber

WHILE @@FETCH_STATUS = 0
BEGIN
	-- Generate Starting Number
	EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryShipment, @ShipmentNumber OUTPUT, @intShipFromLocationId
	
	-- Insert New Shipment
	INSERT INTO tblICInventoryShipment(
		strShipmentNumber
		, dtmShipDate
		, intOrderType
		, intSourceType
		, intShipFromLocationId
		, intEntityCustomerId
		, intShipToLocationId
		, intFreightTermId
		, strBOLNumber
		, intCurrencyId
		, strReferenceNumber
	)
	VALUES(
		@ShipmentNumber
		, @dtmShipDate
		, @intOrderType
		, @intSourceType
		, @intShipFromLocationId
		, @intEntityCustomerId
		, @intShipToLocationId
		, @intFreightTermId
		, ''
		, ISNULL(@intCurrencyId, @intFunctionalCurrencyId)
		, @strReferenceNumber
	)

	-- Get Inserted Shipment ID
	SET @CurrentShipmentId = SCOPE_IDENTITY()

	-- Insert results to temp table
	INSERT INTO #tmpAddItemShipmentResult(intInventoryShipmentId)
	VALUES(@CurrentShipmentId)

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
	FETCH NEXT FROM cur INTO 
		@intId
		, @intOrderType
		, @intSourceType
		, @intEntityCustomerId
		, @dtmShipDate
		, @intShipFromLocationId
		, @intShipToLocationId
		, @intFreightTermId
		, @intBaseId
		, @strSourceScreenName
		, @intCurrencyId
		, @strReferenceNumber
END

CLOSE cur
DEALLOCATE cur
---------------------------------------- END OF CURSOR -----------------------------------------

-- Insert shipment items
INSERT INTO tblICInventoryShipmentItem(
	intInventoryShipmentId
	, intItemId
	, intOwnershipType
	, dblQuantity
	, intItemUOMId
	, intOrderId
	, intSourceId
	, intLineNo
	, intSubLocationId
	, intStorageLocationId
	, intCurrencyId
	, intWeightUOMId
	, dblUnitPrice
	, intDockDoorId
	, strNotes
	, intGradeId
	, intDiscountSchedule
	, intStorageScheduleTypeId
	, intDestinationGradeId
	, intDestinationWeightId
	, intForexRateTypeId
	, dblForexRate
	, strChargesLink
	, intConcurrencyId
	, intPriceUOMId
	, dblLineTotal
	, dblGross
	, dblTare
	, dblNet
	, intSort 
)
SELECT 
	se.intShipmentId
	, se.intItemId
	, se.intOwnershipType
	, se.dblQuantity
	, se.intItemUOMId
	, se.intOrderId
	, se.intSourceId
	, se.intLineNo
	, se.intSubLocationId
	, se.intStorageLocationId
	, se.intItemCurrencyId
	, se.intWeightUOMId
	, se.dblUnitPrice
	, se.intDockDoorId
	, se.strNotes
	, se.intGradeId
	, se.intDiscountSchedule
	, se.intStorageScheduleTypeId
	, se.intDestinationGradeId
	, se.intDestinationWeightId
	, intForexRateTypeId = CASE WHEN ISNULL(s.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId THEN ISNULL(se.intForexRateTypeId, @intDefaultForexRateTypeId) ELSE NULL END 
	, dblForexRate = CASE WHEN ISNULL(s.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId THEN ISNULL(se.dblForexRate, forexRate.dblRate)  ELSE NULL END 
	, strChargesLink
	, intConcurrencyId = 1
	, intPriceUOMId = ISNULL(se.intPriceUOMId, se.intItemUOMId) 
	, dblLineTotal = 
		ROUND(
			se.dblQuantity
			* dbo.fnCalculateCostBetweenUOM(
				ISNULL(se.intPriceUOMId, se.intItemUOMId)
				, se.intItemUOMId
				, se.dblUnitPrice
			) 
			, 2
		) 
	, se.dblGross
	, se.dblTare
	, se.dblNet
	, se.intItemLotGroup
FROM @ShipmentEntries se INNER JOIN tblICInventoryShipment s
		ON se.intShipmentId = s.intInventoryShipmentId
	-- Get the SM forex rate. 
	OUTER APPLY dbo.fnSMGetForexRate(
		ISNULL(s.intCurrencyId, @intFunctionalCurrencyId)
		,CASE WHEN ISNULL(s.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId THEN ISNULL(se.intForexRateTypeId, @intDefaultForexRateTypeId) ELSE NULL END 
		,se.dtmShipDate
	) forexRate

-- Insert shipment charges
INSERT INTO tblICInventoryShipmentCharge(
	intInventoryShipmentId
	, intEntityVendorId
	, intChargeId
	, strCostMethod
	, dblAmount
	, dblRate
	, intContractId
	, intContractDetailId
	, ysnPrice
	, ysnAccrue
	, intCostUOMId
	, intCurrencyId
	, intForexRateTypeId 
	, dblForexRate 
	, strAllocatePriceBy
	, strChargesLink
	, intConcurrencyId
)
SELECT 
	sc.intShipmentId
	, sc.intEntityVendorId
	, sc.intChargeId
	, sc.strCostMethod
	, sc.dblAmount
	, sc.dblRate
	, sc.intContractId
	, sc.intContractDetailId
	, sc.ysnPrice
	, sc.ysnAccrue
	, sc.intCostUOMId
	, ISNULL(sc.intCurrency, @intFunctionalCurrencyId)
	, intForexRateTypeId = CASE WHEN ISNULL(sc.intCurrency, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId THEN ISNULL(sc.intForexRateTypeId, @intDefaultForexRateTypeId) ELSE NULL END  
	, dblForexRate = CASE WHEN ISNULL(sc.intCurrency, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId THEN ISNULL(sc.dblForexRate, forexRate.dblRate) ELSE NULL END   
	, ISNULL(sc.strAllocatePriceBy, 'Unit')
	, strChargesLink
	, intConcurrencyId = 1
FROM @ShipmentCharges sc INNER JOIN tblICInventoryShipment s
		ON sc.intShipmentId = s.intInventoryShipmentId 
	-- Get the SM forex rate. 
	OUTER APPLY dbo.fnSMGetForexRate(
		ISNULL(sc.intCurrency, @intFunctionalCurrencyId)
		,CASE WHEN ISNULL(sc.intCurrency, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId THEN ISNULL(sc.intForexRateTypeId, @intDefaultForexRateTypeId) ELSE NULL END  
		,s.dtmShipDate
	) forexRate			

-- Insert item lots
INSERT INTO tblICInventoryShipmentItemLot(
	intInventoryShipmentItemId
	, intLotId
	, dblQuantityShipped
	, dblGrossWeight
	, dblTareWeight
	, dblWeightPerQty
	, strWarehouseCargoNumber
)
SELECT 
	si.intInventoryShipmentItemId
	, l.intLotId
	, l.dblQuantityShipped
	, l.dblGrossWeight
	, l.dblTareWeight
	, l.dblWeightPerQty
	, l.strWarehouseCargoNumber
FROM @ShipmentItemLots l INNER JOIN @ShipmentEntries se 
		ON l.intItemLotGroup = se.intItemLotGroup
		AND se.intOrderType = l.intOrderType
		AND se.intSourceType = l.intSourceType
		AND se.intEntityCustomerId = l.intEntityCustomerId
		AND se.dtmShipDate = l.dtmShipDate
		AND se.intShipFromLocationId = l.intShipFromLocationId
		AND se.intShipToLocationId = l.intShipToLocationId
		AND se.intFreightTermId = l.intFreightTermId
	INNER JOIN tblICInventoryShipment s 
		ON s.intInventoryShipmentId = se.intShipmentId
	INNER JOIN tblICInventoryShipmentItem si 
		ON si.intInventoryShipmentId = s.intInventoryShipmentId
		AND si.intSort = se.intItemLotGroup
	INNER JOIN tblICItem i 
		ON i.intItemId = si.intItemId
WHERE i.strLotTracking <> 'No'

-- Insert into the reservation table.
-- Scan Headers
DECLARE @intShipmentId INT

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR SELECT DISTINCT intShipmentId FROM @ShipmentEntries

OPEN cur

FETCH NEXT FROM cur INTO @intShipmentId

WHILE @@FETCH_STATUS = 0
BEGIN	
	-- Calculate the Stock Reservation 
	EXEC @intResult = uspICReserveStockForInventoryShipment @intShipmentId		
	IF @intResult <> 0 RETURN @intResult

	-- Calculate the other charges
	BEGIN 			
		-- Calculate the other charges. 
		EXEC @intResult = dbo.uspICCalculateInventoryShipmentOtherCharges @intShipmentId			
		IF @intResult <> 0 RETURN @intResult

		-- Calculate the surcharges
		EXEC @intResult = dbo.uspICCalculateInventoryShipmentSurchargeOnOtherCharges @intShipmentId
		IF @intResult <> 0 RETURN @intResult
	END 	
	FETCH NEXT FROM cur INTO @intShipmentId
END

CLOSE cur
DEALLOCATE cur 

_Exit:
