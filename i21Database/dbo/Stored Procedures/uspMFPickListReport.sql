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
Declare @intSalesOrderId INT
Declare @dblTotalCost NUMERIC(38,20)

	DECLARE @strCompanyName NVARCHAR(100)
		,@strCompanyAddress NVARCHAR(100)
		,@strCity NVARCHAR(25)
		,@strState NVARCHAR(50)
		,@strZip NVARCHAR(12)
		,@strCountry NVARCHAR(25)

	SELECT TOP 1 @strCompanyName = strCompanyName
		,@strCompanyAddress = strAddress
		,@strCity = strCity
		,@strState = strState
		,@strZip = strZip
		,@strCountry = strCountry
	FROM dbo.tblSMCompanySetup

DECLARE @tblInputItem TABLE (
	intRowNo INT IDENTITY,
	intItemId INT
	,dblRequiredQty NUMERIC(18, 6)
	,ysnIsSubstitute BIT
	,intConsumptionMethodId INT
	,intStorageLocationId INT
	,intParentItemId INT
	)

Select @intLocationId=intLocationId,@strPickListNo=strPickListNo,@strWorkOrderNo=strWorkOrderNo,@intSalesOrderId=ISNULL(intSalesOrderId,0) from tblMFPickList Where intPickListId=@intPickListId
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
		,intStorageLocationId
		,intParentItemId
		)
	SELECT 
		ri.intItemId
		,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
		,0
		,ri.intConsumptionMethodId
		,ri.intStorageLocationId
		,0
	FROM tblMFWorkOrderRecipeItem ri
	JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = ri.intWorkOrderId
	WHERE r.intRecipeId = @intRecipeId
		AND ri.intRecipeItemTypeId = 1
		AND r.intWorkOrderId = @intWorkOrderId
		AND ri.intConsumptionMethodId <> 1

	UNION
	
	SELECT 
		rs.intSubstituteItemId AS intItemId
		,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)) dblRequiredQty
		,1
		,ri.intConsumptionMethodId
		,ri.intStorageLocationId
		,ri.intItemId
	FROM tblMFWorkOrderRecipeSubstituteItem rs
	JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = rs.intWorkOrderId
	JOIN tblMFWorkOrderRecipeItem ri on rs.intRecipeItemId=ri.intRecipeItemId
	WHERE r.intRecipeId = @intRecipeId
		AND rs.intRecipeItemTypeId = 1
		AND r.intWorkOrderId = @intWorkOrderId
		AND ri.intConsumptionMethodId <> 1

If @intSalesOrderId=0 --Kit Pick List
Begin
	SELECT pl.strPickListNo,  
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
			dbo.fnRemoveTrailingZeroes(@dblQtyToProduce) AS dblReqQty,
			dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) AS dblTotalPickQty,
			pld.dblQuantity AS dblQuantity,
			0 AS dblCost,
			0 AS dblTotalCost
			,@strCompanyName AS strCompanyName
			,@strCompanyAddress AS strCompanyAddress
			,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCompanyCityStateZip
			,@strCountry AS strCompanyCountry
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
	Select @strPickListNo,@strBlendItemNoDesc,@strWorkOrderNo,'' strLotNumber,'' strLotAlias,sl.strName AS strStorageLocationName,
	i.strItemNo,i.strDescription,dbo.fnRemoveTrailingZeroes(sr.dblQty) AS dblPickQuantity,um.strUnitMeasure AS strUOM,'',
	@intWorkOrderCount,'' strParentLotNumber,dbo.fnRemoveTrailingZeroes(@dblQtyToProduce) AS dblReqQty,dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) AS dblTotalPickQty,
	sr.dblQty AS dblQuantity,0 AS dblCost,0 AS dblTotalCost
	,@strCompanyName AS strCompanyName
	,@strCompanyAddress AS strCompanyAddress
	,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCompanyCityStateZip
	,@strCountry AS strCompanyCountry
	From tblICStockReservation sr Join @tblInputItem ti on sr.intItemId=ti.intItemId
	Join tblICItem i on ti.intItemId=i.intItemId
	Join tblICItemUOM iu on sr.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Left Join tblICStorageLocation sl on ti.intStorageLocationId=sl.intStorageLocationId
	Where sr.intTransactionId=@intPickListId AND intInventoryTransactionType=34 AND ISNULL(sr.intLotId,0)=0
	ORDER BY dblQuantity--strPickUOM
End
Else
Begin --Sales Order Pick List
	Select @dblTotalCost= SUM(pl.dblQuantity * ISNULL(l.dblLastCost,0)) From tblMFPickListDetail pl Join tblICLot l on pl.intLotId=l.intLotId 
	Where intPickListId=@intPickListId AND ISNULL(pl.intLotId,0)>0

	Select @dblTotalCost=ISNULL(@dblTotalCost,0) + ISNULL(SUM(pl.dblQuantity * ISNULL(ip.dblStandardCost,0)),0) 
	From tblMFPickListDetail pl Join tblICItem i on pl.intItemId=i.intItemId
	Join tblICItemLocation il on i.intItemId=il.intItemId AND il.intLocationId=@intLocationId
	Join tblICItemPricing ip on i.intItemId=ip.intItemId AND ip.intItemLocationId=il.intItemLocationId
	Where intPickListId=@intPickListId AND ISNULL(pl.intLotId,0)=0

	SELECT distinct pl.strPickListNo,  
			''  AS strBlendItemNoDesc,  
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
			'' strParentLotNumber,
			dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) AS dblReqQty,
			dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) AS dblTotalPickQty,
			pld.dblQuantity AS dblQuantity,
			pld.dblQuantity * (
			CASE WHEN ISNULL(pld.intLotId,0) > 0 THEN ISNULL(l.dblLastCost,0) ELSE 
			(Select TOP 1 ISNULL(ip.dblStandardCost,0) From tblICItemLocation il Join tblICItemPricing ip on il.intItemId=ip.intItemId AND il.intLocationId=@intLocationId AND il.intItemId=pld.intItemId)
			End ) AS dblCost,
			@dblTotalCost AS dblTotalCost
			,@strCompanyName AS strCompanyName
			,@strCompanyAddress AS strCompanyAddress
			,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCompanyCityStateZip
			,@strCountry AS strCompanyCountry
	FROM tblMFPickList pl  
	JOIN tblMFPickListDetail pld ON pl.intPickListId=pld.intPickListId
	JOIN tblICItem i on pld.intItemId=i.intItemId
	Left JOIN tblICLot l on l.intLotId=pld.intLotId
	Left JOIN tblICStorageLocation sl on sl.intStorageLocationId=l.intStorageLocationId
	Join tblICItemUOM iu on pld.intPickUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	WHERE pl.intPickListId=@intPickListId 
	ORDER BY dblQuantity
End