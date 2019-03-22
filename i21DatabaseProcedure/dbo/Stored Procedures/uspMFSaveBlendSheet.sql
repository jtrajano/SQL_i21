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
	DECLARE @dblPlannedQuantity NUMERIC(38,20)
	DECLARE @dblBulkReqQuantity NUMERIC(38,20)
	Declare @intCategoryId int
	Declare @intCellId int
	Declare @strPackagingCategoryId NVARCHAR(Max)
	DECLARE @dblWOQuantity NUMERIC(38,20)
	Declare @intPlannedShiftId int

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
		,dblQtyToProduce NUMERIC(38,20)
		,dblPlannedQuantity NUMERIC(38,20)
		,intItemUOMId INT
		,dblBinSize NUMERIC(38,20)
		,strComment NVARCHAR(Max)
		,ysnUseTemplate BIT
		,ysnKittingEnabled BIT
		,intLocationId INT
		,intPlannedShiftId INT
		,intUserId INT
		,intConcurrencyId INT
		)
	DECLARE @tblLot TABLE (
		intRowNo INT Identity(1, 1)
		,intWorkOrderInputLotId INT
		,intLotId INT
		,intItemId INT
		,dblQty NUMERIC(38,20)
		,intItemUOMId INT
		,dblIssuedQuantity NUMERIC(38,20)
		,intItemIssuedUOMId INT
		,dblWeightPerUnit NUMERIC(38,20)
		,intUserId INT
		,strRowState NVARCHAR(50)
		,intRecipeItemId INT
		,intLocationId INT
		,intStorageLocationId INT
		,ysnParentLot BIT
		)

	Declare @tblPackagingCategoryId Table 
	(
		intCategoryId int
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
		,intPlannedShiftId
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
		,intPlannedShiftId
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
			,dblQtyToProduce NUMERIC(38,20)
			,dblPlannedQuantity NUMERIC(38,20)
			,intItemUOMId INT
			,dblBinSize NUMERIC(38,20)
			,strComment NVARCHAR(Max)
			,ysnUseTemplate BIT
			,ysnKittingEnabled BIT
			,intLocationId INT
			,intPlannedShiftId INT
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
			,dblQty NUMERIC(38,20)
			,intItemUOMId INT
			,dblIssuedQuantity NUMERIC(38,20)
			,intItemIssuedUOMId INT
			,dblWeightPerUnit NUMERIC(38,20)
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
		,@intCellId = intCellId
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
	Select @intCategoryId=intCategoryId From tblICItem Where intItemId=@intBlendItemId

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDateTime, @intLocationId)

	SELECT @intBusinessShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	SELECT @strPackagingCategoryId = ISNULL(pa.strAttributeValue, '')
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND at.strAttributeName = 'Packaging Category'

	Select @intPlannedShiftId=intPlannedShiftId From @tblBlendSheet
	IF ISNULL(@intPlannedShiftId,0)=0
	BEGIN
		SELECT @intPlannedShiftId = intShiftId
		FROM dbo.tblMFShift
		WHERE intLocationId = @intLocationId
			AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
				AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

		IF @intPlannedShiftId IS NULL
		BEGIN
			SELECT @intPlannedShiftId = intShiftId
			FROM dbo.tblMFShift
			WHERE intLocationId = @intLocationId
				AND intShiftSequence = 1
		END

		Update @tblBlendSheet set intPlannedShiftId=@intPlannedShiftId
	END

	BEGIN TRAN

	IF @intWorkOrderId = 0
	BEGIN
		DECLARE @strNextWONo NVARCHAR(50)

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

		--Exclude Packing category while summing weight
		Update @tblBlendSheet Set dblQtyToProduce=(Select SUM(ISNULL(dblQty,0)) 
		From @tblLot l 
		join tblICItem i on l.intItemId=i.intItemId Where i.intCategoryId not in (Select * from dbo.fnCommaSeparatedValueToTable(@strPackagingCategoryId)))

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
			,intTransactionFrom
			,intPlannedShiftId
			,dtmPlannedDate
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
			,1
			,intPlannedShiftId
			,dtmDueDate
		FROM @tblBlendSheet

		SET @intWorkOrderId = SCOPE_IDENTITY()
	END
	ELSE
		UPDATE a
		SET  a.intManufacturingCellId = b.intCellId
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
			,a.intPlannedShiftId=b.intPlannedShiftId
			,a.dtmPlannedDate = b.dtmDueDate
		FROM tblMFWorkOrder a
		JOIN @tblBlendSheet b ON a.intWorkOrderId = b.intWorkOrderId

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

	IF @ysnEnableParentLot = 0
	Select @dblWOQuantity = SUM(ISNULL(dblQuantity,0)) 
		From tblMFWorkOrderInputLot wi 
		join tblICItem i on wi.intItemId=i.intItemId 
		Where wi.intWorkOrderId=@intWorkOrderId AND i.intCategoryId not in (Select * from dbo.fnCommaSeparatedValueToTable(@strPackagingCategoryId))
	Else
	Select @dblWOQuantity = SUM(ISNULL(dblQuantity,0)) 
		From tblMFWorkOrderInputParentLot wi 
		join tblICItem i on wi.intItemId=i.intItemId 
		Where wi.intWorkOrderId=@intWorkOrderId AND i.intCategoryId not in (Select * from dbo.fnCommaSeparatedValueToTable(@strPackagingCategoryId))
					
	UPDATE tblMFWorkOrder
	SET dblQuantity = ISNULL(@dblWOQuantity,0) + ISNULL(@dblBulkReqQuantity,0)
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
