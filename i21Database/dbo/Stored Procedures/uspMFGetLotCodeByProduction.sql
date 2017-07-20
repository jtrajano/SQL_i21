CREATE PROCEDURE uspMFGetLotCodeByProduction
AS
	
DECLARE @tblMFMultipleLotCode TABLE (
	strLotNumber NVARCHAR(50)COLLATE Latin1_General_CI_AS
	,dblLotQty NUMERIC(24, 10)
	,strParentLotNumber NVARCHAR(50)COLLATE Latin1_General_CI_AS
	,dblWOQty NUMERIC(24, 10)
	,dblWOTotalQty NUMERIC(24, 10)
	)
INSERT INTO @tblMFMultipleLotCode (
	strLotNumber
	,dblLotQty
	,strParentLotNumber
	,dblWOQty
	,dblWOTotalQty
	)
SELECT *
FROM (
	SELECT L.strLotNumber
		,L.dblQty
		,WP1.strParentLotNumber
		,WP1.dblPhysicalCount
		,SUM(WP1.dblPhysicalCount) OVER (PARTITION BY WP1.strLotNumber) dblTotalPhysicalCount
	FROM tblICLot L
	JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	LEFT JOIN (
		SELECT L1.strLotNumber
			,WP.dblPhysicalCount
			,WP.strParentLotNumber
			,WP.intWorkOrderId
		FROM tblICLot L1
		JOIN tblMFWorkOrderProducedLot WP ON WP.intLotId = L1.intLotId
			AND WP.ysnProductionReversed = 0
		) WP1 ON WP1.strLotNumber = L.strLotNumber
	WHERE L.dblQty > 0
		AND PL.strParentLotNumber LIKE '%/%'
	) AS DT
WHERE ROUND(dblQty, 0) = Round(dblTotalPhysicalCount, 0)

DECLARE @tblMFMultipleLotCodeO1 TABLE (
	strLotNumber NVARCHAR(50)COLLATE Latin1_General_CI_AS
	,intStorageLocationId int
	,dblLotQty NUMERIC(24, 10)
	,strParentLotNumber NVARCHAR(50)COLLATE Latin1_General_CI_AS
	,dblWOQty NUMERIC(24, 10)
	,dblWOTotalQty NUMERIC(24, 10)
	)

INSERT INTO @tblMFMultipleLotCodeO1 (
	strLotNumber
	,intStorageLocationId
	,dblLotQty
	,strParentLotNumber
	,dblWOQty
	,dblWOTotalQty
	)
SELECT *
FROM (
	SELECT L.strLotNumber
		,L.intStorageLocationId
		,L.dblQty
		,WP1.strParentLotNumber
		,WP1.dblPhysicalCount
		,SUM(WP1.dblPhysicalCount) OVER (PARTITION BY WP1.strLotNumber) dblTotalPhysicalCount
	FROM tblICLot L
	JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	LEFT JOIN (
		SELECT L1.strLotNumber
			,WP.dblPhysicalCount
			,WP.strParentLotNumber
			,WP.intWorkOrderId
		FROM tblICLot L1
		JOIN tblMFWorkOrderProducedLot WP ON WP.intLotId = L1.intLotId
			AND WP.ysnProductionReversed = 0
		) WP1 ON WP1.strLotNumber = L.strLotNumber
	WHERE L.dblQty > 0
		AND PL.strParentLotNumber LIKE '%/%'
	) AS DT
WHERE ROUND(dblQty, 0) <> Round(dblTotalPhysicalCount, 0)

DECLARE @tblMFMultipleLotCodeO2 TABLE (
	intRecordId INT Identity(1, 1)
	,strLotNumber NVARCHAR(50)COLLATE Latin1_General_CI_AS
	,intStorageLocationId INT
	,dblLotQty NUMERIC(24, 10)
	)
DECLARE @strLotNumber NVARCHAR(50)
	,@intStorageLocationId INT
	,@dblLotQty NUMERIC(24, 10)
	,@dblWOQty NUMERIC(24, 10)
	,@strParentLotNumber NVARCHAR(50)
	,@intRecordId INT

INSERT INTO @tblMFMultipleLotCodeO2
SELECT DISTINCT strLotNumber
	,intStorageLocationId
	,dblLotQty
FROM @tblMFMultipleLotCodeO1

SELECT @intRecordId = Min(intRecordId)
FROM @tblMFMultipleLotCodeO2

WHILE @intRecordId IS NOT NULL
BEGIN
	SELECT @strLotNumber = NULL
		,@intStorageLocationId = NULL
		,@dblLotQty = NULL

	SELECT @dblWOQty = NULL
		,@strParentLotNumber = NULL

	SELECT @strLotNumber = strLotNumber
		,@intStorageLocationId = intStorageLocationId
		,@dblLotQty = dblLotQty
	FROM @tblMFMultipleLotCodeO2
	WHERE intRecordId = @intRecordId

	SELECT @dblWOQty = dblWOQty
		,@strParentLotNumber = strParentLotNumber
	FROM @tblMFMultipleLotCodeO1
	WHERE strLotNumber = @strLotNumber
		AND intStorageLocationId = @intStorageLocationId
		AND dblWOQty = @dblLotQty

	IF @strParentLotNumber IS NULL
	BEGIN
		SELECT @dblWOQty = dblWOQty
			,@strParentLotNumber = strParentLotNumber
		FROM @tblMFMultipleLotCodeO1
		WHERE strLotNumber = @strLotNumber
			AND intStorageLocationId = @intStorageLocationId
			AND dblWOQty > @dblLotQty
	END

	IF @strParentLotNumber IS NOT NULL
	BEGIN
		INSERT INTO @tblMFMultipleLotCode (
			strLotNumber
			,dblLotQty
			,strParentLotNumber
			,dblWOQty
			,dblWOTotalQty
			)
		SELECT @strLotNumber
			,@dblLotQty
			,@strParentLotNumber
			,@dblWOQty
			,@dblWOQty

		DELETE
		FROM @tblMFMultipleLotCodeO1
		WHERE strLotNumber = @strLotNumber
			AND strParentLotNumber = @strParentLotNumber
			AND dblWOQty = @dblLotQty
	END

	SELECT @intRecordId = Min(intRecordId)
	FROM @tblMFMultipleLotCodeO2
	WHERE intRecordId > @intRecordId
END

Select *from @tblMFMultipleLotCode