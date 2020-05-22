CREATE PROCEDURE [dbo].[uspMFPickListReport]
@xmlParam NVARCHAR(MAX) = NULL
AS
	DECLARE @intPickListId			INT,
			@idoc					INT,
			@intSalesOrderId		INT, 
			@intRecipeGuideId		INT

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

	SELECT	@intSalesOrderId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intSalesOrderId'

	SELECT	@intRecipeGuideId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intRecipeGuideId'

	Set @intSalesOrderId = ISNULL(@intSalesOrderId,0)

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
Declare @dblTotalCost NUMERIC(38,20)
Declare @strUOM nvarchar(50)
Declare @strSONo nvarchar(50)
Declare @strShipTo nvarchar(max)
Declare @strCustomerComments nvarchar(max)
Declare @strFooterComments nvarchar(max)
Declare @ysnShowCostInSalesOrderPickList bit=0
Declare @ysnShowAddOnItemQtyInSalesOrderPickList bit=0
Declare @intMaxOtherChargeId int
Declare @ysnIncludeEntityName bit=0
Declare @strCustomerName nvarchar(250)
Declare @intNoOfBatches INT
Declare @intNoOfBatchesCopy INT
Declare @dblBatchSize NUMERIC(38,20)
Declare @intMinItem int
Declare @intItemId int
Declare @dblRequiredQty numeric(38,20)
Declare @intMinLot int
Declare @intLotId int
Declare @dblAvailableQty numeric(38,20)
Declare @intPickListDetailId int
Declare @intBatchCounter INT=1
Declare @strCustomerMessages nvarchar(max)
Declare @ysnShowRunningWeight bit=0

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

Declare @tblItems AS TABLE
(
	[strPickListNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strBlendItemNoDesc] [varchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strWorkOrderNo] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strLotNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strLotAlias] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strStorageLocationName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
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
	[ysnLotTracking] bit null default 0,
	[intSalesOrderDetailId] int null,
	[strItemType] nvarchar(50) null,
	[strFooterComments] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intBatchId] INT NULL default 0,
	[dblBatchSize] [numeric](38, 20) NULL,
	[strCommodityCode] nvarchar(50) null,
	[dblNoOfAcre] [numeric](38, 20) NULL,
	[strFarmNumber] nvarchar(50) null,
	[strFieldNumber] nvarchar(50) null,
	[dblLatitude] [numeric](38, 20) NULL,
	[dblLongitude] [numeric](38, 20) NULL,
	[strDirection] nvarchar(MAX) null,
	[strNote] nvarchar(MAX) null,
	[strGuaranteedAnalysis] nvarchar(MAX) null,
	[imgFieldMapFile] VARBINARY(MAX) null,
	[strRate] nvarchar(MAX) null,
	[strSplitNumber] nvarchar(50) null,
	[strOrderType] nvarchar(50) null,
	[strTax] nvarchar(50) null,
	[dblDensity] [numeric](38, 20) NULL,
	[dblAvgDensity] [numeric](38, 20) NULL,
	[intNoOfBatches] INT NULL,
	[strApplicator] nvarchar(MAX) null,
	[strLicenseNo] nvarchar(MAX) null,
	[strMethodOfApp] nvarchar(MAX) null,
	[dblCubicFeet] [numeric](38, 20) NULL,
	[strEPANumber] nvarchar(MAX) null
)

DECLARE @tblLot TABLE (
	 intRowNo INT IDENTITY
    ,intPickListDetailId INT
	,intLotId INT
	,intItemId INT
	,dblQty NUMERIC(38,20)
	,intItemUOMId INT
	,intLocationId INT
	,intSubLocationId INT
	,intStorageLocationId INT
	)

If ISNULL(@xmlParam,'')=''
Begin
	Select * from @tblItems
	Return
End

If @intSalesOrderId=0 --Kit Pick List
Begin
	Select @intLocationId=intLocationId,@strPickListNo=strPickListNo,@strWorkOrderNo=strWorkOrderNo from tblMFPickList Where intPickListId=@intPickListId
	Select TOP 1 @intBlendItemId=w.intItemId,@strBlendItemNoDesc=(i.strItemNo + ' - '  + ISNULL(i.strDescription,'')),@intWorkOrderId=intWorkOrderId,@intBlendRequirementId=intBlendRequirementId,@intKitStatusId=intKitStatusId,
	@strUOM=um.strUnitMeasure 
	From tblMFWorkOrder w Join tblICItem i on w.intItemId=i.intItemId 
	Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Where intPickListId=@intPickListId
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
	Select TOP 1 @ysnShowCostInSalesOrderPickList=ISNULL(ysnPrintPriceOnPrintTicket,0),@ysnIncludeEntityName=ISNULL(ysnIncludeEntityName,0) From tblARCustomer 
	Where [intEntityId]=(Select intEntityCustomerId From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId)

	Select TOP 1 @intPickListId=ISNULL(intPickListId,0),@dblBatchSize=ISNULL(dblBatchSize,0) From tblMFPickList Where intSalesOrderId=@intSalesOrderId

	SELECT TOP 1 @ysnShowAddOnItemQtyInSalesOrderPickList = ISNULL(ysnShowAddOnItemQtyInSalesOrderPickList, 0) FROM tblMFCompanyPreference

	--Printing from Recipe Guide screen 
	if @intRecipeGuideId>0
		Set @intPickListId=0

	Select @dblTotalPickQty=SUM(SO.dblQtyOrdered)
	From tblSOSalesOrderDetail SO
	JOIN tblICItem I ON I.intItemId = SO.intItemId
	Where SO.intSalesOrderId = @intSalesOrderId
		AND I.strType <> 'Other Charge'
	
	If @dblBatchSize > 0
	Begin
		Set @intNoOfBatches=ceiling(@dblTotalPickQty / @dblBatchSize)
		Set @intNoOfBatchesCopy=@intNoOfBatches
	End
				 
	Select TOP 1 @strUOM = um.strUnitMeasure 
	From tblSOSalesOrderDetail sd Join tblICItemUOM iu on sd.intItemUOMId=iu.intItemUOMId 
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	JOIN tblICItem I ON I.intItemId = sd.intItemId Where sd.intSalesOrderId=@intSalesOrderId AND I.strType <> 'Other Charge'

	-- If having 2 different pick qty UOM, resetting the value
	IF (
			SELECT COUNT(DISTINCT um.strUnitMeasure)
			FROM tblSOSalesOrderDetail sd
			JOIN tblICItemUOM iu ON sd.intItemUOMId = iu.intItemUOMId
			JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
			JOIN tblICItem I ON I.intItemId = sd.intItemId
			WHERE sd.intSalesOrderId = @intSalesOrderId
				AND I.strType <> 'Other Charge'
			) > 1
	BEGIN
		SELECT @dblTotalPickQty = NULL
			,@strUOM = NULL
	END


	Select @intLocationId=intCompanyLocationId,@strSONo=strSalesOrderNumber From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId

	Select @strCustomerName=ISNULL(strName,'') From vyuARCustomer Where [intEntityId]=(Select intEntityCustomerId From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId)

	Select @strShipTo= ISNULL(RTRIM(CASE WHEN @ysnIncludeEntityName=1 THEN @strCustomerName + CHAR(13) ELSE '' END),'') 
					 + ISNULL(RTRIM(so.strShipToLocationName),'') + CHAR(13)
					 + ISNULL(RTRIM(el.strAddress) + CHAR(13) + char(10), '')
					 + ISNULL(RTRIM(el.strCity), '')
					 + ISNULL(', ' + RTRIM(el.strState), '')
					 + ISNULL(', ' + RTRIM(el.strZipCode), '') + CHAR(13)
					 + ISNULL(RTRIM(el.strCountry), '')
	From tblSOSalesOrder so Join tblEMEntityLocation el on so.intShipToLocationId=el.intEntityLocationId
	Where intSalesOrderId=@intSalesOrderId

	Select @strCustomerComments=COALESCE(@strCustomerComments, '') + dm.strMessage + CHAR(13)
	From tblSMDocumentMaintenanceMessage dm 
	Join tblSMDocumentMaintenance d on dm.intDocumentMaintenanceId=d.intDocumentMaintenanceId
	Where d.intEntityCustomerId = (Select intEntityCustomerId From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId) AND d.intCompanyLocationId=@intLocationId
	AND dm.ysnPickList=1 AND dm.strHeaderFooter='Header'

	If ISNULL(@strCustomerComments,'')=''
		Select @strCustomerComments=COALESCE(@strCustomerComments, '') + dm.strMessage + CHAR(13)
		From tblSMDocumentMaintenanceMessage dm 
		Join tblSMDocumentMaintenance d on dm.intDocumentMaintenanceId=d.intDocumentMaintenanceId
		Where d.intEntityCustomerId = (Select intEntityCustomerId From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId)
		AND dm.ysnPickList=1 AND dm.strHeaderFooter='Header'

	Set @strCustomerMessages=dbo.fnEMEntityMessage((Select intEntityCustomerId From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId), 'Pick Ticket')

	If ISNULL(@strCustomerMessages,'')<>''
	Begin
		If ISNULL(@strCustomerComments,'')=''
			Set @strCustomerComments=@strCustomerMessages
		Else
			Set @strCustomerComments = @strCustomerComments + CHAR(13) + @strCustomerMessages
	End

	Select @strFooterComments=COALESCE(@strFooterComments, '') + dm.strMessage + CHAR(13)
	From tblSMDocumentMaintenanceMessage dm 
	Join tblSMDocumentMaintenance d on dm.intDocumentMaintenanceId=d.intDocumentMaintenanceId
	Where d.intEntityCustomerId = (Select intEntityCustomerId From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId) AND d.intCompanyLocationId=@intLocationId
	AND dm.ysnPickList=1 AND dm.strHeaderFooter='Footer'

	If ISNULL(@strFooterComments,'')=''
		Select @strFooterComments=COALESCE(@strFooterComments, '') + dm.strMessage + CHAR(13)
		From tblSMDocumentMaintenanceMessage dm 
		Join tblSMDocumentMaintenance d on dm.intDocumentMaintenanceId=d.intDocumentMaintenanceId
		Where d.intEntityCustomerId = (Select intEntityCustomerId From tblSOSalesOrder Where intSalesOrderId=@intSalesOrderId)
		AND dm.ysnPickList=1 AND dm.strHeaderFooter='Footer'

	If @intPickListId>0
		Begin
			If (Select count(1) from tblSOSalesOrderDetail a Join tblICItem b on a.intItemId=b.intItemId 
					where a.intSalesOrderId=@intSalesOrderId 
					AND b.strType NOT IN ('Other Charge','Comment')) = 1 --Exclude Single Item
				OR 
				(Select COUNT(distinct c.intUnitMeasureId) From tblMFPickListDetail a Join tblICItem b on a.intItemId=b.intItemId 
				Join tblICItemUOM c on a.intItemUOMId=c.intItemUOMId
				Where a.intPickListId=@intPickListId AND b.strType NOT IN ('Other Charge','Comment')) = 1 --Exclude All Items with Same UOM
			Begin
				Set @ysnShowRunningWeight=1
			End

			INSERT INTO @tblItems
			SELECT pl.strPickListNo ,  
					''  AS strBlendItemNoDesc,  
					pl.strWorkOrderNo,  
					l.strLotNumber,
					l.strLotAlias,
					sl.strName AS strStorageLocationName,
					i.strItemNo COLLATE Latin1_General_CI_AS AS strItemNo,
					--ISNULL(i.strDescription,'') + CHAR(13) + ISNULL(i.strPickListComments,'') COLLATE Latin1_General_CI_AS AS strDescription,
					CASE 
						WHEN ISNULL(sd.strAddonDetailKey, '') <> ''
							AND ISNULL(sd.ysnAddonParent, 0) = 0
							AND @ysnShowAddOnItemQtyInSalesOrderPickList = 1
							THEN ISNULL(i.strDescription, '') + CHAR(13) + ISNULL(i.strPickListComments, '') + (
									SELECT ' ' + CONVERT(NVARCHAR, CONVERT(NUMERIC(38, 2), (ISNULL(Ad.dblQuantity, 0)))) + ' ' + um.strUnitMeasure + '/' + UOM1.strUnitMeasure
									FROM tblSOSalesOrderDetail sd1
									JOIN tblICItemAddOn Ad ON Ad.intItemId = sd1.intItemId
										AND sd1.strAddonDetailKey = sd.strAddonDetailKey
										AND sd1.ysnAddonParent = 1
									JOIN tblICItemUOM IUOM1 ON IUOM1.intItemUOMId = sd1.intItemUOMId
									JOIN tblICUnitMeasure UOM1 ON UOM1.intUnitMeasureId = IUOM1.intUnitMeasureId
									)
						ELSE ISNULL(i.strDescription, '') + CHAR(13) + ISNULL(i.strPickListComments, '')
						END COLLATE Latin1_General_CI_AS AS strDescription,
					dbo.fnRemoveTrailingZeroes(pld.dblPickQuantity) AS dblPickQuantity,
					um.strUnitMeasure AS strPickUOM,
					l.strGarden,
					@intWorkOrderCount AS intWorkOrderCount,
					'' strParentLotNumber,
					dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) AS dblReqQty,
					dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) + ' ' + @strUOM AS dblTotalPickQty,
					pld.dblQuantity,
					CASE WHEN ISNULL(pld.intLotId,0)>0 THEN (dbo.fnICConvertUOMtoStockUnit(pld.intItemId,pld.intItemUOMId,pld.dblQuantity) * ISNULL(l.dblLastCost,0))
					- ((dbo.fnICConvertUOMtoStockUnit(pld.intItemId,pld.intItemUOMId,pld.dblQuantity) * ISNULL(l.dblLastCost,0) * ISNULL(sd.dblDiscount,0.0))/100)
					Else (pld.dblQuantity * ISNULL(sd.dblPrice,0.0)) - ((pld.dblQuantity * ISNULL(sd.dblPrice,0.0) * ISNULL(sd.dblDiscount,0.0))/100) END AS dblCost,
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
					,@strShipTo + (CHAR(13) + c.strPhone) AS strShipTo
					,c.strPhone
					,@strCustomerComments
					,@ysnShowCostInSalesOrderPickList
					,0
					,sd.intSalesOrderDetailId
					,i.strType
					,@strFooterComments
					,0
					,0.0
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
			FROM tblMFPickList pl  
			JOIN tblMFPickListDetail pld ON pl.intPickListId=pld.intPickListId
			JOIN tblICItem i on pld.intItemId=i.intItemId
			Left JOIN tblICLot l on l.intLotId=pld.intLotId
			Left JOIN tblICStorageLocation sl on sl.intStorageLocationId=pld.intStorageLocationId
			Join tblICItemUOM iu on pld.intPickUOMId=iu.intItemUOMId
			Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
			Join tblSOSalesOrder so on pl.intSalesOrderId=so.intSalesOrderId
			Join vyuARCustomer c on so.intEntityCustomerId=c.[intEntityId]
			Join tblSMCompanyLocation cl on so.intCompanyLocationId=cl.intCompanyLocationId
			Left Join vyuEMSalesperson sp on so.intEntitySalespersonId=sp.[intEntityId]
			Left Join tblSMShipVia sv on so.intShipViaId=sv.[intEntityId]
			Left Join tblSMFreightTerms ft on so.intFreightTermId=ft.intFreightTermId
			Left Join tblSMTerm tm on so.intTermId=tm.intTermID
			Join tblSOSalesOrderDetail sd on sd.intSalesOrderId=so.intSalesOrderId AND sd.intItemId=pld.intItemId
			WHERE pl.intPickListId=@intPickListId 

			--Delete duplicate item records
			DELETE t FROM @tblItems t 
				WHERE EXISTS (
					SELECT *
					FROM @tblItems t1
					WHERE t.strItemNo = t1.strItemNo
					AND t.intSalesOrderDetailId > t1.intSalesOrderDetailId
					)
		End
	Else
		Begin
			If (Select count(1) from tblSOSalesOrderDetail a Join tblICItem b on a.intItemId=b.intItemId 
					where a.intSalesOrderId=@intSalesOrderId 
					AND b.strType NOT IN ('Other Charge','Comment')) = 1  --Exclude Single Item
				OR 
				(Select COUNT(distinct c.intUnitMeasureId) From tblSOSalesOrderDetail a Join tblICItem b on a.intItemId=b.intItemId 
				Join tblICItemUOM c on a.intItemUOMId=c.intItemUOMId
				Where a.intSalesOrderId=@intSalesOrderId AND b.strType NOT IN ('Other Charge','Comment')) = 1 --Exclude All Items Same UOM
			Begin
				Set @ysnShowRunningWeight=1
			End

			INSERT INTO @tblItems
			SELECT so.strSalesOrderNumber strPickListNo ,  
			''  AS strBlendItemNoDesc,  
			so.strSalesOrderNumber strWorkOrderNo,  
			'' strLotNumber,
			'' strLotAlias,
			sl.strName AS strStorageLocationName,
			i.strItemNo COLLATE Latin1_General_CI_AS AS strItemNo,
			--ISNULL(i.strDescription,'') + CHAR(13) + ISNULL(i.strPickListComments,'') COLLATE Latin1_General_CI_AS AS strDescription,
			CASE 
				WHEN ISNULL(sd.strAddonDetailKey, '') <> ''
					AND ISNULL(sd.ysnAddonParent, 0) = 0
					AND @ysnShowAddOnItemQtyInSalesOrderPickList = 1
					THEN ISNULL(i.strDescription, '') + CHAR(13) + ISNULL(i.strPickListComments, '') + (
							SELECT ' ' + CONVERT(NVARCHAR, CONVERT(NUMERIC(38, 2), (ISNULL(Ad.dblQuantity, 0)))) + ' ' + um.strUnitMeasure + '/' + UOM1.strUnitMeasure
							FROM tblSOSalesOrderDetail sd1
							JOIN tblICItemAddOn Ad ON Ad.intItemId = sd1.intItemId
								AND sd1.strAddonDetailKey = sd.strAddonDetailKey
								AND sd1.ysnAddonParent = 1
							JOIN tblICItemUOM IUOM1 ON IUOM1.intItemUOMId = sd1.intItemUOMId
							JOIN tblICUnitMeasure UOM1 ON UOM1.intUnitMeasureId = IUOM1.intUnitMeasureId
							)
				ELSE ISNULL(i.strDescription, '') + CHAR(13) + ISNULL(i.strPickListComments, '')
				END COLLATE Latin1_General_CI_AS AS strDescription,
			dbo.fnRemoveTrailingZeroes(sd.dblQtyOrdered) AS dblPickQuantity,
			um.strUnitMeasure AS strPickUOM,
			'' strGarden,
			@intWorkOrderCount AS intWorkOrderCount,
			'' strParentLotNumber,
			dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) AS dblReqQty,
			dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) + ' ' + @strUOM AS dblTotalPickQty,
			sd.dblQtyOrdered AS dblQuantity,
            (sd.dblQtyOrdered * ISNULL(sd.dblPrice,0)) - ((sd.dblQtyOrdered * ISNULL(sd.dblPrice,0) * ISNULL(sd.dblDiscount,0.0))/100)  AS dblCost,
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
			,@strShipTo + (CHAR(13) + c.strPhone) AS strShipTo
			,c.strPhone
			,@strCustomerComments
			,@ysnShowCostInSalesOrderPickList
			,0
			,sd.intSalesOrderDetailId
			,i.strType
			,@strFooterComments
			,0
			,0.0
			,cd.strCommodityCode
			,rg.dblNoOfAcre
			,ef.strLocationName
			,ef.strFarmFieldNumber
			,ef.dblLatitude
			,ef.dblLongitude
			,ef.strAddress
			,rg.strComment
			,rg.strGuaranteedAnalysis
			,CASE WHEN ef.imgFieldMapFile=0x THEN NULL ELSE ef.imgFieldMapFile END
			,null AS strRate
			,es.strSplitNumber
			,so.strType
			,CASE WHEN sd.dblTotalTax>0 THEN 'Y' ELSE 'N' END
			,dblDensity
			,null
			,rg.intNoOfBatches
			,ca.strName
			,ca.strLicenseNo
			,ma.strName
			,null
			,i.strEPANumber
			FROM tblSOSalesOrderDetail sd  
			JOIN tblICItem i on sd.intItemId=i.intItemId
			Join tblICItemUOM iu on sd.intItemUOMId=iu.intItemUOMId
			Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
			Join tblSOSalesOrder so on sd.intSalesOrderId=so.intSalesOrderId
			Join vyuARCustomer c on so.intEntityCustomerId=c.[intEntityId]
			Join tblSMCompanyLocation cl on so.intCompanyLocationId=cl.intCompanyLocationId
			Left Join vyuEMSalesperson sp on so.intEntitySalespersonId=sp.[intEntityId]
			Left Join tblSMShipVia sv on so.intShipViaId=sv.[intEntityId]
			Left Join tblSMFreightTerms ft on so.intFreightTermId=ft.intFreightTermId
			Left Join tblSMTerm tm on so.intTermId=tm.intTermID
			Left Join tblMFRecipeGuide rg on rg.intRecipeGuideId=so.intRecipeGuideId AND rg.intRecipeGuideId=@intRecipeGuideId
			Left Join tblICCommodity cd on rg.intCommodityId=cd.intCommodityId
			Left Join tblEMEntityLocation ef on rg.intFarmId=ef.intEntityLocationId
			Left Join tblEMEntitySplit es on so.intSplitId=es.intSplitId
			Left Join vyuEMCustomerApplicator ca on so.intEntityApplicatorId=ca.intEntityId
			Left Join tblMFMethodOfApp ma on rg.intMethodOfAppId=ma.intMethodOfAppId
			Left Join tblICStorageLocation sl on sl.intStorageLocationId=sd.intStorageLocationId
			WHERE so.intSalesOrderId=@intSalesOrderId AND i.strType<>'Other Charge'
		End

	--Update total weigt for recipe guide print
	If @intRecipeGuideId>0
	Begin
		Declare @intUnitMeasureId int
		Declare @dblNoOfAcre NUMERIC(38,20)
		Declare @dblTotalWeight NUMERIC(38,20)
		Declare @dblTotalDensity NUMERIC(38,20)

		--get recipe guide weigth unit measure
		Select @intUnitMeasureId=intUOMId,@dblNoOfAcre=CASE WHEN ISNULL(dblNoOfAcre,1)=0 THEN 1 ELSE ISNULL(dblNoOfAcre,1) END
		From tblMFRecipeGuide Where intRecipeGuideId=@intRecipeGuideId
		Select @strUOM=strUnitMeasure From tblICUnitMeasure Where intUnitMeasureId=@intUnitMeasureId

		--calculate total weight , convert so detail item uom to recipe guide weight uom
		Select @dblTotalPickQty = SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,iu.intItemUOMId,sd.dblQtyOrdered),0.0)),
			   @dblTotalWeight  = SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,iu.intItemUOMId,sd.dblQtyOrdered),0.0) * ISNULL(t.dblNoOfAcre,0.0)),
			   @dblTotalDensity = SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,iu.intItemUOMId,sd.dblQtyOrdered),0.0) * ISNULL(t.dblNoOfAcre,0.0) * ISNULL(t.dblDensity,0.0))
		From @tblItems t join tblSOSalesOrderDetail sd on t.intSalesOrderDetailId=sd.intSalesOrderDetailId
		Join tblSOSalesOrderDetail sd1 on t.intSalesOrderDetailId=sd1.intSalesOrderDetailId AND sd.intSalesOrderDetailId=sd1.intSalesOrderDetailId
		join tblICItemUOM iu on sd1.intItemId=iu.intItemId AND iu.intUnitMeasureId=@intUnitMeasureId
		Where sd.intSalesOrderId=@intSalesOrderId AND sd1.intSalesOrderId=@intSalesOrderId

		if @dblTotalDensity is null OR @dblTotalDensity=0
			Set @dblTotalDensity=1

		--update total weight, rate(total weight/no of acres), avg density
		Update @tblItems Set dblTotalPickQty=dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) + ' ' + @strUOM,
				strRate=dbo.fnRemoveTrailingZeroes(@dblTotalPickQty / @dblNoOfAcre) + ' ' + @strUOM + '/Acre',
				dblAvgDensity=(Select SUM(ISNULL(CAST(dblPickQuantity AS NUMERIC(38,20)),0.0) * ISNULL(dblDensity,0.0)) From @tblItems) / (Select SUM(ISNULL(CAST(dblPickQuantity AS NUMERIC(38,20)),0.0)) From @tblItems),
				dblCubicFeet = (@dblTotalWeight/(@dblTotalDensity/@dblTotalWeight))
	End

	Select @dblTotalCost=SUM(ISNULL(dblCost,0.0)) From @tblItems

	Update @tblItems Set dblTotalCost=@dblTotalCost

	--Get Comments From SO	
	INSERT INTO @tblItems(strItemNo,strDescription,intSalesOrderDetailId,strItemType)
	Select sd.strItemDescription,'',sd.intSalesOrderDetailId,i.strType
	From tblSOSalesOrderDetail sd Join tblICItem i on sd.intItemId=i.intItemId
	Where sd.intSalesOrderId=@intSalesOrderId AND sd.intCommentTypeId IN (1,2)

	Update ti Set  ti.strPickListNo=t.strPickListNo,ti.strBlendItemNoDesc=t.strBlendItemNoDesc,ti.strWorkOrderNo=t.strWorkOrderNo,ti.intWorkOrderCount=t.intWorkOrderCount,
	ti.dblReqQty=t.dblReqQty,ti.dblTotalPickQty=t.dblTotalPickQty,ti.dblTotalCost=t.dblTotalCost,ti.strCompanyName=t.strCompanyName,ti.strCompanyAddress=t.strCompanyAddress,
	ti.strCompanyCityStateZip=t.strCompanyCityStateZip,ti.strCompanyCountry=t.strCompanyCountry,ti.strCustomerName=t.strCustomerName,ti.strLocationName=t.strLocationName,
	ti.strBOLNumber=t.strBOLNumber,ti.strSalespersonName=t.strSalespersonName,ti.strShipVia=t.strShipVia,ti.strFreightTerm=t.strFreightTerm,ti.strPONumber=t.strPONumber,
	ti.strTerm=t.strTerm,ti.strOrderStatus=t.strOrderStatus,ti.dtmDate=t.dtmDate,ti.dtmDueDate=t.dtmDueDate,ti.strSOComments=t.strSOComments,ti.strShipTo=t.strShipTo,
	ti.strPhone=t.strPhone,ti.strCustomerComments=t.strCustomerComments,ti.ysnShowCostInSalesOrderPickList=t.ysnShowCostInSalesOrderPickList,ti.ysnLotTracking=t.ysnLotTracking,
	ti.strFooterComments=t.strFooterComments
	From @tblItems ti Cross Join (Select TOP 1 * From @tblItems) t
	Where ISNULL(ti.strPickListNo,'')=''

	--Other Charge
	If @ysnShowCostInSalesOrderPickList=1
		Begin
		Select @intMaxOtherChargeId=MAX(intSalesOrderDetailId) + 1 From tblSOSalesOrderDetail

		INSERT INTO @tblItems
		Select ISNULL(@strPickListNo,@strSONo) strPickListNo,  
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
				sd.dblQtyOrdered * sd.dblPrice AS dblCost,
				0.0 AS dblTotalCost
				,@strCompanyName AS strCompanyName
				,@strCompanyAddress AS strCompanyAddress
				,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCompanyCityStateZip
				,@strCountry AS strCompanyCountry 
				,'','','','','','','','','',null,null,'','','','',@ysnShowCostInSalesOrderPickList,0,@intMaxOtherChargeId,'Other Charge',@strFooterComments,0,0.0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null
				From tblSOSalesOrderDetail sd join tblICItem i on sd.intItemId=i.intItemId
				Where intSalesOrderId=@intSalesOrderId AND i.strType='Other Charge'

				--recalculate total cost
				Set @dblTotalCost=@dblTotalCost + (Select SUM(ISNULL(dblCost,0.0)) From @tblItems Where strItemType='Other Charge')

				Update @tblItems Set dblTotalCost=@dblTotalCost
		End

	If Exists (Select 1 From @tblItems Where ISNULL(LTRIM(RTRIM(strLotNumber)),'')<>'')
		Update @tblItems set ysnLotTracking=1

	If @ysnShowCostInSalesOrderPickList=0 
		Update @tblItems set dblTotalCost=null

	--Generate Batches Data if available
	If @intPickListId > 0 AND @intNoOfBatches > 1
	Begin
			--Get Lots/Items from PickList table
			DELETE FROM @tblLot

			INSERT INTO @tblLot (
			intPickListDetailId
			,intLotId
			,intItemId
			,dblQty
			,intItemUOMId
			,intLocationId
			,intSubLocationId
			,intStorageLocationId
			)
		SELECT intPickListDetailId 
		    ,intLotId
			,intItemId
			,dblQuantity
			,intItemUOMId
			,intLocationId
			,intSubLocationId
			,intStorageLocationId
		FROM tblMFPickListDetail
			Where intPickListId=@intPickListId
			ORDER BY dtmCreated

			Delete From @tblInputItem

			--Calculate Items Qty using batch size
			Insert Into @tblInputItem(intItemId,dblRequiredQty)
			Select sd.intItemId,SUM(sd.dblQtyOrdered)/@intNoOfBatches
			From tblSOSalesOrderDetail sd Join tblICItem i on sd.intItemId=i.intItemId 
			Where intSalesOrderId=@intSalesOrderId AND i.strType NOT IN ('Comment','Other Charge') Group By sd.intItemId

		While (@intNoOfBatchesCopy>0) --Loop No Of Batches
		Begin
			
			IF OBJECT_ID('tempdb..#tblTempItems') IS NOT NULL
				DROP TABLE #tblTempItems

			Select * into #tblTempItems from @tblItems Where intBatchId=0
			Delete From #tblTempItems Where cast(dblPickQuantity as numeric(38,20))>0
			Update #tblTempItems Set intBatchId=@intBatchCounter

			Select @intMinItem = MIN(intRowNo) From @tblInputItem

			While @intMinItem is not null --Loop Items
			Begin
				Select @intItemId=intItemId,@dblRequiredQty=dblRequiredQty
				From @tblInputItem Where intRowNo=@intMinItem

				Select @intMinLot=MIN(intRowNo) From @tblLot Where dblQty>0 AND intItemId=@intItemId
				While @intMinLot is not null --Loop Lots
				Begin
					Select @intLotId=intLotId,@dblAvailableQty=dblQty From @tblLot Where intRowNo=@intMinLot

					If @dblAvailableQty >= @dblRequiredQty 
					Begin
						Select @intPickListDetailId=intPickListDetailId From @tblLot Where intRowNo=@intMinLot

						INSERT INTO #tblTempItems
						SELECT pl.strPickListNo ,  
								''  AS strBlendItemNoDesc,  
								pl.strWorkOrderNo,  
								l.strLotNumber,
								l.strLotAlias,
								sl.strName AS strStorageLocationName,
								i.strItemNo COLLATE Latin1_General_CI_AS AS strItemNo,
								--ISNULL(i.strDescription,'') + CHAR(13) + ISNULL(i.strPickListComments,'') COLLATE Latin1_General_CI_AS AS strDescription,
								CASE 
									WHEN ISNULL(sd.strAddonDetailKey, '') <> ''
										AND ISNULL(sd.ysnAddonParent, 0) = 0
										AND @ysnShowAddOnItemQtyInSalesOrderPickList = 1
										THEN ISNULL(i.strDescription, '') + CHAR(13) + ISNULL(i.strPickListComments, '') + (
												SELECT ' ' + CONVERT(NVARCHAR, CONVERT(NUMERIC(38, 2), (ISNULL(Ad.dblQuantity, 0)))) + ' ' + um.strUnitMeasure + '/' + UOM1.strUnitMeasure
												FROM tblSOSalesOrderDetail sd1
												JOIN tblICItemAddOn Ad ON Ad.intItemId = sd1.intItemId
													AND sd1.strAddonDetailKey = sd.strAddonDetailKey
													AND sd1.ysnAddonParent = 1
												JOIN tblICItemUOM IUOM1 ON IUOM1.intItemUOMId = sd1.intItemUOMId
												JOIN tblICUnitMeasure UOM1 ON UOM1.intUnitMeasureId = IUOM1.intUnitMeasureId
												)
									ELSE ISNULL(i.strDescription, '') + CHAR(13) + ISNULL(i.strPickListComments, '')
									END COLLATE Latin1_General_CI_AS AS strDescription,
								dbo.fnRemoveTrailingZeroes(@dblRequiredQty) AS dblPickQuantity,
								um.strUnitMeasure AS strPickUOM,
								l.strGarden,
								@intWorkOrderCount AS intWorkOrderCount,
								'' strParentLotNumber,
								dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) AS dblReqQty,
								dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) + ' ' + @strUOM AS dblTotalPickQty,
								@dblRequiredQty AS dblQuantity,
								CASE WHEN ISNULL(pld.intLotId,0)>0 THEN (dbo.fnICConvertUOMtoStockUnit(pld.intItemId,pld.intItemUOMId,@dblRequiredQty) * ISNULL(l.dblLastCost,0))
								- ((dbo.fnICConvertUOMtoStockUnit(pld.intItemId,pld.intItemUOMId,@dblRequiredQty) * ISNULL(l.dblLastCost,0) * ISNULL(sd.dblDiscount,0.0))/100)
								Else (@dblRequiredQty * ISNULL(sd.dblPrice,0.0)) - ((@dblRequiredQty * ISNULL(sd.dblPrice,0.0) * ISNULL(sd.dblDiscount,0.0))/100) END AS dblCost,
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
								,@strShipTo + (CHAR(13) + c.strPhone) AS strShipTo
								,c.strPhone
								,@strCustomerComments
								,@ysnShowCostInSalesOrderPickList
								,0
								,sd.intSalesOrderDetailId
								,i.strType
								,@strFooterComments
								,@intBatchCounter
								,@dblBatchSize
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
						FROM tblMFPickList pl  
						JOIN tblMFPickListDetail pld ON pl.intPickListId=pld.intPickListId
						JOIN tblICItem i on pld.intItemId=i.intItemId
						Left JOIN tblICLot l on l.intLotId=pld.intLotId
						Left JOIN tblICStorageLocation sl on sl.intStorageLocationId=l.intStorageLocationId
						Join tblICItemUOM iu on pld.intPickUOMId=iu.intItemUOMId
						Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
						Join tblSOSalesOrder so on pl.intSalesOrderId=so.intSalesOrderId
						Join vyuARCustomer c on so.intEntityCustomerId=c.[intEntityId]
						Join tblSMCompanyLocation cl on so.intCompanyLocationId=cl.intCompanyLocationId
						Left Join vyuEMSalesperson sp on so.intEntitySalespersonId=sp.[intEntityId]
						Left Join tblSMShipVia sv on so.intShipViaId=sv.[intEntityId]
						Left Join tblSMFreightTerms ft on so.intFreightTermId=ft.intFreightTermId
						Left Join tblSMTerm tm on so.intTermId=tm.intTermID
						Join tblSOSalesOrderDetail sd on sd.intSalesOrderId=so.intSalesOrderId AND sd.intItemId=pld.intItemId
						WHERE pl.intPickListId=@intPickListId AND pld.intPickListDetailId=@intPickListDetailId

						Update @tblLot Set dblQty=@dblAvailableQty - @dblRequiredQty Where intRowNo=@intMinLot

						GOTO NEXT_ITEM
					End
					Else
					Begin
						Select @intPickListDetailId=intPickListDetailId From @tblLot Where intRowNo=@intMinLot

						INSERT INTO #tblTempItems
						SELECT pl.strPickListNo ,  
								''  AS strBlendItemNoDesc,  
								pl.strWorkOrderNo,  
								l.strLotNumber,
								l.strLotAlias,
								sl.strName AS strStorageLocationName,
								i.strItemNo COLLATE Latin1_General_CI_AS AS strItemNo,
								--ISNULL(i.strDescription,'') + CHAR(13) + ISNULL(i.strPickListComments,'') COLLATE Latin1_General_CI_AS AS strDescription,
								CASE 
									WHEN ISNULL(sd.strAddonDetailKey, '') <> ''
										AND ISNULL(sd.ysnAddonParent, 0) = 0
										AND @ysnShowAddOnItemQtyInSalesOrderPickList = 1
										THEN ISNULL(i.strDescription, '') + CHAR(13) + ISNULL(i.strPickListComments, '') + (
												SELECT ' ' + CONVERT(NVARCHAR, CONVERT(NUMERIC(38, 2), (ISNULL(Ad.dblQuantity, 0)))) + ' ' + um.strUnitMeasure + '/' + UOM1.strUnitMeasure
												FROM tblSOSalesOrderDetail sd1
												JOIN tblICItemAddOn Ad ON Ad.intItemId = sd1.intItemId
													AND sd1.strAddonDetailKey = sd.strAddonDetailKey
													AND sd1.ysnAddonParent = 1
												JOIN tblICItemUOM IUOM1 ON IUOM1.intItemUOMId = sd1.intItemUOMId
												JOIN tblICUnitMeasure UOM1 ON UOM1.intUnitMeasureId = IUOM1.intUnitMeasureId
												)
									ELSE ISNULL(i.strDescription, '') + CHAR(13) + ISNULL(i.strPickListComments, '')
									END COLLATE Latin1_General_CI_AS AS strDescription,
								dbo.fnRemoveTrailingZeroes(@dblAvailableQty) AS dblPickQuantity,
								um.strUnitMeasure AS strPickUOM,
								l.strGarden,
								@intWorkOrderCount AS intWorkOrderCount,
								'' strParentLotNumber,
								dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) AS dblReqQty,
								dbo.fnRemoveTrailingZeroes(@dblTotalPickQty) + ' ' + @strUOM AS dblTotalPickQty,
								@dblAvailableQty AS dblQuantity,
								CASE WHEN ISNULL(pld.intLotId,0)>0 THEN (dbo.fnICConvertUOMtoStockUnit(pld.intItemId,pld.intItemUOMId,@dblAvailableQty) * ISNULL(l.dblLastCost,0))
								- ((dbo.fnICConvertUOMtoStockUnit(pld.intItemId,pld.intItemUOMId,@dblAvailableQty) * ISNULL(l.dblLastCost,0) * ISNULL(sd.dblDiscount,0.0))/100)
								Else (@dblAvailableQty * ISNULL(sd.dblPrice,0.0)) - ((@dblAvailableQty * ISNULL(sd.dblPrice,0.0) * ISNULL(sd.dblDiscount,0.0))/100) END AS dblCost,
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
								,@strShipTo + (CHAR(13) + c.strPhone) AS strShipTo
								,c.strPhone
								,@strCustomerComments
								,@ysnShowCostInSalesOrderPickList
								,0
								,sd.intSalesOrderDetailId
								,i.strType
								,@strFooterComments
								,@intBatchCounter
								,@dblBatchSize
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
								,null
						FROM tblMFPickList pl  
						JOIN tblMFPickListDetail pld ON pl.intPickListId=pld.intPickListId
						JOIN tblICItem i on pld.intItemId=i.intItemId
						Left JOIN tblICLot l on l.intLotId=pld.intLotId
						Left JOIN tblICStorageLocation sl on sl.intStorageLocationId=l.intStorageLocationId
						Join tblICItemUOM iu on pld.intPickUOMId=iu.intItemUOMId
						Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
						Join tblSOSalesOrder so on pl.intSalesOrderId=so.intSalesOrderId
						Join vyuARCustomer c on so.intEntityCustomerId=c.[intEntityId]
						Join tblSMCompanyLocation cl on so.intCompanyLocationId=cl.intCompanyLocationId
						Left Join vyuEMSalesperson sp on so.intEntitySalespersonId=sp.[intEntityId]
						Left Join tblSMShipVia sv on so.intShipViaId=sv.[intEntityId]
						Left Join tblSMFreightTerms ft on so.intFreightTermId=ft.intFreightTermId
						Left Join tblSMTerm tm on so.intTermId=tm.intTermID
						Join tblSOSalesOrderDetail sd on sd.intSalesOrderId=so.intSalesOrderId AND sd.intItemId=pld.intItemId
						WHERE pl.intPickListId=@intPickListId AND pld.intPickListDetailId=@intPickListDetailId

						Set @dblRequiredQty = @dblRequiredQty - @dblAvailableQty

						Update @tblLot Set dblQty=0 Where intRowNo=@intMinLot
					End

					Select @intMinLot = MIN(intRowNo) From @tblLot Where intRowNo>@intMinLot AND dblQty>0 AND intItemId=@intItemId
				End

				NEXT_ITEM:
				Select @intMinItem = MIN(intRowNo) From @tblInputItem Where intRowNo>@intMinItem

			End
			Set @intNoOfBatchesCopy=@intNoOfBatchesCopy-1
			Set @intBatchCounter=@intBatchCounter+1

			Update #tblTempItems Set dblTotalCost=dblTotalCost/@intNoOfBatches
			Update @tblItems Set dblBatchSize=@dblBatchSize

			Insert Into @tblItems
			Select * from #tblTempItems
		End
	End

	Select *,@ysnShowRunningWeight AS ysnShowRunningWeight from @tblItems Order By intBatchId,intSalesOrderDetailId
End