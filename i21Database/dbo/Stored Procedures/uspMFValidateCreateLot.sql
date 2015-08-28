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
	,@intMachineId int
	,@ysnLotAlias bit=0
	,@strLotAlias nvarchar(50)
	,@intProductionTypeId bit=3
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
		,@ysnMergeOnMove BIT
		,@intExistingiItemId INT
		,@intExistingStorageLocationId INT
		,@strExistingStorageLocationName NVARCHAR(50)
		,@strExistingItemNo NVARCHAR(50)
		,@intLotId INT
		,@CasesPerPallet INT
		,@dblUpperToleranceQuantity NUMERIC(18, 6)
		,@dblLowerToleranceQuantity NUMERIC(18, 6)
		,@strLocationName nvarchar(50)
		,@dtmCurrentDate datetime
		,@dtmCurrentDateTime datetime
		,@intDayOfYear int
		,@intAttributeId int
		,@strAllInputItemsMandatoryforConsumption nvarchar(50)
		,@strUpperToleranceQuantity nvarchar(50)
		,@strLowerToleranceQuantity nvarchar(50)
		,@strQuantity nvarchar(50)
	
	Select @dtmCurrentDateTime	=GETDATE()
	Select @dtmCurrentDate		=CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))
	Select @intDayOfYear		=DATEPART(dy,@dtmCurrentDateTime)


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
				,@strLocationName,@strItemNo
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
				AND intItemUOMId in (@intItemUOMId,@intItemUnitCountUOMId) and ysnStockUnit=1
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
		,@ysnMergeOnMove = ysnMergeOnMove
	FROM dbo.tblICStorageLocation
	WHERE intStorageLocationId = @intStorageLocationId

	IF @ysnAllowMultipleLot = 0
		AND @ysnAllowMultipleItem = 0
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM tblICLot
				WHERE intStorageLocationId = @intStorageLocationId
					AND dblQty > 0
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
		AND @ysnMergeOnMove=0
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM tblICLot
				WHERE intStorageLocationId = @intStorageLocationId
					AND intItemId = @intItemId
					AND dblQty > 0
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
					AND dblQty > 0
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

	IF @intLotId IS NOT NULL AND @ysnMergeOnMove=0
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
	IF @dtmCreated > @dtmCurrentDateTime
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
			,@intManufacturingProcessId int

		SELECT @intProductId = intItemId
			,@dblRequiredQuantity = dblQuantity
			,@intManufacturingProcessId=intManufacturingProcessId 
		FROM dbo.tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		IF @intItemId NOT IN (
				SELECT RI.intItemId
				FROM dbo.tblMFWorkOrderRecipeItem RI 
				WHERE RI.intWorkOrderId =@intWorkOrderId 
					AND RI.intRecipeItemTypeId = 2
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
				WHERE intWorkOrderId = @intWorkOrderId and W.intStatusId =13
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
				WHERE intWorkOrderId = @intWorkOrderId and W.intStatusId =11
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
				WHERE intWorkOrderId = @intWorkOrderId and W.intStatusId in(10,12)
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
		FROM dbo.tblMFWorkOrderRecipe R
		JOIN dbo.tblMFWorkOrderRecipeItem RI ON R.intRecipeId = RI.intRecipeId and R.intWorkOrderId=RI.intWorkOrderId 
		WHERE R.intItemId = @intProductId
			AND R.ysnActive = 1
			AND intRecipeItemTypeId = 2
			AND RI.intItemId = @intItemId

		IF @ysnIgnoreTolerance = 0
			AND @dblQuantity > @dblUpperToleranceQuantity
		BEGIN
			SELECT @strQuantity=@dblQuantity
			SELECT @strUpperToleranceQuantity=@dblUpperToleranceQuantity
			RAISERROR (
					51083
					,11
					,1
					,@strQuantity
					,@strItemNo
					,@strUpperToleranceQuantity
					)

			RETURN
		END

		IF @ysnIgnoreTolerance = 0
			AND @dblLowerToleranceQuantity > @dblQuantity
		BEGIN
			SELECT @strQuantity=@dblQuantity
			SELECT @strLowerToleranceQuantity=@dblLowerToleranceQuantity
			RAISERROR (
					51084
					,11
					,1
					,@strQuantity
					,@strItemNo
					,@strLowerToleranceQuantity
					)

			RETURN
		END

		Select @intAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='All input items mandatory for consumption'

		Select @strAllInputItemsMandatoryforConsumption=strAttributeValue
		From tblMFManufacturingProcessAttribute
		Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId and intAttributeId=@intAttributeId

		IF @strAllInputItemsMandatoryforConsumption='True' and @intProductionTypeId=3 and EXISTS (
		SELECT *
		FROM dbo.tblMFWorkOrderRecipeItem ri
		LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem SI ON SI.intRecipeItemId = ri.intRecipeItemId and ri.intWorkOrderId =SI.intWorkOrderId 
		AND SI.intRecipeId = ri.intRecipeId
		WHERE ri.intWorkOrderId = @intWorkOrderId
			AND ri.intRecipeItemTypeId = 1
			AND (
				(
					ri.ysnYearValidationRequired = 1
					AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
						AND ri.dtmValidTo
					)
				OR (
					ri.ysnYearValidationRequired = 0
					AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
						AND DATEPART(dy, ri.dtmValidTo)
					)
				)
			AND ri.intConsumptionMethodId <>4
			AND NOT EXISTS (
				SELECT *
				FROM tblMFWorkOrderConsumedLot WC
				JOIN dbo.tblICLot L ON L.intLotId = WC.intLotId
				WHERE (L.intItemId = ri.intItemId OR L.intItemId = SI.intSubstituteItemId)and WC.intWorkOrderId =@intWorkOrderId 
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
		If @intMachineId is NOt null
		Begin

			Declare @dblBatchSize numeric(18,6),@intBatchSizeUOMId int,@intUnitMeasureId int

			Select @intUnitMeasureId=intUnitMeasureId 
			from dbo.tblICItemUOM 
			Where intItemUOMId=@intItemUOMId

			Select @dblBatchSize=dblBatchSize,@intBatchSizeUOMId=intBatchSizeUOMId
			From dbo.tblMFMachine
			Where intMachineId=@intMachineId

			If @dblBatchSize is not null and @intBatchSizeUOMId is not null
			Begin
				If @intBatchSizeUOMId=@intUnitMeasureId and @dblQuantity>@dblBatchSize
				Begin
					RAISERROR (
					51121
					,11
					,1
					)
				End
			End
		End
		If @ysnLotAlias=1 and @strLotAlias=''
		Begin
					RAISERROR (
					51122
					,11
					,1
					,@strItemNo
					)
	
		End

		If @intWorkOrderId is null
		Begin
					RAISERROR (
					51123
					,11
					,1
					,@strItemNo
					)
	
		end


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

