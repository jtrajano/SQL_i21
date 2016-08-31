CREATE PROCEDURE uspMFWastage_LotCreate
     @strXml NVARCHAR(Max)
	,@strLotNumber NVARCHAR(50) OUTPUT
	,@intLotId INT OUTPUT
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
		,@intManufacturingCellId INT
		,@intStorageLocationId INT
		,@intLocationId INT
		,@intWorkOrderId INT
		,@dblWeight NUMERIC(38, 20)
		,@intWeightUOMId INT
		,@strLotAlias NVARCHAR(50)
		,@intUserId INT
		,@strParentLotNumber NVARCHAR(50)
	DECLARE @strLotTracking NVARCHAR(50)
		,@intCategoryId INT
		,@intSubLocationId INT
		,@STARTING_NUMBER_BATCH AS INT = 3
		,@strRetBatchId NVARCHAR(40)
		,@intBatchId INT
		,@dtmDate DATETIME
		,@intItemUOMId INT

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
		,@strParentLotNumber = strParentLotNumber
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
			,strParentLotNumber NVARCHAR(50)
			)

	SELECT @strLotTracking = strLotTracking
		,@intCategoryId = intCategoryId
	FROM tblICItem
	WHERE intItemId = @intItemId

	SELECT @intSubLocationId = intSubLocationId
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intStorageLocationId

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

		IF (@intItemUOMId <> @intWeightUOMId)
		BEGIN
			SELECT @dblWeight = dbo.fnMFConvertQuantityToTargetItemUOM(@intWeightUOMId, @intItemUOMId, ISNULL(@dblWeight, 0))

			SELECT @intWeightUOMId = @intItemUOMId
		END
	END

	IF (
			@strLotNumber = ''
			OR @strLotNumber IS NULL
			)
		AND @strLotTracking <> 'Yes - Serial Number'
	BEGIN
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
		,@intWeightUOMId
		,1
		,@dblWeight
		,@intWeightUOMId
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
