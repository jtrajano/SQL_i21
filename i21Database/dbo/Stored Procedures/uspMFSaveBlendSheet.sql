CREATE PROCEDURE [dbo].[uspMFSaveBlendSheet] @strXml NVARCHAR(Max)
	,@intWorkOrderId INT OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(Max)
	DECLARE @ysnEnableParentLot BIT = 0
	DECLARE @intBlendItemId INT
	DECLARE @intLocationId INT
	DECLARE @dblPlannedQuantity NUMERIC(18, 6)
	DECLARE @dblBulkReqQuantity NUMERIC(18, 6)

	SET @intWorkOrderId = 0;

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	DECLARE @tblBlendSheet TABLE (
		intWorkOrderId INT
		,strWorkOrderNo NVARCHAR(50)
		,intBlendRequirementId INT
		,intItemId INT
		,intCellId INT
		,intMachineId INT
		,dtmDueDate DATETIME
		,dblQtyToProduce NUMERIC(18, 6)
		,dblPlannedQuantity NUMERIC(18, 6)
		,intItemUOMId INT
		,dblBinSize NUMERIC(18, 6)
		,strComment NVARCHAR(Max)
		,ysnUseTemplate BIT
		,ysnKittingEnabled BIT
		,intLocationId INT
		,intUserId INT
		,intConcurrencyId INT
		)
	DECLARE @tblLot TABLE (
		intRowNo INT Identity(1, 1)
		,intWorkOrderInputLotId INT
		,intLotId INT
		,intItemId INT
		,dblQty NUMERIC(18, 6)
		,intItemUOMId INT
		,dblIssuedQuantity NUMERIC(18, 6)
		,intItemIssuedUOMId INT
		,dblWeightPerUnit NUMERIC(18, 6)
		,intUserId INT
		,strRowState NVARCHAR(50)
		,intRecipeItemId INT
		,intLocationId INT
		,intStorageLocationId INT
		,ysnParentLot BIT
		)

	INSERT INTO @tblBlendSheet (
		intWorkOrderId
		,strWorkOrderNo
		,intBlendRequirementId
		,intItemId
		,intCellId
		,intMachineId
		,dtmDueDate
		,dblQtyToProduce
		,dblPlannedQuantity
		,intItemUOMId
		,dblBinSize
		,strComment
		,ysnUseTemplate
		,ysnKittingEnabled
		,intLocationId
		,intUserId
		,intConcurrencyId
		)
	SELECT intWorkOrderId
		,strWorkOrderNo
		,intBlendRequirementId
		,intItemId
		,intCellId
		,intMachineId
		,dtmDueDate
		,dblQtyToProduce
		,dblPlannedQuantity
		,intItemUOMId
		,dblBinSize
		,strComment
		,ysnUseTemplate
		,ysnKittingEnabled
		,intLocationId
		,intUserId
		,intConcurrencyId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,strWorkOrderNo NVARCHAR(50)
			,intBlendRequirementId INT
			,intItemId INT
			,intCellId INT
			,intMachineId INT
			,dtmDueDate DATETIME
			,dblQtyToProduce NUMERIC(18, 6)
			,dblPlannedQuantity NUMERIC(18, 6)
			,intItemUOMId INT
			,dblBinSize NUMERIC(18, 6)
			,strComment NVARCHAR(Max)
			,ysnUseTemplate BIT
			,ysnKittingEnabled BIT
			,intLocationId INT
			,intUserId INT
			,intConcurrencyId INT
			)

	INSERT INTO @tblLot (
		intWorkOrderInputLotId
		,intLotId
		,intItemId
		,dblQty
		,intItemUOMId
		,dblIssuedQuantity
		,intItemIssuedUOMId
		,dblWeightPerUnit
		,intUserId
		,strRowState
		,intRecipeItemId
		,intLocationId
		,intStorageLocationId
		,ysnParentLot
		)
	SELECT intWorkOrderInputLotId
		,intLotId
		,intItemId
		,dblQty
		,intItemUOMId
		,dblIssuedQuantity
		,intItemIssuedUOMId
		,dblWeightPerUnit
		,intUserId
		,strRowState
		,intRecipeItemId
		,intLocationId
		,intStorageLocationId
		,ysnParentLot
	FROM OPENXML(@idoc, 'root/lot', 2) WITH (
			intWorkOrderInputLotId INT
			,intLotId INT
			,intItemId INT
			,dblQty NUMERIC(18, 6)
			,intItemUOMId INT
			,dblIssuedQuantity NUMERIC(18, 6)
			,intItemIssuedUOMId INT
			,dblWeightPerUnit NUMERIC(18, 6)
			,intUserId INT
			,strRowState NVARCHAR(50)
			,intRecipeItemId INT
			,intLocationId INT
			,intStorageLocationId INT
			,ysnParentLot BIT
			)

	UPDATE @tblLot
	SET intStorageLocationId = NULL
	WHERE intStorageLocationId = 0

	SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
	FROM tblMFCompanyPreference

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

	DECLARE @intBlendRequirementId INT
		,@strDemandNo NVARCHAR(50)
		,@intManufacturingProcessId INT
		,@dtmBusinessDate DATETIME
		,@intBusinessShiftId INT
		,@dtmCurrentDateTime DATETIME
		,@dtmProductionDate DATETIME

	SELECT @dtmCurrentDateTime = GetDate()

	SELECT @intWorkOrderId = intWorkOrderId
		,@intBlendRequirementId = intBlendRequirementId
	FROM @tblBlendSheet

	SELECT @strDemandNo = strDemandNo
	FROM tblMFBlendRequirement
	WHERE intBlendRequirementId = @intBlendRequirementId

	SELECT @intManufacturingProcessId = a.intManufacturingProcessId
	FROM tblMFRecipe a
	JOIN @tblBlendSheet b ON a.intItemId = b.intItemId
		AND a.intLocationId = b.intLocationId
		AND ysnActive = 1

	SELECT @intBlendItemId = intItemId
		,@intLocationId = intLocationId
		,@dblPlannedQuantity = dblPlannedQuantity
	FROM @tblBlendSheet

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDateTime, @intLocationId)

	SELECT @intBusinessShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	BEGIN TRAN

	IF @intWorkOrderId = 0
	BEGIN
		DECLARE @strNextWONo NVARCHAR(50)

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
			,ysnUseTemplate
			,strComment
			,dtmCreated
			,intCreatedUserId
			,dtmLastModified
			,intLastModifiedUserId
			,intConcurrencyId
			,intManufacturingProcessId
			)
		SELECT @strNextWONo
			,intItemId
			,dblQtyToProduce
			,intItemUOMId
			,2
			,intCellId
			,intMachineId
			,intLocationId
			,dblBinSize
			,dtmDueDate
			,0
			,1
			,dblPlannedQuantity
			,intBlendRequirementId
			,ysnKittingEnabled
			,ysnUseTemplate
			,strComment
			,GetDate()
			,intUserId
			,GetDate()
			,intUserId
			,intConcurrencyId + 1
			,@intManufacturingProcessId
		FROM @tblBlendSheet

		SET @intWorkOrderId = SCOPE_IDENTITY()
	END
	ELSE
		UPDATE a
		SET a.dblQuantity = b.dblQtyToProduce
			,a.intManufacturingCellId = b.intCellId
			,a.intMachineId = b.intMachineId
			,a.dblBinSize = b.dblBinSize
			,a.dtmExpectedDate = b.dtmDueDate
			,a.dblPlannedQuantity = b.dblPlannedQuantity
			,a.ysnKittingEnabled = b.ysnKittingEnabled
			,a.ysnUseTemplate = b.ysnUseTemplate
			,a.strComment = b.strComment
			,a.intLastModifiedUserId = b.intUserId
			,a.dtmLastModified = GetDate()
			,a.intConcurrencyId = a.intConcurrencyId + 1
		FROM tblMFWorkOrder a
		JOIN @tblBlendSheet b ON a.intWorkOrderId = b.intWorkOrderId

	--Delete From tblMFWorkOrderInputLot where intWorkOrderId=@intWorkOrderId
	SELECT @dtmProductionDate = dtmExpectedDate
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	DECLARE @intMinRowNo INT

	SELECT @intMinRowNo = Min(intRowNo)
	FROM @tblLot

	DECLARE @strRowState NVARCHAR(50)
		,@intWorkOrderInputLotId INT

	WHILE (@intMinRowNo IS NOT NULL)
	BEGIN
		SELECT @strRowState = strRowState
			,@intWorkOrderInputLotId = intWorkOrderInputLotId
		FROM @tblLot
		WHERE intRowNo = @intMinRowNo

		IF @strRowState = 'ADDED'
		BEGIN
			IF @ysnEnableParentLot = 0
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
					,intItemUOMId
					,dblIssuedQuantity
					,intItemIssuedUOMId
					,NULL
					,GetDate()
					,intUserId
					,GetDate()
					,intUserId
					,intRecipeItemId
					,@dtmProductionDate
					,@dtmBusinessDate
					,@intBusinessShiftId
				FROM @tblLot
				WHERE intRowNo = @intMinRowNo
			ELSE
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
					,intItemUOMId
					,dblIssuedQuantity
					,intItemIssuedUOMId
					,NULL
					,GetDate()
					,intUserId
					,GetDate()
					,intUserId
					,intRecipeItemId
					,dblWeightPerUnit
					,intLocationId
					,intStorageLocationId
				FROM @tblLot
				WHERE intRowNo = @intMinRowNo
		END

		IF @strRowState = 'MODIFIED'
		BEGIN
			IF @ysnEnableParentLot = 0
				UPDATE tblMFWorkOrderInputLot
				SET dblQuantity = (
						SELECT dblQty
						FROM @tblLot
						WHERE intRowNo = @intMinRowNo
						)
					,dblIssuedQuantity = (
						SELECT dblIssuedQuantity
						FROM @tblLot
						WHERE intRowNo = @intMinRowNo
						)
					,dtmProductionDate = @dtmProductionDate
					,dtmBusinessDate = @dtmBusinessDate
					,intBusinessShiftId = @intBusinessShiftId
				WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId
			ELSE
				UPDATE tblMFWorkOrderInputParentLot
				SET dblQuantity = (
						SELECT dblQty
						FROM @tblLot
						WHERE intRowNo = @intMinRowNo
						)
					,dblIssuedQuantity = (
						SELECT dblIssuedQuantity
						FROM @tblLot
						WHERE intRowNo = @intMinRowNo
						)
				WHERE intWorkOrderInputParentLotId = @intWorkOrderInputLotId
		END

		IF @strRowState = 'DELETE'
		BEGIN
			IF @ysnEnableParentLot = 0
				DELETE
				FROM tblMFWorkOrderInputLot
				WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId
			ELSE
				DELETE
				FROM tblMFWorkOrderInputParentLot
				WHERE intWorkOrderInputParentLotId = @intWorkOrderInputLotId
		END

		SELECT @intMinRowNo = Min(intRowNo)
		FROM @tblLot
		WHERE intRowNo > @intMinRowNo
	END

	--Insert Into tblMFWorkOrderInputLot(intWorkOrderId,intLotId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
	--dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId)
	--Select @intWorkOrderId,intLotId,dblQty,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,null,
	--GetDate(),intUserId,GetDate(),intUserId
	--From @tblLot
	--Update Bulk Item(By Location or FIFO) Standard Required Qty Calculated Using Planned Qty
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

	--Create Quality Computations
	EXEC uspMFCreateBlendRecipeComputation @intWorkOrderId = @intWorkOrderId
		,@intTypeId = 1
		,@strXml = @strXml

	COMMIT TRAN

	SELECT @intWorkOrderId AS intWorkOrderId
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
