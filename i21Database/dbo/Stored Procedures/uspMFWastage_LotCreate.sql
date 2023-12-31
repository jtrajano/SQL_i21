CREATE PROCEDURE uspMFWastage_LotCreate
	@strXml NVARCHAR(Max)
	,@strLotNumber NVARCHAR(50) OUTPUT
	,@intLotId INT OUTPUT
	,@intBatchId INT OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(Max)
	DECLARE @dtmCreated DATETIME
			,@dtmBusinessDate DATETIME
			,@intBusinessShiftId INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	DECLARE @intItemId INT
		,@intManufacturingCellId INT
		,@intStorageLocationId INT
		,@intLocationId INT
		,@intWorkOrderId INT
		,@dblWeight NUMERIC(38, 20)
		,@intWeightUOMId INT
		,@strLotAlias NVARCHAR(50)
		,@intUserId INT
		,@strShiftActivityNo NVARCHAR(50)
	DECLARE @strLotTracking NVARCHAR(50)
		,@intCategoryId INT
		,@intSubLocationId INT
		,@STARTING_NUMBER_BATCH AS INT = 3
		,@strRetBatchId NVARCHAR(40)
		,@dtmDate DATETIME
		,@intItemUOMId INT
		,@intWeightItemUOMId INT
		,@strParentLotNumber NVARCHAR(50)
		,@intItemLocationId INT
		,@dblStandardCost NUMERIC(38, 20)

	SELECT @strLotNumber = strLotNumber
		,@intLotId = intLotId
		,@intItemId = intItemId
		,@intManufacturingCellId = intManufacturingCellId
		,@intStorageLocationId = intStorageLocationId
		,@intLocationId = intLocationId
		,@intWorkOrderId = intWorkOrderId
		,@dblWeight = dblWeight
		,@intWeightUOMId = intWeightUOMId
		,@strLotAlias = strLotAlias
		,@intUserId = intUserId
		,@strShiftActivityNo = strShiftActivityNo
	FROM OPENXML(@idoc, 'root', 2) WITH (
			strLotNumber NVARCHAR(50)
			,intLotId INT
			,intItemId INT
			,intManufacturingCellId INT
			,intStorageLocationId INT
			,intLocationId INT
			,intWorkOrderId INT
			,dblWeight NUMERIC(38, 20)
			,intWeightUOMId INT
			,strLotAlias NVARCHAR(50)
			,intUserId INT
			,strShiftActivityNo NVARCHAR(50)
			)

	SELECT @strLotTracking = strLotTracking
		,@intCategoryId = intCategoryId
	FROM tblICItem
	WHERE intItemId = @intItemId

	SELECT @intSubLocationId = intSubLocationId
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intStorageLocationId

	SELECT @intWeightItemUOMId = IUOM.intItemUOMId
	FROM tblICItemUOM IUOM
	JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
	WHERE IUOM.intItemId = @intItemId
		AND IUOM.intUnitMeasureId = @intWeightUOMId

	SELECT @intItemLocationId = intItemLocationId
	FROM tblICItemLocation
	WHERE intItemId = @intItemId
		AND intLocationId = @intLocationId

	SELECT @dblStandardCost = ISNULL(dblStandardCost, 0)
	FROM tblICItemPricing
	WHERE intItemId = @intItemId
		AND intItemLocationId = @intItemLocationId

	IF (@dblStandardCost <= 0)
	BEGIN
		SELECT @intBatchId = NULL
			,@intLotId = NULL
			,@strLotNumber = ''

		RETURN;
	END

	BEGIN TRAN

	-- Converting Quantity to Lot Item UOM
	IF (ISNULL(@intLotId, 0) > 0)
	BEGIN
		SELECT @intItemUOMId = intItemUOMId
		FROM tblICLot
		WHERE intLotId = @intLotId

		SELECT @strParentLotNumber = PL.strParentLotNumber
		FROM tblICLot L
		JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
		WHERE L.intLotId = @intLotId

		IF (@intItemUOMId <> @intWeightItemUOMId)
		BEGIN
			SELECT @dblWeight = dbo.fnMFConvertQuantityToTargetItemUOM(@intWeightItemUOMId, @intItemUOMId, ISNULL(@dblWeight, 0))

			SELECT @intWeightItemUOMId = @intItemUOMId
		END
	END

	IF (
			@strLotNumber = ''
			OR @strLotNumber IS NULL
			)
		AND @strLotTracking <> 'Yes - Serial Number'
	BEGIN
		SELECT @dtmCreated = Getdate()

		SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCreated, @intLocationId)

		SELECT @intBusinessShiftId = intShiftId
		FROM dbo.tblMFShift
		WHERE intLocationId = @intLocationId
			AND @dtmCreated BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
				AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

		EXEC uspMFGeneratePatternId @intCategoryId = @intCategoryId
			,@intItemId = @intItemId
			,@intManufacturingId = @intManufacturingCellId
			,@intSubLocationId = @intSubLocationId
			,@intLocationId = @intLocationId
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = NULL
			,@intPatternCode = 24
			,@ysnProposed = 0
			,@strPatternString = @strLotNumber OUTPUT
			,@intShiftId=@intBusinessShiftId
	END

	-- Get the next batch number
	EXEC uspSMGetStartingNumber @STARTING_NUMBER_BATCH
		,@strRetBatchId OUTPUT

	EXEC uspMFGeneratePatternId @intCategoryId = @intCategoryId
		,@intItemId = @intItemId
		,@intManufacturingId = @intManufacturingCellId
		,@intSubLocationId = @intSubLocationId
		,@intLocationId = @intLocationId
		,@intOrderTypeId = NULL
		,@intBlendRequirementId = NULL
		,@intPatternCode = 33
		,@ysnProposed = 0
		,@strPatternString = @intBatchId OUTPUT

	EXEC uspMFPostProduction 1
		,0
		,@intWorkOrderId
		,@intItemId
		,@intUserId
		,NULL
		,@intStorageLocationId
		,@dblWeight
		,@intWeightItemUOMId
		,1
		,@dblWeight
		,@intWeightItemUOMId
		,@strRetBatchId
		,@strLotNumber
		,@intBatchId
		,@intLotId OUTPUT
		,@strLotAlias
		,NULL
		,@strParentLotNumber
		,NULL
		,@dtmDate
		,NULL
		,@strShiftActivityNo

	EXEC sp_xml_removedocument @idoc

	COMMIT TRAN
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
