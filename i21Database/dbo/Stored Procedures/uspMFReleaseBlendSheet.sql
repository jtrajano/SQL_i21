CREATE PROCEDURE [dbo].[uspMFReleaseBlendSheet] @strXml NVARCHAR(Max)
	,@strWorkOrderNoOut NVARCHAR(50) = '' OUT
	,@dblBalancedQtyToProduceOut NUMERIC(38, 20) = 0 OUTPUT
	,@intWorkOrderIdOut INT = 0 OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @intWorkOrderId INT
	DECLARE @strNextWONo NVARCHAR(50)
	DECLARE @strDemandNo NVARCHAR(50)
	DECLARE @intBlendRequirementId INT
	DECLARE @ErrMsg NVARCHAR(Max)
	DECLARE @intLocationId INT
	DECLARE @intCellId INT
	DECLARE @intUserId INT
	DECLARE @dblQtyToProduce NUMERIC(38, 20)
	DECLARE @dtmDueDate DATETIME
	DECLARE @intExecutionOrder INT = 1
	DECLARE @intBlendItemId INT
	DECLARE @strBlendItemNo NVARCHAR(50)
	DECLARE @strBlendItemStatus NVARCHAR(50)
	DECLARE @strInputItemNo NVARCHAR(50)
	DECLARE @strInputItemStatus NVARCHAR(50)
	DECLARE @ysnEnableParentLot BIT = 0
	DECLARE @intRecipeId INT
	DECLARE @intManufacturingProcessId INT
	DECLARE @dblBinSize NUMERIC(38, 20)
	DECLARE @intNoOfSheet INT
	DECLARE @intNoOfSheetOriginal INT
	DECLARE @dblRemainingQtyToProduce NUMERIC(38, 20)
	DECLARE @PerBlendSheetQty NUMERIC(38, 20)
	DECLARE @ysnCalculateNoSheetUsingBinSize BIT = 0
	DECLARE @ysnKittingEnabled BIT
	DECLARE @ysnRequireCustomerApproval BIT
	DECLARE @intWorkOrderStatusId INT
	DECLARE @intKitStatusId INT = NULL
	DECLARE @dblBulkReqQuantity NUMERIC(38, 20)
	DECLARE @dblPlannedQuantity NUMERIC(38, 20)
	DECLARE @ysnAllInputItemsMandatory BIT
		,@dtmBusinessDate DATETIME
		,@intBusinessShiftId INT
		,@dtmCurrentDateTime DATETIME
		,@dtmProductionDate DATETIME
		,@intMachineId INT
		,@dblWeightPerUnit NUMERIC(38, 20)
		,@ysnMinorIngredient BIT
		,@dblSuggestedCeilingQty DECIMAL(38, 20)
		,@dblSuggestedFloorQty DECIMAL(38, 20)
		,@dblCeilingQtyDiff DECIMAL(38, 20)
		,@dblFloorQtyDiff DECIMAL(38, 20)
		,@dblOriginalRequiredQty DECIMAL(38, 20)
		,@dblQty1 DECIMAL(38, 20)
		,@intRowNo INT
	DECLARE @intCategoryId INT
	DECLARE @strInActiveItems NVARCHAR(max)
	DECLARE @dtmDate DATETIME = Convert(DATE, GetDate())
	DECLARE @intDayOfYear INT = DATEPART(dy, @dtmDate)
	DECLARE @strPackagingCategoryId NVARCHAR(Max)
	DECLARE @intPlannedShiftId INT
	DECLARE @strSavedWONo NVARCHAR(50)
		,@intSubLocationId INT
		,@intIssuedUOMTypeId INT
		,@dblQuantity NUMERIC(18, 6)
		,@dblIssuedQuantity NUMERIC(18, 6)
		,@intItemIssuedUOMId INT
		,@intItemUOMId INT
		,@dblPickedQty NUMERIC(38, 20)
		,@intSeq INT
		,@dblTotalPickedQty NUMERIC(38, 20)
		,@intMinRowNo INT
		,@ysnComplianceItem BIT
		,@dblCompliancePercent NUMERIC(38, 20)
		,@sRequiredQty NUMERIC(18, 6)
		,@ysnPercResetRequired BIT = 0
		,@dblQuantityTaken NUMERIC(18, 6)
		,@dblPercentageIncrease NUMERIC(18, 6)
	DECLARE @tblInputItemSeq TABLE (
		intItemId INT
		,intSeq INT
		)

	SELECT @dtmCurrentDateTime = GetDate()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	BEGIN TRAN

	DECLARE @tblBlendSheet TABLE (
		intWorkOrderId INT
		,intItemId INT
		,intCellId INT
		,intMachineId INT
		,dtmDueDate DATETIME
		,dblQtyToProduce NUMERIC(38, 20)
		,dblPlannedQuantity NUMERIC(38, 20)
		,dblBinSize NUMERIC(38, 20)
		,strComment NVARCHAR(Max)
		,ysnUseTemplate BIT
		,ysnKittingEnabled BIT
		,ysnDietarySupplements BIT
		,intLocationId INT
		,intBlendRequirementId INT
		,intItemUOMId INT
		,intUserId INT
		,intPlannedShiftId INT
		)
	DECLARE @tblPreItem TABLE (
		intRowNo INT Identity(1, 1)
		,intItemId INT
		,dblReqQty NUMERIC(38, 20)
		,ysnIsSubstitute BIT
		,intConsumptionMethodId INT
		,intConsumptionStoragelocationId INT
		,intParentItemId INT
		,dblUpperToleranceQty NUMERIC(38, 20)
		,dblLowerToleranceQty NUMERIC(38, 20)
		,ysnComplianceItem BIT
		,dblCompliancePercent NUMERIC(38, 20)
		,dblPickedQty NUMERIC(38, 20)
		,ysnMinorIngredient BIT
		)
	DECLARE @tblItem TABLE (
		intRowNo INT Identity(1, 1)
		,intItemId INT
		,dblReqQty NUMERIC(38, 20)
		,ysnIsSubstitute BIT
		,intConsumptionMethodId INT
		,intConsumptionStoragelocationId INT
		,intParentItemId INT
		,dblUpperToleranceQty NUMERIC(38, 20)
		,dblLowerToleranceQty NUMERIC(38, 20)
		,ysnComplianceItem BIT
		,dblCompliancePercent NUMERIC(38, 20)
		,dblPickedQty NUMERIC(38, 20)
		,ysnMinorIngredient BIT
		)
	DECLARE @tblPreLot TABLE (
		intRowNo INT Identity(1, 1)
		,intLotId INT
		,intItemId INT
		,dblQty NUMERIC(38, 20)
		,dblIssuedQuantity NUMERIC(38, 20)
		,dblWeightPerUnit NUMERIC(38, 20)
		,intItemUOMId INT
		,intItemIssuedUOMId INT
		,intUserId INT
		,intRecipeItemId INT
		,intLocationId INT
		,intStorageLocationId INT
		,ysnParentLot BIT
		,dtmDateCreated DATETIME
		)
	DECLARE @tblLot TABLE (
		intRowNo INT Identity(1, 1)
		,intLotId INT
		,intItemId INT
		,dblQty NUMERIC(38, 20)
		,dblIssuedQuantity NUMERIC(38, 20)
		,dblWeightPerUnit NUMERIC(38, 20)
		,intItemUOMId INT
		,intItemIssuedUOMId INT
		,intUserId INT
		,intRecipeItemId INT
		,intLocationId INT
		,intStorageLocationId INT
		,ysnParentLot BIT
		,dtmDateCreated DATETIME
		)
	DECLARE @tblBSLot TABLE (
		intLotId INT
		,intItemId INT
		,dblQty NUMERIC(38, 20)
		,intUOMId INT
		,dblIssuedQuantity NUMERIC(38, 20)
		,intIssuedUOMId INT
		,dblWeightPerUnit NUMERIC(38, 20)
		,intRecipeItemId INT
		,intLocationId INT
		,intStorageLocationId INT
		)

	INSERT INTO @tblBlendSheet (
		intWorkOrderId
		,intItemId
		,intCellId
		,intMachineId
		,dtmDueDate
		,dblQtyToProduce
		,dblPlannedQuantity
		,dblBinSize
		,strComment
		,ysnUseTemplate
		,ysnKittingEnabled
		,ysnDietarySupplements
		,intLocationId
		,intBlendRequirementId
		,intItemUOMId
		,intUserId
		,intPlannedShiftId
		)
	SELECT intWorkOrderId
		,intItemId
		,intCellId
		,intMachineId
		,dtmDueDate
		,dblQtyToProduce
		,dblPlannedQuantity
		,dblBinSize
		,strComment
		,ysnUseTemplate
		,ysnKittingEnabled
		,ysnDietarySupplements
		,intLocationId
		,intBlendRequirementId
		,intItemUOMId
		,intUserId
		,intPlannedShiftId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intItemId INT
			,intCellId INT
			,intMachineId INT
			,dtmDueDate DATETIME
			,dblQtyToProduce NUMERIC(38, 20)
			,dblPlannedQuantity NUMERIC(38, 20)
			,dblBinSize NUMERIC(38, 20)
			,strComment NVARCHAR(Max)
			,ysnUseTemplate BIT
			,ysnKittingEnabled BIT
			,ysnDietarySupplements BIT
			,intLocationId INT
			,intBlendRequirementId INT
			,intItemUOMId INT
			,intUserId INT
			,intPlannedShiftId INT
			)

	INSERT INTO @tblPreLot (
		intLotId
		,intItemId
		,dblQty
		,dblIssuedQuantity
		,dblWeightPerUnit
		,intItemUOMId
		,intItemIssuedUOMId
		,intUserId
		,intRecipeItemId
		,intLocationId
		,intStorageLocationId
		,ysnParentLot
		)
	SELECT x.intLotId
		,x.intItemId
		,x.dblQty
		,x.dblIssuedQuantity
		,x.dblWeightPerUnit
		,x.intItemUOMId
		,x.intItemIssuedUOMId
		,x.intUserId
		,x.intRecipeItemId
		,x.intLocationId
		,x.intStorageLocationId
		,x.ysnParentLot
	FROM OPENXML(@idoc, 'root/lot', 2) WITH (
			intLotId INT
			,intItemId INT
			,dblQty NUMERIC(38, 20)
			,dblIssuedQuantity NUMERIC(38, 20)
			,dblPickedQuantity NUMERIC(38, 20)
			,dblWeightPerUnit NUMERIC(38, 20)
			,intItemUOMId INT
			,intItemIssuedUOMId INT
			,intUserId INT
			,intRecipeItemId INT
			,intLocationId INT
			,intStorageLocationId INT
			,ysnParentLot BIT
			) x

	UPDATE a
	SET a.dtmDateCreated = (
			SELECT TOP 1 L.dtmDateCreated
			FROM tblICLot L
			WHERE L.intParentLotId = a.intLotId
				AND L.intStorageLocationId = a.intStorageLocationId
				AND L.dblWeight > 0
			ORDER BY intLotId DESC
			)
	FROM @tblPreLot a

	INSERT INTO @tblLot (
		intLotId
		,intItemId
		,dblQty
		,dblIssuedQuantity
		,dblWeightPerUnit
		,intItemUOMId
		,intItemIssuedUOMId
		,intUserId
		,intRecipeItemId
		,intLocationId
		,intStorageLocationId
		,ysnParentLot
		)
	SELECT intLotId
		,intItemId
		,dblQty
		,dblIssuedQuantity
		,dblWeightPerUnit
		,intItemUOMId
		,intItemIssuedUOMId
		,intUserId
		,intRecipeItemId
		,intLocationId
		,intStorageLocationId
		,ysnParentLot
	FROM @tblPreLot
	ORDER BY dtmDateCreated

	--Available Qty Check
	DECLARE @tblLotSummary AS TABLE (
		intRowNo INT IDENTITY
		,intLotId INT
		,intItemId INT
		,dblQty NUMERIC(38, 20)
		,intRecipeItemId INT
		)
	DECLARE @dblInputAvlQty NUMERIC(38, 20)
	DECLARE @dblInputReqQty NUMERIC(38, 20)
	DECLARE @intInputLotId INT
	DECLARE @intInputItemId INT
	DECLARE @strInputLotNumber NVARCHAR(50)

	SELECT @intLocationId = intLocationId
	FROM @tblBlendSheet

	SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
	FROM tblMFCompanyPreference

	INSERT INTO @tblLotSummary (
		intLotId
		,intItemId
		,dblQty
		)
	SELECT intLotId
		,intItemId
		,SUM(dblQty)
	FROM @tblLot
	GROUP BY intLotId
		,intItemId

	DECLARE @intMinLot INT

	SELECT @intMinLot = Min(intRowNo)
	FROM @tblLotSummary

	WHILE (@intMinLot IS NOT NULL)
		AND @ysnEnableParentLot = 0
	BEGIN
		SELECT @intInputLotId = intLotId
			,@dblInputReqQty = dblQty
			,@intInputItemId = intItemId
		FROM @tblLotSummary
		WHERE intRowNo = @intMinLot

		SELECT @dblInputAvlQty = CASE 
				WHEN isnull(l.dblWeight, 0) > 0
					THEN l.dblWeight
				ELSE dbo.fnMFConvertQuantityToTargetItemUOM(l.intItemUOMId, tl.intItemUOMId, l.dblQty)
				END - (
				SELECT ISNULL(SUM(ISNULL(dblQty, 0)), 0)
				FROM tblICStockReservation
				WHERE intLotId = @intInputLotId
					AND ISNULL(ysnPosted, 0) = 0
				)
		FROM tblICLot l
		JOIN @tblLot tl ON l.intLotId = tl.intLotId
		WHERE l.intLotId = @intInputLotId

		IF @dblInputReqQty > @dblInputAvlQty
		BEGIN
			SELECT @strInputLotNumber = strLotNumber
			FROM tblICLot
			WHERE intLotId = @intInputLotId

			SELECT @strInputItemNo = strItemNo
			FROM tblICItem
			WHERE intItemId = @intInputItemId

			SET @ErrMsg = 'Quantity of ' + CONVERT(VARCHAR, @dblInputReqQty) + ' from lot ' + @strInputLotNumber + ' of item ' + CONVERT(NVARCHAR, @strInputItemNo) + + ' cannot be added to blend sheet because the lot has available qty of ' + CONVERT(VARCHAR, @dblInputAvlQty) + '.'

			RAISERROR (
					@ErrMsg
					,16
					,1
					)
		END

		SELECT @intMinLot = Min(intRowNo)
		FROM @tblLotSummary
		WHERE intRowNo > @intMinLot
	END

	--End Available Qty Check
	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDateTime, @intLocationId)

	SELECT @intBusinessShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	SELECT @intRecipeId = intRecipeId
		,@intManufacturingProcessId = a.intManufacturingProcessId
	FROM tblMFRecipe a
	JOIN @tblBlendSheet b ON a.intItemId = b.intItemId
		AND a.intLocationId = b.intLocationId
		AND ysnActive = 1

	SELECT @strPackagingCategoryId = ISNULL(pa.strAttributeValue, '')
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND at.strAttributeName = 'Packaging Category'

	UPDATE @tblBlendSheet
	SET dblQtyToProduce = (
			SELECT sum(dblQty)
			FROM @tblLot l
			JOIN tblICItem i ON l.intItemId = i.intItemId
			WHERE i.intCategoryId NOT IN (
					SELECT *
					FROM dbo.[fnCommaSeparatedValueToTable](@strPackagingCategoryId)
					)
			)

	UPDATE @tblLot
	SET intStorageLocationId = NULL
	WHERE intStorageLocationId = 0

	SELECT @dblQtyToProduce = dblQtyToProduce
		,@intUserId = intUserId
		,@intLocationId = intLocationId
		,@dtmDueDate = dtmDueDate
		,@intBlendItemId = intItemId
		,@intCellId = intCellId
		,@intBlendRequirementId = intBlendRequirementId
		,@dblBinSize = dblBinSize
		,@intWorkOrderId = intWorkOrderId
		,@ysnKittingEnabled = ysnKittingEnabled
		,@dblPlannedQuantity = dblPlannedQuantity
		,@intMachineId = intMachineId
	FROM @tblBlendSheet

	SELECT @strDemandNo = strDemandNo
	FROM tblMFBlendRequirement
	WHERE intBlendRequirementId = @intBlendRequirementId

	SELECT @intSubLocationId = NULL

	SELECT @intSubLocationId = intSubLocationId
	FROM tblMFManufacturingCell
	WHERE intManufacturingCellId = @intCellId

	SELECT @strBlendItemNo = strItemNo
		,@strBlendItemStatus = strStatus
		,@ysnRequireCustomerApproval = ysnRequireCustomerApproval
		,@intCategoryId = intCategoryId
	FROM tblICItem
	WHERE intItemId = @intBlendItemId

	--If @ysnKittingEnabled=1 And (@ysnEnableParentLot=0 OR (Select TOP 1 ysnParentLot From @tblLot) = 0 )
	--	Begin
	--		Set @ErrMsg='Please enable Parent Lot for Kitting.'
	--		RaisError(@ErrMsg,16,1)
	--	End
	IF @ysnKittingEnabled = 1
		SET @intKitStatusId = 6

	IF @ysnRequireCustomerApproval = 1
		SET @intWorkOrderStatusId = 5 --Hold
	ELSE
		SET @intWorkOrderStatusId = 9 --Released

	IF (@strBlendItemStatus <> 'Active')
	BEGIN
		SET @ErrMsg = 'The blend item ' + @strBlendItemNo + ' is not active, cannot release the blend sheet.'

		RAISERROR (
				@ErrMsg
				,16
				,1
				)
	END

	SELECT TOP 1 @strInputItemNo = strItemNo
		,@strInputItemStatus = strStatus
	FROM @tblLot l
	JOIN tblICItem i ON l.intItemId = i.intItemId
	WHERE strStatus <> 'Active'

	IF @strInputItemNo IS NOT NULL
	BEGIN
		SET @ErrMsg = 'The input item ' + @strInputItemNo + ' is not active, cannot release the blend sheet.'

		RAISERROR (
				@ErrMsg
				,16
				,1
				)
	END

	IF @ysnEnableParentLot = 0
		UPDATE a
		SET a.dblWeightPerUnit = CASE 
				WHEN b.dblWeightPerQty > 0
					THEN b.dblWeightPerQty
				ELSE iu1.dblUnitQty / iu.dblUnitQty
				END
		FROM @tblLot a
		JOIN tblICLot b ON a.intLotId = b.intLotId
		LEFT JOIN tblICItemUOM iu ON a.intItemUOMId = iu.intItemUOMId
		LEFT JOIN tblICItemUOM iu1 ON a.intItemIssuedUOMId = iu1.intItemUOMId
	ELSE
		UPDATE a
		SET a.dblWeightPerUnit = (
				SELECT TOP 1 L.dblWeightPerQty
				FROM tblICLot L
				WHERE L.intParentLotId = a.intLotId
					AND L.intStorageLocationId = a.intStorageLocationId
					AND L.dblWeight > 0
				ORDER BY intLotId DESC
				)
			,a.dtmDateCreated = (
				SELECT TOP 1 L.dtmDateCreated
				FROM tblICLot L
				WHERE L.intParentLotId = a.intLotId
					AND L.intStorageLocationId = a.intStorageLocationId
					AND L.dblWeight > 0
				ORDER BY intLotId DESC
				)
		FROM @tblLot a

	SELECT @ysnCalculateNoSheetUsingBinSize = CASE 
			WHEN UPPER(pa.strAttributeValue) = 'TRUE'
				THEN 1
			ELSE 0
			END
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND at.strAttributeName = 'Calculate No Of Blend Sheet Using Blend Bin Size'

	SELECT @ysnAllInputItemsMandatory = CASE 
			WHEN UPPER(pa.strAttributeValue) = 'TRUE'
				THEN 1
			ELSE 0
			END
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND UPPER(at.strAttributeName) = UPPER('All input items mandatory for consumption')

	SELECT @intPlannedShiftId = intPlannedShiftId
	FROM @tblBlendSheet

	IF ISNULL(@intPlannedShiftId, 0) = 0
	BEGIN
		IF ISNULL(@intBusinessShiftId, 0) = 0
		BEGIN
			SELECT @intPlannedShiftId = intShiftId
			FROM dbo.tblMFShift
			WHERE intLocationId = @intLocationId
				AND intShiftSequence = 1
		END
		ELSE
			SET @intPlannedShiftId = @intBusinessShiftId

		UPDATE @tblBlendSheet
		SET intPlannedShiftId = @intPlannedShiftId
	END

	--Missing Item Check / Required Qty Check
	IF @ysnAllInputItemsMandatory = 1
	BEGIN
		INSERT INTO @tblPreItem (
			intItemId
			,dblReqQty
			,ysnIsSubstitute
			,intConsumptionMethodId
			,intConsumptionStoragelocationId
			,intParentItemId
			,dblUpperToleranceQty
			,dblLowerToleranceQty
			,ysnMinorIngredient
			)
		SELECT ri.intItemId
			,(ri.dblCalculatedQuantity * (@dblPlannedQuantity / r.dblQuantity)) AS RequiredQty
			,0 AS ysnIsSubstitute
			,ri.intConsumptionMethodId
			,ri.intStorageLocationId
			,0
			,(ri.dblCalculatedUpperTolerance * (@dblPlannedQuantity / r.dblQuantity)) AS dblUpperToleranceQty
			,(ri.dblCalculatedLowerTolerance * (@dblPlannedQuantity / r.dblQuantity)) AS dblLowerToleranceQty
			,(
				CASE 
					WHEN (ri.dblCalculatedQuantity / SUM(ri.dblCalculatedQuantity) OVER ()) * 100 <= 10
						THEN 1
					ELSE 0
					END
				) AS ysnMinorIngredient
		FROM tblMFRecipeItem ri
		JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		WHERE ri.intRecipeId = @intRecipeId
			AND ri.intRecipeItemTypeId = 1
			AND (
				(
					ri.ysnYearValidationRequired = 1
					AND @dtmDate BETWEEN ri.dtmValidFrom
						AND ri.dtmValidTo
					)
				OR (
					ri.ysnYearValidationRequired = 0
					AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
						AND DATEPART(dy, ri.dtmValidTo)
					)
				)
			AND ri.intConsumptionMethodId IN (
				1
				,2
				,3
				)
		
		UNION
		
		SELECT rs.intSubstituteItemId
			,(rs.dblQuantity * (@dblPlannedQuantity / r.dblQuantity)) AS RequiredQty
			,1 AS ysnIsSubstitute
			,0
			,0
			,rs.intItemId
			,(ri.dblCalculatedUpperTolerance * (@dblPlannedQuantity / r.dblQuantity)) AS dblUpperToleranceQty
			,(ri.dblCalculatedLowerTolerance * (@dblPlannedQuantity / r.dblQuantity)) AS dblLowerToleranceQty
			,(
				CASE 
					WHEN (ri.dblCalculatedQuantity / SUM(ri.dblCalculatedQuantity) OVER ()) * 100 <= 10
						THEN 1
					ELSE 0
					END
				) AS ysnMinorIngredient
		FROM tblMFRecipeSubstituteItem rs
		JOIN tblMFRecipeItem ri ON ri.intRecipeItemId = rs.intRecipeItemId
		JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
		WHERE rs.intRecipeId = @intRecipeId
			AND rs.intRecipeItemTypeId = 1
		ORDER BY 2 DESC
			,ysnIsSubstitute
			,ysnMinorIngredient

		DECLARE @intMinMissingItem INT
		DECLARE @intConsumptionMethodId INT
		DECLARE @dblInputItemBSQty NUMERIC(38, 20)
		DECLARE @dblBulkItemAvlQty NUMERIC(38, 20)
		DECLARE @dblLowerToleranceQty NUMERIC(38, 20)
		DECLARE @dblUpperToleranceQty NUMERIC(38, 20)

		SELECT @intMinMissingItem = Min(intRowNo)
		FROM @tblPreItem

		WHILE (@intMinMissingItem IS NOT NULL)
		BEGIN
			SELECT @dblLowerToleranceQty = NULL
				,@dblUpperToleranceQty = NULL

			SELECT @intInputItemId = intItemId
				,@dblInputReqQty = dblReqQty
				,@intConsumptionMethodId = intConsumptionMethodId
				,@dblLowerToleranceQty = dblLowerToleranceQty
				,@dblUpperToleranceQty = dblUpperToleranceQty
			FROM @tblPreItem
			WHERE intRowNo = @intMinMissingItem
				AND ysnIsSubstitute = 0

			IF @intConsumptionMethodId = 1
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM @tblLot
						WHERE intItemId = @intInputItemId
						)
					AND NOT EXISTS (
						SELECT 1
						FROM @tblLot
						WHERE intItemId = (
								SELECT intItemId
								FROM @tblItem
								WHERE intParentItemId = @intInputItemId
								)
						)
				BEGIN
					SELECT @strInputItemNo = strItemNo
					FROM tblICItem
					WHERE intItemId = @intInputItemId

					SET @ErrMsg = 'There is no lot selected for item ' + CONVERT(NVARCHAR, @strInputItemNo) + '.'

					RAISERROR (
							@ErrMsg
							,16
							,1
							)
				END

				SELECT @dblInputItemBSQty = ISNULL(SUM(ISNULL(dblQty, 0)), 0)
				FROM @tblLot
				WHERE intItemId = @intInputItemId

				--Include Sub Items
				SET @dblInputItemBSQty = @dblInputItemBSQty + (
						SELECT ISNULL(SUM(ISNULL(dblQty, 0)), 0)
						FROM @tblLot
						WHERE intItemId IN (
								SELECT intItemId
								FROM @tblItem
								WHERE intParentItemId = @intInputItemId
								)
						)

				IF @dblInputItemBSQty < @dblLowerToleranceQty
				BEGIN
					SELECT @strInputItemNo = strItemNo
					FROM tblICItem
					WHERE intItemId = @intInputItemId

					SET @ErrMsg = 'Selected quantity of ' + [dbo].[fnRemoveTrailingZeroes](@dblInputItemBSQty) + ' of item ' + CONVERT(NVARCHAR, @strInputItemNo) + + ' is less than the lower tolerance quantity of ' + [dbo].[fnRemoveTrailingZeroes](@dblLowerToleranceQty) + '.'

					RAISERROR (
							@ErrMsg
							,16
							,1
							)
				END

				IF @dblInputItemBSQty > @dblUpperToleranceQty
				BEGIN
					SELECT @strInputItemNo = strItemNo
					FROM tblICItem
					WHERE intItemId = @intInputItemId

					SET @ErrMsg = 'Selected quantity of ' + [dbo].[fnRemoveTrailingZeroes](@dblInputItemBSQty) + ' of item ' + CONVERT(NVARCHAR, @strInputItemNo) + + ' is more than the upper tolerance quantity of ' + [dbo].[fnRemoveTrailingZeroes](@dblUpperToleranceQty) + '.'

					RAISERROR (
							@ErrMsg
							,16
							,1
							)
				END
			END

			--Bulk
			IF @intConsumptionMethodId IN (
					2
					,3
					)
			BEGIN
				SELECT @dblBulkItemAvlQty = ISNULL(SUM(ISNULL(dblWeight, 0)), 0)
				FROM tblICLot l
				JOIN tblICLotStatus ls ON l.intLotStatusId = ls.intLotStatusId
				WHERE l.intItemId = @intInputItemId
					AND l.intLocationId = @intLocationId
					AND ls.strPrimaryStatus IN (
						'Active'
						,'Quarantine'
						)
					AND (
						l.dtmExpiryDate IS NULL
						OR l.dtmExpiryDate >= GETDATE()
						)
					AND l.dblWeight > 0

				--Iclude Sub Items
				SET @dblBulkItemAvlQty = @dblBulkItemAvlQty + (
						SELECT ISNULL(SUM(ISNULL(dblWeight, 0)), 0)
						FROM tblICLot l
						JOIN tblICLotStatus ls ON l.intLotStatusId = ls.intLotStatusId
						WHERE l.intItemId IN (
								SELECT intItemId
								FROM @tblItem
								WHERE intParentItemId = @intInputItemId
								)
							AND l.intLocationId = @intLocationId
							AND ls.strPrimaryStatus IN (
								'Active'
								,'Quarantine'
								)
							AND (
								l.dtmExpiryDate IS NULL
								OR l.dtmExpiryDate >= GETDATE()
								)
							AND l.dblWeight > 0
						)

				IF @dblBulkItemAvlQty < @dblInputReqQty
				BEGIN
					SELECT @strInputItemNo = strItemNo
					FROM tblICItem
					WHERE intItemId = @intInputItemId

					SET @ErrMsg = 'Required quantity of ' + CONVERT(VARCHAR, @dblInputReqQty) + ' of bulk item ' + CONVERT(NVARCHAR, @strInputItemNo) + + ' is not avaliable.'

					RAISERROR (
							@ErrMsg
							,16
							,1
							)
				END
			END

			SELECT @intMinMissingItem = Min(intRowNo)
			FROM @tblPreItem
			WHERE intRowNo > @intMinMissingItem
				AND ysnIsSubstitute = 0
		END
	END

	IF @ysnCalculateNoSheetUsingBinSize = 0
	BEGIN
		SET @intNoOfSheet = 1
		SET @PerBlendSheetQty = @dblQtyToProduce
		SET @intNoOfSheetOriginal = @intNoOfSheet
	END
	ELSE
	BEGIN
		IF Ceiling(@dblPlannedQuantity / @dblBinSize) = 1
		BEGIN
			SET @intNoOfSheet = 1
			SET @PerBlendSheetQty = @dblBinSize
			SET @intNoOfSheetOriginal = 1
		END
		ELSE
		BEGIN
			SET @intNoOfSheet = Ceiling(Convert(DECIMAL(18, 1), @dblPlannedQuantity / @dblBinSize))
			SET @PerBlendSheetQty = @dblBinSize
			SET @intNoOfSheetOriginal = @intNoOfSheet
		END
	END

	IF EXISTS (
			SELECT 1
			FROM tblMFWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId
			)
	BEGIN
		SELECT @strSavedWONo = strWorkOrderNo
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		DELETE
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId
	END

	DECLARE @intItemCount INT
		,@intLotCount INT
		,@intItemId INT
		,@dblReqQty NUMERIC(38, 20)
		,@intLotId INT
		,@dblQty NUMERIC(38, 20)

	SELECT @intExecutionOrder = Count(1)
	FROM tblMFWorkOrder
	WHERE intManufacturingCellId = @intCellId
		AND convert(DATE, dtmExpectedDate) = convert(DATE, @dtmDueDate)
		AND intBlendRequirementId IS NOT NULL
		AND intStatusId NOT IN (
			2
			,13
			)

	WHILE (
			@intNoOfSheet > 0
			AND @dblQtyToProduce > 1
			)
	BEGIN
		SET @intWorkOrderId = NULL
		SELECT @ysnPercResetRequired = 0

		--Calculate Required Quantity by Item
		IF (@dblQtyToProduce > @PerBlendSheetQty)
			SELECT @PerBlendSheetQty = @PerBlendSheetQty
		ELSE
			SELECT @PerBlendSheetQty = @dblQtyToProduce

		IF @intNoOfSheet = 1
			AND @intNoOfSheetOriginal = @intNoOfSheet
		BEGIN
			INSERT INTO @tblBSLot (
				intLotId
				,intItemId
				,dblQty
				,intUOMId
				,dblIssuedQuantity
				,intIssuedUOMId
				,dblWeightPerUnit
				,intRecipeItemId
				,intLocationId
				,intStorageLocationId
				)
			SELECT intLotId
				,intItemId
				,dblQty
				,intItemUOMId
				,dblIssuedQuantity
				,intItemIssuedUOMId
				,dblWeightPerUnit
				,intRecipeItemId
				,intLocationId
				,intStorageLocationId
			FROM @tblLot
			WHERE dblQty > 0
		END
		ELSE
		BEGIN
			SELECT @intIssuedUOMTypeId = ISNULL(intIssuedUOMTypeId, 0)
			FROM tblMFMachine
			WHERE intMachineId = @intMachineId

			IF ISNULL(@intIssuedUOMTypeId, 0) = 0
			BEGIN
				SET @intIssuedUOMTypeId = 1
			END

			DELETE
			FROM @tblItem

			INSERT INTO @tblItem (
				intItemId
				,dblReqQty
				,dblUpperToleranceQty
				,dblLowerToleranceQty
				,ysnComplianceItem
				,dblCompliancePercent
				,ysnMinorIngredient
				)
			SELECT ri.intItemId
				,(ri.dblCalculatedQuantity * (@PerBlendSheetQty / r.dblQuantity)) AS RequiredQty
				,(ri.dblCalculatedUpperTolerance * (@PerBlendSheetQty / r.dblQuantity)) AS dblCalculatedUpperTolerance
				,(ri.dblCalculatedLowerTolerance * (@PerBlendSheetQty / r.dblQuantity)) AS dblCalculatedLowerTolerance
				,ri.ysnComplianceItem
				,ri.dblCompliancePercent
				,(
					CASE 
						WHEN (ri.dblCalculatedQuantity / SUM(ri.dblCalculatedQuantity) OVER ()) * 100 <= 10
							THEN 1
						ELSE 0
						END
					) AS ysnMinorIngredient
			FROM tblMFRecipeItem ri
			JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
			WHERE ri.intRecipeId = @intRecipeId
				AND ri.intRecipeItemTypeId = 1
			
			UNION
			
			SELECT rs.intSubstituteItemId
				,(rs.dblQuantity * (@PerBlendSheetQty / r.dblQuantity)) AS RequiredQty
				,(ri.dblCalculatedUpperTolerance * (@PerBlendSheetQty / r.dblQuantity)) AS dblCalculatedUpperTolerance
				,(ri.dblCalculatedLowerTolerance * (@PerBlendSheetQty / r.dblQuantity)) AS dblCalculatedLowerTolerance
				,ri.ysnComplianceItem
				,ri.dblCompliancePercent
				,(
					CASE 
						WHEN (ri.dblCalculatedQuantity / SUM(ri.dblCalculatedQuantity) OVER ()) * 100 <= 10
							THEN 1
						ELSE 0
						END
					) AS ysnMinorIngredient
			FROM tblMFRecipeSubstituteItem rs
			JOIN tblMFRecipeItem ri ON ri.intRecipeItemId = rs.intRecipeItemId
				AND ri.intRecipeId = rs.intRecipeId
			JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
			WHERE rs.intRecipeId = @intRecipeId
				AND rs.intRecipeItemTypeId = 1
			ORDER BY 2 DESC
				,ysnMinorIngredient

			UPDATE @tblItem
			SET dblPickedQty = dblReqQty

			SELECT @intItemCount = Min(intRowNo)
			FROM @tblItem

			WHILE (@intItemCount IS NOT NULL)
			BEGIN
				SET @intLotCount = NULL
				SET @strNextWONo = NULL

				SELECT @dblUpperToleranceQty = NULL

				SELECT @dblLowerToleranceQty = NULL

				SELECT @ysnComplianceItem = NULL

				SELECT @dblCompliancePercent = NULL
					,@intItemId = NULL
					,@dblReqQty = NULL
					,@ysnMinorIngredient = NULL

				SELECT @dblOriginalRequiredQty = NULL

				SELECT @intItemId = intItemId
					,@dblReqQty = dblReqQty
					,@dblUpperToleranceQty = dblUpperToleranceQty
					,@dblLowerToleranceQty = dblLowerToleranceQty
					,@ysnComplianceItem = ysnComplianceItem
					,@dblCompliancePercent = dblCompliancePercent
					,@ysnMinorIngredient = ysnMinorIngredient
				FROM @tblItem
				WHERE intRowNo = @intItemCount

				SELECT @dblOriginalRequiredQty = @dblReqQty

				IF @ysnMinorIngredient = 1
				BEGIN
					IF @ysnPercResetRequired = 0
					BEGIN
						SELECT @sRequiredQty = NULL

						SELECT @sRequiredQty = SUM(dblReqQty)
						FROM @tblItem
						WHERE ysnMinorIngredient = 0

						SELECT @dblQuantityTaken = NULL

						SELECT @dblQuantityTaken = Sum(dblQty)
						FROM @tblBSLot BS
						JOIN @tblItem I ON I.intItemId = BS.intItemId
						WHERE I.ysnMinorIngredient = 0

						IF @dblQuantityTaken > @sRequiredQty
						BEGIN
							SET @dblPercentageIncrease = (@dblQuantityTaken - @sRequiredQty) / @sRequiredQty * 100

							SELECT @ysnPercResetRequired = 1
						END
					END

					IF ISNULL(@dblPercentageIncrease, 0) > 0
					BEGIN
						SET @dblReqQty = (@dblReqQty + (@dblReqQty * ISNULL(@dblPercentageIncrease, 0) / 100))
					END
				END

				UPDATE @tblItem
				SET dblPickedQty = 0
				WHERE intItemId = @intItemId

				SELECT @intLotCount = Min(intRowNo)
				FROM @tblLot
				WHERE intItemId = @intItemId
					AND dblQty > 0

				WHILE (@intLotCount IS NOT NULL)
				BEGIN
					SELECT @intLotId = NULL
						,@dblQty = NULL
						,@dblWeightPerUnit = NULL
						,@intItemUOMId = NULL
						,@intItemIssuedUOMId = NULL

					SELECT @dblQuantity = NULL

					SELECT @intLotId = intLotId
						,@dblQty = dblQty
						,@dblWeightPerUnit = dblWeightPerUnit
						,@intItemUOMId = intItemUOMId
						,@intItemIssuedUOMId = intItemIssuedUOMId
					FROM @tblLot
					WHERE intRowNo = @intLotCount

					IF @intIssuedUOMTypeId IN (
							2
							,3
							)
						AND @ysnMinorIngredient = 0 --'BAG' & 'Weight and Pack' 
					BEGIN
						IF @dblQty - @dblWeightPerUnit < 0
						BEGIN
							SET @dblWeightPerUnit = @dblQty
						END
						ELSE
						BEGIN
							IF @dblWeightPerUnit - (@dblQty % @dblWeightPerUnit) < 0.01
							BEGIN
								SET @dblQty = @dblQty
							END
							ELSE
							BEGIN
								SET @dblQty = @dblQty - (@dblQty % @dblWeightPerUnit)
							END
						END
					END

					IF (
							@dblQty >= @dblReqQty
							AND @intNoOfSheet > 1
							)
					BEGIN
						IF @ysnMinorIngredient = 0
						BEGIN
							SELECT @dblQuantity = @dblReqQty
								,@dblIssuedQuantity = @dblReqQty
								,@intItemIssuedUOMId = (
									CASE 
										WHEN @intIssuedUOMTypeId IN (
												2
												,3
												)
											THEN @intItemIssuedUOMId
										ELSE @intItemUOMId
										END
									)

							IF @intIssuedUOMTypeId = 2
							BEGIN
								SELECT @dblPickedQty = NULL

								SELECT @dblPickedQty = dblPickedQty
								FROM @tblItem
								WHERE intItemId = @intItemId

								SELECT @dblSuggestedCeilingQty = 0

								SELECT @dblSuggestedCeilingQty = Convert(NUMERIC(38, 20), Ceiling(dbo.[fnDivide](@dblReqQty, @dblWeightPerUnit)) * @dblWeightPerUnit)

								SELECT @dblSuggestedFloorQty = 0

								SELECT @dblSuggestedFloorQty = Convert(NUMERIC(38, 20), Floor(dbo.[fnDivide](@dblReqQty, @dblWeightPerUnit)) * @dblWeightPerUnit)

								SELECT @dblCeilingQtyDiff = @dblOriginalRequiredQty - (@dblPickedQty + @dblSuggestedCeilingQty)

								SELECT @dblFloorQtyDiff = @dblOriginalRequiredQty - (@dblPickedQty + @dblSuggestedFloorQty)

								IF abs(@dblFloorQtyDiff) > abs(@dblCeilingQtyDiff)
									AND @dblSuggestedCeilingQty + @dblPickedQty BETWEEN @dblLowerToleranceQty
										AND @dblUpperToleranceQty
									AND (
										@dblQty >= @dblSuggestedCeilingQty
										OR @dblSuggestedCeilingQty - @dblQty < 0.01
										)
								BEGIN
									SELECT @dblQuantity = @dblSuggestedCeilingQty
										,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Ceiling(dbo.[fnDivide](@dblReqQty, @dblWeightPerUnit)))
								END
								ELSE
								BEGIN
									SELECT @dblQuantity = Convert(NUMERIC(38, 20), ROUND(dbo.[fnDivide](@dblReqQty, @dblWeightPerUnit), 0) * @dblWeightPerUnit)
										,@dblIssuedQuantity = Convert(NUMERIC(38, 20), ROUND(dbo.[fnDivide](@dblReqQty, @dblWeightPerUnit), 0))
								END

								UPDATE @tblItem
								SET dblPickedQty = dblPickedQty + @dblQuantity
								WHERE intItemId = @intItemId
							END

							IF @intIssuedUOMTypeId = 3
							BEGIN
								SELECT @dblQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblReqQty, @dblWeightPerUnit), 0) * @dblWeightPerUnit)
									,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblReqQty, @dblWeightPerUnit), 0))

								IF @dblQuantity = 0
								BEGIN
									SELECT @dblQuantity = @dblReqQty
										,@dblIssuedQuantity = @dblReqQty
										,@intItemIssuedUOMId = @intItemUOMId

									UPDATE @tblItem
									SET dblPickedQty = dblPickedQty + @dblQuantity
									WHERE intItemId = @intItemId
								END
								ELSE
								BEGIN
									UPDATE @tblItem
									SET dblPickedQty = dblPickedQty + @dblQuantity
									WHERE intItemId = @intItemId

									SELECT @dblPickedQty = NULL

									SELECT @dblPickedQty = dblPickedQty
									FROM @tblItem
									WHERE intItemId = @intItemId

									IF (
											--@dblPickedQty BETWEEN @dblLowerToleranceQty
											--	AND @dblUpperToleranceQty
											@dblPickedQty <= @dblUpperToleranceQty
											)
										AND @dblLowerToleranceQty > 0
										AND @dblUpperToleranceQty > 0
									BEGIN
										DELETE
										FROM @tblInputItemSeq

										INSERT INTO @tblInputItemSeq (
											intItemId
											,intSeq
											)
										SELECT intItemId
											,row_number() OVER (
												ORDER BY dblPickedQty DESC
												)
										FROM @tblItem

										SELECT @intSeq = NULL

										SELECT @intSeq = intSeq
										FROM @tblInputItemSeq
										WHERE intItemId = @intItemId

										SELECT @intRowNo = NULL

										SELECT @intRowNo = intRowNo
										FROM @tblPreItem
										WHERE intItemId = @intItemId

										IF @intRowNo = @intSeq
										BEGIN
											SELECT @dblTotalPickedQty = NULL

											SELECT @dblTotalPickedQty = Sum(dblPickedQty)
											FROM @tblItem

											IF @ysnComplianceItem = 1
												AND ((@dblPickedQty / @dblTotalPickedQty) * 100) < @dblCompliancePercent
											BEGIN
												UPDATE @tblItem
												SET dblPickedQty = dblPickedQty - @dblQuantity
												WHERE intItemId = @intItemId

												SELECT @dblQuantity = @dblReqQty
													,@dblIssuedQuantity = dbo.[fnDivide](@dblReqQty, @dblWeightPerUnit)

												UPDATE @tblItem
												SET dblPickedQty = dblPickedQty + @dblQuantity
												WHERE intItemId = @intItemId
											END
										END
										ELSE
										BEGIN
											UPDATE @tblItem
											SET dblPickedQty = dblPickedQty - @dblQuantity
											WHERE intItemId = @intItemId

											SELECT @dblQuantity = @dblReqQty
												,@dblIssuedQuantity = dbo.[fnDivide](@dblReqQty, @dblWeightPerUnit)

											UPDATE @tblItem
											SET dblPickedQty = dblPickedQty + @dblQuantity
											WHERE intItemId = @intItemId
										END
									END
									ELSE
									BEGIN
										UPDATE @tblItem
										SET dblPickedQty = dblPickedQty - @dblQuantity
										WHERE intItemId = @intItemId

										SELECT @dblQuantity = @dblReqQty
											,@dblIssuedQuantity = dbo.[fnDivide](@dblReqQty, @dblWeightPerUnit)

										UPDATE @tblItem
										SET dblPickedQty = dblPickedQty + @dblQuantity
										WHERE intItemId = @intItemId
									END
								END
							END
						END
						ELSE
						BEGIN
							SELECT @dblQuantity = @dblReqQty
								,@dblIssuedQuantity = @dblReqQty
								,@intItemIssuedUOMId = @intItemUOMId
						END

						INSERT INTO @tblBSLot (
							intLotId
							,intItemId
							,dblQty
							,intUOMId
							,dblIssuedQuantity
							,intIssuedUOMId
							,dblWeightPerUnit
							,intRecipeItemId
							,intLocationId
							,intStorageLocationId
							)
						SELECT intLotId
							,intItemId
							,@dblQuantity
							,intItemUOMId
							,@dblIssuedQuantity
							,@intItemIssuedUOMId
							,dblWeightPerUnit
							,intRecipeItemId
							,intLocationId
							,intStorageLocationId
						FROM @tblLot
						WHERE intRowNo = @intLotCount

						UPDATE @tblLot
						SET dblQty = dblQty - @dblQuantity
						WHERE intRowNo = @intLotCount

						GOTO NextItem
					END
					ELSE
					BEGIN
						SELECT @dblQuantity = @dblQty
							,@dblIssuedQuantity = @dblQty
							,@intItemIssuedUOMId = (
								CASE 
									WHEN @intIssuedUOMTypeId IN (
											2
											,3
											)
										THEN @intItemIssuedUOMId
									ELSE @intItemUOMId
									END
								)

						IF @intIssuedUOMTypeId = 2
						BEGIN
							SELECT @dblPickedQty = NULL

							SELECT @dblPickedQty = dblPickedQty
							FROM @tblItem
							WHERE intItemId = @intItemId

							SELECT @dblSuggestedCeilingQty = 0

							SELECT @dblSuggestedCeilingQty = Convert(NUMERIC(38, 20), Ceiling(dbo.[fnDivide](@dblQty, @dblWeightPerUnit)) * @dblWeightPerUnit)

							SELECT @dblSuggestedFloorQty = 0

							SELECT @dblSuggestedFloorQty = Convert(NUMERIC(38, 20), Floor(dbo.[fnDivide](@dblQty, @dblWeightPerUnit)) * @dblWeightPerUnit)

							SELECT @dblCeilingQtyDiff = @dblOriginalRequiredQty - (@dblPickedQty + @dblSuggestedCeilingQty)

							SELECT @dblFloorQtyDiff = @dblOriginalRequiredQty - (@dblPickedQty + @dblSuggestedFloorQty)

							IF abs(@dblFloorQtyDiff) > abs(@dblCeilingQtyDiff)
								AND @dblSuggestedCeilingQty + @dblPickedQty BETWEEN @dblLowerToleranceQty
									AND @dblUpperToleranceQty
								AND (
									@dblQty >= @dblSuggestedCeilingQty
									OR @dblSuggestedCeilingQty - @dblQty < 0.01
									)
							BEGIN
								SELECT @dblQuantity = @dblSuggestedCeilingQty
									,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Ceiling(dbo.[fnDivide](@dblQty, @dblWeightPerUnit)))
							END
							ELSE
							BEGIN
								SELECT @dblQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblQty, @dblWeightPerUnit), 0) * @dblWeightPerUnit)
									,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblQty, @dblWeightPerUnit), 0))
							END

							UPDATE @tblItem
							SET dblPickedQty = dblPickedQty + @dblQuantity
							WHERE intItemId = @intItemId
						END

						IF @intIssuedUOMTypeId = 3
						BEGIN
							SELECT @dblQty1 = 0

							SELECT @dblQty1 = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblQty, @dblWeightPerUnit), 0))

							IF @ysnMinorIngredient = 0
								AND (
									@dblQty >= @dblQty1
									OR @dblQty1 - @dblQty < 0.01
									)
							BEGIN
								SELECT @dblQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblQty, @dblWeightPerUnit), 0) * @dblWeightPerUnit)
									,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Round(dbo.[fnDivide](@dblQty, @dblWeightPerUnit), 0))
							END
							ELSE
							BEGIN
								SELECT @dblQuantity = @dblQty
									,@dblIssuedQuantity = @dblQty
									,@intItemIssuedUOMId = @intItemUOMId
							END

							IF @dblQuantity = 0
							BEGIN
								SELECT @dblQuantity = @dblQty
									,@dblIssuedQuantity = @dblQty
									,@intItemIssuedUOMId = @intItemUOMId

								UPDATE @tblItem
								SET dblPickedQty = dblPickedQty + @dblQuantity
								WHERE intItemId = @intItemId
							END
							ELSE
							BEGIN
								UPDATE @tblItem
								SET dblPickedQty = dblPickedQty + @dblQuantity
								WHERE intItemId = @intItemId

								SELECT @dblPickedQty = NULL

								SELECT @dblPickedQty = dblPickedQty
								FROM @tblItem
								WHERE intItemId = @intItemId

								IF (
										--@dblPickedQty BETWEEN @dblLowerToleranceQty
										--	AND @dblUpperToleranceQty
										@dblPickedQty <= @dblUpperToleranceQty
										)
									AND @dblLowerToleranceQty > 0
									AND @dblUpperToleranceQty > 0
								BEGIN
									DELETE
									FROM @tblInputItemSeq

									INSERT INTO @tblInputItemSeq (
										intItemId
										,intSeq
										)
									SELECT intItemId
										,row_number() OVER (
											ORDER BY dblPickedQty DESC
											)
									FROM @tblItem

									SELECT @intSeq = NULL

									SELECT @intSeq = intSeq
									FROM @tblInputItemSeq
									WHERE intItemId = @intItemId

									SELECT @intRowNo = NULL

									SELECT @intRowNo = intRowNo
									FROM @tblPreItem
									WHERE intItemId = @intItemId

									IF @intRowNo = @intSeq
									BEGIN
										SELECT @dblTotalPickedQty = NULL

										SELECT @dblTotalPickedQty = Sum(dblPickedQty)
										FROM @tblItem

										IF @ysnComplianceItem = 1
											AND ((@dblPickedQty / @dblTotalPickedQty) * 100) < @dblCompliancePercent
										BEGIN
											UPDATE @tblItem
											SET dblPickedQty = dblPickedQty - @dblQuantity
											WHERE intItemId = @intItemId

											IF @ysnMinorIngredient = 1
											BEGIN
												SELECT @dblQuantity = @dblQty
													,@dblIssuedQuantity = @dblQty
													,@intItemIssuedUOMId = @intItemUOMId
											END
											ELSE
											BEGIN
												SELECT @dblQuantity = @dblQty
													,@dblIssuedQuantity = dbo.[fnDivide](@dblQty, @dblWeightPerUnit)
											END

											UPDATE @tblItem
											SET dblPickedQty = dblPickedQty + @dblQuantity
											WHERE intItemId = @intItemId
										END
									END
									ELSE
									BEGIN
										UPDATE @tblItem
										SET dblPickedQty = dblPickedQty - @dblQuantity
										WHERE intItemId = @intItemId

										IF @ysnMinorIngredient = 1
										BEGIN
											SELECT @dblQuantity = @dblQty
												,@dblIssuedQuantity = @dblQty
												,@intItemIssuedUOMId = @intItemUOMId
										END
										ELSE
										BEGIN
											SELECT @dblQuantity = @dblQty
												,@dblIssuedQuantity = dbo.[fnDivide](@dblQty, @dblWeightPerUnit)
										END

										UPDATE @tblItem
										SET dblPickedQty = dblPickedQty + @dblQuantity
										WHERE intItemId = @intItemId
									END
								END
								ELSE
								BEGIN
									UPDATE @tblItem
									SET dblPickedQty = dblPickedQty - @dblQuantity
									WHERE intItemId = @intItemId

									IF @ysnMinorIngredient = 1
									BEGIN
										SELECT @dblQuantity = @dblQty
											,@dblIssuedQuantity = @dblQty
											,@intItemIssuedUOMId = @intItemUOMId
									END
									ELSE
									BEGIN
										SELECT @dblQuantity = @dblQty
											,@dblIssuedQuantity = dbo.[fnDivide](@dblQty, @dblWeightPerUnit)
									END

									UPDATE @tblItem
									SET dblPickedQty = dblPickedQty + @dblQuantity
									WHERE intItemId = @intItemId
								END
							END
						END

						INSERT INTO @tblBSLot (
							intLotId
							,intItemId
							,dblQty
							,intUOMId
							,dblIssuedQuantity
							,intIssuedUOMId
							,dblWeightPerUnit
							,intRecipeItemId
							,intLocationId
							,intStorageLocationId
							)
						SELECT intLotId
							,intItemId
							,@dblQuantity
							,intItemUOMId
							,@dblIssuedQuantity
							,@intItemIssuedUOMId
							,dblWeightPerUnit
							,intRecipeItemId
							,intLocationId
							,intStorageLocationId
						FROM @tblLot
						WHERE intRowNo = @intLotCount

						UPDATE @tblLot
						SET dblQty = 0
						WHERE intRowNo = @intLotCount

						SET @dblReqQty = @dblReqQty - @dblQuantity

						IF @intIssuedUOMTypeId = 2
							AND Round(dbo.[fnDivide](@dblReqQty, @dblWeightPerUnit), 0) * @dblWeightPerUnit = 0
						BEGIN
							SELECT @dblReqQty = 0

							GOTO NextItem;
						END
					END

					SELECT @intLotCount = Min(intRowNo)
					FROM @tblLot
					WHERE intItemId = @intItemId
						AND dblQty > 0
						AND intRowNo > @intLotCount
				END

				NextItem:

				SELECT @intItemCount = Min(intRowNo)
				FROM @tblItem
				WHERE intRowNo > @intItemCount
			END
		END

		--Create WorkOrder
		IF ISNULL(@strSavedWONo, '') = ''
			EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
				,@intItemId = @intBlendItemId
				,@intManufacturingId = @intCellId
				,@intSubLocationId = 0
				,@intLocationId = @intLocationId
				,@intOrderTypeId = NULL
				,@intBlendRequirementId = @intBlendRequirementId
				,@intPatternCode = 93
				,@ysnProposed = 0
				,@strPatternString = @strNextWONo OUTPUT
		ELSE
		BEGIN
			SET @strNextWONo = @strSavedWONo
			SET @strSavedWONo = ''
		END

		SET @intExecutionOrder = @intExecutionOrder + 1

		INSERT INTO tblMFWorkOrder (
			strWorkOrderNo
			,intItemId
			,dblQuantity
			,intItemUOMId
			,intStatusId
			,intManufacturingCellId
			,intMachineId
			,intLocationId
			,dblBinSize
			,dtmExpectedDate
			,intExecutionOrder
			,intProductionTypeId
			,dblPlannedQuantity
			,intBlendRequirementId
			,ysnKittingEnabled
			,intKitStatusId
			,ysnUseTemplate
			,ysnDietarySupplements
			,strComment
			,dtmCreated
			,intCreatedUserId
			,dtmLastModified
			,intLastModifiedUserId
			,dtmReleasedDate
			,intManufacturingProcessId
			,intTransactionFrom
			,intPlannedShiftId
			,dtmPlannedDate
			,intConcurrencyId
			,intSubLocationId
			,dtmOrderDate
			,intSupervisorId
			)
		SELECT @strNextWONo
			,intItemId
			,@PerBlendSheetQty
			,intItemUOMId
			,@intWorkOrderStatusId
			,intCellId
			,intMachineId
			,intLocationId
			,dblBinSize
			,dtmDueDate
			,@intExecutionOrder
			,1
			,CASE 
				WHEN @intNoOfSheetOriginal = 1
					THEN dblPlannedQuantity
				ELSE @PerBlendSheetQty
				END
			,intBlendRequirementId
			,ysnKittingEnabled
			,@intKitStatusId
			,ysnUseTemplate
			,ysnDietarySupplements
			,strComment
			,GetDate()
			,intUserId
			,GetDate()
			,intUserId
			,GetDate()
			,@intManufacturingProcessId
			,1
			,intPlannedShiftId
			,dtmDueDate
			,1 AS intConcurrencyId
			,@intSubLocationId
			,GetDate()
			,intUserId
		FROM @tblBlendSheet

		SET @intWorkOrderId = SCOPE_IDENTITY()

		SELECT @dtmProductionDate = dtmExpectedDate
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		EXEC dbo.uspMFCopyRecipe @intItemId = @intBlendItemId
			,@intLocationId = @intLocationId
			,@intUserId = @intUserId
			,@intWorkOrderId = @intWorkOrderId

		--Check for Input Items validity
		SELECT @strInActiveItems = COALESCE(@strInActiveItems + ', ', '') + i.strItemNo
		FROM @tblLot l
		JOIN tblICItem i ON l.intItemId = i.intItemId
		WHERE l.intItemId NOT IN (
				SELECT intItemId
				FROM tblMFWorkOrderRecipeItem
				WHERE intWorkOrderId = @intWorkOrderId
					AND intRecipeItemTypeId = 1
				
				UNION
				
				SELECT intSubstituteItemId
				FROM tblMFWorkOrderRecipeSubstituteItem
				WHERE intWorkOrderId = @intWorkOrderId
				)

		IF ISNULL(@strInActiveItems, '') <> ''
		BEGIN
			SET @ErrMsg = 'Recipe ingredient items ' + @strInActiveItems + ' are inactive. Please remove the lots belong to the inactive items from blend sheet.'

			RAISERROR (
					@ErrMsg
					,16
					,1
					)
		END

		--Insert Into Input/Consumed Lot
		IF @ysnEnableParentLot = 0
		BEGIN
			IF @ysnKittingEnabled = 0
			BEGIN
				INSERT INTO tblMFWorkOrderInputLot (
					intWorkOrderId
					,intLotId
					,intItemId
					,dblQuantity
					,intItemUOMId
					,dblIssuedQuantity
					,intItemIssuedUOMId
					,intSequenceNo
					,dtmCreated
					,intCreatedUserId
					,dtmLastModified
					,intLastModifiedUserId
					,intRecipeItemId
					,dtmProductionDate
					,dtmBusinessDate
					,intBusinessShiftId
					)
				SELECT @intWorkOrderId
					,intLotId
					,intItemId
					,dblQty
					,intUOMId
					,dblIssuedQuantity
					,intIssuedUOMId
					,NULL
					,GetDate()
					,@intUserId
					,GetDate()
					,@intUserId
					,intRecipeItemId
					,@dtmProductionDate
					,@dtmBusinessDate
					,@intBusinessShiftId
				FROM @tblBSLot

				INSERT INTO tblMFWorkOrderConsumedLot (
					intWorkOrderId
					,intLotId
					,intItemId
					,dblQuantity
					,intItemUOMId
					,dblIssuedQuantity
					,intItemIssuedUOMId
					,intSequenceNo
					,dtmCreated
					,intCreatedUserId
					,dtmLastModified
					,intLastModifiedUserId
					,intRecipeItemId
					)
				SELECT @intWorkOrderId
					,intLotId
					,intItemId
					,dblQty
					,intUOMId
					,dblIssuedQuantity
					,intIssuedUOMId
					,NULL
					,GetDate()
					,@intUserId
					,GetDate()
					,@intUserId
					,intRecipeItemId
				FROM @tblBSLot
			END
			ELSE
			BEGIN
				INSERT INTO tblMFWorkOrderInputLot (
					intWorkOrderId
					,intLotId
					,intItemId
					,dblQuantity
					,intItemUOMId
					,dblIssuedQuantity
					,intItemIssuedUOMId
					,intSequenceNo
					,dtmCreated
					,intCreatedUserId
					,dtmLastModified
					,intLastModifiedUserId
					,intRecipeItemId
					,dtmProductionDate
					,dtmBusinessDate
					,intBusinessShiftId
					)
				SELECT @intWorkOrderId
					,intLotId
					,intItemId
					,dblQty
					,intUOMId
					,dblIssuedQuantity
					,intIssuedUOMId
					,NULL
					,GetDate()
					,@intUserId
					,GetDate()
					,@intUserId
					,intRecipeItemId
					,@dtmProductionDate
					,@dtmBusinessDate
					,@intBusinessShiftId
				FROM @tblBSLot
			END
		END
		ELSE
		BEGIN
			INSERT INTO tblMFWorkOrderInputParentLot (
				intWorkOrderId
				,intParentLotId
				,intItemId
				,dblQuantity
				,intItemUOMId
				,dblIssuedQuantity
				,intItemIssuedUOMId
				,intSequenceNo
				,dtmCreated
				,intCreatedUserId
				,dtmLastModified
				,intLastModifiedUserId
				,intRecipeItemId
				,dblWeightPerUnit
				,intLocationId
				,intStorageLocationId
				)
			SELECT @intWorkOrderId
				,intLotId
				,intItemId
				,dblQty
				,intUOMId
				,dblIssuedQuantity
				,intIssuedUOMId
				,NULL
				,GetDate()
				,@intUserId
				,GetDate()
				,@intUserId
				,intRecipeItemId
				,dblWeightPerUnit
				,intLocationId
				,intStorageLocationId
			FROM @tblBSLot
		END

		IF @ysnEnableParentLot = 0
			IF @ysnKittingEnabled = 0
				UPDATE tblMFWorkOrder
				SET dblQuantity = (
						SELECT sum(dblQuantity)
						FROM tblMFWorkOrderConsumedLot wi
						JOIN tblICItem i ON wi.intItemId = i.intItemId
							AND i.intCategoryId NOT IN (
								SELECT *
								FROM dbo.[fnCommaSeparatedValueToTable](@strPackagingCategoryId)
								)
						WHERE intWorkOrderId = @intWorkOrderId
						)
				WHERE intWorkOrderId = @intWorkOrderId
			ELSE
				UPDATE tblMFWorkOrder
				SET dblQuantity = (
						SELECT sum(dblQuantity)
						FROM tblMFWorkOrderInputLot wi
						JOIN tblICItem i ON wi.intItemId = i.intItemId
							AND i.intCategoryId NOT IN (
								SELECT *
								FROM dbo.[fnCommaSeparatedValueToTable](@strPackagingCategoryId)
								)
						WHERE intWorkOrderId = @intWorkOrderId
						)
				WHERE intWorkOrderId = @intWorkOrderId
		ELSE
			UPDATE tblMFWorkOrder
			SET dblQuantity = (
					SELECT sum(dblQuantity)
					FROM tblMFWorkOrderInputParentLot wi
					JOIN tblICItem i ON wi.intItemId = i.intItemId
						AND i.intCategoryId NOT IN (
							SELECT *
							FROM dbo.[fnCommaSeparatedValueToTable](@strPackagingCategoryId)
							)
					WHERE intWorkOrderId = @intWorkOrderId
					)
			WHERE intWorkOrderId = @intWorkOrderId

		--Create Quality Computations
		EXEC uspMFCreateBlendRecipeComputation @intWorkOrderId = @intWorkOrderId
			,@intTypeId = 1
			,@strXml = @strXml

		--Create Reservation
		EXEC [uspMFCreateLotReservation] @intWorkOrderId = @intWorkOrderId
			,@ysnReservationByParentLot = @ysnEnableParentLot

		DELETE
		FROM @tblBSLot

		SELECT @dblQtyToProduce = @dblQtyToProduce - @PerBlendSheetQty

		INSERT INTO dbo.tblMFWorkOrderPreStage (
			intWorkOrderId
			,intWorkOrderStatusId
			,intUserId
			,strRowState
			)
		SELECT @intWorkOrderId
			,9
			,@intUserId
			,'Added'

		SET @intNoOfSheet = @intNoOfSheet - 1
	END

	--Update Bulk Item(By Location or FIFO) Standard Required Qty Calculated Using Planned Qty
	--IF @ysnCalculateNoSheetUsingBinSize = 0
	BEGIN
		SELECT @dblBulkReqQuantity = ISNULL(SUM((ri.dblCalculatedQuantity * (@dblPlannedQuantity / r.dblQuantity))), 0)
		FROM tblMFRecipeItem ri
		JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		WHERE r.intItemId = @intBlendItemId
			AND intLocationId = @intLocationId
			AND ysnActive = 1
			AND ri.intRecipeItemTypeId = 1
			AND ri.intConsumptionMethodId IN (
				2
				,3
				)

		UPDATE tblMFWorkOrder
		SET dblQuantity = dblQuantity + @dblBulkReqQuantity
		WHERE intWorkOrderId = @intWorkOrderId
	END

	UPDATE tblMFBlendRequirement
	SET dblIssuedQty = (
			SELECT SUM(dblQuantity)
			FROM tblMFWorkOrder
			WHERE intBlendRequirementId = @intBlendRequirementId
			)
	WHERE intBlendRequirementId = @intBlendRequirementId

	UPDATE tblMFBlendRequirement
	SET intStatusId = 2
	WHERE intBlendRequirementId = @intBlendRequirementId
		AND ISNULL(dblIssuedQty, 0) >= dblQuantity

	SELECT @dblBalancedQtyToProduceOut = (dblQuantity - ISNULL(dblIssuedQty, 0))
	FROM tblMFBlendRequirement
	WHERE intBlendRequirementId = @intBlendRequirementId

	IF @dblBalancedQtyToProduceOut <= 0
		SET @dblBalancedQtyToProduceOut = 0
	SET @strWorkOrderNoOut = @strNextWONo;
	SET @intWorkOrderIdOut = @intWorkOrderId

	COMMIT TRAN

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
