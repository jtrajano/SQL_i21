CREATE PROCEDURE [dbo].[uspICAdjustStockFromSAP]
	@dtmQtyChange			DATETIME				-- Date of quantity change (if not specified, it will default to current system date)
	,@intItemId				INT						-- Id of item to adjust
	,@strLotNumber			NVARCHAR(50) = NULL		-- Lot Number of the item to adjust (required for lot tracked items; Can be flagged as '[FIFO]' if exact lot number can't be specified. The system will reduce the lot in FIFO order.)
	,@intLocationId			INT						-- Location Id of the item
	,@intSubLocationId		INT						-- Sub Location of the item
	,@intStorageLocationId	INT = NULL				-- Storage Location of the item
	,@intItemUOMId			INT = NULL				-- Unit of Measure Id of the item (if not specified, system will get the item's stock UOM id)
	,@dblNewQty				NUMERIC(38, 20)	        -- New Quantity for the item
	,@dblCost				NUMERIC(38, 20) = NULL	-- Cost of the item (required if increasing stock; if missing, the system will use the item's last cost to increase the stock)
	,@intEntityUserId		INT = NULL				-- Entity User Id
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE
	@intLotId AS INT
	,@strItemNo AS NVARCHAR(50)

BEGIN
	-------------------------------------  
	-- Validation for Mandatory Fields -- 
	------------------------------------- 
	IF @intItemId IS NULL
		BEGIN 
			-- Item id is invalid or missing.
			RAISERROR(80001, 11,1);
			GOTO _Exit;
		END
	------------------------- 
	-- SET Required Values --
	-------------------------
	-- Set Transaction Date
	SET @dtmQtyChange = ISNULL(@dtmQtyChange, GETDATE());

	-- Set UOM Id
	SET @intItemUOMId = ISNULL(@intItemUOMId, dbo.fnGetItemStockUOM(@intItemId));
 
	---------------------------------------------
	-- Validate values specified in the fields --
	---------------------------------------------

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

	-- Check the lot number if it is lot-tracked. Validate the lot number. 
	IF dbo.fnGetItemLotType(@intItemId) IN (1, 2)
	BEGIN
		IF @strLotNumber IS NOT NULL OR @strLotNumber != '[FIFO]'
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

	-- Set value for @strItemNo
	SELECT @strItemNo = strItemNo
	FROM tblICItem 
	WHERE intItemId = @intItemId

	-- Validate Item Location
	IF NOT EXISTS (SELECT 1 FROM dbo.tblICItemLocation WHERE intItemLocationId = @intLocationId AND intItemId = @intItemId)
	BEGIN
		-- Item Location is invalid or missing for {item}
		RAISERROR(80002, 11, 1, @strItemNo);
		GOTO _Exit;
	END

	-- Validate Sub Location
	IF @intSubLocationId IS NOT NULL
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationSubLocationId = @intSubLocationId AND intCompanyLocationId = @intLocationId)
			BEGIN
				-- Sub Location is invalid for item {item}.
				RAISERROR(80097, 11, 1, @strItemNo);
				GOTO _Exit;
			END
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
END

_Exit: