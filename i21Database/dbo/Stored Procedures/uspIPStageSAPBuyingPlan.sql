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

	Set @strXml= REPLACE(@strXml,'utf-8' COLLATE Latin1_General_CI_AS,'utf-16' COLLATE Latin1_General_CI_AS)  

	Select @intLocationId=dbo.[fnIPGetSAPIDOCTagValue]('STOCK','LOCATION_ID')

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
	SELECT materialNumber
		,plantOrLocation
		,calenderWeek
		,plannedDemand
		,totalDemand
		,dbo.fnIPConvertSAPUOMToi21(unit)
	FROM OPENXML(@idoc, 'MT_INB_BuyingPlan/record', 2) WITH (
			 materialNumber NVARCHAR(100) 
			,plantOrLocation NVARCHAR(100) 
			,calenderWeek NVARCHAR(50) 
			,plannedDemand NUMERIC(38,20)
			,totalDemand NUMERIC(38,20)
			,unit NVARCHAR(50)
			)

	--Add to Staging tables
	Insert into tblRKStgBlendDemand(strItemName,strSubLocation,intYear,intWeek,dblQuantity,dblTotalDemand,strUOM,intItemId,intSubLocationId,intUOMId,strPeriod,intConcurrencyId)
	Select bp.strItemNo,bp.strSubLocation,LEFT(bp.strCalendarWeek,4),RIGHT(bp.strCalendarWeek,2),bp.dblPlannedDemand,bp.dblTotalDemand,bp.strUOM,
	i.intItemId,sl.intCompanyLocationSubLocationId,iu.intItemUOMId,
	(CONVERT(CHAR(3), DATENAME(MONTH,
	(CAST('1900' + RIGHT('00' + CONVERT(VARCHAR, DATEPART(MM,CAST(CONVERT(CHAR(3),
                 DATEADD(WW,RIGHT(bp.strCalendarWeek,2) - 1,
                 CONVERT(datetime,'01/01/'+CONVERT(char(4),LEFT(bp.strCalendarWeek,4))))
                 ,100)+ ' 1900' AS DATETIME))),2) + '01' AS datetime)))) + ' ' + SUBSTRING(LEFT(bp.strCalendarWeek,4),3,2))
	,0
	From @tblBuyingPlan bp Join tblICItem i on bp.strItemNo=i.strItemNo
	Join tblSMCompanyLocationSubLocation sl on bp.strSubLocation=sl.strSubLocationName
	Join tblICItemUOM iu on i.intItemId=iu.intItemId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId AND um.strUnitMeasure=bp.strUOM
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