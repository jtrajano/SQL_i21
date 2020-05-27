CREATE PROCEDURE [dbo].uspMFValidateCreateLot (
	@strLotNumber NVARCHAR(50)
	,@dtmCreated DATETIME = NULL
	,@intShiftId INT = NULL
	,@intItemId INT
	,@intStorageLocationId INT
	,@intSubLocationId INT
	,@intLocationId INT
	,@dblQuantity NUMERIC(38, 20)
	,@intItemUOMId INT
	,@dblUnitCount NUMERIC(38, 20) = 0
	,@intItemUnitCountUOMId INT = NULL
	,@ysnNegativeQtyAllowed BIT = 0
	,@ysnSubLotAllowed BIT = 0
	,@intWorkOrderId INT = NULL
	,@intLotTransactionTypeId INT
	,@ysnCreateNewLot BIT = 1
	,@ysnFGProduction BIT = 0
	,@ysnIgnoreTolerance BIT = 1
	,@intMachineId INT
	,@ysnLotAlias BIT = 0
	,@strLotAlias NVARCHAR(50)
	,@intProductionTypeId BIT = 3
	,@ysnFillPartialPallet BIT = 0
	)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	IF @ysnNegativeQtyAllowed IS NULL
		SELECT @ysnNegativeQtyAllowed = 0

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
		,@dblUpperToleranceQuantity NUMERIC(38, 20)
		,@dblLowerToleranceQuantity NUMERIC(38, 20)
		,@strLocationName NVARCHAR(50)
		,@dtmCurrentDate DATETIME
		,@dtmCurrentDateTime DATETIME
		,@intDayOfYear INT
		,@intAttributeId INT
		,@strAllInputItemsMandatoryforConsumption NVARCHAR(50)
		,@strUpperToleranceQuantity NVARCHAR(50)
		,@strLowerToleranceQuantity NVARCHAR(50)
		,@strQuantity NVARCHAR(50)
		,@strAttributeValue NVARCHAR(50)
		,@intSampleStatusId INT
		,@strCellName NVARCHAR(50)
		,@dtmSampleCreated DATETIME
		,@strWIPSampleMandatory NVARCHAR(50)
		,@intDurationBetweenLineSample INT
		,@dtmStartedDate DATETIME
		,@intControlPointId INT
		,@intSampleTypeId INT
		,@ysnAddQtyOnExistingLot BIT
		,@strLotTracking NVARCHAR(50)
		,@intCategoryId INT
		,@strCategoryCode NVARCHAR(50)
		,@strErrorMsg NVARCHAR(MAX)
		,@strName NVARCHAR(50)

	SELECT @dtmCurrentDateTime = GETDATE()

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDateTime)

	IF @strLotNumber LIKE '%[@~$\`^&*()%?<>!|\+;:",.{}'']%'
	BEGIN
		RAISERROR (
				'Special characters are not allowed for LotID.'
				,11
				,1
				)
	END

	SELECT @ysnAddQtyOnExistingLot = ysnAddQtyOnExistingLot
	FROM tblMFCompanyPreference

	IF @ysnFillPartialPallet = 0
		AND @ysnAddQtyOnExistingLot = 0
		AND EXISTS (
			SELECT *
			FROM dbo.tblICLot L
			JOIN dbo.tblMFWorkOrderProducedLot WP ON L.intLotId = WP.intLotId
			WHERE strLotNumber = @strLotNumber
				AND WP.ysnProductionReversed = 0
			)
	BEGIN
		RAISERROR (
				'Pallet Id already exists'
				,11
				,1
				)
	END

	IF @dblQuantity <> @dblUnitCount
		AND @intItemUOMId = @intItemUnitCountUOMId
	BEGIN
		RAISERROR (
				'Lot quantity and physical count should be equal when same UOM is selected.'
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
				'It is required to enter number of unit and weight to produce the lot.'
				,11
				,1
				)
	END

	SELECT @strItemNo = strItemNo
		,@strStatus = strStatus
		,@CasesPerPallet = intLayerPerPallet * intUnitPerLayer
		,@strLotTracking = strLotTracking
		,@intCategoryId = intCategoryId
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	IF EXISTS (
			SELECT *
			FROM tblICStorageLocationCategory
			WHERE intStorageLocationId = @intStorageLocationId
			)
	BEGIN
		IF NOT EXISTS (
				SELECT *
				FROM tblICStorageLocationCategory
				WHERE intStorageLocationId = @intStorageLocationId
					AND intCategoryId = @intCategoryId
				)
		BEGIN
			SELECT @strCategoryCode = strCategoryCode
			FROM tblICCategory
			WHERE intCategoryId = @intCategoryId

			SELECT @strName = strName
			FROM tblICStorageLocation
			WHERE intStorageLocationId = @intStorageLocationId

			SELECT @strErrorMsg = 'Item category ''' + @strCategoryCode + ''' is not allowed into the storage unit ''' + @strName + '''.'

			RAISERROR (
					@strErrorMsg
					,11
					,1
					)
		END
	END

	IF @strItemNo IS NULL
	BEGIN
		RAISERROR (
				'Item is not available. It may have been deleted or inactive.'
				,11
				,1
				)
	END

	IF @strStatus = 'InActive'
	BEGIN
		RAISERROR (
				'The specified item ''%s'' is InActive. The transaction can not proceed.'
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
		SELECT @strLocationName = strLocationName
		FROM dbo.tblSMCompanyLocation
		WHERE intCompanyLocationId = @intLocationId

		RAISERROR (
				'Please configure the location %s in the Item maintenance.'
				,11
				,1
				,@strLocationName
				,@strItemNo
				)
	END

	IF @intItemUnitCountUOMId IS NULL
	BEGIN
		RAISERROR (
				'Please configure the Packing UOM in the Item maintenance.'
				,11
				,1
				)
	END

	--IF NOT EXISTS (
	--		SELECT *
	--		FROM dbo.tblICItemUOM
	--		WHERE intItemId = @intItemId
	--			AND intItemUOMId in (@intItemUOMId,@intItemUnitCountUOMId) and ysnStockUnit=1
	--		)
	--BEGIN
	--	RAISERROR (
	--			51094
	--			,11
	--			,1
	--			)
	--END
	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblICItemUOM
			WHERE intItemId = @intItemId
				AND intItemUOMId = @intItemUnitCountUOMId
			)
	BEGIN
		RAISERROR (
				'Please configure the Packing UOM in the Item maintenance.'
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
				'Location is not available. It may have been deleted.'
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
				'Sub Location is not available. It may have been deleted.'
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
				'Storage Location is not available. It may have been deleted.'
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
				'Parent Storage Location is not allowed to hold a Lot.'
				,11
				,1
				)
	END

	SELECT @ysnAllowMultipleItem = ysnAllowMultipleItem
		,@ysnAllowMultipleLot = ysnAllowMultipleLot
		,@ysnMergeOnMove = ysnMergeOnMove
	FROM dbo.tblICStorageLocation
	WHERE intStorageLocationId = @intStorageLocationId

	IF @strLotTracking <> 'No'
	BEGIN
		IF @ysnAllowMultipleLot = 0
			AND @ysnAllowMultipleItem = 0
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM tblICLot
					WHERE intStorageLocationId = @intStorageLocationId
						AND dblQty > 0
						AND intItemId <> @intItemId
					)
			BEGIN
				SELECT @strName = strName
				FROM tblICStorageLocation
				WHERE intStorageLocationId = @intStorageLocationId

				RAISERROR (
						'The Storage Location ''%s'' is already used by other Lot.'
						,11
						,1
						,@strName
						)
			END
		END
		ELSE IF @ysnAllowMultipleLot = 0
			AND @ysnAllowMultipleItem = 1
			AND @ysnMergeOnMove = 0
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
						'The Storage Location is already used by other Lot for the Item ''%s'''
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
						'The Storage Location is already used by other Item.'
						,11
						,1
						)
			END
		END

		IF @strLotNumber IS NOT NULL and @strLotNumber<>''
		BEGIN
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
		END

		IF @intLotId IS NOT NULL
			AND @ysnMergeOnMove = 0
		BEGIN
			SELECT @strExistingStorageLocationName = strName
			FROM dbo.tblICStorageLocation
			WHERE intStorageLocationId = @intExistingStorageLocationId

			RAISERROR (
					'LotID ''%s'' already exists in this storage location ''%s''.'
					,11
					,1
					,@strLotNumber
					,@strExistingStorageLocationName
					)
		END
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
				'LotID ''%s'' has been configured with item ''%s'' in storage location ''%s''. Please select same item to proceed.'
				,11
				,1
				,@strLotNumber
				,@strExistingItemNo
				,@strExistingStorageLocationName
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
				'The Lot %s does not exist.'
				,11
				,1
				,@strLotNumber
				)
	END

	IF @intLotTransactionTypeId = 3
	BEGIN
		DECLARE @intProductId INT
			,@dblRequiredQuantity DECIMAL(18, 6)
			,@intManufacturingProcessId INT
			,@intManufacturingCellId INT

		SELECT @intProductId = intItemId
			,@dblRequiredQuantity = dblQuantity
			,@intManufacturingProcessId = intManufacturingProcessId
			,@dtmStartedDate = dtmStartedDate
			,@intManufacturingCellId = intManufacturingCellId
		FROM dbo.tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @intAttributeId = intAttributeId
		FROM tblMFAttribute
		WHERE strAttributeName = 'Future Date Production Allowed'

		SELECT @strAttributeValue = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = @intAttributeId

		SELECT @dtmCreated = @dtmCreated + dtmShiftStartTime + intStartOffset
		FROM tblMFShift
		WHERE intShiftId = @intShiftId

		IF @strAttributeValue = 'False'
			AND @dtmCreated > @dtmCurrentDateTime
		BEGIN
			RAISERROR (
					'Lot cannot be produced in a future date or future shift.'
					,11
					,1
					)
		END

		IF @intItemId NOT IN (
				SELECT RI.intItemId
				FROM dbo.tblMFWorkOrderRecipeItem RI
				WHERE RI.intWorkOrderId = @intWorkOrderId
					AND RI.intRecipeItemTypeId = 2
				)
		BEGIN
			EXEC uspICRaiseError 80021;

			RETURN;
		END

		IF NOT EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrder
				WHERE intWorkOrderId = @intWorkOrderId
				)
		BEGIN
			RAISERROR (
					'The work order that you clicked on does not exist.'
					,11
					,1
					)
		END

		IF EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrder W
				WHERE intWorkOrderId = @intWorkOrderId
					AND W.intStatusId = 13
				)
		BEGIN
			RAISERROR (
					'The work order that you clicked on is already completed.'
					,11
					,1
					)
		END

		IF EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrder W
				WHERE intWorkOrderId = @intWorkOrderId
					AND W.intStatusId = 11
				)
		BEGIN
			RAISERROR (
					'The work order has been paused. Please re-start the WO to resume.'
					,11
					,1
					)
		END

		IF NOT EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrder W
				WHERE intWorkOrderId = @intWorkOrderId
					AND W.intStatusId IN (
						10
						,12
						)
				)
		BEGIN
			RAISERROR (
					'Work order is not in started state. Please start the work order.'
					,11
					,1
					)
		END

		IF @ysnFGProduction = 1
			AND @CasesPerPallet > 0
			AND @dblQuantity > @CasesPerPallet
		BEGIN
			RAISERROR (
					'The pallet lot quantity cannot exceed more than  item''s cases per pallet. Please check produce quantity.'
					,11
					,1
					)

			RETURN
		END

		SELECT @dblUpperToleranceQuantity = CASE 
				WHEN dblCalculatedUpperTolerance = 0
					THEN @dblRequiredQuantity
				ELSE dblCalculatedUpperTolerance * @dblRequiredQuantity / R.dblQuantity
				END
			,@dblLowerToleranceQuantity = CASE 
				WHEN dblCalculatedLowerTolerance = 0
					THEN @dblRequiredQuantity
				ELSE dblCalculatedLowerTolerance * @dblRequiredQuantity / R.dblQuantity
				END
		FROM dbo.tblMFWorkOrderRecipe R
		JOIN dbo.tblMFWorkOrderRecipeItem RI ON R.intRecipeId = RI.intRecipeId
			AND R.intWorkOrderId = RI.intWorkOrderId
		WHERE R.intItemId = @intProductId
			AND R.ysnActive = 1
			AND intRecipeItemTypeId = 2
			AND RI.intItemId = @intItemId
			AND R.intWorkOrderId = @intWorkOrderId

		IF @ysnIgnoreTolerance = 0
			AND @dblQuantity > @dblUpperToleranceQuantity
		BEGIN
			SELECT @strQuantity = @dblQuantity

			SELECT @strUpperToleranceQuantity = @dblUpperToleranceQuantity

			RAISERROR (
					'The attempted produce quantity of ''%s'' for material ''%s'' is more than the allowed production quantity with upper tolerance %s. The transaction will not be allowed to proceed.'
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
			SELECT @strQuantity = @dblQuantity

			SELECT @strLowerToleranceQuantity = @dblLowerToleranceQuantity

			RAISERROR (
					'The attempted produce quantity of ''%s'' for material ''%s'' is more than the allowed production quantity with lower tolerance %s. The transaction will not be allowed to proceed.'
					,11
					,1
					,@strQuantity
					,@strItemNo
					,@strLowerToleranceQuantity
					)

			RETURN
		END

		SELECT @intAttributeId = intAttributeId
		FROM tblMFAttribute
		WHERE strAttributeName = 'All input items mandatory for consumption'

		SELECT @strAllInputItemsMandatoryforConsumption = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = @intAttributeId

		IF @strAllInputItemsMandatoryforConsumption = 'True'
			AND @intProductionTypeId = 3
			AND EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrderRecipeItem ri
				LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem SI ON SI.intRecipeItemId = ri.intRecipeItemId
					AND ri.intWorkOrderId = SI.intWorkOrderId
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
					AND ri.intConsumptionMethodId <> 4
					AND NOT EXISTS (
						SELECT *
						FROM tblMFWorkOrderConsumedLot WC
						JOIN dbo.tblICLot L ON L.intLotId = WC.intLotId
						WHERE (
								L.intItemId = ri.intItemId
								OR L.intItemId = SI.intSubstituteItemId
								)
							AND WC.intWorkOrderId = @intWorkOrderId
						)
				)
		BEGIN
			RAISERROR (
					'The input lots for the item %s are expired / inactive / unavailable. Cannot produce.'
					,11
					,1
					)

			RETURN
		END

		IF @intMachineId IS NOT NULL
		BEGIN
			DECLARE @dblBatchSize NUMERIC(18, 6)
				,@intBatchSizeUOMId INT
				,@intUnitMeasureId INT

			SELECT @intUnitMeasureId = intUnitMeasureId
			FROM dbo.tblICItemUOM
			WHERE intItemUOMId = @intItemUOMId

			SELECT @dblBatchSize = dblBatchSize
				,@intBatchSizeUOMId = intBatchSizeUOMId
			FROM dbo.tblMFMachine
			WHERE intMachineId = @intMachineId

			IF @dblBatchSize IS NOT NULL
				AND @intBatchSizeUOMId IS NOT NULL
			BEGIN
				IF @intBatchSizeUOMId = @intUnitMeasureId
					AND @dblQuantity > @dblBatchSize
				BEGIN
					RAISERROR (
							'Entered quantity is greater than the configured batch size for the machine'
							,11
							,1
							)
				END
			END
		END

		IF @ysnLotAlias = 1
			AND @strLotAlias = ''
		BEGIN
			RAISERROR (
					'Lot Alias for Item ID ''%s'' Cannot be blank.'
					,11
					,1
					,@strItemNo
					)
		END

		IF @intWorkOrderId IS NULL
		BEGIN
			RAISERROR (
					51123
					,11
					,1
					,@strItemNo
					)
		END

		SELECT TOP 1 @intSampleStatusId = intSampleStatusId
			,@dtmSampleCreated = dtmCreated
		FROM tblQMSample
		WHERE intProductTypeId = 12
			AND intProductValueId = @intWorkOrderId
		ORDER BY dtmLastModified DESC

		IF @intSampleStatusId = 4
		BEGIN
			SELECT @strCellName = strCellName
			FROM tblMFManufacturingCell
			WHERE intManufacturingCellId = @intManufacturingCellId

			RAISERROR (
					'%s has failed the quality test. Cannot proceed further.'
					,11
					,1
					,@strCellName
					)
		END

		SELECT @strWIPSampleMandatory = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 84

		IF @strWIPSampleMandatory = 'True'
		BEGIN
			SELECT TOP 1 @intSampleStatusId = S.intSampleStatusId
				,@dtmSampleCreated = S.dtmCreated
			FROM tblQMSample S
			JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
			WHERE S.intProductTypeId = 12
				AND S.intProductValueId = @intWorkOrderId
				AND ST.intControlPointId = 12 --WIP Sample
			ORDER BY S.dtmLastModified DESC

			SELECT @intDurationBetweenLineSample = strAttributeValue
			FROM tblMFManufacturingProcessAttribute
			WHERE intManufacturingProcessId = @intManufacturingProcessId
				AND intLocationId = @intLocationId
				AND intAttributeId = 85

			IF @dtmSampleCreated IS NULL
			BEGIN
				SELECT @dtmSampleCreated = @dtmStartedDate
			END

			IF DateDiff(MINUTE, @dtmSampleCreated, GETDATE()) > @intDurationBetweenLineSample
			BEGIN
				SELECT @strCellName = strCellName
				FROM tblMFManufacturingCell
				WHERE intManufacturingCellId = @intManufacturingCellId

				RAISERROR (
						'Sample is not taken for the line %s for a while. Please take the sample and then produce the pallet'
						,11
						,1
						,@strCellName
						)
			END
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
