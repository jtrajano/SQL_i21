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

DECLARE @strCommodityCode NVARCHAR(100)

SELECT @strCommodityCode = strCommodityCode  FROM tblICCommodity where intCommodityId = @intCommodityId

select * into #tmpDPRReconSummary from (

	select
		strBucketName
		,dblTotal = sum(dblQty) 
		,strCommodityCode
		,intSort
		,strGroup = '+ Priced Purchase Contract'
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
	from tblRKDPRReconDerivatives
	where intDPRReconHeaderId  = @intDPRReconHeaderId
	group by strBucketName, strCommodityCode,intSort,intDPRReconHeaderId
	
) t


select 
	intSort
	,strGroup
	,strBucketName
	,dblTotal = sum(dblTotal) 
	,strCommodityCode
	,intDPRReconHeaderId = @intDPRReconHeaderId
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
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 1
		,strGroup = '+ Priced Purchase Contract'

	union all
	select 
		strBucketName = '+ New HTA Purchase Contract'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 2
		,strGroup = '+ Priced Purchase Contract'

	union all
	select 
		strBucketName = '+ Spot Purchases'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 3
		,strGroup = '+ Priced Purchase Contract'

		union all
	select 
		strBucketName = '+ Purchase Basis Pricing'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 4
		,strGroup = '+ Priced Purchase Contract'

		union all
	select 
		strBucketName = '+ Purchase Qty Adjustment'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 5
		,strGroup = '+ Priced Purchase Contract'

		union all
	select 
		strBucketName = '+/- Purchase Load Variance'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 6
		,strGroup = '+ Priced Purchase Contract'

		union all
	select 
		strBucketName = '- Purchase Short Closed'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort =7
		,strGroup = '+ Priced Purchase Contract'

		union all
	select 
		strBucketName = '- Purchase Cancelled'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 8
		,strGroup = '+ Priced Purchase Contract'

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

	union all
	select 
		strBucketName = '+ New HTA Sales Contract'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 12
		,strGroup = '- Priced Sales Contract'

	union all
	select 
		strBucketName = '+ Spot Sales'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 13
		,strGroup = '- Priced Sales Contract'

		union all
	select 
		strBucketName = '+ Sales Basis Pricing'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 14
		,strGroup = '- Priced Sales Contract'

		union all
	select 
		strBucketName = '+ Sales Qty Adjustment'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 15
		,strGroup = '- Priced Sales Contract'

		union all
	select 
		strBucketName = '+/- Sales Load Variance'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 16
		,strGroup = '- Priced Sales Contract'

		union all
	select 
		strBucketName = '- Sales Short Closed'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort =17
		,strGroup = '- Priced Sales Contract'

		union all
	select 
		strBucketName = '- Sales Cancelled'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 18
		,strGroup = '- Priced Sales Contract'

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

	union all
	select 
		strBucketName = 'Crush'
		,dblTotal = NULL
		,strCommodityCode = @strCommodityCode
		,intSort = 22
		,strGroup = '+ Futures'

) t

group by
	strBucketName
	,strCommodityCode
	,intSort
	,strGroup
order by intSort
	



drop table #tmpDPRReconSummary


END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH