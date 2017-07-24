﻿CREATE PROCEDURE uspMFLotSnapshot
AS
DECLARE @dtmCurrentDate DATETIME
	,@intLotSnapshotId INT

SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, GETDATE(), 101))

IF NOT EXISTS (
		SELECT *
		FROM tblGLFiscalYearPeriod
		WHERE dtmStartDate = @dtmCurrentDate
		)
BEGIN
	RETURN
END

INSERT INTO tblMFLotSnapshot
SELECT @dtmCurrentDate

SET @intLotSnapshotId = SCOPE_IDENTITY()

INSERT INTO tblMFLotSnapshotDetail (
	intLotSnapshotId
	,intLotId
	,intItemId
	,intLocationId
	,intItemUOMId
	,intSubLocationId
	,intStorageLocationId
	,dblQty
	,intLotStatusId
	,intParentLotId
	,dblWeight
	,intWeightUOMId
	,dblWeightPerQty
	,intBondStatusId
	)
SELECT @intLotSnapshotId
	,L.intLotId
	,L.intItemId
	,L.intLocationId
	,L.intItemUOMId
	,L.intSubLocationId
	,L.intStorageLocationId
	,L.dblQty
	,L.intLotStatusId
	,L.intParentLotId
	,L.dblWeight
	,L.intWeightUOMId
	,L.dblWeightPerQty
	,LI.intBondStatusId
FROM tblICLot L
JOIN tblMFLotInventory LI ON LI.intLotId = L.intLotId
WHERE dblQty > 0