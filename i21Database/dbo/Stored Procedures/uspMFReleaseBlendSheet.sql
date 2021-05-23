﻿CREATE PROCEDURE [dbo].[uspMFReleaseBlendSheet] @strXml NVARCHAR(Max)
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
	DECLARE @intCategoryId INT
	DECLARE @strInActiveItems NVARCHAR(max)
	DECLARE @dtmDate DATETIME = Convert(DATE, GetDate())
	DECLARE @intDayOfYear INT = DATEPART(dy, @dtmDate)
	DECLARE @strPackagingCategoryId NVARCHAR(Max)
	DECLARE @intPlannedShiftId INT
	DECLARE @strSavedWONo NVARCHAR(50)
		,@intSubLocationId INT
		,@intMachineId INT
		,@intIssuedUOMTypeId INT
		,@dblWeightPerUnit NUMERIC(38, 20)
		,@intLotId INT
		,@intItemId INT
		,@dblQty NUMERIC(38, 20)
		,@intUOMId INT
		,@dblIssuedQuantity NUMERIC(38, 20)
		,@intIssuedUOMId INT
		--,@dblWeightPerUnit NUMERIC(38, 20)
		,@intRecipeItemId INT
		,@intLotLocationId INT
		,@intStorageLocationId INT
		,@dblPickedQty NUMERIC(38, 20)
		,@dblUpperToleranceQty NUMERIC(38, 20)
		,@dblLowerToleranceQty NUMERIC(38, 20)
		,@ysnComplianceItem BIT
		,@dblCompliancePercent NUMERIC(38, 20)
		,@intSeq INT
		,@dblTotalPickedQty NUMERIC(38, 20)
		,@dblAvailQty NUMERIC(38, 20)
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
			)

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

	SELECT @intIssuedUOMTypeId = NULL

	SELECT @intIssuedUOMTypeId = ISNULL(intIssuedUOMTypeId, 1)
	FROM tblMFMachine
	WHERE intMachineId = @intMachineId

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
				SELECT TOP 1 dblWeightPerQty
				FROM tblICLot
				WHERE intParentLotId = b.intParentLotId
				)
		FROM @tblLot a
		JOIN tblICParentLot b ON a.intLotId = b.intParentLotId

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
		INSERT INTO @tblItem (
			intItemId
			,dblReqQty
			,ysnIsSubstitute
			,intConsumptionMethodId
			,intConsumptionStoragelocationId
			,intParentItemId
			)
		SELECT ri.intItemId
			,(ri.dblCalculatedQuantity * (@dblPlannedQuantity / r.dblQuantity)) AS RequiredQty
			,0 AS ysnIsSubstitute
			,ri.intConsumptionMethodId
			,ri.intStorageLocationId
			,0
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
		FROM tblMFRecipeSubstituteItem rs
		JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
		WHERE rs.intRecipeId = @intRecipeId
			AND rs.intRecipeItemTypeId = 1

		DECLARE @intMinMissingItem INT
		DECLARE @intConsumptionMethodId INT
		DECLARE @dblInputItemBSQty NUMERIC(38, 20)
		DECLARE @dblBulkItemAvlQty NUMERIC(38, 20)

		SELECT @intMinMissingItem = Min(intRowNo)
		FROM @tblItem

		WHILE (@intMinMissingItem IS NOT NULL)
		BEGIN
			SELECT @intInputItemId = intItemId
				,@dblInputReqQty = dblReqQty
				,@intConsumptionMethodId = intConsumptionMethodId
			FROM @tblItem
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

				IF @dblInputItemBSQty < @dblInputReqQty
				BEGIN
					SELECT @strInputItemNo = strItemNo
					FROM tblICItem
					WHERE intItemId = @intInputItemId

					SET @ErrMsg = 'Selected quantity of ' + CONVERT(VARCHAR, @dblInputItemBSQty) + ' of item ' + CONVERT(NVARCHAR, @strInputItemNo) + + ' is less than the required quantity of ' + CONVERT(VARCHAR, @dblInputReqQty) + '.'

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
			FROM @tblItem
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
		SET @intNoOfSheet = Ceiling(@dblQtyToProduce / @dblBinSize)
		SET @PerBlendSheetQty = @dblBinSize
		SET @intNoOfSheetOriginal = @intNoOfSheet
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
		,@dblReqQty NUMERIC(38, 20)

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

		--Calculate Required Quantity by Item
		IF (@dblQtyToProduce > @PerBlendSheetQty)
			SELECT @PerBlendSheetQty = @PerBlendSheetQty
		ELSE
			SELECT @PerBlendSheetQty = @dblQtyToProduce

		DELETE
		FROM @tblItem

		INSERT INTO @tblItem (
			intItemId
			,dblReqQty
			,dblUpperToleranceQty
			,dblLowerToleranceQty
			,ysnComplianceItem
			,dblCompliancePercent
			)
		SELECT ri.intItemId
			,(ri.dblCalculatedQuantity * (@PerBlendSheetQty / r.dblQuantity)) AS RequiredQty
			,(ri.dblCalculatedUpperTolerance * (@PerBlendSheetQty / r.dblQuantity)) AS dblCalculatedUpperTolerance
			,(ri.dblCalculatedLowerTolerance * (@PerBlendSheetQty / r.dblQuantity)) AS dblCalculatedLowerTolerance
			,ri.ysnComplianceItem
			,ri.dblCompliancePercent
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
		FROM tblMFRecipeSubstituteItem rs
		JOIN tblMFRecipeItem ri ON ri.intRecipeItemId = rs.intRecipeItemId
		JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
		WHERE rs.intRecipeId = @intRecipeId
			AND rs.intRecipeItemTypeId = 1

		SELECT @intItemCount = Min(intRowNo)
		FROM @tblItem

		WHILE (@intItemCount IS NOT NULL)
		BEGIN
			SET @intLotCount = NULL
			SET @strNextWONo = NULL

			SELECT @dblUpperToleranceQty = NULL
				,@dblLowerToleranceQty = NULL
				,@ysnComplianceItem = NULL
				,@dblCompliancePercent = NULL

			SELECT @intItemId = intItemId
				,@dblReqQty = dblReqQty
				,@dblUpperToleranceQty = dblUpperToleranceQty
				,@dblLowerToleranceQty = dblLowerToleranceQty
				,@ysnComplianceItem = ysnComplianceItem
				,@dblCompliancePercent = dblCompliancePercent
			FROM @tblItem
			WHERE intRowNo = @intItemCount

			SELECT @intLotCount = Min(intRowNo)
			FROM @tblLot
			WHERE intItemId = @intItemId
				AND dblQty > 0

			WHILE (@intLotCount IS NOT NULL)
			BEGIN
				SELECT @intLotId = NULL
					,@intItemId = NULL
					,@dblQty = NULL
					,@intUOMId = NULL
					,@dblIssuedQuantity = NULL
					,@intIssuedUOMId = NULL
					,@dblWeightPerUnit = NULL
					,@intRecipeItemId = NULL
					,@intLotLocationId = NULL
					,@intStorageLocationId = NULL

				SELECT @intLotId = intLotId
					,@dblQty = dblQty
					,@dblWeightPerUnit = dblWeightPerUnit
				FROM @tblLot
				WHERE intRowNo = @intLotCount

				IF @intIssuedUOMTypeId IN (
						2
						,3
						) --Pack and Pack and Weight
				BEGIN
					SET @dblAvailQty = NULL
					SET @dblAvailQty = @dblQty
					SET @dblQty = @dblQty - (@dblQty % @dblWeightPerUnit)
				END

				IF (
						@dblQty >= @dblReqQty
						AND @intNoOfSheet > 1
						)
				BEGIN
					SELECT @intLotId = intLotId
						,@intItemId = intItemId
						,@dblQty = CASE 
							WHEN @intIssuedUOMTypeId = 2
								THEN Convert(NUMERIC(38, 20), (
											(
												CASE 
													WHEN Floor(@dblReqQty / dblWeightPerUnit) = 0
														THEN 1
													ELSE Floor(@dblReqQty / dblWeightPerUnit)
													END
												) * dblWeightPerUnit
											))
							ELSE @dblReqQty
							END
						,@intUOMId = intItemUOMId
						,@dblIssuedQuantity = CASE 
							WHEN Floor(@dblReqQty / dblWeightPerUnit) = 0
								THEN 1
							ELSE Floor(@dblReqQty / dblWeightPerUnit)
							END
						,@intIssuedUOMId = intItemIssuedUOMId
						,@dblWeightPerUnit = dblWeightPerUnit
						,@intRecipeItemId = intRecipeItemId
						,@intLotLocationId = intLocationId
						,@intStorageLocationId = intStorageLocationId
					FROM @tblLot
					WHERE intRowNo = @intLotCount

					IF @intIssuedUOMTypeId = 3
					BEGIN
						SELECT @dblQty = Convert(NUMERIC(38, 20), Round(@dblReqQty / @dblWeightPerUnit, 0) * @dblWeightPerUnit)
							,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Round(@dblReqQty / @dblWeightPerUnit, 0))

						IF @dblQty = 0
						BEGIN
							SELECT @dblQty = @dblReqQty
								,@dblIssuedQuantity = @dblReqQty
								,@intIssuedUOMId = @intUOMId

							UPDATE @tblItem
							SET dblPickedQty = dblPickedQty + @dblQty
							WHERE intItemId = @intItemId
						END
						ELSE
						BEGIN
							UPDATE @tblItem
							SET dblPickedQty = dblPickedQty + @dblQty
							WHERE intItemId = @intItemId

							SELECT @dblPickedQty = NULL

							SELECT @dblPickedQty = dblPickedQty
							FROM @tblItem
							WHERE intItemId = @intItemId

							IF (
									@dblPickedQty BETWEEN @dblLowerToleranceQty
										AND @dblUpperToleranceQty
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

								IF @intItemCount = @intSeq
								BEGIN
									SELECT @dblTotalPickedQty = NULL

									SELECT @dblTotalPickedQty = Sum(dblPickedQty)
									FROM @tblItem

									IF @ysnComplianceItem = 1
										AND ((@dblPickedQty / @dblTotalPickedQty) * 100) < @dblCompliancePercent
									BEGIN
										SELECT @dblQty = @dblReqQty
											,@dblIssuedQuantity = @dblReqQty
											,@intIssuedUOMId = @intUOMId
									END
								END
								ELSE
								BEGIN
									SELECT @dblQty = @dblReqQty
										,@dblIssuedQuantity = @dblReqQty
										,@intIssuedUOMId = @intUOMId
								END
							END
							ELSE
							BEGIN
								SELECT @dblQty = @dblReqQty
									,@dblIssuedQuantity = @dblReqQty
									,@intIssuedUOMId = @intUOMId
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
					SELECT @intLotId
						,@intItemId
						,@dblQty
						,@intUOMId
						,@dblIssuedQuantity
						,@intIssuedUOMId
						,@dblWeightPerUnit
						,@intRecipeItemId
						,@intLotLocationId
						,@intStorageLocationId

					UPDATE @tblLot
					SET dblQty = dblQty - @dblQty
					WHERE intRowNo = @intLotCount

					GOTO NextItem
				END
				ELSE
				BEGIN
					/*INSERT INTO @tblBSLot (
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
						,CASE 
							WHEN @intIssuedUOMTypeId = 2
								THEN Convert(NUMERIC(38, 20), (
											(
												CASE 
													WHEN Floor(@dblQty / dblWeightPerUnit) = 0
														THEN 1
													ELSE Floor(@dblQty / dblWeightPerUnit)
													END
												) * dblWeightPerUnit
											))
							ELSE @dblQty
							END
						,intItemUOMId
						,CASE 
							WHEN Floor(@dblQty / dblWeightPerUnit) = 0
								THEN 1
							ELSE Floor(@dblQty / dblWeightPerUnit)
							END
						,intItemIssuedUOMId
						,dblWeightPerUnit
						,intRecipeItemId
						,intLocationId
						,intStorageLocationId
					FROM @tblLot
					WHERE intRowNo = @intLotCount

					UPDATE @tblLot
					SET dblQty = 0
					WHERE intRowNo = @intLotCount

					SET @dblReqQty = @dblReqQty - (
							CASE 
								WHEN @intIssuedUOMTypeId = 2
									THEN Convert(NUMERIC(38, 20), (
												(
													CASE 
														WHEN Floor(@dblQty / dblWeightPerUnit) = 0
															THEN 1
														ELSE Floor(@dblQty / dblWeightPerUnit)
														END
													) * dblWeightPerUnit
												))
								ELSE @dblQty
								END
							)*/
					IF @dblQty = 0
					BEGIN
						SELECT @dblQty = @dblAvailQty
					END

					SELECT @intLotId = intLotId
						,@intItemId = intItemId
						,@dblQty = CASE 
							WHEN @intIssuedUOMTypeId = 2
								THEN Convert(NUMERIC(38, 20), (
											(
												CASE 
													WHEN Floor(@dblQty / dblWeightPerUnit) = 0
														THEN 1
													ELSE Floor(@dblQty / dblWeightPerUnit)
													END
												) * dblWeightPerUnit
											))
							ELSE @dblQty
							END
						,@intUOMId = intItemUOMId
						,@dblIssuedQuantity = CASE 
							WHEN Floor(@dblQty / dblWeightPerUnit) = 0
								THEN 1
							ELSE Floor(@dblQty / dblWeightPerUnit)
							END
						,@intIssuedUOMId = intItemIssuedUOMId
						,@dblWeightPerUnit = dblWeightPerUnit
						,@intRecipeItemId = intRecipeItemId
						,@intLotLocationId = intLocationId
						,@intStorageLocationId = intStorageLocationId
					FROM @tblLot
					WHERE intRowNo = @intLotCount

					IF @intIssuedUOMTypeId = 3
					BEGIN
						SELECT @dblAvailQty = @dblQty

						SELECT @dblQty = Convert(NUMERIC(38, 20), Round(@dblQty / @dblWeightPerUnit, 0) * @dblWeightPerUnit)
							,@dblIssuedQuantity = Convert(NUMERIC(38, 20), Round(@dblQty / @dblWeightPerUnit, 0))

						IF @dblQty = 0
							OR @dblQty > @dblAvailQty
						BEGIN
							SELECT @dblQty = @dblAvailQty
								,@dblIssuedQuantity = @dblAvailQty
								,@intIssuedUOMId = @intUOMId

							UPDATE @tblItem
							SET dblPickedQty = dblPickedQty + @dblQty
							WHERE intItemId = @intItemId
						END
						ELSE
						BEGIN
							UPDATE @tblItem
							SET dblPickedQty = dblPickedQty + @dblQty
							WHERE intItemId = @intItemId

							SELECT @dblPickedQty = NULL

							SELECT @dblPickedQty = dblPickedQty
							FROM @tblItem
							WHERE intItemId = @intItemId

							IF (
									@dblPickedQty BETWEEN @dblLowerToleranceQty
										AND @dblUpperToleranceQty
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

								IF @intItemCount = @intSeq
								BEGIN
									SELECT @dblTotalPickedQty = NULL

									SELECT @dblTotalPickedQty = Sum(dblPickedQty)
									FROM @tblItem

									IF @ysnComplianceItem = 1
										AND ((@dblPickedQty / @dblTotalPickedQty) * 100) < @dblCompliancePercent
									BEGIN
										SELECT @dblQty = @dblQty
											,@dblIssuedQuantity = @dblQty
											,@intIssuedUOMId = @intUOMId
									END
								END
								ELSE
								BEGIN
									SELECT @dblQty = @dblAvailQty
										,@dblIssuedQuantity = @dblAvailQty
										,@intIssuedUOMId = @intUOMId
								END
							END
							ELSE
							BEGIN
								SELECT @dblQty = @dblAvailQty
									,@dblIssuedQuantity = @dblAvailQty
									,@intIssuedUOMId = @intUOMId
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
					SELECT @intLotId
						,@intItemId
						,@dblQty
						,@intUOMId
						,@dblIssuedQuantity
						,@intIssuedUOMId
						,@dblWeightPerUnit
						,@intRecipeItemId
						,@intLotLocationId
						,@intStorageLocationId

					UPDATE @tblLot
					SET dblQty = dblQty - @dblQty
					WHERE intRowNo = @intLotCount
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
