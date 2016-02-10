CREATE PROCEDURE [dbo].[uspMFReleaseBlendSheet] @strXml NVARCHAR(Max)
	,@strWorkOrderNoOut NVARCHAR(50) = '' OUT
	,@dblBalancedQtyToProduceOut NUMERIC(18, 6) = 0 OUTPUT
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
	DECLARE @dblQtyToProduce NUMERIC(18, 6)
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
	DECLARE @dblBinSize NUMERIC(18, 6)
	DECLARE @intNoOfSheet INT
	DECLARE @intNoOfSheetOriginal INT
	DECLARE @dblRemainingQtyToProduce NUMERIC(18, 6)
	DECLARE @PerBlendSheetQty NUMERIC(18, 6)
	DECLARE @ysnCalculateNoSheetUsingBinSize BIT = 0
	DECLARE @ysnKittingEnabled BIT
	DECLARE @ysnRequireCustomerApproval BIT
	DECLARE @intWorkOrderStatusId INT
	DECLARE @intKitStatusId INT = NULL
	DECLARE @dblBulkReqQuantity NUMERIC(18, 6)
	DECLARE @dblPlannedQuantity NUMERIC(18, 6)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	BEGIN TRAN

	DECLARE @tblBlendSheet TABLE (
		intWorkOrderId INT
		,intItemId INT
		,intCellId INT
		,intMachineId INT
		,dtmDueDate DATETIME
		,dblQtyToProduce NUMERIC(18, 6)
		,dblPlannedQuantity NUMERIC(18, 6)
		,dblBinSize NUMERIC(18, 6)
		,strComment NVARCHAR(Max)
		,ysnUseTemplate BIT
		,ysnKittingEnabled BIT
		,intLocationId INT
		,intBlendRequirementId INT
		,intItemUOMId INT
		,intUserId INT
		)
	DECLARE @tblItem TABLE (
		intRowNo INT Identity(1, 1)
		,intItemId INT
		,dblReqQty NUMERIC(18, 6)
		)
	DECLARE @tblLot TABLE (
		intRowNo INT Identity(1, 1)
		,intLotId INT
		,intItemId INT
		,dblQty NUMERIC(18, 6)
		,dblIssuedQuantity NUMERIC(18, 6)
		,dblWeightPerUnit NUMERIC(18, 6)
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
		,dblQty NUMERIC(18, 6)
		,intUOMId INT
		,dblIssuedQuantity NUMERIC(18, 6)
		,intIssuedUOMId INT
		,dblWeightPerUnit NUMERIC(18, 6)
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
		,intLocationId
		,intBlendRequirementId
		,intItemUOMId
		,intUserId
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
		,intLocationId
		,intBlendRequirementId
		,intItemUOMId
		,intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intItemId INT
			,intCellId INT
			,intMachineId INT
			,dtmDueDate DATETIME
			,dblQtyToProduce NUMERIC(18, 6)
			,dblPlannedQuantity NUMERIC(18, 6)
			,dblBinSize NUMERIC(18, 6)
			,strComment NVARCHAR(Max)
			,ysnUseTemplate BIT
			,ysnKittingEnabled BIT
			,intLocationId INT
			,intBlendRequirementId INT
			,intItemUOMId INT
			,intUserId INT
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
			,dblQty NUMERIC(18, 6)
			,dblIssuedQuantity NUMERIC(18, 6)
			,dblPickedQuantity NUMERIC(18, 6)
			,dblWeightPerUnit NUMERIC(18, 6)
			,intItemUOMId INT
			,intItemIssuedUOMId INT
			,intUserId INT
			,intRecipeItemId INT
			,intLocationId INT
			,intStorageLocationId INT
			,ysnParentLot BIT
			)

	UPDATE @tblBlendSheet
	SET dblQtyToProduce = (
			SELECT sum(dblQty)
			FROM @tblLot
			)

	UPDATE @tblLot
	SET intStorageLocationId = NULL
	WHERE intStorageLocationId = 0

	SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
	FROM tblMFCompanyPreference

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
	FROM @tblBlendSheet

	SELECT @strDemandNo = strDemandNo
	FROM tblMFBlendRequirement
	WHERE intBlendRequirementId = @intBlendRequirementId

	SELECT @strBlendItemNo = strItemNo
		,@strBlendItemStatus = strStatus
		,@ysnRequireCustomerApproval = ysnRequireCustomerApproval
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
		SET a.dblWeightPerUnit = b.dblWeightPerQty
		FROM @tblLot a
		JOIN tblICLot b ON a.intLotId = b.intLotId
	ELSE
		UPDATE a
		SET a.dblWeightPerUnit = (
				SELECT TOP 1 dblWeightPerQty
				FROM tblICLot
				WHERE intParentLotId = b.intParentLotId
				)
		FROM @tblLot a
		JOIN tblICParentLot b ON a.intLotId = b.intParentLotId

	SELECT @intRecipeId = intRecipeId
		,@intManufacturingProcessId = a.intManufacturingProcessId
	FROM tblMFRecipe a
	JOIN @tblBlendSheet b ON a.intItemId = b.intItemId
		AND a.intLocationId = b.intLocationId
		AND ysnActive = 1

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
		DELETE
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

	DECLARE @intItemCount INT
		,@intLotCount INT
		,@intItemId INT
		,@dblReqQty NUMERIC(18, 6)
		,@intLotId INT
		,@dblQty NUMERIC(18, 6)

	SELECT @intExecutionOrder = Count(1)
	FROM tblMFWorkOrder
	WHERE intManufacturingCellId = @intCellId
		AND convert(DATE, dtmExpectedDate) = convert(DATE, @dtmDueDate)
		AND intBlendRequirementId IS NOT NULL
		AND intStatusId NOT IN (
			2
			,13
			)

	WHILE (@intNoOfSheet > 0)
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
			)
		SELECT ri.intItemId
			,(ri.dblCalculatedQuantity * (@PerBlendSheetQty / r.dblQuantity)) AS RequiredQty
		FROM tblMFRecipeItem ri
		JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		WHERE ri.intRecipeId = @intRecipeId
			AND ri.intRecipeItemTypeId = 1
		
		UNION
		
		SELECT rs.intSubstituteItemId
			,(rs.dblQuantity * (@PerBlendSheetQty / r.dblQuantity)) AS RequiredQty
		FROM tblMFRecipeSubstituteItem rs
		JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
		WHERE rs.intRecipeId = @intRecipeId
			AND rs.intRecipeItemTypeId = 1

		SELECT @intItemCount = Min(intRowNo)
		FROM @tblItem

		WHILE (@intItemCount IS NOT NULL)
		BEGIN
			SET @intLotCount = NULL
			SET @strNextWONo = NULL

			SELECT @intItemId = intItemId
				,@dblReqQty = dblReqQty
			FROM @tblItem
			WHERE intRowNo = @intItemCount

			SELECT @intLotCount = Min(intRowNo)
			FROM @tblLot
			WHERE intItemId = @intItemId
				AND dblQty > 0

			WHILE (@intLotCount IS NOT NULL)
			BEGIN
				SELECT @intLotId = intLotId
					,@dblQty = dblQty
				FROM @tblLot
				WHERE intRowNo = @intLotCount

				IF (
						@dblQty >= @dblReqQty
						AND @intNoOfSheet > 1
						)
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
						,@dblReqQty
						,intItemUOMId
						,CASE 
							WHEN intItemUOMId = intItemIssuedUOMId
								THEN @dblReqQty
							ELSE @dblReqQty / dblWeightPerUnit
							END
						,intItemIssuedUOMId
						,dblWeightPerUnit
						,intRecipeItemId
						,intLocationId
						,intStorageLocationId
					FROM @tblLot
					WHERE intRowNo = @intLotCount

					UPDATE @tblLot
					SET dblQty = dblQty - @dblReqQty
					WHERE intRowNo = @intLotCount

					GOTO NextItem
				END
				ELSE
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
						,@dblQty
						,intItemUOMId
						,CASE 
							WHEN intItemUOMId = intItemIssuedUOMId
								THEN @dblQty
							ELSE @dblQty / dblWeightPerUnit
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

					SET @dblReqQty = @dblReqQty - @dblQty
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
		IF (
				SELECT count(1)
				FROM tblMFWorkOrder
				WHERE strWorkOrderNo LIKE @strDemandNo + '%'
				) = 0
			SET @strNextWONo = convert(VARCHAR, @strDemandNo) + '01'
		ELSE
			SELECT @strNextWONo = convert(VARCHAR, @strDemandNo) + right('00' + Convert(VARCHAR, (Max(Cast(right(strWorkOrderNo, 2) AS INT))) + 1), 2)
			FROM tblMFWorkOrder
			WHERE strWorkOrderNo LIKE @strDemandNo + '%'

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
			,strComment
			,dtmCreated
			,intCreatedUserId
			,dtmLastModified
			,intLastModifiedUserId
			,dtmReleasedDate
			,intManufacturingProcessId
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
			,strComment
			,GetDate()
			,intUserId
			,GetDate()
			,intUserId
			,GetDate()
			,@intManufacturingProcessId
		FROM @tblBlendSheet

		SET @intWorkOrderId = SCOPE_IDENTITY()

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
						FROM tblMFWorkOrderConsumedLot
						WHERE intWorkOrderId = @intWorkOrderId
						)
				WHERE intWorkOrderId = @intWorkOrderId
			ELSE
				UPDATE tblMFWorkOrder
				SET dblQuantity = (
						SELECT sum(dblQuantity)
						FROM tblMFWorkOrderInputLot
						WHERE intWorkOrderId = @intWorkOrderId
						)
				WHERE intWorkOrderId = @intWorkOrderId
		ELSE
			UPDATE tblMFWorkOrder
			SET dblQuantity = (
					SELECT sum(dblQuantity)
					FROM tblMFWorkOrderInputParentLot
					WHERE intWorkOrderId = @intWorkOrderId
					)
			WHERE intWorkOrderId = @intWorkOrderId

		EXEC dbo.uspMFCopyRecipe @intItemId = @intBlendItemId
			,@intLocationId = @intLocationId
			,@intUserId = @intUserId
			,@intWorkOrderId = @intWorkOrderId

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

		SET @intNoOfSheet = @intNoOfSheet - 1
	END

	--Update Bulk Item(By Location or FIFO) Standard Required Qty Calculated Using Planned Qty
	IF @ysnCalculateNoSheetUsingBinSize = 0
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
