CREATE PROCEDURE uspMFLotSnapshot
AS
DECLARE @dtmCurrentDate DATETIME
	,@intLotSnapshotId INT
	,@ysnLotSnapshotByFiscalMonth BIT

SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, GETDATE(), 101))

SELECT @ysnLotSnapshotByFiscalMonth = ysnLotSnapshotByFiscalMonth
FROM tblMFCompanyPreference

IF @ysnLotSnapshotByFiscalMonth IS NULL
BEGIN
	SELECT @ysnLotSnapshotByFiscalMonth = 1
END

IF @ysnLotSnapshotByFiscalMonth = 1
	AND NOT EXISTS (
		SELECT *
		FROM tblGLFiscalYearPeriod
		WHERE dtmStartDate = @dtmCurrentDate
		)
BEGIN
	RETURN
END

INSERT INTO tblMFLotSnapshot(dtmDate)
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
