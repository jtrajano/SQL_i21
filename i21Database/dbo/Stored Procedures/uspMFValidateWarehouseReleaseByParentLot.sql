﻿CREATE PROCEDURE uspMFValidateWarehouseReleaseByParentLot (
	@strParentLotNumber NVARCHAR(50)
	,@intLocationId INT
	)
AS
BEGIN TRY
	DECLARE @intRecordId INT
		,@strLotNumber NVARCHAR(50)
		,@ErrMsg NVARCHAR(MAX)
	DECLARE @tblMFParentLot TABLE (
		intRecordId INT identity(1, 1)
		,strLotNumber NVARCHAR(50)
		)

	INSERT INTO @tblMFParentLot (strLotNumber)
	SELECT L.strLotNumber
	FROM dbo.tblICLot L
	JOIN dbo.tblICParentLot PL ON L.intParentLotId = PL.intParentLotId
	WHERE PL.strParentLotNumber = @strParentLotNumber
		AND L.intLotStatusId = 3

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

	SELECT W.intWorkOrderId
		,W.strWorkOrderNo
		,L.intLocationId
		,L.intParentLotId
		,PL.strParentLotNumber
		,I.strItemNo
		,I.strDescription
		,SUM(L.dblQty) dblQty
		,IU.intItemUOMId
		,U.strUnitMeasure
		,U.intUnitMeasureId
		,W.intManufacturingProcessId
	FROM tblICLot L
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN tblMFWorkOrderProducedLot WPL ON WPL.intLotId = L.intLotId
	JOIN tblMFWorkOrder W ON W.intWorkOrderId = WPL.intWorkOrderId
	JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	WHERE PL.strParentLotNumber = @strParentLotNumber
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
		,W.intManufacturingProcessId
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
