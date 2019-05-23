CREATE PROCEDURE [dbo].[uspMFUpdateBlendProduction] @intWorkOrderId INT
	,@intStatusId INT
	,@dtmDueDate DATETIME
	,@intExecutionOrder INT
	,@intStorageLocationId INT
	,@intManufacturingCellId INT
	,@strComment NVARCHAR(Max)
	,@intUserId INT
	,@strReferenceNo nvarchar(50)=NULL
	,@strLotAlias nvarchar(50)=NULL
	,@strVesselNo nvarchar(50)=NULL
	,@dblActualQuantity Numeric(18,6)=NULL
	,@dblNoOfUnits Numeric(18,6)=NULL
	,@intNoOfUnitsItemUOMId int=NULL
	,@dtmPlannedDate Datetime=NULL
AS
DECLARE @intCurrentExecutionOrder INT
DECLARE @dtmCurrentDueDate DATETIME
DECLARE @intCurrentManufacturingCellId INT

IF @intStorageLocationId = 0
	SET @intStorageLocationId = NULL

IF @intStatusId = 9
BEGIN
	DECLARE @tblWO AS TABLE (
		intWOId INT
		,intExecNo INT
		)

	SELECT @dtmCurrentDueDate = dtmExpectedDate
		,@intCurrentExecutionOrder = intExecutionOrder
		,@intCurrentManufacturingCellId = intManufacturingCellId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF ISNULL(@intManufacturingCellId, 0) = 0
		SET @intManufacturingCellId = @intCurrentManufacturingCellId

	IF @intCurrentManufacturingCellId <> @intManufacturingCellId
	BEGIN
		SELECT @intExecutionOrder = ISNULL(Max(intExecutionOrder), 0) + 1
		FROM tblMFWorkOrder
		WHERE Convert(DATE, dtmExpectedDate) = convert(DATE, @dtmDueDate)
			AND intManufacturingCellId = @intManufacturingCellId

		INSERT INTO @tblWO (
			intWOId
			,intExecNo
			)
		SELECT intWorkOrderId
			,intExecutionOrder - 1
		FROM tblMFWorkOrder
		WHERE intExecutionOrder > @intCurrentExecutionOrder
			AND Convert(DATE, dtmExpectedDate) = convert(DATE, @dtmCurrentDueDate)
			AND intManufacturingCellId = @intCurrentManufacturingCellId
		ORDER BY intExecutionOrder
	END
	ELSE
	BEGIN
		IF Convert(DATE, @dtmDueDate) <> convert(DATE, @dtmCurrentDueDate)
		BEGIN
			SELECT @intExecutionOrder = ISNULL(Max(intExecutionOrder), 0) + 1
			FROM tblMFWorkOrder
			WHERE Convert(DATE, dtmExpectedDate) = convert(DATE, @dtmDueDate)
				AND intManufacturingCellId = @intCurrentManufacturingCellId

			INSERT INTO @tblWO (
				intWOId
				,intExecNo
				)
			SELECT intWorkOrderId
				,intExecutionOrder - 1
			FROM tblMFWorkOrder
			WHERE intExecutionOrder > @intCurrentExecutionOrder
				AND Convert(DATE, dtmExpectedDate) = convert(DATE, @dtmCurrentDueDate)
				AND intManufacturingCellId = @intCurrentManufacturingCellId
			ORDER BY intExecutionOrder
		END
		ELSE
		BEGIN
			IF @intExecutionOrder > @intCurrentExecutionOrder
			BEGIN
				INSERT INTO @tblWO (
					intWOId
					,intExecNo
					)
				SELECT intWorkOrderId
					,intExecutionOrder - 1
				FROM tblMFWorkOrder
				WHERE intExecutionOrder > @intCurrentExecutionOrder
					AND intExecutionOrder <= @intExecutionOrder
					AND Convert(DATE, dtmExpectedDate) = convert(DATE, @dtmCurrentDueDate)
					AND intManufacturingCellId = @intCurrentManufacturingCellId
				ORDER BY intExecutionOrder
			END

			IF @intExecutionOrder < @intCurrentExecutionOrder
			BEGIN
				INSERT INTO @tblWO (
					intWOId
					,intExecNo
					)
				SELECT intWorkOrderId
					,intExecutionOrder + 1
				FROM tblMFWorkOrder
				WHERE intExecutionOrder >= @intExecutionOrder
					AND intExecutionOrder < @intCurrentExecutionOrder
					AND Convert(DATE, dtmExpectedDate) = convert(DATE, @dtmCurrentDueDate)
					AND intManufacturingCellId = @intCurrentManufacturingCellId
				ORDER BY intExecutionOrder
			END
		END
	END

	UPDATE tblMFWorkOrder
	SET intStorageLocationId = @intStorageLocationId
		,intManufacturingCellId = @intManufacturingCellId
		,strComment = @strComment
		,dtmExpectedDate = Convert(DATE, @dtmDueDate)
		,intExecutionOrder = @intExecutionOrder
		,dtmLastModified = GetDate()
		,intLastModifiedUserId = @intUserId
		,strReferenceNo=@strReferenceNo
		,strLotAlias=@strLotAlias
		,strVesselNo=@strVesselNo
		,dblActualQuantity=@dblActualQuantity
		,dblNoOfUnits=@dblNoOfUnits
		,intNoOfUnitsItemUOMId=@intNoOfUnitsItemUOMId
		,dtmPlannedDate=@dtmPlannedDate
	WHERE intWorkOrderId = @intWorkOrderId

	IF (
			SELECT count(1)
			FROM @tblWO
			) > 0
		UPDATE a
		SET a.intExecutionOrder = b.intExecNo
		FROM tblMFWorkOrder a
		JOIN @tblWO b ON a.intWorkOrderId = b.intWOId
END
ELSE
BEGIN
	UPDATE tblMFWorkOrder
	SET intStorageLocationId = @intStorageLocationId
		,strComment = @strComment
		,dtmLastModified = GetDate()
		,intLastModifiedUserId = @intUserId
		,strReferenceNo=@strReferenceNo
		,strLotAlias=@strLotAlias
		,strVesselNo=@strVesselNo
		,dblActualQuantity=@dblActualQuantity
		,dblNoOfUnits=@dblNoOfUnits
		,intNoOfUnitsItemUOMId=@intNoOfUnitsItemUOMId
		,dtmPlannedDate=@dtmPlannedDate
	WHERE intWorkOrderId = @intWorkOrderId
END
