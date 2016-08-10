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
Declare @strUOM nvarchar(50)
Declare @strSONo nvarchar(50)
Declare @strShipTo nvarchar(max)
Declare @strCustomerComments nvarchar(max)
Declare @ysnShowCostInSalesOrderPickList bit

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

DECLARE @tblRecipeInputItem TABLE (
	intRecipeId INT,
	intItemId INT,
	intMarginById INT,
	dblMargin NUMERIC(38,20)
)

Declare @tblItems AS TABLE
(
	[strPickListNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strBlendItemNoDesc] [varchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strWorkOrderNo] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strLotNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strLotAlias] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strStorageLocationName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[dblPickQuantity] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strPickUOM] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strGarden] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intWorkOrderCount] [int] NULL,
	[strParentLotNumber] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dblReqQty] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dblTotalPickQty] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[dblQuantity] [numeric](38, 20) NULL,
	[dblCost] [numeric](38, 20) NULL,
	[dblTotalCost] [numeric](38, 20) NULL,
	[strCompanyName] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strCompanyAddress] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strCompanyCityStateZip] [nvarchar](92) COLLATE Latin1_General_CI_AS NULL,
	[strCompanyCountry] [nvarchar](25) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerName] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strLocationName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strBOLNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strSalespersonName] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strShipVia] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strFreightTerm] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strPONumber] [nvarchar](25) COLLATE Latin1_General_CI_AS NULL,
	[strTerm] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strOrderStatus] [nvarchar](25) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [datetime] NULL,
	[dtmDueDate] [datetime] NULL,
	[strSOComments] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strShipTo] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strPhone] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerComments] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[ysnShowCostInSalesOrderPickList] bit null default 0,
	[ysnLotTracking] bit null default 0
)

If ISNULL(@xmlParam,'')=''
Begin
	Select * from @tblItems
	Return
End

Select @intLocationId=intLocationId,@strPickListNo=strPickListNo,@strWorkOrderNo=strWorkOrderNo,@intSalesOrderId=ISNULL(intSalesOrderId,0) from tblMFPickList Where intPickListId=@intPickListId
Select TOP 1 @intBlendItemId=w.intItemId,@strBlendItemNoDesc=(i.strItemNo + ' - '  + ISNULL(i.strDescription,'')),@intWorkOrderId=intWorkOrderId,@intBlendRequirementId=intBlendRequirementId,@intKitStatusId=intKitStatusId,
@strUOM=um.strUnitMeasure 
From tblMFWorkOrder w Join tblICItem i on w.intItemId=i.intItemId 
Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Where intPickListId=@intPickListId
Select @dblQtyToProduce=SUM(dblQuantity) From tblMFWorkOrder Where intPickListId=@intPickListId
Select @dblTotalPickQty=SUM(dblQuantity) From tblMFPickListDetail Where intPickListId=@intPickListId
Select @strSONo=strSalesOrderNumber From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId

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
		AND ri.intConsumptionMethodId IN (2,3)

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
		AND ri.intConsumptionMethodId IN (2,3)

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
			dbo.fnRemoveTrailingZeroes(@dblQtyToProduce) + ' ' + @strUOM AS dblReqQty,
			dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) + ' ' + @strUOM AS dblTotalPickQty,
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
	@intWorkOrderCount,'' strParentLotNumber,dbo.fnRemoveTrailingZeroes(@dblQtyToProduce) + ' ' + @strUOM  AS dblReqQty,dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) + ' ' + @strUOM AS dblTotalPickQty,
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
	Where sr.intTransactionId=@intPickListId AND intInventoryTransactionType=34 AND ISNULL(sr.intLotId,0)=0 AND i.strLotTracking <> 'No'
	UNION --Non Lot Tracked Items
	Select @strPickListNo,@strBlendItemNoDesc,@strWorkOrderNo,'' strLotNumber,'' strLotAlias,sl.strName AS strStorageLocationName,
	i.strItemNo,i.strDescription,dbo.fnRemoveTrailingZeroes(pld.dblQuantity) AS dblPickQuantity,um.strUnitMeasure AS strUOM,'',
	@intWorkOrderCount,'' strParentLotNumber,dbo.fnRemoveTrailingZeroes(@dblQtyToProduce) + ' ' + @strUOM AS dblReqQty,dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) + ' ' + @strUOM AS dblTotalPickQty,
	pld.dblQuantity AS dblQuantity,0 AS dblCost,0 AS dblTotalCost
	,@strCompanyName AS strCompanyName
	,@strCompanyAddress AS strCompanyAddress
	,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCompanyCityStateZip
	,@strCountry AS strCompanyCountry
	From tblMFPickListDetail pld
	Join tblICItem i on pld.intItemId=i.intItemId
	Join tblICItemUOM iu on pld.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Left Join tblICStorageLocation sl on pld.intStorageLocationId=sl.intStorageLocationId
	Where pld.intPickListId=@intPickListId AND ISNULL(pld.intLotId,0)=0
	ORDER BY dblQuantity--strPickUOM
End
Else
Begin --Sales Order Pick List
	Select TOP 1 @ysnShowCostInSalesOrderPickList=ISNULL(ysnShowCostInSalesOrderPickList,0) From tblMFCompanyPreference

	Select TOP 1 @strUOM = um.strUnitMeasure 
	From tblMFPickListDetail pld Join tblICItemUOM iu on pld.intItemUOMId=iu.intItemUOMId 
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId Where pld.intPickListId=@intPickListId

	INSERT INTO @tblRecipeInputItem(intRecipeId,intItemId,intMarginById,dblMargin)
	Select distinct r.intRecipeId,ri.intItemId,ri.intMarginById,ISNULL(ri.dblMargin,0)
	From tblSOSalesOrderDetail sd Join tblMFRecipe r on sd.intRecipeId=r.intRecipeId
	Join tblMFRecipeItem ri on r.intRecipeId=ri.intRecipeId AND ri.intItemId=sd.intItemId
	Where sd.intSalesOrderId=@intSalesOrderId

	Select @dblTotalCost=SUM(dblCost) From 
	(
	SELECT 
			ISNULL(dbo.fnICConvertUOMtoStockUnit(pld.intItemId,pld.intItemUOMId,pld.dblQuantity) * (
			CASE WHEN ISNULL(pld.intLotId,0) > 0 THEN 
				CASE WHEN ISNULL(l.dblLastCost,0) > 0 THEN
					ISNULL(l.dblLastCost,0) 
				ELSE
					(Select TOP 1 ISNULL(ip.dblCost,0) From vyuMFGetItemByLocation ip Where ip.intLocationId=@intLocationId AND ip.intItemId=pld.intItemId)
				END		
			ELSE 
			CASE WHEN ri.intMarginById=1 THEN 
			ISNULL((Select TOP 1 ISNULL(ip.dblCost,0) From vyuMFGetItemByLocation ip Where ip.intLocationId=@intLocationId AND ip.intItemId=pld.intItemId),0) 
			+ (ISNULL(ri.dblMargin,0) * ISNULL((Select TOP 1 ISNULL(ip.dblCost,0) From vyuMFGetItemByLocation ip Where ip.intLocationId=@intLocationId AND ip.intItemId=pld.intItemId ),0))/100
			ELSE (Select TOP 1 ISNULL(ip.dblCost,0) From vyuMFGetItemByLocation ip Where ip.intLocationId=@intLocationId AND ip.intItemId=pld.intItemId ) + ISNULL(ri.dblMargin,0) End
			End ),0) AS dblCost
		FROM tblMFPickList pl  
		JOIN tblMFPickListDetail pld ON pl.intPickListId=pld.intPickListId
		JOIN tblICItem i on pld.intItemId=i.intItemId
		Left JOIN tblICLot l on l.intLotId=pld.intLotId
		Join tblICItemUOM iu on pld.intPickUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Left Join @tblRecipeInputItem ri on pld.intItemId=ri.intItemId
		WHERE pl.intPickListId=@intPickListId 
	) t

	Set @dblTotalCost=@dblTotalCost + (Select ISNULL(SUM(dblLineTotal),0) From [dbo].[fnMFGetInvoiceChargesByShipment](0,@intSalesOrderId))

	Select @strShipTo= ISNULL(RTRIM(el.strAddress) + CHAR(13) + char(10), '')
					 + ISNULL(RTRIM(el.strCity), '')
					 + ISNULL(', ' + RTRIM(el.strState), '')
					 + ISNULL(', ' + RTRIM(el.strZipCode), '') + CHAR(13)
					 + ISNULL(RTRIM(el.strCountry), '')
	From tblSOSalesOrder so Join tblEMEntityLocation el on so.intShipToLocationId=el.intEntityLocationId
	Where intSalesOrderId=@intSalesOrderId

	Select @strCustomerComments=COALESCE(@strCustomerComments, '') + dm.strMessage + CHAR(13)
	From tblSMDocumentMaintenanceMessage dm 
	Join tblSMDocumentMaintenance d on dm.intDocumentMaintenanceId=d.intDocumentMaintenanceId
	Where d.intEntityCustomerId = (Select intEntityCustomerId From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId)
	AND dm.ysnPickList=1

	INSERT INTO @tblItems
	SELECT pl.strPickListNo ,  
			''  AS strBlendItemNoDesc,  
			pl.strWorkOrderNo,  
			l.strLotNumber,
			l.strLotAlias,
			sl.strName AS strStorageLocationName,
			i.strItemNo COLLATE Latin1_General_CI_AS AS strItemNo,
			ISNULL(i.strDescription,'') + CHAR(13) + ISNULL(i.strPickListComments,'') COLLATE Latin1_General_CI_AS AS strDescription,
			dbo.fnRemoveTrailingZeroes(pld.dblPickQuantity) AS dblPickQuantity,
			um.strUnitMeasure AS strPickUOM,
			l.strGarden,
			@intWorkOrderCount AS intWorkOrderCount,
			'' strParentLotNumber,
			dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) AS dblReqQty,
			dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) + ' ' + @strUOM AS dblTotalPickQty,
			pld.dblQuantity AS dblQuantity,
			dbo.fnICConvertUOMtoStockUnit(pld.intItemId,pld.intItemUOMId,pld.dblQuantity) * (
			CASE WHEN ISNULL(pld.intLotId,0) > 0 THEN 
				CASE WHEN ISNULL(l.dblLastCost,0) > 0 THEN
					ISNULL(l.dblLastCost,0) 
				ELSE
					(Select TOP 1 ISNULL(ip.dblCost,0) From vyuMFGetItemByLocation ip Where ip.intLocationId=@intLocationId AND ip.intItemId=pld.intItemId)
				END		
			ELSE 
			CASE WHEN ri.intMarginById=1 THEN 
			ISNULL((Select TOP 1 ISNULL(ip.dblCost,0) From vyuMFGetItemByLocation ip Where ip.intLocationId=@intLocationId AND ip.intItemId=pld.intItemId ),0) 
			+ (ISNULL(ri.dblMargin,0) * ISNULL((Select TOP 1 ISNULL(ip.dblCost,0) From vyuMFGetItemByLocation ip Where ip.intLocationId=@intLocationId AND ip.intItemId=pld.intItemId ),0))/100
			ELSE (Select TOP 1 ISNULL(ip.dblCost,0) From vyuMFGetItemByLocation ip Where ip.intLocationId=@intLocationId AND ip.intItemId=pld.intItemId ) + ISNULL(ri.dblMargin,0) End
			End ) AS dblCost,
			@dblTotalCost AS dblTotalCost
			,@strCompanyName AS strCompanyName
			,@strCompanyAddress AS strCompanyAddress
			,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCompanyCityStateZip
			,@strCountry AS strCompanyCountry
			,c.strName AS strCustomerName
			,cl.strLocationName
			,so.strBOLNumber
			,sp.strName AS strSalespersonName
			,sv.strShipVia
			,ft.strFreightTerm
			,so.strPONumber
			,tm.strTerm
			,so.strOrderStatus
			,so.dtmDate
			,so.dtmDueDate
			,so.strComments AS strSOComments
			,@strShipTo AS strShipTo
			,c.strPhone
			,@strCustomerComments
			,@ysnShowCostInSalesOrderPickList
			,0
	FROM tblMFPickList pl  
	JOIN tblMFPickListDetail pld ON pl.intPickListId=pld.intPickListId
	JOIN tblICItem i on pld.intItemId=i.intItemId
	Left JOIN tblICLot l on l.intLotId=pld.intLotId
	Left JOIN tblICStorageLocation sl on sl.intStorageLocationId=l.intStorageLocationId
	Join tblICItemUOM iu on pld.intPickUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Left Join @tblRecipeInputItem ri on pld.intItemId=ri.intItemId
	Join tblSOSalesOrder so on pl.intSalesOrderId=so.intSalesOrderId
	Join vyuARCustomer c on so.intEntityCustomerId=c.intEntityCustomerId
	Join tblSMCompanyLocation cl on so.intCompanyLocationId=cl.intCompanyLocationId
	Left Join vyuEMSalesperson sp on so.intEntitySalespersonId=sp.intEntitySalespersonId
	Left Join tblSMShipVia sv on so.intShipViaId=sv.intEntityShipViaId
	Left Join tblSMFreightTerms ft on so.intFreightTermId=ft.intFreightTermId
	Left Join tblSMTerm tm on so.intTermId=tm.intTermID
	WHERE pl.intPickListId=@intPickListId 
	ORDER BY dblQuantity
	
	--Other Charge
	If @ysnShowCostInSalesOrderPickList=1
		INSERT INTO @tblItems
		Select @strPickListNo strPickListNo,  
				''  AS strBlendItemNoDesc,  
				@strSONo strWorkOrderNo,  
				'' strLotNumber,
				'' strLotAlias,
				'' AS strStorageLocationName,
				strItemNo COLLATE Latin1_General_CI_AS AS strItemNo,
				strDescription COLLATE Latin1_General_CI_AS AS strDescription,
				NULL AS dblPickQuantity,
				'' AS strPickUOM,
				'' strGarden,
				@intWorkOrderCount AS intWorkOrderCount,
				'' strParentLotNumber,
				NULL AS dblReqQty,
				dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) + ' ' + @strUOM AS dblTotalPickQty,
				NULL AS dblQuantity,
				dblLineTotal AS dblCost,
				@dblTotalCost AS dblTotalCost
				,@strCompanyName AS strCompanyName
				,@strCompanyAddress AS strCompanyAddress
				,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCompanyCityStateZip
				,@strCountry AS strCompanyCountry 
				,'','','','','','','','','',null,null,'','','','',@ysnShowCostInSalesOrderPickList,0
		From [dbo].[fnMFGetInvoiceChargesByShipment](0,@intSalesOrderId)
	
	If Exists (Select 1 From @tblItems Where ISNULL(LTRIM(RTRIM(strLotNumber)),'')<>'')
		Update @tblItems set ysnLotTracking=1

	If @ysnShowCostInSalesOrderPickList=0 
		Update @tblItems set dblTotalCost=null

	Select * from @tblItems
End