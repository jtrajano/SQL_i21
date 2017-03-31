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
	@dblMaxQtyToProduce numeric(38,20) OUT
AS
BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @ErrMsg NVARCHAR(MAX)
Declare @strXml NVARCHAR(MAX)
Declare @intSalesOrderLocationId int
Declare @intRecipeId int
Declare @intBlendItemId int
Declare @intBlendItemUOMId int
Declare @strItemNo nvarchar(50)
Declare @strLocationName nvarchar(50)
Declare @intCellId int
Declare @dtmDate DateTime=GETDATE()
Declare @intMinItem int
Declare @intWorkOrderId int
Declare @dblRequiredQty NUMERIC(38,20)
Declare @intRawItemId int
Declare @strRawItemTrackingType nvarchar(50)
Declare @strBlendItemTrackingType nvarchar(50)
Declare @intMinLot INT
Declare @dblAvailableQty NUMERIC(38,20)
Declare @intLotId int
Declare @strRetBatchId NVARCHAR(50)
Declare @intBlendLotId int
DECLARE @intDayOfYear INT=DATEPART(dy, @dtmDate)
Declare @dblItemAvailableQty NUMERIC(38,20)
Declare @dblMaxProduceQty NUMERIC(38,20)
Declare @dblRecipeQty NUMERIC(38,20)
Declare @dblRawItemRecipeCalculatedQty NUMERIC(38,20)
Declare @dblBlendBinSize NUMERIC(38,20)
Declare @intNoOfBlendSheets INT
Declare @dblWOQty NUMERIC(38,20)
Declare @strWorkOrderConsumedLotsXml NVARCHAR(MAX)
Declare @strLotNumber nvarchar(50)
Declare @intBlendLotIssuesUOMId INT
Declare @dblBlendLotIssuedQty NUMERIC(38,20)
Declare @dblBlendLotWeightPerUnit NUMERIC(38,20)
Declare @intMaxWorkOrderId INT
Declare @intRecipeItemUOMId INT
Declare @strOrderType nvarchar(50)

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

If (ISNULL(@intSalesOrderDetailId,0)>0 AND ISNULL(@intInvoiceDetailId,0)>0 AND ISNULL(@intLoadDistributionDetailId,0)>0) 
OR (ISNULL(@intSalesOrderDetailId,0)=0 AND ISNULL(@intInvoiceDetailId,0)=0 AND ISNULL(@intLoadDistributionDetailId,0)=0)
	RaisError('Supply either Sales Order Detail Id or Invoice Detail Id or Load Distribution Detail Id.',16,1)

If ISNULL(@intSalesOrderDetailId,0)>0
	Set @strOrderType='SALES ORDER'

If ISNULL(@intInvoiceDetailId,0)>0
	Set @strOrderType='INVOICE'

If ISNULL(@intLoadDistributionDetailId,0)>0
Set @strOrderType='LOAD DISTRIBUTION'

If ISNULL(@dblQtyToProduce,0)=0
	RaisError('Quantity to produce should be greater than 0.',16,1)

If ISNULL(@intLocationId,0)=0
	RaisError('Location is not supplied.',16,1)

If ISNULL(@intItemUOMId,0)=0
	RaisError('Item UOM Id is not supplied.',16,1)

If @strOrderType='SALES ORDER'
Begin
	If ISNULL(@intSalesOrderDetailId,0)=0 OR NOT EXISTS (Select 1 From tblSOSalesOrderDetail Where intSalesOrderDetailId=ISNULL(@intSalesOrderDetailId,0))
		RaisError('Sales Order Detail does not exist.',16,1)

	If Exists(Select 1 From tblMFWorkOrder Where intSalesOrderLineItemId=ISNULL(@intSalesOrderDetailId,0))
		If Exists(Select 1 From tblMFWorkOrderProducedLot Where intWorkOrderId in 
		(Select intWorkOrderId From tblMFWorkOrder Where intSalesOrderLineItemId=ISNULL(@intSalesOrderDetailId,0)) 
		AND ISNULL(ysnProductionReversed,0)=0)
			RaisError('Sales Order Line is already blended.',16,1)

	Select @intSalesOrderLocationId=s.intCompanyLocationId,@intBlendItemId=sd.intItemId
	From tblSOSalesOrderDetail sd Join tblSOSalesOrder s on sd.intSalesOrderId=s.intSalesOrderId 
	Where intSalesOrderDetailId=@intSalesOrderDetailId

	If @intSalesOrderLocationId <> ISNULL(@intLocationId,0)
		RaisError('Sales Order location is not same as supplied location.',16,1)

	If @intBlendItemId <> ISNULL(@intItemId,0)
		RaisError('Sales Order detail item is not same as supplied item.',16,1)
End

If @strOrderType='INVOICE'
Begin
	If ISNULL(@intInvoiceDetailId,0)=0 OR NOT EXISTS (Select 1 From tblARInvoiceDetail Where intInvoiceDetailId=ISNULL(@intInvoiceDetailId,0))
		RaisError('Invoice Detail does not exist.',16,1)

	If Exists (Select 1 From tblMFWorkOrder Where intInvoiceDetailId=ISNULL(@intInvoiceDetailId,0))
		If Exists(Select 1 From tblMFWorkOrderProducedLot Where intWorkOrderId in 
		(Select intWorkOrderId From tblMFWorkOrder Where intInvoiceDetailId=ISNULL(@intInvoiceDetailId,0)) 
		AND ISNULL(ysnProductionReversed,0)=0)
			RaisError('Invoice Line is already blended.',16,1)

	Select @intSalesOrderLocationId=iv.intCompanyLocationId,@intBlendItemId=id.intItemId
	From tblARInvoiceDetail id Join tblARInvoice iv on id.intInvoiceId=iv.intInvoiceId
	Where id.intInvoiceDetailId=@intInvoiceDetailId

	If @intSalesOrderLocationId <> ISNULL(@intLocationId,0)
		RaisError('Invoice location is not same as supplied location.',16,1)

	If @intBlendItemId <> ISNULL(@intItemId,0)
		RaisError('Invoice detail item is not same as supplied item.',16,1)
End

If @strOrderType='LOAD DISTRIBUTION'
Begin
	If ISNULL(@intLoadDistributionDetailId,0)=0 OR NOT EXISTS (Select 1 From tblTRLoadDistributionDetail Where intLoadDistributionDetailId=ISNULL(@intLoadDistributionDetailId,0))
		RaisError('Load Distribution Detail does not exist.',16,1)

	If Exists (Select 1 From tblMFWorkOrder Where intLoadDistributionDetailId=ISNULL(@intLoadDistributionDetailId,0))
		If Exists(Select 1 From tblMFWorkOrderProducedLot Where intWorkOrderId in 
		(Select intWorkOrderId From tblMFWorkOrder Where intLoadDistributionDetailId=ISNULL(@intLoadDistributionDetailId,0)) 
		AND ISNULL(ysnProductionReversed,0)=0)
			RaisError('Load Distribution Detail item is already blended.',16,1)

	Select @intSalesOrderLocationId=h.intCompanyLocationId,@intBlendItemId=d.intItemId
	From tblTRLoadDistributionDetail d Join tblTRLoadDistributionHeader h on d.intLoadDistributionHeaderId=h.intLoadDistributionHeaderId
	Where d.intLoadDistributionDetailId=@intLoadDistributionDetailId

	If @intSalesOrderLocationId <> ISNULL(@intLocationId,0)
		RaisError('Load Distribution location is not same as supplied location.',16,1)

	If @intBlendItemId <> ISNULL(@intItemId,0)
		RaisError('Load Distribution detail item is not same as supplied item.',16,1)
End

Select TOP 1 @intRecipeId=intRecipeId,@intBlendItemUOMId=intItemUOMId 
From tblMFRecipe r Join tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId 
Where intItemId=@intBlendItemId AND intLocationId=@intLocationId AND ysnActive=1 AND mp.intAttributeTypeId=2

--Get Default Cell
Select TOP 1 @intCellId = fc.intManufacturingCellId From tblICItemFactoryManufacturingCell fc join tblICItemFactory f on fc.intItemFactoryId=f.intItemFactoryId 
Where f.intItemId=@intBlendItemId AND f.intFactoryId=@intLocationId Order By fc.ysnDefault DESC

--Get Bin Size Using Default Cell And Machine
Select TOP 1 @dblBlendBinSize=mp.dblMachineCapacity 
From tblMFMachine m Join tblMFMachinePackType mp on m.intMachineId=mp.intMachineId 
Join tblMFManufacturingCellPackType mcp on mp.intPackTypeId=mcp.intPackTypeId 
Join tblMFManufacturingCell mc on mcp.intManufacturingCellId=mc.intManufacturingCellId
Where mc.intManufacturingCellId=@intCellId

If ISNULL(@dblBlendBinSize,0)=0
	RaisError('Blend bin size is not defined',16,1)

Select @strBlendItemTrackingType=strLotTracking From tblICItem Where intItemId=@intBlendItemId

If @strBlendItemTrackingType <> 'No'
Begin
	If ISNULL(@intSubLocationId,0)=0 
		RaisError('Sub Location is required for lot tracking blend item',16,1)

	If ISNULL(@intStorageLocationId,0)=0 
		RaisError('Storage Location is required for lot tracking blend item',16,1)
End

If ISNULL(@intSubLocationId,0) > 0 
Begin
	If Not Exists (Select 1 From tblSMCompanyLocationSubLocation Where intCompanyLocationSubLocationId=@intSubLocationId)
		RaisError('Invalid Sub Location',16,1)

	If (Select intCompanyLocationId From tblSMCompanyLocationSubLocation Where intCompanyLocationSubLocationId=@intSubLocationId)<>@intLocationId
		RaisError('Sub Location does not belong to location',16,1)
End

If ISNULL(@intStorageLocationId,0) > 0 
Begin
	If Not Exists (Select 1 From tblICStorageLocation Where intStorageLocationId=@intStorageLocationId)
		RaisError('Invalid Storage Location',16,1)

	If ISNULL(@intSubLocationId,0) = 0
		RaisError('Sub Location is required',16,1)
	 
	If (Select intSubLocationId From tblICStorageLocation Where intStorageLocationId=@intStorageLocationId)<>@intSubLocationId
		RaisError('Storage Location does not belong to sub location',16,1)
End

If ISNULL(@intRecipeId,0)=0
Begin
	Select @strItemNo=strItemNo From tblICItem Where intItemId=@intBlendItemId
	Select @strLocationName=strLocationName From tblSMCompanyLocation Where intCompanyLocationId=@intLocationId
	Set @ErrMsg='No Active Recipe found for item ' + @strItemNo + ' in location ' + @strLocationName + '.'
	RaisError(@ErrMsg,16,1)
End

If ISNULL(@intCellId,0)=0
Begin
	Select @strItemNo=strItemNo From tblICItem Where intItemId=@intBlendItemId
	Select @strLocationName=strLocationName From tblSMCompanyLocation Where intCompanyLocationId=@intLocationId
	Set @ErrMsg='No Manufacturing Cell configured for item ' + @strItemNo + ' in location ' + @strLocationName + '.'
	RaisError(@ErrMsg,16,1)
End

Select @dblQtyToProduce=dbo.fnMFConvertQuantityToTargetItemUOM(@intItemUOMId,@intBlendItemUOMId,@dblQtyToProduce)

If @strOrderType IN ('SALES ORDER','INVOICE')
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
SELECT @intRecipeId
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
FROM tblMFRecipeItem ri
JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
WHERE r.intRecipeId = @intRecipeId
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
 	
UNION
	
SELECT @intRecipeId
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
FROM tblMFRecipeSubstituteItem rs
JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
JOIN tblMFRecipeItem ri on rs.intRecipeItemId=ri.intRecipeItemId
WHERE r.intRecipeId = @intRecipeId
	AND rs.intRecipeItemTypeId = 1
ORDER BY ysnIsSubstitute

If @strOrderType = 'LOAD DISTRIBUTION'
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
Select @intRecipeId,ri.intRecipeItemId,ri.intItemId,v.dblQuantity,ri.intItemUOMId,0,0,ri.intConsumptionMethodId,ri.intStorageLocationId,0,ri.dblCalculatedQuantity
From tblTRLoadBlendIngredient v Join tblMFRecipeItem ri on v.intRecipeItemId =ri.intRecipeItemId
Where intLoadDistributionDetailId=@intLoadDistributionDetailId AND ri.intRecipeId=@intRecipeId AND ri.intRecipeItemTypeId=1

Select @dblRecipeQty=dblQuantity From tblMFRecipe Where intRecipeId=@intRecipeId

--Pick Lots/Items

Select @intMinItem = MIN(intRowNo) From @tblInputItem Where ysnIsSubstitute=0

While @intMinItem is not null
Begin
	Select @intRawItemId=intItemId,@dblRequiredQty=dblRequiredQty,@dblRawItemRecipeCalculatedQty=dblCalculatedQuantity,@intRecipeItemUOMId=intItemUOMId 
	From @tblInputItem Where intRowNo=@intMinItem

	Select @strRawItemTrackingType=strLotTracking From tblICItem Where intItemId=@intRawItemId

	DELETE FROM @tblLot

	If @strRawItemTrackingType='No'
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
	Select 0,'',sd.intItemId,dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,@intRecipeItemUOMId,sd.dblAvailableQty),
	sd.intLocationId,sd.intSubLocationId,sd.intStorageLocationId,NULL,NULL,0,sd.dblUnitQty,'',0,@intRecipeItemUOMId,0 
	From vyuMFGetItemStockDetail sd 
	Where sd.intItemId=@intRawItemId AND sd.dblAvailableQty > .01 AND sd.intLocationId=@intLocationId AND ISNULL(sd.ysnStockUnit,0)=1 ORDER BY sd.intItemStockUOMId
	Else
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
SELECT L.intLotId
	,L.strLotNumber
	,L.intItemId
	,ISNULL(L.dblWeight,0) - (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intLotId=L.intLotId AND ISNULL(ysnPosted,0)=0) AS dblQty
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
FROM tblICLot L
LEFT JOIN tblSMUserSecurity US ON L.intCreatedEntityId = US.[intEntityId]
JOIN tblICLotStatus LS ON L.intLotStatusId = LS.intLotStatusId
JOIN tblICStorageLocation SL ON L.intStorageLocationId=SL.intStorageLocationId
WHERE L.intItemId = @intRawItemId
	AND L.intLocationId = @intLocationId
	AND LS.strPrimaryStatus IN (
		'Active'
		)
	AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
	AND ISNULL(L.dblWeight,0) - (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intLotId=L.intLotId AND ISNULL(ysnPosted,0)=0)  >= .01
	AND ISNULL(SL.ysnAllowConsume,0)=1 
	ORDER BY L.dtmDateCreated

	If (Select COUNT(1) From @tblLot)=0
	Begin
		Select @strItemNo=strItemNo From tblICItem Where intItemId=@intRawItemId
		Set @ErrMsg='Inventory is not available for item ' + @strItemNo + '.'
		RaisError(@ErrMsg,16,1)
	End

	Select @dblItemAvailableQty = SUM(dblQty) From @tblLot

	If @dblRequiredQty > @dblItemAvailableQty
	Begin
		Set @dblMaxProduceQty=(@dblItemAvailableQty * @dblRecipeQty) / @dblRawItemRecipeCalculatedQty
		Update @tblInputItem Set dblMaxProduceQty=@dblMaxProduceQty Where intRowNo=@intMinItem
	End

	Select @intMinLot=MIN(intRowNo) From @tblLot
	While @intMinLot is not null
	Begin
		Select @intLotId=intLotId,@dblAvailableQty=dblQty From @tblLot Where intRowNo=@intMinLot

		If @dblAvailableQty >= @dblRequiredQty 
		Begin
			INSERT INTO @tblPickedLot(intLotId,intItemId,dblQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId)
			Select @intLotId,@intRawItemId,@dblRequiredQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId From @tblLot Where intRowNo=@intMinLot

			GOTO NEXT_ITEM
		End
		Else
		Begin
			INSERT INTO @tblPickedLot(intLotId,intItemId,dblQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId)
			Select @intLotId,@intRawItemId,@dblAvailableQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId From @tblLot Where intRowNo=@intMinLot

			Set @dblRequiredQty = @dblRequiredQty - @dblAvailableQty
		End

		Select @intMinLot = MIN(intRowNo) From @tblLot Where intRowNo>@intMinLot
	End

	NEXT_ITEM:
	Select @intMinItem = MIN(intRowNo) From @tblInputItem Where ysnIsSubstitute=0 AND intRowNo>@intMinItem

End

--Check for Max produce qty using available inventory
Select @dblMaxProduceQty = ISNULL(MIN(ISNULL(dblMaxProduceQty,0)),0) From @tblInputItem Where ISNULL(dblMaxProduceQty,0)>0

If @dblMaxProduceQty > 0
Begin
	If @dblQtyToProduce <> @dblMaxProduceQty
		Begin
			Set @dblMaxQtyToProduce=@dblMaxProduceQty
			Set @ErrMsg='Maximum of ' + CONVERT(VARCHAR,@dblMaxProduceQty) + ' can be produced using the available inventory.'
			RaisError(@ErrMsg,16,1)
		End
End

Begin Tran

--Create WorkOrder
Set @strXml = '<root>'
Set @strXml += '<intSalesOrderDetailId>' + ISNULL(CONVERT(VARCHAR,@intSalesOrderDetailId),'') + '</intSalesOrderDetailId>'
Set @strXml += '<intInvoiceDetailId>' + ISNULL(CONVERT(VARCHAR,@intInvoiceDetailId),'') + '</intInvoiceDetailId>'
Set @strXml += '<intLoadDistributionDetailId>' + ISNULL(CONVERT(VARCHAR,@intLoadDistributionDetailId),'') + '</intLoadDistributionDetailId>'
Set @strXml += '<strOrderType>' + CONVERT(VARCHAR,@strOrderType) + '</strOrderType>'
Set @strXml += '<intLocationId>' + CONVERT(VARCHAR,@intLocationId) + '</intLocationId>'
Set @strXml += '<intRecipeId>' + CONVERT(VARCHAR,@intRecipeId) + '</intRecipeId>'
Set @strXml += '<intItemId>' + CONVERT(VARCHAR,@intBlendItemId) + '</intItemId>'
Set @strXml += '<intItemUOMId>' + CONVERT(VARCHAR,@intBlendItemUOMId) + '</intItemUOMId>'
Set @strXml += '<intUserId>' + ISNULL(CONVERT(VARCHAR,@intUserId),'') + '</intUserId>'

While (@dblQtyToProduce>0)
Begin
	If @dblQtyToProduce < @dblBlendBinSize
		Set @dblBlendBinSize=@dblQtyToProduce

	Set @strXml += '<wo>'
	Set @strXml += '<dblQuantity>' + CONVERT(VARCHAR,@dblBlendBinSize) + '</dblQuantity>'
	Set @strXml += '<dtmDueDate>' + CONVERT(VARCHAR,@dtmDate) + '</dtmDueDate>'
	Set @strXml += '<intCellId>' + CONVERT(VARCHAR,@intCellId) + '</intCellId>'
	Set @strXml += '</wo>'

	Set @dblQtyToProduce = @dblQtyToProduce - @dblBlendBinSize
End

Set @strXml += '</root>'

Select @intMaxWorkOrderId=MAX(intWorkOrderId) From tblMFWorkOrder

Exec uspMFCreateWorkOrderFromSalesOrder @strXml

If @strOrderType='SALES ORDER'
	Select @intWorkOrderId=MIN(intWorkOrderId) From tblMFWorkOrder Where intSalesOrderLineItemId=@intSalesOrderDetailId AND intWorkOrderId>@intMaxWorkOrderId

If @strOrderType='INVOICE'
	Select @intWorkOrderId=MIN(intWorkOrderId) From tblMFWorkOrder Where intInvoiceDetailId=@intInvoiceDetailId AND intWorkOrderId>@intMaxWorkOrderId

If @strOrderType='LOAD DISTRIBUTION'
	Select @intWorkOrderId=MIN(intWorkOrderId) From tblMFWorkOrder Where intLoadDistributionDetailId=@intLoadDistributionDetailId AND intWorkOrderId>@intMaxWorkOrderId

While @intWorkOrderId is not null
Begin
	Select @dblWOQty=dblQuantity From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId


	--Selects Lots/Items
	Set @intMinItem=NULL

	Delete From @tblWorkOrderPickedLot

	Select @intMinItem = MIN(intRowNo) From @tblInputItem Where ysnIsSubstitute=0

	--Loop through Items
	While @intMinItem is not null
	Begin
	Set @intRawItemId=NULL
	Set @dblRawItemRecipeCalculatedQty=NULL
	Select @intRawItemId=intItemId,@dblRawItemRecipeCalculatedQty=dblCalculatedQuantity From @tblInputItem Where intRowNo=@intMinItem

	Set @dblRequiredQty = @dblRawItemRecipeCalculatedQty * (@dblWOQty / @dblRecipeQty)

	Delete From @tblPickedLot Where dblQty <= 0

	--Loop through picked lot/item
	Set @intMinLot=NULL
	Select @intMinLot=MIN(intRowNo) From @tblPickedLot Where intItemId=@intRawItemId
	While @intMinLot is not null
	Begin
		Set @dblAvailableQty=NULL
		Set @intLotId=NULL
		Select @intLotId=intLotId,@dblAvailableQty=dblQty From @tblPickedLot Where intRowNo=@intMinLot

		If @dblAvailableQty >= @dblRequiredQty 
		Begin
			INSERT INTO @tblWorkOrderPickedLot(intWorkOrderId,intLotId,intItemId,dblQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId)
			Select @intWorkOrderId,@intLotId,@intRawItemId,@dblRequiredQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId From @tblPickedLot Where intRowNo=@intMinLot

			Update @tblPickedLot Set dblQty=@dblAvailableQty - @dblRequiredQty Where intRowNo=@intMinLot

			GOTO NEXT_ITEM_WO
		End
		Else
		Begin
			INSERT INTO @tblWorkOrderPickedLot(intWorkOrderId,intLotId,intItemId,dblQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId)
			Select @intWorkOrderId,@intLotId,@intRawItemId,@dblAvailableQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId From @tblPickedLot Where intRowNo=@intMinLot

			Set @dblRequiredQty = @dblRequiredQty - @dblAvailableQty

			Update @tblPickedLot Set dblQty=0 Where intRowNo=@intMinLot
		End

		Select @intMinLot = MIN(intRowNo) From @tblPickedLot Where intRowNo>@intMinLot
	End

	NEXT_ITEM_WO:
	Select @intMinItem = MIN(intRowNo) From @tblInputItem Where ysnIsSubstitute=0 AND intRowNo>@intMinItem

	End

	Update @tblWorkOrderPickedLot Set intLotId=NULL Where intLotId=0

	--Add Lots/Items to workorder consume table
	Insert Into tblMFWorkOrderConsumedLot(intWorkOrderId,intLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intSequenceNo,
	dtmCreated,intCreatedUserId,dtmLastModified,intLastModifiedUserId,intRecipeItemId,ysnStaged,intSubLocationId,intStorageLocationId)
	Select @intWorkOrderId,intLotId,intItemId,dblQty,intItemUOMId,
	dblQty,intItemUOMId,null,
	@dtmDate,@intUserId,@dtmDate,@intUserId,null,1,intSubLocationId,intStorageLocationId
	From @tblWorkOrderPickedLot

	--Start Blend Sheet
	Update tblMFWorkOrder Set intStatusId=10,dtmStartedDate=GETDATE(),intLastModifiedUserId=@intUserId,dtmLastModified=GETDATE() 
	Where intWorkOrderId=@intWorkOrderId

	--Consume Lots/Items/End Blend Sheet
	Exec [uspMFPostConsumption] 1,0,@intWorkOrderId,@intUserId,NULL,@strRetBatchId OUT

	Update tblMFWorkOrder Set intStatusId=12,dtmCompletedDate=GETDATE(),intLastModifiedUserId=@intUserId,dtmLastModified=GETDATE(),strBatchId=@strRetBatchId 
	Where intWorkOrderId=@intWorkOrderId

	If @intItemUOMId<>@intBlendItemUOMId
		Begin
			Select @dblBlendLotWeightPerUnit=dblUnitQty From tblICItemUOM Where intItemUOMId=@intItemUOMId
			Set @dblBlendLotIssuedQty=@dblWOQty/@dblBlendLotWeightPerUnit
			Set @intBlendLotIssuesUOMId=@intItemUOMId
		End
	Else
		Begin
			Set @dblBlendLotWeightPerUnit=1
			Set @dblBlendLotIssuedQty=@dblWOQty
			Set @intBlendLotIssuesUOMId=@intBlendItemUOMId
		End

	--Produce Lot
	Set @strXml = '<root>'
	Set @strXml += '<intWorkOrderId>' + CONVERT(VARCHAR,@intWorkOrderId) + '</intWorkOrderId>'
	Set @strXml += '<intItemId>' + CONVERT(VARCHAR,@intBlendItemId) + '</intItemId>'
	Set @strXml += '<dblQtyToProduce>' + CONVERT(VARCHAR,@dblWOQty) + '</dblQtyToProduce>'
	Set @strXml += '<intItemUOMId>' + CONVERT(VARCHAR,@intBlendItemUOMId) + '</intItemUOMId>'
	Set @strXml += '<dblIssuedQuantity>' + CONVERT(VARCHAR,@dblBlendLotIssuedQty) + '</dblIssuedQuantity>'
	Set @strXml += '<intItemIssuedUOMId>' + CONVERT(VARCHAR,@intBlendLotIssuesUOMId) + '</intItemIssuedUOMId>'
	Set @strXml += '<dblWeightPerUnit>' + CONVERT(VARCHAR,@dblBlendLotWeightPerUnit) + '</dblWeightPerUnit>'
	Set @strXml += '<intLocationId>' + CONVERT(VARCHAR,@intLocationId) + '</intLocationId>'
	Set @strXml += '<intStorageLocationId>' + ISNULL(CONVERT(VARCHAR,@intStorageLocationId),'') + '</intStorageLocationId>'
	Set @strXml += '<strVesselNo>' + CONVERT(VARCHAR,'') + '</strVesselNo>'
	Set @strXml += '<intManufacturingCellId>' + CONVERT(VARCHAR,@intCellId) + '</intManufacturingCellId>'
	Set @strXml += '<dblPlannedQuantity>' + CONVERT(VARCHAR,@dblWOQty) + '</dblPlannedQuantity>'
	Set @strXml += '<intUserId>' + ISNULL(CONVERT(VARCHAR,@intUserId),'') + '</intUserId>'
	
	Select @strWorkOrderConsumedLotsXml=COALESCE(@strWorkOrderConsumedLotsXml, '') + '<lot>' +  '<intWorkOrderId>' + convert(varchar,@intWorkOrderId) + '</intWorkOrderId>' + 
	'<intWorkOrderConsumedLotId>' + convert(varchar,wc.intWorkOrderConsumedLotId) + '</intWorkOrderConsumedLotId>' + 
	'<intLotId>' + ISNULL(convert(varchar,wc.intLotId),'') + '</intLotId>' + 
	'<intItemId>' + convert(varchar,wc.intItemId) + '</intItemId>' + 
	'<dblQty>' + convert(varchar,wc.dblQuantity) + '</dblQty>' + 
	'<intItemUOMId>' + convert(varchar,wc.intItemUOMId) + '</intItemUOMId>' + 
	'<dblIssuedQuantity>' + convert(varchar,wc.dblIssuedQuantity) + '</dblIssuedQuantity>' + 
	'<intItemIssuedUOMId>' + convert(varchar,wc.intItemIssuedUOMId) + '</intItemIssuedUOMId>' + 
	'<dblWeightPerUnit>' + convert(varchar,0) + '</dblWeightPerUnit>' + 
	'<intRecipeItemId>' + ISNULL(convert(varchar,wc.intRecipeItemId),'') + '</intRecipeItemId>' + 
	'<ysnStaged>' + convert(varchar,wc.ysnStaged) + '</ysnStaged>' + 
	'<intSubLocationId>' + ISNULL(convert(varchar,wc.intSubLocationId),'') + '</intSubLocationId>' + 
	'<intStorageLocationId>' + ISNULL(convert(varchar,wc.intStorageLocationId),'') + '</intStorageLocationId>' + '</lot>' 
	From tblMFWorkOrderConsumedLot wc Where intWorkOrderId=@intWorkOrderId

	Set @strXml += @strWorkOrderConsumedLotsXml
	Set @strXml += '</root>'

	Exec uspMFCompleteBlendSheet @strXml,@intBlendLotId OUT,@strLotNumber OUT

	If @strOrderType='SALES ORDER'
		Select @intWorkOrderId=MIN(intWorkOrderId) From tblMFWorkOrder Where intSalesOrderLineItemId=@intSalesOrderDetailId AND intWorkOrderId > @intWorkOrderId

	If @strOrderType='INVOICE'
		Select @intWorkOrderId=MIN(intWorkOrderId) From tblMFWorkOrder Where intInvoiceDetailId=@intInvoiceDetailId AND intWorkOrderId > @intWorkOrderId

	If @strOrderType='LOAD DISTRIBUTION'
		Select @intWorkOrderId=MIN(intWorkOrderId) From tblMFWorkOrder Where intLoadDistributionDetailId=@intLoadDistributionDetailId AND intWorkOrderId > @intWorkOrderId
End

Commit Tran

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  