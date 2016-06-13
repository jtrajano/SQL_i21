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
		strStorageLocation nvarchar(50)
	)  

	Select @intPickListId=intPickListId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId

	If Exists (Select 1 From tblMFWorkOrderConsumedLot Where intWorkOrderId=@intWorkOrderId)
	Begin
		Insert Into @tblBlendSheet(intWorkOrderId,strLotNumber,strLotAlias,strRawItemNo,strRawItemDesc,
		dblQuantity,strUOM,dblIssuedQuantity,strIssuedUOM,strVendor,dblBSPercentage,dblCost,strStorageLocation)
		Select @intWorkOrderId,l.strLotNumber,l.strLotAlias,i.strItemNo,i.strDescription ,
		wcl.dblQuantity,um.strUnitMeasure,wcl.dblIssuedQuantity,um1.strUnitMeasure,v.strName,
		ROUND(100 * (wcl.dblQuantity / SUM(wcl.dblQuantity) OVER()),2) AS dblBSPercentage,
		wcl.dblQuantity * ISNULL(l.dblLastCost,0),sl.strName
		From tblMFWorkOrderConsumedLot wcl Join tblICLot l on wcl.intLotId=l.intLotId 
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICItemUOM iu on wcl.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICItemUOM iu1 on wcl.intItemIssuedUOMId=iu1.intItemUOMId
		Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
		Left Join vyuAPVendor v on l.intEntityVendorId=v.intEntityId
		Join tblICStorageLocation sl on l.intStorageLocationId=sl.intStorageLocationId
		Where wcl.intWorkOrderId=@intWorkOrderId

		GOTO FINAL
	End

	If Exists (Select 1 From tblMFPickList Where intPickListId=@intPickListId)
	Begin
		Insert Into @tblBlendSheet(intWorkOrderId,strLotNumber,strLotAlias,strRawItemNo,strRawItemDesc,
		dblQuantity,strUOM,dblIssuedQuantity,strIssuedUOM,strVendor,dblBSPercentage,dblCost,strStorageLocation)
		Select @intWorkOrderId,l.strLotNumber,l.strLotAlias,i.strItemNo,i.strDescription ,
		wcl.dblQuantity,um.strUnitMeasure,wcl.dblIssuedQuantity,um1.strUnitMeasure,'',
		ROUND(100 * (wcl.dblQuantity / SUM(wcl.dblQuantity) OVER()),2) AS dblBSPercentage,
		wcl.dblQuantity * ISNULL(l.dblLastCost,0),sl.strName
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
		wcl.dblQuantity * ISNULL((Select TOP 1 ip.dblStandardCost 
		From tblICItemPricing ip Join tblICItemLocation il on ip.intItemLocationId=il.intItemLocationId 
		AND ip.intItemId=wcl.intItemId AND il.intLocationId=wcl.intLocationId),0),sl.strName
		From tblMFPickListDetail wcl
		Join tblICItem i on wcl.intItemId=i.intItemId
		Join tblICItemUOM iu on wcl.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Left Join tblICStorageLocation sl on wcl.intStorageLocationId=sl.intStorageLocationId
		Where wcl.intPickListId=@intPickListId

		GOTO FINAL
	End

	If Exists (Select 1 From tblMFWorkOrderInputLot Where intWorkOrderId=@intWorkOrderId)
	Begin
		Insert Into @tblBlendSheet(intWorkOrderId,strLotNumber,strLotAlias,strRawItemNo,strRawItemDesc,
		dblQuantity,strUOM,dblIssuedQuantity,strIssuedUOM,strVendor,dblBSPercentage,dblCost,strStorageLocation)
		Select @intWorkOrderId,l.strLotNumber,l.strLotAlias,i.strItemNo,i.strDescription ,
		wcl.dblQuantity,um.strUnitMeasure,wcl.dblIssuedQuantity,um1.strUnitMeasure,l.strMarkings,
		ROUND(100 * (wcl.dblQuantity / SUM(wcl.dblQuantity) OVER()),2) AS dblBSPercentage,
		wcl.dblQuantity * ISNULL(l.dblLastCost,0),sl.strName
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
		dblQuantity,strUOM,dblIssuedQuantity,strIssuedUOM,strVendor,dblBSPercentage)
		Select @intWorkOrderId,l.strLotNumber,l.strLotAlias,i.strItemNo,i.strDescription ,
		wcl.dblQuantity,um.strUnitMeasure,wcl.dblIssuedQuantity,um1.strUnitMeasure,l.strMarkings,
		ROUND(100 * (wcl.dblQuantity / SUM(wcl.dblQuantity) OVER()),2) AS dblBSPercentage
		From tblMFWorkOrderInputParentLot wcl Join tblICLot l on wcl.intParentLotId=l.intParentLotId 
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICItemUOM iu on wcl.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICItemUOM iu1 on wcl.intItemIssuedUOMId=iu1.intItemUOMId
		Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
		Where wcl.intWorkOrderId=@intWorkOrderId

		GOTO FINAL
	End

	FINAL:

	Update bs Set bs.strWorkOrderNo=w.strWorkOrderNo,bs.strBlendItemNoDesc=i.strItemNo + ' - ' + i.strDescription,
	bs.dblBlendReqQuantity=w.dblQuantity,bs.dblBlendActualQuantity=wpl.dblQuantity,
	bs.strBlendUOM=um.strUnitMeasure,bs.strBlendLotNumber=l.strLotNumber,bs.strBlendLotAlias=l.strLotAlias,
	bs.strShift=s.strShiftName,bs.dtmCreatedDate=w.dtmCreated,bs.dtmCreatedTime=Convert(char,l.dtmDateCreated,108),
	bs.strBlender=us.strUserName,bs.strVesselNo=wpl.strVesselNo
	From @tblBlendSheet bs Join tblMFWorkOrder w on bs.intWorkOrderId=w.intWorkOrderId 
	join tblICItem i on w.intItemId=i.intItemId
	Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Left Join tblMFWorkOrderProducedLot wpl on w.intWorkOrderId=wpl.intWorkOrderId
	Left Join tblICLot l on wpl.intLotId=l.intLotId
	Left Join tblMFShift s on wpl.intShiftId=s.intShiftId
	Left Join tblSMUserSecurity us on w.intCreatedUserId=us.intEntityUserSecurityId

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
			From @tblBlendSheet
