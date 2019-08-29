CREATE PROCEDURE uspRKPositionReconciliationReportContractBalance
	@intCommodityId INT 
	,@intContractTypeId INT --1 = Purchase, 2 = Sale
	,@dtmFromTransactionDate DATE 
	,@dtmToTransactionDate DATE
	,@intQtyUOMId INT = NULL

AS

----Test Param (Remove it once push to repo)
--DECLARE @intCommodityId INT = 9
--		,@intContractTypeId INT = 2 --1 = Purchase, 2 = Sale
--		,@dtmFromTransactionDate DATE = '08/01/2019'
--		,@dtmToTransactionDate DATE = '08/30/2019'

BEGIN



DECLARE @dtmContractBeginBalance DATE
		,@strContractType NVARCHAR(50) = ''

		IF @intContractTypeId = 1
		BEGIN
			SET @strContractType = 'Purchase'
		END
		ELSE
		BEGIN
			SET @strContractType = 'Sale'
		END

		select @dtmContractBeginBalance = DATEADD(day, -1, convert(date, @dtmFromTransactionDate))

--EXEC [dbo].[uspCTGetContractBalance]
--   	@intContractTypeId		  = @intContractTypeId
--   ,@intEntityId			  = NULL
--   ,@IntCommodityId			  = @intCommodityId  
--   ,@dtmEndDate				 = @dtmContractBeginBalance
--   ,@intCompanyLocationId     = NULL
--   ,@IntFutureMarketId        = NULL
--   ,@IntFutureMonthId         = NULL
--   ,@strPositionIncludes    = NULL
--   ,@strCallingApp			 = 'DPR'
--   ,@strPrintOption			 = NULL


SELECT
	strHeaderType = @strContractType + ' Contract Balance' 
	,dtmTransactionDate 
	,t.intContractHeaderId
	,t.intContractDetailId
	,CH.strContractNumber
	,CD.intContractSeq
	,dblIncrease = CASE WHEN t.dblQty > 0 THEN t.dblQty ELSE 0 END
	,dblDecrease = CASE WHEN t.dblQty < 0 THEN t.dblQty * -1 ELSE 0 END
	,t.strPricingType
INTO #tblContractBalance
FROM(
	select  
		1 AS Row_Num
		, dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmTransactionDate)
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, dblQty = case when isnull(cd.intNoOfLoad,0) = 0 then sh.dblTransactionQuantity 
						else sh.dblTransactionQuantity * cd.dblQuantityPerLoad
					end
		, pt.strPricingType
	from vyuCTSequenceUsageHistory sh
	inner join tblCTContractDetail cd on cd.intContractDetailId = sh.intContractDetailId
	inner join tblCTPricingType pt on pt.intPricingTypeId = cd.intPricingTypeId
	where strFieldName = 'Balance'

	union all
	select 
		Row_Number() OVER (PARTITION BY sh.intContractDetailId ORDER BY dtmCreated  DESC) AS Row_Num
		, dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmCreated)
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, dblQty = sh.dblBalance
		, pt.strPricingType
	from tblCTSequenceHistory sh
	inner join tblCTContractDetail cd on cd.intContractDetailId = sh.intContractDetailId
	inner join tblCTPricingType pt on pt.intPricingTypeId = cd.intPricingTypeId
	where intSequenceUsageHistoryId is null 

	union all
	SELECT	
		Row_Number() OVER (PARTITION BY pf.intContractDetailId ORDER BY fd.dtmFixationDate  DESC) AS Row_Num
		, dtmTransactionDate = dbo.fnRemoveTimeOnDate(fd.dtmFixationDate)
		, pf.intContractHeaderId
		, pf.intContractDetailId
		, dblQty = fd.dblQuantity * -1
		, 'Basis'
	FROM	tblCTPriceFixationDetail fd
	JOIN	tblCTPriceFixation		 pf	ON	pf.intPriceFixationId =	fd.intPriceFixationId
	JOIN tblCTContractDetail		 cd ON cd.intContractDetailId = pf.intContractDetailId
	WHERE fd.intPriceFixationDetailId NOT IN (SELECT intPriceFixationDetailId FROM tblCTPriceFixationDetailAPAR)

	union all
	SELECT	
		Row_Number() OVER (PARTITION BY pf.intContractDetailId ORDER BY fd.dtmFixationDate  DESC) AS Row_Num
		, dtmTransactionDate = dbo.fnRemoveTimeOnDate(fd.dtmFixationDate)
		, pf.intContractHeaderId
		, pf.intContractDetailId
		, dblQty = fd.dblQuantity
		, 'Priced'
	FROM	tblCTPriceFixationDetail fd
	JOIN	tblCTPriceFixation		 pf	ON	pf.intPriceFixationId =	fd.intPriceFixationId
	JOIN tblCTContractDetail		 cd ON cd.intContractDetailId = pf.intContractDetailId
	WHERE fd.intPriceFixationDetailId NOT IN (SELECT intPriceFixationDetailId FROM tblCTPriceFixationDetailAPAR)



) t
INNER JOIN tblCTContractHeader CH on CH.intContractHeaderId = t.intContractHeaderId 
INNER JOIN tblCTContractDetail CD on CD.intContractDetailId = t.intContractDetailId
WHERE Row_Num = 1
AND dtmTransactionDate between @dtmFromTransactionDate and @dtmToTransactionDate
AND CH.intContractTypeId = @intContractTypeId --1 = Purchase, 2 = Sale
AND CH.intCommodityId  = @intCommodityId
ORDER BY dtmTransactionDate


SELECT *
INTO #tblFinalContractBalance
FROM (
	
	SELECT 
			 intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmTransactionDate ASC))
			,dtmTransactionDate
			,dblBasisIncrease =  CASE WHEN strPricingType = 'Basis' THEN dblIncrease ELSE 0 END
			,dblBasisDecrease =  CASE WHEN strPricingType = 'Basis' THEN dblDecrease ELSE 0 END
			,dblPricedIncrease =  CASE WHEN strPricingType = 'Priced' THEN dblIncrease ELSE 0 END
			,dblPricedDecrease =  CASE WHEN strPricingType = 'Priced' THEN dblDecrease ELSE 0 END
			,dblDPIncrease =  CASE WHEN strPricingType = 'DP (Priced Later)' THEN dblIncrease ELSE 0 END
			,dblDPDecrease =  CASE WHEN strPricingType = 'DP (Priced Later)' THEN dblDecrease ELSE 0 END
			,dblCashIncrease =  CASE WHEN strPricingType = 'Cash' THEN dblIncrease ELSE 0 END
			,dblCashDecrease =  CASE WHEN strPricingType = 'Cash' THEN dblDecrease ELSE 0 END
			,strContractSeq = strContractNumber + '-' + CONVERT(NVARCHAR(5),intContractSeq)
			,intContractHeaderId
			,intContractDetailId
		FROM #tblContractBalance
		WHERE strPricingType <> 'HTA'
) t
ORDER BY dtmTransactionDate






SELECT	intRowNum 
INTO #tempDateRange
FROM	#tblFinalContractBalance AS d

declare @tblRunningBalance as table (
	intRowNum  INT  NULL
	,dblBasisBalance  NUMERIC(18,6)
	,dblPricedBalance  NUMERIC(18,6)
	,dblDPBalance  NUMERIC(18,6)
	,dblCashBalance  NUMERIC(18,6)
)

Declare @intRowNum int
	,@dblBasisBeginBalance  NUMERIC(18,6)
	,@dblPricedBeginBalance  NUMERIC(18,6)
	,@dblDPBeginBalance  NUMERIC(18,6)
	,@dblCashBeginBalance  NUMERIC(18,6)


select @dblBasisBeginBalance = isnull(sum(dblQuantity) ,0)
from tblCTContractBalance where dtmEndDate = @dtmContractBeginBalance
and intCommodityId = @intCommodityId
and intContractTypeId = @intContractTypeId
and strPricingTypeDesc = 'Basis'

select @dblPricedBeginBalance = isnull(sum(dblQuantity) ,0)
from tblCTContractBalance where dtmEndDate = @dtmContractBeginBalance
and intCommodityId = @intCommodityId
and intContractTypeId = @intContractTypeId
and strPricingTypeDesc = 'Priced'

select @dblDPBeginBalance = isnull(sum(dblQuantity) ,0)
from tblCTContractBalance where dtmEndDate = @dtmContractBeginBalance
and intCommodityId = @intCommodityId
and intContractTypeId = @intContractTypeId
and strPricingTypeDesc = 'DP (Priced Later)'

select @dblCashBeginBalance = isnull(sum(dblQuantity) ,0)
from tblCTContractBalance where dtmEndDate = @dtmContractBeginBalance
and intCommodityId = @intCommodityId
and intContractTypeId = @intContractTypeId
and strPricingTypeDesc = 'Cash'

insert into @tblRunningBalance(
		intRowNum
		,dblBasisBalance
		,dblPricedBalance
		,dblDPBalance
		,dblCashBalance
	)
values (
	null
	,@dblBasisBeginBalance
	,@dblPricedBeginBalance
	,@dblDPBeginBalance
	,@dblCashBeginBalance
)

While (Select Count(*) From #tempDateRange) > 0
Begin

	Select Top 1 @intRowNum = intRowNum From #tempDateRange

	insert into @tblRunningBalance(
		intRowNum
		,dblBasisBalance
		,dblPricedBalance
		,dblDPBalance
		,dblCashBalance
	)
	select @intRowNum
		,@dblBasisBeginBalance + ( dblBasisIncrease - dblBasisDecrease)  
		,@dblPricedBeginBalance + ( dblPricedIncrease - dblPricedDecrease)  
		,@dblDPBeginBalance + ( dblDPIncrease - dblDPIncrease)  
		,@dblCashBeginBalance + ( dblCashIncrease - dblCashDecrease)  
	from #tblFinalContractBalance 
	WHERE intRowNum = @intRowNum
	
	select 
		@dblBasisBeginBalance = dblBasisBalance 
		,@dblPricedBeginBalance = dblPricedBalance 
		,@dblDPBeginBalance = dblDPBalance
		,@dblCashBeginBalance = dblCashBalance
	from @tblRunningBalance where intRowNum = @intRowNum
						
	Delete #tempDateRange Where intRowNum = @intRowNum

End

select 
	 cb.intRowNum 
	,dtmTransactionDate
	,dblBasisIncrease
	,dblBasisDecrease
	,dblBasisBalance
	,dblPricedIncrease
	,dblPricedDecrease
	,dblPricedBalance
	,dblDPIncrease
	,dblDPDecrease
	,dblDPBalance
	,dblCashIncrease
	,dblCashDecrease
	,dblCashBalance
	,strContractSeq 
	,intContractHeaderId
	,intContractDetailId
from #tblFinalContractBalance cb
full join @tblRunningBalance rb on rb.intRowNum = cb.intRowNum
order by cb.dtmTransactionDate



DROP TABLE #tblContractBalance
DROP TABLE #tblFinalContractBalance 
DROP TABLE #tempDateRange


END
