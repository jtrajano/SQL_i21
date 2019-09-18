CREATE PROCEDURE uspRKPositionReconciliationReportContractBalance
	@strCommodityId NVARCHAR(100) 
	,@intContractTypeId INT --1 = Purchase, 2 = Sale
	,@dtmFromTransactionDate DATE 
	,@dtmToTransactionDate DATE
	,@intQtyUOMId INT = NULL

AS

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



SELECT
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
INTO #tblContractBalance
FROM(
	select  
		1 AS Row_Num
		, dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmScreenDate)
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
INNER JOIN tblICCommodity C  on C.intCommodityId = CH.intCommodityId
WHERE Row_Num = 1
AND dtmTransactionDate between @dtmFromTransactionDate and @dtmToTransactionDate
AND CH.intContractTypeId = @intContractTypeId --1 = Purchase, 2 = Sale
AND CH.intCommodityId  IN (SELECT com.intCommodityId FROM @Commodity com)
ORDER BY dtmTransactionDate


SELECT *
INTO #tblFinalContractBalance
FROM (
	
	SELECT 
			 intRowNum = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmTransactionDate ASC))
			,dtmTransactionDate
			,strCommodityCode
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
	,dblCashBegBalance  NUMERIC(18,6)
	,dblCashEndBalance  NUMERIC(18,6)
	,dblBasisBegBalForSummary NUMERIC(18,6)
	,dblBasisEndBalForSummary NUMERIC(18,6)
	,dblPricedBegBalForSummary NUMERIC(18,6)
	,dblPricedEndBalForSummary NUMERIC(18,6)
	,dblDPBegBalForSummary NUMERIC(18,6)
	,dblDPEndBalForSummary NUMERIC(18,6)
	,dblCashBegBalForSummary NUMERIC(18,6)
	,dblCashEndBalForSummary NUMERIC(18,6)
)

Declare @intRowNum int
	,@dtmCurDate DATE
	,@dtmPrevDate DATE
	,@dblBasisBalanceForward  NUMERIC(18,6)
	,@dblPricedBalanceForward  NUMERIC(18,6)
	,@dblDPBalanceForward  NUMERIC(18,6)
	,@dblCashBalanceForward  NUMERIC(18,6)
	,@dblBasisBegBalForSummary NUMERIC(18,6)
	,@dblPricedBegBalForSummary NUMERIC(18,6)
	,@dblDPBegBalForSummary NUMERIC(18,6)
	,@dblCashBegBalForSummary NUMERIC(18,6)


select @dblBasisBalanceForward = isnull(sum(dblQuantity) ,0)
from tblCTContractBalance where dtmEndDate = @dtmContractBeginBalance
and intCommodityId  IN (SELECT intCommodityId FROM @Commodity)
and intContractTypeId = @intContractTypeId
and strPricingTypeDesc = 'Basis'

select @dblPricedBalanceForward = isnull(sum(dblQuantity) ,0)
from tblCTContractBalance where dtmEndDate = @dtmContractBeginBalance
and intCommodityId  IN (SELECT intCommodityId FROM @Commodity)
and intContractTypeId = @intContractTypeId
and strPricingTypeDesc = 'Priced'

select @dblDPBalanceForward = isnull(sum(dblQuantity) ,0)
from tblCTContractBalance where dtmEndDate = @dtmContractBeginBalance
and intCommodityId  IN (SELECT intCommodityId FROM @Commodity)
and intContractTypeId = @intContractTypeId
and strPricingTypeDesc = 'DP (Priced Later)'

select @dblCashBalanceForward = isnull(sum(dblQuantity) ,0)
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
		,@dblDPBalanceForward + ( dblDPIncrease - dblDPIncrease)  
		,@dblCashBalanceForward
		,@dblCashBalanceForward + ( dblCashIncrease - dblCashDecrease)  
	from #tblFinalContractBalance 
	WHERE intRowNum = @intRowNum
	
	select 
		@dblBasisBalanceForward = dblBasisEndBalance 
		,@dblPricedBalanceForward = dblPricedEndBalance 
		,@dblDPBalanceForward = dblDPEndBalance
		,@dblCashBalanceForward = dblCashEndBalance
	from @tblRunningBalance where intRowNum = @intRowNum
	
	IF @dtmCurDate <> @dtmPrevDate OR @dtmPrevDate IS NULL
	BEGIN
		SELECT 
			@dblBasisBegBalForSummary =  dblBasisBegBalance
			,@dblPricedBegBalForSummary =  dblPricedBegBalance
			,@dblDPBegBalForSummary =  dblDPBegBalance
			,@dblCashBegBalForSummary =  dblCashBegBalance
		FROM @tblRunningBalance
		WHERE dtmDate = @dtmCurDate
			
		UPDATE @tblRunningBalance 
		SET dblBasisBegBalForSummary = @dblBasisBegBalForSummary
			,dblPricedBegBalForSummary = @dblPricedBegBalForSummary
			,dblDPBegBalForSummary = @dblDPBegBalForSummary
			,dblCashBegBalForSummary = @dblCashBegBalForSummary
			--
			,dblBasisEndBalForSummary = @dblBasisBalanceForward
			,dblPricedEndBalForSummary = @dblPricedBalanceForward
			,dblDPEndBalForSummary = @dblDPBalanceForward
			,dblCashEndBalForSummary = @dblCashBalanceForward
		WHERE dtmDate = @dtmCurDate

	
	END

	IF @dtmCurDate = @dtmPrevDate
	BEGIN
		UPDATE @tblRunningBalance 
		SET dblBasisEndBalForSummary = @dblBasisBalanceForward
			,dblPricedEndBalForSummary = @dblPricedBalanceForward
			,dblDPEndBalForSummary = @dblDPBalanceForward
			,dblCashEndBalForSummary = @dblCashBalanceForward
		WHERE dtmDate = @dtmCurDate

		UPDATE @tblRunningBalance 
		SET dblBasisBegBalForSummary = @dblBasisBegBalForSummary
			,dblPricedBegBalForSummary = @dblPricedBegBalForSummary
			,dblDPBegBalForSummary = @dblDPBegBalForSummary
			,dblCashBegBalForSummary = @dblCashBegBalForSummary
		WHERE dtmDate = @dtmCurDate
		AND dblBasisBegBalForSummary IS NULL
		AND dblPricedBegBalForSummary IS NULL
		AND dblDPBegBalForSummary IS NULL
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
	,dblCashBegBalance
	,dblCashIncrease
	,dblCashDecrease
	,dblCashEndBalance
	,strContractSeq 
	,intContractHeaderId
	,intContractDetailId
	,dblBasisBegBalForSummary
	,dblBasisEndBalForSummary
	,dblPricedBegBalForSummary 
	,dblPricedEndBalForSummary 
	,dblDPBegBalForSummary 
	,dblDPEndBalForSummary
	,dblCashBegBalForSummary 
	,dblCashEndBalForSummary
from #tblFinalContractBalance cb
full join @tblRunningBalance rb on rb.intRowNum = cb.intRowNum
order by cb.dtmTransactionDate



DROP TABLE #tblContractBalance
DROP TABLE #tblFinalContractBalance 
DROP TABLE #tempDateRange


END
