/**
* If a lot is moved within the same location, this function will be able to retrieve the new lot id. 
*
* For Example: 
*
*	Below is how the lot looks like before the Lot Move. 
*	----------------------------------------------------------------------------
*	Lot Id	Lot Number	     Qty	Location	Sub Location	Storage Location
*	------	----------	--------	--------	------------	----------------
*	1		ABC-123			  10	MAIN		NULL			NULL 
*
*	When the lot is moved into a new storage location, it will create a new lot record. 
*	----------------------------------------------------------------------------
*	Lot Id	Lot Number	     Qty	Location	Sub Location	Storage Location
*	------	----------	--------	--------	------------	----------------
*	1		ABC-123			   0	MAIN		NULL			NULL 
*	2		ABC-123			  10	MAIN		NULL			BARN
* 
* This function will retrieve the lot with Lot id 2 because it shares the same Location and qty is non zero. 
* 
* Sample usage: 
*
*	SELECT	B.*
*	FROM	tblICLot A 
*			CROSS APPLY dbo.fnTrackMovedLots (
*				A.intLotId 
*			) B
* 
*/
CREATE FUNCTION fnTrackMovedLots (
	@intLotId AS INT
)
RETURNS TABLE 
AS
RETURN (
	WITH TrackMovedLots AS (
		SELECT	intLotId
				, strLotNumber			
				, intItemId
				, intItemLocationId 
				, intSubLocationId
				, intStorageLocationId
				, Lot.dblQty
				, 1 AS LotLevel
		FROM	tblICLot Lot
		WHERE	Lot.intLotId = @intLotId

		UNION ALL 

		SELECT	MovedLot.intLotId
				, MovedLot.strLotNumber
				, MovedLot.intItemId
				, MovedLot.intItemLocationId
				, MovedLot.intSubLocationId
				, MovedLot.intStorageLocationId
				, MovedLot.dblQty
				, TrackMovedLots.LotLevel + 1
		FROM	tblICLot MovedLot INNER JOIN TrackMovedLots
					ON MovedLot.intSplitFromLotId = TrackMovedLots.intLotId
					AND MovedLot.intItemLocationId = TrackMovedLots.intItemLocationId
		WHERE	MovedLot.intSplitFromLotId IS NOT NULL 
	)
	SELECT	TOP 1 * 
	FROM	TrackMovedLots
	WHERE	dblQty > 0 
)