CREATE PROCEDURE uspMFValidateWarehouseReleaseByParentLot (
	@strParentLotNumber NVARCHAR(50)
	,@intLocationId INT
	)
AS
BEGIN TRY
	DECLARE @intRecordId INT
		,@strLotNumber NVARCHAR(50)
		,@ErrMsg NVARCHAR(MAX)
		,@intLotId INT
		,@intParentLotId INT
		,@intManufacturingProcessId INT
		,@intAttributeId INT
		,@strAttributeValue NVARCHAR(50)
		,@intItemId int

	DECLARE @tblMFParentLot TABLE (
		intRecordId INT identity(1, 1)
		,strLotNumber NVARCHAR(50)
		)

	SELECT @intLotId = intLotId,
			@intItemId=intItemId
	FROM dbo.tblICLot
	WHERE strLotNumber = @strParentLotNumber
		AND intLocationId = @intLocationId
		AND dblQty>0

	IF @intLotId IS NULL
	BEGIN
		SELECT @intParentLotId = intParentLotId,@intItemId=intItemId
		FROM dbo.tblICParentLot
		WHERE strParentLotNumber = @strParentLotNumber

		SELECT @intLotId = intLotId,@intItemId=intItemId
		FROM dbo.tblICLot
		WHERE intParentLotId = @intParentLotId
			AND intLocationId = @intLocationId
			AND dblQty>0
	END

	SELECT @intManufacturingProcessId =intManufacturingProcessId
	FROM tblMFRecipe 
	WHERE intItemId=@intItemId 
	AND intLocationId=@intLocationId 
	AND ysnActive =1

	SELECT @intAttributeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Warehouse Release Lot By Batch'

	SELECT @strAttributeValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intAttributeId

	IF @strAttributeValue = 'True'
	BEGIN
		INSERT INTO @tblMFParentLot (strLotNumber)
		SELECT L.strLotNumber
		FROM dbo.tblICLot L
		JOIN dbo.tblICParentLot PL ON L.intParentLotId = PL.intParentLotId
		WHERE PL.strParentLotNumber = @strParentLotNumber
			AND L.intLotStatusId = 3
			AND L.dblQty>0 
	END
	ELSE
	BEGIN
		INSERT INTO @tblMFParentLot (strLotNumber)
		SELECT L.strLotNumber
		FROM dbo.tblICLot L
		WHERE L.strLotNumber = @strParentLotNumber
			AND L.intLotStatusId = 3
			AND L.dblQty>0 
	END

	IF NOT EXISTS (
			SELECT *
			FROM @tblMFParentLot
			)
	BEGIN
		EXEC uspICRaiseError 80020; 
		RETURN
	END

	SELECT @intRecordId = MIN(intRecordId)
	FROM @tblMFParentLot

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @strLotNumber = NULL

		SELECT @strLotNumber = strLotNumber
		FROM @tblMFParentLot
		WHERE intRecordId = @intRecordId

		EXEC uspMFValidateWarehouseReleaseLot @strLotNumber = @strLotNumber
			,@intLocationId = @intLocationId

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFParentLot
		WHERE intRecordId > @intRecordId
	END

	IF @strAttributeValue = 'True'
	BEGIN
		SELECT ISNULL(W.intWorkOrderId,0) AS intWorkOrderId
			,ISNULL(W.strWorkOrderNo,'') AS strWorkOrderNo
			,L.intLocationId
			,L.intParentLotId
			,PL.strParentLotNumber
			,0 AS intLotId
			,'' AS strLotNumber
			,I.strItemNo
			,I.strDescription
			,SUM(L.dblQty) dblQty
			,IU.intItemUOMId
			,U.strUnitMeasure
			,U.intUnitMeasureId
			,R.intManufacturingProcessId
			,@strAttributeValue AS strWarehouseReleaseLotByBatch
		FROM tblICLot L
		JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
		JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
		JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
		JOIN dbo.tblMFRecipe R ON R.intItemId=I.intItemId AND R.intLocationId=@intLocationId AND R.ysnActive =1
		LEFT JOIN dbo.tblMFWorkOrderProducedLot WPL ON WPL.intLotId = L.intLotId
		LEFT JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = WPL.intWorkOrderId
		WHERE PL.strParentLotNumber = @strParentLotNumber AND L.dblQty>0 
			AND L.intLotStatusId = 3
		GROUP BY W.intWorkOrderId
			,W.strWorkOrderNo
			,L.intLocationId
			,L.intParentLotId
			,PL.strParentLotNumber
			,I.strItemNo
			,I.strDescription
			,IU.intItemUOMId
			,U.strUnitMeasure
			,U.intUnitMeasureId
			,R.intManufacturingProcessId
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
