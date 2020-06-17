CREATE PROCEDURE [dbo].[uspMFAutoBlend]
	@intSalesOrderDetailId int=0,
	@intInvoiceDetailId int=0,
	@intLoadDistributionDetailId int=0,
	@intItemId int,
	@dblQtyToProduce numeric(38,20),
	@intItemUOMId INT,
	@intLocationId int,
	@intSubLocationId int=NULL,
	@intStorageLocationId int=NULL,
	@intUserId int,
	@dblMaxQtyToProduce numeric(38,20) OUT,
	@dtmDate AS DATETIME = NULL 
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	SET @dtmDate = ISNULL(@dtmDate, GETDATE()) 

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strXml NVARCHAR(MAX)
	DECLARE @intSalesOrderLocationId int
	DECLARE @intRecipeId int
	DECLARE @intBlendItemId int
	DECLARE @intBlendItemUOMId int
	DECLARE @strItemNo nvarchar(50)
	DECLARE @strLocationName nvarchar(50)
	DECLARE @intCellId int
	--DECLARE @dtmDate DateTime=GETDATE()
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
			,@intLotItemUOMId int

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
		,intLotId INT
		,intItemId INT
		,dblQty NUMERIC(38,20)
		,intItemUOMId INT
		,intLocationId INT
		,intSubLocationId INT
		,intStorageLocationId INT
	)

	DECLARE @tblWorkOrderPickedLot TABLE(
		 intWorkOrderId INT 
		,intLotId INT
		,intItemId INT
		,dblQty NUMERIC(38,20)
		,intItemUOMId INT
		,intLocationId INT
		,intSubLocationId INT
		,intStorageLocationId INT
	)

	/******************************************************************************
	  BEGIN VALIDATIONS
	******************************************************************************/
	BEGIN 
		IF (ISNULL(@intSalesOrderDetailId,0)>0 AND ISNULL(@intInvoiceDetailId,0)>0 AND ISNULL(@intLoadDistributionDetailId,0)>0) 
		OR (ISNULL(@intSalesOrderDetailId,0)=0 AND ISNULL(@intInvoiceDetailId,0)=0 AND ISNULL(@intLoadDistributionDetailId,0)=0)
			RAISERROR('Supply either Sales Order Detail Id or Invoice Detail Id or Load Distribution Detail Id.',16,1)

		IF ISNULL(@intSalesOrderDetailId,0)>0
			SET @strOrderType='SALES ORDER'

		IF ISNULL(@intInvoiceDetailId,0)>0
			SET @strOrderType='INVOICE'

		IF ISNULL(@intLoadDistributionDetailId,0)>0
			SET @strOrderType='LOAD DISTRIBUTION'

		IF ISNULL(@dblQtyToProduce,0)=0
			RAISERROR('Quantity to produce should be greater than 0.',16,1)

		IF ISNULL(@intLocationId,0)=0
			RAISERROR('Location is not supplied.',16,1)

		IF ISNULL(@intItemUOMId,0)=0
			RAISERROR('Item UOM Id is not supplied.',16,1)

		IF @strOrderType='SALES ORDER'
		BEGIN
			IF ISNULL(@intSalesOrderDetailId,0)=0 OR NOT EXISTS (Select 1 From tblSOSalesOrderDetail Where intSalesOrderDetailId=ISNULL(@intSalesOrderDetailId,0))
				RAISERROR('Sales Order Detail does not exist.',16,1)

			IF EXISTS(SELECT 1 FROM tblMFWorkOrder WHERE intSalesOrderLineItemId = ISNULL(@intSalesOrderDetailId,0))
				IF EXISTS(
					SELECT	1 
					FROM	tblMFWorkOrderProducedLot 
					WHERE	intWorkOrderId IN (
								SELECT intWorkOrderId 
								FROM tblMFWorkOrder 
								WHERE intSalesOrderLineItemId = ISNULL(@intSalesOrderDetailId,0)
							) 
							AND ISNULL(ysnProductionReversed,0) = 0
				)
					RAISERROR('Sales Order Line is already blended.',16,1)

			SELECT 
					@intSalesOrderLocationId = s.intCompanyLocationId
					,@intBlendItemId = sd.intItemId
			FROM	tblSOSalesOrderDetail sd INNER JOIN tblSOSalesOrder s 
						ON sd.intSalesOrderId=s.intSalesOrderId 
			WHERE	intSalesOrderDetailId = @intSalesOrderDetailId

			IF @intSalesOrderLocationId <> ISNULL(@intLocationId,0)
				RAISERROR('Sales Order location is not same as supplied location.',16,1)

			IF @intBlendItemId <> ISNULL(@intItemId,0)
				RAISERROR('Sales Order detail item is not same as supplied item.',16,1)
		END

		IF @strOrderType = 'INVOICE'
		BEGIN
			IF ISNULL(@intInvoiceDetailId,0)=0 OR NOT EXISTS (SELECT 1 FROM tblARInvoiceDetail WHERE intInvoiceDetailId=ISNULL(@intInvoiceDetailId,0))
				RAISERROR('Invoice Detail does not exist.',16,1)

			IF EXISTS (SELECT 1 FROM tblMFWorkOrder WHERE intInvoiceDetailId=ISNULL(@intInvoiceDetailId,0))
				IF EXISTS(
					SELECT	1 
					FROM	tblMFWorkOrderProducedLot 
					WHERE	intWorkOrderId IN (
								SELECT	intWorkOrderId 
								From	tblMFWorkOrder 
								Where	intInvoiceDetailId = ISNULL(@intInvoiceDetailId,0)
							) 
							AND ISNULL(ysnProductionReversed,0)=0
				)
					RAISERROR('Invoice Line is already blended.',16,1)

			SELECT	@intSalesOrderLocationId=iv.intCompanyLocationId
					,@intBlendItemId=id.intItemId
			FROM	tblARInvoiceDetail id INNER JOIN tblARInvoice iv 
						ON id.intInvoiceId = iv.intInvoiceId
			WHERE	id.intInvoiceDetailId = @intInvoiceDetailId

			IF @intSalesOrderLocationId <> ISNULL(@intLocationId,0)
				RAISERROR('Invoice location is not same as supplied location.',16,1)

			IF @intBlendItemId <> ISNULL(@intItemId,0)
				RAISERROR('Invoice detail item is not same as supplied item.',16,1)
		END

		IF @strOrderType='LOAD DISTRIBUTION'
		BEGIN
			IF ISNULL(@intLoadDistributionDetailId,0)=0 OR NOT EXISTS (SELECT 1 FROM tblTRLoadDistributionDetail WHERE intLoadDistributionDetailId=ISNULL(@intLoadDistributionDetailId,0))
				RAISERROR('Load Distribution Detail does not exist.',16,1)

			IF EXISTS (SELECT 1 FROM tblMFWorkOrder WHERE intLoadDistributionDetailId=ISNULL(@intLoadDistributionDetailId,0))
				IF EXISTS(
					SELECT	1 
					FROM	tblMFWorkOrderProducedLot 
					WHERE	intWorkOrderId IN (
								SELECT	intWorkOrderId 
								FROM	tblMFWorkOrder 
								WHERE	intLoadDistributionDetailId = ISNULL(@intLoadDistributionDetailId,0)
							) 
							AND ISNULL(ysnProductionReversed,0) = 0
					)
					RAISERROR('Load Distribution Detail item is already blended.',16,1)

			SELECT	@intSalesOrderLocationId=h.intCompanyLocationId
					,@intBlendItemId=d.intItemId
			FROM	tblTRLoadDistributionDetail d INNER JOIN tblTRLoadDistributionHeader h 
						ON d.intLoadDistributionHeaderId = h.intLoadDistributionHeaderId
			WHERE	d.intLoadDistributionDetailId = @intLoadDistributionDetailId

			IF @intSalesOrderLocationId <> ISNULL(@intLocationId,0)
				RAISERROR('Load Distribution location is not same as supplied location.',16,1)

			IF @intBlendItemId <> ISNULL(@intItemId,0)
				RAISERROR('Load Distribution detail item is not same as supplied item.',16,1)
		END

		SELECT TOP 1 
				@intRecipeId = intRecipeId
				,@intBlendItemUOMId = intItemUOMId 
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
				@dblBlendBinSize = mp.dblMachineCapacity 
		FROM	tblMFMachine m JOIN tblMFMachinePackType mp 
					ON m.intMachineId = mp.intMachineId 
				JOIN tblMFManufacturingCellPackType mcp 
					ON mp.intPackTypeId = mcp.intPackTypeId 
				JOIN tblMFManufacturingCell mc 
					ON mcp.intManufacturingCellId = mc.intManufacturingCellId
		WHERE	mc.intManufacturingCellId=@intCellId

		SELECT	@strBlendItemTrackingType=strLotTracking 
		FROM	tblICItem 
		WHERE	intItemId=@intBlendItemId

		IF @strBlendItemTrackingType <> 'No'
		BEGIN
			IF ISNULL(@intSubLocationId,0)=0 
				RAISERROR('Sub Location is required for lot tracking blend item',16,1)

			IF ISNULL(@intStorageLocationId,0)=0 
				RAISERROR('Storage Location is required for lot tracking blend item',16,1)
		END

		IF ISNULL(@intSubLocationId,0) > 0 
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationSubLocationId=@intSubLocationId)
				RAISERROR('Invalid Sub Location',16,1)

			IF NOT EXISTS (
				SELECT	TOP 1 intCompanyLocationId 
				FROM	tblSMCompanyLocationSubLocation 
				WHERE	intCompanyLocationSubLocationId = @intSubLocationId
						AND intCompanyLocationId = @intLocationId
			)
				RAISERROR('Sub Location does not belong to location',16,1)
		END

		IF ISNULL(@intStorageLocationId,0) > 0 
		BEGIN
			IF NOT EXISTS (SELECT TOP 1 1 FROM tblICStorageLocation WHERE intStorageLocationId = @intStorageLocationId)
				RAISERROR('Invalid Storage Location',16,1)

			IF ISNULL(@intSubLocationId,0) = 0
				RAISERROR('Sub Location is required',16,1)
	 
			IF NOT EXISTS (
				SELECT	TOP 1 intSubLocationId 
				FROM	tblICStorageLocation 
				WHERE	intStorageLocationId = @intStorageLocationId 
						AND intSubLocationId = @intSubLocationId
			)
				RAISERROR('Storage Location does not belong to sub location',16,1)
		END

		IF ISNULL(@intRecipeId,0) = 0
		BEGIN
			SELECT	@strItemNo = strItemNo 
			FROM	tblICItem 
			Where	intItemId = @intBlendItemId
		
			SELECT	@strLocationName = strLocationName 
			FROM	tblSMCompanyLocation 
			WHERE	intCompanyLocationId=@intLocationId
		
			SET @ErrMsg='No Active Recipe found for item ' + @strItemNo + ' in location ' + @strLocationName + '.'
			RAISERROR(@ErrMsg,16,1)
		End

		IF ISNULL(@intCellId,0) = 0
		BEGIN
			SELECT	@strItemNo=strItemNo 
			FROM	tblICItem 
			WHERE	intItemId=@intBlendItemId
		
			SELECT	@strLocationName=strLocationName 
			FROM	tblSMCompanyLocation 
			WHERE	intCompanyLocationId = @intLocationId
		
			SET @ErrMsg='No Manufacturing Cell configured for item ' + @strItemNo + ' in location ' + @strLocationName + '.'
			RAISERROR(@ErrMsg,16,1)
		End

		IF ISNULL(@dblBlendBinSize,0)=0
			RAISERROR('Blend bin size is not defined. Please configure Blend bin size(Machine Capacity in Packing Types Tab) in Machine Configuration Screen.',16,1)
	END 
	/******************************************************************************
	  END VALIDATIONS
	******************************************************************************/

	SELECT	@dblQtyToProduce = dbo.fnMFConvertQuantityToTargetItemUOM(@intItemUOMId,@intBlendItemUOMId,@dblQtyToProduce)

	IF @strOrderType IN ('SALES ORDER','INVOICE')
	BEGIN 
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

		UNION ALL 	
		SELECT 
				@intRecipeId
				,rs.intRecipeSubstituteItemId
				,rs.intSubstituteItemId AS intItemId
				,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)) dblRequiredQty
				,ri.intItemUOMId
				,1 AS ysnIsSubstitute
				,0
				,1
				,0
				,ri.intItemId
				,ri.dblCalculatedQuantity
		FROM	tblMFRecipeSubstituteItem rs
				JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
				JOIN tblMFRecipeItem ri on rs.intRecipeItemId=ri.intRecipeItemId
		WHERE	r.intRecipeId = @intRecipeId
				AND rs.intRecipeItemTypeId = 1
		ORDER BY ysnIsSubstitute
	END 

	IF @strOrderType = 'LOAD DISTRIBUTION'
	BEGIN 
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
		SELECT 
				@intRecipeId
				,(
					CASE 
					WHEN BlendIngredient.ysnSubstituteItem = 1
						THEN (
								CASE 
									WHEN BlendIngredient.intSubstituteItemId = Receipt.intItemId
										THEN rs.intRecipeSubstituteItemId
									ELSE BlendIngredient.intRecipeItemId
									END
								)
					ELSE BlendIngredient.intRecipeItemId
					END
				)
				,(
					CASE 
					WHEN BlendIngredient.ysnSubstituteItem = 1
						THEN (
								CASE 
									WHEN BlendIngredient.intSubstituteItemId = Receipt.intItemId
										THEN BlendIngredient.intSubstituteItemId
									ELSE ri.intItemId
									END
								)
					ELSE ri.intItemId
					END
				)
				,BlendIngredient.dblQuantity
				,(
					CASE 
					WHEN BlendIngredient.ysnSubstituteItem = 1
						THEN (
								CASE 
									WHEN BlendIngredient.intSubstituteItemId = Receipt.intItemId
										THEN iu1.intItemUOMId
									ELSE ri.intItemUOMId
									END
								)
					ELSE ri.intItemUOMId
					END
				)
				,0
				,0
				,1
				,null
				,0
				,ri.dblCalculatedQuantity
				FROM tblTRLoadDistributionDetail DistItem
				LEFT JOIN tblTRLoadDistributionHeader HeaderDistItem ON HeaderDistItem.intLoadDistributionHeaderId = DistItem.intLoadDistributionHeaderId
				LEFT JOIN tblTRLoadHeader LoadHeader ON LoadHeader.intLoadHeaderId = HeaderDistItem.intLoadHeaderId
				LEFT JOIN tblTRLoadBlendIngredient BlendIngredient ON BlendIngredient.intLoadDistributionDetailId = DistItem.intLoadDistributionDetailId
				LEFT JOIN tblTRLoadReceipt Receipt ON Receipt.intLoadHeaderId = LoadHeader.intLoadHeaderId AND Receipt.strReceiptLine = BlendIngredient.strReceiptLink
				LEFT JOIN tblMFRecipeItem ri ON ri.intRecipeItemId=BlendIngredient.intRecipeItemId
				LEFT JOIN tblMFRecipeSubstituteItem rs ON rs.intRecipeItemId=BlendIngredient.intRecipeItemId AND rs.intSubstituteItemId=BlendIngredient.intSubstituteItemId
				LEFT JOIN dbo.tblICItemUOM iu ON iu.intItemUOMId = ri.intItemUOMId
				LEFT JOIN dbo.tblICItemUOM iu1 ON iu1.intItemId = BlendIngredient.intSubstituteItemId AND iu.intUnitMeasureId = iu1.intUnitMeasureId
				WHERE DistItem.intLoadDistributionDetailId = @intLoadDistributionDetailId
					AND ISNULL(DistItem.strReceiptLink, '') = ''
					AND ri.intRecipeId=@intRecipeId
					AND ri.intRecipeItemTypeId = 1

        IF (SELECT COUNT(1) FROM tblTRLoadBlendIngredient Where intLoadDistributionDetailId=@intLoadDistributionDetailId)=0
            RaisError('No Ingredients found in Transport.',16,1)

        IF Exists (SELECT 1 FROM tblTRLoadBlendIngredient Where intLoadDistributionDetailId=@intLoadDistributionDetailId AND ISNULL(dblQuantity,0)=0)
            RaisError('Ingredients Quantity cannot be 0.',16,1)

        IF (SELECT COUNT(1) FROM @tblInputItem)=0
            RaisError('No Ingredients found in Transport.',16,1)
	END

	SELECT	@dblRecipeQty = dblQuantity 
	FROM	tblMFRecipe 
	WHERE	intRecipeId = @intRecipeId

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
					0
					,''
					,S.intItemId
					,S.dblOnHand - S.dblUnitReserved 
					,@intLocationId
					,S.intStorageLocationId
					,S.intSubLocationId
					,NULL
					,NULL
					,0
					,1
					,''
					,0
					,S.intItemUOMId
					,0 
			FROM dbo.tblICItemStockUOM S
			JOIN dbo.tblICItemLocation IL ON IL.intItemLocationId = S.intItemLocationId
				AND S.intItemId = IL.intItemId
			JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = S.intItemUOMId
				AND IU.ysnStockUnit = 1
			WHERE S.intItemId = @intRawItemId
				AND IL.intLocationId = @intLocationId
				AND S.dblOnHand - S.dblUnitReserved > 0
	
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
					,(Case When L.intWeightUOMId is null Then L.dblQty Else ISNULL(L.dblWeight,0) End) - (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intLotId=L.intLotId AND ISNULL(ysnPosted,0)=0) AS dblQty
					,L.intLocationId
					,L.intSubLocationId
					,L.intStorageLocationId
					,L.dtmDateCreated
					,L.dtmExpiryDate
					,L.dblLastCost
					,L.dblWeightPerQty
					,US.strUserName
					,L.intParentLotId
					,IsNULL(L.intWeightUOMId,L.intItemUOMId)
					,L.intItemUOMId
			FROM	tblICLot L LEFT JOIN tblSMUserSecurity US 
						ON L.intCreatedEntityId = US.intEntityId
					JOIN tblICLotStatus LS 
						ON L.intLotStatusId = LS.intLotStatusId
					Left JOIN tblICStorageLocation SL 
						ON L.intStorageLocationId=SL.intStorageLocationId
			WHERE	L.intItemId = @intRawItemId
					AND L.intLocationId = @intLocationId
					AND LS.strPrimaryStatus IN ('Active')
					AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
					AND (Case When L.intWeightUOMId is null Then L.dblQty Else ISNULL(L.dblWeight,0) End) - (
							SELECT	ISNULL(SUM(ISNULL(dblQty,0)),0) 
							FROM	tblICStockReservation 
							WHERE	intLotId=L.intLotId 
									AND ISNULL(ysnPosted,0)=0
						) >= .01
					AND ISNULL(SL.ysnAllowConsume,1)=1 
			ORDER BY L.dtmDateCreated
		END

		IF (SELECT COUNT(1) FROM @tblLot)=0 AND @strOrderType IN ('SALES ORDER','INVOICE') AND @strRawItemTrackingType <> 'No'
		BEGIN
			SELECT	@strItemNo=strItemNo 
			FROM	tblICItem 
			WHERE	intItemId = @intRawItemId

			SELECT	@strLocationName = strLocationName 
			FROM	tblSMCompanyLocation 
			WHERE	intCompanyLocationId=@intLocationId
		
			SET @ErrMsg = 'Negative stock quantity is not allowed for item ' + @strItemNo + ' in location ' + @strLocationName + '.'
			RAISERROR(@ErrMsg,16,1)
		END

		SELECT	@dblItemAvailableQty = SUM(dblQty) 
		FROM	@tblLot

		IF @dblRequiredQty > @dblItemAvailableQty
		BEGIN
			SET @dblMaxProduceQty=(@dblItemAvailableQty * @dblRecipeQty) / @dblRawItemRecipeCalculatedQty
			UPDATE	@tblInputItem 
			SET		dblMaxProduceQty = @dblMaxProduceQty 
			WHERE	intRowNo=@intMinItem
		END

		SELECT @intMinLot = MIN(intRowNo) 
		FROM	@tblLot
	
		WHILE	@intMinLot IS NOT NULL
		BEGIN
			Select @intLotItemUOMId=NULL
			SELECT	@intLotId=intLotId
					,@dblAvailableQty=dblQty 
					,@intLotItemUOMId=intItemUOMId
			FROM	@tblLot 
			WHERE	intRowNo = @intMinLot

			IF @dblAvailableQty >= [dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, @intLotItemUOMId, @dblRequiredQty) 
			BEGIN
				INSERT INTO @tblPickedLot(
						intLotId
						,intItemId
						,dblQty
						,intItemUOMId
						,intLocationId
						,intSubLocationId
						,intStorageLocationId
				)
				SELECT 
						@intLotId
						,@intRawItemId
						,[dbo].[fnMFConvertQuantityToTargetItemUOM](@intRecipeItemUOMId, @intLotItemUOMId, @dblRequiredQty)
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
						intLotId
						,intItemId
						,dblQty
						,intItemUOMId
						,intLocationId
						,intSubLocationId
						,intStorageLocationId
				)
				SELECT 
						@intLotId
						,@intRawItemId
						,@dblAvailableQty
						,intItemUOMId
						,intLocationId
						,intSubLocationId
						,intStorageLocationId 
				FROM	@tblLot 
				WHERE	intRowNo = @intMinLot

				SET	@dblRequiredQty = @dblRequiredQty - [dbo].[fnMFConvertQuantityToTargetItemUOM](@intLotItemUOMId, @intRecipeItemUOMId, @dblAvailableQty)
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

	BEGIN TRAN

	--Create Work Order
	SET @strXml = '<root>'
	SET @strXml += '<intSalesOrderDetailId>' + ISNULL(CONVERT(VARCHAR,@intSalesOrderDetailId),'') + '</intSalesOrderDetailId>'
	SET @strXml += '<intInvoiceDetailId>' + ISNULL(CONVERT(VARCHAR,@intInvoiceDetailId),'') + '</intInvoiceDetailId>'
	SET @strXml += '<intLoadDistributionDetailId>' + ISNULL(CONVERT(VARCHAR,@intLoadDistributionDetailId),'') + '</intLoadDistributionDetailId>'
	SET @strXml += '<strOrderType>' + CONVERT(VARCHAR,@strOrderType) + '</strOrderType>'
	SET @strXml += '<intLocationId>' + CONVERT(VARCHAR,@intLocationId) + '</intLocationId>'
	SET @strXml += '<intRecipeId>' + CONVERT(VARCHAR,@intRecipeId) + '</intRecipeId>'
	SET @strXml += '<intItemId>' + CONVERT(VARCHAR,@intBlendItemId) + '</intItemId>'
	SET @strXml += '<intItemUOMId>' + CONVERT(VARCHAR,@intBlendItemUOMId) + '</intItemUOMId>'
	SET @strXml += '<intUserId>' + ISNULL(CONVERT(VARCHAR,@intUserId),'') + '</intUserId>'
	SET @strXml += '<intTransactionFrom>' + ISNULL(CONVERT(VARCHAR,5),'') + '</intTransactionFrom>'

	WHILE (@dblQtyToProduce>0)
	BEGIN
		IF @dblQtyToProduce < @dblBlendBinSize
			SET @dblBlendBinSize=@dblQtyToProduce

		SET @strXml += '<wo>'
		SET @strXml += '<dblQuantity>' + CONVERT(VARCHAR,@dblBlendBinSize) + '</dblQuantity>'
		SET @strXml += '<dtmDueDate>' + CONVERT(VARCHAR,@dtmDate) + '</dtmDueDate>'
		SET @strXml += '<intCellId>' + CONVERT(VARCHAR,@intCellId) + '</intCellId>'
		SET @strXml += '</wo>'

		SET @dblQtyToProduce = @dblQtyToProduce - @dblBlendBinSize
	END

	SET @strXml += '</root>'

	SELECT	@intMaxWorkOrderId = MAX(intWorkOrderId) 
	FROM	tblMFWorkOrder

	IF @intMaxWorkOrderId IS NULL
		SELECT @intMaxWorkOrderId = 0
	
	EXEC uspMFCreateWorkOrderFromSalesOrder @strXml

	IF @strOrderType='SALES ORDER'
		SELECT	@intWorkOrderId = MIN(intWorkOrderId) 
		FROM	tblMFWorkOrder 
		WHERE	intSalesOrderLineItemId = @intSalesOrderDetailId 
				AND intWorkOrderId > @intMaxWorkOrderId

	IF @strOrderType='INVOICE'
		SELECT	@intWorkOrderId = MIN(intWorkOrderId) 
		FROM	tblMFWorkOrder 
		WHERE	intInvoiceDetailId = @intInvoiceDetailId 
				AND intWorkOrderId > @intMaxWorkOrderId

	IF @strOrderType='LOAD DISTRIBUTION'
		SELECT	@intWorkOrderId = MIN(intWorkOrderId) 
		FROM	tblMFWorkOrder 
		WHERE	intLoadDistributionDetailId = @intLoadDistributionDetailId 
				AND intWorkOrderId > @intMaxWorkOrderId

	WHILE @intWorkOrderId IS NOT NULL
	BEGIN
		SELECT	@dblWOQty = dblQuantity 
		FROM	tblMFWorkOrder 
		WHERE	intWorkOrderId = @intWorkOrderId
	
		--Selects Lots/Items
		SET @intMinItem = NULL

		DELETE FROM @tblWorkOrderPickedLot

		SELECT	@intMinItem = MIN(intRowNo) 
		FROM	@tblInputItem 
		WHERE	ysnIsSubstitute = 0

		--Loop through Items
		WHILE @intMinItem IS NOT NULL
		BEGIN
			SET @intRawItemId = NULL
			SET @dblRawItemRecipeCalculatedQty = NULL
			SELECT	@intRawItemId = intItemId
					,@dblRawItemRecipeCalculatedQty = dblCalculatedQuantity 
					,@dblRequiredQty=dblRequiredQty
			FROM	@tblInputItem 
			WHERE	intRowNo = @intMinItem

			IF @strOrderType IN ('SALES ORDER','INVOICE')
				SET @dblRequiredQty = @dblRawItemRecipeCalculatedQty * (@dblWOQty / @dblRecipeQty)

			DELETE FROM @tblPickedLot WHERE dblQty <= 0

			--Loop through picked lot/item
			SET @intMinLot = NULL
			SELECT @intMinLot = MIN(intRowNo) FROM @tblPickedLot WHERE intItemId = @intRawItemId
			WHILE @intMinLot IS NOT NULL
			BEGIN
				SET @dblAvailableQty=NULL
				SET @intLotId=NULL
				SELECT	@intLotId=intLotId
						,@dblAvailableQty=dblQty 
				FROM	@tblPickedLot 
				WHERE	intRowNo = @intMinLot

				IF @dblAvailableQty >= @dblRequiredQty 
				BEGIN
					INSERT INTO @tblWorkOrderPickedLot(
						intWorkOrderId
						,intLotId
						,intItemId
						,dblQty
						,intItemUOMId
						,intLocationId
						,intSubLocationId
						,intStorageLocationId
					)
					SELECT 
						@intWorkOrderId
						,@intLotId
						,intItemId
						,@dblRequiredQty
						,intItemUOMId
						,intLocationId
						,intSubLocationId
						,intStorageLocationId 
					FROM	@tblPickedLot 
					WHERE	intRowNo = @intMinLot

					UPDATE	@tblPickedLot 
					SET		dblQty = @dblAvailableQty - @dblRequiredQty 
					WHERE	intRowNo = @intMinLot

					GOTO NEXT_ITEM_WO
				END
				ELSE
				BEGIN
					INSERT INTO @tblWorkOrderPickedLot(
							intWorkOrderId
							,intLotId
							,intItemId
							,dblQty
							,intItemUOMId
							,intLocationId
							,intSubLocationId
							,intStorageLocationId
					)
					SELECT 
							@intWorkOrderId
							,@intLotId
							,intItemId
							,@dblAvailableQty
							,intItemUOMId
							,intLocationId
							,intSubLocationId
							,intStorageLocationId 
					FROM	@tblPickedLot 
					WHERE	intRowNo=@intMinLot

					SET @dblRequiredQty = @dblRequiredQty - @dblAvailableQty

					UPDATE	@tblPickedLot 
					SET		dblQty = 0
					WHERE	intRowNo=@intMinLot
				END

				SELECT	@intMinLot = MIN(intRowNo) 
				FROM	@tblPickedLot 
				WHERE	intRowNo > @intMinLot
			END

			NEXT_ITEM_WO:
			SELECT	@intMinItem = MIN(intRowNo) 
			FROM	@tblInputItem 
			WHERE	ysnIsSubstitute = 0 
					AND intRowNo>@intMinItem
		END

		UPDATE	@tblWorkOrderPickedLot 
		SET		intLotId = NULL 
		WHERE	intLotId = 0

		--Add Lots/Items to workorder consume table
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
		SELECT	@intWorkOrderId
				,intLotId
				,intItemId
				,dblQty
				,intItemUOMId
				,dblQty
				,intItemUOMId
				,null
				,@dtmDate
				,@intUserId
				,@dtmDate
				,@intUserId
				,null
				,1
				,intSubLocationId
				,intStorageLocationId
		FROM	@tblWorkOrderPickedLot

		--Start Blend Sheet
		UPDATE	tblMFWorkOrder 
		SET		intStatusId = 10
				,dtmStartedDate = GETDATE()
				,intLastModifiedUserId=@intUserId
				,dtmLastModified = GETDATE() 
		WHERE	intWorkOrderId = @intWorkOrderId

		--Consume Lots/Items/End Blend Sheet
		EXEC uspMFPostConsumption
			@ysnPost = 1
			,@ysnRecap = 0
			,@intWorkOrderId = @intWorkOrderId
			,@intUserId = @intUserId
			,@intEntityId = NULL
			,@strRetBatchId = @strRetBatchId OUT
			,@intBatchId = NULL
			,@ysnPostGL = 1
			,@intLoadDistributionDetailId = @intLoadDistributionDetailId
			,@dtmDate = @dtmDate

		--Check if the consumption entries exist
		IF (SELECT COUNT(1) FROM tblMFWorkOrderConsumedLot WHERE intWorkOrderId = @intWorkOrderId)=0
			RAISERROR('No consumption entries found.',16,1)

		UPDATE	tblMFWorkOrder 
		SET		intStatusId=12
				,dtmCompletedDate = GETDATE()
				,intLastModifiedUserId = @intUserId
				,dtmLastModified = GETDATE()
				,strBatchId = @strRetBatchId 
		WHERE	intWorkOrderId = @intWorkOrderId

		IF @intItemUOMId <> @intBlendItemUOMId
		BEGIN
			SELECT	@dblBlendLotWeightPerUnit = dblUnitQty 
			FROM	tblICItemUOM 
			WHERE	intItemUOMId = @intItemUOMId
		
			SET @dblBlendLotIssuedQty = @dblWOQty/@dblBlendLotWeightPerUnit
			SET @intBlendLotIssuesUOMId = @intItemUOMId
		END
		ELSE
		BEGIN
			SET @dblBlendLotWeightPerUnit = 1
			SET @dblBlendLotIssuedQty = @dblWOQty
			SET @intBlendLotIssuesUOMId = @intBlendItemUOMId
		END

		--Produce Lot
		SET @strXml = '<root>'
		SET @strXml += '<intWorkOrderId>' + CONVERT(VARCHAR,@intWorkOrderId) + '</intWorkOrderId>'
		SET @strXml += '<intItemId>' + CONVERT(VARCHAR,@intBlendItemId) + '</intItemId>'
		SET @strXml += '<dblQtyToProduce>' + CONVERT(VARCHAR,@dblWOQty) + '</dblQtyToProduce>'
		SET @strXml += '<intItemUOMId>' + CONVERT(VARCHAR,@intBlendItemUOMId) + '</intItemUOMId>'
		SET @strXml += '<dblIssuedQuantity>' + CONVERT(VARCHAR,@dblBlendLotIssuedQty) + '</dblIssuedQuantity>'
		SET @strXml += '<intItemIssuedUOMId>' + CONVERT(VARCHAR,@intBlendLotIssuesUOMId) + '</intItemIssuedUOMId>'
		SET @strXml += '<dblWeightPerUnit>' + CONVERT(VARCHAR,@dblBlendLotWeightPerUnit) + '</dblWeightPerUnit>'
		SET @strXml += '<intLocationId>' + CONVERT(VARCHAR,@intLocationId) + '</intLocationId>'
		SET @strXml += '<intStorageLocationId>' + ISNULL(CONVERT(VARCHAR,@intStorageLocationId),'') + '</intStorageLocationId>'
		SET @strXml += '<strVesselNo>' + CONVERT(VARCHAR,'') + '</strVesselNo>'
		SET @strXml += '<intManufacturingCellId>' + CONVERT(VARCHAR,@intCellId) + '</intManufacturingCellId>'
		SET @strXml += '<dblPlannedQuantity>' + CONVERT(VARCHAR,@dblWOQty) + '</dblPlannedQuantity>'
		SET @strXml += '<intUserId>' + ISNULL(CONVERT(VARCHAR,@intUserId),'') + '</intUserId>'
		SET @strXml += '<dtmProductionDate>' + ISNULL(CONVERT(VARCHAR,@dtmDate),'') + '</dtmProductionDate>'

		SELECT @strWorkOrderConsumedLotsXml =
			COALESCE(@strWorkOrderConsumedLotsXml, '') + '<lot>' +  '<intWorkOrderId>' + CONVERT(VARCHAR,@intWorkOrderId) + '</intWorkOrderId>' + 
			'<intWorkOrderConsumedLotId>' + CONVERT(VARCHAR,wc.intWorkOrderConsumedLotId) + '</intWorkOrderConsumedLotId>' + 
			'<intLotId>' + ISNULL(CONVERT(VARCHAR,wc.intLotId),'') + '</intLotId>' + 
			'<intItemId>' + CONVERT(VARCHAR,wc.intItemId) + '</intItemId>' + 
			'<dblQty>' + CONVERT(VARCHAR,wc.dblQuantity) + '</dblQty>' + 
			'<intItemUOMId>' + CONVERT(VARCHAR,wc.intItemUOMId) + '</intItemUOMId>' + 
			'<dblIssuedQuantity>' + CONVERT(VARCHAR,wc.dblIssuedQuantity) + '</dblIssuedQuantity>' + 
			'<intItemIssuedUOMId>' + CONVERT(VARCHAR,wc.intItemIssuedUOMId) + '</intItemIssuedUOMId>' + 
			'<dblWeightPerUnit>' + CONVERT(VARCHAR,0) + '</dblWeightPerUnit>' + 
			'<intRecipeItemId>' + ISNULL(CONVERT(VARCHAR,wc.intRecipeItemId),'') + '</intRecipeItemId>' + 
			'<ysnStaged>' + CONVERT(VARCHAR,wc.ysnStaged) + '</ysnStaged>' + 
			'<intSubLocationId>' + ISNULL(CONVERT(VARCHAR,wc.intSubLocationId),'') + '</intSubLocationId>' + 
			'<intStorageLocationId>' + ISNULL(CONVERT(VARCHAR,wc.intStorageLocationId),'') + '</intStorageLocationId>' + '</lot>' 
		FROM	tblMFWorkOrderConsumedLot wc 
		WHERE	intWorkOrderId = @intWorkOrderId

		SET @strXml += ISNULL(@strWorkOrderConsumedLotsXml,'')
		SET @strXml += '</root>'

		EXEC uspMFCompleteBlendSheet 
			@strXml = @strXml
			,@intLoadDistributionDetailId = @intLoadDistributionDetailId
			,@intLotId = @intBlendLotId OUT
			,@strLotNumber = @strLotNumber OUT
			,@ysnAutoBlend=1
			
		If @strOrderType='LOAD DISTRIBUTION'
		Begin
			If (Select Count(1) From tblTRLoadBlendIngredient Where intLoadDistributionDetailId=@intLoadDistributionDetailId) 
				<> (Select Count(1) From tblMFWorkOrderConsumedLot Where intWorkOrderId=@intWorkOrderId)
				RAISERROR('All the ingredients found in Transport are not consumed.',16,1)

			If Exists(
				Select 1 From
					(Select intItemId,SUM(dblRequiredQty) dblQuantity From @tblInputItem group by intItemId) t1
				Join 
					(Select intItemId,SUM(dblQuantity) dblQuantity From tblMFWorkOrderConsumedLot Where intWorkOrderId=@intWorkOrderId group by intItemId) t2
					on t1.intItemId=t2.intItemId
					Where t1.dblQuantity<>t2.dblQuantity
				)
				RAISERROR('Quantity mismatch between Transport Ingredient and Blend Consumption.',16,1)
		End

		IF @strOrderType='SALES ORDER'
			SELECT	@intWorkOrderId = MIN(intWorkOrderId) 
			FROM	tblMFWorkOrder 
			WHERE	intSalesOrderLineItemId = @intSalesOrderDetailId 
					AND intWorkOrderId > @intWorkOrderId

		IF @strOrderType='INVOICE'
			SELECT	@intWorkOrderId = MIN(intWorkOrderId) 
			FROM	tblMFWorkOrder 
			WHERE	intInvoiceDetailId = @intInvoiceDetailId 
					AND intWorkOrderId > @intWorkOrderId

		IF @strOrderType='LOAD DISTRIBUTION'
			SELECT	@intWorkOrderId = MIN(intWorkOrderId) 
			FROM	tblMFWorkOrder 
			WHERE	intLoadDistributionDetailId = @intLoadDistributionDetailId 
					AND intWorkOrderId > @intWorkOrderId
	END
	COMMIT TRAN
END TRY   
BEGIN CATCH  
	 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
	--IF @InitialTransaction = 0
	--	IF (XACT_STATE()) <> 0
	--		ROLLBACK TRANSACTION 
	--ELSE
	--	IF (XACT_STATE()) <> 0
	--		ROLLBACK TRANSACTION @Savepoint
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
END CATCH  