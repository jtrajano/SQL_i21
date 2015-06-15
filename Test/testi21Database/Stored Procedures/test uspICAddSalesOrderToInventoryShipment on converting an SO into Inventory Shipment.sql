CREATE PROCEDURE [testi21Database].[test uspICAddSalesOrderToInventoryShipment on converting an SO into Inventory Shipment]
AS
BEGIN
	-- Declare the variables for grains (item)
	DECLARE @WetGrains AS INT = 1
			,@StickyGrains AS INT = 2
			,@PremiumGrains AS INT = 3
			,@ColdGrains AS INT = 4
			,@HotGrains AS INT = 5
			,@ManualLotGrains AS INT = 6
			,@SerializedLotGrains AS INT = 7
			,@InvalidItem AS INT = -1

	-- Declare the variables for location
	DECLARE @Default_Location AS INT = 1
			,@NewHaven AS INT = 2
			,@BetterHaven AS INT = 3
			,@InvalidLocation AS INT = -1

	-- Declare the variables for the Item UOM Ids
	DECLARE @WetGrains_BushelUOMId AS INT = 1
			,@StickyGrains_BushelUOMId AS INT = 2
			,@PremiumGrains_BushelUOMId AS INT = 3
			,@ColdGrains_BushelUOMId AS INT = 4
			,@HotGrains_BushelUOMId AS INT = 5
			,@ManualLotGrains_BushelUOMId AS INT = 6
			,@SerializedLotGrains_BushelUOMId AS INT = 7

			,@WetGrains_PoundUOMId AS INT = 8
			,@StickyGrains_PoundUOMId AS INT = 9
			,@PremiumGrains_PoundUOMId AS INT = 10
			,@ColdGrains_PoundUOMId AS INT = 11
			,@HotGrains_PoundUOMId AS INT = 12
			,@ManualLotGrains_PoundUOMId AS INT = 13
			,@SerializedLotGrains_PoundUOMId AS INT = 14

	-- Declare Item-Locations
	DECLARE @WetGrains_DefaultLocation AS INT = 1
			,@StickyGrains_DefaultLocation AS INT = 2
			,@PremiumGrains_DefaultLocation AS INT = 3
			,@ColdGrains_DefaultLocation AS INT = 4
			,@HotGrains_DefaultLocation AS INT = 5

			,@WetGrains_NewHaven AS INT = 6
			,@StickyGrains_NewHaven AS INT = 7
			,@PremiumGrains_NewHaven AS INT = 8
			,@ColdGrains_NewHaven AS INT = 9
			,@HotGrains_NewHaven AS INT = 10

			,@WetGrains_BetterHaven AS INT = 11
			,@StickyGrains_BetterHaven AS INT = 12
			,@PremiumGrains_BetterHaven AS INT = 13
			,@ColdGrains_BetterHaven AS INT = 14
			,@HotGrains_BetterHaven AS INT = 15

			,@ManualLotGrains_DefaultLocation AS INT = 16
			,@SerializedLotGrains_DefaultLocation AS INT = 17

	DECLARE @SALES_CONTRACT AS NVARCHAR(50) = 'Sales Contract'
			,@SALES_ORDER AS NVARCHAR(50) = 'Sales Order'
			,@TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'			

	DECLARE @SALES_CONTRACT_TYPE_ID AS INT = 1
			,@SALES_ORDER_TYPE_ID AS INT = 2
			,@TRANSFER_ORDER_TYPE_ID AS INT = 3

	-- Fake Sales Order variables 
	BEGIN 
		DECLARE @STR_SO_10001 AS NVARCHAR(50) = 'SO-10001'
				,@INT_SO_10001 AS INT = 1
				,@INT_SO_10001_DETAIL_1  AS INT = 1
	END

	-- Fake customer variables 
	BEGIN 
		DECLARE @Customer_Paul_Unlimited AS NVARCHAR(50) = 'Paul Unlimited'
		DECLARE @Customer_Paul_Unlimited_Id AS INT = 1
	END

	-- Fake Ship Via variables
	BEGIN 
		DECLARE @Ship_Via_Truck AS NVARCHAR(50) = 'Truck'
				,@Ship_Via_Truck_Id AS INT = 1
	END 

	-- Fake Entity variables
	BEGIN 
		DECLARE @intUserId AS INT = 39989
		DECLARE @intEntityId AS INT = 19945
	END

	-- Arrange 
	BEGIN 
		-- Create the fake data. 		
		EXEC testi21Database.[Fake sales orders]

		-- Create the expected tables 
		EXEC testi21Database.[Inventory Shipment expected tables]

		DECLARE @Expected_Shipment_Id AS INT = 1

		INSERT INTO expected_tblICInventoryShipment (
			intInventoryShipmentId
			,strShipmentNumber
			,dtmShipDate
			,intOrderType
			,strReferenceNumber
			,dtmRequestedArrivalDate
			,intShipFromLocationId
			,intEntityCustomerId
			,intShipToLocationId
			,intFreightTermId
			,strBOLNumber
			,intShipViaId
			,strVessel
			,strProNumber
			,strDriverId
			,strSealNumber
			,strDeliveryInstruction
			,dtmAppointmentTime
			,dtmDepartureTime
			,dtmArrivalTime
			,dtmDeliveredDate
			,dtmFreeTime
			,strReceivedBy
			,strComment
			,ysnPosted
			,intEntityId
			,intCreatedUserId
			,intConcurrencyId
		)
		SELECT 
			intInventoryShipmentId		= @Expected_Shipment_Id
			,strShipmentNumber			= 'INVSHIP-1'
			,dtmShipDate				= '01/03/2015'
			,intOrderType				= @SALES_ORDER_TYPE_ID
			,strReferenceNumber			= @STR_SO_10001 
			,dtmRequestedArrivalDate	= NULL 
			,intShipFromLocationId		= @Default_Location
			,intEntityCustomerId		= @Customer_Paul_Unlimited_Id
			,intShipToLocationId		= NULL -- TODO -- There should be a intShipToId field in Sales Order
			,intFreightTermId			= NULL -- TODO -- There should be a Freight Term Id in Sales Order
			,strBOLNumber				= NULL 
			,intShipViaId				= @Ship_Via_Truck_Id
			,strVessel					= NULL 
			,strProNumber				= NULL -- a PRO number is a tracking number used by some but not all carriers.  
			,strDriverId				= NULL
			,strSealNumber				= NULL
			,strDeliveryInstruction		= NULL
			,dtmAppointmentTime			= NULL
			,dtmDepartureTime			= NULL
			,dtmArrivalTime				= NULL
			,dtmDeliveredDate			= NULL
			,dtmFreeTime				= NULL
			,strReceivedBy				= NULL
			,strComment					= 'Comments from Sales Order'
			,ysnPosted					= 0
			,intEntityId				= @intEntityId
			,intCreatedUserId			= @intUserId
			,intConcurrencyId			= 1

		INSERT INTO expected_tblICInventoryShipmentItem (
			intInventoryShipmentId
			,intOrderId
			,intLineNo
			,intItemId
			,intSubLocationId
			,dblQuantity
			,intItemUOMId
			,dblUnitPrice
			,intTaxCodeId
			,intDockDoorId
			,strNotes
			,intSort
			,intConcurrencyId		
		)
		SELECT 
			intInventoryShipmentId	= @Expected_Shipment_Id
			,intOrderId			= @INT_SO_10001
			,intLineNo				= @INT_SO_10001_DETAIL_1
			,intItemId				= @WetGrains
			,intSubLocationId		= NULL 
			,dblQuantity			= 10
			,intItemUOMId			= @WetGrains_BushelUOMId
			,dblUnitPrice			= 25.10
			,intTaxCodeId			= NULL
			,intDockDoorId			= NULL
			,strNotes				= 'Line detail comments'
			,intSort				= @INT_SO_10001_DETAIL_1
			,intConcurrencyId		= 1
	END

	-- Act
	BEGIN 
		DECLARE @InventoryShipmentIdResult AS INT 

		EXEC dbo.uspICAddSalesOrderToInventoryShipment
			@SalesOrderId = 1
			,@intUserId = @intUserId
			,@InventoryShipmentId = @InventoryShipmentIdResult OUTPUT			
	END 

	-- Assert
	BEGIN 
		-- Check if the output parameter value returned is correct. 
		EXEC tSQLt.AssertEquals @InventoryShipmentIdResult, @Expected_Shipment_Id

		-- Get the actual shipment header record 
		INSERT INTO actual_tblICInventoryShipment (
				intInventoryShipmentId
				,strShipmentNumber
				,dtmShipDate
				,intOrderType
				,strReferenceNumber
				,dtmRequestedArrivalDate
				,intShipFromLocationId
				,intEntityCustomerId
				,intShipToLocationId
				,intFreightTermId
				,strBOLNumber
				,intShipViaId
				,strVessel
				,strProNumber
				,strDriverId
				,strSealNumber
				,strDeliveryInstruction
				,dtmAppointmentTime
				,dtmDepartureTime
				,dtmArrivalTime
				,dtmDeliveredDate
				,dtmFreeTime
				,strReceivedBy
				,strComment
				,ysnPosted
				,intEntityId
				,intCreatedUserId
				,intConcurrencyId
		)
		SELECT 
				intInventoryShipmentId
				,strShipmentNumber
				,dtmShipDate
				,intOrderType
				,strReferenceNumber
				,dtmRequestedArrivalDate
				,intShipFromLocationId
				,intEntityCustomerId
				,intShipToLocationId
				,intFreightTermId
				,strBOLNumber
				,intShipViaId
				,strVessel
				,strProNumber
				,strDriverId
				,strSealNumber
				,strDeliveryInstruction
				,dtmAppointmentTime
				,dtmDepartureTime
				,dtmArrivalTime
				,dtmDeliveredDate
				,dtmFreeTime
				,strReceivedBy
				,strComment
				,ysnPosted
				,intEntityId
				,intCreatedUserId
				,intConcurrencyId
		FROM	dbo.tblICInventoryShipment
		WHERE	intInventoryShipmentId = @Expected_Shipment_Id

		-- Get the actual shipment detail record(s)
		INSERT INTO actual_tblICInventoryShipmentItem (
				intInventoryShipmentId
				,intOrderId
				,intLineNo
				,intItemId
				,intSubLocationId
				,dblQuantity
				,intItemUOMId
				,dblUnitPrice
				,intTaxCodeId
				,intDockDoorId
				,strNotes
				,intSort
				,intConcurrencyId		
		)
		SELECT 
				intInventoryShipmentId	
				,intOrderId			
				,intLineNo				
				,intItemId				
				,intSubLocationId		
				,dblQuantity			
				,intItemUOMId			
				,dblUnitPrice			
				,intTaxCodeId			
				,intDockDoorId			
				,strNotes				
				,intSort				
				,intConcurrencyId		
		FROM	dbo.tblICInventoryShipmentItem
		WHERE	intInventoryShipmentId = @Expected_Shipment_Id

		-- Check if the expected data in the tables are created
		EXEC tSQLt.AssertEqualsTable 'expected_tblICInventoryShipment', 'actual_tblICInventoryShipment'
		EXEC tSQLt.AssertEqualsTable 'expected_tblICInventoryShipmentItem', 'actual_tblICInventoryShipmentItem'
	END 
	
	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual_tblICInventoryShipment') IS NOT NULL 
		DROP TABLE actual_tblICInventoryShipment

	IF OBJECT_ID('actual_tblICInventoryShipmentItem') IS NOT NULL 
		DROP TABLE actual_tblICInventoryShipmentItem

	IF OBJECT_ID('expected_tblICInventoryShipment') IS NOT NULL 
		DROP TABLE expected_tblICInventoryShipmentItem

	IF OBJECT_ID('expected_tblICInventoryShipmentItem') IS NOT NULL 
		DROP TABLE expected_tblICInventoryShipmentItem
END
