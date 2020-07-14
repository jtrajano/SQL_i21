CREATE Procedure [dbo].[uspMFBlendSheetReport] 
@xmlParam NVARCHAR(MAX) = NULL
AS
	DECLARE @intWorkOrderId			INT,
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
    
	SELECT	@intWorkOrderId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intWorkOrderId'

	DECLARE @strCompanyName NVARCHAR(100)
		,@strCompanyAddress NVARCHAR(100)
		,@strCity NVARCHAR(25)
		,@strState NVARCHAR(50)
		,@strZip NVARCHAR(12)
		,@strCountry NVARCHAR(25)
		,@intPickListId INT

	SELECT TOP 1 @strCompanyName = strCompanyName
		,@strCompanyAddress = strAddress
		,@strCity = strCity
		,@strState = strState
		,@strZip = strZip
		,@strCountry = strCountry
	FROM dbo.tblSMCompanySetup

	DECLARE @tblBlendSheet TABLE 
	(  
		intWorkOrderId int,
		strWorkOrderNo nvarchar(50),
		strBlendItemNoDesc nvarchar(500),
		dblBlendReqQuantity numeric(18,6),
		dblBlendActualQuantity numeric(18,6),
		strBlendUOM nvarchar(50),
		strBlendLotNumber nvarchar(50),
		strBlendLotAlias nvarchar(50),
		strShift nvarchar(50),
		dtmCreatedDate datetime,
		dtmCreatedTime datetime,
		strBlender nvarchar(50),
		strVesselNo nvarchar(50),
		strLotNumber nvarchar(50),
		strLotAlias  nvarchar(50),
		strRawItemNo nvarchar(50),
		strRawItemDesc nvarchar(200),
		dblQuantity numeric(18,6),
		strUOM nvarchar(50),
		dblIssuedQuantity numeric(18,6),
		strIssuedUOM nvarchar(50),
		strVendor nvarchar(50),
		dblBSPercentage numeric(18,6),
		dblCost numeric(38,20),
		strStorageLocation nvarchar(50),
		intSequenceNo int default 1,
		strReferenceNo NVARCHAR(100),
		strERPOrderNo NVARCHAR(100),
		dtmCompletedDate DATETIME
	)  

	Declare @dblProduceQty NUMERIC(38,20)
	Declare @dblOtherCharges NUMERIC(38,20)
	Declare @intLocationId int
	Declare @dblCost NUMERIC(38,20)
	Declare @dblTotalCost NUMERIC(38,20)

	Select @intPickListId=intPickListId,@dblProduceQty=dblQuantity,@intLocationId=intLocationId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId

	If Exists (Select 1 From tblMFWorkOrderConsumedLot Where intWorkOrderId=@intWorkOrderId)
	Begin
		Insert Into @tblBlendSheet(intWorkOrderId,strLotNumber,strLotAlias,strRawItemNo,strRawItemDesc,
		dblQuantity,strUOM,dblIssuedQuantity,strIssuedUOM,strVendor,dblBSPercentage,dblCost,strStorageLocation,intSequenceNo)
		Select @intWorkOrderId,l.strLotNumber,l.strLotAlias,i.strItemNo,i.strDescription ,
		wcl.dblQuantity,um.strUnitMeasure,wcl.dblIssuedQuantity,um1.strUnitMeasure,v.strName,
		ROUND(100 * (wcl.dblQuantity / SUM(wcl.dblQuantity) OVER()),2) AS dblBSPercentage,
		dbo.fnICConvertUOMtoStockUnit(wcl.intItemId,wcl.intItemUOMId,wcl.dblQuantity) * ISNULL(l.dblLastCost,0),sl.strName,0
		From tblMFWorkOrderConsumedLot wcl Join tblICLot l on wcl.intLotId=l.intLotId 
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICItemUOM iu on wcl.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICItemUOM iu1 on wcl.intItemIssuedUOMId=iu1.intItemUOMId
		Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
		Left Join vyuAPVendor v on l.intEntityVendorId=v.intEntityId
		Join tblICStorageLocation sl on l.intStorageLocationId=sl.intStorageLocationId
		Where wcl.intWorkOrderId=@intWorkOrderId
		UNION --Non Lot Tracked Items
		Select @intWorkOrderId,'' strLotNumber,'' strLotAlias,i.strItemNo,i.strDescription ,
		wcl.dblQuantity,um.strUnitMeasure,wcl.dblQuantity,um.strUnitMeasure,'',
		ROUND(100 * (wcl.dblQuantity / SUM(wcl.dblQuantity) OVER()),2) AS dblBSPercentage,
		dbo.fnICConvertUOMtoStockUnit(wcl.intItemId,wcl.intItemUOMId,wcl.dblQuantity) * 
		ISNULL((Select TOP 1 ISNULL(ip.dblCost,0) From vyuMFGetItemByLocation ip 
		Where ip.intLocationId=@intLocationId AND ip.intItemId=wcl.intItemId),0),sl.strName,0
		From tblMFWorkOrderConsumedLot wcl 
		Join tblICItem i on wcl.intItemId=i.intItemId
		Join tblICItemUOM iu on wcl.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Left Join tblICStorageLocation sl on wcl.intStorageLocationId=sl.intStorageLocationId
		Where wcl.intWorkOrderId=@intWorkOrderId AND ISNULL(wcl.intLotId,0)=0
		UNION --Other Charge Items
		SELECT @intWorkOrderId,'' AS strLotNumber,'' AS strLotAlias,I.strItemNo,I.strDescription ,
		NULL dblQuantity,'' strUnitMeasure,NULL dblQuantity,'' strUnitMeasure,'',
		0 AS dblBSPercentage,
		(
			CASE 
				WHEN intMarginById = 1
					THEN ISNULL(ip.dblCost,0) + (ISNULL(ip.dblCost,0) * ISNULL(RI.dblMargin,0) / 100)
				ELSE ISNULL(ip.dblCost,0) + ISNULL(RI.dblMargin,0)
				END
			) / R.dblQuantity * @dblProduceQty
		,'' strName,1
		FROM dbo.tblMFWorkOrderRecipeItem RI
		JOIN dbo.tblMFWorkOrderRecipe R ON R.intWorkOrderId = RI.intWorkOrderId
			AND R.intRecipeId = RI.intRecipeId
		JOIN dbo.tblICItem I ON I.intItemId = RI.intItemId
			AND RI.intRecipeItemTypeId = 1
			AND RI.ysnCostAppliedAtInvoice = 0
			AND I.strType = 'Other Charge'
		JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
			AND IL.intLocationId = @intLocationId
		Left Join vyuMFGetItemByLocation ip on ip.intItemId=RI.intItemId AND ip.intLocationId=@intLocationId
		WHERE RI.intWorkOrderId = @intWorkOrderId
		GOTO FINAL
	End

	If Exists (Select 1 From tblMFPickList Where intPickListId=@intPickListId)
	Begin
		Insert Into @tblBlendSheet(intWorkOrderId,strLotNumber,strLotAlias,strRawItemNo,strRawItemDesc,
		dblQuantity,strUOM,dblIssuedQuantity,strIssuedUOM,strVendor,dblBSPercentage,dblCost,strStorageLocation,intSequenceNo)
		Select @intWorkOrderId,l.strLotNumber,l.strLotAlias,i.strItemNo,i.strDescription ,
		wcl.dblQuantity,um.strUnitMeasure,wcl.dblIssuedQuantity,um1.strUnitMeasure,'',
		ROUND(100 * (wcl.dblQuantity / SUM(wcl.dblQuantity) OVER()),2) AS dblBSPercentage,
		dbo.fnICConvertUOMtoStockUnit(wcl.intItemId,wcl.intItemUOMId,wcl.dblQuantity) * ISNULL(l.dblLastCost,0),sl.strName,0
		From tblMFPickListDetail wcl Join tblICLot l on wcl.intStageLotId=l.intLotId 
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICItemUOM iu on wcl.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICItemUOM iu1 on wcl.intItemIssuedUOMId=iu1.intItemUOMId
		Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
		Join tblICStorageLocation sl on l.intStorageLocationId=sl.intStorageLocationId
		Where wcl.intPickListId=@intPickListId
		UNION --Non Lot Tracked Items
		Select @intWorkOrderId,'' AS strLotNumber,'' AS strLotAlias,i.strItemNo,i.strDescription ,
		wcl.dblQuantity,um.strUnitMeasure,wcl.dblQuantity,um.strUnitMeasure,'',
		ROUND(100 * (wcl.dblQuantity / SUM(wcl.dblQuantity) OVER()),2) AS dblBSPercentage,
		dbo.fnICConvertUOMtoStockUnit(wcl.intItemId,wcl.intItemUOMId,wcl.dblQuantity) * 
		ISNULL((Select TOP 1 ISNULL(ip.dblCost,0) From vyuMFGetItemByLocation ip 
		Where ip.intLocationId=@intLocationId AND ip.intItemId=wcl.intItemId),0),sl.strName,0
		From tblMFPickListDetail wcl
		Join tblICItem i on wcl.intItemId=i.intItemId
		Join tblICItemUOM iu on wcl.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Left Join tblICStorageLocation sl on wcl.intStorageLocationId=sl.intStorageLocationId
		Where wcl.intPickListId=@intPickListId AND ISNULL(wcl.intLotId,0)=0
		UNION --Other Charge Items
		SELECT @intWorkOrderId,'' AS strLotNumber,'' AS strLotAlias,I.strItemNo,I.strDescription ,
		NULL dblQuantity,'' strUnitMeasure,NULL dblQuantity,'' strUnitMeasure,'',
		0 AS dblBSPercentage,
		(
			CASE 
				WHEN intMarginById = 1
					THEN ISNULL(ip.dblCost,0) + (ISNULL(ip.dblCost,0) * ISNULL(RI.dblMargin,0) / 100)
				ELSE ISNULL(ip.dblCost,0) + ISNULL(RI.dblMargin,0)
				END
			) / R.dblQuantity * @dblProduceQty
		,'' strName,1
		FROM dbo.tblMFWorkOrderRecipeItem RI
		JOIN dbo.tblMFWorkOrderRecipe R ON R.intWorkOrderId = RI.intWorkOrderId
			AND R.intRecipeId = RI.intRecipeId
		JOIN dbo.tblICItem I ON I.intItemId = RI.intItemId
			AND RI.intRecipeItemTypeId = 1
			AND RI.ysnCostAppliedAtInvoice = 0
			AND I.strType = 'Other Charge'
		JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
			AND IL.intLocationId = @intLocationId
		Left Join vyuMFGetItemByLocation ip on ip.intItemId=RI.intItemId AND ip.intLocationId=@intLocationId
		WHERE RI.intWorkOrderId = @intWorkOrderId

		GOTO FINAL
	End

	If Exists (Select 1 From tblMFWorkOrderInputLot Where intWorkOrderId=@intWorkOrderId)
	Begin
		Insert Into @tblBlendSheet(intWorkOrderId,strLotNumber,strLotAlias,strRawItemNo,strRawItemDesc,
		dblQuantity,strUOM,dblIssuedQuantity,strIssuedUOM,strVendor,dblBSPercentage,dblCost,strStorageLocation)
		Select @intWorkOrderId,l.strLotNumber,l.strLotAlias,i.strItemNo,i.strDescription ,
		wcl.dblQuantity,um.strUnitMeasure,wcl.dblIssuedQuantity,um1.strUnitMeasure,l.strMarkings,
		ROUND(100 * (wcl.dblQuantity / SUM(wcl.dblQuantity) OVER()),2) AS dblBSPercentage,
		dbo.fnICConvertUOMtoStockUnit(wcl.intItemId,wcl.intItemUOMId,wcl.dblQuantity) * ISNULL(l.dblLastCost,0),sl.strName
		From tblMFWorkOrderInputLot wcl Join tblICLot l on wcl.intLotId=l.intLotId 
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICItemUOM iu on wcl.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICItemUOM iu1 on wcl.intItemIssuedUOMId=iu1.intItemUOMId
		Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
		Join tblICStorageLocation sl on l.intStorageLocationId=sl.intStorageLocationId
		Where wcl.intWorkOrderId=@intWorkOrderId

		GOTO FINAL
	End

	If Exists (Select 1 From tblMFWorkOrderInputParentLot Where intWorkOrderId=@intWorkOrderId)
	Begin
		Insert Into @tblBlendSheet(intWorkOrderId,strLotNumber,strLotAlias,strRawItemNo,strRawItemDesc,
		dblQuantity,strUOM,dblIssuedQuantity,strIssuedUOM,strVendor,dblBSPercentage,strStorageLocation)
		Select @intWorkOrderId,PL.strParentLotNumber,'' as strLotAlias,i.strItemNo,i.strDescription ,
		wcl.dblQuantity,um.strUnitMeasure,wcl.dblIssuedQuantity,um1.strUnitMeasure,'' as strMarkings,
		ROUND(100 * (wcl.dblQuantity / SUM(wcl.dblQuantity) OVER()),2) AS dblBSPercentage,sl.strName
		From tblMFWorkOrderInputParentLot wcl 
		--Join tblICLot l on wcl.intParentLotId=l.intParentLotId 
		JOIN tblICParentLot PL on PL.intParentLotId=wcl.intParentLotId
		Join tblICItem i on wcl.intItemId=i.intItemId
		Join tblICItemUOM iu on wcl.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICItemUOM iu1 on wcl.intItemIssuedUOMId=iu1.intItemUOMId
		Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
		Left Join tblICStorageLocation sl on wcl.intStorageLocationId=sl.intStorageLocationId
		Where wcl.intWorkOrderId=@intWorkOrderId

		GOTO FINAL
	End

	FINAL:

	Update bs Set bs.strWorkOrderNo=w.strWorkOrderNo,bs.strBlendItemNoDesc=i.strItemNo + ' - ' + i.strDescription,
	bs.dblBlendReqQuantity=w.dblQuantity,bs.dblBlendActualQuantity=wpl.dblQuantity,
	bs.strBlendUOM=um.strUnitMeasure,bs.strBlendLotNumber=l.strLotNumber,bs.strBlendLotAlias=l.strLotAlias,
	bs.strShift=s.strShiftName,bs.dtmCreatedDate=w.dtmCreated,bs.dtmCreatedTime=Convert(char,l.dtmDateCreated,108),
	bs.strBlender=us.strUserName,bs.strVesselNo=sl.strName,bs.strReferenceNo=ISNULL(w.strReferenceNo,''),bs.strERPOrderNo=ISNULL(w.strERPOrderNo,''),
	bs.dtmCompletedDate=w.dtmCompletedDate
	From @tblBlendSheet bs Join tblMFWorkOrder w on bs.intWorkOrderId=w.intWorkOrderId 
	join tblICItem i on w.intItemId=i.intItemId
	Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Left Join tblMFWorkOrderProducedLot wpl on w.intWorkOrderId=wpl.intWorkOrderId
	Left Join tblICLot l on wpl.intLotId=l.intLotId
	Left Join tblMFShift s on wpl.intBusinessShiftId=s.intShiftId
	Left Join tblSMUserSecurity us on w.intCreatedUserId=us.[intEntityId]
	Left Join tblICStorageLocation sl on l.intStorageLocationId=sl.intStorageLocationId

	Select @dblTotalCost=ISNULL(SUM(ISNULL(dblCost,0)),0) From @tblBlendSheet

	--Quality Proerty read from tblQMReportProperty if available
	Declare @strQuality NVARCHAR(MAX)=''

	If (
	select COUNT(1) from tblQMReportProperty rp Join tblQMProperty p on rp.intPropertyId=p.intPropertyId 
	Where strReportName='Blend Sheet Report'
	) > 0 
	Begin
		select @strQuality=@strQuality + p.strPropertyName + ':--------------------------' from tblQMReportProperty rp Join tblQMProperty p on rp.intPropertyId=p.intPropertyId 
		Where strReportName='Blend Sheet Report' Order By intSequenceNo

		Set @strQuality= @strQuality + 'Approved By:--------------------------'

		Set  @strQuality= 'To be filled in by Lab=======================================================================================' + char(10) + char(10)
		+ @strQuality + char(10) + char(10) + '========================================================================================================'
	End

	Select  intWorkOrderId,
			strWorkOrderNo,
			strBlendItemNoDesc,
			dblBlendReqQuantity,
			dblBlendActualQuantity,
			strBlendUOM,
			dbo.fnRemoveTrailingZeroes(dblBlendReqQuantity) + ' ' + strBlendUOM AS strBlendReqQuantityUOM,
			dbo.fnRemoveTrailingZeroes(dblBlendActualQuantity) + ' ' + strBlendUOM AS strBlendActualQuantityUOM,
			strBlendLotNumber,
			strBlendLotAlias,
			strShift,
			dtmCreatedDate,
			dtmCreatedTime,
			strBlender,
			strVesselNo,
			strLotNumber,
			strLotAlias,
			strRawItemNo,
			strRawItemDesc,
			strRawItemNo + ' - ' + strRawItemDesc AS strRawItemNoDesc,
			dblQuantity,
			strUOM,
			dbo.fnRemoveTrailingZeroes(dblQuantity) + ' ' + strUOM AS strQuantityUOM,
			dblIssuedQuantity,
			strIssuedUOM,
			dbo.fnRemoveTrailingZeroes(dblIssuedQuantity) + ' ' + strIssuedUOM + '    ' + dbo.fnRemoveTrailingZeroes(dblQuantity) + ' ' + strUOM AS strIssuedQuantityUOM,
			strVendor,
			dblBSPercentage,
			dbo.fnRemoveTrailingZeroes(dblBSPercentage) + '%' AS strBSPercentage,
			dblCost
			,strStorageLocation
			,@strCompanyName AS strCompanyName
			,@strCompanyAddress AS strCompanyAddress
			,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCompanyCityStateZip
			,@strCountry AS strCompanyCountry
			,ISNULL(@dblTotalCost,0) AS dblTotalCost
			,strReferenceNo
			,strERPOrderNo
			,dtmCompletedDate
			,@strQuality AS strQuality
			From @tblBlendSheet
			Order By intSequenceNo