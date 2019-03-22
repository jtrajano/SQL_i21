CREATE PROCEDURE uspMFLotCreate (
	@strXml NVARCHAR(MAX)
	,@strLotNumber NVARCHAR(50) OUTPUT
	,@intLotId INT OUTPUT
	)
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(Max)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	DECLARE @intItemId INT
		,@intCategoryId INT
		,@strLotAlias NVARCHAR(50)
		,@strParentLotNumber NVARCHAR(50)
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@dblQty NUMERIC(38, 20)
		,@intQtyUOMId INT
		,@dblWeight NUMERIC(38, 20)
		,@intWeightUOMId INT
		,@dblWeightPerQty NUMERIC(38, 20)
		,@intLotStatusId INT
		,@dtmDate DATETIME
		,@dblCostPerUnit NUMERIC(38, 20)
		,@strCropYear NVARCHAR(50)
		,@intReasonCodeId INT
		,@strNotes NVARCHAR(MAX)
		,@intLocationId INT
		,@intUserId INT
		,@dtmCreated DATETIME
		,@dtmBusinessDate DATETIME
		,@intBusinessShiftId INT
		,@strLotTracking NVARCHAR(50)
		,@STARTING_NUMBER_BATCH AS INT = 3
		,@strRetBatchId NVARCHAR(40)
		,@intBatchId INT
		,@strReasonCode NVARCHAR(50)

	SELECT @intItemId = intItemId
		,@intCategoryId = intCategoryId
		,@strLotNumber = strLotNumber
		,@strLotAlias = strLotAlias
		,@strParentLotNumber = strParentLotNumber
		,@intSubLocationId = intCompanyLocationSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@dblQty = dblQty
		,@intQtyUOMId = intQtyUOMId
		,@dblWeight = dblWeight
		,@intWeightUOMId = intWeightUOMId
		,@dblWeightPerQty = dblWeightPerQty
		,@intLotStatusId = intLotStatusId
		,@dtmDate = dtmCreateDate
		,@dblCostPerUnit = dblCostPerUnit
		,@strCropYear = strCropYear
		,@intReasonCodeId = intReasonCodeId
		,@strNotes = strNotes
		,@intLocationId = intLocationId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intItemId INT
			,intCategoryId INT
			,strLotNumber NVARCHAR(50)
			,strLotAlias NVARCHAR(50)
			,strParentLotNumber NVARCHAR(50)
			,intCompanyLocationSubLocationId INT
			,intStorageLocationId INT
			,dblQty NUMERIC(38, 20)
			,intQtyUOMId INT
			,dblWeight NUMERIC(38, 20)
			,intWeightUOMId INT
			,dblWeightPerQty NUMERIC(38, 20)
			,intLotStatusId INT
			,dtmCreateDate DATETIME
			,dblCostPerUnit NUMERIC(38, 20)
			,strCropYear NVARCHAR(50)
			,intReasonCodeId INT
			,strNotes NVARCHAR(MAX)
			,intLocationId INT
			,intUserId INT
			)

	SELECT @strReasonCode = strReasonCode
	FROM tblMFReasonCode
	WHERE intReasonCodeId = @intReasonCodeId

	IF @intReasonCodeId IS NOT NULL
		SELECT @strNotes = @strReasonCode + ' ' + @strNotes

	IF @dblCostPerUnit IS NULL
		SELECT @dblCostPerUnit = 0

	SELECT @strLotTracking = strLotTracking
	FROM tblICItem
	WHERE intItemId = @intItemId

	BEGIN TRAN

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
			,@intManufacturingId = NULL
			,@intSubLocationId = @intSubLocationId
			,@intLocationId = @intLocationId
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = NULL
			,@intPatternCode = 24
			,@ysnProposed = 0
			,@strPatternString = @strLotNumber OUTPUT
			,@intShiftId = @intBusinessShiftId
	END

	-- Get the next batch number
	EXEC uspSMGetStartingNumber @STARTING_NUMBER_BATCH
		,@strRetBatchId OUTPUT

	EXEC uspMFGeneratePatternId @intCategoryId = @intCategoryId
		,@intItemId = @intItemId
		,@intManufacturingId = NULL
		,@intSubLocationId = @intSubLocationId
		,@intLocationId = @intLocationId
		,@intOrderTypeId = NULL
		,@intBlendRequirementId = NULL
		,@intPatternCode = 33
		,@ysnProposed = 0
		,@strPatternString = @intBatchId OUTPUT

	EXEC uspMFPostProduction 1
		,0
		,NULL
		,@intItemId
		,@intUserId
		,NULL
		,@intStorageLocationId
		,@dblWeight
		,@intWeightUOMId
		,@dblWeightPerQty
		,@dblQty
		,@intQtyUOMId
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
		,NULL
		,NULL
		,NULL
		,@dblCostPerUnit
		,@strNotes

	IF @intLotStatusId IS NOT NULL
		AND NOT EXISTS (
			SELECT *
			FROM dbo.tblICLot
			WHERE intLotId = @intLotId
				AND intLotStatusId = @intLotStatusId
			)
		AND @strLotTracking <> 'No'
	BEGIN
		EXEC uspMFSetLotStatus @intLotId
			,@intLotStatusId
			,@intUserId
	END

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
