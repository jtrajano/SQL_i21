CREATE PROCEDURE uspMFGetLotCodeByProduction (@intLotSnapshotId INT)
AS
DECLARE @tblMFMultipleLotCode TABLE (
	intLotId INT
	,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblLotQty NUMERIC(24, 10)
	,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblWOQty NUMERIC(24, 10)
	,dblWOTotalQty NUMERIC(24, 10)
	)

INSERT INTO @tblMFMultipleLotCode (
	intLotId
	,strLotNumber
	,dblLotQty
	,strParentLotNumber
	,dblWOQty
	,dblWOTotalQty
	)
SELECT *
FROM (
	SELECT L.intLotId
		,L.strLotNumber
		,SD.dblQty
		,WP1.strParentLotNumber
		,WP1.dblPhysicalCount
		,SUM(WP1.dblPhysicalCount) OVER (PARTITION BY WP1.strLotNumber) dblTotalPhysicalCount
	FROM tblICLot L
	JOIN tblMFLotSnapshotDetail SD ON SD.intLotId = L.intLotId
		AND SD.intLotSnapshotId = @intLotSnapshotId
	JOIN tblICParentLot PL ON PL.intParentLotId = SD.intParentLotId
	LEFT JOIN (
		SELECT L1.strLotNumber
			,WP.dblPhysicalCount
			,WP.strParentLotNumber
			,WP.intWorkOrderId
		FROM tblICLot L1
		JOIN tblMFWorkOrderProducedLot WP ON WP.intLotId = L1.intLotId
			AND WP.ysnProductionReversed = 0
		) WP1 ON WP1.strLotNumber = L.strLotNumber
	WHERE SD.dblQty > 0
		AND PL.strParentLotNumber LIKE '%/%'
	) AS DT
WHERE ROUND(dblQty, 0) = Round(dblTotalPhysicalCount, 0)

DECLARE @tblMFMultipleLotCodeO1 TABLE (
	intLotId INT
	,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intStorageLocationId INT
	,dblLotQty NUMERIC(24, 10)
	,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblWOQty NUMERIC(24, 10)
	,dblWOTotalQty NUMERIC(24, 10)
	,intWorkOrderProducedLotId INT
	)

INSERT INTO @tblMFMultipleLotCodeO1 (
	intLotId
	,strLotNumber
	,intStorageLocationId
	,dblLotQty
	,strParentLotNumber
	,dblWOQty
	,dblWOTotalQty
	,intWorkOrderProducedLotId
	)
SELECT *
FROM (
	SELECT L.intLotId
		,L.strLotNumber
		,SD.intStorageLocationId
		,SD.dblQty
		,WP1.strParentLotNumber
		,WP1.dblPhysicalCount
		,SUM(WP1.dblPhysicalCount) OVER (PARTITION BY WP1.strLotNumber) dblTotalPhysicalCount
		,WP1.intWorkOrderProducedLotId
	FROM tblICLot L
	JOIN tblMFLotSnapshotDetail SD ON SD.intLotId = L.intLotId
		AND SD.intLotSnapshotId = @intLotSnapshotId
	JOIN tblICParentLot PL ON PL.intParentLotId = SD.intParentLotId
	LEFT JOIN (
		SELECT L1.strLotNumber
			,WP.dblPhysicalCount
			,WP.strParentLotNumber
			,WP.intWorkOrderId
			,WP.intWorkOrderProducedLotId
		FROM tblICLot L1
		JOIN tblMFWorkOrderProducedLot WP ON WP.intLotId = L1.intLotId
			AND WP.ysnProductionReversed = 0
		) WP1 ON WP1.strLotNumber = L.strLotNumber
	WHERE SD.dblQty > 0
		AND PL.strParentLotNumber LIKE '%/%'
	) AS DT
WHERE ROUND(dblQty, 0) <> Round(dblTotalPhysicalCount, 0)

DECLARE @tblMFMultipleLotCodeO2 TABLE (
	intRecordId INT Identity(1, 1)
	,intLotId INT
	,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intStorageLocationId INT
	,dblLotQty NUMERIC(24, 10)
	)
DECLARE @strLotNumber NVARCHAR(50)
	,@intStorageLocationId INT
	,@dblLotQty NUMERIC(24, 10)
	,@dblWOQty NUMERIC(24, 10)
	,@strParentLotNumber NVARCHAR(50)
	,@intRecordId INT
	,@intWorkOrderProducedLotId INT
	,@intLotId INT

INSERT INTO @tblMFMultipleLotCodeO2
SELECT DISTINCT intLotId
	,strLotNumber
	,intStorageLocationId
	,dblLotQty
FROM @tblMFMultipleLotCodeO1
Order by intLotId

SELECT @intRecordId = Min(intRecordId)
FROM @tblMFMultipleLotCodeO2

WHILE @intRecordId IS NOT NULL
BEGIN
	SELECT @strLotNumber = NULL
		,@intStorageLocationId = NULL
		,@dblLotQty = NULL
		,@intLotId = NULL

	SELECT @dblWOQty = NULL
		,@strParentLotNumber = NULL
		,@intWorkOrderProducedLotId = NULL

	SELECT @strLotNumber = strLotNumber
		,@intStorageLocationId = intStorageLocationId
		,@dblLotQty = dblLotQty
		,@intLotId = intLotId
	FROM @tblMFMultipleLotCodeO2
	WHERE intRecordId = @intRecordId

	X:

	SELECT TOP 1 @dblWOQty = dblWOQty
		,@strParentLotNumber = strParentLotNumber
		,@intWorkOrderProducedLotId = intWorkOrderProducedLotId
	FROM @tblMFMultipleLotCodeO1
	WHERE strLotNumber = @strLotNumber
		AND intStorageLocationId = @intStorageLocationId
	ORDER BY intWorkOrderProducedLotId

	IF @strParentLotNumber IS NOT NULL
	BEGIN
		IF @dblWOQty - @dblLotQty >= 0
		BEGIN
			INSERT INTO @tblMFMultipleLotCode (
				intLotId
				,strLotNumber
				,dblLotQty
				,strParentLotNumber
				,dblWOQty
				,dblWOTotalQty
				)
			SELECT @intLotId
				,@strLotNumber
				,@dblLotQty
				,@strParentLotNumber
				,@dblLotQty
				,@dblLotQty

			IF @dblWOQty - @dblLotQty = 0
			BEGIN
				DELETE
				FROM @tblMFMultipleLotCodeO1
				WHERE intWorkOrderProducedLotId = @intWorkOrderProducedLotId
			END
			ELSE
			BEGIN
				UPDATE @tblMFMultipleLotCodeO1
				SET dblWOQty = @dblWOQty - @dblLotQty
				WHERE intWorkOrderProducedLotId = @intWorkOrderProducedLotId
			END
		END
		ELSE
		BEGIN
			INSERT INTO @tblMFMultipleLotCode (
				intLotId
				,strLotNumber
				,dblLotQty
				,strParentLotNumber
				,dblWOQty
				,dblWOTotalQty
				)
			SELECT @intLotId
				,@strLotNumber
				,@dblLotQty
				,@strParentLotNumber
				,@dblWOQty
				,@dblWOQty

			DELETE
			FROM @tblMFMultipleLotCodeO1
			WHERE intWorkOrderProducedLotId = @intWorkOrderProducedLotId

			SELECT @dblLotQty = @dblLotQty - @dblWOQty

			GOTO X
		END
	END

	SELECT @intRecordId = Min(intRecordId)
	FROM @tblMFMultipleLotCodeO2
	WHERE intRecordId > @intRecordId
END

SELECT *
FROM @tblMFMultipleLotCode
