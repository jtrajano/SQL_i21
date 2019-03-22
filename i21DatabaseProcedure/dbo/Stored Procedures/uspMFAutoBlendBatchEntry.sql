CREATE PROCEDURE [dbo].[uspMFAutoBlendBatchEntry]
	@Invoices	[dbo].[InvoicePostingTable] Readonly
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @intMinInvoice int
	DECLARE @intSalesOrderDetailId int=0
	DECLARE @intInvoiceDetailId int=0
	DECLARE @intLoadDistributionDetailId int=0
	DECLARE @intItemId int
	DECLARE @dblQtyToProduce numeric(38,20)
	DECLARE @intItemUOMId INT
	DECLARE @intLocationId int
	DECLARE @intSubLocationId int=NULL
	DECLARE @intStorageLocationId int=NULL
	DECLARE @intUserId int
	DECLARE @strActualCost NVARCHAR(20) = NULL
	DECLARE @dtmDate AS DATETIME = NULL 
	SET		@dtmDate = ISNULL(@dtmDate, GETDATE()) 
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strXml NVARCHAR(MAX)
	DECLARE @intSalesOrderLocationId int
	DECLARE @intRecipeId int
	DECLARE @intBlendItemId int
	DECLARE @intBlendItemUOMId int
	DECLARE @strItemNo nvarchar(50)
	DECLARE @strLocationName nvarchar(50)
	DECLARE @intCellId int
	DECLARE @intMinItem int
	DECLARE @intWorkOrderId int
	DECLARE @dblRequiredQty NUMERIC(38,20)
	DECLARE @intRawItemId int
	DECLARE @strRawItemTrackingType nvarchar(50)
	DECLARE @strBlendItemTrackingType nvarchar(50)
	DECLARE @intMinLot INT
	DECLARE @dblAvailableQty NUMERIC(38,20)
	DECLARE @intLotId int
	DECLARE @strRetBatchId NVARCHAR(50)
	DECLARE @intBlendLotId int
	DECLARE @intDayOfYear INT=DATEPART(dy, @dtmDate)
	DECLARE @dblItemAvailableQty NUMERIC(38,20)
	DECLARE @dblMaxProduceQty NUMERIC(38,20)
	DECLARE @dblRecipeQty NUMERIC(38,20)
	DECLARE @dblRawItemRecipeCalculatedQty NUMERIC(38,20)
	DECLARE @dblBlendBinSize NUMERIC(38,20)
	DECLARE @intNoOfBlendSheets INT
	DECLARE @dblWOQty NUMERIC(38,20)
	DECLARE @strWorkOrderConsumedLotsXml NVARCHAR(MAX)
	DECLARE @strLotNumber nvarchar(50)
	DECLARE @intBlendLotIssuesUOMId INT
	DECLARE @dblBlendLotIssuedQty NUMERIC(38,20)
	DECLARE @dblBlendLotWeightPerUnit NUMERIC(38,20)
	DECLARE @intMaxWorkOrderId INT
	DECLARE @intRecipeItemUOMId INT
	DECLARE @strOrderType nvarchar(50)
	DECLARE @intManufacturingProcessId int
	DECLARE @intMinWorkOrder int
	DECLARE @intRetLotId int
	DECLARE @dblWeightPerUnit NUMERIC(38,20)
	DECLARE @dblIssuedQuantity NUMERIC(38,20)
	DECLARE @intItemIssuedUOMId int
	DECLARE @intBatchId int
	DECLARE @intMachinId int
	DECLARE @intCategoryId int
	DECLARE @strDemandNo nvarchar(50) 
	DECLARE @strWorkOrderNo nvarchar(50) 

	DECLARE @tblInput table (
		 intInvoiceId int
		,dtmDate DateTime
		,intCompanyLocationId int
		,intInvoiceDetailId int
		,intItemId int
		,intItemUOMId int
		,intSubLocationId int
		,intStorageLocationId int
		,dblQuantity numeric(38,20)
		,intUserId int
		,intCellId int
		,intMachineId int
		,dblBlendBinSize numeric(38,20)
		,intBlendItemUOMId int
		,dblWOQuantity numeric(38,20)
		,strDemandNo nvarchar(50)
		,strWorkOrderNo nvarchar(50)
	)

	DECLARE @tblInputItem TABLE (
			intRowNo INT IDENTITY(1, 1)
			,intRecipeId INT
			,intRecipeItemId INT
			,intItemId INT
			,dblRequiredQty NUMERIC(38,20)
			,intItemUOMId int
			,ysnIsSubstitute BIT
			,ysnMinorIngredient BIT
			,intConsumptionMethodId INT
			,intConsumptionStoragelocationId INT
			,intParentItemId int
			,dblCalculatedQuantity NUMERIC(38,20)
			,dblMaxProduceQty NUMERIC(38,20)
		)

	DECLARE @tblLot TABLE (
			 intRowNo INT IDENTITY
			,intLotId INT
			,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
			,intItemId INT
			,dblQty NUMERIC(38,20)
			,intLocationId INT
			,intSubLocationId INT
			,intStorageLocationId INT
			,dtmCreateDate DATETIME
			,dtmExpiryDate DATETIME
			,dblUnitCost NUMERIC(38,20)
			,dblWeightPerQty NUMERIC(38, 20)
			,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
			,intParentLotId INT
			,intItemUOMId INT
			,intItemIssuedUOMId INT
		)

	DECLARE @tblPickedLot TABLE(
			 intRowNo INT IDENTITY
			,intInvoiceDetailId int
			,intLotId INT
			,intItemId INT
			,dblQty NUMERIC(38,20)
			,intItemUOMId INT
			,intLocationId INT
			,intSubLocationId INT
			,intStorageLocationId INT
		)

	DECLARE @tblBlendRequirementOutput table (intBlendRequirementId int,intInvoiceDetailId int)
	DECLARE @tblWorkOrderOutput table (intWorkOrderId int,intInvoiceDetailId int)

	--Add records from @Invoices table to @tblInput
	Insert Into @tblInput(intInvoiceId,dtmDate,intCompanyLocationId,intInvoiceDetailId,intItemId,intItemUOMId,intSubLocationId,intStorageLocationId,dblQuantity,intUserId)
	Select intInvoiceId,dtmDate,intCompanyLocationId,intInvoiceDetailId,intItemId,intItemUOMId,intSubLocationId,intStorageLocationId,dblQuantity,intUserId
	From @Invoices

	Select @intMinInvoice=MIN(intInvoiceDetailId) from @Invoices

	--Loop through Invoice Detail
	While (@intMinInvoice is not null)
	Begin
		Set @intBlendItemId=null
		Set @intBlendItemUOMId=null
		Set @intItemUOMId=null
		Set @intLocationId=null
		Set @intSubLocationId=null
		Set @intRecipeId=null
		Set @intCellId=null
		Set @intMachinId=null

		Select @dblQtyToProduce=t.dblQuantity,@intBlendItemId=t.intItemId,@intItemUOMId=t.intItemUOMId,@intLocationId=t.intCompanyLocationId,@intSubLocationId=intSubLocationId 
		From @tblInput t Where t.intInvoiceDetailId=@intMinInvoice

		Select @intCategoryId=intCategoryId From tblICItem where intItemId=@intBlendItemId

		--Get Recipe
		SELECT TOP 1 
				@intRecipeId = r.intRecipeId
				,@intBlendItemUOMId = r.intItemUOMId 
				,@dblRecipeQty = r.dblQuantity
				,@intManufacturingProcessId=r.intManufacturingProcessId  
		FROM	tblMFRecipe r JOIN tblMFManufacturingProcess mp 
					ON r.intManufacturingProcessId=mp.intManufacturingProcessId 
		WHERE	intItemId = @intBlendItemId 
				AND intLocationId = @intLocationId 
				AND ysnActive = 1 
				AND mp.intAttributeTypeId = 2

		--Get Default Cell
		SELECT TOP 1 
				@intCellId = fc.intManufacturingCellId 
		FROM	tblICItemFactoryManufacturingCell fc JOIN tblICItemFactory f 
					ON fc.intItemFactoryId = f.intItemFactoryId 
		WHERE	f.intItemId=@intBlendItemId 
				AND f.intFactoryId=@intLocationId 
		ORDER BY fc.ysnDefault DESC

		--Get Bin Size Using Default Cell And Machine
		SELECT TOP 1 
				@intMachinId = m.intMachineId,	
				@dblBlendBinSize = mp.dblMachineCapacity 
		FROM	tblMFMachine m JOIN tblMFMachinePackType mp 
					ON m.intMachineId = mp.intMachineId 
				JOIN tblMFManufacturingCellPackType mcp 
					ON mp.intPackTypeId = mcp.intPackTypeId 
				JOIN tblMFManufacturingCell mc 
					ON mcp.intManufacturingCellId = mc.intManufacturingCellId
		WHERE	mc.intManufacturingCellId=@intCellId

		SELECT	@dblQtyToProduce = dbo.fnMFConvertQuantityToTargetItemUOM(@intItemUOMId,@intBlendItemUOMId,@dblQtyToProduce)

		--Generate Demand No
		EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
			,@intItemId = @intBlendItemId
			,@intManufacturingId = NULL
			,@intSubLocationId = @intSubLocationId
			,@intLocationId = @intLocationId
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = NULL
			,@intPatternCode = 46
			,@ysnProposed = 0
			,@strPatternString = @strDemandNo OUTPUT

		--Generate WorkOrder No
		EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
		,@intItemId = @intItemId
		,@intManufacturingId = @intCellId
		,@intSubLocationId = 0
		,@intLocationId = @intLocationId
		,@intOrderTypeId = NULL
		,@intBlendRequirementId = NULL
		,@intPatternCode = 93
		,@ysnProposed = 0
		,@strPatternString = @strWorkOrderNo OUTPUT

		--update cell,machine in tblInput table
		Update @tblInput Set intCellId=@intCellId,intMachineId=@intMachinId,intBlendItemUOMId=@intBlendItemUOMId,dblBlendBinSize=@dblBlendBinSize,
		dblWOQuantity=@dblQtyToProduce,strDemandNo=@strDemandNo,strWorkOrderNo=@strWorkOrderNo 
		Where intInvoiceDetailId=@intMinInvoice

		Delete From @tblInputItem

		--Get Recipe Items
		INSERT INTO @tblInputItem (
				intRecipeId
				,intRecipeItemId
				,intItemId
				,dblRequiredQty
				,intItemUOMId
				,ysnIsSubstitute
				,ysnMinorIngredient
				,intConsumptionMethodId
				,intConsumptionStoragelocationId
				,intParentItemId
				,dblCalculatedQuantity
		)
		SELECT	@intRecipeId
				,ri.intRecipeItemId
				,ri.intItemId
				,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
				,ri.intItemUOMId
				,0 AS ysnIsSubstitute
				,ri.ysnMinorIngredient
				,ri.intConsumptionMethodId
				,ri.intStorageLocationId
				,0
				,ri.dblCalculatedQuantity
		FROM	tblMFRecipeItem ri
				JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		WHERE	r.intRecipeId = @intRecipeId
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
				AND ri.intConsumptionMethodId IN (1,2,3)

		--Pick Lots/Items
		SELECT	@intMinItem = MIN(intRowNo) 
		FROM	@tblInputItem 
		WHERE	ysnIsSubstitute = 0

		WHILE @intMinItem IS NOT NULL
		BEGIN
			SELECT	@intRawItemId = intItemId
					,@dblRequiredQty = dblRequiredQty
					,@dblRawItemRecipeCalculatedQty = dblCalculatedQuantity
					,@intRecipeItemUOMId = intItemUOMId 
			FROM	@tblInputItem 
			WHERE	intRowNo = @intMinItem

			SELECT	@strRawItemTrackingType=strLotTracking 
			FROM	tblICItem 
			WHERE	intItemId = @intRawItemId

			DELETE FROM @tblLot

			IF @strRawItemTrackingType = 'No'
			BEGIN 
				INSERT INTO @tblLot (
					 intLotId
					,strLotNumber
					,intItemId
					,dblQty
					,intLocationId
					,intSubLocationId
					,intStorageLocationId
					,dtmCreateDate
					,dtmExpiryDate
					,dblUnitCost
					,dblWeightPerQty
					,strCreatedBy
					,intParentLotId
					,intItemUOMId
					,intItemIssuedUOMId
				)
				SELECT 
						NULL
						,''
						,@intRawItemId
						,@dblRequiredQty
						,@intLocationId
						,NULL
						,NULL
						,NULL
						,NULL
						,0
						,1
						,''
						,0
						,@intRecipeItemUOMId
						,0 
			END
			ELSE
			BEGIN 
				INSERT INTO @tblLot (
						 intLotId
						,strLotNumber
						,intItemId
						,dblQty
						,intLocationId
						,intSubLocationId
						,intStorageLocationId
						,dtmCreateDate
						,dtmExpiryDate
						,dblUnitCost
						,dblWeightPerQty
						,strCreatedBy
						,intParentLotId
						,intItemUOMId
						,intItemIssuedUOMId
				)
				SELECT 
						L.intLotId
						,L.strLotNumber
						,L.intItemId
						,ISNULL(L.dblWeight,0) 
						- (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intLotId=L.intLotId AND ISNULL(ysnPosted,0)=0) 
						- (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From @tblPickedLot Where intLotId=L.intLotId) AS dblQty
						,L.intLocationId
						,L.intSubLocationId
						,L.intStorageLocationId
						,L.dtmDateCreated
						,L.dtmExpiryDate
						,L.dblLastCost
						,L.dblWeightPerQty
						,US.strUserName
						,L.intParentLotId
						,L.intWeightUOMId
						,L.intItemUOMId
				FROM	tblICLot L LEFT JOIN tblSMUserSecurity US 
							ON L.intCreatedEntityId = US.intEntityId
						JOIN tblICLotStatus LS 
							ON L.intLotStatusId = LS.intLotStatusId
						JOIN tblICStorageLocation SL 
							ON L.intStorageLocationId=SL.intStorageLocationId
				WHERE	L.intItemId = @intRawItemId
						AND L.intLocationId = @intLocationId
						AND LS.strPrimaryStatus IN ('Active')
						AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
						AND ISNULL(L.dblWeight,0) - (
								SELECT	ISNULL(SUM(ISNULL(dblQty,0)),0) 
								FROM	tblICStockReservation 
								WHERE	intLotId=L.intLotId 
										AND ISNULL(ysnPosted,0)=0
							) 
							- (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From @tblPickedLot Where intLotId=L.intLotId) >= .01
						AND ISNULL(SL.ysnAllowConsume,0)=1 
				ORDER BY L.dtmDateCreated
			END

			IF (SELECT COUNT(1) FROM @tblLot)=0 AND @strRawItemTrackingType <> 'No'
			BEGIN
				SELECT	@strItemNo=strItemNo 
				FROM	tblICItem 
				WHERE	intItemId = @intRawItemId
		
				SET @ErrMsg = 'Inventory is not available for item ' + @strItemNo + '.'
				RAISERROR(@ErrMsg,16,1)
			END

			SELECT @intMinLot = MIN(intRowNo) 
			FROM	@tblLot
	
			WHILE	@intMinLot IS NOT NULL
			BEGIN
				SELECT	@intLotId=intLotId
						,@dblAvailableQty=dblQty 
				FROM	@tblLot 
				WHERE	intRowNo = @intMinLot

				IF @dblAvailableQty >= @dblRequiredQty 
				BEGIN
					INSERT INTO @tblPickedLot(
							 intInvoiceDetailId
							,intLotId
							,intItemId
							,dblQty
							,intItemUOMId
							,intLocationId
							,intSubLocationId
							,intStorageLocationId
					)
					SELECT 
							 @intMinInvoice
							,@intLotId
							,@intRawItemId
							,@dblRequiredQty
							,intItemUOMId
							,intLocationId
							,intSubLocationId
							,intStorageLocationId 
					FROM	@tblLot 
					WHERE	intRowNo=@intMinLot

					GOTO NEXT_ITEM
				END
				ELSE
				BEGIN
					INSERT INTO @tblPickedLot(
							 intInvoiceDetailId
							,intLotId
							,intItemId
							,dblQty
							,intItemUOMId
							,intLocationId
							,intSubLocationId
							,intStorageLocationId
					)
					SELECT 
							 @intMinInvoice
							,@intLotId
							,@intRawItemId
							,@dblAvailableQty
							,intItemUOMId
							,intLocationId
							,intSubLocationId
							,intStorageLocationId 
					FROM	@tblLot 
					WHERE	intRowNo = @intMinLot

					SET	@dblRequiredQty = @dblRequiredQty - @dblAvailableQty
				END

				SELECT	@intMinLot = MIN(intRowNo) 
				FROM	@tblLot 
				WHERE	intRowNo > @intMinLot
			END

			NEXT_ITEM:
			SELECT	@intMinItem = MIN(intRowNo) 
			FROM	@tblInputItem 
			WHERE	ysnIsSubstitute = 0 
					AND intRowNo>@intMinItem
		END

	Select @intMinInvoice=MIN(intInvoiceDetailId) from @tblInput Where intInvoiceDetailId>@intMinInvoice
	End

	Begin Tran

	--Create Blend Demands
	Insert Into tblMFBlendRequirement(strDemandNo,intItemId,dblQuantity,intUOMId,dtmDueDate,intLocationId,intStatusId,dblIssuedQty,
	intCreatedUserId,dtmCreated,intLastModifiedUserId,dtmLastModified,intMachineId,intConcurrencyId)
	OUTPUT inserted.intBlendRequirementId,inserted.intConcurrencyId INTO @tblBlendRequirementOutput
	Select t.strDemandNo,t.intItemId,t.dblWOQuantity,iu.intUnitMeasureId,@dtmDate,t.intCompanyLocationId,2,t.dblWOQuantity,
	t.intUserId,GETDATE(),t.intUserId,GETDATE(),t.intMachineId,t.intInvoiceDetailId
	From @tblInput t Join tblICItemUOM iu on t.intBlendItemUOMId=iu.intItemUOMId

	--Create Work Orders
	insert into tblMFWorkOrder(strWorkOrderNo,intItemId,dblQuantity,intItemUOMId,intStatusId,intManufacturingCellId,intMachineId,intLocationId,dblBinSize,dtmExpectedDate,intExecutionOrder,
	intProductionTypeId,dblPlannedQuantity,intBlendRequirementId,dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,dtmReleasedDate,
	intManufacturingProcessId,intSalesOrderLineItemId,intInvoiceDetailId,intLoadDistributionDetailId,dtmPlannedDate,intConcurrencyId,dtmCompletedDate,intTransactionFrom)
	OUTPUT inserted.intWorkOrderId,inserted.intInvoiceDetailId INTO @tblWorkOrderOutput
	Select t.strWorkOrderNo,t.intItemId,t.dblWOQuantity,t.intBlendItemUOMId,13,t.intCellId,t.intMachineId,t.intCompanyLocationId,t.dblBlendBinSize,@dtmDate,1,
	1,t.dblWOQuantity,o.intBlendRequirementId,GETDATE(),t.intUserId,GETDATE(),t.intUserId,@dtmDate,
	@intManufacturingProcessId,null,t.intInvoiceDetailId,null,@dtmDate,1,GETDATE(),5
	From @tblInput t 
	join @tblBlendRequirementOutput o on o.intInvoiceDetailId=t.intInvoiceDetailId

	--Add Lots/Items to workorder consume table for all work orders
	INSERT INTO tblMFWorkOrderConsumedLot(
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
			,ysnStaged
			,intSubLocationId
			,intStorageLocationId
	)
	SELECT	t.intWorkOrderId
			,p.intLotId
			,p.intItemId
			,p.dblQty
			,p.intItemUOMId
			,p.dblQty
			,p.intItemUOMId
			,null
			,@dtmDate
			,@intUserId
			,@dtmDate
			,@intUserId
			,null
			,1
			,p.intSubLocationId
			,p.intStorageLocationId
	FROM	@tblWorkOrderOutput t join @tblPickedLot p on t.intInvoiceDetailId=p.intInvoiceDetailId

	Select @intMinWorkOrder=MIN(intWorkOrderId) from @tblWorkOrderOutput

	--Loop through WorkOrder for Post Consumption & Production
	While (@intMinWorkOrder is not null)
	Begin
		Set @intStorageLocationId=null
		Set @intItemUOMId=null
		Set @intBlendItemUOMId=null

		Select @intBlendItemId=v.intItemId,@intStorageLocationId=v.intStorageLocationId,
		@dblWOQty=v.dblWOQuantity,@intItemUOMId=v.intItemUOMId,@intBlendItemUOMId=v.intBlendItemUOMId,@intUserId=v.intUserId
		From @tblWorkOrderOutput w join @tblInput v on w.intInvoiceDetailId=v.intInvoiceDetailId 
		Where intWorkOrderId=@intMinWorkOrder

		IF @intItemUOMId <> @intBlendItemUOMId
		BEGIN
			SELECT	@dblWeightPerUnit = dblUnitQty 
			FROM	tblICItemUOM 
			WHERE	intItemUOMId = @intItemUOMId
		
			SET @dblIssuedQuantity = @dblWOQty/@dblWeightPerUnit
			SET @intItemIssuedUOMId = @intItemUOMId
		END
		ELSE
		BEGIN
			SET @dblWeightPerUnit = 1
			SET @dblIssuedQuantity = @dblWOQty
			SET @intItemIssuedUOMId = @intBlendItemUOMId
		END

		--Post Consumption
		EXEC uspMFPostConsumption
			 @ysnPost = 1
			,@ysnRecap = 0
			,@intWorkOrderId = @intMinWorkOrder
			,@intUserId = @intUserId
			,@intEntityId = NULL
			,@strRetBatchId = @strRetBatchId OUT
			,@intBatchId = NULL
			,@ysnPostGL = 1
			,@intLoadDistributionDetailId = null
			,@dtmDate = @dtmDate
		
		UPDATE	tblMFWorkOrder 
		SET		strBatchId = @strRetBatchId 
		WHERE	intWorkOrderId = @intMinWorkOrder

		SELECT @intBatchId = intBatchID
		FROM tblMFWorkOrder
		WHERE intWorkOrderId = @intMinWorkOrder

		--Post Production
		EXEC uspMFPostProduction 1
			,0
			,@intMinWorkOrder
			,@intBlendItemId
			,@intUserId
			,NULL
			,@intStorageLocationId
			,@dblWOQty
			,@intBlendItemUOMId
			,@dblWeightPerUnit
			,@dblIssuedQuantity
			,@intItemIssuedUOMId
			,@strRetBatchId
			,''
			,@intBatchId
			,@intRetLotId OUT
			,''
			,''
			,''
			,''
			,@dtmDate
			,null
			,null
			,null
			,null

		--Add to WorkOrder Produce Lot Table
		Insert Into tblMFWorkOrderProducedLot(intWorkOrderId,intLotId,intItemId,dblQuantity,intItemUOMId,dblPhysicalCount,intPhysicalItemUOMId,dblWeightPerUnit,
		intStorageLocationId,intBatchId,strBatchId,dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,dtmProductionDate,intConcurrencyId)
		Values(@intMinWorkOrder,@intRetLotId,@intBlendItemId,@dblWOQty,@intBlendItemUOMId,@dblIssuedQuantity,@intItemIssuedUOMId,@dblWeightPerUnit,
		@intStorageLocationId,@intBatchId,@strRetBatchId,@dtmDate,@intUserId,@dtmDate,@intUserId,@dtmDate,1)

		Select @intMinWorkOrder=MIN(intWorkOrderId) From @tblWorkOrderOutput Where intWorkOrderId>@intMinWorkOrder
	End

	Commit Tran

END TRY   
BEGIN CATCH  
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
END CATCH  
