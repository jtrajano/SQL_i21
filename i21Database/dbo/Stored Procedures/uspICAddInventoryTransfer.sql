CREATE PROCEDURE [dbo].[uspICAddInventoryTransfer]
	@TransferEntries InventoryTransferStagingTable READONLY
	,@intEntityUserSecurityId AS INT	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @StartingNumberId_InventoryTransfer AS INT = 41;
DECLARE @inventoryTransferNumber AS NVARCHAR(50);
DECLARE @inventoryTransferId AS INT
		,@strSourceId AS NVARCHAR(50)
		,@strSourceScreenName AS NVARCHAR(50)
		,@strTransferId AS NVARCHAR(50)		

-- Create the temp table if it does not exists. 
IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddInventoryTransferResult')) 
BEGIN 
	CREATE TABLE #tmpAddInventoryTransferResult (
		intSourceId INT
		,intInventoryTransferId INT
	)
END 

DECLARE @DataForInventoryTransferHeader TABLE(
	intId INT IDENTITY PRIMARY KEY CLUSTERED
	,TransferType NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,SourceType INT
	,FromLocationId INT
	,ToLocationId INT
	,StatusId INT
	,ShipViaId INT 
)

-- Sort the data from @TransferEntries and determine which ones are the header records. 
INSERT INTO @DataForInventoryTransferHeader(
		TransferType
		,SourceType
		,FromLocationId
		,ToLocationId
		,StatusId 
		,ShipViaId
)
SELECT	RawData.strTransferType
		,RawData.intSourceType
		,RawData.intFromLocationId
		,RawData.intToLocationId
		,RawData.intStatusId
		,RawData.intShipViaId
FROM	@TransferEntries RawData
GROUP BY RawData.strTransferType
		,RawData.intSourceType
		,RawData.intFromLocationId
		,RawData.intToLocationId
		,RawData.intStatusId
		,RawData.intShipViaId
;

-- Validate if there is data to process. If there is no data, then raise an error. 
IF NOT EXISTS (SELECT TOP 1 1 FROM @DataForInventoryTransferHeader)
BEGIN 
	-- 'Data not found. Unable to create the Inventory Transfer.'
	RAISERROR('Data not found. Unable to create the Inventory Transfer.', 11, 1);	
	GOTO _Exit;
END 

-- Do a loop using a cursor. 
BEGIN 

	DECLARE @intId INT
	DECLARE loopDataForTransferHeader CURSOR LOCAL FAST_FORWARD 
	FOR 
	SELECT intId FROM @DataForInventoryTransferHeader

	-- Open the cursor 
	OPEN loopDataForTransferHeader;

	-- First data row fetch from the cursor 
	FETCH NEXT FROM loopDataForTransferHeader INTO @intId;

	-- Begin Loop
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @inventoryTransferNumber = NULL 
		SET @inventoryTransferId = NULL 

		-- Check if there is an existing Inventory Transfer 
		SELECT	@inventoryTransferId = RawData.intInventoryTransferId
				,@strSourceScreenName = RawData.strSourceScreenName
				,@strSourceId = RawData.strSourceId
		FROM	@TransferEntries RawData INNER JOIN @DataForInventoryTransferHeader RawHeaderData
					ON RawHeaderData.TransferType = RawData.strTransferType
					AND RawHeaderData.SourceType = RawData.intSourceType
					AND RawHeaderData.FromLocationId = RawData.intFromLocationId
					AND RawHeaderData.ToLocationId = RawData.intToLocationId
					AND RawHeaderData.StatusId = RawData.intStatusId
					AND ISNULL(RawHeaderData.ShipViaId, 0) = ISNULL(RawData.intShipViaId, 0)
		WHERE	RawHeaderData.intId = @intId

		-- Block overwrite of a posted inventory transfer record.
		IF EXISTS (SELECT 1 FROM dbo.tblICInventoryTransfer WHERE intInventoryTransferId = @inventoryTransferId AND ISNULL(ysnPosted, 0) = 1) 
		BEGIN 
			SELECT	@inventoryTransferNumber = strTransferNo
			FROM	dbo.tblICInventoryTransfer 
			WHERE	intInventoryTransferId = @inventoryTransferId

			-- 'Unable to update %s. It is posted. Please unpost it first.'
			RAISERROR('Unable to update %s. It is posted. Please unpost it first.', 11, 1, @inventoryTransferNumber);	
			GOTO _Exit;
		END
				
		IF @inventoryTransferId IS NULL 
		BEGIN 
			-- Generate the transfer starting number
			-- If @inventoryTransferNumber IS NULL, uspSMGetStartingNumber will throw an error. 
			-- Error is 'Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.'
			EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryTransfer, @inventoryTransferNumber OUTPUT 
			IF @@ERROR <> 0 OR @inventoryTransferNumber IS NULL GOTO _BreakLoop;
		END 

		MERGE	
		INTO	dbo.tblICInventoryTransfer 
		WITH	(HOLDLOCK) 
		AS		InventoryTransfer 
		USING (
			SELECT	TOP 1 
					RawData.*
			FROM	@TransferEntries RawData INNER JOIN @DataForInventoryTransferHeader RawHeaderData
						ON RawHeaderData.TransferType = RawData.strTransferType
						AND RawHeaderData.SourceType = RawData.intSourceType
						AND RawHeaderData.FromLocationId = RawData.intFromLocationId
						AND RawHeaderData.ToLocationId = RawData.intToLocationId
						AND RawHeaderData.StatusId = RawData.intStatusId
						AND ISNULL(RawHeaderData.ShipViaId, 0) = ISNULL(RawData.intShipViaId, 0)
			WHERE	RawHeaderData.intId = @intId
		) AS IntegrationData
			ON InventoryTransfer.intInventoryTransferId = IntegrationData.intInventoryTransferId

		WHEN MATCHED THEN 
			UPDATE
			SET 
				dtmTransferDate			= dbo.fnRemoveTimeOnDate(ISNULL(IntegrationData.dtmTransferDate, GETDATE()))
				,strTransferType		= IntegrationData.strTransferType
				,intSourceType			= IntegrationData.intSourceType
				,intTransferredById		= @intEntityUserSecurityId
				,strDescription			= IntegrationData.strDescription
				,intFromLocationId		= IntegrationData.intFromLocationId
				,intToLocationId		= IntegrationData.intToLocationId
				,ysnShipmentRequired	= IntegrationData.ysnShipmentRequired
				,intStatusId			= IntegrationData.intStatusId
				,intShipViaId			= IntegrationData.intShipViaId
				,intFreightUOMId		= IntegrationData.intFreightUOMId
				,ysnPosted				= 0
				,intEntityId			= @intEntityUserSecurityId
				,strActualCostId		= IntegrationData.strActualCostId

		WHEN NOT MATCHED THEN 
			INSERT (
				strTransferNo
				,dtmTransferDate		
				,strTransferType	
				,intSourceType		
				,intTransferredById	
				,strDescription		
				,intFromLocationId	
				,intToLocationId	
				,ysnShipmentRequired
				,intStatusId		
				,intShipViaId		
				,intFreightUOMId	
				,ysnPosted			
				,intEntityId
				,strActualCostId
			)
			VALUES (
				/*strTransferNo*/			@inventoryTransferNumber		
				/*dtmTransferDate*/			,dbo.fnRemoveTimeOnDate(ISNULL(IntegrationData.dtmTransferDate, GETDATE())) 
				/*strTransferType*/			,IntegrationData.strTransferType
				/*intSourceType*/			,IntegrationData.intSourceType
				/*intTransferredById*/		,@intEntityUserSecurityId
				/*strDescription*/			,IntegrationData.strDescription
				/*intFromLocationId*/		,IntegrationData.intFromLocationId
				/*intToLocationId*/			,IntegrationData.intToLocationId
				/*ysnShipmentRequired*/		,IntegrationData.ysnShipmentRequired
				/*intStatusId*/				,IntegrationData.intStatusId
				/*intShipViaId*/			,IntegrationData.intShipViaId
				/*intFreightUOMId*/			,IntegrationData.intFreightUOMId
				/*ysnPosted*/				,0
				/*intEntityId*/				,@intEntityUserSecurityId
				/*strActualCostId*/			,IntegrationData.strActualCostId
			)			
		;
				
		-- Get the identity value from tblICInventoryReceipt to check if the insert was successful
		IF @inventoryTransferId IS NULL 
		BEGIN 
			SELECT @inventoryTransferId = SCOPE_IDENTITY()
		END 

		-- Validate the Inventory Transfer id
		IF @inventoryTransferId IS NULL 
		BEGIN 
			-- 'Unable to generate the Inventory Transfer. An error stopped the creation of the inventory transfer.'
			RAISERROR('Unable to generate the Inventory Transfer. An error stopped the creation of the inventory transfer.', 11, 1);
			RETURN;
		END

		--  Flush out existing detail detail data for re-insertion
		BEGIN 
			DELETE FROM dbo.tblICInventoryTransferDetail
			WHERE intInventoryTransferId = @inventoryTransferId
		END 

		-- Insert the Inventory Transfer Detail. 
		INSERT INTO dbo.tblICInventoryTransferDetail (
				[intInventoryTransferId]
				,[intSourceId]
				,[intItemId]
				,[intLotId]
				,[intFromSubLocationId]
				,[intToSubLocationId]
				,[intFromStorageLocationId]
				,[intToStorageLocationId]
				,[dblQuantity]
				,[intItemUOMId]
				,[intItemWeightUOMId]
				,[dblGrossWeight]
				,[dblTareWeight]
				,[intNewLotId]
				,[strNewLotId]
				,[dblCost]
				,[intTaxCodeId]
				,[dblFreightRate]
				,[dblFreightAmount]
				,[intOwnershipType]
				,[ysnWeights]
				,[intSort]
				,[intConcurrencyId]		
		)
		SELECT
				[intInventoryTransferId]	= @inventoryTransferId
				,[intSourceId]				= RawData.intSourceId
				,[intItemId]				= RawData.intItemId
				,[intLotId]					= RawData.intLotId
				,[intFromSubLocationId]		= RawData.intFromSubLocationId
				,[intToSubLocationId]		= RawData.intToSubLocationId
				,[intFromStorageLocationId]	= RawData.intFromStorageLocationId
				,[intToStorageLocationId]	= RawData.intToStorageLocationId
				,[dblQuantity]				= RawData.dblQuantityToTransfer
				,[intItemUOMId]				= RawData.intItemUOMId
				,[intItemWeightUOMId]		= Lot.intWeightUOMId
				,[dblGrossWeight]			= 0
				,[dblTareWeight]			= 0 
				,[intNewLotId]				= NULL 
				,[strNewLotId]				= RawData.strNewLotId
				,[dblCost]					= ISNULL(Lot.dblLastCost, ItemPricing.dblLastCost)
				,[intTaxCodeId]				= NULL 
				,[dblFreightRate]			= NULL 
				,[dblFreightAmount]			= NULL 
				,[intOwnershipType]			= RawData.intOwnershipType
				,[ysnWeights]				= RawData.ysnWeights
				,[intSort]					= NULL 
				,[intConcurrencyId]			= 1
		FROM	@TransferEntries RawData INNER JOIN @DataForInventoryTransferHeader RawHeaderData
					ON RawHeaderData.TransferType = RawData.strTransferType
					AND RawHeaderData.SourceType = RawData.intSourceType
					AND RawHeaderData.FromLocationId = RawData.intFromLocationId
					AND RawHeaderData.ToLocationId = RawData.intToLocationId
					AND RawHeaderData.StatusId = RawData.intStatusId
					AND ISNULL(RawHeaderData.ShipViaId, 0) = ISNULL(RawData.intShipViaId, 0)
				INNER JOIN dbo.tblICItemLocation FromItemLocation
					ON FromItemLocation.intItemId = RawData.intItemId
					AND FromItemLocation.intLocationId = RawData.intFromLocationId
				LEFT JOIN dbo.tblICLot Lot
					ON Lot.intLotId = RawData.intLotId 
				LEFT JOIN dbo.tblICItemPricing ItemPricing
					ON ItemPricing.intItemId = RawData.intItemId
					AND ItemPricing.intItemLocationId = FromItemLocation.intItemLocationId
		WHERE	RawHeaderData.intId = @intId

		-- Log successful inserts. 
		INSERT INTO #tmpAddInventoryTransferResult (
			intSourceId
			,intInventoryTransferId
		)
		SELECT	InvDetail.intSourceId
				,InvTransfer.intInventoryTransferId
		FROM	dbo.tblICInventoryTransfer InvTransfer INNER JOIN dbo.tblICInventoryTransferDetail InvDetail
					ON InvTransfer.intInventoryTransferId = InvDetail.intInventoryTransferId
		WHERE	InvTransfer.intInventoryTransferId = @inventoryTransferId

		-- Create an Audit Log
		BEGIN 
			DECLARE @strDescription AS NVARCHAR(100) = @strSourceScreenName + ' to Inventory Transfer'
			
			SELECT	@strTransferId = strTransferNo
			FROM	dbo.tblICInventoryTransfer 
			WHERE	intInventoryTransferId = @inventoryTransferId
			
			EXEC	dbo.uspSMAuditLog 
					@keyValue = @inventoryTransferId						-- Primary Key Value of the Inventory Transfer. 
					,@screenName = 'Inventory.view.InventoryTransfer'       -- Screen Namespace
					,@entityId = @intEntityUserSecurityId                   -- Entity Id.
					,@actionType = 'Processed'                              -- Action Type
					,@changeDescription = @strDescription					-- Description
					,@fromValue = @strSourceId                              -- Previous Value
					,@toValue = @strTransferId								-- New Value
		END


		-- Fetch the next row from cursor. 
		FETCH NEXT FROM loopDataForTransferHeader INTO @intId;
	END
	-- End of the loop

	_BreakLoop:

	CLOSE loopDataForTransferHeader;
	DEALLOCATE loopDataForTransferHeader;
END 

_Exit: