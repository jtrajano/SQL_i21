CREATE PROCEDURE [dbo].[uspICAdjustStockFromSAP]
	@dtmQtyChange			DATETIME	   = NULL	-- Date of quantity change (if not specified, it will default to current system date)
	,@intItemId				INT						-- Id of item to adjust
	,@strLotNumber			NVARCHAR(50)   = NULL	-- Lot Number of the item to adjust (required for lot tracked items; Can be flagged as '[FIFO]' if exact lot number can't be specified. The system will reduce the lot in FIFO order.)
	,@intLocationId			INT						-- Location Id of the item
	,@intSubLocationId		INT						-- Sub Location of the item
	,@intStorageLocationId	INT 		   = NULL	-- Storage Location of the item
	,@intItemUOMId			INT 		   = NULL	-- Unit of Measure Id of the item (if not specified, system will get the item's stock UOM id)
	,@dblNewQty				NUMERIC(38, 20)	        -- New Quantity for the item
	,@dblCost				NUMERIC(38, 20)= NULL	-- Cost of the item (required if increasing stock; if missing, the system will use the item's last cost to increase the stock)
	,@intEntityUserId		INT 					-- Entity User Id
	,@intSourceId			INT						-- Source Transaction Id
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

------------------------------  
-- Declaration of Variables -- 
------------------------------ 
DECLARE
	@intLotId AS INT
	,@strItemNo AS NVARCHAR(50)
	,@dblAdjustQtyBy AS NUMERIC(38, 20) = 0
	,@intItemLocationId AS INT
	,@tempEachLotQty AS NUMERIC(38,20)
	,@tempAdjustQtyBy AS NUMERIC(38,20)
	,@temp_RemainingQty AS NUMERIC(38,20)
	,@intInventoryAdjustmentId AS INT
	,@intInventoryLotId AS INT

BEGIN

	---------------- 
	-- SET Values --
	----------------
	-- Set Transaction Date
		--SET @dtmQtyChange = ISNULL(@dtmQtyChange, GETDATE());
	IF EXISTS(SELECT * FROM tblICInventoryLot Lot WHERE Lot.intItemId=@intItemId)
		BEGIN
			IF @dtmQtyChange IS NULL
				BEGIN
					SELECT TOP 1 @dtmQtyChange=Lot.dtmDate 
					FROM tblICInventoryLot Lot 
						LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = Lot.intItemId
					WHERE Lot.intItemId=@intItemId AND Lot.intSubLocationId=@intSubLocationId AND ItemLocation.intLocationId = @intLocationId
					ORDER BY Lot.dtmDate desc
				END
		END
	ELSE
		SET @dtmQtyChange = ISNULL(@dtmQtyChange, GETDATE());
 	
	IF @intItemId IS NOT NULL
		BEGIN
			-- Set UOM Id
			SET @intItemUOMId = ISNULL(@intItemUOMId, dbo.fnGetItemStockUOM(@intItemId));

			-- Set value for Item No
			SELECT @strItemNo = strItemNo
			FROM tblICItem 
			WHERE intItemId = @intItemId

			-- Set Item Location Id
			IF @intLocationId IS NOT NULL
				BEGIN
					SELECT @intItemLocationId = intItemLocationId
					FROM dbo.tblICItemLocation
					WHERE intLocationId = @intLocationId AND intItemId = @intItemId
				END
		END

	---------------------------------------------
	-- Validate values specified in the fields --
	---------------------------------------------

	-- Validate Item Id
	IF @intItemId IS NULL
		BEGIN 
			-- Item id is invalid or missing.
			RAISERROR(80001, 11,1);
			GOTO _Exit;
		END

	-- Validate New Quantity
	IF @dblNewQty IS NULL
		BEGIN
			-- New Quantity for item {item} is required.
			RAISERROR(80099, 11, 1, @strItemNo);
			GOTO _Exit;
		END

	-- Validate the date against the FY Periods  
	IF EXISTS (SELECT 1 WHERE dbo.isOpenAccountingDate(@dtmQtyChange) = 0) 
	BEGIN   
		-- Unable to find an open fiscal year period to match the transaction date.  
		RAISERROR(50005, 11, 1);
		GOTO _Exit;
	END
	
	-- Validate Item Id
	IF NOT EXISTS (SELECT 1 FROM tblICItem where intItemId = @intItemId)
	BEGIN
		-- Invalid Item.
		RAISERROR(80021, 11, 1); 
		GOTO _Exit;
	END

	-- Validate Source Id
	IF @intSourceId IS NULL
	BEGIN
		-- 'Internal Error. The source transaction id is invalid.'
		RAISERROR(80033, 11, 1)  
		GOTO _Exit;
	END

	-- Validate Item Location
	IF NOT EXISTS (SELECT 1 FROM dbo.tblICItemLocation WHERE intLocationId = @intLocationId AND intItemId = @intItemId)
	BEGIN
		-- Item Location is invalid or missing for {item}
		RAISERROR(80002, 11, 1, @strItemNo);
		GOTO _Exit;
	END

	-- Validate Sub Location
	IF NOT EXISTS (SELECT 1 FROM tblSMCompanyLocationSubLocation SubLocation WHERE SubLocation.intCompanyLocationSubLocationId = @intSubLocationId AND SubLocation.intCompanyLocationId = @intLocationId)
		BEGIN
			-- Sub Location is invalid or missing for item {item}.
			RAISERROR(80097, 11, 1, @strItemNo);
			GOTO _Exit;
		END

	-- Validate Storage Location if specified
	IF @intStorageLocationId IS NOT NULL
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM tblICStorageLocation StorageLocation WHERE StorageLocation.intLocationId = @intLocationId AND StorageLocation.intSubLocationId = @intSubLocationId AND StorageLocation.intStorageLocationId = @intStorageLocationId)
				BEGIN
					-- Storage Location is invalid for item {item}
					RAISERROR(80098, 11, 1, @strItemNo);
					GOTO _Exit;
				END
		END

	-- Check the lot number if it is lot-tracked. Validate the lot number. 
	IF dbo.fnGetItemLotType(@intItemId) <> 0 
	BEGIN
		IF @strLotNumber IS NOT NULL AND UPPER(@strLotNumber) NOT IN ('[FIFO]', 'FIFO') 
		BEGIN
			-- Find the Lot Id
			BEGIN 
				SELECT	@intLotId = Lot.intLotId
				FROM	dbo.tblICLot Lot 
				WHERE	Lot.strLotNumber = @strLotNumber
						AND Lot.intItemId = @intItemId
						AND ISNULL(Lot.intLocationId, 0) = ISNULL(@intLocationId, ISNULL(Lot.intLocationId, 0)) 
						AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, ISNULL(Lot.intSubLocationId, 0))
						AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, ISNULL(Lot.intStorageLocationId, 0)) 
			END 

			-- Raise an error if Lot id is invalid. 
			IF @intLotId IS NULL 
			BEGIN 
				-- Invalid Lot
				RAISERROR(80020, 11, 1);
				GOTO _Exit;
			END 	

			-- Check if the item uom id is valid for the lot record. 
			IF NOT EXISTS (
				SELECT	TOP 1 1
				FROM	dbo.tblICLot 
				WHERE	intItemId = @intItemId
						AND intLotId = @intLotId
						AND (intItemUOMId = @intItemUOMId OR intWeightUOMId = @intItemUOMId) 
			)
			BEGIN 
				-- Item UOM is invalid or missing.
				RAISERROR(80048, 11, 1);
				GOTO _Exit;
			END 
		END
	END

	-- Validate Item UOM Id
	IF @intItemUOMId IS NOT NULL AND @intItemUOMId NOT IN (SELECT intItemUOMId FROM tblICItemUOM)
		BEGIN
			-- UOM Id is invalid for item {Item}
			RAISERROR(80104,11,1,@strItemNo);
			GOTO _Exit;
		END

	-- If Item has no existing Stocks, create a new stock
	IF NOT EXISTS (SELECT intItemId FROM tblICItemStockUOM WHERE intItemId = @intItemId AND intItemUOMId = @intItemUOMId)
	BEGIN
		EXEC dbo.uspICPostStockQuantity
			@intItemId
			,@intItemLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@intItemUOMId
			,0
			,1
			,@intLotId
	END
	--------------------------------------
	-- Transaction: Quantity Adjustment -- 
	--------------------------------------

	 -- Check if item is Lot-Tracked or not
	 IF EXISTS(SELECT * FROM tblICItem WHERE intItemId = @intItemId AND strLotTracking ='No')
	-- Process Non-Lot-tracked items
	BEGIN
		-- Get the value to Adjust
		SELECT	@dblAdjustQtyBy = -(SUM(ISNULL(StockUOM.dblOnHand, 0)) - @dblNewQty)
		FROM	dbo.tblICItemStockUOM StockUOM
		WHERE	StockUOM.intItemId = @intItemId 
				AND StockUOM.intItemUOMId = @intItemUOMId
				AND StockUOM.intItemLocationId = @intItemLocationId 
				AND StockUOM.intSubLocationId = @intSubLocationId 

		IF @dblAdjustQtyBy IS NULL 
			SET @dblAdjustQtyBy = @dblNewQty

		IF @dblAdjustQtyBy = 0 
			GOTO _Exit

		ELSE 
		BEGIN
			SELECT TOP 1 
					@intStorageLocationId = intStorageLocationId
			FROM	dbo.tblICItemStockUOM
			WHERE	intItemId = @intItemId 
					AND intSubLocationId = @intSubLocationId 
					AND intItemLocationId = @intItemLocationId
					AND @intStorageLocationId IS NULL

			-- Create Quantity Change Adjustment then post
			GOTO _AdjustQuantity
		END
	END

	ELSE
	BEGIN
		-- Process Item with Lot Number Provided
		IF @strLotNumber IS NOT NULL AND UPPER(@strLotNumber) NOT IN ('[FIFO]','FIFO')
		BEGIN
			-- Get the value to Adjust
			SELECT @dblAdjustQtyBy = -(ISNULL(SUM(ISNULL(ICLot.dblStockIn, 0) - ISNULL(ICLot.dblStockOut, 0)) - @dblNewQty,0))
			FROM dbo.tblICInventoryLot ICLot INNER JOIN dbo.tblICLot Lot ON Lot.intLotId = ICLot.intLotId
			WHERE Lot.intItemId = @intItemId AND Lot.strLotNumber = @strLotNumber AND ICLot.intItemUOMId = @intItemUOMId

			-- Get value for @intInventoryLotId --
			SELECT @intInventoryLotId = ICLot.intInventoryLotId
			FROM dbo.tblICInventoryLot ICLot INNER JOIN dbo.tblICLot Lot ON Lot.intLotId = ICLot.intLotId
			WHERE Lot.intItemId = @intItemId AND Lot.strLotNumber = @strLotNumber AND ICLot.intItemUOMId = @intItemUOMId

			IF @intStorageLocationId IS NULL
				BEGIN
					SET @intStorageLocationId = 
					(SELECT TOP 1 ICLot.intStorageLocationId
						FROM dbo.tblICInventoryLot ICLot INNER JOIN dbo.tblICLot Lot ON Lot.intLotId = ICLot.intLotId
						WHERE ICLot.intItemId = @intItemId AND ICLot.intSubLocationId = @intSubLocationId AND ICLot.intItemLocationId = @intItemLocationId AND ICLot.intItemUOMId = @intItemUOMId AND Lot.strLotNumber = @strLotNumber 
					)
				END

			IF @dblCost IS NULL
				BEGIN
					SELECT	@dblCost = dblLastCost 
					FROM	dbo.tblICInventoryLot cb INNER JOIN dbo.tblICLot Lot 
								ON Lot.intLotId = cb.intLotId
					WHERE	cb.intInventoryLotId = @intInventoryLotId
				END

			IF @dblAdjustQtyBy IS NULL 
				SET @dblAdjustQtyBy = @dblNewQty

			IF @dblAdjustQtyBy = 0 
				GOTO _Exit

			GOTO _AdjustQuantity
		END

		-- Process Item with No Lot Number Provided
		ELSE
		BEGIN
			-- Get the value to Adjust
			SELECT	@dblAdjustQtyBy = -(SUM(ISNULL(StockUOM.dblOnHand, 0)) - @dblNewQty)
			FROM	dbo.tblICItemStockUOM StockUOM
			WHERE	StockUOM.intItemId = @intItemId 
					AND StockUOM.intItemUOMId = @intItemUOMId
					AND StockUOM.intItemLocationId = @intItemLocationId 
					AND StockUOM.intSubLocationId = @intSubLocationId 

			IF @dblAdjustQtyBy IS NULL 
				SET @dblAdjustQtyBy = @dblNewQty;

			IF @dblAdjustQtyBy = 0 
				GOTO _Exit

			ELSE IF @dblAdjustQtyBy > 0
			BEGIN
				SELECT TOP 1 
						@strLotNumber = Lot.strLotNumber 
						,@intInventoryLotId = cb.intInventoryLotId
				FROM	dbo.tblICInventoryLot cb INNER JOIN dbo.tblICLot Lot 
							ON Lot.intLotId = cb.intLotId
				WHERE	cb.intItemId = @intItemId 
						AND cb.intItemUOMId = @intItemUOMId
						AND cb.intSubLocationId = @intSubLocationId 
						AND cb.intItemLocationId = @intItemLocationId 						
				ORDER BY cb.dtmCreated DESC

				IF @intStorageLocationId IS NULL
				BEGIN
					SELECT	@intStorageLocationId = intStorageLocationId 
					FROM	dbo.tblICInventoryLot 
					WHERE	intInventoryLotId = @intInventoryLotId
				END

				IF @dblCost IS NULL
				BEGIN
					SELECT	@dblCost = dblLastCost 
					FROM	dbo.tblICInventoryLot cb INNER JOIN dbo.tblICLot Lot 
								ON Lot.intLotId = cb.intLotId
					WHERE	cb.intInventoryLotId = @intInventoryLotId
				END

				GOTO _AdjustQuantity
			END

			ELSE IF @dblAdjustQtyBy < 0
			BEGIN
				SET @temp_RemainingQty = ABS(@dblAdjustQtyBy)

				WHILE @temp_RemainingQty > 0
				BEGIN
					SELECT TOP 1 
							@strLotNumber = Lot.strLotNumber 
							,@intInventoryLotId = ICLot.intInventoryLotId
							,@tempEachLotQty = ISNULL(ICLot.dblStockIn, 0) - ISNULL(ICLot.dblStockOut, 0)
					FROM	dbo.tblICInventoryLot ICLot INNER JOIN dbo.tblICLot Lot 
								ON Lot.intLotId = ICLot.intLotId
					WHERE	ICLot.intItemId = @intItemId 
							AND ICLot.intItemUOMId = @intItemUOMId 
							AND ICLot.intSubLocationId = @intSubLocationId 
							AND ICLot.intItemLocationId = @intItemLocationId 							
							AND (ISNULL(ICLot.dblStockIn, 0) - ISNULL(ICLot.dblStockOut, 0)) > 0
					ORDER BY ICLot.dtmCreated ASC

					IF @intStorageLocationId IS NULL
					 	BEGIN
							SELECT @intStorageLocationId = intStorageLocationId 
							FROM dbo.tblICInventoryLot 
							WHERE intInventoryLotId = @intInventoryLotId
						END

					IF @dblCost IS NULL
						BEGIN
							SELECT @dblCost = dblLastCost 
							FROM dbo.tblICInventoryLot ICLot INNER JOIN dbo.tblICLot Lot ON Lot.intLotId = ICLot.intLotId
							WHERE intInventoryLotId = @intInventoryLotId
						END

					IF @temp_RemainingQty > @tempEachLotQty
					BEGIN
						SET @tempAdjustQtyBy = -(@tempEachLotQty)
											
						EXEC dbo.uspICInventoryAdjustment_CreatePostQtyChangeFromSAP
						-- Parameters for filtering:
						@intItemId = @intItemId
						,@dtmDate = @dtmQtyChange
						,@intLocationId = @intLocationId
						,@intSubLocationId = @intSubLocationId	
						,@intStorageLocationId = @intStorageLocationId
						,@strLotNumber = @strLotNumber	
						-- Parameters for the new values: 
						,@dblAdjustByQuantity = @tempAdjustQtyBy
						,@dblNewUnitCost = @dblCost
						,@intItemUOMId = @intItemUOMId
						-- Parameters used for linking or FK (foreign key) relationships
						,@intSourceId = @intSourceId
						,@intSourceTransactionTypeId = 41 --SAP stock integration
						,@intEntityUserSecurityId = @intEntityUserId
						,@intInventoryAdjustmentId = @intInventoryAdjustmentId

						SET @temp_RemainingQty = @temp_RemainingQty - @tempEachLotQty
						SET @intStorageLocationId = NULL
						SET @dblCost = NULL
					END

					ELSE
					BEGIN
						SET @tempAdjustQtyBy = -(@temp_RemainingQty)

						EXEC dbo.uspICInventoryAdjustment_CreatePostQtyChangeFromSAP
						-- Parameters for filtering:
						@intItemId = @intItemId
						,@dtmDate = @dtmQtyChange
						,@intLocationId = @intLocationId
						,@intSubLocationId = @intSubLocationId	
						,@intStorageLocationId = @intStorageLocationId
						,@strLotNumber = @strLotNumber	
						-- Parameters for the new values: 
						,@dblAdjustByQuantity = @tempAdjustQtyBy
						,@dblNewUnitCost = @dblCost
						,@intItemUOMId = @intItemUOMId
						-- Parameters used for linking or FK (foreign key) relationships
						,@intSourceId = @intSourceId
						,@intSourceTransactionTypeId = 41 --SAP stock integration
						,@intEntityUserSecurityId = @intEntityUserId
						,@intInventoryAdjustmentId = @intInventoryAdjustmentId

						GOTO _Exit
					END
				END
			END
		END
	END	 
END
	
-- Create Quantity Change Adjustment then post
_AdjustQuantity:
BEGIN	
	EXEC dbo.uspICInventoryAdjustment_CreatePostQtyChangeFromSAP
	-- Parameters for filtering:
	@intItemId = @intItemId
	,@dtmDate = @dtmQtyChange
	,@intLocationId = @intLocationId
	,@intSubLocationId = @intSubLocationId	
	,@intStorageLocationId = @intStorageLocationId
	,@strLotNumber = @strLotNumber	
	-- Parameters for the new values: 
	,@dblAdjustByQuantity = @dblAdjustQtyBy
	,@dblNewUnitCost = @dblCost
	,@intItemUOMId = @intItemUOMId
	-- Parameters used for linking or FK (foreign key) relationships
	,@intSourceId = @intSourceId
	,@intSourceTransactionTypeId = 41 --SAP stock integration
	,@intEntityUserSecurityId = @intEntityUserId
	,@intInventoryAdjustmentId = @intInventoryAdjustmentId
END

_Exit: