CREATE PROCEDURE uspRKPositionReconciliationReportContractBalance
	@strCommodityId NVARCHAR(100) 
	,@intContractTypeId INT --1 = Purchase, 2 = Sale
	,@dtmFromTransactionDate DATE 
	,@dtmToTransactionDate DATE
	,@intQtyUOMId INT = NULL

AS

BEGIN

	DECLARE @dtmContractBeginBalance DATE
		,@strCommodities NVARCHAR(MAX)
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
		--@intContractTypeId		  = @intContractTypeId
		--,@intEntityId			  = NULL
		--,@IntCommodityId			  = NULL  
		--,@dtmEndDate				 = @dtmContractBeginBalance
		--,@intCompanyLocationId     = NULL
		--,@IntFutureMarketId        = NULL
		--,@IntFutureMonthId         = NULL
		--,@strPositionIncludes    = NULL
		--,@strCallingApp			 = 'DPR'
		--,@strPrintOption			 = NULL


	DECLARE @Commodity AS TABLE (intCommodityIdentity INT IDENTITY PRIMARY KEY
		, intCommodityId INT)
		
	
	INSERT INTO @Commodity(intCommodityId)
	SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@strCommodityId, ',')

	SELECT DISTINCT com.intCommodityId, strCommodityCode
	INTO #tempCommodity
	FROM @Commodity com
	INNER JOIN tblICCommodity iccom on iccom.intCommodityId = com.intCommodityId
	WHERE ISNULL(com.intCommodityId, '') <> ''
	
	--Build concatenated commodities to be used if begin balance only (no record from given date range)
	SELECT @strCommodities =  COALESCE(@strCommodities + ', ' + strCommodityCode, strCommodityCode) FROM #tempCommodity


SELECT DISTINCT
	strHeaderType = @strContractType + ' Contract Balance' 
	,dtmTransactionDate 
	,C.strCommodityCode
	,t.intContractHeaderId
	,t.intContractDetailId
	,CH.strContractNumber
	,CD.intContractSeq
	,dblIncrease = CASE WHEN t.dblQty > 0 THEN t.dblQty ELSE 0 END
	,dblDecrease = CASE WHEN t.dblQty < 0 THEN t.dblQty * -1 ELSE 0 END
	,t.strPricingType
	,t.strTransactionType
	,t.intTransactionId
	,t.strTransactionId
	,intOrderBy
INTO #tblContractBalance
FROM(
	select 
		Row_Number() OVER (PARTITION BY sh.intContractDetailId ORDER BY cd.dtmCreated  DESC, sh.intSequenceHistoryId DESC) AS Row_Num
		, dtmTransactionDate = dbo.fnRemoveTimeOnDate(cd.dtmCreated)
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, dblQty = dbo.fnCTConvertQtyToTargetCommodityUOM(ch.intCommodityId,dbo.fnCTGetCommodityUnitMeasure(ch.intCommodityUOMId),cum.intUnitMeasureId,sh.dblBalance)
		, pt.strPricingType
		, strTransactionType = ''
		, intTransactionId = null
		, strTransactionId = ''
		, intOrderBy = 1
	from tblCTSequenceHistory sh
	inner join tblCTContractDetail cd on cd.intContractDetailId = sh.intContractDetailId
	inner join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
	inner join tblCTPricingType pt on pt.intPricingTypeId = sh.intPricingTypeId
	inner join tblICCommodityUnitMeasure cum on cum.intCommodityId = ch.intCommodityId and cum.ysnDefault = 1
	where intSequenceUsageHistoryId is null and strPricingStatus not in ( 'Partially Priced', 'Fully Priced')

	
	union all
	select  
		1 AS Row_Num
		, dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmScreenDate)
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, dblQty = dbo.fnCTConvertQtyToTargetCommodityUOM(ch.intCommodityId,dbo.fnCTGetCommodityUnitMeasure(ch.intCommodityUOMId),cum.intUnitMeasureId,case when isnull(cd.intNoOfLoad,0) = 0 then suh.dblTransactionQuantity 
						else suh.dblTransactionQuantity * cd.dblQuantityPerLoad
					end)
		, pt.strPricingType
		, strTransactionType = strScreenName
		, intTransactionId = suh.intExternalHeaderId
		, strTransactionId = suh.strNumber
		, intOrderBy = 2
	from vyuCTSequenceUsageHistory suh
	inner join tblCTSequenceHistory sh on sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
	inner join tblCTContractDetail cd on cd.intContractDetailId = sh.intContractDetailId
	inner join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
	inner join tblCTPricingType pt on pt.intPricingTypeId = sh.intPricingTypeId
	inner join tblICCommodityUnitMeasure cum on cum.intCommodityId = ch.intCommodityId and cum.ysnDefault = 1
	where strFieldName = 'Balance'

	union all
	SELECT	
		Row_Number() OVER (PARTITION BY pf.intContractDetailId, fd.intPriceFixationDetailId ORDER BY fd.dtmFixationDate  DESC) AS Row_Num
		, dtmTransactionDate = dbo.fnRemoveTimeOnDate(fd.dtmFixationDate)
		, pf.intContractHeaderId
		, pf.intContractDetailId
		, dblQty = dbo.fnCTConvertQtyToTargetCommodityUOM(ch.intCommodityId,dbo.fnCTGetCommodityUnitMeasure(ch.intCommodityUOMId),cum.intUnitMeasureId,(fd.dblQuantity - fd.dblQuantityAppliedAndPriced) * -1)
		, 'Basis'
		, strTransactionType = ''
		, intTransactionId = null
		, strTransactionId = ''
		, intOrderBy = 3
	FROM	tblCTPriceFixationDetail fd
	JOIN	tblCTPriceFixation		 pf	ON	pf.intPriceFixationId =	fd.intPriceFixationId
	JOIN tblCTContractDetail		 cd ON cd.intContractDetailId = pf.intContractDetailId
	inner join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
	inner join tblICCommodityUnitMeasure cum on cum.intCommodityId = ch.intCommodityId and cum.ysnDefault = 1
	WHERE (fd.dblQuantity - fd.dblQuantityAppliedAndPriced) <> 0

	union all
	SELECT	
		Row_Number() OVER (PARTITION BY pf.intContractDetailId, fd.intPriceFixationDetailId ORDER BY fd.dtmFixationDate  DESC) AS Row_Num
		, dtmTransactionDate = dbo.fnRemoveTimeOnDate(fd.dtmFixationDate)
		, pf.intContractHeaderId
		, pf.intContractDetailId
		, dblQty = dbo.fnCTConvertQtyToTargetCommodityUOM(ch.intCommodityId,dbo.fnCTGetCommodityUnitMeasure(ch.intCommodityUOMId),cum.intUnitMeasureId,fd.dblQuantity - fd.dblQuantityAppliedAndPriced)
		, 'Priced'
		, strTransactionType = ''
		, intTransactionId = null
		, strTransactionId = ''
		, intOrderBy = 4
	FROM	tblCTPriceFixationDetail fd
	JOIN	tblCTPriceFixation		 pf	ON	pf.intPriceFixationId =	fd.intPriceFixationId
	JOIN tblCTContractDetail		 cd ON cd.intContractDetailId = pf.intContractDetailId
	inner join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
	inner join tblICCommodityUnitMeasure cum on cum.intCommodityId = ch.intCommodityId and cum.ysnDefault = 1
	WHERE (fd.dblQuantity - fd.dblQuantityAppliedAndPriced) <> 0



) t
INNER JOIN tblCTContractHeader CH on CH.intContractHeaderId = t.intContractHeaderId 
INNER JOIN tblCTContractDetail CD on CD.intContractDetailId = t.intContractDetailId
INNER JOIN tblICCommodity C  on C.intCommodityId = CH.intCommodityId
WHERE Row_Num = 1
AND dtmTransactionDate between @dtmFromTransactionDate and @dtmToTransactionDate
AND CH.intContractTypeId = @intContractTypeId --1 = Purchase, 2 = Sale
AND CH.intCommodityId  IN (SELECT com.intCommodityId FROM @Commodity com)
ORDER BY dtmTransactionDate, intOrderBy


SELECT *
INTO #tblFinalContractBalance
FROM (
	
	SELECT 
			 intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmTransactionDate ASC, intOrderBy ASC, intContractHeaderId ASC, intContractDetailId ASC))
			,dtmTransactionDate
			,strCommodityCode
			,dblBasisIncrease =  CASE WHEN strPricingType = 'Basis' THEN dblIncrease ELSE 0 END
			,dblBasisDecrease =  CASE WHEN strPricingType = 'Basis' THEN dblDecrease ELSE 0 END
			,dblPricedIncrease =  CASE WHEN strPricingType = 'Priced' THEN dblIncrease ELSE 0 END
			,dblPricedDecrease =  CASE WHEN strPricingType = 'Priced' THEN dblDecrease ELSE 0 END
			,dblDPIncrease =  CASE WHEN strPricingType = 'DP (Priced Later)' THEN dblIncrease ELSE 0 END
			,dblDPDecrease =  CASE WHEN strPricingType = 'DP (Priced Later)' THEN dblDecrease ELSE 0 END
			,dblHTAIncrease =  CASE WHEN strPricingType = 'HTA' THEN dblIncrease ELSE 0 END
			,dblHTADecrease =  CASE WHEN strPricingType = 'HTA' THEN dblDecrease ELSE 0 END
			,dblCashIncrease =  CASE WHEN strPricingType = 'Cash' THEN dblIncrease ELSE 0 END
			,dblCashDecrease =  CASE WHEN strPricingType = 'Cash' THEN dblDecrease ELSE 0 END
			,strContractSeq = strContractNumber + '-' + CONVERT(NVARCHAR(5),intContractSeq)
			,intContractHeaderId
			,intContractDetailId
			,strTransactionType
			,intTransactionId
			,strTransactionId
			,intOrderBy
		FROM #tblContractBalance
) t
ORDER BY dtmTransactionDate, intOrderBy


SELECT	intRowNum, dtmTransactionDate
INTO #tempDateRange
FROM	#tblFinalContractBalance AS d

declare @tblRunningBalance as table (
	intRowNum  INT  NULL
	,dtmDate DATE
	,dblBasisBegBalance  NUMERIC(18,6)
	,dblBasisEndBalance  NUMERIC(18,6)
	,dblPricedBegBalance  NUMERIC(18,6)
	,dblPricedEndBalance  NUMERIC(18,6)
	,dblDPBegBalance  NUMERIC(18,6)
	,dblDPEndBalance  NUMERIC(18,6)
	,dblHTABegBalance  NUMERIC(18,6)
	,dblHTAEndBalance  NUMERIC(18,6)
	,dblCashBegBalance  NUMERIC(18,6)
	,dblCashEndBalance  NUMERIC(18,6)
	,dblBasisBegBalForSummary NUMERIC(18,6)
	,dblBasisEndBalForSummary NUMERIC(18,6)
	,dblPricedBegBalForSummary NUMERIC(18,6)
	,dblPricedEndBalForSummary NUMERIC(18,6)
	,dblDPBegBalForSummary NUMERIC(18,6)
	,dblDPEndBalForSummary NUMERIC(18,6)
	,dblHTABegBalForSummary NUMERIC(18,6)
	,dblHTAEndBalForSummary NUMERIC(18,6)
	,dblCashBegBalForSummary NUMERIC(18,6)
	,dblCashEndBalForSummary NUMERIC(18,6)
)

Declare @intRowNum int
	,@dtmCurDate DATE
	,@dtmPrevDate DATE
	,@dblBasisBalanceForward  NUMERIC(18,6)
	,@dblPricedBalanceForward  NUMERIC(18,6)
	,@dblDPBalanceForward  NUMERIC(18,6)
	,@dblHTABalanceForward  NUMERIC(18,6)
	,@dblCashBalanceForward  NUMERIC(18,6)
	,@dblBasisBegBalForSummary NUMERIC(18,6)
	,@dblPricedBegBalForSummary NUMERIC(18,6)
	,@dblDPBegBalForSummary NUMERIC(18,6)
	,@dblHTABegBalForSummary NUMERIC(18,6)
	,@dblCashBegBalForSummary NUMERIC(18,6)


select @dblBasisBalanceForward = isnull(sum(dblQtyinCommodityStockUOM) ,0)
from tblCTContractBalance where dtmEndDate = @dtmContractBeginBalance
and intCommodityId  IN (SELECT intCommodityId FROM @Commodity)
and intContractTypeId = @intContractTypeId
and strPricingTypeDesc = 'Basis'

select @dblPricedBalanceForward = isnull(sum(dblQtyinCommodityStockUOM) ,0)
from tblCTContractBalance where dtmEndDate = @dtmContractBeginBalance
and intCommodityId  IN (SELECT intCommodityId FROM @Commodity)
and intContractTypeId = @intContractTypeId
and strPricingTypeDesc = 'Priced'

select @dblDPBalanceForward = isnull(sum(dblQtyinCommodityStockUOM) ,0)
from tblCTContractBalance where dtmEndDate = @dtmContractBeginBalance
and intCommodityId  IN (SELECT intCommodityId FROM @Commodity)
and intContractTypeId = @intContractTypeId
and strPricingTypeDesc = 'DP (Priced Later)'

select @dblHTABalanceForward = isnull(sum(dblQtyinCommodityStockUOM) ,0)
from tblCTContractBalance where dtmEndDate = @dtmContractBeginBalance
and intCommodityId  IN (SELECT intCommodityId FROM @Commodity)
and intContractTypeId = @intContractTypeId
and strPricingTypeDesc = 'HTA'

select @dblCashBalanceForward = isnull(sum(dblQtyinCommodityStockUOM) ,0)
from tblCTContractBalance where dtmEndDate = @dtmContractBeginBalance
and intCommodityId  IN (SELECT intCommodityId FROM @Commodity)
and intContractTypeId = @intContractTypeId
and strPricingTypeDesc = 'Cash'

--insert into @tblRunningBalance(
--		intRowNum
--		,dblBasisBalance
--		,dblPricedBalance
--		,dblDPBalance
--		,dblCashBalance
--	)
--values (
--	null
--	,@dblBasisBeginBalance
--	,@dblPricedBeginBalance
--	,@dblDPBeginBalance
--	,@dblCashBeginBalance
--)

IF NOT EXISTS (SELECT TOP 1 * FROM #tempDateRange)
BEGIN
	GOTO BeginBalanceOnly
END

While (Select Count(*) From #tempDateRange) > 0
Begin

	Select Top 1 
		@intRowNum = intRowNum 
		,@dtmCurDate = dtmTransactionDate
	From #tempDateRange

	insert into @tblRunningBalance(
		intRowNum
		,dtmDate
		,dblBasisBegBalance
		,dblBasisEndBalance
		,dblPricedBegBalance
		,dblPricedEndBalance
		,dblDPBegBalance
		,dblDPEndBalance
		,dblHTABegBalance
		,dblHTAEndBalance
		,dblCashBegBalance
		,dblCashEndBalance
	)
	select @intRowNum
		,dtmTransactionDate
		,@dblBasisBalanceForward
		,@dblBasisBalanceForward + ( dblBasisIncrease - dblBasisDecrease)  
		,@dblPricedBalanceForward
		,@dblPricedBalanceForward + ( dblPricedIncrease - dblPricedDecrease)  
		,@dblDPBalanceForward
		,@dblDPBalanceForward + ( dblDPIncrease - dblDPDecrease)  
		,@dblHTABalanceForward
		,@dblHTABalanceForward + ( dblHTAIncrease - dblHTADecrease)  
		,@dblCashBalanceForward
		,@dblCashBalanceForward + ( dblCashIncrease - dblCashDecrease)  
	from #tblFinalContractBalance 
	WHERE intRowNum = @intRowNum
	ORDER by dtmTransactionDate, intOrderBy
	
	select 
		@dblBasisBalanceForward = dblBasisEndBalance 
		,@dblPricedBalanceForward = dblPricedEndBalance 
		,@dblDPBalanceForward = dblDPEndBalance
		,@dblHTABalanceForward = dblHTAEndBalance
		,@dblCashBalanceForward = dblCashEndBalance
	from @tblRunningBalance where intRowNum = @intRowNum
	
	IF @dtmCurDate <> @dtmPrevDate OR @dtmPrevDate IS NULL
	BEGIN
		SELECT 
			@dblBasisBegBalForSummary =  dblBasisBegBalance
			,@dblPricedBegBalForSummary =  dblPricedBegBalance
			,@dblDPBegBalForSummary =  dblDPBegBalance
			,@dblHTABegBalForSummary =  dblHTABegBalance
			,@dblCashBegBalForSummary =  dblCashBegBalance
		FROM @tblRunningBalance
		WHERE dtmDate = @dtmCurDate
			
		UPDATE @tblRunningBalance 
		SET dblBasisBegBalForSummary = @dblBasisBegBalForSummary
			,dblPricedBegBalForSummary = @dblPricedBegBalForSummary
			,dblDPBegBalForSummary = @dblDPBegBalForSummary
			,dblHTABegBalForSummary = @dblHTABegBalForSummary
			,dblCashBegBalForSummary = @dblCashBegBalForSummary
			--
			,dblBasisEndBalForSummary = @dblBasisBalanceForward
			,dblPricedEndBalForSummary = @dblPricedBalanceForward
			,dblDPEndBalForSummary = @dblDPBalanceForward
			,dblHTAEndBalForSummary = @dblHTABalanceForward
			,dblCashEndBalForSummary = @dblCashBalanceForward
		WHERE dtmDate = @dtmCurDate

	
	END

	IF @dtmCurDate = @dtmPrevDate
	BEGIN
		UPDATE @tblRunningBalance 
		SET dblBasisEndBalForSummary = @dblBasisBalanceForward
			,dblPricedEndBalForSummary = @dblPricedBalanceForward
			,dblDPEndBalForSummary = @dblDPBalanceForward
			,dblHTAEndBalForSummary = @dblHTABalanceForward
			,dblCashEndBalForSummary = @dblCashBalanceForward
		WHERE dtmDate = @dtmCurDate

		UPDATE @tblRunningBalance 
		SET dblBasisBegBalForSummary = @dblBasisBegBalForSummary
			,dblPricedBegBalForSummary = @dblPricedBegBalForSummary
			,dblDPBegBalForSummary = @dblDPBegBalForSummary
			,dblHTABegBalForSummary = @dblHTABegBalForSummary
			,dblCashBegBalForSummary = @dblCashBegBalForSummary
		WHERE dtmDate = @dtmCurDate
		AND dblBasisBegBalForSummary IS NULL
		AND dblPricedBegBalForSummary IS NULL
		AND dblDPBegBalForSummary IS NULL
		AND dblHTABegBalForSummary IS NULL
		AND dblCashBegBalForSummary IS NULL
	END

	
	SET @dtmPrevDate = @dtmCurDate
						
	Delete #tempDateRange Where intRowNum = @intRowNum

End


select 
	 cb.intRowNum 
	,dtmTransactionDate
	,strCommodityCode
	,dblBasisBegBalance
	,dblBasisIncrease
	,dblBasisDecrease
	,dblBasisEndBalance
	,dblPricedBegBalance
	,dblPricedIncrease
	,dblPricedDecrease
	,dblPricedEndBalance
	,dblDPBegBalance
	,dblDPIncrease
	,dblDPDecrease
	,dblDPEndBalance
	,dblHTABegBalance
	,dblHTAIncrease
	,dblHTADecrease
	,dblHTAEndBalance
	,dblCashBegBalance
	,dblCashIncrease
	,dblCashDecrease
	,dblCashEndBalance
	,strContractSeq 
	,intContractHeaderId
	,intContractDetailId
	,strTransactionType
	,strTransactionId
	,intTransactionId
	,dblBasisBegBalForSummary
	,dblBasisEndBalForSummary
	,dblPricedBegBalForSummary 
	,dblPricedEndBalForSummary 
	,dblDPBegBalForSummary 
	,dblDPEndBalForSummary
	,dblHTABegBalForSummary 
	,dblHTAEndBalForSummary
	,dblCashBegBalForSummary 
	,dblCashEndBalForSummary
from #tblFinalContractBalance cb
full join @tblRunningBalance rb on rb.intRowNum = cb.intRowNum
order by cb.dtmTransactionDate, intOrderBy

GOTO ExitRoutine

BeginBalanceOnly:

IF @dblBasisBalanceForward <> 0 OR @dblPricedBalanceForward <> 0
	OR @dblDPBalanceForward <> 0 OR @dblHTABalanceForward <> 0 OR @dblCashBalanceForward <> 0
BEGIN
	select 
		 intRowNum  = 1
		,dtmTransactionDate = NULL
		,strCommodityCode = @strCommodities
		,dblBasisBegBalance = @dblBasisBalanceForward
		,dblBasisIncrease  = NULL
		,dblBasisDecrease  = NULL
		,dblBasisEndBalance = @dblBasisBalanceForward
		,dblPricedBegBalance = @dblPricedBalanceForward
		,dblPricedIncrease  = NULL
		,dblPricedDecrease  = NULL
		,dblPricedEndBalance = @dblPricedBalanceForward
		,dblDPBegBalance = @dblDPBalanceForward
		,dblDPIncrease  = NULL
		,dblDPDecrease  = NULL
		,dblDPEndBalance = @dblDPBalanceForward
		,dblHTABegBalance = @dblHTABalanceForward
		,dblHTAIncrease  = NULL
		,dblHTADecrease  = NULL
		,dblHTAEndBalance = @dblHTABalanceForward
		,dblCashBegBalance = @dblCashBalanceForward
		,dblCashIncrease  = NULL
		,dblCashDecrease  = NULL
		,dblCashEndBalance = @dblCashBalanceForward
		,strContractSeq  = 'Balance Forward'
		,intContractHeaderId  = NULL
		,intContractDetailId  = NULL
		,strTransactionType = ''
		,strTransactionId = ''
		,intTransactionId = NULL
		,dblBasisBegBalForSummary = @dblBasisBalanceForward
		,dblBasisEndBalForSummary = @dblBasisBalanceForward
		,dblPricedBegBalForSummary = @dblPricedBalanceForward
		,dblPricedEndBalForSummary = @dblPricedBalanceForward
		,dblDPBegBalForSummary  = @dblDPBalanceForward
		,dblDPEndBalForSummary = @dblDPBalanceForward
		,dblHTABegBalForSummary  = @dblHTABalanceForward
		,dblHTAEndBalForSummary = @dblHTABalanceForward
		,dblCashBegBalForSummary = @dblCashBalanceForward
		,dblCashEndBalForSummary = @dblCashBalanceForward

END

ExitRoutine:
DROP TABLE #tblContractBalance
DROP TABLE #tblFinalContractBalance 
DROP TABLE #tempDateRange
DROP TABLE #tempCommodity


END
