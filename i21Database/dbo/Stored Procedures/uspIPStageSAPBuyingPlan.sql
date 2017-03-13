CREATE PROCEDURE [dbo].[uspIPStageSAPBuyingPlan]
	@strXml nvarchar(max)
AS

BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
		
	DECLARE @idoc INT
	DECLARE @ErrMsg nvarchar(max)
	DECLARE @strSessionId nvarchar(50)=NEWID()
	DECLARE @intLocationId INT
	DECLARE @strNamespace NVARCHAR(50)

	Select @intLocationId=dbo.[fnIPGetSAPIDOCTagValue]('STOCK','LOCATION_ID')
	Select @strNamespace=dbo.[fnIPGetSAPIDOCTagValue]('BUYING PLAN','NAMESPACE')

	Set @strXml= REPLACE(@strXml,'utf-8' COLLATE Latin1_General_CI_AS,'utf-16' COLLATE Latin1_General_CI_AS) 
	Set @strXml= REPLACE(@strXml,@strNamespace COLLATE Latin1_General_CI_AS,'' COLLATE Latin1_General_CI_AS)

	EXEC sp_xml_preparedocument @idoc OUTPUT
	,@strXml

	DECLARE @tblBuyingPlan TABLE (
	[strItemNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strSubLocation] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strCalendarWeek] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[dblPlannedDemand] NUMERIC(38,20),
	[dblTotalDemand] NUMERIC(38,20),
	[strUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	)

	INSERT INTO @tblBuyingPlan (
		 strItemNo
		,strSubLocation
		,strCalendarWeek
		,dblPlannedDemand
		,dblTotalDemand
		,strUOM
		)
	SELECT RIGHT(materialNumber,8)
		,plantOrLocation
		,calenderWeek
		,plannedDemand
		,totalDemand
		,unit
	FROM OPENXML(@idoc, 'MT_INB_BuyingPlan/record', 2) WITH (
			 materialNumber NVARCHAR(100) 
			,plantOrLocation NVARCHAR(100) 
			,calenderWeek NVARCHAR(50) 
			,plannedDemand NUMERIC(38,20)
			,totalDemand NUMERIC(38,20)
			,unit NVARCHAR(50)
			)

	--Move to Arch table (Previous Data)
	Insert Into tblRKArchBlendDemand(intConcurrencyId,intItemId,strItemName,intSubLocationId,strSubLocation,dblQuantity,dblTotalDemand,intUOMId,strUOM,intYear,intWeek,strPeriod,dtmNeedDate,dtmImportDate)
	Select intConcurrencyId,intItemId,strItemName,intSubLocationId,strSubLocation,dblQuantity,dblTotalDemand,intUOMId,strUOM,intYear,intWeek,strPeriod,dtmNeedDate,dtmImportDate
	From tblRKStgBlendDemand

	--Delete From Stg table (Previous Data)
	Delete From tblRKStgBlendDemand

	--Add to Staging tables
	Insert into tblRKStgBlendDemand(strItemName,strSubLocation,intYear,intWeek,dblQuantity,dblTotalDemand,strUOM,dtmNeedDate,strPeriod,intConcurrencyId)
	Select bp.strItemNo,bp.strSubLocation,LEFT(bp.strCalendarWeek,4),RIGHT(bp.strCalendarWeek,2),bp.dblPlannedDemand,bp.dblTotalDemand,bp.strUOM,
	dbo.fnGetFirstDateOfWeek(RIGHT(bp.strCalendarWeek,2),LEFT(bp.strCalendarWeek,4)),
	LEFT(DATENAME(MONTH,dbo.[fnGetFirstDateOfWeek](RIGHT(bp.strCalendarWeek,2),LEFT(bp.strCalendarWeek,4))),3)+ ' ' 
	+ RIGHT(Year(dbo.[fnGetFirstDateOfWeek](RIGHT(bp.strCalendarWeek,2),LEFT(bp.strCalendarWeek,4))),2),0
	From @tblBuyingPlan bp

	--Update the ids
	Update bp Set bp.intItemId=i.intItemId,bp.intSubLocationId=sl.intCompanyLocationSubLocationId,bp.intUOMId=iu.intItemUOMId 
	From tblRKStgBlendDemand bp Join tblICItem i on bp.strItemName=i.strItemNo
	Join tblSMCompanyLocationSubLocation sl on bp.strSubLocation=sl.strSubLocationName
	Join tblICItemUOM iu on i.intItemId=iu.intItemId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId AND um.strSymbol=bp.strUOM
	Where sl.intCompanyLocationId=@intLocationId
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH