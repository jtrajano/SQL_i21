CREATE PROCEDURE [dbo].[uspMFReleaseBlendSheet] @strXml NVARCHAR(Max)
	,@strWorkOrderNoOut NVARCHAR(50) = '' OUT
	,@dblBalancedQtyToProduceOut NUMERIC(38,20) = 0 OUTPUT
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
	DECLARE @dblQtyToProduce NUMERIC(38,20)
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
	DECLARE @dblBinSize NUMERIC(38,20)
	DECLARE @intNoOfSheet INT
	DECLARE @intNoOfSheetOriginal INT
	DECLARE @dblRemainingQtyToProduce NUMERIC(38,20)
	DECLARE @PerBlendSheetQty NUMERIC(38,20)
	DECLARE @ysnCalculateNoSheetUsingBinSize BIT = 0
	DECLARE @ysnKittingEnabled BIT
	DECLARE @ysnRequireCustomerApproval BIT
	DECLARE @intWorkOrderStatusId INT
	DECLARE @intKitStatusId INT = NULL
	DECLARE @dblBulkReqQuantity NUMERIC(38,20)
	DECLARE @dblPlannedQuantity NUMERIC(38,20)
	Declare @ysnAllInputItemsMandatory bit
			,@dtmBusinessDate DATETIME
		,@intBusinessShiftId INT
		,@dtmCurrentDateTime DATETIME
		,@dtmProductionDate DATETIME
	Declare @intCategoryId int
	Declare @strInActiveItems nvarchar(max)
	DECLARE @dtmDate DATETIME=Convert(DATE, GetDate())
	DECLARE @intDayOfYear INT=DATEPART(dy, @dtmDate)
	Declare @strPackagingCategoryId NVARCHAR(Max)
	Declare @intPlannedShiftId int
	DECLARE @strSavedWONo NVARCHAR(50)

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
		,dblQtyToProduce NUMERIC(38,20)
		,dblPlannedQuantity NUMERIC(38,20)
		,dblBinSize NUMERIC(38,20)
		,strComment NVARCHAR(Max)
		,ysnUseTemplate BIT
		,ysnKittingEnabled BIT
		,intLocationId INT
		,intBlendRequirementId INT
		,intItemUOMId INT
		,intUserId INT
		,intPlannedShiftId INT
		)
	DECLARE @tblItem TABLE (
		intRowNo INT Identity(1, 1)
		,intItemId INT
		,dblReqQty NUMERIC(38,20)
		,ysnIsSubstitute BIT
		,intConsumptionMethodId INT
		,intConsumptionStoragelocationId INT
		,intParentItemId int
		)
	DECLARE @tblLot TABLE (
		intRowNo INT Identity(1, 1)
		,intLotId INT
		,intItemId INT
		,dblQty NUMERIC(38,20)
		,dblIssuedQuantity NUMERIC(38,20)
		,dblWeightPerUnit NUMERIC(38,20)
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
		,dblQty NUMERIC(38,20)
		,intUOMId INT
		,dblIssuedQuantity NUMERIC(38,20)
		,intIssuedUOMId INT
		,dblWeightPerUnit NUMERIC(38,20)
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
			,dblQtyToProduce NUMERIC(38,20)
			,dblPlannedQuantity NUMERIC(38,20)
			,dblBinSize NUMERIC(38,20)
			,strComment NVARCHAR(Max)
			,ysnUseTemplate BIT
			,ysnKittingEnabled BIT
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
			,dblQty NUMERIC(38,20)
			,dblIssuedQuantity NUMERIC(38,20)
			,dblPickedQuantity NUMERIC(38,20)
			,dblWeightPerUnit NUMERIC(38,20)
			,intItemUOMId INT
			,intItemIssuedUOMId INT
			,intUserId INT
			,intRecipeItemId INT
			,intLocationId INT
			,intStorageLocationId INT
			,ysnParentLot BIT
			)

--Available Qty Check
Declare @tblLotSummary AS table
(
	intRowNo int IDENTITY,
	intLotId INT,
	intItemId int,
	dblQty NUMERIC(38,20),
	intRecipeItemId int	
)
Declare @dblInputAvlQty NUMERIC(38,20)
Declare @dblInputReqQty NUMERIC(38,20)
Declare @intInputLotId int
Declare @intInputItemId int
Declare @strInputLotNumber nvarchar(50)

Select @intLocationId=intLocationId From @tblBlendSheet

SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
FROM tblMFCompanyPreference

INSERT INTO @tblLotSummary(intLotId,intItemId,dblQty)
Select intLotId,intItemId,SUM(dblQty) From @tblLot GROUP BY intLotId,intItemId

Declare @intMinLot INT
Select @intMinLot=Min(intRowNo) From @tblLotSummary
While(@intMinLot is not null) and @ysnEnableParentLot=0
Begin
	Select @intInputLotId=intLotId,@dblInputReqQty=dblQty,@intInputItemId=intItemId From @tblLotSummary Where intRowNo=@intMinLot
	Select @dblInputAvlQty=CASE WHEN isnull(l.dblWeight,0)>0 Then l.dblWeight Else dbo.fnMFConvertQuantityToTargetItemUOM(l.intItemUOMId,tl.intItemUOMId,l.dblQty) End 
	- (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intLotId=@intInputLotId AND ISNULL(ysnPosted,0)=0) 
	From tblICLot l join @tblLot tl on l.intLotId=tl.intLotId Where l.intLotId=@intInputLotId

	if @dblInputReqQty > @dblInputAvlQty
	Begin
		Select @strInputLotNumber=strLotNumber From tblICLot Where intLotId=@intInputLotId
		Select @strInputItemNo=strItemNo From tblICItem Where intItemId=@intInputItemId

		Set @ErrMsg='Quantity of ' + CONVERT(varchar,@dblInputReqQty) + ' from lot ' + @strInputLotNumber + ' of item ' + CONVERT(nvarchar,@strInputItemNo) +
		+ ' cannot be added to blend sheet because the lot has available qty of ' + CONVERT(varchar,@dblInputAvlQty) + '.'
		RaisError(@ErrMsg,16,1)
	End

	Select @intMinLot=Min(intRowNo) From @tblLotSummary Where intRowNo>@intMinLot
End
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
			FROM @tblLot l join tblICItem i on l.intItemId=i.intItemId Where i.intCategoryId not in (Select * from dbo.[fnCommaSeparatedValueToTable](@strPackagingCategoryId))
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
	FROM @tblBlendSheet

	SELECT @strDemandNo = strDemandNo
	FROM tblMFBlendRequirement
	WHERE intBlendRequirementId = @intBlendRequirementId

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
		SET a.dblWeightPerUnit = CASE WHEN b.dblWeightPerQty > 0 THEN b.dblWeightPerQty ELSE iu1.dblUnitQty/iu.dblUnitQty END
		FROM @tblLot a
		JOIN tblICLot b ON a.intLotId = b.intLotId
		LEFT JOIN tblICItemUOM iu on a.intItemUOMId=iu.intItemUOMId
		LEFT JOIN tblICItemUOM iu1 on a.intItemIssuedUOMId=iu1.intItemUOMId
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

	Select @ysnAllInputItemsMandatory=CASE When UPPER(pa.strAttributeValue) = 'TRUE' then 1 Else 0 End 
	From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
	and UPPER(at.strAttributeName)=UPPER('All input items mandatory for consumption')

	Select @intPlannedShiftId=intPlannedShiftId From @tblBlendSheet
	IF ISNULL(@intPlannedShiftId,0)=0
	BEGIN
		If ISNULL(@intBusinessShiftId,0)=0
			BEGIN
				SELECT @intPlannedShiftId = intShiftId
				FROM dbo.tblMFShift
				WHERE intLocationId = @intLocationId
					AND intShiftSequence = 1
			END
		Else
			Set @intPlannedShiftId=@intBusinessShiftId

		Update @tblBlendSheet set intPlannedShiftId=@intPlannedShiftId
	END

	--Missing Item Check / Required Qty Check
	if @ysnAllInputItemsMandatory=1
	Begin
		Insert into @tblItem(intItemId,dblReqQty,ysnIsSubstitute,intConsumptionMethodId,intConsumptionStoragelocationId,intParentItemId)
		Select ri.intItemId,(ri.dblCalculatedQuantity * (@dblPlannedQuantity/r.dblQuantity)) AS RequiredQty,0 AS ysnIsSubstitute,ri.intConsumptionMethodId,ri.intStorageLocationId,0
		From tblMFRecipeItem ri 
		Join tblMFRecipe r on r.intRecipeId=ri.intRecipeId 
		where ri.intRecipeId=@intRecipeId and ri.intRecipeItemTypeId=1
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
		AND ri.intConsumptionMethodId IN (1,2,3)
		UNION
		Select rs.intSubstituteItemId,(rs.dblQuantity * (@dblPlannedQuantity/r.dblQuantity)) AS RequiredQty,1 AS ysnIsSubstitute,0,0,rs.intItemId
		From tblMFRecipeSubstituteItem rs 
		Join tblMFRecipe r on r.intRecipeId=rs.intRecipeId 
		where rs.intRecipeId=@intRecipeId and rs.intRecipeItemTypeId=1

		Declare @intMinMissingItem INT
		Declare @intConsumptionMethodId int
		Declare @dblInputItemBSQty numeric(38,20)
		Declare @dblBulkItemAvlQty numeric(38,20)

		Select @intMinMissingItem=Min(intRowNo) From @tblItem
		While(@intMinMissingItem is not null)
		Begin
			Select @intInputItemId=intItemId,@dblInputReqQty=dblReqQty,@intConsumptionMethodId=intConsumptionMethodId 
			From @tblItem Where intRowNo=@intMinMissingItem AND ysnIsSubstitute=0

			If @intConsumptionMethodId=1
			Begin
				If Not Exists (Select 1 From @tblLot Where intItemId=@intInputItemId) 
				AND 
				Not Exists (Select 1 From @tblLot Where intItemId=(Select intItemId From @tblItem Where intParentItemId=@intInputItemId))
				Begin
					Select @strInputItemNo=strItemNo From tblICItem Where intItemId=@intInputItemId

					Set @ErrMsg='There is no lot selected for item ' + CONVERT(nvarchar,@strInputItemNo) + '.'
					RaisError(@ErrMsg,16,1)
				End

				Select @dblInputItemBSQty=ISNULL(SUM(ISNULL(dblQty,0)),0) From @tblLot Where intItemId=@intInputItemId

				--Include Sub Items
				Set @dblInputItemBSQty=@dblInputItemBSQty + (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From @tblLot 
				Where intItemId in (Select intItemId From @tblItem Where intParentItemId = @intInputItemId))

				if @dblInputItemBSQty < @dblInputReqQty
				Begin
					Select @strInputItemNo=strItemNo From tblICItem Where intItemId=@intInputItemId

					Set @ErrMsg='Selected quantity of ' + CONVERT(varchar,@dblInputItemBSQty) + ' of item ' + CONVERT(nvarchar,@strInputItemNo) +
					+ ' is less than the required quantity of ' + CONVERT(varchar,@dblInputReqQty) + '.'
					RaisError(@ErrMsg,16,1)
				End
			End
		
			--Bulk
			If @intConsumptionMethodId in (2,3)
			Begin
				Select @dblBulkItemAvlQty=ISNULL(SUM(ISNULL(dblWeight,0)),0) From tblICLot l Join tblICLotStatus ls on l.intLotStatusId=ls.intLotStatusId
				Where l.intItemId=@intInputItemId AND l.intLocationId = @intLocationId
					AND ls.strPrimaryStatus IN (
						'Active'
						,'Quarantine'
						)
					AND (l.dtmExpiryDate IS NULL OR l.dtmExpiryDate >= GETDATE())
					AND l.dblWeight >0

					--Iclude Sub Items
					Set @dblBulkItemAvlQty = @dblBulkItemAvlQty + (Select ISNULL(SUM(ISNULL(dblWeight,0)),0) From tblICLot l Join tblICLotStatus ls on l.intLotStatusId=ls.intLotStatusId
					Where l.intItemId in (Select intItemId From @tblItem Where intParentItemId = @intInputItemId)
					AND l.intLocationId = @intLocationId
					AND ls.strPrimaryStatus IN (
						'Active'
						,'Quarantine'
						)
					AND (l.dtmExpiryDate IS NULL OR l.dtmExpiryDate >= GETDATE())
					AND l.dblWeight >0)

				if @dblBulkItemAvlQty < @dblInputReqQty
				Begin
					Select @strInputItemNo=strItemNo From tblICItem Where intItemId=@intInputItemId

					Set @ErrMsg='Required quantity of ' + CONVERT(varchar,@dblInputReqQty) + ' of bulk item ' + CONVERT(nvarchar,@strInputItemNo) +
					+ ' is not avaliable.'
					RaisError(@ErrMsg,16,1)
				End
			End

			Select @intMinMissingItem=Min(intRowNo) From @tblItem Where intRowNo>@intMinMissingItem AND ysnIsSubstitute=0
		End
	End

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
	Begin
		Select @strSavedWONo=strWorkOrderNo From tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

		DELETE
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId
	End

	DECLARE @intItemCount INT
		,@intLotCount INT
		,@intItemId INT
		,@dblReqQty NUMERIC(38,20)
		,@intLotId INT
		,@dblQty NUMERIC(38,20)

	SELECT @intExecutionOrder = Count(1)
	FROM tblMFWorkOrder
	WHERE intManufacturingCellId = @intCellId
		AND convert(DATE, dtmExpectedDate) = convert(DATE, @dtmDueDate)
		AND intBlendRequirementId IS NOT NULL
		AND intStatusId NOT IN (
			2
			,13
			)

	WHILE (@intNoOfSheet > 0 and @dblQtyToProduce>1)
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
							ELSE @dblReqQty / CASE WHEN dblWeightPerUnit > 0 THEN dblWeightPerUnit ELSE 1.0 END
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
							ELSE @dblQty / CASE WHEN dblWeightPerUnit > 0 THEN dblWeightPerUnit ELSE 1.0 END
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
		If ISNULL(@strSavedWONo,'')=''
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
		Else
		Begin
			Set @strNextWONo=@strSavedWONo
			Set @strSavedWONo=''
		End

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
			,intTransactionFrom
			,intPlannedShiftId
			,dtmPlannedDate
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
			,1
			,intPlannedShiftId
			,dtmDueDate
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
		FROM @tblLot l join tblICItem i on l.intItemId=i.intItemId 
		Where l.intItemId NOT IN (Select intItemId From tblMFWorkOrderRecipeItem 
		Where intWorkOrderId=@intWorkOrderId AND intRecipeItemTypeId=1 
		Union
		Select intSubstituteItemId From tblMFWorkOrderRecipeSubstituteItem Where intWorkOrderId=@intWorkOrderId)

		If ISNULL(@strInActiveItems,'')<>''
		Begin
			Set @ErrMsg='Recipe ingredient items ' + @strInActiveItems + ' are inactive. Please remove the lots belong to the inactive items from blend sheet.'
			RaisError(@ErrMsg,16,1)
		End

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
						join tblICItem i on wi.intItemId=i.intItemId AND i.intCategoryId not in (Select * from dbo.[fnCommaSeparatedValueToTable](@strPackagingCategoryId))
						WHERE intWorkOrderId = @intWorkOrderId
						)
				WHERE intWorkOrderId = @intWorkOrderId
			ELSE
				UPDATE tblMFWorkOrder
				SET dblQuantity = (
						SELECT sum(dblQuantity)
						FROM tblMFWorkOrderInputLot wi 
						join tblICItem i on wi.intItemId=i.intItemId AND i.intCategoryId not in (Select * from dbo.[fnCommaSeparatedValueToTable](@strPackagingCategoryId))
						WHERE intWorkOrderId = @intWorkOrderId
						)
				WHERE intWorkOrderId = @intWorkOrderId
		ELSE
			UPDATE tblMFWorkOrder
			SET dblQuantity = (
					SELECT sum(dblQuantity)
					FROM tblMFWorkOrderInputParentLot wi 
						join tblICItem i on wi.intItemId=i.intItemId AND i.intCategoryId not in (Select * from dbo.[fnCommaSeparatedValueToTable](@strPackagingCategoryId))
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
