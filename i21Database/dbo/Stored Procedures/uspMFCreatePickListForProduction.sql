CREATE PROCEDURE [dbo].[uspMFCreatePickListForProduction]
	@intWorkOrderId int,
	@dblQtyToProduce NUMERIC(38,20)
AS

Declare @intLocationId INT
Declare @intMinItem INT
Declare @intItemId INT
Declare @dblRequiredQty NUMERIC(38,20)
Declare @dblItemRequiredQty NUMERIC(38,20)
Declare @strLotTracking nvarchar(50)
Declare @intItemUOMId INT
Declare @intMinLot INT
Declare @intLotId INT
Declare @dblAvailableQty NUMERIC(38,20)
Declare @intPickListId INT
Declare @intRecipeId int
Declare @intOutputItemId int
Declare @intManufacturingProcessId int
DECLARE @intDayOfYear INT
DECLARE @dtmDate DATETIME=Convert(DATE, GetDate())
DECLARE @dblReservedQty NUMERIC(38,20)

DECLARE @tblInputItem TABLE (
	intRowNo INT IDENTITY(1, 1)
	,intRecipeId INT
	,intRecipeItemId INT
	,intItemId INT
	,dblRequiredQty NUMERIC(38,20)
	,ysnIsSubstitute BIT
	,ysnMinorIngredient BIT
	,intConsumptionMethodId INT
	,intConsumptionStoragelocationId INT
	,intParentItemId int
	,dblSubstituteRatio NUMERIC(38,20)
	,dblMaxSubstituteRatio NUMERIC(38,20)
	,strLotTracking NVARCHAR(50)
	,intItemUOMId int
	)

Declare @tblInputItemCopy AS table
( 
	intRowNo INT IDENTITY(1, 1)
	,intRecipeId INT
	,intRecipeItemId INT
	,intItemId INT
	,dblRequiredQty NUMERIC(38,20)
	,ysnIsSubstitute BIT
	,ysnMinorIngredient BIT
	,intConsumptionMethodId INT
	,intConsumptionStoragelocationId INT
	,intParentItemId int
	,dblSubstituteRatio NUMERIC(38,20)
	,dblMaxSubstituteRatio NUMERIC(38,20)
	,strLotTracking NVARCHAR(50)
	,intItemUOMId int
)

DECLARE @tblLot TABLE (
	 intRowNo INT IDENTITY
	,intLotId INT
	,intItemId INT
	,dblQty NUMERIC(38,20)
	,intItemUOMId INT
	,intLocationId INT
	,intSubLocationId INT
	,intStorageLocationId INT
	,dblReservedQty NUMERIC(38,20)
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
	,dblItemRequiredQty NUMERIC(38,20)
	,dblAvailableQty NUMERIC(38,20)
	,dblReservedQty NUMERIC(38,20)
)

Select @intLocationId=intLocationId,@intOutputItemId=intItemId,@intPickListId=ISNULL(intPickListId,0) From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId

SELECT @intRecipeId = intRecipeId
	,@intManufacturingProcessId = intManufacturingProcessId
FROM tblMFRecipe
WHERE intItemId = @intOutputItemId
	AND intLocationId = @intLocationId
	AND ysnActive = 1

SELECT @intDayOfYear = DATEPART(dy, @dtmDate)

If ISNULL(@intPickListId,0)=0
Begin
INSERT INTO @tblInputItem (
				intRecipeId
				,intRecipeItemId
				,intItemId
				,dblRequiredQty
				,ysnIsSubstitute
				,ysnMinorIngredient
				,intConsumptionMethodId
				,intConsumptionStoragelocationId
				,intParentItemId
				,dblSubstituteRatio
				,dblMaxSubstituteRatio
				,strLotTracking
				,intItemUOMId
				)
			SELECT @intRecipeId
				,ri.intRecipeItemId
				,ri.intItemId
				,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
				,0 AS ysnIsSubstitute
				,ri.ysnMinorIngredient
				,ri.intConsumptionMethodId
				,ri.intStorageLocationId
				,0
				,0.0
				,0.0
				,i.strLotTracking
				,ri.intItemUOMId
			FROM tblMFRecipeItem ri
			JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
			JOIN tblICItem i on ri.intItemId=i.intItemId
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
				,1 AS ysnIsSubstitute
				,0
				,1
				,0
				,ri.intItemId
				,rs.dblSubstituteRatio
				,rs.dblMaxSubstituteRatio
				,i.strLotTracking
				,ri.intItemUOMId
			FROM tblMFRecipeSubstituteItem rs
			JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
			JOIN tblMFRecipeItem ri on rs.intRecipeItemId=ri.intRecipeItemId
			JOIN tblICItem i on ri.intItemId=i.intItemId
			WHERE r.intRecipeId = @intRecipeId
				AND rs.intRecipeItemTypeId = 1
			ORDER BY ysnIsSubstitute
End
Else
Begin --Pick List is already created
INSERT INTO @tblInputItemCopy (
				intRecipeId
				,intRecipeItemId
				,intItemId
				,dblRequiredQty
				,ysnIsSubstitute
				,ysnMinorIngredient
				,intConsumptionMethodId
				,intConsumptionStoragelocationId
				,intParentItemId
				,dblSubstituteRatio
				,dblMaxSubstituteRatio
				,strLotTracking
				,intItemUOMId
				)
			SELECT r.intRecipeId
				,ri.intRecipeItemId
				,ri.intItemId
				,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
				,0 AS ysnIsSubstitute
				,ri.ysnMinorIngredient
				,ri.intConsumptionMethodId
				,ri.intStorageLocationId
				,0
				,0.0
				,0.0
				,i.strLotTracking
				,ri.intItemUOMId
			FROM tblMFWorkOrderRecipeItem ri
			JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = ri.intWorkOrderId
			JOIN tblICItem i on ri.intItemId=i.intItemId
			WHERE r.intWorkOrderId=@intWorkOrderId
				AND ri.intRecipeItemTypeId = 1 AND ri.intConsumptionMethodId IN (1,2,3)
	
			UNION
	
			SELECT r.intRecipeId
				,rs.intRecipeSubstituteItemId
				,rs.intSubstituteItemId AS intItemId
				,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)) dblRequiredQty
				,1 AS ysnIsSubstitute
				,0
				,ri.intConsumptionMethodId
				,ri.intStorageLocationId
				,ri.intItemId
				,rs.dblSubstituteRatio
				,rs.dblMaxSubstituteRatio
				,i.strLotTracking
				,ri.intItemUOMId
			FROM tblMFWorkOrderRecipeSubstituteItem rs
			JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = rs.intWorkOrderId
			JOIN tblMFWorkOrderRecipeItem ri on rs.intRecipeItemId=ri.intRecipeItemId AND ri.intWorkOrderId=r.intWorkOrderId
			JOIN tblICItem i on rs.intSubstituteItemId=i.intItemId
			WHERE r.intWorkOrderId = @intWorkOrderId
				AND rs.intRecipeItemTypeId = 1
			ORDER BY ysnIsSubstitute

Insert Into @tblInputItem(intRecipeId,intRecipeItemId,intItemId,dblRequiredQty,ysnIsSubstitute,ysnMinorIngredient
			,intConsumptionMethodId,intConsumptionStoragelocationId,intParentItemId,dblSubstituteRatio,dblMaxSubstituteRatio,strLotTracking,intItemUOMId)
	Select ti.intRecipeId,ti.intRecipeItemId,ti.intItemId,ISNULL(ti.dblRequiredQty,0) - ISNULL(t.dblQty,0),ti.ysnIsSubstitute,ti.ysnMinorIngredient,
	ti.intConsumptionMethodId,ti.intConsumptionStoragelocationId,ti.intParentItemId,ti.dblSubstituteRatio,ti.dblMaxSubstituteRatio,ti.strLotTracking,ti.intItemUOMId
	From @tblInputItemCopy ti 
	Left Join (Select pld.intItemId,SUM(pld.dblPickQuantity) AS dblQty From tblMFPickListDetail pld 
	Where intPickListId=@intPickListId Group By pld.intItemId) t ON ti.intItemId=t.intItemId

	Delete From @tblInputItem Where ISNULL(dblRequiredQty,0)=0
End

Select @intMinItem = MIN(intRowNo) From @tblInputItem

While @intMinItem is not null
Begin
	Select @intItemId=intItemId,@dblRequiredQty=dblRequiredQty,@dblItemRequiredQty=dblRequiredQty,@intItemUOMId=intItemUOMId,@strLotTracking=strLotTracking 
	From @tblInputItem Where intRowNo=@intMinItem

	DELETE FROM @tblLot

	If @strLotTracking='No'
		INSERT INTO @tblLot (
		 intLotId
		,intItemId
		,dblQty
		,intItemUOMId
		,intLocationId
		,intSubLocationId
		,intStorageLocationId
		,dblReservedQty
		)
		Select 0,sd.intItemId,dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,@intItemUOMId,sd.dblAvailableQty),@intItemUOMId,
		sd.intLocationId,sd.intSubLocationId,sd.intStorageLocationId,dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,@intItemUOMId,sd.dblReservedQty)
		From vyuMFGetItemStockDetail sd 
		Where sd.intItemId=@intItemId AND sd.dblAvailableQty > .01 AND sd.intLocationId=@intLocationId AND ISNULL(sd.ysnStockUnit,0)=1 ORDER BY sd.intItemStockUOMId
	Else
		INSERT INTO @tblLot (
		 intLotId
		,intItemId
		,dblQty
		,intItemUOMId
		,intLocationId
		,intSubLocationId
		,intStorageLocationId
		,dblReservedQty
		)
	SELECT L.intLotId
		,L.intItemId
		,dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId,@intItemUOMId,L.dblQty) - 
		(Select ISNULL(SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(sr.intItemUOMId,@intItemUOMId,sr.dblQty),0)),0) 
		From tblICStockReservation sr Where sr.intLotId=L.intLotId AND ISNULL(sr.ysnPosted,0)=0) AS dblQty
		,@intItemUOMId
		,L.intLocationId
		,L.intSubLocationId
		,L.intStorageLocationId
		,(Select ISNULL(SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(sr.intItemUOMId,@intItemUOMId,sr.dblQty),0)),0) 
		From tblICStockReservation sr Where sr.intLotId=L.intLotId AND ISNULL(sr.ysnPosted,0)=0) AS dblReservedQty
	FROM tblICLot L
	JOIN tblICLotStatus LS ON L.intLotStatusId = LS.intLotStatusId
	WHERE L.intItemId = @intItemId
		AND L.intLocationId = @intLocationId
		AND LS.strPrimaryStatus IN (
			'Active'
			)
		AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
		AND L.dblQty  >= .01
		ORDER BY L.dtmDateCreated

	Delete From @tblLot Where dblQty < .01

	Select @intMinLot=MIN(intRowNo) From @tblLot
	While @intMinLot is not null
	Begin
		Select @intLotId=intLotId,@dblAvailableQty=dblQty,@dblReservedQty=dblReservedQty From @tblLot Where intRowNo=@intMinLot

		If @dblAvailableQty >= @dblRequiredQty 
		Begin
			INSERT INTO @tblPickedLot(intLotId,intItemId,dblQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId,dblItemRequiredQty,dblAvailableQty,dblReservedQty)
			Select @intLotId,@intItemId,@dblRequiredQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId,@dblRequiredQty,@dblAvailableQty,@dblReservedQty 
			From @tblLot Where intRowNo=@intMinLot

			GOTO NEXT_ITEM
		End
		Else
		Begin
			INSERT INTO @tblPickedLot(intLotId,intItemId,dblQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId,dblItemRequiredQty,dblAvailableQty,dblReservedQty)
			Select @intLotId,@intItemId,@dblAvailableQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId,@dblAvailableQty,@dblAvailableQty,@dblReservedQty 
			From @tblLot Where intRowNo=@intMinLot

			Set @dblRequiredQty = @dblRequiredQty - @dblAvailableQty
		End

		Select @intMinLot = MIN(intRowNo) From @tblLot Where intRowNo>@intMinLot
	End

	If ISNULL(@dblRequiredQty,0)>0
		INSERT INTO @tblPickedLot(intLotId,intItemId,dblQty,intItemUOMId,intLocationId,intSubLocationId,intStorageLocationId,dblItemRequiredQty,dblAvailableQty,dblReservedQty)
		Select 0,@intItemId,0,@intItemUOMId,@intLocationId,0,0,@dblRequiredQty,0.0,0.0

	NEXT_ITEM:
	Select @intMinItem = MIN(intRowNo) From @tblInputItem Where intRowNo>@intMinItem

End

Select p.intItemId,i.strItemNo,i.strDescription,l.intLotId,l.strLotNumber,p.intStorageLocationId,sl.strName AS strStorageLocationName,
p.dblQty AS dblPickQuantity,p.intItemUOMId AS intPickUOMId,um.strUnitMeasure AS strPickUOM,
pl.intParentLotId,pl.strParentLotNumber,p.intSubLocationId,sbl.strSubLocationName,p.intLocationId,i.strLotTracking,
p.dblItemRequiredQty AS dblQuantity,p.intItemUOMId,um.strUnitMeasure AS strUOM,
p.dblItemRequiredQty AS dblIssuedQuantity,p.intItemUOMId AS intItemIssuedUOMId,um.strUnitMeasure AS strIssuedUOM,
p.dblAvailableQty,p.dblReservedQty,l.dblWeightPerQty AS dblWeightPerUnit
from @tblPickedLot p Join tblICItem i on p.intItemId=i.intItemId 
Left Join tblICLot l on p.intLotId=l.intLotId
Left Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
Left Join tblICStorageLocation sl on p.intStorageLocationId=sl.intStorageLocationId
Left Join tblSMCompanyLocationSubLocation sbl on p.intSubLocationId=sbl.intCompanyLocationSubLocationId
Left Join tblSMCompanyLocation cl on p.intLocationId=cl.intCompanyLocationId
Join tblICItemUOM iu on p.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId

