CREATE PROCEDURE [dbo].[uspICAddInventoryTransfer]
	@TransferEntries InventoryTransferStagingTable READONLY
	,@intUserId AS INT	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @StartingNumberId_InventoryTransfer AS INT = 41;
DECLARE @InventoryTransferNumber AS NVARCHAR(50);
DECLARE @InventoryTransferId AS INT;

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
	RAISERROR(51180, 11, 1);	
	GOTO _Exit;
END 

-- Do a loop using a cursor. 
BEGIN 
	DECLARE @intEntityId AS INT;

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
		SET @InventoryTransferNumber = NULL 
		SET @InventoryTransferId = NULL 
		SET @intEntityId = NULL 

		-- Check if there is an existing Inventory Transfer 
		SELECT	@InventoryTransferId = RawData.intInventoryTransferId
		FROM	@TransferEntries RawData INNER JOIN @DataForInventoryTransferHeader RawHeaderData
					ON RawHeaderData.TransferType = RawData.strTransferType
					AND RawHeaderData.SourceType = RawData.intSourceType
					AND RawHeaderData.FromLocationId = RawData.intFromLocationId
					AND RawHeaderData.ToLocationId = RawData.intToLocationId
					AND RawHeaderData.StatusId = RawData.intStatusId
					AND ISNULL(RawHeaderData.ShipViaId, 0) = ISNULL(RawData.intShipViaId, 0)
		WHERE	RawHeaderData.intId = @intId
				
		IF @InventoryTransferId IS NULL 
		BEGIN 
			-- Generate the transfer starting number
			-- If @InventoryTransferNumber IS NULL, uspSMGetStartingNumber will throw an error. 
			-- Error is 'Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.'
			EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryTransfer, @InventoryTransferNumber OUTPUT 
			IF @@ERROR <> 0 OR @InventoryTransferNumber IS NULL GOTO _BreakLoop;
		END 

		-- Get the entity id's 
		SELECT	TOP 1 
				@intEntityId = intEntityId
		FROM	dbo.tblSMUserSecurity
		WHERE	intUserSecurityID = @intUserId

		MERGE	
		INTO	dbo.tblICInventoryTransfer 
		WITH	(HOLDLOCK) 
		AS		InventoryTransfer 
		USING (
			SELECT	RawData.*
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
				,intTransferredById		= @intEntityId
				,strDescription			= IntegrationData.strDescription
				,intFromLocationId		= IntegrationData.intFromLocationId
				,intToLocationId		= IntegrationData.intToLocationId
				,ysnShipmentRequired	= IntegrationData.ysnShipmentRequired
				,intStatusId			= IntegrationData.intStatusId
				,intShipViaId			= IntegrationData.intShipViaId
				,intFreightUOMId		= IntegrationData.intFreightUOMId
				,ysnPosted				= 0
				,intCreatedUserId		= @intUserId
				,intEntityId			= @intEntityId

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
				,intCreatedUserId	
				,intEntityId
			)
			VALUES (
				/*strTransferNo*/			@InventoryTransferNumber		
				/*dtmTransferDate*/			,dbo.fnRemoveTimeOnDate(ISNULL(IntegrationData.dtmTransferDate, GETDATE())) 
				/*strTransferType*/			,IntegrationData.strTransferType
				/*intSourceType*/			,IntegrationData.intSourceType
				/*intTransferredById*/		,@intEntityId
				/*strDescription*/			,IntegrationData.strDescription
				/*intFromLocationId*/		,IntegrationData.intFromLocationId
				/*intToLocationId*/			,IntegrationData.intToLocationId
				/*ysnShipmentRequired*/		,IntegrationData.ysnShipmentRequired
				/*intStatusId*/				,IntegrationData.intStatusId
				/*intShipViaId*/			,IntegrationData.intShipViaId
				/*intFreightUOMId*/			,IntegrationData.intFreightUOMId
				/*ysnPosted*/				,0
				/*intCreatedUserId*/		,@intUserId
				/*intEntityId*/				,@intEntityId
			)			
		;
				
		-- Get the identity value from tblICInventoryReceipt to check if the insert was successful
		IF @InventoryTransferId IS NULL 
		BEGIN 
			SELECT @InventoryTransferId = SCOPE_IDENTITY()
		END 

		-- Validate the Inventory Transfer id
		IF @InventoryTransferId IS NULL 
		BEGIN 
			-- 'Unable to generate the Inventory Transfer. An error stopped the creation of the inventory transfer.'
			RAISERROR(51181, 11, 1);
			RETURN;
		END

		--  Flush out existing detail detail data for re-insertion
		BEGIN 
			DELETE FROM dbo.tblICInventoryTransferDetail
			WHERE intInventoryTransferId = @InventoryTransferId
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
				,[intSort]
				,[intConcurrencyId]		
		)
		SELECT
				[intInventoryTransferId]	= @InventoryTransferId
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
		WHERE	InvTransfer.intInventoryTransferId = @InventoryTransferId

		-- Fetch the next row from cursor. 
		FETCH NEXT FROM loopDataForTransferHeader INTO @intId;
	END
	-- End of the loop

	_BreakLoop:

	CLOSE loopDataForTransferHeader;
	DEALLOCATE loopDataForTransferHeader;
END 

_Exit: