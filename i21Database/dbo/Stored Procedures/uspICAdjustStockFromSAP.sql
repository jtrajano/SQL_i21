﻿CREATE PROCEDURE [dbo].[uspICAdjustStockFromSAP]
	@dtmQtyChange			DATETIME				-- Date of quantity change (if not specified, it will default to current system date)
	,@intItemId				INT						-- Id of item to adjust
	,@strLotNumber			NVARCHAR(50) 			-- Lot Number of the item to adjust (required for lot tracked items; Can be flagged as '[FIFO]' if exact lot number can't be specified. The system will reduce the lot in FIFO order.)
	,@intLocationId			INT						-- Location Id of the item
	,@intSubLocationId		INT						-- Sub Location of the item
	,@intStorageLocationId	INT 					-- Storage Location of the item
	,@intItemUOMId			INT 					-- Unit of Measure Id of the item (if not specified, system will get the item's stock UOM id)
	,@dblNewQty				NUMERIC(38, 20)	        -- New Quantity for the item
	,@dblCost				NUMERIC(38, 20) 		-- Cost of the item (required if increasing stock; if missing, the system will use the item's last cost to increase the stock)
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
	,@dblAdjustQtyBy AS NUMERIC(38, 20)
	,@intItemLocationId AS INT
	,@tempQty AS NUMERIC(38,20)
	,@tempNextQty AS NUMERIC(38,20)
	,@tempEachLotQty AS NUMERIC(38,20)
	,@tempAdjustQtyBy AS NUMERIC(38,20)
	,@intInventoryAdjustmentId AS INT

BEGIN

	---------------- 
	-- SET Values --
	----------------
	-- Set Transaction Date
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
	IF NOT EXISTS (SELECT 1 FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationSubLocationId = @intSubLocationId AND intCompanyLocationId = @intLocationId)
		BEGIN
			-- Sub Location is invalid or missing for item {item}.
			RAISERROR(80097, 11, 1, @strItemNo);
			GOTO _Exit;
		END

	-- Validate Storage Location if specified
	IF @intStorageLocationId IS NOT NULL
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM tblICStorageLocation WHERE intLocationId = @intLocationId AND intSubLocationId = @intSubLocationId AND intStorageLocationId = @intStorageLocationId)
				BEGIN
					-- Storage Location is invalid for item {item}
					RAISERROR(80098, 11, 1, @strItemNo);
					GOTO _Exit;
				END
		END

	-- Check the lot number if it is lot-tracked. Validate the lot number. 
	IF dbo.fnGetItemLotType(@intItemId) IN (1, 2)
	BEGIN
		IF @strLotNumber IS NOT NULL OR @strLotNumber != '[FIFO]' OR @strLotNumber != 'FIFO'
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

	--------------------------------------
	-- Transaction: Quantity Adjustment -- 
	--------------------------------------
	 
	-- Get the value to Adjust
	 SELECT @dblAdjustQtyBy = -(ISNULL(SUM(dblOnHand),0) - @dblNewQty)
	 FROM dbo.tblICItemStockUOM
	 WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId AND intSubLocationId = @intSubLocationId AND intItemUOMId = @intItemUOMId

	 -- Check if item is Lot-Tracked or not
	 IF EXISTS(SELECT * FROM tblICItem WHERE intItemId = @intItemId AND strLotTracking='No')
		BEGIN
			-- Process Non-Lot-tracked items
			IF @dblAdjustQtyBy = 0 GOTO _Exit

			ELSE 
				BEGIN
				 IF @intStorageLocationId IS NULL
					 BEGIN
						SET @intStorageLocationId = 
						(SELECT TOP 1 intStorageLocationId
						 FROM dbo.tblICItemLocation
						 WHERE intItemId = @intItemId AND intSubLocationId = @intSubLocationId AND intItemLocationId = @intItemLocationId
						)
					END
					-- Create Quantity Change Adjustment then post
					EXEC dbo.uspICInventoryAdjustment_CreatePostQtyChange
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
		END

	ELSE
		BEGIN
			-- Process Lot-tracked items
			-- Get Lot Number
			IF @strLotNumber IS NULL OR @strLotNumber = '[FIFO]' OR @strLotNumber = 'FIFO'
				BEGIN
					IF @dblAdjustQtyBy > 0
						BEGIN
							IF @strLotNumber IS NULL
								BEGIN
									SET @strLotNumber =
									(SELECT TOP 1 strLotNumber
									 FROM dbo.tblICLot
									 WHERE intItemId = @intItemId AND intSubLocationId = @intSubLocationId AND intItemLocationId = @intItemLocationId AND intItemUOMId = @intItemUOMId
									 ORDER BY dtmDateCreated DESC)
								END

							 IF @intStorageLocationId IS NULL
					 			BEGIN
									SET @intStorageLocationId = 
									(SELECT TOP 1 intStorageLocationId
									 FROM dbo.tblICLot
									 WHERE intItemId = @intItemId AND intSubLocationId = @intSubLocationId AND intItemLocationId = @intItemLocationId AND intItemUOMId = @intItemUOMId AND strLotNumber = @strLotNumber
									 ORDER BY dtmDateCreated DESC)
								END

							IF @dblCost IS NULL
								BEGIN
									SET @dblCost = 
									(SELECT TOP 1 dblLastCost
									 FROM dbo.tblICLot
									 WHERE intItemId = @intItemId AND intSubLocationId = @intSubLocationId AND intItemLocationId = @intItemLocationId AND intItemUOMId = @intItemUOMId AND strLotNumber = @strLotNumber AND intStorageLocationId = @intStorageLocationId
									 ORDER BY dtmDateCreated DESC)
								END

							 -- Create Quantity Change Adjustment then post
							 EXEC dbo.uspICInventoryAdjustment_CreatePostQtyChange
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

					 ELSE IF @dblAdjustQtyBy = 0 GOTO _Exit

					 ELSE IF @dblAdjustQtyBy < 0
						BEGIN
							SET @tempQty = ABS(@dblAdjustQtyBy)

							WHILE @tempQty > 0
								BEGIN
									SELECT TOP 1 @tempEachLotQty = dblQty
										 FROM dbo.tblICLot
										 WHERE intItemId = @intItemId AND intSubLocationId = @intSubLocationId AND intItemLocationId = @intItemLocationId AND intItemUOMId = @intItemUOMId
												AND dblQty > 0
										 ORDER BY dtmDateCreated ASC

									SET @tempNextQty = @tempQty - @tempEachLotQty

									IF @strLotNumber IS NULL OR 
									   (@strLotNumber IS NOT NULL AND (SELECT SUM(dblQty) FROM dbo.tblICLot
										WHERE intItemId = @intItemId AND intSubLocationId = @intSubLocationId AND intItemLocationId = @intItemLocationId AND intItemUOMId = @intItemUOMId
											   AND strLotNumber = @strLotNumber) = 0)
										BEGIN
											SELECT TOP 1 @strLotNumber = strLotNumber
														,@intStorageLocationId = intStorageLocationId
														,@dblCost = dblLastCost
											 FROM dbo.tblICLot
											 WHERE intItemId = @intItemId AND intSubLocationId = @intSubLocationId AND intItemLocationId = @intItemLocationId AND intItemUOMId = @intItemUOMId
												AND dblQty > 0
											 ORDER BY dtmDateCreated ASC
										END

									ELSE
								

									IF @tempNextQty >= 0 
										BEGIN
											SET @tempAdjustQtyBy = -(@tempEachLotQty)
											SET @tempQty = @tempNextQty
										END
									ELSE IF @tempNextQty < 0 
										BEGIN
											SET @tempAdjustQtyBy = -(@tempQty)
											SET @tempQty = 0
										END
								
									IF @tempAdjustQtyBy != 0
										BEGIN
											 -- Create Quantity Change Adjustment then post
											 EXEC dbo.uspICInventoryAdjustment_CreatePostQtyChange
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
										END

								END
						END
				END
		END	 
END

_Exit: