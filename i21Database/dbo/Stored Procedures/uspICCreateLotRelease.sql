CREATE PROCEDURE [dbo].[uspICCreateLotRelease]
	@LotsToRelease AS LotReleaseTableType READONLY
	,@intTransactionId AS INT
	,@intTransactionTypeId AS INT
	,@intUserId AS INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @ClearReleased AS LotReleaseTableType
DECLARE @LotsToReleaseAggregrate AS LotReleaseTableType
		,@intReturn AS INT = 0 

INSERT INTO @LotsToReleaseAggregrate (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intLotId
		,dblQty
		,intTransactionId
		,strTransactionId
		,intTransactionTypeId
		,intSubLocationId
		,intStorageLocationId
		,dtmDate
)
SELECT	r.intItemId
		,r.intItemLocationId
		,r.intItemUOMId
		,r.intLotId
		,SUM(r.dblQty)
		,r.intTransactionId
		,r.strTransactionId
		,r.intTransactionTypeId
		,r.intSubLocationId
		,r.intStorageLocationId	
		,r.dtmDate
FROM	@LotsToRelease r INNER JOIN tblICLot l
			ON r.intLotId = l.intLotId
		LEFT JOIN tblICWarrantStatus s
			ON s.intWarrantStatus = l.intWarrantStatus
WHERE
		s.strWarrantStatus IN ('Partially Released', 'Released')
		AND l.strCondition NOT IN ('Missing', 'Swept', 'Skimmed')
GROUP  BY 
	r.intItemId
	, r.intItemLocationId
	, r.intItemUOMId
	, r.intLotId
	, r.intTransactionId
	, r.strTransactionId
	, r.intTransactionTypeId
	, r.intSubLocationId
	, r.intStorageLocationId
	, r.dtmDate
HAVING 
	SUM(r.dblQty) > 0 

---- Clear the existing released records. 
--IF EXISTS (
--	SELECT TOP 1 1 
--	FROM	dbo.tblICLotReleased LotsReleased 
--	WHERE	intTransactionId = @intTransactionId
--			AND intInventoryTransactionType = @intTransactionTypeId	
--)
BEGIN 
	INSERT INTO @ClearReleased (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,dblQty
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
			,intSubLocationId
			,intStorageLocationId	
			,dtmDate
	)
	SELECT 
			LotsReleased.intItemId
			,LotsReleased.intItemLocationId
			,LotsReleased.intItemUOMId
			,LotsReleased.intLotId
			,-LotsReleased.dblQty -- Negate the qty to reduce the released qty. 
			,LotsReleased.intTransactionId
			,LotsReleased.strTransactionId
			,LotsReleased.intInventoryTransactionType
			,LotsReleased.intSubLocationId
			,LotsReleased.intStorageLocationId
			,LotsReleased.dtmDate
	FROM	dbo.tblICLotReleased LotsReleased 
			CROSS APPLY (
				SELECT DISTINCT 
					LotsToRelease.intLotId
				FROM 
					@LotsToRelease LotsToRelease
				WHERE
					LotsReleased.intLotId = LotsToRelease.intLotId
			) LotsToRelease

	-- Call this SP to decrease the released qty. 
	EXEC @intReturn = dbo.uspICIncreaseReleasedLot 
		@ClearReleased

	IF @intReturn <> 0
		RETURN @intReturn
		
	-- Clear the list (if it exists)
	DELETE	LotsReleased
	FROM	dbo.tblICLotReleased LotsReleased 
	WHERE	intTransactionId = @intTransactionId
			AND intInventoryTransactionType = @intTransactionTypeId

END 

-- Add new Lots Released
INSERT INTO dbo.tblICLotReleased (
		intItemId
		,intLocationId
		,intItemLocationId
		,intItemUOMId
		,intLotId
		,dblQty
		,intTransactionId
		,strTransactionId
		,intSort
		,intInventoryTransactionType
		,intSubLocationId
		,intStorageLocationId
		,intConcurrencyId
		,dtmDate
		,dtmDateCreated
		,intCreatedByUserId
)
SELECT	intItemId						= Items.intItemId
		,intLocationId					= ItemLocation.intLocationId
		,intItemLocationId				= Items.intItemLocationId
		,intItemUOMId					= Items.intItemUOMId
		,intLotId						= Items.intLotId
		,dblQty							= Items.dblQty
		,intTransactionId				= Items.intTransactionId
		,strTransactionId				= Items.strTransactionId
		,intSort						= Items.intId
		,intInventoryTransactionType	= Items.intTransactionTypeId
		,intSubLocationId				= Items.intSubLocationId
		,intStorageLocationId			= Items.intStorageLocationId
		,intConcurrencyId				= 1
		,dtmDate
		,dtmDateCreated					= GETDATE()
		,intCreatedByUserId				= @intUserId
FROM	@LotsToReleaseAggregrate Items 
		INNER JOIN tblICLot Lot
			ON Lot.intItemId = Items.intItemId
			AND Lot.intLotId = Items.intLotId		
		INNER JOIN dbo.tblICItemLocation ItemLocation
			ON Items.intItemLocationId = ItemLocation.intItemLocationId
			AND Items.intItemId = ItemLocation.intItemId
WHERE
	Items.dblQty > 0 

-- Call this SP to increase the released qty. 
IF EXISTS (SELECT TOP 1 1 FROM @LotsToReleaseAggregrate)
BEGIN
	EXEC @intReturn = dbo.uspICIncreaseReleasedLot
		@LotsToReleaseAggregrate

	IF @intReturn <> 0 RETURN @intReturn
END 


RETURN 0;