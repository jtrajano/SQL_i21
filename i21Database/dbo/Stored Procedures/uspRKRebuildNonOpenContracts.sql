CREATE PROCEDURE uspRKRebuildNonOpenContracts 
	@intMonthThreshold INT = 3
AS

BEGIN
	DECLARE @dtmRebuildEndDate DATETIME = GETDATE() -- REBUILD END DATE
	DECLARE @dtmRebuildStartDate DATETIME = DATEADD(MM, -@intMonthThreshold, @dtmRebuildEndDate) -- REBUILD START DATE
	DECLARE @strRebuildCommodityCode NVARCHAR(100) = NULL -- NULL IF ALL COMMODITY. ADD IF WANT FOR SPECIFIC COMMODITY ex. 'CWRS'

	-- Format as date only
	SELECT @dtmRebuildStartDate = DATEADD(dd, 0, DATEDIFF(dd, 0, @dtmRebuildStartDate))
	SELECT @dtmRebuildEndDate = DATEADD(dd, 0, DATEDIFF(dd, 0, @dtmRebuildEndDate)) 

	--========== GET CONTRACTS WITHOUT CONTRACT BALANCE LOGS WITHIN THRESHOLD ====================
	
	IF OBJECT_ID('tempdb..#tmpNonOpenContractsToRebuild') IS NOT NULL
 		DROP TABLE #tmpNonOpenContractsToRebuild
	IF OBJECT_ID('tempdb..#tempContracts') IS NOT NULL
 		DROP TABLE #tempContracts
	IF OBJECT_ID('tempdb..#tempOrigContract') IS NOT NULL
 		DROP TABLE #tempOrigContract

	SELECT CH.strContractNumber
		, CD.intContractSeq
		, CD.dtmCreated
		, CD.intContractHeaderId
		, CD.intContractDetailId
	INTO #tmpNonOpenContractsToRebuild
	FROM tblCTContractDetail CD 
	JOIN tblCTContractHeader CH
		ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblICCommodity commodity
		ON commodity.intCommodityId = CH.intCommodityId
	WHERE DATEADD(dd, 0, DATEDIFF(dd, 0, CD.dtmCreated)) >= @dtmRebuildStartDate
	AND DATEADD(dd, 0, DATEDIFF(dd, 0, CD.dtmCreated)) <= @dtmRebuildEndDate
	AND NOT EXISTS (SELECT TOP 1 '' FROM tblCTContractBalanceLog cbLog WHERE cbLog.intContractDetailId = CD.intContractDetailId)
	AND commodity.strCommodityCode = CASE WHEN ISNULL(@strRebuildCommodityCode, '') = '' 
										THEN commodity.strCommodityCode
										ELSE @strRebuildCommodityCode
										END
	ORDER BY CD.dtmCreated
	
	-- ===================== PROCEED ON REBUILD ===========================

	-- REBUILD SPECIFIC CONTRACTS
	DECLARE @cbLog AS CTContractBalanceLog

	SELECT
		  CH.intContractHeaderId
		, CD.intContractDetailId
		, CH.dtmContractDate
		, CH.strContractNumber
		, CD.intContractSeq
		, CH.intContractTypeId
		, CH.intPricingTypeId as intHeaderPricingTypeId
		, CD.intPricingTypeId
		, dblQtyBalance = CD.dblBalance
		, CH.ysnLoad
		, CH.dblQuantityPerLoad
		, CH.intCommodityId
		, C.strCommodityCode
		, CD.intItemId
		, CD.intCompanyLocationId
		, CD.intFutureMarketId 
		, CD.intFutureMonthId 
		, CD.dtmStartDate 
		, CD.dtmEndDate 
		, intQtyUOMId = CUM.intCommodityUnitMeasureId
		, CD.dblFutures
		, CD.dblBasis
		, CD.intBasisUOMId 
		, CD.intBasisCurrencyId 
		, intPriceUOMId  = CD.intPriceItemUOMId
		, CD.intContractStatusId 
		, CD.intBookId 
		, CD.intSubBookId 
		, intUserId = CD.intCreatedById
	INTO #tempContracts
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
	INNER JOIN tblICCommodity C ON C.intCommodityId = CH.intCommodityId
	INNER JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = CD.intItemUOMId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityId = CH.intCommodityId AND CUM.intUnitMeasureId = IUOM.intUnitMeasureId
	WHERE dtmContractDate between '01/01/1900' and getdate()
	and intContractDetailId IN (SELECT intContractDetailId FROM #tmpNonOpenContractsToRebuild)


	select * into #tempOrigContract from #tempContracts


	declare @intContractHeaderId int
			,@intContractDetailId int
			,@intContractTypeId int
			,@strContractNumber NVARCHAR(100)
			,@intContractSeq int
			,@intHeaderPricingType INT
			,@intPricingTypeId INT
			,@ysnLoad BIT
			,@dblQuantityPerLoad numeric(18,6)
			,@intCommodityId int
			,@strCommodityCode NVARCHAR(100)
			,@intItemId int
			,@intEntityId int
			,@intLocationId int
			,@intFutureMarketId int
			,@intFutureMonthId int
			,@dtmStartDate datetime
			,@dtmEndDate datetime
			,@intQtyUOMId int
			,@dblFutures numeric(18,6)
			,@dblBasis numeric(18,6)
			,@intBasisUOMId int
			,@intBasisCurrencyId int
			,@intPriceUOMId int
			,@intContractStatusId int
			,@intBookId int
			,@intSubBookId int
			,@intUserId int


	declare @tblContractBalance as table (
			intId int identity(1,1)
			,dtmTransactionDate datetime
			,dtmCreatedDate datetime
			,strTransactionType nvarchar(50)
			,strTransactionReference nvarchar(50)
			,intTransactionReferenceId int
			,strTransactionReferenceNo nvarchar(50)
			,strContractNumber nvarchar(50)
			,intContractSeq int
			,intContractHeaderId int
			,intContractDetailId int
			,intContractTypeId int
			,intEntityId int
			,intCommodityId int
			,strCommodityCode nvarchar(50)
			,intItemId int
			,intLocationId int
			,intPricingTypeId int
			,strPricingType nvarchar(50)
			,intFutureMarketId int
			,intFutureMonthId int
			,dtmStartDate datetime
			,dtmEndDate datetime
			,dblQuantity numeric(18,6)
			,intQtyUOMId int
			,dblFutures numeric(18,6)
			,dblBasis numeric(18,6)
			,intBasisUOMId int
			,intBasisCurrencyId int
			,intPriceUOMId int
			,intContractStatusId int
			,intBookId int
			,intSubBookId int
			,strNotes nvarchar(50)
			,intUserId int
		)


	declare @tblCTSequenceHistory as table (
		dtmHistoryCreated datetime
		,strContractNumber NVARCHAR(100)
		,intContractSeq int
		,intContractTypeId int
		,dblQuantity numeric(18,6)
		,strTransactionReference nvarchar(50)
		,intContractHeaderId int
		,intContractDetailId int
		,intPricingTypeId int
		,intTransactionReferenceId int
		,strTransactionReferenceNo nvarchar(50)
		,intCommodityId int
		,strCommodityCode NVARCHAR(100)
		,intItemId int
		,intEntityId int
		,intLocationId int
		,intFutureMarketId int
		,intFutureMonthId int
		,dtmStartDate datetime
		,dtmEndDate datetime
		,intQtyUOMId int
		,dblFutures numeric(18,6)
		,dblBasis numeric(18,6)
		,intBasisUOMId int
		,intBasisCurrencyId int
		,intPriceUOMId int
		,intContractStatusId int
		,intBookId int
		,intSubBookId int
		,intUserId int

	)


	WHILE EXISTS (SELECT TOP 1 1 FROM #tempContracts)
	BEGIN
	
	
		SELECT TOP 1 
			@intContractHeaderId = intContractHeaderId
			,@intContractDetailId = intContractDetailId 
			,@intContractTypeId = intContractTypeId
			,@strContractNumber = strContractNumber
			,@intContractSeq = intContractSeq
			,@intHeaderPricingType = intHeaderPricingTypeId
			,@intPricingTypeId = intPricingTypeId
			,@ysnLoad = ysnLoad
			,@dblQuantityPerLoad = dblQuantityPerLoad
			,@intCommodityId = intCommodityId
			,@strCommodityCode = strCommodityCode
			,@intItemId  = intItemId
			,@intLocationId = intCompanyLocationId
			,@intFutureMarketId  = intFutureMarketId
			,@intFutureMonthId = intFutureMonthId
			,@dtmStartDate = dtmStartDate
			,@dtmEndDate = dtmEndDate
			,@intQtyUOMId = intQtyUOMId
			,@dblFutures =  dblFutures
			,@dblBasis = dblBasis
			,@intBasisUOMId = intBasisUOMId
			,@intBasisCurrencyId = intBasisCurrencyId
			,@intPriceUOMId =  intPriceUOMId
			,@intContractStatusId = intContractStatusId
			,@intBookId = intBookId
			,@intSubBookId = intSubBookId
			,@intUserId = intUserId
		FROM #tempContracts 
		
		IF OBJECT_ID('tempdb..#tmpCTSequenceHistory') IS NOT NULL
			DROP TABLE #tmpCTSequenceHistory

		SELECT ROW_NUMBER() OVER (ORDER BY intSequenceHistoryId) as rowNum, 
			* 
		INTO	#tmpCTSequenceHistory
		FROM	tblCTSequenceHistory ctsha
		WHERE	ctsha.intContractDetailId = @intContractDetailId

		insert into @tblCTSequenceHistory (
			dtmHistoryCreated
			,strContractNumber
			,intContractSeq
			,intContractTypeId
			,dblQuantity
			,strTransactionReference
			,intContractHeaderId
			,intContractDetailId
			,intPricingTypeId
			,intTransactionReferenceId
			,strTransactionReferenceNo
			,intCommodityId
			,strCommodityCode
			,intItemId
			,intEntityId
			,intLocationId
			,intFutureMarketId 
			,intFutureMonthId 
			,dtmStartDate 
			,dtmEndDate 
			,intQtyUOMId
			,dblFutures
			,dblBasis
			,intBasisUOMId 
			,intBasisCurrencyId 
			,intPriceUOMId 
			,intContractStatusId 
			,intBookId 
			,intSubBookId 
			,intUserId
		)
	
		SELECT
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblBalance  
			, strTransactionReference = 'Contract Sequence Begin Balance'
			, @intContractHeaderId
			, @intContractDetailId
			, intPricingTypeId = CASE WHEN @intHeaderPricingType = 1 AND @intPricingTypeId = 2 THEN 2 ELSE intPricingTypeId END --Special case where in the header is Priced but the sequence is Basis
			, intTransactionReferenceId = intContractHeaderId
			, strTransactionReferenceNo = strContractNumber + '-' + cast(intContractSeq as nvarchar(10))
			, @intCommodityId
			, @strCommodityCode
			, @intItemId
			, intEntityId
			, @intLocationId
			, @intFutureMarketId 
			, @intFutureMonthId 
			, @dtmStartDate 
			, @dtmEndDate 
			, @intQtyUOMId
			, @dblFutures
			, @dblBasis
			, @intBasisUOMId 
			, @intBasisCurrencyId 
			, @intPriceUOMId 
			, @intContractStatusId 
			, @intBookId 
			, @intSubBookId
			, @intUserId 
		FROM 
		(
			SELECT TOP 1 *
			FROM tblCTSequenceHistory 
			WHERE intContractDetailId = @intContractDetailId
			ORDER BY dtmHistoryCreated
		) t

		union  all
		select
			SH.dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblBalance  = SH.dblBalance - SH.dblOldBalance
			, strTransactionReference = 'Contract Sequence Balance Change'
			, @intContractHeaderId
			, @intContractDetailId
			, intPricingTypeId  = SH.intPricingTypeId --  CASE WHEN @intHeaderPricingType = 2 AND @intPricingTypeId = 1 THEN 2 ELSE SH.intPricingTypeId END
			, intTransactionReferenceId = SH.intContractHeaderId
			, strTransactionReferenceNo = SH.strContractNumber + '-' + cast(SH.intContractSeq as nvarchar(10))
			, @intCommodityId
			, @strCommodityCode
			, @intItemId
			, SH.intEntityId
			, @intLocationId
			, @intFutureMarketId 
			, @intFutureMonthId 
			, @dtmStartDate 
			, @dtmEndDate 
			, @intQtyUOMId
			, @dblFutures
			, @dblBasis
			, @intBasisUOMId 
			, @intBasisCurrencyId 
			, @intPriceUOMId 
			, @intContractStatusId 
			, @intBookId 
			, @intSubBookId
			, @intUserId 
		from tblCTSequenceHistory SH
		LEFT JOIN vyuCTSequenceUsageHistory SUH
			ON SUH.intSequenceUsageHistoryId = SH.intSequenceUsageHistoryId
			AND SUH.strFieldName = 'Balance'
			AND SUH.ysnDeleted = 0
			AND SUH.intContractDetailId = @intContractDetailId
		WHERE SH.intContractDetailId = @intContractDetailId
		--and SH.ysnQtyChange = 1
		and SH.ysnBalanceChange = 1
		and SH.intPricingTypeId <> 5
		AND SUH.intSequenceUsageHistoryId IS NULL

		union all
		select 
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblTransactionQuantity =  CASE WHEN @ysnLoad = 1 THEN SUH.dblTransactionQuantity * @dblQuantityPerLoad ELSE SUH.dblTransactionQuantity END
			, SUH.strScreenName  
			, @intContractHeaderId
			, @intContractDetailId
			, intPricingTypeId = CASE WHEN SH.strPricingStatus = 'Partially Priced' THEN 1 ELSE SH.intPricingTypeId END
			, intTransactionReferenceId = SUH.intExternalHeaderId
			, strTransactionReferenceNo = SUH.strNumber
			, @intCommodityId
			, @strCommodityCode
			, @intItemId
			, intEntityId
			, @intLocationId
			, @intFutureMarketId 
			, @intFutureMonthId 
			, @dtmStartDate 
			, @dtmEndDate 
			, @intQtyUOMId
			, @dblFutures
			, @dblBasis
			, @intBasisUOMId 
			, @intBasisCurrencyId 
			, @intPriceUOMId 
			, @intContractStatusId 
			, @intBookId 
			, @intSubBookId
			, SU.intUserId
		from vyuCTSequenceUsageHistory SUH
		inner join tblCTSequenceHistory SH on SH.intSequenceUsageHistoryId = SUH.intSequenceUsageHistoryId
		inner join tblCTSequenceUsageHistory SU on SU.intSequenceUsageHistoryId = SUH.intSequenceUsageHistoryId
		where ysnDeleted = 0
		and SUH.strFieldName = 'Balance'
		and SUH.intContractDetailId = @intContractDetailId
	
		union all
		select 
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblTransactionQuantity =  CASE WHEN @ysnLoad = 1 THEN SUH.dblTransactionQuantity * @dblQuantityPerLoad ELSE SUH.dblTransactionQuantity END
			, SUH.strScreenName  
			, @intContractHeaderId
			, @intContractDetailId
			, intPricingTypeId = CASE WHEN SH.strPricingStatus = 'Partially Priced' THEN 1 ELSE SH.intPricingTypeId END
			, intTransactionReferenceId = SUH.intExternalHeaderId
			, strTransactionReferenceNo = SUH.strNumber
			, @intCommodityId
			, @strCommodityCode
			, @intItemId
			, intEntityId
			, @intLocationId
			, @intFutureMarketId 
			, @intFutureMonthId 
			, @dtmStartDate 
			, @dtmEndDate 
			, @intQtyUOMId
			, @dblFutures
			, @dblBasis
			, @intBasisUOMId 
			, @intBasisCurrencyId 
			, @intPriceUOMId 
			, @intContractStatusId 
			, @intBookId 
			, @intSubBookId
			, SU.intUserId
		from vyuCTSequenceUsageHistory SUH
		inner join tblCTSequenceHistory SH on SH.intSequenceUsageHistoryId = SUH.intSequenceUsageHistoryId
		inner join tblCTSequenceUsageHistory SU on SU.intSequenceUsageHistoryId = SUH.intSequenceUsageHistoryId
		where ysnDeleted = 1
		and SUH.strFieldName = 'Balance'
		and SUH.intContractDetailId = @intContractDetailId
		and SUH.strScreenName IN ('Settle Storage', 'Transfer Storage')

		union all
		select
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblBalance  = CASE WHEN strPricingType = 'Priced' THEN dblQtyPriced * -1 ELSE dblQtyUnpriced  END 
			, strTransactionReference = 'HTA - Price Fixation'
			, @intContractHeaderId
			, @intContractDetailId
			, @intHeaderPricingType
			, intTransactionReferenceId = intContractHeaderId
			, strTransactionReferenceNo = strContractNumber + '-' + cast(intContractSeq as nvarchar(10))
			, @intCommodityId
			, @strCommodityCode
			, @intItemId
			, intEntityId
			, @intLocationId
			, @intFutureMarketId 
			, @intFutureMonthId 
			, @dtmStartDate 
			, @dtmEndDate 
			, @intQtyUOMId
			, @dblFutures
			, @dblBasis
			, @intBasisUOMId 
			, @intBasisCurrencyId 
			, @intPriceUOMId 
			, @intContractStatusId 
			, @intBookId 
			, @intSubBookId
			, @intUserId 
		from tblCTSequenceHistory 
		where intContractDetailId = @intContractDetailId
		and @intHeaderPricingType = 3
		and ysnBasisChange = 1
		and ysnCashPriceChange = 1
		and strPricingType IN ('Priced','HTA')

		union all --Counter entry when price fixing an HTA
		select
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblBalance  =  CASE WHEN strPricingType = 'Priced' THEN dblQtyPriced ELSE dblQtyUnpriced * -1 END 
			, strTransactionReference = 'HTA - Price Fixation'
			, @intContractHeaderId
			, @intContractDetailId
			, 1 --Priced
			, intTransactionReferenceId = intContractHeaderId
			, strTransactionReferenceNo = strContractNumber + '-' + cast(intContractSeq as nvarchar(10))
			, @intCommodityId
			, @strCommodityCode
			, @intItemId
			, intEntityId
			, @intLocationId
			, @intFutureMarketId 
			, @intFutureMonthId 
			, @dtmStartDate 
			, @dtmEndDate 
			, @intQtyUOMId
			, @dblFutures
			, @dblBasis
			, @intBasisUOMId 
			, @intBasisCurrencyId 
			, @intPriceUOMId 
			, @intContractStatusId 
			, @intBookId 
			, @intSubBookId
			, @intUserId 
		from tblCTSequenceHistory 
		where intContractDetailId = @intContractDetailId
		and @intHeaderPricingType = 3
		and ysnBasisChange = 1
		and ysnCashPriceChange = 1
		and strPricingType IN ('Priced','HTA')
			
		union all  -- Header is Basis (Price Fixation of Basis thru Contract Pricing Screen or Updating Sequence Pricing Type to 'Priced')
		select 
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblQuantity = CASE WHEN dblCumulativeBalance > dblActualPriceFixation OR dblCumulativeBalance <= dblCumulativeQtyPriced THEN dblActualPriceFixation ELSE dblActualPriceFixation - dblCumulativeBalance END
			, strTransactionReference = CASE WHEN ISNULL(P.intPriceFixationId, 0) = 0 
											THEN 'Basis - Price Fixation'	
											ELSE 'Price Fixation' 
											END
			, @intContractHeaderId
			, @intContractDetailId
			, 1
			, intTransactionReferenceId = CASE WHEN ISNULL(P.intPriceFixationId, 0) = 0 
											THEN SH.intContractHeaderId 
											ELSE P.intPriceFixationId END
			, strTransactionReferenceNo = CASE WHEN ISNULL(P.intPriceFixationId, 0) = 0 
											THEN SH.strContractNumber + '-' + cast(SH.intContractSeq as nvarchar(10))
											ELSE P.strPriceContractNo END
			, @intCommodityId
			, @strCommodityCode
			, @intItemId
			, intEntityId
			, @intLocationId
			, @intFutureMarketId 
			, @intFutureMonthId 
			, @dtmStartDate 
			, @dtmEndDate 
			, @intQtyUOMId
			, @dblFutures
			, @dblBasis
			, @intBasisUOMId 
			, @intBasisCurrencyId 
			, @intPriceUOMId 
			, @intContractStatusId 
			, @intBookId 
			, @intSubBookId
			, intUserId = CASE WHEN ISNULL(P.intPriceFixationId, 0) = 0 THEN @intUserId ELSE P.intUserId END
		from  (
			SELECT ysnIsPricing = CASE WHEN origctsh.dblQtyPriced <> lagctsh.dblQtyPriced THEN 1 ELSE 0 END
				,dblActualPriceFixation = origctsh.dblQtyPriced - lagctsh.dblQtyPriced
				,dblCumulativeBalance =  origctsh.dblQuantity - origctsh.dblBalance
				,dblCumulativeQtyPriced = lagctsh.dblQtyPriced
				,intLagPricingTypeId = lagctsh.intPricingTypeId
				,origctsh.* 
			FROM #tmpCTSequenceHistory origctsh
			OUTER APPLY 
			(
				SELECT TOP 1 * FROM #tmpCTSequenceHistory ictsh
				WHERE ictsh.rowNum = origctsh.rowNum - 1
			) lagctsh
		) SH 
		OUTER APPLY(
			select top 1 PF.intPriceFixationId, PC.strPriceContractNo, intUserId from tblCTPriceFixation PF
			inner join tblCTPriceContract PC ON PC.intPriceContractId = PF.intPriceContractId
			where intContractHeaderId = @intContractHeaderId and intContractDetailId = @intContractDetailId
		) P 
		LEFT JOIN vyuCTSequenceUsageHistory SUH
			ON SUH.intSequenceUsageHistoryId = SH.intSequenceUsageHistoryId
			AND SUH.strFieldName = 'Balance'
			AND SUH.ysnDeleted = 0
			AND SUH.intContractDetailId = @intContractDetailId
		WHERE SH.intContractDetailId = @intContractDetailId 
		AND @intHeaderPricingType = 2
		AND SUH.intSequenceUsageHistoryId IS NULL
		AND (	(ISNULL(P.intPriceFixationId, 0) <> 0 AND SH.ysnIsPricing = 1 AND SH.intLagPricingTypeId <> 1)
				OR
					(ISNULL(P.intPriceFixationId, 0) = 0
					AND SH.ysnFuturesChange = 1
					AND SH.ysnCashPriceChange = 1
					AND SH.strPricingType IN ('Priced','Basis')
					)
				)

		union all -- Counter entry when price fixing a Basis (Price Fixation of Basis thru Contract Pricing Screen or Updating Sequence Pricing Type to 'Priced')
		select 
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblQuantity = CASE WHEN dblCumulativeBalance > dblActualPriceFixation OR dblCumulativeBalance <= dblCumulativeQtyPriced THEN dblActualPriceFixation ELSE dblActualPriceFixation - dblCumulativeBalance END * -1
			, strTransactionReference = CASE WHEN ISNULL(P.intPriceFixationId, 0) = 0 
											THEN 'Basis - Price Fixation'
											ELSE 'Price Fixation' 
											END
			, @intContractHeaderId
			, @intContractDetailId
			, 2
			, intTransactionReferenceId = CASE WHEN ISNULL(P.intPriceFixationId, 0) = 0 
											THEN SH.intContractHeaderId 
											ELSE P.intPriceFixationId END
			, strTransactionReferenceNo = CASE WHEN ISNULL(P.intPriceFixationId, 0) = 0 
											THEN SH.strContractNumber + '-' + cast(SH.intContractSeq as nvarchar(10))
											ELSE P.strPriceContractNo END
			, @intCommodityId
			, @strCommodityCode
			, @intItemId
			, intEntityId
			, @intLocationId
			, @intFutureMarketId 
			, @intFutureMonthId 
			, @dtmStartDate 
			, @dtmEndDate 
			, @intQtyUOMId
			, @dblFutures
			, @dblBasis
			, @intBasisUOMId 
			, @intBasisCurrencyId 
			, @intPriceUOMId 
			, @intContractStatusId 
			, @intBookId 
			, @intSubBookId
			, intUserId = CASE WHEN ISNULL(P.intPriceFixationId, 0) = 0 THEN @intUserId ELSE P.intUserId END
		from  (
			SELECT ysnIsPricing = CASE WHEN origctsh.dblQtyPriced <> lagctsh.dblQtyPriced THEN 1 ELSE 0 END
				,dblActualPriceFixation = origctsh.dblQtyPriced - lagctsh.dblQtyPriced
				,dblCumulativeBalance =  origctsh.dblQuantity - origctsh.dblBalance
				,dblCumulativeQtyPriced = lagctsh.dblQtyPriced
				,intLagPricingTypeId = lagctsh.intPricingTypeId
				,origctsh.* 
			FROM #tmpCTSequenceHistory origctsh
			OUTER APPLY 
			(
				SELECT TOP 1 * FROM #tmpCTSequenceHistory ictsh
				WHERE ictsh.rowNum = origctsh.rowNum - 1
			) lagctsh
		) SH 
		OUTER APPLY (
			select top 1  PF.intPriceFixationId, PC.strPriceContractNo, intUserId from tblCTPriceFixation PF
			inner join tblCTPriceContract PC ON PC.intPriceContractId = PF.intPriceContractId
			where intContractHeaderId = @intContractHeaderId and intContractDetailId = @intContractDetailId
		) P 
		LEFT JOIN vyuCTSequenceUsageHistory SUH
			ON SUH.intSequenceUsageHistoryId = SH.intSequenceUsageHistoryId
			AND SUH.strFieldName = 'Balance'
			AND SUH.ysnDeleted = 0
			AND SUH.intContractDetailId = @intContractDetailId
		WHERE SH.intContractDetailId = @intContractDetailId 
		AND @intHeaderPricingType = 2
		AND SUH.intSequenceUsageHistoryId IS NULL
		AND (	(ISNULL(P.intPriceFixationId, 0) <> 0 AND SH.ysnIsPricing = 1 AND SH.intLagPricingTypeId <> 1)
				OR
					(ISNULL(P.intPriceFixationId, 0) = 0
					AND SH.ysnFuturesChange = 1
					AND SH.ysnCashPriceChange = 1
					AND SH.strPricingType IN ('Priced','Basis')
					)
				)

		union all
		select 
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblQuantity = CASE WHEN dblCumulativeBalance > dblActualPriceFixation OR dblCumulativeBalance <= dblCumulativeQtyPriced THEN dblActualPriceFixation ELSE dblActualPriceFixation - dblCumulativeBalance END
			, 'Price Fixation' 
			, @intContractHeaderId
			, @intContractDetailId
			, 1
			, intTransactionReferenceId = P.intPriceFixationId
			, strTransactionReferenceNo = P.strPriceContractNo
			, @intCommodityId
			, @strCommodityCode
			, @intItemId
			, intEntityId
			, @intLocationId
			, @intFutureMarketId 
			, @intFutureMonthId 
			, @dtmStartDate 
			, @dtmEndDate 
			, @intQtyUOMId
			, @dblFutures
			, @dblBasis
			, @intBasisUOMId 
			, @intBasisCurrencyId 
			, @intPriceUOMId 
			, @intContractStatusId 
			, @intBookId 
			, @intSubBookId
			, P.intUserId 
		from  (
			select 
				ysnIsPricing = CASE WHEN dblQtyPriced <> LAG(dblQtyPriced) OVER (ORDER BY intSequenceHistoryId) THEN 1 ELSE 0 END
				,dblActualPriceFixation = dblQtyPriced -  LAG(dblQtyPriced) OVER (ORDER BY intSequenceHistoryId) 
				,dblCumulativeBalance =  dblQuantity - dblBalance
				,dblCumulativeQtyPriced = LAG(dblQtyPriced) OVER (ORDER BY intSequenceHistoryId) 
				,* 
			from tblCTSequenceHistory
			where intContractDetailId = @intContractDetailId
		) SH 
		cross apply (
			select top 1 PF.intPriceFixationId, PC.strPriceContractNo, intUserId from tblCTPriceFixation PF
			inner join tblCTPriceContract PC ON PC.intPriceContractId = PF.intPriceContractId
			where intContractHeaderId = @intContractHeaderId and intContractDetailId = @intContractDetailId
		) P 
		where SH.intContractDetailId = @intContractDetailId AND SH.ysnIsPricing = 1  AND @intHeaderPricingType IN (1)  and strPricingStatus <> 'Unpriced'

		union all  --Counter entry when price fixing a Basis
		select 
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblQuantity = CASE WHEN dblCumulativeBalance > dblActualPriceFixation OR dblCumulativeBalance <= dblCumulativeQtyPriced THEN dblActualPriceFixation ELSE dblActualPriceFixation - dblCumulativeBalance END * -1
			, 'Price Fixation' 
			, @intContractHeaderId
			, @intContractDetailId
			, 2
			, intTransactionReferenceId = P.intPriceFixationId
			, strTransactionReferenceNo = P.strPriceContractNo
			, @intCommodityId
			, @strCommodityCode
			, @intItemId
			, intEntityId
			, @intLocationId
			, @intFutureMarketId 
			, @intFutureMonthId 
			, @dtmStartDate 
			, @dtmEndDate 
			, @intQtyUOMId
			, @dblFutures
			, @dblBasis
			, @intBasisUOMId 
			, @intBasisCurrencyId 
			, @intPriceUOMId 
			, @intContractStatusId 
			, @intBookId 
			, @intSubBookId
			, P.intUserId  
		from  (
			select 
				ysnIsPricing = CASE WHEN dblQtyPriced <> LAG(dblQtyPriced) OVER (ORDER BY intSequenceHistoryId) THEN 1 ELSE 0 END
				,dblActualPriceFixation = dblQtyPriced -  LAG(dblQtyPriced) OVER (ORDER BY intSequenceHistoryId) 
				,dblCumulativeBalance =  dblQuantity - dblBalance
				,dblCumulativeQtyPriced = LAG(dblQtyPriced) OVER (ORDER BY intSequenceHistoryId) 
				,* 
			from tblCTSequenceHistory
			where intContractDetailId = @intContractDetailId
		) SH 
		cross apply (
			select top 1  PF.intPriceFixationId, PC.strPriceContractNo, intUserId from tblCTPriceFixation PF
			inner join tblCTPriceContract PC ON PC.intPriceContractId = PF.intPriceContractId
			where intContractHeaderId = @intContractHeaderId and intContractDetailId = @intContractDetailId
		) P 
		where SH.intContractDetailId = @intContractDetailId AND SH.ysnIsPricing = 1  AND @intHeaderPricingType IN (1) and strPricingStatus <> 'Unpriced'

		union all -- Cancelled and Short Closed Contracts
		SELECT TOP 1
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblBalance  = sh.dblBalance * -1
			, strTransactionReference = 'Updated Contract'
			, @intContractHeaderId
			, @intContractDetailId
			, intPricingTypeId  =  CASE WHEN @intHeaderPricingType = 2 AND @intPricingTypeId = 1 THEN ctd.intPricingTypeId ELSE sh.intPricingTypeId END
			, intTransactionReferenceId = sh.intContractHeaderId
			, strTransactionReferenceNo = strContractNumber + '-' + cast(sh.intContractSeq as nvarchar(10))
			, @intCommodityId
			, @strCommodityCode
			, @intItemId
			, intEntityId
			, @intLocationId
			, @intFutureMarketId 
			, @intFutureMonthId 
			, @dtmStartDate 
			, @dtmEndDate 
			, @intQtyUOMId
			, @dblFutures
			, @dblBasis
			, @intBasisUOMId 
			, @intBasisCurrencyId 
			, @intPriceUOMId 
			, @intContractStatusId 
			, @intBookId 
			, @intSubBookId
			, @intUserId 
		from 
		(	SELECT TOP 1 * 
			FROM tblCTSequenceHistory ctsh
			WHERE ctsh.intContractDetailId = @intContractDetailId
			AND ctsh.intContractStatusId IN (3, 6) -- Cancelled and Short Closed
			AND ctsh.ysnStatusChange = 1
			ORDER BY ctsh.dtmHistoryCreated DESC
		) sh
		JOIN tblCTContractDetail ctd
		ON ctd.intContractDetailId = sh.intContractDetailId

		DELETE FROM #tempContracts WHERE intContractDetailId = @intContractDetailId  

	END

	INSERT INTO @tblContractBalance(
		dtmTransactionDate
		,dtmCreatedDate
		,strTransactionType 
		,strTransactionReference 
		,intTransactionReferenceId
		,strTransactionReferenceNo
		,strContractNumber
		,intContractSeq
		,intContractHeaderId 
		,intContractDetailId 
		,intContractTypeId 
		,intEntityId 
		,intCommodityId 
		,strCommodityCode 
		,intItemId 
		,intLocationId 
		,intPricingTypeId 
		,strPricingType 
		,intFutureMarketId 
		,intFutureMonthId 
		,dtmStartDate 
		,dtmEndDate 
		,dblQuantity
		,intQtyUOMId 
		,dblFutures
		,dblBasis
		,intBasisUOMId 
		,intBasisCurrencyId 
		,intPriceUOMId 
		,intContractStatusId 
		,intBookId 
		,intSubBookId 
		,strNotes
		,intUserId
	)
	select
		dtmTransactionDate = SH.dtmHistoryCreated
		,dtmCreatedDate = SH.dtmHistoryCreated
		,strTransactionType = 'Contract Balance'
		,SH.strTransactionReference
		,SH.intTransactionReferenceId
		,SH.strTransactionReferenceNo
		,SH.strContractNumber
		,SH.intContractSeq
		,SH.intContractHeaderId 
		,SH.intContractDetailId 
		,SH.intContractTypeId 
		,SH.intEntityId 
		,SH.intCommodityId 
		,SH.strCommodityCode 
		,SH.intItemId 
		,SH.intLocationId 
		,SH.intPricingTypeId 
		,PT.strPricingType 
		,SH.intFutureMarketId 
		,SH.intFutureMonthId 
		,SH.dtmStartDate 
		,SH.dtmEndDate 
		,SH.dblQuantity
		,SH.intQtyUOMId
		,SH.dblFutures
		,SH.dblBasis
		,SH.intBasisUOMId 
		,SH.intBasisCurrencyId 
		,SH.intPriceUOMId 
		,SH.intContractStatusId 
		,SH.intBookId 
		,SH.intSubBookId 
		,strNotes = ''
		,SH.intUserId
	from @tblCTSequenceHistory SH
	inner join tblCTPricingType PT on PT.intPricingTypeId = SH.intPricingTypeId
	
	
	INSERT INTO @cbLog (strBatchId
		, dtmTransactionDate
		, strTransactionType
		, strTransactionReference
		, intTransactionReferenceId
		, strTransactionReferenceNo
		, intContractDetailId
		, intContractHeaderId
		, strContractNumber
		, intContractSeq
		, intContractTypeId
		, intEntityId
		, intCommodityId
		, intItemId
		, intLocationId
		, intPricingTypeId
		, intFutureMarketId
		, intFutureMonthId
		, dblBasis
		, dblFutures
		, intQtyUOMId
		, intQtyCurrencyId
		, intBasisUOMId
		, intBasisCurrencyId
		, intPriceUOMId
		, dtmStartDate
		, dtmEndDate
		, dblQty
		, intContractStatusId
		, intBookId
		, intSubBookId
		, strNotes
		, intUserId
		, intActionId)
	SELECT strBatchId = NULL
		, dtmTransactionDate
		, strTransactionType
		, strTransactionReference
		, intTransactionReferenceId
		, strTransactionReferenceNo
		, intContractDetailId
		, intContractHeaderId
		, strContractNumber
		, intContractSeq
		, intContractTypeId
		, intEntityId
		, intCommodityId
		, intItemId
		, intLocationId
		, intPricingTypeId
		, intFutureMarketId
		, intFutureMonthId
		, dblBasis
		, dblFutures
		, intQtyUOMId
		, intQtyCurrencyId = NULL
		, intBasisUOMId
		, intBasisCurrencyId
		, intPriceUOMId
		, dtmStartDate
		, dtmEndDate
		, dblQuantity
		, intContractStatusId
		, intBookId
		, intSubBookId
		, strNotes
		, intUserId
		, intActionId  = 1 --Rebuild 		
	FROM @tblContractBalance

	EXEC uspCTLogContractBalance @cbLog, 1

	DROP TABLE #tempContracts
	DROP TABLE #tempOrigContract
	DROP TABLE #tmpNonOpenContractsToRebuild
END