CREATE PROCEDURE [dbo].[uspRKRptDPRReconDiagnostic] 
	@xmlParam NVARCHAR(MAX) = NULL

AS

--DECLARE @xmlParam NVARCHAR(MAX) = N'<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>dtmFromDate</fieldname><condition>EQUAL TO</condition><from>07/05/2022 10:30:00</from><join /><begingroup /><endgroup /><datatype>String</datatype></filter><filter><fieldname>dtmToDate</fieldname><condition>EQUAL TO</condition><from>07/07/2022 10:00:00</from><join /><begingroup /><endgroup /><datatype>String</datatype></filter><filter><fieldname>intCommodityId</fieldname><condition>EQUAL TO</condition><from>1</from><join /><begingroup /><endgroup /><datatype>Int32</datatype></filter><filter><fieldname>intClientTimeZoneOffset</fieldname><condition>EQUAL TO</condition><from>330</from><join /><begingroup /><endgroup /><datatype>Int32</datatype></filter><filter><fieldname>intUserId</fieldname><condition>EQUAL TO</condition><from>2</from><join /><begingroup /><endgroup /><datatype>Int32</datatype></filter><filter><fieldname>intSrCurrentUserId</fieldname><condition>Dummy</condition><from>2</from><join>OR</join><begingroup /><endgroup /><datatype>int</datatype></filter><filter><fieldname>intSrLanguageId</fieldname><condition>Dummy</condition><from>0</from><join>OR</join><begingroup /><endgroup /><datatype>int</datatype></filter></filters><sorts /><dummies><filter><fieldname>strReportLogId</fieldname><condition>Dummy</condition><from>49895bb0-0b85-449e-abd6-7325c60f31d7</from><join /><begingroup /><endgroup /><datatype>string</datatype></filter></dummies></xmlparam>'
BEGIN

	DECLARE @idoc INT
		,@dtmFromDate DATETIME
		,@dtmToDate DATETIME
		,@intCommodityId int
		,@intClientTimeZoneOffset INT
		,@intUserId int
	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	DECLARE @temp_xml_table TABLE (
		fieldname NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@idoc, 'xmlparam/filters/filter', 2) WITH (
			 fieldname NVARCHAR(50)
			,condition NVARCHAR(20)
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
			)

	SELECT @dtmFromDate = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'dtmFromDate'

	SELECT @dtmToDate = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'dtmToDate'
	
	SELECT @intCommodityId = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'intCommodityId'

	SELECT @intClientTimeZoneOffset = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'intClientTimeZoneOffset'

	SELECT @intUserId = [from]
	FROM @temp_xml_table	
	WHERE [fieldname] = 'intUserId'


DECLARE @dtmCurrent datetimeoffset = GETDATE(),
		@intServerTimeZoneOffset INT
		
SELECT @intServerTimeZoneOffset = DATEDIFF(MINUTE,GETUTCDATE(),GETDATE())


IF @intServerTimeZoneOffset <> @intClientTimeZoneOffset
BEGIN
	DECLARE @dtmFrom datetimeoffset = @dtmFromDate
		,@dtmTo datetimeoffset = @dtmToDate
		, @dtmClient DATETIME
		, @dtmServer DATETIME
		, @intClientToServerOffset INT


	SELECT @dtmClient = DATEADD(MINUTE,@intClientTimeZoneOffset,@dtmFromDate)
		,@dtmServer = DATEADD(MINUTE,@intServerTimeZoneOffset,@dtmFromDate) ;

	SELECT @intClientToServerOffset = DATEDIFF(MINUTE, @dtmClient, @dtmServer )


	SET @dtmFromDate = DATEADD(MINUTE,@intClientToServerOffset,@dtmFromDate)
	SET @dtmToDate = DATEADD(MINUTE,@intClientToServerOffset,@dtmToDate)

END
	
DECLARE @strCommodityCode NVARCHAR(100)

SELECT @strCommodityCode = strCommodityCode FROM tblICCommodity WHERE intCommodityId = @intCommodityId

DECLARE @tempDPRReconHeader TABLE
(
	[intDPRReconHeaderId] INT, 
    [dtmFromDate] DATETIME, 
    [dtmToDate] DATETIME, 
    [intCommodityId] INT, 
    [intUserId] INT, 
    [intConcurrencyId] INT 
)


INSERT INTO @tempDPRReconHeader(
	intDPRReconHeaderId
	,dtmFromDate
	,dtmToDate
	,intCommodityId
	,intUserId
	,intConcurrencyId
)
EXEC uspRKGenerateDPRRecon NULL, @dtmFromDate, @dtmToDate, @intCommodityId, @intUserId

DECLARE @intDPRReconHeaderId INT

select @intDPRReconHeaderId = intDPRReconHeaderId from @tempDPRReconHeader 



select * into #tmpSourceContracts from dbo.fnCTGetContractDPRRecon(@dtmFromDate,@dtmToDate,@intCommodityId)



select
		strBucketName
		,strCommodityCode
		,strContractNumber = strContractNumber + '-' + CAST(intContractSeq AS NVARCHAR(10))
		,intContractSeq
		,intContractHeaderId
		,dblQty
		,strUnitMeasure
into #tmpDPRReconContracts
	from tblRKDPRReconContracts
	where intDPRReconHeaderId  = @intDPRReconHeaderId


select * into #tmpSourceDerivatives from dbo.fnRKGetDerivativeDPRRecon(@dtmFromDate,@dtmToDate,@intCommodityId)


select
		strBucketName
		,strCommodityCode
		,strTransactionNumber 
		,intFutOptTransactionHeaderId
		,dblOrigQty
		,strUnitMeasure = ''
into #tmpDPRReconDerivatives
	from tblRKDPRReconDerivatives
	where intDPRReconHeaderId  = @intDPRReconHeaderId


select
	 S.strBucket
	 ,strCommodity = @strCommodityCode
	 ,strTransactionReference = S.strContractNumber
	 ,dblSourceQty = S.dblQuantity
	 ,dblDPRReconQty = R.dblQty
	 ,dblDifference = ISNULL(S.dblQuantity,0) - ISNULL(R.dblQty,0)
	 ,strUOM = R.strUnitMeasure COLLATE Latin1_General_CI_AS
from #tmpSourceContracts S
left join #tmpDPRReconContracts R ON R.strContractNumber COLLATE Latin1_General_CI_AS = S.strContractNumber COLLATE Latin1_General_CI_AS
	and REPLACE(REPLACE(REPLACE(R.strBucketName,'+ ',''),'- ',''),'+/','') COLLATE Latin1_General_CI_AS = S.strBucket COLLATE Latin1_General_CI_AS

union all

select
	 S.strBucket
	 ,strCommodityCode = @strCommodityCode
	 ,S.strInternalTradeNo
	 ,S.dblTotal
	 ,R.dblOrigQty
	 ,dblDifference = ISNULL(S.dblTotal,0) - ISNULL(R.dblOrigQty,0)
	 ,strUOM = R.strUnitMeasure COLLATE Latin1_General_CI_AS
from #tmpSourceDerivatives S
left join #tmpDPRReconDerivatives R ON R.strTransactionNumber COLLATE Latin1_General_CI_AS = S.strInternalTradeNo COLLATE Latin1_General_CI_AS
	and R.strBucketName COLLATE Latin1_General_CI_AS = S.strBucket COLLATE Latin1_General_CI_AS


drop table #tmpDPRReconContracts
drop table #tmpDPRReconDerivatives
drop table #tmpSourceContracts
drop table #tmpSourceDerivatives

delete from tblRKDPRReconHeader where intDPRReconHeaderId = @intDPRReconHeaderId



--select strBucket = null,strCommodity= null	,strTransactionReference= null	,dblSourceQty= null	,dblDPRReconQty= null, dblDifference = null, strUOM = null


END	