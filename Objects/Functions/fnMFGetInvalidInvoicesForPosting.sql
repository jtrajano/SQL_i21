CREATE FUNCTION [dbo].[fnMFGetInvalidInvoicesForPosting]
(
	 @Invoices	[dbo].[InvoicePostingTable] Readonly
	,@Post		BIT	= 0
)
RETURNS @returntable TABLE
(
	 [intInvoiceId]				INT				NOT NULL
	,[strInvoiceNumber]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strTransactionType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[intInvoiceDetailId]		INT				NULL
	,[intItemId]				INT				NULL
	,[strBatchId]				NVARCHAR(40)	COLLATE Latin1_General_CI_AS	NULL
	,[strPostingError]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
)
AS
BEGIN

	DECLARE @ZeroDecimal DECIMAL(18,6)
	SET @ZeroDecimal = 0.000000	
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

	--Add records from @Invoices table to @tblInput
	Insert Into @tblInput(intInvoiceId,dtmDate,intCompanyLocationId,intInvoiceDetailId,intItemId,intItemUOMId,intSubLocationId,intStorageLocationId,dblQuantity,intUserId)
	Select intInvoiceId,dtmDate,intCompanyLocationId,intInvoiceDetailId,intItemId,intItemUOMId,intSubLocationId,intStorageLocationId,dblQuantity,intUserId
	From @Invoices

	Select @intMinInvoice=MIN(intInvoiceDetailId) from @Invoices

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
		Set @ErrMsg=null

		IF EXISTS (SELECT 1 FROM tblMFWorkOrder WHERE intInvoiceDetailId=ISNULL(@intInvoiceDetailId,0))
			IF EXISTS(
				SELECT	1 
				FROM	tblMFWorkOrderProducedLot 
				WHERE	intWorkOrderId IN (
							SELECT	intWorkOrderId 
							From	tblMFWorkOrder 
							Where	intInvoiceDetailId = ISNULL(@intMinInvoice,0)
						) 
						AND ISNULL(ysnProductionReversed,0)=0
			)
			--Add the error msg to return table
			INSERT INTO @returntable(
					[intInvoiceId]
				,[strInvoiceNumber]
				,[strTransactionType]
				,[intInvoiceDetailId]
				,[intItemId]
				,[strBatchId]
				,[strPostingError])
			Select intInvoiceId,strInvoiceNumber,strTransactionType,intInvoiceDetailId,intItemId,strBatchId,'Invoice Line is already blended.'
			From @Invoices 
			Where intInvoiceDetailId=@intMinInvoice

		Select @dblQtyToProduce=t.dblQuantity,@intBlendItemId=t.intItemId,@intItemUOMId=t.intItemUOMId,@intLocationId=t.intCompanyLocationId,@intSubLocationId=intSubLocationId 
		From @tblInput t Where t.intInvoiceDetailId=@intMinInvoice

		Select @intCategoryId=intCategoryId From tblICItem where intItemId=@intBlendItemId

		--Get Recipe
		SELECT TOP 1 
				@intRecipeId = r.intRecipeId
				,@intBlendItemUOMId = r.intItemUOMId 
				,@dblRecipeQty = r.dblQuantity 
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
						,sd.intItemId
						,dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,@intRecipeItemUOMId,sd.dblAvailableQty)
						- (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From @tblPickedLot Where intItemId=sd.intItemId)
						,sd.intLocationId
						,sd.intSubLocationId
						,sd.intStorageLocationId
						,NULL
						,NULL
						,0
						,sd.dblUnitQty
						,''
						,0
						,@intRecipeItemUOMId
						,0 
				FROM	vyuMFGetItemStockDetail sd 
				WHERE	sd.intItemId=@intRawItemId 
						AND sd.dblAvailableQty > .01 
						AND sd.intLocationId = @intLocationId 
						AND ISNULL(sd.ysnStockUnit,0) = 1 
				ORDER BY sd.intItemStockUOMId
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

				--Add the error msg to return table
				INSERT INTO @returntable(
					 [intInvoiceId]
					,[strInvoiceNumber]
					,[strTransactionType]
					,[intInvoiceDetailId]
					,[intItemId]
					,[strBatchId]
					,[strPostingError])
				Select intInvoiceId,strInvoiceNumber,strTransactionType,intInvoiceDetailId,intItemId,strBatchId,@ErrMsg
				From @Invoices 
				Where intInvoiceDetailId=@intMinInvoice
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
																												
	RETURN
END
