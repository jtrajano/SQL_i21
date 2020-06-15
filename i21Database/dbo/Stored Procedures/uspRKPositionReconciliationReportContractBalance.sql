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

		--select @dtmContractBeginBalance = DATEADD(day, -1, convert(date, @dtmFromTransactionDate))


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

--Get raw Contract Balance
SELECT * INTO #tblRawContractBalance
FROM dbo.fnRKGetBucketContractBalance(@dtmToTransactionDate,NULL,NULL)

DECLARE @intCommodityId INT
		,@intCommodityUnitMeasureId INT

DECLARE @tblContractBalance AS TABLE (
	strHeaderType NVARCHAR(100)
	,dtmTransactionDate DATETIME
	,strCommodityCode NVARCHAR(100)
	,intContractHeaderId INT
	,intContractDetailId INT
	,strContractNumber NVARCHAR(100)
	,intContractSeq INT
	,dblIncrease NUMERIC(18,6)
	,dblDecrease NUMERIC(18,6)
	,strPricingType NVARCHAR(100)
	,strTransactionType  NVARCHAR(100)
	,intTransactionId INT
	,strTransactionId NVARCHAR(100)
	,intOrderBy INT
)

WHILE EXISTS(SELECT TOP 1 * FROM #tempCommodity)
BEGIN

	SELECT @intCommodityId = intCommodityId FROM #tempCommodity

	SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = @intCommodityId AND ysnDefault = 1 AND ysnStockUnit = 1

	INSERT INTO @tblContractBalance(
		strHeaderType 
		,dtmTransactionDate
		,strCommodityCode 
		,intContractHeaderId 
		,intContractDetailId
		,strContractNumber 
		,intContractSeq 
		,dblIncrease 
		,dblDecrease
		,strPricingType 
		,strTransactionType  
		,intTransactionId 
		,strTransactionId 
		,intOrderBy 
	)
	SELECT DISTINCT
		strHeaderType = @strContractType + ' Contract Balance' 
		,dtmTransactionDate = CONVERT(DATETIME, CONVERT(VARCHAR(10),t.dtmTransactionDate, 110), 110)
		,t.strCommodityCode
		,t.intContractHeaderId
		,t.intContractDetailId
		,t.strContractNumber
		,t.intContractSeq
		,dblIncrease = CASE WHEN  dbo.fnCTConvertQuantityToTargetCommodityUOM(t.intQtyUOMId, @intCommodityUnitMeasureId, t.dblQty) > 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(t.intQtyUOMId, @intCommodityUnitMeasureId, t.dblQty) ELSE 0 END
		,dblDecrease = CASE WHEN dbo.fnCTConvertQuantityToTargetCommodityUOM(t.intQtyUOMId, @intCommodityUnitMeasureId, t.dblQty) < 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(t.intQtyUOMId, @intCommodityUnitMeasureId, t.dblQty) * -1 ELSE 0 END
		,t.strPricingType
		,strTransactionType = t.strTransactionReference
		,intTransactionId = t.intTransactionReferenceId
		,strTransactionId = t.strTransactionReferenceNo
		,intOrderBy = intContractBalanceLogId
	FROM #tblRawContractBalance t
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10),t.dtmTransactionDate, 110), 110) between @dtmFromTransactionDate and @dtmToTransactionDate
	AND t.intContractTypeId = @intContractTypeId --1 = Purchase, 2 = Sale
	AND t.intCommodityId = @intCommodityId
	ORDER BY intContractBalanceLogId

	DELETE FROM #tempCommodity WHERE intCommodityId = @intCommodityId
END

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
		FROM @tblContractBalance
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


select @dblBasisBalanceForward = isnull(sum(dblQty) ,0)
from #tblRawContractBalance where dtmTransactionDate < @dtmFromTransactionDate
and intCommodityId  IN (SELECT intCommodityId FROM @Commodity)
and intContractTypeId = @intContractTypeId
and strPricingType = 'Basis'

select @dblPricedBalanceForward = isnull(sum(dblQty) ,0)
from #tblRawContractBalance where dtmTransactionDate < @dtmFromTransactionDate
and intCommodityId  IN (SELECT intCommodityId FROM @Commodity)
and intContractTypeId = @intContractTypeId
and strPricingType = 'Priced'

select @dblDPBalanceForward = isnull(sum(dblQty) ,0)
from #tblRawContractBalance where dtmTransactionDate < @dtmFromTransactionDate
and intCommodityId  IN (SELECT intCommodityId FROM @Commodity)
and intContractTypeId = @intContractTypeId
and strPricingType = 'DP (Priced Later)'

select @dblHTABalanceForward = isnull(sum(dblQty) ,0)
from #tblRawContractBalance where dtmTransactionDate < @dtmFromTransactionDate
and intCommodityId  IN (SELECT intCommodityId FROM @Commodity)
and intContractTypeId = @intContractTypeId
and strPricingType = 'HTA'

select @dblCashBalanceForward = isnull(sum(dblQty) ,0)
from #tblRawContractBalance where dtmTransactionDate < @dtmFromTransactionDate
and intCommodityId  IN (SELECT intCommodityId FROM @Commodity)
and intContractTypeId = @intContractTypeId
and strPricingType = 'Cash'

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
DROP TABLE #tblRawContractBalance
DROP TABLE #tblFinalContractBalance 
DROP TABLE #tempDateRange
DROP TABLE #tempCommodity


END
