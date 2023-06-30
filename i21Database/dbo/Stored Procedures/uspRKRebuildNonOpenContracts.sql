CREATE PROCEDURE uspRKRebuildNonOpenContracts 
	  @intMonthThreshold INT = 3
	, @intSpecificContractDetailId INT = NULL
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
	AND NOT EXISTS (SELECT TOP 1 '' 
					FROM tblCTContractBalanceLog cbLog 
					WHERE cbLog.intContractDetailId = CD.intContractDetailId)
	AND commodity.strCommodityCode = CASE WHEN ISNULL(@strRebuildCommodityCode, '') = '' 
										THEN commodity.strCommodityCode
										ELSE @strRebuildCommodityCode
										END
	AND CD.intContractDetailId = ISNULL(@intSpecificContractDetailId, CD.intContractDetailId)
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
		, strContractNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intContractSeq int
		, intContractTypeId int
		, dblQuantity numeric(18,6)
		, strTransactionReference NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intContractHeaderId int
		, intContractDetailId int
		, intPricingTypeId int
		, intTransactionReferenceId int
		, strTransactionReferenceNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intCommodityId int
		, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intItemId int
		, intEntityId int
		, intLocationId int
		, intFutureMarketId int
		, intFutureMonthId int
		, dtmStartDate datetime
		, dtmEndDate datetime
		, intQtyUOMId int
		, dblFutures numeric(18,6)
		, dblBasis numeric(18,6)
		, intBasisUOMId int
		, intBasisCurrencyId int
		, intPriceUOMId int
		, intContractStatusId int
		, intBookId int
		, intSubBookId int
		, intUserId int

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
			, strContractNumber
			, intContractSeq
			, intContractTypeId
			, dblQuantity
			, strTransactionReference
			, intContractHeaderId
			, intContractDetailId
			, intPricingTypeId
			, intTransactionReferenceId
			, strTransactionReferenceNo
			, intCommodityId
			, strCommodityCode
			, intItemId
			, intEntityId
			, intLocationId
			, intFutureMarketId 
			, intFutureMonthId 
			, dtmStartDate 
			, dtmEndDate 
			, intQtyUOMId
			, dblFutures
			, dblBasis
			, intBasisUOMId 
			, intBasisCurrencyId 
			, intPriceUOMId 
			, intContractStatusId 
			, intBookId 
			, intSubBookId 
			, intUserId
		)
	
		SELECT
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblBalance = CASE WHEN t.intContractStatusId = 3 THEN 0 ELSE dblBalance END
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
		
		-- SCENARIO: BALANCE CHANGE WITHOUT PRICING TYPE CHANGE
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
			AND SUH.intContractDetailId = @intContractDetailId
		WHERE SH.intContractDetailId = @intContractDetailId
		--and SH.ysnQtyChange = 1
		and SH.ysnBalanceChange = 1
		and SH.intPricingTypeId <> 5 
		AND SH.intContractStatusId NOT IN (3, 6)-- NOT INCLUDE CANCELLED AND SHORT CLOSE (SEPARATE PART)
		AND SUH.intSequenceUsageHistoryId IS NULL
		AND ((SH.intPricingTypeId = @intHeaderPricingType)
				OR 
				(SH.intPricingTypeId <> @intHeaderPricingType
				AND ISNULL(SH.ysnFuturesChange, 0) <> 1
				AND ISNULL(SH.ysnBasisChange, 0) <> 1)
			)

		-- SCENARIO: BALANCE CHANGE WITH PRICING TYPE CHANGE (WHEN OLD IS UNPRICED AND UPDATED TO PRICED)
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
			, intPricingTypeId  = @intHeaderPricingType 
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
			AND SUH.intContractDetailId = @intContractDetailId
		WHERE SH.intContractDetailId = @intContractDetailId
		--and SH.ysnQtyChange = 1
		and SH.ysnBalanceChange = 1
		and SH.intPricingTypeId <> 5
		AND SH.intContractStatusId NOT IN (3, 6)-- NOT INCLUDE CANCELLED AND SHORT CLOSE (SEPARATE PART)
		AND SUH.intSequenceUsageHistoryId IS NULL
		AND SH.intPricingTypeId <> @intHeaderPricingType
		AND ( (SH.ysnFuturesChange = 1 AND  SH.dblOldFutures IS NULL) 
				OR 
				(SH.ysnBasisChange = 1 AND SH.dblOldBasis IS NULL)
			)
		
		-- SCENARIO: BALANCE CHANGE WITH PRICING TYPE CHANGE (WHEN OLD IS PRICED AND UPDATED TO FUTURES OR BASIS PRICE)
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
			, intPricingTypeId  = @intHeaderPricingType --SH.intPricingTypeId 
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
			AND SUH.intContractDetailId = @intContractDetailId
		WHERE SH.intContractDetailId = @intContractDetailId
		--and SH.ysnQtyChange = 1
		and SH.ysnBalanceChange = 1
		and SH.intPricingTypeId <> 5
		AND SH.intContractStatusId NOT IN (3, 6)-- NOT INCLUDE CANCELLED AND SHORT CLOSE (SEPARATE PART)
		AND SUH.intSequenceUsageHistoryId IS NULL
		AND SH.intPricingTypeId <> @intHeaderPricingType
		AND ( (SH.ysnFuturesChange = 1 AND SH.intPricingTypeId = 1 AND SH.dblOldFutures IS NULL) 
				 OR 
				  (SH.ysnBasisChange = 1 AND SH.intPricingTypeId = 1 AND SH.dblOldBasis IS NULL)
				)
		AND SH.strPricingStatus <> 'Fully Priced'
		--AND ( (SH.ysnFuturesChange = 1 AND SH.intPricingTypeId = 1 AND SH.dblOldFutures IS NOT NULL) 
		--		OR 
		--		(SH.ysnBasisChange = 1 AND SH.intPricingTypeId = 1 AND SH.dblOldBasis IS NOT NULL)
		--	)
		
		-- SCENARIO: BALANCE CHANGE WITHOUT PRICING TYPE CHANGE (WITH SEQUENCE USAGE HISTORY = 'Price Contract')
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
			AND SUH.intContractDetailId = @intContractDetailId
		WHERE SH.intContractDetailId = @intContractDetailId
		and SH.ysnBalanceChange = 1
		and SH.intPricingTypeId <> 5
		AND SUH.intSequenceUsageHistoryId IS NOT NULL
		AND SUH.strScreenName = 'Price Contract'
		AND ((SH.intPricingTypeId = @intHeaderPricingType)
				OR 
				(SH.intPricingTypeId <> @intHeaderPricingType
				AND ISNULL(SH.ysnFuturesChange, 0) <> 1
				AND ISNULL(SH.ysnBasisChange, 0) <> 1)
			)
			
		union all
		select 
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblTransactionQuantity = CASE WHEN SH.intContractStatusId = 6 AND ISNULL(SH.ysnStatusChange, 0) <> 1 THEN 0
											ELSE CASE WHEN @ysnLoad = 1 THEN SUH.dblTransactionQuantity * @dblQuantityPerLoad ELSE SUH.dblTransactionQuantity END
											END
			, SUH.strScreenName  
			, @intContractHeaderId
			, @intContractDetailId
			, intPricingTypeId = CASE WHEN SH.strPricingStatus = 'Partially Priced' 
									AND (SH.dblOldBalance <= SH.dblBalance
										  OR
										 (SH.dblOldBalance > SH.dblBalance AND SH.dblOldBalance > SH.dblQtyUnpriced AND (SH.dblOldBalance - SH.dblBalance) <> SH.dblQtyUnpriced)
										  OR 
										 ((SH.dblQuantity - SH.dblOldBalance) <= SH.dblQtyPriced AND (SH.dblQuantity - SH.dblOldBalance) + (SH.dblOldBalance - SH.dblBalance) <= SH.dblQtyPriced)
										)
							THEN 1 ELSE SH.intPricingTypeId END
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
		AND SH.dblOldBalance IS NOT NULL
		
		union all
		select 
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblTransactionQuantity =  CASE WHEN @ysnLoad = 1 THEN SUH.dblTransactionQuantity * @dblQuantityPerLoad 
							ELSE ((SH.dblOldBalance - SH.dblBalance) - ABS(CASE WHEN SH.dblQtyPriced = 0 THEN 0 ELSE SH.dblQtyPriced - (SH.dblQuantity - SH.dblBalance) END)) * -1 END
			, SUH.strScreenName  
			, @intContractHeaderId
			, @intContractDetailId
			, intPricingTypeId = CASE WHEN SH.strPricingStatus = 'Partially Priced' 
											AND CASE WHEN SH.dblQtyPriced = 0 THEN 0 ELSE SH.dblQtyPriced - (SH.dblQuantity - SH.dblBalance) END < 0 
									THEN 1 ELSE SH.intPricingTypeId END
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
		AND CASE WHEN SH.dblQtyPriced = 0 THEN 0 ELSE SH.dblQtyPriced - (SH.dblQuantity - SH.dblBalance) END < 0
		AND (SH.dblOldBalance - SH.dblBalance) * -1 < (CASE WHEN SH.dblQtyPriced = 0 THEN 0 ELSE SH.dblQtyPriced - (SH.dblQuantity - SH.dblBalance) END) 
		AND SH.dblOldBalance IS NOT NULL

		-- DELETED ORIG QTY
		UNION ALL
		SELECT
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblTransactionQuantity =  CASE WHEN @ysnLoad = 1 
												THEN SUH.dblTransactionQuantity * @dblQuantityPerLoad 
												ELSE SUH.dblTransactionQuantity END 
			, SUH.strScreenName  
			, @intContractHeaderId
			, @intContractDetailId
			, intPricingTypeId = CASE WHEN SH.strPricingStatus = 'Partially Priced' 
									AND (SH.dblOldBalance <= SH.dblBalance
										  OR
										 (SH.dblOldBalance > SH.dblBalance AND SH.dblOldBalance > SH.dblQtyUnpriced AND (SH.dblOldBalance - SH.dblBalance) <> SH.dblQtyUnpriced)
										)
									AND (SH.dblQuantity - SH.dblOldBalance) <= SH.dblQtyPriced
									AND ((SH.dblOldBalance > SH.dblBalance AND (SH.dblQuantity - SH.dblOldBalance) + (SH.dblOldBalance - SH.dblBalance) <= SH.dblQtyPriced)
											OR (SH.dblOldBalance < SH.dblBalance AND (SH.dblQuantity - SH.dblOldBalance) - (SH.dblOldBalance - SH.dblBalance) <= SH.dblQtyPriced)
										)
							THEN 1 ELSE SH.intPricingTypeId END
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
		FROM vyuCTSequenceUsageHistory SUH
		INNER JOIN tblCTSequenceHistory SH on SH.intSequenceUsageHistoryId = SUH.intSequenceUsageHistoryId
		INNER JOIN tblCTSequenceUsageHistory SU on SU.intSequenceUsageHistoryId = SUH.intSequenceUsageHistoryId
		CROSS APPLY (
			SELECT TOP 1 ctUH.intSequenceUsageHistoryId
					, ctUH.dtmTransactionDate
			FROM tblCTSequenceUsageHistory ctUH
			WHERE ctUH.intExternalHeaderId = SUH.intExternalHeaderId
			AND ctUH.intContractDetailId = @intContractDetailId
			AND ctUH.strFieldName = 'Balance'
			AND SUH.dblTransactionQuantity * -1 = ctUH.dblTransactionQuantity
		) negateHistory
		where ysnDeleted = 1
		AND SUH.strFieldName = 'Balance'
		AND SUH.intContractDetailId = @intContractDetailId
		AND ((SH.intContractTypeId = 1 AND SUH.dblTransactionQuantity < 0)
				OR
				(SH.intContractTypeId = 2 AND SUH.dblTransactionQuantity > 0)
			)
		AND SUH.strScreenName NOT IN ('Settle Storage', 'Transfer Storage')
		AND SH.dblOldBalance IS NOT NULL
		--AND (SH.dblBalance - SH.dblOldBalance) <> dblQtyPriced
		AND (	SH.dblOldBalance < SH.dblBalance
				OR
				(SH.dblOldBalance > SH.dblBalance) AND (SH.dblBalance - SH.dblOldBalance) <> dblQtyPriced
		)

		UNION ALL
		-- DELETED NEGATE QTY
		SELECT 
			dtmHistoryCreated = negateHistory.dtmTransactionDate
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblTransactionQuantity = CASE WHEN @ysnLoad = 1 
											THEN SUH.dblTransactionQuantity * @dblQuantityPerLoad 
											ELSE SUH.dblTransactionQuantity END * -1
			, SUH.strScreenName  
			, @intContractHeaderId
			, @intContractDetailId
			, intPricingTypeId = CASE WHEN  (currentPricingType.strPricingStatus = 'Fully Priced' AND currentPricingType.dblQtyPriced <> 0)
											OR
											(	SH.strPricingStatus = 'Partially Priced' 
												AND (	(CASE WHEN SH.dblQtyPriced = 0 THEN 0 ELSE SH.dblQtyPriced - (SH.dblQuantity - SH.dblBalance) END < 0)
														OR
														((SH.dblBalance - SH.dblOldBalance) = SH.dblQtyPriced)
													)
												AND (SH.dblQuantity - SH.dblOldBalance) <= SH.dblQtyPriced
												AND ((SH.dblOldBalance > SH.dblBalance AND (SH.dblQuantity - SH.dblOldBalance) + (SH.dblOldBalance - SH.dblBalance) <= SH.dblQtyPriced)
														OR (SH.dblOldBalance < SH.dblBalance AND (SH.dblQuantity - SH.dblOldBalance) - (SH.dblOldBalance - SH.dblBalance) <= SH.dblQtyPriced)
													)
											)
									THEN 1 
									ELSE currentPricingType.intPricingTypeId END
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
		FROM vyuCTSequenceUsageHistory SUH
		INNER JOIN tblCTSequenceHistory SH on SH.intSequenceUsageHistoryId = SUH.intSequenceUsageHistoryId
		INNER JOIN tblCTSequenceUsageHistory SU on SU.intSequenceUsageHistoryId = SUH.intSequenceUsageHistoryId
		CROSS APPLY (
			SELECT TOP 1 ctUH.intSequenceUsageHistoryId
					, ctUH.dtmTransactionDate
			FROM tblCTSequenceUsageHistory ctUH
			WHERE ctUH.intExternalHeaderId = SUH.intExternalHeaderId
			AND ctUH.intContractDetailId = @intContractDetailId
			AND ctUH.strFieldName = 'Balance'
			AND SUH.dblTransactionQuantity * -1 = ctUH.dblTransactionQuantity
		) negateHistory
		OUTER APPLY (
			SELECT TOP 1 intPricingTypeId
				, strPricingStatus
				, dblQtyPriced
			FROM tblCTSequenceHistory seqHist
			WHERE seqHist.dtmHistoryCreated <= negateHistory.dtmTransactionDate
			AND seqHist.intContractDetailId = @intContractDetailId
			ORDER BY seqHist.dtmHistoryCreated DESC
		) currentPricingType
		where ysnDeleted = 1
		AND SUH.strFieldName = 'Balance'
		AND SUH.intContractDetailId = @intContractDetailId
		AND ((SH.intContractTypeId = 1 AND SUH.dblTransactionQuantity < 0)
				OR
				(SH.intContractTypeId = 2 AND SUH.dblTransactionQuantity > 0)
			)
		AND SUH.strScreenName NOT IN ('Settle Storage', 'Transfer Storage')
		AND SH.dblOldBalance IS NOT NULL
	
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
		AND SH.dblOldBalance IS NOT NULL

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

		-- Header is Unit
		UNION ALL
		SELECT
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblBalance  = CASE WHEN strPricingType = 'Priced' THEN dblQtyPriced * -1 ELSE dblQtyUnpriced  END 
			, strTransactionReference = 'Unit - Price Fixation'
			, @intContractHeaderId
			, @intContractDetailId
			, @intHeaderPricingType
			, intTransactionReferenceId = intContractHeaderId
			, strTransactionReferenceNo = strContractNumber + '-' + CAST(intContractSeq AS NVARCHAR(10))
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
		FROM tblCTSequenceHistory 
		WHERE intContractDetailId = @intContractDetailId
		AND @intHeaderPricingType = 4
		AND ysnFuturesChange = 1
		AND strPricingType IN ('Priced','Unit')

		UNION ALL --Counter entry when price fixing an Unit
		SELECT
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblBalance  =  CASE WHEN strPricingType = 'Priced' THEN dblQtyPriced ELSE dblQtyUnpriced * -1 END 
			, strTransactionReference = 'Unit - Price Fixation'
			, @intContractHeaderId
			, @intContractDetailId
			, 1 --Priced
			, intTransactionReferenceId = intContractHeaderId
			, strTransactionReferenceNo = strContractNumber + '-' + CAST(intContractSeq AS NVARCHAR(10))
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
		FROM tblCTSequenceHistory 
		WHERE intContractDetailId = @intContractDetailId
		AND @intHeaderPricingType = 4
		AND ysnFuturesChange = 1
		AND strPricingType IN ('Priced','Unit')
			
		union all  -- Header is Basis (Price Fixation of Basis thru Contract Pricing Screen or Updating Sequence Pricing Type to 'Priced')
		select 
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblQuantity = CASE WHEN SH.intContractStatusId = 6 THEN 0 -- CANCELLED
								WHEN ( strPricingStatus = 'Partially Priced' AND SH.dblQtyPriced <> 0
											AND dblCumulativeBalance > dblActualPriceFixation AND SH.dblBalance > dblActualPriceFixation AND dblCumulativeBalance = dblQtyPriced
													AND dblCumulativeBalance <= dblCumulativeQtyPriced AND SH.dblBalance = SH.dblQtyUnpriced) 
									THEN 0
								WHEN ( strPricingStatus <> 'Unpriced'
											AND ((dblCumulativeBalance > dblActualPriceFixation AND SH.dblBalance > dblActualPriceFixation AND dblCumulativeBalance <> dblQtyPriced)
													AND dblCumulativeBalance <= dblCumulativeQtyPriced AND (dblLagOldBalance * 2) = dblLagQtyPriced)) 
									THEN 0
								WHEN (SH.intLagPricingTypeId <> SH.intPricingTypeId
									AND SH.strLagPricingStatus = 'Partially Priced'
									AND SH.strPricingStatus = 'Fully Priced'
									AND SH.ysnBalanceChange = 1
									AND SH.ysnCashPriceChange = 1
									AND SH.ysnFuturesChange = 1
									AND SH.ysnStatusChange = 1
									AND SH.dblBalance = 0 
									) THEN 0
								WHEN ( strPricingStatus <> 'Unpriced'
											AND ((dblCumulativeBalance > dblActualPriceFixation AND SH.dblBalance > dblActualPriceFixation AND dblCumulativeBalance <> dblQtyPriced)
													OR dblCumulativeBalance <= dblCumulativeQtyPriced)  
										   )
									THEN dblActualPriceFixation
								WHEN strPricingStatus = 'Partially Priced' AND dblCumulativeBalance = dblQtyPriced AND dblLagQtyPriced = 0
									THEN 0
								WHEN strPricingStatus = 'Partially Priced' 
									AND ROUND(SH.dblBalance, 1) = ROUND(SH.dblQtyUnpriced, 1) THEN SH.dblBalance - SH.dblQtyUnpriced
								-- PRICED TO UNPRICED (Previous Transaction is Contract Sequence Begin Balance)
								WHEN (SH.intLagPricingTypeId <> SH.intPricingTypeId
									AND SH.strLagPricingStatus = 'Fully Priced'
									AND SH.strPricingStatus = 'Unpriced'
									AND SH.ysnBalanceChange = 1
									AND SH.ysnBasisChange = 1
									AND SH.ysnFuturesChange = 1
									AND SH.ysnCashPriceChange = 1
									AND SH.ysnStatusChange = 1
									AND SH.dblOldBalance = dblLagQuantity
									) THEN dblOldBalance * -1
								 -- PRICED TO UNPRICED
								WHEN (ISNULL(P.intPriceFixationId, 0) = 0
								 	AND SH.intLagPricingTypeId <> SH.intPricingTypeId
								 	AND SH.strLagPricingStatus = 'Fully Priced'
								 	AND SH.strPricingStatus = 'Unpriced'
								 	AND SH.ysnBalanceChange = 1
								 	AND SH.ysnBasisChange IS NULL
								 	AND SH.ysnFuturesChange IS NULL
								 	) THEN SH.dblOldBalance * -1
								WHEN SH.dblBalance < dblActualPriceFixation THEN SH.dblBalance
								WHEN  strPricingStatus = 'Unpriced' THEN SH.dblBalance * -1
								ELSE dblActualPriceFixation - dblCumulativeBalance END
			, strTransactionReference =  CASE WHEN ISNULL(P.intPriceFixationId, 0) = 0 AND SH.intLagPricingTypeId <> 1
												THEN 'Basis - Price Fixation'
											WHEN ISNULL(P.intPriceFixationId, 0) = 0 AND SH.intLagPricingTypeId = 1
												THEN 'Updated Contract'
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
		FROM  (
			SELECT ysnIsPricing = CASE WHEN origctsh.dblQtyPriced <> lagctsh.dblQtyPriced 
												OR
											(lagctsh.strPricingStatus = 'Unpriced'
												AND origctsh.strPricingStatus <> 'Unpriced')
												OR
											(lagctsh.strPricingStatus <> 'Unpriced'
												AND origctsh.strPricingStatus = 'Unpriced')
									THEN 1 ELSE 0 END
					, dblActualPriceFixation = 
								(CASE WHEN origctsh.strPricingStatus = 'Unpriced' THEN 0 ELSE origctsh.dblQtyPriced END) 
								- (CASE WHEN lagctsh.strPricingStatus = 'Unpriced' THEN 0 ELSE lagctsh.dblQtyPriced END)
					, dblCumulativeBalance =  origctsh.dblQuantity - origctsh.dblBalance
					, dblCumulativeQtyPriced = (CASE WHEN lagctsh.strPricingStatus = 'Unpriced' THEN 0 ELSE lagctsh.dblQtyPriced END)
					, intLagPricingTypeId = lagctsh.intPricingTypeId
					, strLagPricingStatus = lagctsh.strPricingStatus
					, dblLagQtyPriced = lagctsh.dblQtyPriced
					, dblLagQtyUnpriced = lagctsh.dblQtyUnpriced
					, dblLagQuantity = lagctsh.dblQuantity
					, dblLagOldBalance = lagctsh.dblOldBalance
					, origctsh.* 
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
		AND (	(ISNULL(P.intPriceFixationId, 0) <> 0 AND SH.ysnIsPricing = 1 
					AND ( SH.dblQuantity = SH.dblQtyPriced
							OR
							(SH.dblQuantity <> SH.dblQtyPriced AND SH.dblBalance >= (SH.dblQuantity - SH.dblQtyPriced) AND SH.strPricingStatus = 'Partially Priced')
							OR
							(SH.dblQtyPriced = 0 AND SH.strPricingStatus = 'Unpriced')
						)
					AND (SH.intLagPricingTypeId <> SH.intPricingTypeId OR SH.strPricingStatus = 'Partially Priced')
				)
				OR
					(ISNULL(P.intPriceFixationId, 0) = 0
					AND SH.ysnFuturesChange = 1
					AND SH.ysnCashPriceChange = 1
					AND SH.strPricingType IN ('Priced','Basis')
					)
				OR
					-- PRICED TO UNPRICED
					(ISNULL(P.intPriceFixationId, 0) = 0
					AND SH.intLagPricingTypeId <> SH.intPricingTypeId
					AND ( (SH.ysnFuturesChange = 1 AND SH.dblOldFutures IS NOT NULL AND SH.dblFutures IS NULL) 
							OR 
						  (SH.ysnBasisChange = 1 AND SH.dblOldBasis IS NOT NULL AND SH.dblBasis IS NULL)
						)
					)
				OR
					-- PRICED TO UNPRICED IF ysnBasisChange and ysnFuturesChange IS NULL
					(ISNULL(P.intPriceFixationId, 0) = 0
					AND SH.intLagPricingTypeId <> SH.intPricingTypeId
					AND SH.strLagPricingStatus = 'Fully Priced'
					AND SH.strPricingStatus = 'Unpriced'
					AND SH.ysnBalanceChange = 1
					AND SH.ysnBasisChange IS NULL
					AND SH.ysnFuturesChange IS NULL	
					)
				OR
					(SH.intLagPricingTypeId <> SH.intPricingTypeId
					AND SH.strLagPricingStatus = 'Partially Priced'
					AND SH.strPricingStatus = 'Fully Priced'
					AND SH.ysnBalanceChange = 1
					AND SH.ysnCashPriceChange = 1
					AND SH.ysnFuturesChange = 1
					AND SH.ysnStatusChange = 1
					AND SH.dblBalance = 0 
					)
				)
		

		union all -- Counter entry when price fixing a Basis (Price Fixation of Basis thru Contract Pricing Screen or Updating Sequence Pricing Type to 'Priced')
		select 
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblQuantity = CASE WHEN SH.intContractStatusId = 6 THEN 0 -- CANCELLED
								WHEN ( strPricingStatus = 'Partially Priced' AND SH.dblQtyPriced <> 0
											AND dblCumulativeBalance > dblActualPriceFixation AND SH.dblBalance > dblActualPriceFixation AND dblCumulativeBalance = dblQtyPriced
													AND dblCumulativeBalance <= dblCumulativeQtyPriced AND SH.dblBalance = SH.dblQtyUnpriced) 
									THEN 0
								WHEN ( strPricingStatus <> 'Unpriced'
											AND ((dblCumulativeBalance > dblActualPriceFixation AND SH.dblBalance > dblActualPriceFixation AND dblCumulativeBalance <> dblQtyPriced)
													AND dblCumulativeBalance <= dblCumulativeQtyPriced AND (dblLagOldBalance * 2) = dblLagQtyPriced)) 
									THEN 0
								WHEN (SH.intLagPricingTypeId <> SH.intPricingTypeId
									AND SH.strLagPricingStatus = 'Partially Priced'
									AND SH.strPricingStatus = 'Fully Priced'
									AND SH.ysnBalanceChange = 1
									AND SH.ysnCashPriceChange = 1
									AND SH.ysnFuturesChange = 1
									AND SH.ysnStatusChange = 1
									AND SH.dblBalance = 0 
									) THEN SH.dblOldBalance * -1
								WHEN	strPricingStatus <> 'Unpriced'
										AND ((dblCumulativeBalance > dblActualPriceFixation AND SH.dblBalance > dblActualPriceFixation AND dblCumulativeBalance <> dblQtyPriced) 
												OR dblCumulativeBalance <= dblCumulativeQtyPriced)  
									THEN dblActualPriceFixation 
								WHEN strPricingStatus = 'Partially Priced' AND dblCumulativeBalance = dblQtyPriced AND dblLagQtyPriced = 0
									THEN 0
								WHEN strPricingStatus = 'Partially Priced' 
									AND ROUND(SH.dblBalance, 1) = ROUND(SH.dblQtyUnpriced, 1) THEN SH.dblBalance - SH.dblQtyUnpriced
								WHEN (SH.intLagPricingTypeId <> SH.intPricingTypeId
									AND SH.strLagPricingStatus = 'Fully Priced'
									AND SH.strPricingStatus = 'Unpriced'
									AND SH.ysnBalanceChange = 1
									AND SH.ysnBasisChange = 1
									AND SH.ysnFuturesChange = 1
									AND SH.ysnCashPriceChange = 1
									AND SH.ysnStatusChange = 1
									AND SH.dblOldBalance = dblLagQuantity
									) THEN 0 
								-- PRICED TO UNPRICED
								WHEN (ISNULL(P.intPriceFixationId, 0) = 0
								 	AND SH.intLagPricingTypeId <> SH.intPricingTypeId
								 	AND SH.strLagPricingStatus = 'Fully Priced'
								 	AND SH.strPricingStatus = 'Unpriced'
								 	AND SH.ysnBalanceChange = 1
								 	AND SH.ysnBasisChange IS NULL
								 	AND SH.ysnFuturesChange IS NULL
								 	) THEN SH.dblBalance * -1
								WHEN SH.dblBalance < dblActualPriceFixation THEN SH.dblBalance
								WHEN  strPricingStatus = 'Unpriced' THEN SH.dblBalance * -1
								ELSE dblActualPriceFixation - dblCumulativeBalance END * -1
			, strTransactionReference = CASE WHEN ISNULL(P.intPriceFixationId, 0) = 0 AND SH.intLagPricingTypeId <> 1
												THEN 'Basis - Price Fixation'
											WHEN ISNULL(P.intPriceFixationId, 0) = 0 AND SH.intLagPricingTypeId = 1
												THEN 'Updated Contract'
											ELSE 'Price Fixation' 
											END
			, @intContractHeaderId
			, @intContractDetailId
			, CASE WHEN ISNULL(P.intPriceFixationId, 0) = 0 AND SH.intLagPricingTypeId = 1 THEN 1 ELSE 2 END
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
		FROM  (
			SELECT ysnIsPricing = CASE WHEN origctsh.dblQtyPriced <> lagctsh.dblQtyPriced 
												OR
											(lagctsh.strPricingStatus = 'Unpriced'
												AND origctsh.strPricingStatus <> 'Unpriced')
												OR
											(lagctsh.strPricingStatus <> 'Unpriced'
												AND origctsh.strPricingStatus = 'Unpriced')
									THEN 1 ELSE 0 END
					, dblActualPriceFixation = 
								(CASE WHEN origctsh.strPricingStatus = 'Unpriced' THEN 0 ELSE origctsh.dblQtyPriced END) 
								- (CASE WHEN lagctsh.strPricingStatus = 'Unpriced' THEN 0 ELSE lagctsh.dblQtyPriced END)
					, dblCumulativeBalance =  origctsh.dblQuantity - origctsh.dblBalance
					, dblCumulativeQtyPriced = (CASE WHEN lagctsh.strPricingStatus = 'Unpriced' THEN 0 ELSE lagctsh.dblQtyPriced END)
					, intLagPricingTypeId = lagctsh.intPricingTypeId
					, strLagPricingStatus = lagctsh.strPricingStatus
					, dblLagQtyPriced = lagctsh.dblQtyPriced
					, dblLagQtyUnpriced = lagctsh.dblQtyUnpriced
					, dblLagQuantity = lagctsh.dblQuantity
					, dblLagOldBalance = lagctsh.dblOldBalance
					, origctsh.* 
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
		AND (	(ISNULL(P.intPriceFixationId, 0) <> 0 AND SH.ysnIsPricing = 1 
					AND ( SH.dblQuantity = SH.dblQtyPriced
							OR
							(SH.dblQuantity <> SH.dblQtyPriced AND SH.dblBalance >= (SH.dblQuantity - SH.dblQtyPriced) AND SH.strPricingStatus = 'Partially Priced')
							OR
							(SH.dblQtyPriced = 0 AND SH.strPricingStatus = 'Unpriced')
						)
					AND (SH.intLagPricingTypeId <> SH.intPricingTypeId OR SH.strPricingStatus = 'Partially Priced')
				)
				OR
					(ISNULL(P.intPriceFixationId, 0) = 0
					AND SH.ysnFuturesChange = 1
					AND SH.ysnCashPriceChange = 1
					AND SH.strPricingType IN ('Priced','Basis')
					AND SH.intLagPricingTypeId <> SH.intPricingTypeId
					)
				OR
					-- PRICED TO UNPRICED
					(ISNULL(P.intPriceFixationId, 0) = 0
					AND SH.intLagPricingTypeId <> SH.intPricingTypeId
					AND ( (SH.ysnFuturesChange = 1 AND SH.dblOldFutures IS NOT NULL AND SH.dblFutures IS NULL) 
							OR 
						  (SH.ysnBasisChange = 1 AND SH.dblOldBasis IS NOT NULL AND SH.dblBasis IS NULL)
						)
					)
				OR
					-- PRICED TO UNPRICED IF ysnBasisChange and ysnFuturesChange IS NULL
					(ISNULL(P.intPriceFixationId, 0) = 0
					AND SH.intLagPricingTypeId <> SH.intPricingTypeId
					AND SH.strLagPricingStatus = 'Fully Priced'
					AND SH.strPricingStatus = 'Unpriced'
					AND SH.ysnBalanceChange = 1
					AND SH.ysnBasisChange IS NULL
					AND SH.ysnFuturesChange IS NULL	
					)
				OR
					(SH.intLagPricingTypeId <> SH.intPricingTypeId
					AND SH.strLagPricingStatus = 'Partially Priced'
					AND SH.strPricingStatus = 'Fully Priced'
					AND SH.ysnBalanceChange = 1
					AND SH.ysnCashPriceChange = 1
					AND SH.ysnFuturesChange = 1
					AND SH.ysnStatusChange = 1
					AND SH.dblBalance = 0 
					)
				)

		union all -- Header is Priced
		select 
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblQuantity = CASE WHEN SH.intContractStatusId = 6 THEN 0 -- CANCELLED
								WHEN	strPricingStatus <> 'Unpriced'
										AND ((dblCumulativeBalance > dblActualPriceFixation AND SH.dblBalance > dblActualPriceFixation) 
												OR dblCumulativeBalance <= dblCumulativeQtyPriced)  
									THEN dblActualPriceFixation 
								WHEN SH.dblBalance < dblActualPriceFixation THEN SH.dblBalance
								WHEN  strPricingStatus = 'Unpriced' THEN SH.dblBalance * -1
								ELSE dblActualPriceFixation - dblCumulativeBalance END
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
		FROM  (
			SELECT ysnIsPricing = CASE WHEN origctsh.dblQtyPriced <> lagctsh.dblQtyPriced 
												OR
											(lagctsh.strPricingStatus = 'Unpriced'
												AND origctsh.strPricingStatus <> 'Unpriced')
									THEN 1 ELSE 0 END
					, dblActualPriceFixation = 
								(CASE WHEN origctsh.strPricingStatus = 'Unpriced' THEN 0 ELSE origctsh.dblQtyPriced END) 
								- (CASE WHEN lagctsh.strPricingStatus = 'Unpriced' THEN 0 ELSE lagctsh.dblQtyPriced END)
					, dblCumulativeBalance =  origctsh.dblQuantity - origctsh.dblBalance
					, dblCumulativeQtyPriced = (CASE WHEN lagctsh.strPricingStatus = 'Unpriced' THEN 0 ELSE lagctsh.dblQtyPriced END)
					, intLagPricingTypeId = lagctsh.intPricingTypeId
					, strLagPricingStatus = lagctsh.strPricingStatus
					, origctsh.* 
			FROM #tmpCTSequenceHistory origctsh
			OUTER APPLY 
			(
				SELECT TOP 1 * FROM #tmpCTSequenceHistory ictsh
				WHERE ictsh.rowNum = origctsh.rowNum - 1
			) lagctsh
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
			, dblQuantity = CASE WHEN SH.intContractStatusId = 6 THEN 0 -- CANCELLED
								WHEN	strPricingStatus <> 'Unpriced'
										AND ((dblCumulativeBalance > dblActualPriceFixation AND SH.dblBalance > dblActualPriceFixation) 
												OR dblCumulativeBalance <= dblCumulativeQtyPriced)  
									THEN dblActualPriceFixation 
								WHEN SH.dblBalance < dblActualPriceFixation THEN SH.dblBalance
								WHEN  strPricingStatus = 'Unpriced' THEN SH.dblBalance * -1
								ELSE dblActualPriceFixation - dblCumulativeBalance END * -1
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
		FROM  (
			SELECT ysnIsPricing = CASE WHEN origctsh.dblQtyPriced <> lagctsh.dblQtyPriced 
												OR
											(lagctsh.strPricingStatus = 'Unpriced'
												AND origctsh.strPricingStatus <> 'Unpriced')
									THEN 1 ELSE 0 END
					, dblActualPriceFixation = 
								(CASE WHEN origctsh.strPricingStatus = 'Unpriced' THEN 0 ELSE origctsh.dblQtyPriced END) 
								- (CASE WHEN lagctsh.strPricingStatus = 'Unpriced' THEN 0 ELSE lagctsh.dblQtyPriced END)
					, dblCumulativeBalance =  origctsh.dblQuantity - origctsh.dblBalance
					, dblCumulativeQtyPriced = (CASE WHEN lagctsh.strPricingStatus = 'Unpriced' THEN 0 ELSE lagctsh.dblQtyPriced END)
					, intLagPricingTypeId = lagctsh.intPricingTypeId
					, strLagPricingStatus = lagctsh.strPricingStatus
					, origctsh.* 
			FROM #tmpCTSequenceHistory origctsh
			OUTER APPLY 
			(
				SELECT TOP 1 * FROM #tmpCTSequenceHistory ictsh
				WHERE ictsh.rowNum = origctsh.rowNum - 1
			) lagctsh
		) SH 
		cross apply (
			select top 1  PF.intPriceFixationId, PC.strPriceContractNo, intUserId from tblCTPriceFixation PF
			inner join tblCTPriceContract PC ON PC.intPriceContractId = PF.intPriceContractId
			where intContractHeaderId = @intContractHeaderId and intContractDetailId = @intContractDetailId
		) P 
		where SH.intContractDetailId = @intContractDetailId AND SH.ysnIsPricing = 1  AND @intHeaderPricingType IN (1) and strPricingStatus <> 'Unpriced'

		UNION ALL -- Cancelled and Short Closed Contracts (PRICED PART)
		SELECT 
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblBalance  = CASE WHEN sh.dblBalance >= dblQtyPriced THEN dblQtyPriced 									
								ELSE CASE WHEN sh.intPricingTypeId = 1 
										THEN sh.dblBalance
										ELSE 0
										END
								END * -1
			, strTransactionReference = 'Updated Contract'
			, @intContractHeaderId
			, @intContractDetailId
			, intPricingTypeId = 1 -- CASE WHEN @intHeaderPricingType = 2 AND @intPricingTypeId = 1 THEN ctd.intPricingTypeId ELSE sh.intPricingTypeId END
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
		(	SELECT * 
			FROM tblCTSequenceHistory ctsh
			WHERE ctsh.intContractDetailId = @intContractDetailId
			AND ctsh.intContractStatusId IN (3, 6) -- Cancelled and Short Closed
			AND ctsh.ysnStatusChange = 1
			AND ctsh.dblQtyPriced > 0
		) sh 
		JOIN tblCTContractDetail ctd
		ON ctd.intContractDetailId = sh.intContractDetailId
		
		UNION ALL -- Cancelled and Short Closed Contracts (UNPRICED PART)
		SELECT 
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblBalance  = CASE WHEN sh.dblBalance >= dblQtyUnpriced THEN dblQtyUnpriced 
								ELSE CASE WHEN sh.intPricingTypeId = 1 
										THEN 0
										ELSE sh.dblBalance
										END
								END * -1
			, strTransactionReference = 'Updated Contract'
			, @intContractHeaderId
			, @intContractDetailId
			, intPricingTypeId = CASE WHEN @intHeaderPricingType = 1 AND sh.intPricingTypeId <> 1 THEN sh.intPricingTypeId ELSE @intHeaderPricingType END 
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
		(	SELECT * 
			FROM tblCTSequenceHistory ctsh
			WHERE ctsh.intContractDetailId = @intContractDetailId
			AND ctsh.intContractStatusId IN (3, 6) -- Cancelled and Short Closed
			AND ctsh.ysnStatusChange = 1
			AND ctsh.dblQtyUnpriced > 0
		) sh 
		JOIN tblCTContractDetail ctd
		ON ctd.intContractDetailId = sh.intContractDetailId

		UNION ALL -- Cancelled and Short Closed Contracts (Reopened)
		SELECT 
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblBalance  = CASE WHEN sh.strPricingStatus = 'Partially Priced' THEN sh.dblBalance - sh.dblQtyUnpriced
								ELSE sh.dblBalance
								END
			, strTransactionReference = 'Updated Contract'
			, @intContractHeaderId
			, @intContractDetailId
			, intPricingTypeId  =  CASE WHEN sh.strPricingStatus = 'Partially Priced' THEN 1
									WHEN @intHeaderPricingType = 2 AND @intPricingTypeId = 1 THEN ctd.intPricingTypeId 
									ELSE sh.intPricingTypeId END
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
		(	SELECT *
			FROM tblCTSequenceHistory ctsh
			WHERE ctsh.intContractDetailId = @intContractDetailId
			AND ctsh.intContractStatusId IN (4) -- Reopened
			AND ctsh.ysnStatusChange = 1
		) sh 
		JOIN tblCTContractDetail ctd
		ON ctd.intContractDetailId = sh.intContractDetailId
		
		-- PARTIAL PRICED UNPRICED PART
		UNION ALL -- Cancelled and Short Closed Contracts (Reopened)
		SELECT 
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblBalance  = sh.dblQtyUnpriced
			, strTransactionReference = 'Updated Contract'
			, @intContractHeaderId
			, @intContractDetailId
			, intPricingTypeId  = @intHeaderPricingType
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
		(	SELECT *
			FROM tblCTSequenceHistory ctsh
			WHERE ctsh.intContractDetailId = @intContractDetailId
			AND ctsh.intContractStatusId IN (4) -- Reopened
			AND ctsh.ysnStatusChange = 1
		) sh 
		JOIN tblCTContractDetail ctd
		ON ctd.intContractDetailId = sh.intContractDetailId
		WHERE sh.strPricingStatus = 'Partially Priced'

		UNION ALL -- Scenario: Short Closed Contracts (Was updated to Short Closed and Updated Balance Qty as well.)
		SELECT 
			dtmHistoryCreated
			, @strContractNumber
			, @intContractSeq
			, @intContractTypeId
			, dblBalance  = sh.dblBalance - sh.dblOldBalance
			, strTransactionReference = 'Contract Sequence Balance Change'
			, @intContractHeaderId
			, @intContractDetailId
			, intPricingTypeId  = sh.intPricingTypeId
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
		FROM 
		(	SELECT *
			FROM tblCTSequenceHistory ctsh
			WHERE ctsh.intContractDetailId = @intContractDetailId
			AND ctsh.intContractStatusId IN (6) -- Short Closed
			AND ctsh.ysnStatusChange = 1
			AND ctsh.ysnBalanceChange = 1
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

	--EXEC uspCTLogContractBalance @cbLog, 1

	
	--=============================================
	-- START - NON-OPEN CONTRACT - BASIS DELIVERIES 
	--=============================================
	select  
		dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmTransactionDate)
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, sh.strContractNumber
		, sh.intContractSeq
		, sh.intEntityId
		, ch.intCommodityId
		, sh.intItemId
		, sh.intCompanyLocationId
		, dblQty = (case when isnull(cd.intNoOfLoad,0) = 0 then si.dblQuantity * -1
						else suh.dblTransactionQuantity * si.dblQuantity end) * -1
		, intQtyUOMId = si.intItemUOMId
		, sh.intPricingTypeId
		, sh.strPricingType
		, strTransactionType = strScreenName
		, intTransactionId = suh.intExternalId
		, strTransactionId = suh.strNumber
		, sh.intContractStatusId
		, ch.intContractTypeId
		, sh.intFutureMarketId
		, sh.intFutureMonthId
		, intUserId = si.intCreatedByUserId
		, si.ysnDestinationWeightsAndGrades
		, sh.dblBasis
		, sh.dtmStartDate
		, sh.dtmEndDate
	into #tblBasisDeliveries
	from vyuCTSequenceUsageHistory suh
		inner join tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
		inner join tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
		inner join tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		inner join tblICInventoryShipmentItem si ON si.intInventoryShipmentItemId = suh.intExternalId
	where strFieldName = 'Balance'
	and sh.strPricingStatus  IN ('Unpriced','Partially Priced')
	and sh.strPricingType = 'Basis'
	and suh.strScreenName = 'Inventory Shipment'
	and si.ysnDestinationWeightsAndGrades = 0
	and cd.intContractDetailId IN (SELECT intContractDetailId FROM #tmpNonOpenContractsToRebuild)

	union all --IS that are DWG
	select  
		dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmTransactionDate)
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, sh.strContractNumber
		, sh.intContractSeq
		, sh.intEntityId
		, ch.intCommodityId
		, sh.intItemId
		, sh.intCompanyLocationId
		, dblQty = (case when isnull(cd.intNoOfLoad,0) = 0 then (CASE WHEN ISNULL(si.dblDestinationNet,0) = 0 THEN suh.dblTransactionQuantity ELSE si.dblDestinationNet * -1 END)
						else suh.dblTransactionQuantity * (CASE WHEN ISNULL(si.dblDestinationNet,0) = 0 THEN suh.dblTransactionQuantity ELSE si.dblDestinationNet END) end) * -1
		, intQtyUOMId = si.intItemUOMId
		, sh.intPricingTypeId
		, sh.strPricingType
		, strTransactionType = strScreenName
		, intTransactionId = suh.intExternalId
		, strTransactionId = suh.strNumber
		, sh.intContractStatusId
		, ch.intContractTypeId
		, sh.intFutureMarketId
		, sh.intFutureMonthId
		, intUserId = si.intCreatedByUserId
		, si.ysnDestinationWeightsAndGrades
		, sh.dblBasis
		, sh.dtmStartDate
		, sh.dtmEndDate
	from vyuCTSequenceUsageHistory suh
		inner join tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
		inner join tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
		inner join tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		inner join tblICInventoryShipmentItem si ON si.intInventoryShipmentItemId = suh.intExternalId
	where strFieldName = 'Balance'
	and sh.strPricingStatus  IN ('Unpriced','Partially Priced')
	and sh.strPricingType = 'Basis'
	and suh.strScreenName = 'Inventory Shipment'
	and si.ysnDestinationWeightsAndGrades = 1
	and cd.intContractDetailId IN (SELECT intContractDetailId FROM #tmpNonOpenContractsToRebuild)

	union all
	select  
		dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmTransactionDate)
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, sh.strContractNumber
		, sh.intContractSeq
		, sh.intEntityId
		, ch.intCommodityId
		, sh.intItemId
		, sh.intCompanyLocationId
		, dblQty = (case when isnull(cd.intNoOfLoad,0) = 0 then suh.dblTransactionQuantity 
						else suh.dblTransactionQuantity * ri.dblReceived end) * -1
		, intQtyUOMId = ri.intUnitMeasureId
		, sh.intPricingTypeId
		, sh.strPricingType
		, strTransactionType = strScreenName
		, intTransactionId = suh.intExternalId
		, strTransactionId = suh.strNumber
		, sh.intContractStatusId
		, ch.intContractTypeId
		, sh.intFutureMarketId
		, sh.intFutureMonthId
		, intUserId = ri.intCreatedByUserId
		, ysnDestinationWeightsAndGrades = 0
		, sh.dblBasis
		, sh.dtmStartDate
		, sh.dtmEndDate
	from vyuCTSequenceUsageHistory suh
		inner join tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
		inner join tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
		inner join tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		inner join tblICInventoryReceiptItem ri ON ri.intInventoryReceiptItemId = suh.intExternalId
	where strFieldName = 'Balance'
	and sh.strPricingStatus  IN ('Unpriced','Partially Priced')
	and sh.strPricingType = 'Basis'
	and suh.strScreenName = 'Inventory Receipt'
	and cd.intContractDetailId IN (SELECT intContractDetailId FROM #tmpNonOpenContractsToRebuild)

	union all
	select  
		dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmTransactionDate)
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, sh.strContractNumber
		, sh.intContractSeq
		, sh.intEntityId
		, ch.intCommodityId
		, sh.intItemId
		, sh.intCompanyLocationId
		, dblQty = (case when isnull(cd.intNoOfLoad,0) = 0 then suh.dblTransactionQuantity 
						else suh.dblTransactionQuantity * ri.dblReceived end) 
		, intQtyUOMId = ri.intUnitMeasureId
		, sh.intPricingTypeId
		, sh.strPricingType
		, strTransactionType = 'Inventory Return'
		, intTransactionId = suh.intExternalId
		, strTransactionId = suh.strNumber
		, sh.intContractStatusId
		, ch.intContractTypeId
		, sh.intFutureMarketId
		, sh.intFutureMonthId
		, intUserId = ri.intCreatedByUserId
		, ysnDestinationWeightsAndGrades = 0
		, sh.dblBasis
		, sh.dtmStartDate
		, sh.dtmEndDate
	from vyuCTSequenceUsageHistory suh
		inner join tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
		inner join tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
		inner join tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		inner join tblICInventoryReceiptItem ri ON ri.intInventoryReceiptItemId = suh.intExternalId
	where strFieldName = 'Balance'
	and sh.strPricingStatus  IN ('Unpriced','Partially Priced')
	and sh.strPricingType = 'Basis'
	and suh.strScreenName = 'Receipt Return'
	and cd.intContractDetailId IN (SELECT intContractDetailId FROM #tmpNonOpenContractsToRebuild)

	union all
	select * from (
	select  
		dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmTransactionDate)
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, sh.strContractNumber
		, sh.intContractSeq
		, sh.intEntityId
		, ch.intCommodityId
		, sh.intItemId
		, sh.intCompanyLocationId
		, dblQty = abs(sum(case when isnull(cd.intNoOfLoad,0) = 0 then (case when suh.dblTransactionQuantity < 0 then ld.dblQuantity * -1 else ld.dblQuantity end)
						else suh.dblTransactionQuantity * ld.dblQuantity end) * -1)
		, intQtyUOMId = ld.intItemUOMId
		, sh.intPricingTypeId
		, sh.strPricingType
		, strTransactionType = strScreenName
		, intTransactionId = suh.intExternalId
		, strTransactionId = suh.strNumber
		, sh.intContractStatusId
		, ch.intContractTypeId
		, sh.intFutureMarketId
		, sh.intFutureMonthId
		, intUserId = sh.intUserId
		, ysnDestinationWeightsAndGrades = 0
		, sh.dblBasis
		, sh.dtmStartDate
		, sh.dtmEndDate
	from vyuCTSequenceUsageHistory suh
		inner join tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
		inner join tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
		inner join tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		inner join tblLGLoadDetail ld ON ld.intLoadDetailId = suh.intExternalId
	where strFieldName = 'Balance'
	and sh.strPricingStatus  IN ('Unpriced','Partially Priced')
	and sh.strPricingType = 'Basis'
	and suh.strScreenName = 'Load Schedule'
	AND cd.intContractStatusId IN (3, 5, 6) -- CANCELLED, COMPLETED AND SHORT CLOSED
	AND DATEADD(dd, 0, DATEDIFF(dd, 0, cd.dtmCreated)) >= @dtmRebuildStartDate
	AND DATEADD(dd, 0, DATEDIFF(dd, 0, cd.dtmCreated)) <= @dtmRebuildEndDate
	and cd.intContractDetailId IN (SELECT intContractDetailId FROM #tmpNonOpenContractsToRebuild)
	group by 
		dbo.fnRemoveTimeOnDate(dtmTransactionDate)
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, sh.strContractNumber
		, sh.intContractSeq
		, sh.intEntityId
		, ch.intCommodityId
		, sh.intItemId
		, sh.intCompanyLocationId
		, ld.intItemUOMId
		, sh.intPricingTypeId
		, sh.strPricingType
		, strScreenName
		, suh.intExternalId
		, suh.strNumber
		, sh.intContractStatusId
		, ch.intContractTypeId
		, sh.intFutureMarketId
		, sh.intFutureMonthId
		, sh.intUserId
		, sh.dblBasis
		, sh.dtmStartDate
		, sh.dtmEndDate
	) t where dblQty <> 0

	union all
	select  
		dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmTransactionDate)
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, sh.strContractNumber
		, sh.intContractSeq
		, sh.intEntityId
		, ch.intCommodityId
		, sh.intItemId
		, sh.intCompanyLocationId
		, dblQty = (case when isnull(cd.intNoOfLoad,0) = 0 then suh.dblTransactionQuantity 
						else suh.dblTransactionQuantity * st.dblUnits end) * -1
		, intQtyUOMId = ss.intCommodityStockUomId
		, sh.intPricingTypeId
		, sh.strPricingType
		, strTransactionType = strScreenName
		, intTransactionId = suh.intExternalHeaderId
		, strTransactionId = suh.strNumber
		, sh.intContractStatusId
		, ch.intContractTypeId
		, sh.intFutureMarketId
		, sh.intFutureMonthId
		, intUserId = ss.intCreatedUserId
		, ysnDestinationWeightsAndGrades = 0
		, sh.dblBasis
		, sh.dtmStartDate
		, sh.dtmEndDate
	from vyuCTSequenceUsageHistory suh
		inner join tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
		inner join tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
		inner join tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		inner join tblGRSettleStorage ss ON ss.intSettleStorageId = suh.intExternalHeaderId
		inner join tblGRSettleStorageTicket st on st.intSettleStorageTicketId = suh.intExternalId and st.intSettleStorageId = suh.intExternalHeaderId
	where strFieldName = 'Balance'
	and sh.strPricingStatus  IN ('Unpriced','Partially Priced')
	and sh.strPricingType = 'Basis'
	and suh.strScreenName = 'Settle Storage'
	and cd.intContractDetailId IN (SELECT intContractDetailId FROM #tmpNonOpenContractsToRebuild)

	-- DELETED ORIG QTY
	UNION ALL
	SELECT  
		dtmTransactionDate = dbo.fnRemoveTimeOnDate(suh.dtmTransactionDate)
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, sh.strContractNumber
		, sh.intContractSeq
		, sh.intEntityId
		, ch.intCommodityId
		, sh.intItemId
		, sh.intCompanyLocationId
		, dblQty =  CASE WHEN ch.ysnLoad = 1 
					THEN suh.dblTransactionQuantity * ch.dblQuantityPerLoad 
					ELSE suh.dblTransactionQuantity END
		, intQtyUOMId = cd.intItemUOMId
		, sh.intPricingTypeId
		, sh.strPricingType
		, strTransactionType = strScreenName
		, intTransactionId = suh.intExternalId
		, strTransactionId = suh.strNumber
		, sh.intContractStatusId
		, ch.intContractTypeId
		, sh.intFutureMarketId
		, sh.intFutureMonthId
		, intUserId = sh.intUserId
		, ysnDestinationWeightsAndGrades = CASE WHEN ISNULL(ctWG.intWeightGradeId, 0) <> 0 
												THEN CAST(1 AS BIT) 
												ELSE CAST(0 AS BIT) 
												END
		, sh.dblBasis
		, sh.dtmStartDate
		, sh.dtmEndDate
	from vyuCTSequenceUsageHistory suh
	INNER JOIN tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
	INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
	INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
	LEFT JOIN tblCTWeightGrade ctWG
		ON (	ctWG.intWeightGradeId = ch.intWeightId
				OR ctWG.intWeightGradeId = ch.intGradeId
			)
		AND ctWG.strWhereFinalized = 'Destination'
	CROSS APPLY (
			SELECT TOP 1 ctUH.intSequenceUsageHistoryId
					, ctUH.dtmTransactionDate
			FROM tblCTSequenceUsageHistory ctUH
			WHERE ctUH.intExternalHeaderId = suh.intExternalHeaderId
			AND ctUH.intContractDetailId = @intContractDetailId
			AND ctUH.strFieldName = 'Balance'
			AND suh.dblTransactionQuantity * -1 = ctUH.dblTransactionQuantity
		) negateHistory
	where strFieldName = 'Balance'
	AND suh.ysnDeleted = 1
	AND sh.strPricingStatus  IN ('Unpriced','Partially Priced')
	AND sh.strPricingType = 'Basis'
	AND suh.strScreenName = 'Inventory Shipment'
	AND suh.dblTransactionQuantity < 0
	and cd.intContractDetailId IN (SELECT intContractDetailId FROM #tmpNonOpenContractsToRebuild)

	-- DELETED NEGATE QTY
	UNION ALL
	SELECT
		dtmTransactionDate = dbo.fnRemoveTimeOnDate(negateHistory.dtmTransactionDate)
		, sh.intContractHeaderId
		, sh.intContractDetailId
		, sh.strContractNumber
		, sh.intContractSeq
		, sh.intEntityId
		, ch.intCommodityId
		, sh.intItemId
		, sh.intCompanyLocationId
		, dblQty =  CASE WHEN ch.ysnLoad = 1 
					THEN suh.dblTransactionQuantity * ch.dblQuantityPerLoad 
					ELSE suh.dblTransactionQuantity END  * -1
		, intQtyUOMId = cd.intItemUOMId
		, sh.intPricingTypeId
		, sh.strPricingType
		, strTransactionType = strScreenName
		, intTransactionId = suh.intExternalId
		, strTransactionId = suh.strNumber
		, sh.intContractStatusId
		, ch.intContractTypeId
		, sh.intFutureMarketId
		, sh.intFutureMonthId
		, intUserId = sh.intUserId
		, ysnDestinationWeightsAndGrades = CASE WHEN ISNULL(ctWG.intWeightGradeId, 0) <> 0 
												THEN CAST(1 AS BIT) 
												ELSE CAST(0 AS BIT) 
												END
		, sh.dblBasis
		, sh.dtmStartDate
		, sh.dtmEndDate
	from vyuCTSequenceUsageHistory suh
	INNER JOIN tblCTSequenceHistory sh ON sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
	INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = sh.intContractDetailId
	INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
	LEFT JOIN tblCTWeightGrade ctWG
		ON (	ctWG.intWeightGradeId = ch.intWeightId
				OR ctWG.intWeightGradeId = ch.intGradeId
			)
		AND ctWG.strWhereFinalized = 'Destination'
	CROSS APPLY (
			SELECT TOP 1 ctUH.intSequenceUsageHistoryId
					, ctUH.dtmTransactionDate
			FROM tblCTSequenceUsageHistory ctUH
			WHERE ctUH.intExternalHeaderId = suh.intExternalHeaderId
			AND ctUH.intContractDetailId = @intContractDetailId
			AND ctUH.strFieldName = 'Balance'
			AND suh.dblTransactionQuantity * -1 = ctUH.dblTransactionQuantity
		) negateHistory
	where strFieldName = 'Balance'
	AND suh.ysnDeleted = 1
	AND sh.strPricingStatus  IN ('Unpriced','Partially Priced')
	AND sh.strPricingType = 'Basis'
	AND suh.strScreenName = 'Inventory Shipment'
	AND suh.dblTransactionQuantity < 0
	and cd.intContractDetailId IN (SELECT intContractDetailId FROM #tmpNonOpenContractsToRebuild)

	SELECT * 
	INTO #tblFinalBasisDeliveries 
	FROM (

		select
			strTransactionType =  CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END 
			, dtmTransactionDate
			, intContractHeaderId
			, intContractDetailId
			, strContractNumber
			, intContractSeq
			, intContractTypeId
			, intContractStatusId
			, intCommodityId
			, intItemId
			, intEntityId
			, intCompanyLocationId
			, dblQty
			, intQtyUOMId
			, intPricingTypeId
			, strPricingType
			, strTransactionReference = strTransactionType
			, intTransactionReferenceId = intTransactionId
			, intTransactionReferenceDetailId = NULL
			, strTransactionReferenceNo = strTransactionId
			, intFutureMarketId
			, intFutureMonthId
			, intUserId
			, dblBasis
			, dtmStartDate
			, dtmEndDate
		from #tblBasisDeliveries

		union all
		select 
				strType  = 'Purchase Basis Deliveries'
			, b.dtmBillDate
			, ba.intContractHeaderId
			, ba.intContractDetailId
			, ba.strContractNumber
			, ba.intContractSeq
			, ba.intContractTypeId
			, ba.intContractStatusId
			, ba.intCommodityId
			, ba.intItemId
			, ba.intEntityId
			, ba.intCompanyLocationId
			, dblQty =  bd.dblQtyReceived  * -1
			, intItemUOMId = bd.intUnitOfMeasureId
			, intPricingTypeId = 2
			, strPricingType = 'Basis'
			, strTransactionType = 'Voucher'
			, intTransactionId = b.intBillId
			, intTransactionReferenceDetailId = NULL
			, strTransactionId = b.strBillId
			, intFutureMarketId
			, intFutureMonthId
			, intUserId = b.intUserId
			, ba.dblBasis
			, ba.dtmStartDate
			, ba.dtmEndDate
		from tblAPBillDetail bd
		inner join tblAPBill b ON b.intBillId = bd.intBillId
		inner join #tblBasisDeliveries ba ON ba.intTransactionId = bd.intInventoryReceiptItemId and ba.strTransactionType = 'Inventory Receipt' and ba.intContractTypeId = 1 and ba.intItemId = bd.intItemId
	
		union all
		select 
				strType  = 'Purchase Basis Deliveries'
			, b.dtmBillDate
			, ba.intContractHeaderId
			, ba.intContractDetailId
			, ba.strContractNumber
			, ba.intContractSeq
			, ba.intContractTypeId
			, ba.intContractStatusId
			, ba.intCommodityId
			, ba.intItemId
			, ba.intEntityId
			, ba.intCompanyLocationId
			, dblQty =  bd.dblQtyReceived  * -1
			, intItemUOMId = bd.intUnitOfMeasureId
			, intPricingTypeId = 2
			, strPricingType = 'Basis'
			, strTransactionType = 'Voucher'
			, intTransactionId = b.intBillId
			, intTransactionReferenceDetailId = NULL
			, strTransactionId = b.strBillId
			, intFutureMarketId
			, intFutureMonthId
			, intUserId = b.intUserId
			, ba.dblBasis
			, ba.dtmStartDate
			, ba.dtmEndDate
		from tblAPBillDetail bd
		inner join tblAPBill b ON b.intBillId = bd.intBillId
		inner join #tblBasisDeliveries ba ON ba.intTransactionId = bd.intSettleStorageId and ba.strTransactionType = 'Settle Storage' and ba.intContractTypeId = 1 and ba.intItemId = bd.intItemId
			and ba.intContractHeaderId = bd.intContractHeaderId and ba.intContractDetailId = bd.intContractDetailId
			
		union all
		select 
				strType  = 'Purchase Basis Deliveries'
			, b.dtmBillDate
			, ba.intContractHeaderId
			, ba.intContractDetailId
			, ba.strContractNumber
			, ba.intContractSeq
			, ba.intContractTypeId
			, ba.intContractStatusId
			, ba.intCommodityId
			, ba.intItemId
			, ba.intEntityId
			, ba.intCompanyLocationId
			, dblQty =  bd.dblQtyReceived  * -1
			, intItemUOMId = bd.intUnitOfMeasureId
			, intPricingTypeId = 2
			, strPricingType = 'Basis'
			, strTransactionType = 'Voucher'
			, intTransactionId = b.intBillId
			, intTransactionReferenceDetailId = NULL
			, strTransactionId = b.strBillId
			, intFutureMarketId
			, intFutureMonthId
			, intUserId = b.intUserId
			, ba.dblBasis
			, ba.dtmStartDate
			, ba.dtmEndDate
		from tblAPBillDetail bd
		inner join tblAPBill b ON b.intBillId = bd.intBillId
		inner join #tblBasisDeliveries ba ON ba.intTransactionId = bd.intLoadDetailId and ba.strTransactionType = 'Load Schedule' and ba.intContractTypeId = 1

		union all
		select 
				strType  = 'Sales Basis Deliveries'
			, i.dtmDate
			, ba.intContractHeaderId
			, ba.intContractDetailId
			, ba.strContractNumber
			, ba.intContractSeq
			, ba.intContractTypeId
			, ba.intContractStatusId
			, ba.intCommodityId
			, ba.intItemId
			, ba.intEntityId
			, ba.intCompanyLocationId
			, dblQty = id.dblQtyShipped  * -1 
			, intItemUOMId = id.intItemUOMId
			, intPricingTypeId = 2
			, strPricingType = 'Basis'
			, strTransactionType = 'Invoice'
			, intTransactionId = i.intInvoiceId
			, intTransactionReferenceDetailId = NULL
			, strTransactionId = i.strInvoiceNumber
			, intFutureMarketId
			, intFutureMonthId
			, intUserId = i.intEntityId 
			, ba.dblBasis
			, ba.dtmStartDate
			, ba.dtmEndDate
		from tblARInvoiceDetail id
		inner join tblARInvoice i ON i.intInvoiceId = id.intInvoiceId
		inner join #tblBasisDeliveries ba ON ba.intTransactionId = id.intInventoryShipmentItemId and ba.strTransactionType <> 'Load Schedule' and ba.intContractTypeId = 2
		where i.strTransactionType <> 'Credit Memo' 
	
		union all
		select 
				strType  = 'Sales Basis Deliveries'
			, i.dtmDate
			, ba.intContractHeaderId
			, ba.intContractDetailId
			, ba.strContractNumber
			, ba.intContractSeq
			, ba.intContractTypeId
			, ba.intContractStatusId
			, ba.intCommodityId
			, ba.intItemId
			, ba.intEntityId
			, ba.intCompanyLocationId
			, dblQty =  id.dblQtyShipped  * -1
			, intItemUOMId = id.intItemUOMId
			, intPricingTypeId = 2
			, strPricingType = 'Basis'
			, strTransactionType = 'Invoice'
			, intTransactionId = i.intInvoiceId
			, intTransactionReferenceDetailId = NULL
			, strTransactionId = i.strInvoiceNumber
			, intFutureMarketId
			, intFutureMonthId
			, intUserId = i.intEntityId 
			, ba.dblBasis
			, ba.dtmStartDate
			, ba.dtmEndDate
		from tblARInvoiceDetail id
		inner join tblARInvoice i ON i.intInvoiceId = id.intInvoiceId
		inner join #tblBasisDeliveries ba ON ba.intTransactionId = id.intLoadDetailId and ba.strTransactionType = 'Load Schedule' and ba.intContractTypeId = 2


		union all
		select distinct
				strType  = 'Sales Basis Deliveries'
			, dtmDate = FD.dtmFixationDate
			, ba.intContractHeaderId
			, ba.intContractDetailId
			, ba.strContractNumber
			, ba.intContractSeq
			, ba.intContractTypeId
			, ba.intContractStatusId
			, ba.intCommodityId
			, ba.intItemId
			, ba.intEntityId
			, ba.intCompanyLocationId
			, dblQty = FD.dblQuantity  * -1 
			, intItemUOMId = ba.intQtyUOMId
			, intPricingTypeId = 2
			, strPricingType = 'Basis'
			, strTransactionType = 'Price Fixation'
			, intTransactionId = FD.intPriceFixationId
			, intTransactionReferenceDetailId = FD.intPriceFixationDetailId
			, strTransactionId = PC.strPriceContractNo
			, FD.intFutureMarketId
			, FD.intFutureMonthId
			, intUserId = PC.intCreatedById
			, ba.dblBasis
			, ba.dtmStartDate
			, ba.dtmEndDate
		FROM tblCTPriceFixation PF 
		INNER JOIN tblCTPriceFixationDetail FD ON PF.intPriceFixationId = FD.intPriceFixationId
		INNER JOIN tblCTPriceContract PC ON PC.intPriceContractId = PF.intPriceContractId
		CROSS APPLY (
			select distinct  
				intContractHeaderId
				, intContractDetailId
				, strContractNumber
				, intContractSeq
				, intContractTypeId
				, intContractStatusId
				, intCommodityId
				, intItemId
				, intEntityId
				, intCompanyLocationId
				, intQtyUOMId
				, dblBasis
				, dtmStartDate
				, dtmEndDate
			from #tblBasisDeliveries
			where intContractDetailId = PF.intContractDetailId
			and strTransactionType <> 'Load Schedule'
			and intContractTypeId = 2
			and ysnDestinationWeightsAndGrades = 1
		) ba
		LEFT JOIN tblCTPriceFixationDetailAPAR PFD ON PFD.intPriceFixationDetailId = FD.intPriceFixationDetailId
		WHERE PFD.intPriceFixationDetailAPARId IS NULL
		AND ISNULL(FD.dblQuantityAppliedAndPriced,0) <> 0

		-- Cancelled Negating Qty
		UNION ALL
		select
			strTransactionType =  CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END 
			, dtmTransactionDate = sh.dtmHistoryCreated
			, intContractHeaderId
			, intContractDetailId
			, strContractNumber
			, intContractSeq
			, intContractTypeId
			, intContractStatusId
			, intCommodityId
			, intItemId
			, intEntityId
			, intCompanyLocationId
			, dblQty = (sh.dblQuantity - sh.dblBalance) * -1
			, intQtyUOMId = intItemUOMId
			, intPricingTypeId
			, strPricingType
			, strTransactionReference = 'Updated Contract'
			, intTransactionReferenceId = sh.intContractHeaderId
			, intTransactionReferenceDetailId = sh.intContractDetailId
			, strTransactionReferenceNo = strContractNumber + '-' + cast(sh.intContractSeq as nvarchar(10))
			, intFutureMarketId
			, intFutureMonthId
			, intUserId
			, dblBasis
			, dtmStartDate
			, dtmEndDate
		FROM
		(	SELECT ctsh.* 
			FROM tblCTSequenceHistory ctsh
			LEFT JOIN tblCTWeightGrade ctWG
				ON (	ctWG.intWeightGradeId = ctsh.intWeightId
						OR ctWG.intWeightGradeId = ctsh.intGradeId
					)
				AND ctWG.strWhereFinalized = 'Destination'
				AND ctsh.intContractTypeId = 2
			WHERE ctsh.intContractDetailId IN (SELECT intContractDetailId FROM #tblBasisDeliveries)
			AND ctsh.intContractStatusId IN (3) -- Cancelled
			AND ctsh.ysnStatusChange = 1
			AND ctWG.intWeightGradeId IS NULL
		) sh

		UNION ALL -- Cancelled and Short Closed Contracts (Reopened)
		SELECT 
			  strTransactionType =  CASE WHEN intContractTypeId = 1 THEN 'Purchase Basis Deliveries' ELSE 'Sales Basis Deliveries' END 
			, dtmTransactionDate = sh.dtmHistoryCreated
			, intContractHeaderId
			, intContractDetailId
			, strContractNumber
			, intContractSeq
			, intContractTypeId
			, sh.intContractStatusId
			, intCommodityId
			, intItemId
			, intEntityId
			, intCompanyLocationId
			, dblQty = (sh.dblQuantity - sh.dblBalance)
			, intQtyUOMId = intItemUOMId
			, intPricingTypeId
			, strPricingType
			, strTransactionReference = 'Updated Contract'
			, intTransactionReferenceId = sh.intContractHeaderId
			, intTransactionReferenceDetailId = sh.intContractDetailId
			, strTransactionReferenceNo = strContractNumber + '-' + cast(sh.intContractSeq as nvarchar(10))
			, intFutureMarketId
			, intFutureMonthId
			, intUserId
			, dblBasis
			, dtmStartDate
			, dtmEndDate
		from 
		(	SELECT ctsh.*
			FROM tblCTSequenceHistory ctsh
				LEFT JOIN tblCTWeightGrade ctWG
				ON (	ctWG.intWeightGradeId = ctsh.intWeightId
						OR ctWG.intWeightGradeId = ctsh.intGradeId
					)
				AND ctWG.strWhereFinalized = 'Destination'
				AND ctsh.intContractTypeId = 2
			WHERE ctsh.intContractDetailId IN (SELECT intContractDetailId FROM #tblBasisDeliveries)
			AND ctsh.intContractStatusId IN (4) -- Reopened
			AND ctsh.ysnStatusChange = 1
			AND ctWG.intWeightGradeId IS NULL
		) sh 
		OUTER APPLY (
			SELECT TOP 1 intContractStatusId
			FROM tblCTSequenceHistory
			WHERE intSequenceHistoryId < sh.intSequenceHistoryId
			ORDER BY intSequenceHistoryId DESC
		) prevHist
		WHERE ISNULL(prevHist.intContractStatusId, 0) <> 6

		UNION ALL
		-- PRICED SALE CONTRACT DWG (WITHOUT DELIVERIES - SHOULD HAVE NEGATING QTY UPON PRICED)
		-- USED PRICING SCREEN 
		SELECT DISTINCT
				strTransactionType  = 'Sales Basis Deliveries'
			, dtmTransactionDate = FD.dtmFixationDate
			, ctd.intContractHeaderId
			, ctd.intContractDetailId
			, cth.strContractNumber
			, ctd.intContractSeq
			, cth.intContractTypeId
			, ctd.intContractStatusId
			, cth.intCommodityId
			, ctd.intItemId
			, intEntityId = cth.intEntityId
			, intCompanyLocationId = ctd.intCompanyLocationId
			, dblQty = FD.dblQuantity  * -1 
			, intQtyUOMId = ctd.intItemUOMId
			, intPricingTypeId = cth.intPricingTypeId
			, strPricingType = pricingType.strPricingType
			, strTransactionReference = 'Price Fixation'
			, intTransactionReferenceId = FD.intPriceFixationId
			, intTransactionReferenceDetailId = FD.intPriceFixationDetailId
			, strTransactionReferenceNo = PC.strPriceContractNo
			, FD.intFutureMarketId
			, FD.intFutureMonthId
			, intUserId = PC.intCreatedById
			, ctd.dblBasis
			, ctd.dtmStartDate
			, ctd.dtmEndDate
		FROM tblCTPriceFixation PF 
		INNER JOIN tblCTPriceFixationDetail FD ON PF.intPriceFixationId = FD.intPriceFixationId
		INNER JOIN tblCTPriceContract PC ON PC.intPriceContractId = PF.intPriceContractId
		INNER JOIN tblCTContractHeader cth
			ON cth.intContractHeaderId = PF.intContractHeaderId
			AND cth.intContractTypeId = 2 -- SALE ONLY
		INNER JOIN tblCTContractDetail ctd
			ON ctd.intContractDetailId = PF.intContractDetailId
			AND ctd.intContractStatusId IN (3, 6) -- CANCELLED AND SHORT CLOSED
			AND DATEADD(dd, 0, DATEDIFF(dd, 0, ctd.dtmCreated)) >= @dtmRebuildStartDate
			AND DATEADD(dd, 0, DATEDIFF(dd, 0, ctd.dtmCreated)) <= @dtmRebuildEndDate
			AND ctd.intContractDetailId NOT IN (SELECT intContractDetailId FROM #tblBasisDeliveries)
		INNER JOIN tblCTWeightGrade ctWG
			ON (	ctWG.intWeightGradeId = cth.intWeightId
					OR ctWG.intWeightGradeId = cth.intGradeId
				)
			AND ctWG.strWhereFinalized = 'Destination'
		LEFT JOIN tblCTPricingType pricingType
			ON pricingType.intPricingTypeId = cth.intPricingTypeId
		LEFT JOIN tblCTPriceFixationDetailAPAR PFD ON PFD.intPriceFixationDetailId = FD.intPriceFixationDetailId
		WHERE PFD.intPriceFixationDetailAPARId IS NULL
		AND ISNULL(FD.dblQuantityAppliedAndPriced, 0) = 0 -- NO QTY APPLIED
		AND cth.intPricingTypeId IN (2, 3) -- HEADER IS BASIS OR HTA
		AND NOT EXISTS ( SELECT TOP 1 '' FROM tblCTContractBalanceLog cblog 
					WHERE cblog.intContractDetailId = ctd.intContractDetailId 
					AND cblog.strTransactionType IN ('Sales Basis Deliveries', 'Purchase Basis Deliveries')
					AND strTransactionReference <> 'Inventory Shipment'
				)
		
		-- PRICED SALE CONTRACT DWG (WITHOUT DELIVERIES - SHOULD HAVE NEGATING QTY UPON PRICED)
		-- NOT USED PRICING SCREEN (UPDATED PRICING THROUGH SEQUENCE)
		UNION ALL
		SELECT DISTINCT
				strTransactionType  = 'Sales Basis Deliveries'
			, dtmTransactionDate = ISNULL(ctd.dtmLastModified, ctd.dtmCreated)
			, ctd.intContractHeaderId
			, ctd.intContractDetailId
			, cth.strContractNumber
			, ctd.intContractSeq
			, cth.intContractTypeId
			, ctd.intContractStatusId
			, cth.intCommodityId
			, ctd.intItemId
			, intEntityId = cth.intEntityId
			, intCompanyLocationId = ctd.intCompanyLocationId
			, dblQty = ctd.dblQuantity  * -1 
			, intQtyUOMId = ctd.intItemUOMId
			, intPricingTypeId = cth.intPricingTypeId
			, strPricingType = pricingType.strPricingType
			, strTransactionReference = 'Updated Contract'
			, intTransactionReferenceId = ctd.intContractHeaderId
			, intTransactionReferenceDetailId = ctd.intContractDetailId
			, strTransactionReferenceNo = cth.strContractNumber + '-' + cast(ctd.intContractSeq as nvarchar(10))
			, ctd.intFutureMarketId
			, ctd.intFutureMonthId
			, intUserId = ctd.intCreatedById
			, ctd.dblBasis
			, ctd.dtmStartDate
			, ctd.dtmEndDate
		FROM tblCTContractHeader cth
		INNER JOIN tblCTContractDetail ctd
			ON cth.intContractHeaderId = ctd.intContractHeaderId
			AND cth.intContractTypeId = 2 -- SALE ONLY
			AND ctd.intContractStatusId IN (3, 6) -- CANCELLED AND SHORT CLOSED
			AND DATEADD(dd, 0, DATEDIFF(dd, 0, ctd.dtmCreated)) >= @dtmRebuildStartDate
			AND DATEADD(dd, 0, DATEDIFF(dd, 0, ctd.dtmCreated)) <= @dtmRebuildEndDate
			AND ctd.intContractDetailId NOT IN (SELECT intContractDetailId FROM #tblBasisDeliveries)
		INNER JOIN tblCTWeightGrade ctWG
		ON (	ctWG.intWeightGradeId = cth.intWeightId
				OR ctWG.intWeightGradeId = cth.intGradeId
			)
		AND ctWG.strWhereFinalized = 'Destination'
		LEFT JOIN tblCTPricingType pricingType
			ON pricingType.intPricingTypeId = cth.intPricingTypeId
		LEFT JOIN tblCTPriceFixation PF
			ON ctd.intContractDetailId = PF.intContractDetailId
		WHERE PF.intPriceFixationId IS NULL
		AND ctd.dblBalance = ctd.dblQuantity
		AND cth.intPricingTypeId IN (2, 3) -- HEADER IS BASIS OR HTA
		AND ctd.intPricingTypeId = 1 -- DETAIL IS PRICED
		AND NOT EXISTS ( SELECT TOP 1 '' FROM tblCTContractBalanceLog cblog 
					WHERE cblog.intContractDetailId = ctd.intContractDetailId 
					AND cblog.strTransactionType IN ('Sales Basis Deliveries', 'Purchase Basis Deliveries')
					AND strTransactionReference <> 'Inventory Shipment'
				)

	) t

	INSERT INTO @cbLog (strBatchId
		, dtmTransactionDate
		, strTransactionType
		, strTransactionReference
		, intTransactionReferenceId
		, intTransactionReferenceDetailId
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
		, dblQty
		, dblOrigQty
		, intQtyUOMId
		, intPricingTypeId
		, intContractStatusId
		, intFutureMarketId
		, intFutureMonthId
		, intUserId
		, intActionId
		, dblBasis
		, dtmStartDate
		, dtmEndDate
	)
	SELECT 
		strBatch = NULL
		, dtmTransactionDate
		, strTransactionType
		, strTransactionReference
		, intTransactionReferenceId
		, intTransactionReferenceDetailId
		, strTransactionReferenceNo
		, intContractDetailId
		, intContractHeaderId
		, strContractNumber
		, intContractSeq
		, intContractTypeId
		, intEntityId
		, BD.intCommodityId
		, BD.intItemId
		, intCompanyLocationId
		, dblQty
		, dblOrigQty = dblQty
		, intQtyUOMId = CUM.intCommodityUnitMeasureId
		, intPricingTypeId
		, intContractStatusId
		, intFutureMarketId
		, intFutureMonthId
		, intUserId
		, intActionId  = 1 --Rebuild
		, BD.dblBasis
		, BD.dtmStartDate
		, BD.dtmEndDate
			
	FROM #tblFinalBasisDeliveries BD
	inner join tblICItemUOM IUOM on IUOM.intItemUOMId = BD.intQtyUOMId
	inner join tblICCommodityUnitMeasure CUM on CUM.intCommodityId = BD.intCommodityId AND CUM.intUnitMeasureId = IUOM.intUnitMeasureId 


	EXEC uspCTLogContractBalance @cbLog, 1
	
	--=============================================
	-- END - NON-OPEN CONTRACT - BASIS DELIVERIES 
	--=============================================

	DROP TABLE #tempContracts
	DROP TABLE #tempOrigContract
	DROP TABLE #tmpNonOpenContractsToRebuild
	DROP TABLE #tblBasisDeliveries
	DROP TABLE #tblFinalBasisDeliveries
END