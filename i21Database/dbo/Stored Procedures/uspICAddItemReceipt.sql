CREATE PROCEDURE [dbo].[uspICAddItemReceipt]
	@ReceiptEntries ReceiptStagingTable READONLY
	,@OtherCharges ReceiptOtherChargesTableType READONLY 
	,@intUserId AS INT	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @StartingNumberId_InventoryReceipt AS INT = 23;
DECLARE @ReceiptNumber AS NVARCHAR(50);
DECLARE @InventoryReceiptId AS INT;

				-- Ownership Types
DECLARE	@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

DECLARE @DataForReceiptHeader TABLE(
	intId INT IDENTITY PRIMARY KEY CLUSTERED
    ,Vendor INT
    ,BillOfLadding NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,ReceiptType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,Location INT
	,ShipVia INT
	,ShipFrom INT
	,Currency INT
	,intSourceType INT
	,strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
)

DECLARE @result AS TABLE (
	intSourceId INT
	,intInventoryReceiptId INT
)

-- Sort the data from @ReceiptEntries and determine which ones are the header records. 
INSERT INTO @DataForReceiptHeader(
		Vendor
		,BillOfLadding
		,ReceiptType
		,Location
		,ShipVia
		,ShipFrom
		,Currency
		,intSourceType
)
SELECT	RawData.intEntityVendorId
		,RawData.strBillOfLadding
		,RawData.strReceiptType
		,RawData.intLocationId
		,RawData.intShipViaId
		,RawData.intShipFromId
		,RawData.intCurrencyId
		,RawData.intSourceType
FROM	@ReceiptEntries RawData
GROUP BY RawData.intEntityVendorId
		,RawData.strBillOfLadding
		,RawData.strReceiptType
		,RawData.intLocationId
		,RawData.intShipViaId
		,RawData.intShipFromId
		,RawData.intCurrencyId
		,RawData.intSourceType
;

-- Validate if there is data to process. If there is no data, then raise an error. 
IF NOT EXISTS (SELECT TOP 1 1 FROM @DataForReceiptHeader)
BEGIN 
	-- 'Data not found. Unable to create the Inventory Receipt.'
	RAISERROR(51169, 11, 1);	
	GOTO _Exit;
END 

-- Do a loop using a cursor. 
BEGIN 
	DECLARE @intId INT
	DECLARE loopDataForReceiptHeader CURSOR LOCAL FAST_FORWARD 
	FOR 
	SELECT intId FROM @DataForReceiptHeader

	-- Open the cursor 
	OPEN loopDataForReceiptHeader;

	-- First data row fetch from the cursor 
	FETCH NEXT FROM loopDataForReceiptHeader INTO @intId;

	-- Begin Loop
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		
		SET @ReceiptNumber = NULL 
		SET @InventoryReceiptId = NULL 

		-- Generate the receipt starting number
		-- If @ReceiptNumber IS NULL, uspSMGetStartingNumber will throw an error. 
		-- Error is 'Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.'
		EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryReceipt, @ReceiptNumber OUTPUT 
		IF @@ERROR <> 0 OR @ReceiptNumber IS NULL GOTO _BreakLoop;

		-- Insert the Inventory Receipt header 
		INSERT INTO dbo.tblICInventoryReceipt (
				strReceiptNumber
				,dtmReceiptDate
				,intEntityVendorId
				,strReceiptType
				,intSourceType
				,intBlanketRelease
				,intLocationId
				,strVendorRefNo
				,strBillOfLading
				,intShipViaId
				,intShipFromId
				,intReceiverId
				,intCurrencyId
				,strVessel
				,intFreightTermId
				,strAllocateFreight
				,intShiftNumber
				,dblInvoiceAmount
				,ysnInvoicePaid
				,intCheckNo
				,dtmCheckDate
				,intTrailerTypeId
				,dtmTrailerArrivalDate
				,dtmTrailerArrivalTime
				,strSealNo
				,strSealStatus
				,dtmReceiveTime
				,dblActualTempReading
				,intConcurrencyId
				,intEntityId
				,intCreatedUserId
				,ysnPosted
		)
		SELECT 	 strReceiptNumber       = @ReceiptNumber
				,dtmReceiptDate			= dbo.fnRemoveTimeOnDate(GETDATE())
				,intEntityVendorId		= RawData.intEntityVendorId
				,strReceiptType			= RawData.strReceiptType
				,intSourceType          = RawData.intSourceType
				,intBlanketRelease		= NULL
				,intLocationId			= RawData.intLocationId
				,strVendorRefNo			= NULL
				,strBillOfLading		= RawData.strBillOfLadding
				,intShipViaId			= RawData.intShipViaId
				,intShipFromId			= RawData.intShipFromId
				,intReceiverId			= @intUserId 
				,intCurrencyId			= RawData.intCurrencyId
				,strVessel				= NULL
				,intFreightTermId		= NULL
				,strAllocateFreight		= 'No' -- Default is No
				,intShiftNumber			= NULL 
				,dblInvoiceAmount		= 0
				,ysnInvoicePaid			= 0 
				,intCheckNo				= NULL 
				,dteCheckDate			= NULL 
				,intTrailerTypeId		= NULL 
				,dteTrailerArrivalDate	= NULL 
				,dteTrailerArrivalTime	= NULL 
				,strSealNo				= NULL 
				,strSealStatus			= NULL 
				,dteReceiveTime			= NULL 
				,dblActualTempReading	= NULL 
				,intConcurrencyId		= 1
				,intEntityId			= (SELECT TOP 1 intEntityId FROM dbo.tblSMUserSecurity WHERE intUserSecurityID = @intUserId)
				,intCreatedUserId		= @intUserId
				,ysnPosted				= 0
		FROM	@ReceiptEntries RawData INNER JOIN @DataForReceiptHeader RawHeaderData
					ON RawHeaderData.Vendor = RawData.intEntityVendorId 
					AND ISNULL(RawHeaderData.BillOfLadding,0) = ISNULL(RawData.strBillOfLadding,0) 
					AND ISNULL(RawHeaderData.Currency,0) = ISNULL(RawData.intCurrencyId,0)
					AND ISNULL(RawHeaderData.Location,0) = ISNULL(RawData.intLocationId,0)
					AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(RawData.strReceiptType,0)
					AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(RawData.intShipFromId,0)
					AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(RawData.intShipViaId,0)	
		WHERE	RawHeaderData.intId = @intId	           
				
		-- Get the identity value from tblICInventoryReceipt to check if the insert was created with no errors 
		SELECT @InventoryReceiptId = SCOPE_IDENTITY()
						
		-- Validate the inventory receipt id
		IF @InventoryReceiptId IS NULL 
		BEGIN 
			-- Unable to generate the Inventory Receipt. An error stopped the process from Purchase Order to Inventory Receipt.
			RAISERROR(50031, 11, 1);
			RETURN;
		END

		-- Insert the Inventory Receipt Detail. 
		INSERT INTO dbo.tblICInventoryReceiptItem (
				intInventoryReceiptId
				,intLineNo
				,intOrderId
				,intSourceId
				,intItemId
				,intSubLocationId
				,dblOrderQty
				,dblOpenReceive
				,dblReceived
				,intUnitMeasureId
				,intWeightUOMId
				,dblUnitCost
				,dblLineTotal
				,intSort
				,intConcurrencyId
				,intOwnershipType
		)
		SELECT	intInventoryReceiptId	= @InventoryReceiptId
				,intLineNo				= ISNULL(RawData.intContractDetailId, 0)
				,intOrderId				= RawData.intContractHeaderId
				,intSourceId			= RawData.intSourceId
				,intItemId				= RawData.intItemId
				,intSubLocationId		= NULL
				,dblOrderQty			= ISNULL(RawData.dblQty, 0)
				,dblOpenReceive			= ISNULL(RawData.dblQty, 0)
				,dblReceived			= ISNULL(RawData.dblQty, 0)
				,intUnitMeasureId		= ItemUOM.intItemUOMId
				,intWeightUOMId			= (
												SELECT	TOP 1 
														tblICItemUOM.intItemUOMId 
												FROM	dbo.tblICItemUOM INNER JOIN dbo.tblICUnitMeasure
															ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
												WHERE	tblICItemUOM.intItemId = RawData.intItemId 
														AND tblICItemUOM.ysnStockUnit = 1 
														AND tblICUnitMeasure.strUnitType = 'Weight'
														AND dbo.fnGetItemLotType(RawData.intItemId) IN (1,2)
										)
				,dblUnitCost			= RawData.dblCost
				,dblLineTotal			= RawData.dblQty * RawData.dblCost
				,intSort				= 1
				,intConcurrencyId		= 1
				,intOwnershipType       = CASE	WHEN RawData.ysnIsCustody = 0 THEN @OWNERSHIP_TYPE_Own
												WHEN RawData.ysnIsCustody = 1 THEN @OWNERSHIP_TYPE_Storage
												ELSE @OWNERSHIP_TYPE_Own
										  END
		FROM	@ReceiptEntries RawData INNER JOIN @DataForReceiptHeader RawHeaderData 
					ON RawHeaderData.Vendor = RawData.intEntityVendorId 
					AND ISNULL(RawHeaderData.BillOfLadding,0) = ISNULL(RawData.strBillOfLadding,0) 
					AND ISNULL(RawHeaderData.Currency,0) = ISNULL(RawData.intCurrencyId,0)
					AND ISNULL(RawHeaderData.Location,0) = ISNULL(RawData.intLocationId,0)
					AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(RawData.strReceiptType,0)
					AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(RawData.intShipFromId,0)
					AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(RawData.intShipViaId,0)		   
				INNER JOIN dbo.tblICItemUOM ItemUOM			
					ON ItemUOM.intItemId = RawData.intItemId  
					AND ItemUOM.intItemUOMId = RawData.intItemUOMId			
				INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId	
		WHERE RawHeaderData.intId = @intId

		-- Insert the Other Charges
		INSERT INTO dbo.tblICInventoryReceiptCharge (
				[intInventoryReceiptId]
				,[intContractId]
				,[intChargeId]
				,[ysnInventoryCost]
				,[strCostMethod]
				,[dblRate]
				,[intCostUOMId]
				,[intEntityVendorId]
				,[dblAmount]
				,[strAllocateCostBy]
				,[strCostBilledBy]
		)
		SELECT 
				[intInventoryReceiptId]		= @InventoryReceiptId
				,[intContractId]			= RawData.intContractDetailId
				,[intChargeId]				= RawData.intChargeId
				,[ysnInventoryCost]			= RawData.ysnInventoryCost
				,[strCostMethod]			= RawData.strCostMethod
				,[dblRate]					= RawData.dblRate
				,[intCostUOMId]				= RawData.intCostUOMId
				,[intEntityVendorId]		= RawData.intEntityVendorId
				,[dblAmount]				= RawData.dblAmount
				,[strAllocateCostBy]		= RawData.strAllocateCostBy
				,[strCostBilledBy]			= RawData.strCostBilledBy
		FROM	@OtherCharges RawData INNER JOIN @DataForReceiptHeader RawHeaderData 
					ON RawHeaderData.Vendor = RawData.intEntityVendorId 
					AND ISNULL(RawHeaderData.BillOfLadding,0) = ISNULL(RawData.strBillOfLadding,0) 
					AND ISNULL(RawHeaderData.ReceiptType,0) = ISNULL(RawData.strReceiptType,0)
					AND ISNULL(RawHeaderData.Location,0) = ISNULL(RawData.intLocationId,0)
					AND ISNULL(RawHeaderData.ShipVia,0) = ISNULL(RawData.intShipViaId,0)		   
					AND ISNULL(RawHeaderData.ShipFrom,0) = ISNULL(RawData.intShipFromId,0)
					AND ISNULL(RawHeaderData.Currency,0) = ISNULL(RawData.intCurrencyId,0)
				LEFT JOIN dbo.tblICItemUOM ItemUOM			
					ON ItemUOM.intItemId = RawData.intChargeId  
					AND ItemUOM.intItemUOMId = RawData.intCostUOMId
				INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId	
		WHERE RawHeaderData.intId = @intId

		-- Re-update the total cost 
		UPDATE	Receipt
		SET		dblInvoiceAmount = (
					SELECT	ISNULL(SUM(ISNULL(ReceiptItem.dblOpenReceive, 0) * ISNULL(ReceiptItem.dblUnitCost, 0)) , 0)
					FROM	dbo.tblICInventoryReceiptItem ReceiptItem
					WHERE	ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
				)
		FROM	dbo.tblICInventoryReceipt Receipt 
		WHERE	intInventoryReceiptId = @InventoryReceiptId

		-- Log successful inserts. 
		INSERT INTO @result (
			intSourceId
			,intInventoryReceiptId
		)
		SELECT	ReceiptItem.intSourceId
				,Receipt.intInventoryReceiptId
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		WHERE	Receipt.intInventoryReceiptId = @InventoryReceiptId

		-- Fetch the next row from cursor. 
		FETCH NEXT FROM loopDataForReceiptHeader INTO @intId;
	END
	-- End of the loop

	_BreakLoop:

	CLOSE loopDataForReceiptHeader;
	DEALLOCATE loopDataForReceiptHeader;
END 

-- Output the values to calling SP
SELECT * FROM @result

_Exit: