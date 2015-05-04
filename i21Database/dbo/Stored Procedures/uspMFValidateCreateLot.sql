CREATE PROCEDURE [dbo].uspMFValidateCreateLot (
	@strLotNumber NVARCHAR(50)
	,@dtmCreated DATETIME = NULL
	,@intShiftId int=NULL
	,@intItemId INT
	,@intStorageLocationId INT
	,@intSubLocationId INT
	,@intLocationId INT
	,@dblQuantity NUMERIC(18, 6)
	,@intItemUOMId INT
	,@dblUnitCount NUMERIC(18, 6) = 0
	,@intItemUnitCountUOMId INT = NULL
	,@ysnNegativeQtyAllowed BIT = 0
	,@ysnSubLotAllowed BIT = 0
	,@intWorkOrderId INT = NULL
	,@intLotTransactionTypeId INT
	,@ysnCreateNewLot BIT = 1
	,@ysnFGProduction BIT = 0
	,@ysnIgnoreTolerance BIT = 1
	)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	if @ysnNegativeQtyAllowed is null
	Select @ysnNegativeQtyAllowed=0

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strItemNo NVARCHAR(50)
		,@strStatus NVARCHAR(50)
		,@ysnAllowMultipleItem BIT
		,@ysnAllowMultipleLot BIT
		,@intExistingiItemId INT
		,@intExistingStorageLocationId INT
		,@strExistingStorageLocationName NVARCHAR(50)
		,@strExistingItemNo NVARCHAR(50)
		,@intLotId INT
		,@CasesPerPallet INT
		,@dblUpperToleranceQuantity NUMERIC(18, 6)
		,@dblLowerToleranceQuantity NUMERIC(18, 6)
		,@strLocationName nvarchar(50)


	IF @strLotNumber LIKE '%[@~$\`^&*()%?/<>!|\+;:",.{}'']%'
	BEGIN
		RAISERROR (
				51061
				,11
				,1
				)
	END

	IF @dblQuantity <> @dblUnitCount
		AND @intItemUOMId = @intItemUnitCountUOMId
	BEGIN
		RAISERROR (
				51062
				,11
				,1
				)
	END

	IF (
			@dblQuantity <= 0
			OR @dblUnitCount <= 0
			)
		AND @ysnNegativeQtyAllowed = 0
	BEGIN
		RAISERROR (
				51063
				,11
				,1
				)
	END

	SELECT @strItemNo = strItemNo
		,@strStatus = strStatus
		,@CasesPerPallet = intLayerPerPallet * intUnitPerLayer
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	IF @strItemNo IS NULL
	BEGIN
		RAISERROR (
				51064
				,11
				,1
				)
	END

	IF @strStatus = 'InActive'
	BEGIN
		RAISERROR (
				51065
				,11
				,1
				,@strItemNo
				)
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblICItemLocation
			WHERE intItemId = @intItemId
				AND intLocationId = @intLocationId
			)
	BEGIN

		SELECT @strLocationName=strLocationName
		FROM dbo.tblSMCompanyLocation
		WHERE intCompanyLocationId = @intLocationId

		RAISERROR (
				51092
				,11
				,1
				,@strLocationName
				)
	END

	IF @intItemUnitCountUOMId is null
	BEGIN
		RAISERROR (
				51093
				,11
				,1
				)
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblICItemUOM
			WHERE intItemId = @intItemId
				AND intItemUOMId = @intItemUOMId and ysnStockUnit=1
			)
	BEGIN

		RAISERROR (
				51094
				,11
				,1
				)
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblICItemUOM
			WHERE intItemId = @intItemId
				AND intItemUOMId = @intItemUnitCountUOMId 
			)
	BEGIN

		RAISERROR (
				51093
				,11
				,1
				)
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblSMCompanyLocation
			WHERE intCompanyLocationId = @intLocationId
			)
	BEGIN
		RAISERROR (
				51066
				,11
				,1
				)
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblSMCompanyLocationSubLocation
			WHERE intCompanyLocationId = @intLocationId
				AND intCompanyLocationSubLocationId = @intSubLocationId
			)
	BEGIN
		RAISERROR (
				51067
				,11
				,1
				)
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblICStorageLocation
			WHERE intStorageLocationId = @intStorageLocationId
				AND intSubLocationId = @intSubLocationId
			)
	BEGIN
		RAISERROR (
				51068
				,11
				,1
				)
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblICStorageLocation
			WHERE intParentStorageLocationId = @intStorageLocationId
			)
	BEGIN
		RAISERROR (
				51069
				,11
				,1
				)
	END

	SELECT @ysnAllowMultipleItem = ysnAllowMultipleItem
		,@ysnAllowMultipleLot = ysnAllowMultipleLot
	FROM dbo.tblICStorageLocation
	WHERE intStorageLocationId = @intStorageLocationId

	IF @ysnAllowMultipleLot = 0
		AND @ysnAllowMultipleItem = 0
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM tblICLot
				WHERE intStorageLocationId = @intStorageLocationId
					AND dblWeight > 0
				)
		BEGIN
			RAISERROR (
					51070
					,11
					,1
					)
		END
	END
	ELSE IF @ysnAllowMultipleLot = 0
		AND @ysnAllowMultipleItem = 1
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM tblICLot
				WHERE intStorageLocationId = @intStorageLocationId
					AND intItemId = @intItemId
					AND dblWeight > 0
				)
		BEGIN
			RAISERROR (
					51071
					,11
					,1
					,@strItemNo
					)
		END
	END
	ELSE IF @ysnAllowMultipleLot = 1
		AND @ysnAllowMultipleItem = 0
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM tblICLot
				WHERE intStorageLocationId = @intStorageLocationId
					AND intItemId <> @intItemId
					AND dblWeight > 0
				)
		BEGIN
			RAISERROR (
					51072
					,11
					,1
					)
		END
	END

	SELECT @intLotId = intLotId
	FROM tblICLot
	WHERE strLotNumber = @strLotNumber
		AND intStorageLocationId = CASE 
			WHEN @ysnSubLotAllowed = 1
				THEN @intStorageLocationId
			ELSE intStorageLocationId
			END

	SELECT @intExistingiItemId = intItemId
		,@intExistingStorageLocationId = intStorageLocationId
	FROM tblICLot
	WHERE strLotNumber = @strLotNumber

	IF @intLotId IS NOT NULL
	BEGIN
		SELECT @strExistingStorageLocationName = strName
		FROM dbo.tblICStorageLocation
		WHERE intStorageLocationId = @intExistingStorageLocationId

		RAISERROR (
				51073
				,11
				,1
				,@strLotNumber
				,@strExistingStorageLocationName
				)
	END

	IF @ysnSubLotAllowed = 1
		AND @intExistingiItemId <> @intItemId
		AND @intExistingiItemId IS NOT NULL
	BEGIN
		SELECT @strExistingStorageLocationName = strName
		FROM dbo.tblICStorageLocation
		WHERE intStorageLocationId = @intExistingStorageLocationId

		SELECT @strExistingItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intExistingiItemId

		RAISERROR (
				51074
				,11
				,1
				,@strLotNumber
				,@strExistingItemNo
				,@strExistingStorageLocationName
				)
	END
	Select @dtmCreated=@dtmCreated+dtmShiftStartTime+intStartOffset from tblMFShift Where intShiftId=@intShiftId 
	IF @dtmCreated > GetDate()
	BEGIN
		RAISERROR (
				51075
				,11
				,1
				)
	END

	IF @ysnCreateNewLot = 0
		AND NOT EXISTS (
			SELECT *
			FROM dbo.tblICLot
			WHERE strLotNumber = @strLotNumber
				AND intStorageLocationId = CASE 
					WHEN @ysnSubLotAllowed = 1
						THEN @intStorageLocationId
					ELSE intStorageLocationId
					END
			)
	BEGIN
		RAISERROR (
				51076
				,11
				,1
				,@strLotNumber
				)
	END

	IF @intLotTransactionTypeId = 3
	BEGIN
		DECLARE @intProductId INT
			,@dblRequiredQuantity DECIMAL(18, 6)

		SELECT @intProductId = intItemId
			,@dblRequiredQuantity = dblQuantity
		FROM dbo.tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		IF @intItemId NOT IN (
				SELECT RI.intItemId
				FROM dbo.tblMFRecipe R
				JOIN dbo.tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId
				WHERE R.intItemId = @intProductId
					AND R.ysnActive = 1
					AND intRecipeItemTypeId = 2
				)
			RAISERROR (
					51077
					,11
					,1
					)

		IF NOT EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrder
				WHERE intWorkOrderId = @intWorkOrderId
				)
		BEGIN
			RAISERROR (
					51078
					,11
					,1
					)
		END

		IF EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrder W
				JOIN tblMFWorkOrderStatus WS ON W.intStatusId = WS.intStatusId
				WHERE intWorkOrderId = @intWorkOrderId
					AND WS.strName = 'Completed'
				)
		BEGIN
			RAISERROR (
					51079
					,11
					,1
					)
		END

		IF EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrder W
				JOIN tblMFWorkOrderStatus WS ON W.intStatusId = WS.intStatusId
				WHERE intWorkOrderId = @intWorkOrderId
					AND WS.strName = 'Paused'
				)
		BEGIN
			RAISERROR (
					51080
					,11
					,1
					)
		END

		IF NOT EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrder W
				JOIN tblMFWorkOrderStatus WS ON W.intStatusId = WS.intStatusId
				WHERE intWorkOrderId = @intWorkOrderId
					AND WS.strName = 'Started'
				)
		BEGIN
			RAISERROR (
					51081
					,11
					,1
					)
		END

		IF @ysnFGProduction = 1
			AND @CasesPerPallet > 0
			AND @dblQuantity > @CasesPerPallet
		BEGIN
			RAISERROR (
					51059
					,11
					,1
					)

			RETURN
		END

		SELECT @dblUpperToleranceQuantity = dblCalculatedUpperTolerance * @dblRequiredQuantity / R.dblQuantity
			,@dblLowerToleranceQuantity = dblCalculatedLowerTolerance * @dblRequiredQuantity / R.dblQuantity
		FROM dbo.tblMFRecipe R
		JOIN dbo.tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId
		WHERE R.intItemId = @intProductId
			AND R.ysnActive = 1
			AND intRecipeItemTypeId = 2
			AND RI.intItemId = @intItemId

		IF @ysnIgnoreTolerance = 0
			AND @dblQuantity > @dblUpperToleranceQuantity
		BEGIN
			RAISERROR (
					51083
					,11
					,1
					,@dblQuantity
					,@strItemNo
					,@dblUpperToleranceQuantity
					)

			RETURN
		END

		IF @ysnIgnoreTolerance = 0
			AND @dblLowerToleranceQuantity > @dblQuantity
		BEGIN
			RAISERROR (
					51084
					,11
					,1
					,@dblQuantity
					,@strItemNo
					,@dblLowerToleranceQuantity
					)

			RETURN
		END

		IF EXISTS (
		SELECT *
		FROM dbo.tblMFRecipeItem ri
		JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		WHERE r.intItemId = @intProductId
			AND ri.intRecipeItemTypeId = 1
			AND (
				(
					ri.ysnYearValidationRequired = 1
					AND CONVERT(DATETIME, CONVERT(CHAR, GETDATE(), 101)) BETWEEN ri.dtmValidFrom
						AND ri.dtmValidTo
					)
				OR (
					ri.ysnYearValidationRequired = 0
					AND DATEPART(dy, GETDATE()) BETWEEN DATEPART(dy, ri.dtmValidFrom)
						AND DATEPART(dy, ri.dtmValidTo)
					)
				)
			AND ri.intConsumptionMethodId IN (
				2
				,3
				)
			AND NOT EXISTS (
				SELECT *
				FROM tblMFWorkOrderConsumedLot WC
				JOIN dbo.tblICLot L ON L.intLotId = WC.intLotId
				WHERE L.intItemId = ri.intItemId and WC.intWorkOrderId =@intWorkOrderId 
				)
		)
		BEGIN
			RAISERROR (
					51095
					,11
					,1
					)

			RETURN
		END

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

