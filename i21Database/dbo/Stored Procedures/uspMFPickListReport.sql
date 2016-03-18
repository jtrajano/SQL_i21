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
Declare @intBlendRequirementId int
Declare @intKitStatusId int

DECLARE @tblInputItem TABLE (
	intRowNo INT IDENTITY,
	intItemId INT
	,dblRequiredQty NUMERIC(18, 6)
	,ysnIsSubstitute BIT
	,intConsumptionMethodId INT
	,intParentItemId INT
	)

Declare @tblRemainingPickedItems AS table
( 
	intRowNo INT IDENTITY,
	intItemId int,
	dblRemainingQuantity numeric(18,6),
	intConsumptionMethodId int,
	ysnIsSubstitute bit,
	intParentItemId int
)

Declare @tblRemainingPickedLots AS table
( 
	intWorkOrderInputLotId int,
	intLotId int,
	strLotNumber nvarchar(50) COLLATE Latin1_General_CI_AS,
	strItemNo nvarchar(50) COLLATE Latin1_General_CI_AS,
	strDescription nvarchar(200) COLLATE Latin1_General_CI_AS,
	dblQuantity numeric(18,6),
	intItemUOMId int,
	strUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblIssuedQuantity numeric(18,6),
	intItemIssuedUOMId int,
	strIssuedUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	intItemId int,
	intRecipeItemId int,
	dblUnitCost numeric(18,6),
	dblDensity numeric(18,6),
	dblRequiredQtyPerSheet numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	dblRiskScore numeric(18,6),
	intStorageLocationId int,
	strStorageLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	strLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	intLocationId int,
	strSubLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	strLotAlias nvarchar(50) COLLATE Latin1_General_CI_AS,
	ysnParentLot bit,
	strRowState nvarchar(50) COLLATE Latin1_General_CI_AS
)

Select @intLocationId=intLocationId,@strPickListNo=strPickListNo,@strWorkOrderNo=strWorkOrderNo from tblMFPickList Where intPickListId=@intPickListId
Select TOP 1 @intBlendItemId=w.intItemId,@strBlendItemNoDesc=(i.strItemNo + ' - '  + ISNULL(i.strDescription,'')),@intWorkOrderId=intWorkOrderId,@intBlendRequirementId=intBlendRequirementId,@intKitStatusId=intKitStatusId 
From tblMFWorkOrder w Join tblICItem i on w.intItemId=i.intItemId Where intPickListId=@intPickListId
Select @dblQtyToProduce=SUM(dblQuantity) From tblMFWorkOrder Where intPickListId=@intPickListId
Select @dblTotalPickQty=SUM(dblQuantity) From tblMFPickListDetail Where intPickListId=@intPickListId

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
		,ri.intConsumptionMethodId
		,ri.intItemId
	FROM tblMFWorkOrderRecipeSubstituteItem rs
	JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = rs.intWorkOrderId
	JOIN tblMFWorkOrderRecipeItem ri on rs.intRecipeItemId=ri.intRecipeItemId
	WHERE r.intRecipeId = @intRecipeId
		AND rs.intRecipeItemTypeId = 1
		AND r.intWorkOrderId = @intWorkOrderId

	Insert Into @tblRemainingPickedItems(intItemId,dblRemainingQuantity,intConsumptionMethodId,ysnIsSubstitute,intParentItemId)
	Select ti.intItemId,(ti.dblRequiredQty - ISNULL(tpl.dblQuantity,0)) AS dblRemainingQuantity,ti.intConsumptionMethodId,ti.ysnIsSubstitute,ti.intParentItemId 
	From @tblInputItem ti Left Join 
	(Select intItemId,SUM(dblQuantity) AS dblQuantity From tblMFPickListDetail Where intPickListId=@intPickListId Group by intItemId) tpl on  ti.intItemId=tpl.intItemId
	WHERE ROUND((ti.dblRequiredQty - ISNULL(tpl.dblQuantity,0)),0) > 0

	--intSalesOrderLineItemId = 0 implies WOs are created from Blend Managemnet Screen And Lots are already attached, keep only bulk items
	If (Select TOP 1 ISNULL(intSalesOrderLineItemId,0) From tblMFWorkOrder Where intPickListId=@intPickListId)=0 OR @intKitStatusId=12
		Delete From @tblRemainingPickedItems Where intConsumptionMethodId not in (2,3)

	--Remove main item if substitute is selected
	Select @intMinRemainingItem=Min(intRowNo) From @tblInputItem Where ysnIsSubstitute=1
	Declare @intRemainingSubItemId int
	Declare @intRemainingParentItemId int
	While(@intMinRemainingItem is not null)
	Begin
		Select @intRemainingSubItemId=intItemId,@intRemainingParentItemId=intParentItemId From @tblInputItem Where intRowNo=@intMinRemainingItem
		
		If Exists (Select 1 From tblMFPickListDetail Where intPickListId=@intPickListId And intItemId=@intRemainingSubItemId)
			Delete From @tblRemainingPickedItems Where intItemId=@intRemainingParentItemId

		Select @intMinRemainingItem=Min(intRowNo) From @tblInputItem Where intRowNo>@intMinRemainingItem And ysnIsSubstitute=1
	End

	--Remove sub item if main is selected
	Delete a From @tblRemainingPickedItems a join tblMFPickListDetail b on a.intParentItemId=b.intItemId Where b.intPickListId=@intPickListId And a.ysnIsSubstitute=1

	Declare @intMinItemCount int
	Declare @strXml nvarchar(max)
	Declare @intRawItemId int
	Declare @dblRequiredQty numeric(18,6)
	Declare @ysnIsSubstitute bit
	Declare @intParentItemId int
	Declare @intRecipeItemId int
	Declare @intConsumptionMethodId int
	Declare @intConsumptionStoragelocationId int

	If (Select COUNT(1) From @tblRemainingPickedItems) > 0
	Begin
		Select @intMinItemCount=Min(intRowNo) from @tblRemainingPickedItems

		Set @strXml = '<root>'
		While(@intMinItemCount is not null)
		Begin
			Select @intRawItemId=intItemId,@dblRequiredQty=dblRemainingQuantity,@ysnIsSubstitute=ysnIsSubstitute,@intParentItemId=ISNULL(intParentItemId,0)
			From @tblRemainingPickedItems Where intRowNo=@intMinItemCount

			--WO created from Blend Management Screen if Lots are there input lot table when kitting enabled
			If (Select TOP 1 ISNULL(intSalesOrderLineItemId,0) From tblMFWorkOrder Where intPickListId=@intPickListId)=0
				Begin
					if @ysnIsSubstitute=0
						Select @intRecipeItemId=ri.intRecipeItemId,@intConsumptionMethodId=ri.intConsumptionMethodId,@intConsumptionStoragelocationId=ri.intStorageLocationId 
						From tblMFRecipe r Join tblMFRecipeItem ri on r.intRecipeId=ri.intRecipeId 
						Where r.intRecipeId=@intRecipeId And ri.intItemId=@intRawItemId And r.intLocationId=@intLocationId And r.ysnActive=1

					if @ysnIsSubstitute=1
						Select @intRecipeItemId=rs.intRecipeSubstituteItemId,@intConsumptionMethodId=ri.intConsumptionMethodId,@intConsumptionStoragelocationId=ri.intStorageLocationId 
						From tblMFRecipe r Join tblMFRecipeItem ri on r.intRecipeId=ri.intRecipeId 
						Join tblMFRecipeSubstituteItem rs on ri.intItemId=rs.intItemId
						Where r.intRecipeId=@intRecipeId And rs.intSubstituteItemId=@intRawItemId And r.intLocationId=@intLocationId And r.ysnActive=1
				End
			Else
				Select @intRecipeItemId=ri.intRecipeItemId,@intConsumptionMethodId=ri.intConsumptionMethodId,@intConsumptionStoragelocationId=ri.intStorageLocationId 
				From tblMFWorkOrderRecipe r Join tblMFWorkOrderRecipeItem ri on r.intWorkOrderId=ri.intWorkOrderId 
				Where r.intRecipeId=@intRecipeId And ri.intItemId=@intRawItemId And r.intLocationId=@intLocationId And r.ysnActive=1 AND r.intWorkOrderId=@intWorkOrderId

			Set @strXml = @strXml + '<item>'
			Set @strXml = @strXml + '<intRecipeId>' + CONVERT(varchar,@intRecipeId) + '</intRecipeId>'
			Set @strXml = @strXml + '<intRecipeItemId>' + CONVERT(varchar,@intRecipeItemId) + '</intRecipeItemId>'
			Set @strXml = @strXml + '<intItemId>' + CONVERT(varchar,@intRawItemId) + '</intItemId>'
			Set @strXml = @strXml + '<dblRequiredQty>' + CONVERT(varchar,@dblRequiredQty) + '</dblRequiredQty>'
			Set @strXml = @strXml + '<ysnIsSubstitute>' + CONVERT(varchar,@ysnIsSubstitute) + '</ysnIsSubstitute>'
			Set @strXml = @strXml + '<ysnMinorIngredient>' + CONVERT(varchar,0) + '</ysnMinorIngredient>'
			Set @strXml = @strXml + '<intConsumptionMethodId>' + CONVERT(varchar,@intConsumptionMethodId) + '</intConsumptionMethodId>'
			Set @strXml = @strXml + '<intConsumptionStoragelocationId>' + CONVERT(varchar,ISNULL(@intConsumptionStoragelocationId,0)) + '</intConsumptionStoragelocationId>'
			Set @strXml = @strXml + '<intParentItemId>' + CONVERT(varchar,@intParentItemId) + '</intParentItemId>'
			Set @strXml = @strXml + '</item>'

			Select @intMinItemCount=Min(intRowNo) from @tblRemainingPickedItems Where intRowNo > @intMinItemCount
		End
		Set @strXml = @strXml + '</root>'

		Insert Into @tblRemainingPickedLots
		Exec uspMFAutoBlendSheetFIFO @intLocationId,@intBlendRequirementId,0,@strXml,1

	End

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
	JOIN tblICLot l on l.intLotId=pld.intStageLotId
	JOIN tblICStorageLocation sl on sl.intStorageLocationId=l.intStorageLocationId
	Join tblICItemUOM iu on pld.intPickUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICParentLot p on l.intParentLotId=p.intParentLotId
	WHERE pl.intPickListId=@intPickListId
	UNION
	Select @strPickListNo,@strBlendItemNoDesc,@strWorkOrderNo,tpl.strLotNumber,tpl.strLotAlias,tpl.strStorageLocationName,i.strItemNo,i.strDescription,dbo.fnRemoveTrailingZeroes(tpl.dblQuantity),tpl.strUOM,'',
	@intWorkOrderCount,pl.strParentLotNumber,'',dbo.fnRemoveTrailingZeroes(@dblQtyToProduce) AS dblReqQty,dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) AS dblTotalPickQty
	From @tblRemainingPickedLots tpl Join tblICItem i on tpl.intItemId=i.intItemId
	Join tblICLot l on tpl.intLotId=l.intLotId
	Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
	ORDER BY strPickUOM
