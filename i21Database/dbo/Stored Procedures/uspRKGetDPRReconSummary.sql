CREATE PROCEDURE [dbo].[uspRKGetDPRReconSummary]
	@intDPRReconHeaderId INT 
	, @intCommodityId INT
AS


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @ErrMsg NVARCHAR(MAX) 

DECLARE @strCommodityCode NVARCHAR(100),
		@dtmFromDate DATETIME,
		@dtmToDate DATETIME

SELECT @strCommodityCode = strCommodityCode  FROM tblICCommodity where intCommodityId = @intCommodityId

SELECT 
	@dtmFromDate = DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dtmFromDate) 
	,@dtmToDate = DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), dtmToDate) 
FROM tblRKDPRReconHeader WHERe intDPRReconHeaderId = @intDPRReconHeaderId


select * into #tmpDPRReconSummary from (

	select
		strBucketName
		,dblTotal = sum(dblQty) 
		,strCommodityCode
		,intSort
		,strGroup = '+ Priced Purchase Contract'
		,intGroupSort = 1
	from tblRKDPRReconContracts
	where strContractType = 'Purchase'
	and intDPRReconHeaderId  = @intDPRReconHeaderId
	group by strBucketName, strCommodityCode,intSort,intDPRReconHeaderId

	union all
	select
		strBucketName
		,dblTotal = sum(dblQty) 
		,strCommodityCode
		,intSort
		,strGroup = '- Priced Sales Contract'
		,intGroupSort = 2
	from tblRKDPRReconContracts
	where strContractType = 'Sales'
	and intDPRReconHeaderId  = @intDPRReconHeaderId
	group by strBucketName, strCommodityCode,intSort,intDPRReconHeaderId

	union all

	select
		strBucketName
		,dblTotal = sum(dblOrigQty) 
		,strCommodityCode
		,intSort
		,strGroup = '+ Futures'
		,intGroupSort = 3
	from tblRKDPRReconDerivatives
	where intDPRReconHeaderId  = @intDPRReconHeaderId
	group by strBucketName, strCommodityCode,intSort,intDPRReconHeaderId
	
) t


select 
	intSort
	,strGroup
	,intGroupSort
	,strBucketName = strBucketName +  CASE WHEN sum(dblTotal) is null THEN ' w/o drill down' Else '' END
	,strOrigBucketName = strBucketName
	,dblTotal = sum(dblTotal) 
	,strCommodityCode
	,intDPRReconHeaderId = @intDPRReconHeaderId
	,ysnIsTotalNull = CAST( CASE WHEN sum(dblTotal) is null THEN 1 Else 0 END AS BIT) 
	,strFromDate = REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(10),@dtmFromDate,101) + ' ' + RIGHT(CONVERT(VARCHAR, @dtmFromDate, 100), 7),'  ',' '),'AM',' AM'),'PM',' PM')
	,strToDate = REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(10),@dtmToDate,101) + ' ' + RIGHT(CONVERT(VARCHAR, @dtmToDate, 100), 7),'  ',' '),'AM',' AM'),'PM',' PM')
from (
	--with data
	select * from #tmpDPRReconSummary

	--template
	--=========================================================
	--				PURCHASE
	--=========================================================
	union all
	select 
		strBucketName = '+ New Priced Purchase Contract'
		,dblTotal = null
		,strCommodityCode = @strCommodityCode
		,intSort = 1
		,strGroup = '+ Priced Purchase Contract'
		,intGroupSort = 1

	union all
	select 
		strBucketName = '+ New HTA Purchase Contract'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 2
		,strGroup = '+ Priced Purchase Contract'
		,intGroupSort = 1

	union all
	select 
		strBucketName = '+ Spot Purchases'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 3
		,strGroup = '+ Priced Purchase Contract'
		,intGroupSort = 1

	union all
	select 
		strBucketName = '+ Purchase Basis Pricing'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 4
		,strGroup = '+ Priced Purchase Contract'
		,intGroupSort = 1

	union all
	select 
		strBucketName = '+ Purchase Qty Adjustment'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 5
		,strGroup = '+ Priced Purchase Contract'
		,intGroupSort = 1

	union all
	select 
		strBucketName = '+/- Purchase Load Variance'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 6
		,strGroup = '+ Priced Purchase Contract'
		,intGroupSort = 1

	union all
	select 
		strBucketName = '- Purchase Short Closed'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort =7
		,strGroup = '+ Priced Purchase Contract'
		,intGroupSort = 1

	union all
	select 
		strBucketName = '- Purchase Cancelled'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 8
		,strGroup = '+ Priced Purchase Contract'
		,intGroupSort = 1

	--=========================================================
	--				SALES
	--=========================================================
	union all
	select 
		strBucketName = '+ New Priced Sales Contract'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 11
		,strGroup = '- Priced Sales Contract'
		,intGroupSort = 2

	union all
	select 
		strBucketName = '+ New HTA Sales Contract'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 12
		,strGroup = '- Priced Sales Contract'
		,intGroupSort = 2

	union all
	select 
		strBucketName = '+ Spot Sales'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 13
		,strGroup = '- Priced Sales Contract'
		,intGroupSort = 2

	union all
	select 
		strBucketName = '+ Sales Basis Pricing'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 14
		,strGroup = '- Priced Sales Contract'
		,intGroupSort = 2

	union all
	select 
		strBucketName = '+ Sales Qty Adjustment'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 15
		,strGroup = '- Priced Sales Contract'
		,intGroupSort = 2

	union all
	select 
		strBucketName = '+/- Sales Load Variance'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 16
		,strGroup = '- Priced Sales Contract'
		,intGroupSort = 2

	union all
	select 
		strBucketName = '- Sales Short Closed'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort =17
		,strGroup = '- Priced Sales Contract'
		,intGroupSort = 2

	union all
	select 
		strBucketName = '- Sales Cancelled'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 18
		,strGroup = '- Priced Sales Contract'
		,intGroupSort = 2

	--=========================================================
	--				FUTURES
	--=========================================================
	union all
	select 
		strBucketName = 'Futures'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 21
		,strGroup = '+ Futures'
		,intGroupSort = 3

	union all
	select 
		strBucketName = 'Crush'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 22
		,strGroup = '+ Futures'
		,intGroupSort = 3

) t

group by
	strBucketName
	,strCommodityCode
	,intSort
	,strGroup
	,intGroupSort
order by intSort
	



drop table #tmpDPRReconSummary


END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH