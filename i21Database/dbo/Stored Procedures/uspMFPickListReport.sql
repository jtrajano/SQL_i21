CREATE PROCEDURE [dbo].[uspMFPickListReport]
@xmlParam NVARCHAR(MAX) = NULL
AS
	DECLARE @intPickListId			INT,
			@idoc					INT 
			
	IF	LTRIM(RTRIM(@xmlParam)) = ''   
		SET @xmlParam = NULL   
      
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(50), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)  
  
	EXEC sp_xml_preparedocument @idoc output, @xmlParam  
  
	INSERT INTO @temp_xml_table  
	SELECT	*  
	FROM	OPENXML(@idoc, 'xmlparam/filters/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(50), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)  
    
	SELECT	@intPickListId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intPickListId'

	Declare @intWorkOrderCount int  
	SELECT  @intWorkOrderCount = COUNT(1) FROM tblMFWorkOrder WHERE intPickListId = @intPickListId 
   
Declare @intRecipeId int
Declare @intBlendItemId int
Declare @intLocationId int
Declare @dblQtyToProduce numeric(18,6)
Declare @strPickListNo nvarchar(50)
Declare @strBlendItemNoDesc nvarchar(max)
Declare @strWorkOrderNo nvarchar(max)
Declare @dblTotalPickQty numeric(18,6)
Declare @intWorkOrderId int
Declare @intMinRemainingItem int

DECLARE @tblInputItem TABLE (
	intRowNo INT IDENTITY,
	intItemId INT
	,dblRequiredQty NUMERIC(18, 6)
	,ysnIsSubstitute BIT
	,intConsumptionMethodId INT
	,intParentItemId INT
	)

Declare @tblRemainingPickedLots AS table
( 
	intItemId int,
	dblRemainingQuantity numeric(18,6),
	intConsumptionMethodId int,
	ysnIsSubstitute bit,
	intParentItemId int
)

Select @intLocationId=intLocationId,@strPickListNo=strPickListNo,@strWorkOrderNo=strWorkOrderNo from tblMFPickList Where intPickListId=@intPickListId
Select TOP 1 @intBlendItemId=w.intItemId,@strBlendItemNoDesc=(i.strItemNo + ' - '  + ISNULL(i.strDescription,'')),@intWorkOrderId=intWorkOrderId  
From tblMFWorkOrder w Join tblICItem i on w.intItemId=i.intItemId Where intPickListId=@intPickListId
Select @dblQtyToProduce=SUM(dblQuantity) From tblMFWorkOrder Where intPickListId=@intPickListId

	SELECT @intRecipeId = intRecipeId
	FROM tblMFWorkOrderRecipe
	WHERE intWorkOrderId = @intWorkOrderId
		AND intItemId = @intBlendItemId
		AND intLocationId = @intLocationId
		AND ysnActive = 1

		INSERT INTO @tblInputItem (
		intItemId
		,dblRequiredQty
		,ysnIsSubstitute
		,intConsumptionMethodId
		,intParentItemId
		)
	SELECT 
		ri.intItemId
		,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
		,0
		,ri.intConsumptionMethodId
		,0
	FROM tblMFWorkOrderRecipeItem ri
	JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = ri.intWorkOrderId
	WHERE r.intRecipeId = @intRecipeId
		AND ri.intRecipeItemTypeId = 1
		AND r.intWorkOrderId = @intWorkOrderId
	
	UNION
	
	SELECT 
		rs.intSubstituteItemId AS intItemId
		,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)) dblRequiredQty
		,1
		,0
		,ri.intItemId
	FROM tblMFWorkOrderRecipeSubstituteItem rs
	JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = rs.intWorkOrderId
	JOIN tblMFWorkOrderRecipeItem ri on rs.intRecipeItemId=ri.intRecipeItemId
	WHERE r.intRecipeId = @intRecipeId
		AND rs.intRecipeItemTypeId = 1
		AND r.intWorkOrderId = @intWorkOrderId

	Insert Into @tblRemainingPickedLots(intItemId,dblRemainingQuantity,intConsumptionMethodId,ysnIsSubstitute,intParentItemId)
	Select ti.intItemId,(ti.dblRequiredQty - ISNULL(tpl.dblQuantity,0)) AS dblRemainingQuantity,ti.intConsumptionMethodId,ti.ysnIsSubstitute,ti.intParentItemId 
	From @tblInputItem ti Left Join 
	(Select intItemId,SUM(dblQuantity) AS dblQuantity From tblMFPickListDetail Where intPickListId=@intPickListId Group by intItemId) tpl on  ti.intItemId=tpl.intItemId
	WHERE ROUND((ti.dblRequiredQty - ISNULL(tpl.dblQuantity,0)),0) > 0

	--Remove main item if substitute is selected
	Select @intMinRemainingItem=Min(intRowNo) From @tblInputItem Where ysnIsSubstitute=1
	Declare @intRemainingSubItemId int
	Declare @intRemainingParentItemId int
	While(@intMinRemainingItem is not null)
	Begin
		Select @intRemainingSubItemId=intItemId,@intRemainingParentItemId=intParentItemId From @tblInputItem Where intRowNo=@intMinRemainingItem
		
		If Exists (Select 1 From tblMFPickListDetail Where intPickListId=@intPickListId And intItemId=@intRemainingSubItemId)
			Delete From @tblRemainingPickedLots Where intItemId=@intRemainingParentItemId

		Select @intMinRemainingItem=Min(intRowNo) From @tblInputItem Where intRowNo>@intMinRemainingItem And ysnIsSubstitute=1
	End

	--Remove sub item if main is selected
	Delete a From @tblRemainingPickedLots a join tblMFPickListDetail b on a.intParentItemId=b.intItemId Where b.intPickListId=@intPickListId And a.ysnIsSubstitute=1

	Select @dblTotalPickQty=SUM(dblQuantity) From tblMFPickListDetail Where intPickListId=@intPickListId

	SELECT distinct pl.strPickListNo,  
			bi.strItemNo + ' - '  + ISNULL(bi.strDescription,'')  AS strBlendItemNoDesc,  
			pl.strWorkOrderNo,  
			l.strLotNumber,
			l.strLotAlias,
			sl.strName AS strStorageLocationName,
			i.strItemNo,
			i.strDescription,
			dbo.fnRemoveTrailingZeroes(pld.dblPickQuantity) AS dblPickQuantity,
			um.strUnitMeasure AS strPickUOM,
			l.strGarden,
			@intWorkOrderCount AS intWorkOrderCount,
			p.strParentLotNumber,
			pl.strPickListNo,
			dbo.fnRemoveTrailingZeroes(@dblQtyToProduce) AS dblReqQty,
			dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) AS dblTotalPickQty
	FROM tblMFPickList pl  
	JOIN tblMFPickListDetail pld ON pl.intPickListId=pld.intPickListId
	JOIN tblMFWorkOrder w on w.intPickListId=pl.intPickListId
	JOIN tblICItem bi on bi.intItemId = w.intItemId
	JOIN tblICItem i on pld.intItemId=i.intItemId
	JOIN tblICLot l on l.intLotId=pld.intLotId
	JOIN tblICStorageLocation sl on sl.intStorageLocationId=pld.intStorageLocationId
	Join tblICItemUOM iu on pld.intPickUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICParentLot p on l.intParentLotId=p.intParentLotId
	WHERE pl.intPickListId=@intPickListId
	UNION
	Select @strPickListNo,@strBlendItemNoDesc,@strWorkOrderNo,'','','',i.strItemNo,i.strDescription,dbo.fnRemoveTrailingZeroes(tpl.dblRemainingQuantity),'','',
	@intWorkOrderCount,'','',dbo.fnRemoveTrailingZeroes(@dblQtyToProduce) AS dblReqQty,dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) AS dblTotalPickQty
	From @tblRemainingPickedLots tpl Join tblICItem i on tpl.intItemId=i.intItemId
	ORDER BY strPickUOM
