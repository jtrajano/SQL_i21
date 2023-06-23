CREATE PROCEDURE [dbo].[uspRKRebuildSummaryLog]
	@intCurrentUserId INT	
	, @ysnCBOnly BIT = 0 -- 1 WILL REBUILD CONTRACT BALANCES ONLY (FOR TESTING) - WILL ENHANCE REBUILD RUNTIME.
AS

BEGIN TRY
	DECLARE @RebuildLogId INT
	
	INSERT INTO tblRKRebuildSummaryLog(dtmRebuildDate, intUserId, ysnSuccess)
	VALUES (GETDATE(), @intCurrentUserId, 0)
	
	SET @RebuildLogId = SCOPE_IDENTITY()

	IF EXISTS (SELECT TOP 1 1 FROM tblRKCompanyPreference WHERE ysnAllowRebuildSummaryLog = 0)
	BEGIN
		RAISERROR('You are not allowed to rebuild the Summary Log!', 16, 1)
	END 
		
	-- Truncate table
	TRUNCATE TABLE tblRKSummaryLog
	TRUNCATE TABLE tblCTContractBalanceLog
	TRUNCATE TABLE tblRKRebuildRTSLog
	--Update ysnAllowRebuildSummaryLog to FALSE
	UPDATE tblRKCompanyPreference SET ysnAllowRebuildSummaryLog = 0
	
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKSummaryLog')
	BEGIN
		DECLARE @ExistingHistory AS RKSummaryLog

		--=======================================
		--				CONTRACTS
		--=======================================
		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Populate RK Summary Log - Contract')
		
		DECLARE @cbLog AS CTContractBalanceLog
		
		SELECT
			CH.intContractHeaderId
			,CD.intContractDetailId
			,CH.dtmContractDate
			,CH.strContractNumber
			,CD.intContractSeq
			,CH.intContractTypeId
			,CH.intPricingTypeId as intHeaderPricingTypeId
			,CD.intPricingTypeId
			,dblQtyBalance = CD.dblBalance
			,CH.ysnLoad
			,CH.dblQuantityPerLoad
			,CH.intCommodityId
			,C.strCommodityCode
			,CD.intItemId
			,CD.intCompanyLocationId
			,CD.intFutureMarketId 
			,CD.intFutureMonthId 
			,CD.dtmStartDate 
			,CD.dtmEndDate 
			,intQtyUOMId = CUM.intCommodityUnitMeasureId
			,CD.dblFutures
			,CD.dblBasis
			,CD.intBasisUOMId 
			,CD.intBasisCurrencyId 
			,intPriceUOMId  = CD.intPriceItemUOMId
			,CD.intContractStatusId 
			,CD.intBookId 
			,CD.intSubBookId 
			,intUserId = CD.intCreatedById
		INTO #tempContracts
		FROM tblCTContractHeader CH
			INNER JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
			INNER JOIN tblICCommodity C ON C.intCommodityId = CH.intCommodityId
			INNER JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = CD.intItemUOMId
			LEFT JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityId = CH.intCommodityId AND CUM.intUnitMeasureId = IUOM.intUnitMeasureId
		WHERE CD.intContractStatusId IN (1,4) AND CD.dblBalance <> 0
			--AND dtmContractDate between '01/01/1900' and getdate()
	
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

		declare @intContractHeaderId int
			, @intContractDetailId int
			, @intContractTypeId int
			, @strContractNumber NVARCHAR(100)
			, @intContractSeq int
			, @intHeaderPricingType INT
			, @intPricingTypeId INT
			, @ysnLoad BIT
			, @dblQuantityPerLoad numeric(18,6)
			, @intCommodityId int
			, @strCommodityCode NVARCHAR(100)
			, @intItemId int
			, @intEntityId int
			, @intLocationId int
			, @intFutureMarketId int
			, @intFutureMonthId int
			, @dtmStartDate datetime
			, @dtmEndDate datetime
			, @intQtyUOMId int
			, @dblFutures numeric(18,6)
			, @dblBasis numeric(18,6)
			, @intBasisUOMId int
			, @intBasisCurrencyId int
			, @intPriceUOMId int
			, @intContractStatusId int
			, @intBookId int
			, @intSubBookId int
			, @intUserId int

		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Begin Raw Contract Balance Loop.')

		WHILE EXISTS (SELECT TOP 1 1 FROM #tempContracts)
		BEGIN
			SELECT TOP 1 
				  @intContractHeaderId = intContractHeaderId
				, @intContractDetailId = intContractDetailId 
				, @intContractTypeId = intContractTypeId
				, @strContractNumber = strContractNumber
				, @intContractSeq = intContractSeq
				, @intHeaderPricingType = intHeaderPricingTypeId
				, @intPricingTypeId = intPricingTypeId
				, @ysnLoad = ysnLoad
				, @dblQuantityPerLoad = dblQuantityPerLoad
				, @intCommodityId = intCommodityId
				, @strCommodityCode = strCommodityCode
				, @intItemId  = intItemId
				, @intLocationId = intCompanyLocationId
				, @intFutureMarketId  = intFutureMarketId
				, @intFutureMonthId = intFutureMonthId
				, @dtmStartDate = dtmStartDate
				, @dtmEndDate = dtmEndDate
				, @intQtyUOMId = intQtyUOMId
				, @dblFutures =  dblFutures
				, @dblBasis = dblBasis
				, @intBasisUOMId = intBasisUOMId
				, @intBasisCurrencyId = intBasisCurrencyId
				, @intPriceUOMId =  intPriceUOMId
				, @intContractStatusId = intContractStatusId
				, @intBookId = intBookId
				, @intSubBookId = intSubBookId
				, @intUserId = intUserId
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
			FROM #tmpCTSequenceHistory SH
			LEFT JOIN vyuCTSequenceUsageHistory SUH
				ON SUH.intSequenceUsageHistoryId = SH.intSequenceUsageHistoryId
				AND SUH.strFieldName = 'Balance'
				AND SUH.intContractDetailId = @intContractDetailId
			OUTER APPLY 
				(
					SELECT TOP 1 * FROM #tmpCTSequenceHistory CTSH
					WHERE CTSH.rowNum = SH.rowNum - 1
					ORDER BY intSequenceHistoryId ASC
				) LAGSH
			WHERE SH.intContractDetailId = @intContractDetailId
			and SH.ysnBalanceChange = 1
			and SH.intPricingTypeId <> 5
			AND SUH.intSequenceUsageHistoryId IS NULL
			AND ((SH.intPricingTypeId = @intHeaderPricingType
					AND NOT (ISNULL(SH.ysnFuturesChange, 0) = 1 AND SH.dblOldFutures IS NOT NULL AND SH.dblFutures IS NULL)
					AND NOT (ISNULL(SH.ysnBasisChange, 0) = 1 AND SH.dblOldBasis IS NOT NULL AND SH.dblBasis IS NULL)
				 )
					OR 
				 (SH.intPricingTypeId <> @intHeaderPricingType
					AND ((ISNULL(SH.ysnFuturesChange, 0) <> 1) OR (ISNULL(SH.ysnFuturesChange, 0) = 1 AND SH.dblOldFutures IS NOT NULL AND SH.dblFutures IS NOT NULL))
					AND ((ISNULL(SH.ysnBasisChange, 0) <> 1) OR (ISNULL(SH.ysnBasisChange, 0) = 1 AND SH.dblOldBasis IS NOT NULL AND SH.dblBasis IS NOT NULL))
				 )
				)
			AND LAGSH.intPricingTypeId = SH.intPricingTypeId

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
			AND SUH.intSequenceUsageHistoryId IS NULL
			AND SH.intPricingTypeId <> @intHeaderPricingType
			AND ( (SH.ysnFuturesChange = 1 AND SH.dblOldFutures IS NULL) 
				 OR 
				  (SH.ysnBasisChange = 1 AND SH.dblOldBasis IS NULL)
				)
			
			-- SCENARIO: BALANCE CHANGE WITH PRICING TYPE CHANGE (WHEN OLD IS PRICED AND UPDATED TO UNPRICED)
			-- SHOULD ADD PRICED QTY
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
				, intPricingTypeId  = 1 -- PRICED
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
			AND SUH.intSequenceUsageHistoryId IS NULL
			AND SH.intPricingTypeId = @intHeaderPricingType
			AND ( (SH.ysnFuturesChange = 1 AND SH.dblOldFutures IS NOT NULL AND SH.dblFutures IS NULL) 
				 OR 
				  (SH.ysnBasisChange = 1 AND SH.dblOldBasis IS NOT NULL AND SH.dblBasis IS NULL)
				)
			
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
				, dblTransactionQuantity = CASE WHEN @ysnLoad = 1 THEN SUH.dblTransactionQuantity * @dblQuantityPerLoad 
												ELSE CASE WHEN SH.strPricingStatus = 'Partially Priced' AND CASE WHEN SH.dblQtyPriced = 0 THEN 0 ELSE SH.dblQtyPriced - (SH.dblQuantity - SH.dblBalance) END < 0
															AND (SH.dblOldBalance - SH.dblBalance) * -1 < (CASE WHEN SH.dblQtyPriced = 0 THEN 0 ELSE SH.dblQtyPriced - (SH.dblQuantity - SH.dblBalance) END) 
													THEN 
														CASE WHEN SH.dblQtyPriced = 0 THEN 0 ELSE SH.dblQtyPriced - (SH.dblQuantity - SH.dblBalance) END
													ELSE SUH.dblTransactionQuantity  END
												END
				, SUH.strScreenName  
				, @intContractHeaderId
				, @intContractDetailId
				, intPricingTypeId = CASE WHEN SH.strPricingStatus = 'Partially Priced' 
												AND CASE WHEN SH.dblQtyPriced = 0 THEN 0 ELSE SH.dblQtyPriced - (SH.dblQuantity - SH.dblBalance) END >= 0 
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
												AND CASE WHEN SH.dblQtyPriced = 0 THEN 0 ELSE SH.dblQtyPriced - (SH.dblQuantity - SH.dblBalance) END >= 0 
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
												THEN SUH.dblTransactionQuantity * @dblQuantityPerLoad * CASE WHEN SH.intContractTypeId = 1 THEN -1 ELSE 1 END
												ELSE SUH.dblTransactionQuantity * CASE WHEN SH.intContractTypeId = 1 THEN 1 ELSE -1 END END
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
													OR (SH.dblOldBalance < SH.dblBalance 
													AND (  (SH.dblQuantity - SH.dblOldBalance) - (SH.dblOldBalance - SH.dblBalance) <= SH.dblQtyPriced)
															OR 
														   (SH.dblBalance = SH.dblQuantity AND SH.dblQtyPriced > 0)
														)
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
			--AND (SH.dblBalance - SH.dblOldBalance) <> SH.dblQtyPriced
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
													THEN SUH.dblTransactionQuantity * @dblQuantityPerLoad * CASE WHEN SH.intContractTypeId = 1 THEN 1 ELSE -1 END
													ELSE SUH.dblTransactionQuantity * CASE WHEN SH.intContractTypeId = 1 THEN -1 ELSE 1 END END
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
														OR (SH.dblOldBalance < SH.dblBalance 
														AND (  (SH.dblQuantity - SH.dblOldBalance) - (SH.dblOldBalance - SH.dblBalance) <= SH.dblQtyPriced)
																OR 
															   (SH.dblBalance = SH.dblQuantity AND SH.dblQtyPriced > 0)
														)
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
			CROSS APPLY (
				SELECT TOP 1 ysnExists = 1
				FROM tblCTSequenceHistory suh
				WHERE suh.intContractDetailId = @intContractDetailId
				AND intSequenceUsageHistoryId = negateHistory.intSequenceUsageHistoryId
				AND dblOldBalance IS NOT NULL
			) createHistorySequenceHistory
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
				, dblTransactionQuantity =  CASE WHEN @ysnLoad = 1 THEN SUH.dblTransactionQuantity * @dblQuantityPerLoad * CASE WHEN SH.intContractTypeId = 1 THEN -1 ELSE 1 END
												 ELSE SUH.dblTransactionQuantity END
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
				, intPricingTypeId
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
				, intPricingTypeId
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
											AND dblCumulativeBalance > dblActualPriceFixation AND SH.dblBalance > dblActualPriceFixation AND dblCumulativeBalance = dblQtyPriced --325 - 25
													AND dblCumulativeBalance <= dblCumulativeQtyPriced AND SH.dblBalance = SH.dblQtyUnpriced) 
									THEN 0
								WHEN ( strPricingStatus <> 'Unpriced'
											AND ((dblCumulativeBalance > dblActualPriceFixation AND SH.dblBalance > dblActualPriceFixation AND dblCumulativeBalance <> dblQtyPriced)
													AND dblCumulativeBalance <= dblCumulativeQtyPriced AND (dblLagOldBalance * 2) = dblLagQtyPriced)) 
									THEN 0
								WHEN (SH.intLagPricingTypeId <> SH.intPricingTypeId
									AND SH.strLagPricingStatus = 'Fully Priced'
									AND SH.strPricingStatus = 'Partially Priced'
									AND SH.ysnBalanceChange = 1 
									AND SH.ysnCashPriceChange = 1
									AND SH.ysnFuturesChange = 1
									AND SH.dblBalance = SH.dblQuantity
									AND SH.dblOldBalance = SH.dblQtyPriced
								)	THEN SH.dblQtyUnpriced * -1
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
									AND SH.ysnBasisChange IS NULL
									AND SH.ysnFuturesChange IS NULL
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
									) THEN dblOldBalance * -1							
								WHEN (SH.intLagPricingTypeId <> SH.intPricingTypeId
									AND SH.strLagPricingStatus = 'Partially Priced'
									AND SH.strPricingStatus = 'Fully Priced'
									AND SH.ysnBalanceChange IS NULL
									AND SH.ysnCashPriceChange = 1
									AND SH.ysnFuturesChange = 1
									AND ((dblLagQtyPriced - dblLagQtyUnpriced) > (SH.dblQtyPriced / 2))
									) THEN 0
								WHEN SH.dblBalance < dblActualPriceFixation THEN SH.dblBalance
								WHEN  strPricingStatus = 'Unpriced' THEN SH.dblBalance * -1
								ELSE dblActualPriceFixation - dblCumulativeBalance END
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
					AND SH.strLagPricingStatus = 'Fully Priced'
					AND SH.strPricingStatus = 'Unpriced'
					AND SH.ysnBalanceChange = 1
					AND SH.ysnBasisChange IS NULL
					AND SH.ysnFuturesChange IS NULL
					)
					OR (SH.intLagPricingTypeId <> SH.intPricingTypeId
					AND SH.strLagPricingStatus = 'Fully Priced'
					AND SH.strPricingStatus = 'Partially Priced'
					AND SH.ysnBalanceChange = 1
					AND SH.ysnCashPriceChange = 1
					AND SH.ysnFuturesChange = 1
					AND SH.dblBalance = SH.dblQuantity
					AND SH.dblOldBalance = SH.dblQtyPriced
					)
				 )
			AND (SH.intPricingTypeId <> 1
				 OR
				 (SH.intPricingTypeId = 1 AND SH.intPricingTypeId <> intLagPricingTypeId)
				)

			union all -- Counter entry when price fixing a Basis (Price Fixation of Basis thru Contract Pricing Screen or Updating Sequence Pricing Type to 'Priced')
			select 
				dtmHistoryCreated
				, @strContractNumber
				, @intContractSeq
				, @intContractTypeId
				, dblQuantity = CASE WHEN SH.intContractStatusId = 6 THEN 0 -- CANCELLED
								WHEN strPricingStatus = 'Partially Priced' AND SH.dblQtyPriced <> 0
											AND dblCumulativeBalance > dblActualPriceFixation AND SH.dblBalance > dblActualPriceFixation AND dblCumulativeBalance = dblQtyPriced
													AND dblCumulativeBalance <= dblCumulativeQtyPriced AND SH.dblBalance = SH.dblQtyUnpriced 
									THEN 0
								WHEN ( strPricingStatus <> 'Unpriced'
											AND ((dblCumulativeBalance > dblActualPriceFixation AND SH.dblBalance > dblActualPriceFixation AND dblCumulativeBalance <> dblQtyPriced)
													AND dblCumulativeBalance <= dblCumulativeQtyPriced AND (dblLagOldBalance * 2) = dblLagQtyPriced)) 
									THEN 0
								WHEN (SH.intLagPricingTypeId <> SH.intPricingTypeId
									AND SH.strLagPricingStatus = 'Fully Priced'
									AND SH.strPricingStatus = 'Partially Priced'
									AND SH.ysnBalanceChange = 1
									AND SH.ysnCashPriceChange = 1
									AND SH.ysnFuturesChange = 1
									AND SH.dblBalance = SH.dblQuantity
									AND SH.dblOldBalance = SH.dblQtyPriced
								)	THEN SH.dblQtyUnpriced * -1
								WHEN	strPricingStatus <> 'Unpriced'
										AND ((dblCumulativeBalance > dblActualPriceFixation AND SH.dblBalance > dblActualPriceFixation AND dblCumulativeBalance <> dblQtyPriced) 
													OR dblCumulativeBalance <= dblCumulativeQtyPriced)  
									THEN dblActualPriceFixation					
								WHEN strPricingStatus = 'Partially Priced' AND dblCumulativeBalance = dblQtyPriced AND dblLagQtyPriced = 0
									THEN 0
								WHEN strPricingStatus = 'Partially Priced' 
									AND ROUND(SH.dblBalance, 1) = ROUND(SH.dblQtyUnpriced, 1) THEN SH.dblBalance - SH.dblQtyUnpriced
								-- PRICED TO UNPRICED
								WHEN (ISNULL(P.intPriceFixationId, 0) = 0
								 	AND SH.intLagPricingTypeId <> SH.intPricingTypeId
								 	AND SH.strLagPricingStatus = 'Fully Priced'
								 	AND SH.strPricingStatus = 'Unpriced'
								 	AND SH.ysnBalanceChange = 1
								 	AND SH.ysnBasisChange IS NULL
								 	AND SH.ysnFuturesChange IS NULL
								 	) THEN SH.dblBalance * -1
								WHEN (SH.intLagPricingTypeId <> SH.intPricingTypeId
									AND SH.strLagPricingStatus = 'Partially Priced'
									AND SH.strPricingStatus = 'Fully Priced'
									AND SH.ysnBalanceChange IS NULL
									AND SH.ysnCashPriceChange = 1
									AND SH.ysnFuturesChange = 1
									AND ((dblLagQtyPriced - dblLagQtyUnpriced) > (SH.dblQtyPriced / 2))
									) THEN 0
								WHEN SH.dblBalance < dblActualPriceFixation THEN SH.dblBalance
								WHEN  strPricingStatus = 'Unpriced' THEN SH.dblBalance * -1
								ELSE dblActualPriceFixation - dblCumulativeBalance END * -1
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
					 )
					 OR
					 -- PRICED TO UNPRICED
					 (ISNULL(P.intPriceFixationId, 0) = 0
					 AND SH.intLagPricingTypeId <> SH.intPricingTypeId
					 AND SH.strLagPricingStatus = 'Fully Priced'
					 AND SH.strPricingStatus = 'Unpriced'
					 AND SH.ysnBalanceChange = 1
					 AND SH.ysnBasisChange IS NULL
					 AND SH.ysnFuturesChange IS NULL
					 )
					 OR (SH.intLagPricingTypeId <> SH.intPricingTypeId
					 AND SH.strLagPricingStatus = 'Fully Priced'
					 AND SH.strPricingStatus = 'Partially Priced'
					 AND SH.ysnBalanceChange = 1
					 AND SH.ysnCashPriceChange = 1
					 AND SH.ysnFuturesChange = 1
					 AND SH.dblBalance = SH.dblQuantity
					 AND SH.dblOldBalance = SH.dblQtyPriced
					 )
				 )
			AND (SH.intPricingTypeId <> 1
				 OR
				 (SH.intPricingTypeId = 1 AND SH.intPricingTypeId <> intLagPricingTypeId)
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
			,dblQuantity = CASE WHEN SH.intQtyUOMId IS NOT NULL 
							THEN SH.dblQuantity
							ELSE ISNULL(dbo.fnCalculateQtyBetweenUOM (
									  CD.intItemUOMId
									, iuomCDefault.intItemUOMId
									, SH.dblQuantity
								), 0.00)
							END
			,intQtyUOMId = ISNULL(SH.intQtyUOMId, cuomDefault.intCommodityUnitMeasureId)
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
		FROM @tblCTSequenceHistory SH
		INNER JOIN tblCTPricingType PT on PT.intPricingTypeId = SH.intPricingTypeId
		LEFT JOIN tblICCommodityUnitMeasure cuomDefault
			ON cuomDefault.intCommodityId = SH.intCommodityId
			AND cuomDefault.ysnDefault = 1
		LEFT JOIN tblICItemUOM iuomCDefault
			ON iuomCDefault.intItemId = SH.intItemId
			AND iuomCDefault.intUnitMeasureId = cuomDefault.intUnitMeasureId
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractDetailId = SH.intContractDetailId
			AND SH.intQtyUOMId IS NULL

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

		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Begin Contract Balance Logging.')
		EXEC uspCTLogContractBalance @cbLog, 1
		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('End Contract Balance Logging.')

		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('End Populate RK Summary Log - Contract')
		DELETE FROM @cbLog

		--=======================================
		--				BASIS DELIVERIES
		--=======================================
		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Populate RK Summary Log - Basis Deliveries')

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
		AND cd.intContractStatusId IN (1,4)

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
		AND cd.intContractStatusId IN (1,4)

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
		AND cd.intContractStatusId IN (1,4)

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
		AND cd.intContractStatusId IN (1,4)

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
		AND cd.intContractStatusId IN (1,4)
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
		AND cd.intContractStatusId IN (1,4)

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
		AND cd.intContractStatusId IN (1,4)

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
		AND cd.intContractStatusId IN (1,4)

	-- END #tblBasisDeliveries INSERT --

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
				AND ctd.intContractStatusId IN (1, 4) -- OPEN AND REOPENED
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
			

			UNION ALL
			-- PRICED SALE CONTRACT DWG (WITHOUT DELIVERIES - SHOULD HAVE NEGATING QTY UPON PRICED)
			-- NOT USED PRICING SCREEN (UPDATED PRICING THROUGH SEQUENCE)
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
				AND ctd.intContractStatusId IN (1, 4) -- OPEN AND REOPENED
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

		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('End Populate RK Summary Log - Basis Deliveries')

		IF @ysnCBOnly = 0
		BEGIN
		--=======================================
		--				DERIVATIVES
		--=======================================
		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Populate RK Summary Log - Derivatives')

		INSERT INTO @ExistingHistory(
			  strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intBookId
			, intSubBookId
			, intFutOptTransactionId
			, intFutureMarketId
			, intFutureMonthId
			, dblNoOfLots
			, dblContractSize
			, dblPrice
			, intEntityId
			, intUserId
			, intLocationId
			, intCommodityUOMId
			, strInOut
			, strNotes
			, strMiscFields
			, intOptionMonthId 
			, strOptionMonth 
			, dblStrike
			, strOptionType
			, strInstrumentType
			, intBrokerageAccountId
			, strBrokerAccount
			, strBroker
			, strBuySell
			, ysnPreCrush
			, strBrokerTradeNo
			, intActionId)
		SELECT
			  strBucketType = 'Derivatives' 
			, strTransactionType = 'Derivative Entry'
			, intTransactionRecordId = der.intFutOptTransactionId
			, intTransactionRecordHeaderId = der.intFutOptTransactionHeaderId
			, strDistributionType = der.strNewBuySell
			, strTransactionNumber = der.strInternalTradeNo
			, dtmTransactionDate = der.dtmTransactionDate
			, intContractDetailId = der.intContractDetailId
			, intContractHeaderId = der.intContractHeaderId
			, intCommodityId = der.intCommodityId
			, intBookId = der.intBookId
			, intSubBookId = der.intSubBookId
			, der.intFutOptTransactionId
			, intFutureMarketId = der.intFutureMarketId
			, intFutureMonthId = der.intFutureMonthId
			, dblNoOfLots = der.dblNewNoOfLots
			, dblContractSize = m.dblContractSize
			, dblPrice = der.dblPrice
			, intEntityId = der.intEntityId
			, intUserId = der.intUserId
			, intLocationId = ISNULL(der.intLocationId, fot.intLocationId)
			, cUOM.intCommodityUnitMeasureId
			, strInOut = CASE WHEN UPPER(der.strNewBuySell) = 'BUY' THEN 'IN' ELSE 'OUT' END
			, strNotes = strNotes
			, strMiscFields = NULL
			, intOptionMonthId =  der.intOptionMonthId
			, strOptionMonth =  strOptionMonth
			, dblStrike =  der.dblStrike
			, strOptionType =  der.strOptionType
			, strInstrumentType =  strInstrumentType
			, intBrokerageAccountId =  intBrokerId
			, strBrokerAccount =  strBrokerAccount
			, strBroker =  strBroker
			, strBuySell =  strNewBuySell
			, ysnPreCrush =  ISNULL(der.ysnPreCrush,0)
			, strBrokerTradeNo = der.strBrokerTradeNo
			, intActionId  = 1 --Rebuild
		FROM vyuRKGetFutOptTransactionHistory der
		JOIN tblRKFutureMarket m ON m.intFutureMarketId = der.intFutureMarketId
		LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = der.intCommodityId AND cUOM.intUnitMeasureId = m.intUnitMeasureId
		LEFT JOIN tblRKFutOptTransaction fot
			ON fot.intFutOptTransactionId = der.intFutOptTransactionId
		ORDER BY der.dtmTransactionDate

		EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0

		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('End Populate RK Summary Log - Derivatives')
		DELETE FROM @ExistingHistory

		--=======================================
		--			MATCH DERIVATIVES
		--=======================================
		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Populate RK Summary Log - Match Derivatives')
		
		INSERT INTO @ExistingHistory(
			  strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intLocationId
			, intBookId
			, intSubBookId
			, intFutOptTransactionId
			, intFutureMarketId
			, intFutureMonthId
			, strNotes
			, dblNoOfLots
			, dblContractSize
			, dblPrice
			, intEntityId
			, intUserId
			, intCommodityUOMId
			, strMiscFields
			, intActionId)
		SELECT
			  strBucketType = 'Derivatives'
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intLocationId
			, intBookId
			, intSubBookId
			, intFutOptTransactionId
			, intFutureMarketId
			, intFutureMonthId
			, strNotes
			, dblNoOfLots
			, dblContractSize
			, dblPrice
			, intEntityId
			, intUserId
			, intCommodityUOMId
			, strMiscFields
			, intActionId  = 1 --Rebuild
		FROM (
			SELECT strTransactionType = 'Match Derivatives'
				, intTransactionRecordId = history.intLFutOptTransactionId
				, intTransactionRecordHeaderId = de.intFutOptTransactionHeaderId
				, strDistributionType  = de.strBuySell
				, strTransactionNumber = de.strInternalTradeNo
				, dtmTransactionDate = history.dtmMatchDate
				, intContractDetailId = history.intMatchFuturesPSDetailId
				, intContractHeaderId = history.intMatchFuturesPSHeaderId
				, intCommodityId = de.intCommodityId
				, de.intLocationId
				, intBookId = de.intBookId
				, intSubBookId = de.intSubBookId
				, intFutOptTransactionId = history.intLFutOptTransactionId
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, strNotes = 'IN'
				, dblNoOfLots = history.dblMatchQty
				, dblContractSize = FutMarket.dblContractSize
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = e.intEntityId
				, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
				, intMatchDerivativeHistoryId
				, strMiscFields =  NULL
				, ysnPreCrush = ISNULL(ysnPreCrush,0)
			FROM tblRKMatchDerivativesHistory history
			JOIN tblRKMatchFuturesPSHeader header ON header.intMatchFuturesPSHeaderId = history.intMatchFuturesPSHeaderId
			JOIN tblRKMatchFuturesPSDetail detail ON detail.intMatchFuturesPSDetailId = history.intMatchFuturesPSDetailId
			JOIN tblRKFutOptTransaction de ON de.intFutOptTransactionId = history.intLFutOptTransactionId
			LEFT JOIN tblRKFutureMarket FutMarket ON FutMarket.intFutureMarketId = de.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = de.intCommodityId AND cUOM.intUnitMeasureId = FutMarket.intUnitMeasureId
			LEFT JOIN (
				SELECT strUserName = e.strName
					, e.intEntityId
				FROM tblEMEntity e
				JOIN tblEMEntityType et ON et.intEntityId = e.intEntityId AND et.strType = 'User'
			) e ON e.strUserName = history.strUserName

			UNION ALL SELECT strTransactionType = 'Match Derivatives'
				, intTransactionRecordId = history.intSFutOptTransactionId
				, intTransactionRecordHeaderId = de.intFutOptTransactionHeaderId
				, strDistributionType  = de.strBuySell
				, strTransactionNumber = de.strInternalTradeNo
				, dtmTransactionDate = history.dtmMatchDate
				, intContractDetailId = history.intMatchFuturesPSDetailId
				, intContractHeaderId = history.intMatchFuturesPSHeaderId
				, intCommodityId = de.intCommodityId
				, intLocationId
				, intBookId = de.intBookId
				, intSubBookId = de.intSubBookId
				, intFutOptTransactionId = history.intSFutOptTransactionId
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, strNotes = 'OUT'
				, dblNoOfLots = history.dblMatchQty * - 1
				, dblContractSize = FutMarket.dblContractSize
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = e.intEntityId
				, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
				, intMatchDerivativeHistoryId
				, strMiscFields = NULL
				, ysnPreCrush = ISNULL(ysnPreCrush,0) 
			FROM tblRKMatchDerivativesHistory history
			JOIN tblRKMatchFuturesPSHeader header ON header.intMatchFuturesPSHeaderId = history.intMatchFuturesPSHeaderId
			JOIN tblRKMatchFuturesPSDetail detail ON detail.intMatchFuturesPSDetailId = history.intMatchFuturesPSDetailId
			JOIN tblRKFutOptTransaction de ON de.intFutOptTransactionId = history.intSFutOptTransactionId
			LEFT JOIN tblRKFutureMarket FutMarket ON FutMarket.intFutureMarketId = de.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = de.intCommodityId AND cUOM.intUnitMeasureId = FutMarket.intUnitMeasureId
			LEFT JOIN (
				SELECT strUserName = e.strName
					, e.intEntityId
				FROM tblEMEntity e
				JOIN tblEMEntityType et ON et.intEntityId = e.intEntityId AND et.strType = 'User'
			) e ON e.strUserName = history.strUserName
		) tbl
		ORDER BY intMatchDerivativeHistoryId

		EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0

		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('End Populate RK Summary Log - Match Derivatives')
		DELETE FROM @ExistingHistory

		--=======================================
		--			Option Derivatives
		--=======================================
		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Populate RK Summary Log - Option Derivatives')
		
		INSERT INTO @ExistingHistory(
			  strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intLocationId
			, intBookId
			, intSubBookId
			, intFutOptTransactionId
			, intFutureMarketId
			, intFutureMonthId
			, strNotes
			, dblNoOfLots
			, dblContractSize
			, dblPrice
			, intEntityId
			, intUserId
			, intCommodityUOMId
			, strMiscFields
			, ysnPreCrush
			, intActionId)
		SELECT
			  strBucketType = 'Derivatives' 
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intLocationId
			, intBookId
			, intSubBookId
			, intFutOptTransactionId
			, intFutureMarketId
			, intFutureMonthId
			, strNotes
			, dblNoOfLots
			, dblContractSize
			, dblPrice
			, intEntityId
			, intUserId
			, intCommodityUOMId
			, strMiscFields
			, ysnPreCrush
			, intActionId  = 1 --Rebuild
		FROM (
			SELECT strTransactionType = 'Expired Options'
				, intTransactionRecordId = detail.intFutOptTransactionId
				, intTransactionRecordHeaderId = de.intFutOptTransactionHeaderId
				, strDistributionType = de.strBuySell
				, strTransactionNumber = de.strInternalTradeNo
				, dtmTransactionDate = detail.dtmExpiredDate
				, intContractDetailId = detail.intOptionsPnSExpiredId
				, intContractHeaderId = header.intOptionsMatchPnSHeaderId
				, intCommodityId = de.intCommodityId
				, de.intLocationId
				, intBookId = de.intBookId
				, intSubBookId = de.intSubBookId
				, intFutOptTransactionId = detail.intFutOptTransactionId
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, strNotes = CASE WHEN de.strBuySell = 'Buy' THEN 'IN' ELSE 'OUT' END
				, dblNoOfLots = detail.dblLots * - 1
				, dblContractSize = FutMarket.dblContractSize
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = @intCurrentUserId
				, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
				, strMiscFields =  NULL
				, ysnPreCrush = ISNULL(ysnPreCrush,0)
			FROM tblRKOptionsPnSExpired detail
			JOIN tblRKOptionsMatchPnSHeader header ON header.intOptionsMatchPnSHeaderId = detail.intOptionsMatchPnSHeaderId
			JOIN tblRKFutOptTransaction de ON de.intFutOptTransactionId = detail.intFutOptTransactionId
			LEFT JOIN tblRKFutureMarket FutMarket ON FutMarket.intFutureMarketId = de.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = de.intCommodityId AND cUOM.intUnitMeasureId = FutMarket.intUnitMeasureId

			UNION ALL SELECT strTransactionType = 'Excercised/Assigned Options'
				, intTransactionRecordId = detail.intFutOptTransactionId
				, intTransactionRecordHeaderId = de.intFutOptTransactionHeaderId
				, strDistributionType = de.strBuySell
				, strTransactionNumber = de.strInternalTradeNo
				, dtmTransactionDate = detail.dtmTranDate
				, intContractDetailId = detail.intOptionsPnSExercisedAssignedId
				, intContractHeaderId = header.intOptionsMatchPnSHeaderId
				, intCommodityId = de.intCommodityId
				, de.intLocationId
				, intBookId = de.intBookId
				, intSubBookId = de.intSubBookId
				, intFutOptTransactionId = detail.intFutOptTransactionId
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, strNotes = CASE WHEN de.strBuySell = 'Buy' THEN 'IN' ELSE 'OUT' END
				, dblNoOfLots = detail.dblLots * - 1
				, dblContractSize = FutMarket.dblContractSize
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = @intCurrentUserId
				, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
				, strMiscFields =  NULL
				, ysnPreCrush = ISNULL(ysnPreCrush,0)
			FROM tblRKOptionsPnSExercisedAssigned detail
			JOIN tblRKOptionsMatchPnSHeader header ON header.intOptionsMatchPnSHeaderId = detail.intOptionsMatchPnSHeaderId
			JOIN tblRKFutOptTransaction de ON de.intFutOptTransactionId = detail.intFutOptTransactionId
			LEFT JOIN tblRKFutureMarket FutMarket ON FutMarket.intFutureMarketId = de.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = de.intCommodityId AND cUOM.intUnitMeasureId = FutMarket.intUnitMeasureId
		) tbl

		EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0

		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('End Populate RK Summary Log - Option Derivatives')
		DELETE FROM @ExistingHistory

		--=======================================
		--				COLLATERAL
		--=======================================
		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Populate RK Summary Log - Collateral')
		
		INSERT INTO @ExistingHistory(
			  strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractHeaderId
			, intCommodityId
			, intItemId
			, intCommodityUOMId
			, intLocationId
			, dblQty
			, intUserId
			, strNotes
			, intActionId)
		SELECT
			  strBucketType = 'Collateral' 
			, strTransactionType = 'Collateral'
			, intTransactionRecordId = intCollateralId
			, intTransactionRecordHeaderId = intCollateralId
			, strDistributionType = strType
			, strTransactionNumber = strReceiptNo
			, dtmTransactionDate = dtmOpenDate
			, intContractHeaderId = intContractHeaderId
			, intCommodityId = a.intCommodityId
			, intItemId
			, intOrigUOMId = CUM.intCommodityUnitMeasureId
			, intLocationId = intLocationId
			, dblQty = dblOriginalQuantity
			, intUserId = (SELECT TOP 1 e.intEntityId
							FROM (tblEMEntity e LEFT JOIN tblEMEntityType et ON et.intEntityId = e.intEntityId AND et.strType = 'User')
							INNER JOIN tblRKCollateralHistory colhis ON colhis.strUserName = e.strName where colhis.intCollateralId = a.intCollateralId and colhis.strAction = 'ADD')
			, strNotes = strType + ' Collateral'
			, intActionId  = 1 --Rebuild
		FROM tblRKCollateral a
		LEFT JOIN tblICCommodityUnitMeasure CUM ON CUM.intUnitMeasureId = a.intUnitMeasureId AND CUM.intCommodityId = a.intCommodityId
		
		INSERT INTO @ExistingHistory(
			  strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intItemId
			, intLocationId
			, dblQty
			, intCommodityUOMId
			, intUserId
			, strNotes
			, intActionId)
		SELECT
			  strBucketType = 'Collateral'  
			, strTransactionType = 'Collateral Adjustments'
			, intTransactionRecordId = CA.intCollateralAdjustmentId
			, intTransactionRecordHeaderId = C.intCollateralId
			, strDistributionType = C.strType
			, strTransactionNumber = strAdjustmentNo
			, dtmTransactionDate = dtmAdjustmentDate
			, intContractDetailId = CA.intCollateralAdjustmentId
			, intContractHeaderId = C.intContractHeaderId
			, intCommodityId = C.intCommodityId
			, intItemId
			, intLocationId = intLocationId
			, dblQty = CA.dblAdjustmentAmount
			, intOrigUOMId = CUM.intCommodityUnitMeasureId
			, intUserId = (SELECT TOP 1 e.intEntityId
							FROM (tblEMEntity e LEFT JOIN tblEMEntityType et ON et.intEntityId = e.intEntityId AND et.strType = 'User')
							INNER JOIN tblRKCollateralHistory colhis ON colhis.strUserName = e.strName where colhis.intCollateralId = C.intCollateralId and colhis.strAction = 'ADD')
			, strNotes = strType + ' Collateral'
			, intActionId  = 1 --Rebuild
		FROM tblRKCollateralAdjustment CA
		JOIN tblRKCollateral C ON C.intCollateralId = CA.intCollateralId
		LEFT JOIN tblICCommodityUnitMeasure CUM ON CUM.intUnitMeasureId = C.intUnitMeasureId AND CUM.intCommodityId = C.intCommodityId
		WHERE intCollateralAdjustmentId NOT IN (SELECT DISTINCT adj.intCollateralAdjustmentId
				FROM tblRKCollateralAdjustment adj
				JOIN tblRKSummaryLog history ON history.intTransactionRecordId = adj.intCollateralId AND strTransactionType = 'Collateral Adjustments'
					AND adj.dtmAdjustmentDate = history.dtmTransactionDate
					AND adj.strAdjustmentNo = history.strTransactionNumber
					AND adj.dblAdjustmentAmount = history.dblOrigQty
				WHERE adj.intCollateralId = C.intCollateralId)
		
		EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0

		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('End Populate RK Summary Log - Collateral')
		DELETE FROM @ExistingHistory

		--=======================================
		--				INVENTORY
		--=======================================
		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Populate RK Summary Log - Inventory')
		
		INSERT INTO @ExistingHistory (	
			  strBatchId
			, strBucketType
			, strTransactionType
			, intTransactionRecordId 
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber 
			, dtmTransactionDate 
			, intContractDetailId 
			, intContractHeaderId 
			, intTicketId 
			, intCommodityId 
			, intCommodityUOMId 
			, intItemId 
			, intBookId 
			, intSubBookId 
			, intLocationId 
			, intFutureMarketId 
			, intFutureMonthId 
			, dblNoOfLots 
			, dblQty 
			, dblPrice 
			, intEntityId 
			, ysnDelete 
			, intUserId 
			, strNotes 	
			, intActionId
		)
		SELECT
			  strBatchId
			, strBucketType
			, strTransactionType
			, intTransactionRecordId 
			, intTransactionRecordHeaderId 
			, strDistributionType = ''
			, strTransactionNumber 
			, dtmTransactionDate 
			, intContractDetailId 
			, intContractHeaderId 
			, intTicketId 
			, intCommodityId 
			, intCommodityUOMId 
			, intItemId 
			, intBookId 
			, intSubBookId 
			, intLocationId 
			, intFutureMarketId 
			, intFutureMonthId 
			, dblNoOfLots 
			, dblQty 
			, dblPrice 
			, intEntityId 
			, ysnDelete 
			, intUserId 
			, strNotes 	
			, intActionId  = 1 --Rebuild
		FROM (
			SELECT 
				  strBatchId = t.strBatchId
				, strBucketType = 'Company Owned'
				, strTransactionType = v.strTransactionType
				, intTransactionRecordId = t.intTransactionDetailId
				, intTransactionRecordHeaderId = t.intTransactionId 
				, strTransactionNumber = t.strTransactionId
				, dtmTransactionDate = t.dtmDate
				, intContractDetailId = NULL
				, intContractHeaderId = NULL
				, intTicketId = v.intTicketId
				, intCommodityId = v.intCommodityId
				, intCommodityUOMId = cuomDefault.intCommodityUnitMeasureId
				, intItemId = t.intItemId
				, intBookId = NULL
				, intSubBookId = NULL
				, intLocationId = v.intLocationId
				, intFutureMarketId = NULL
				, intFutureMonthId = NULL
				, dblNoOfLots = NULL
				--,dblQty = SUM(t.dblQty)
				, dblQty = ISNULL(
							SUM(dbo.fnCalculateQtyBetweenUOM (
									t.intItemUOMId
									, iuomCDefault.intItemUOMId
									, t.dblQty
								))
							, 0.00)
				,dblPrice = AVG(t.dblCost)
				,intEntityId = v.intEntityId
				,ysnDelete = 0
				,intUserId = t.intCreatedEntityId
				,strNotes = t.strDescription
				,intInventoryTransactionId  = MIN(t.intInventoryTransactionId)
			FROM	
				tblICInventoryTransaction t inner join vyuICGetInventoryValuation v 
					ON t.intInventoryTransactionId = v.intInventoryTransactionId
				INNER JOIN tblICCommodityUnitMeasure cuomDefault
					ON cuomDefault.intCommodityId = v.intCommodityId
					AND cuomDefault.ysnDefault = 1
				INNER JOIN tblICItemUOM iuomCDefault
					ON iuomCDefault.intItemId = t.intItemId
					AND iuomCDefault.intUnitMeasureId = cuomDefault.intUnitMeasureId
				LEFT JOIN tblICItemUOM iuom
					ON iuom.intItemUOMId = t.intItemUOMId
				--INNER JOIN tblICUnitMeasure u
				--	ON u.strUnitMeasure = v.strUOM
				--INNER JOIN tblICCommodityUnitMeasure cum
				--	ON cum.intCommodityId = v.intCommodityId AND cum.intUnitMeasureId = u.intUnitMeasureId	
			WHERE
				t.dblQty <> 0 
				AND v.ysnInTransit = 0
				AND ISNULL(t.ysnIsUnposted,0) = 0
				AND v.strTransactionType NOT IN ('Inventory Receipt','Inventory Shipment', 'Storage Settlement')
			GROUP BY 
				  t.strBatchId
				, v.strTransactionType
				, t.intTransactionDetailId
				, t.intTransactionId
				, t.strTransactionId
				, t.dtmDate
				, v.intTicketId
				, v.intCommodityId
				, cuomDefault.intCommodityUnitMeasureId
				, t.intItemId
				, v.intLocationId
				, v.intEntityId
				, t.intCreatedEntityId
				, t.strDescription
				, v.intSubLocationId
				, v.intStorageLocationId

			UNION ALL
			SELECT 
				  strBatchId = t.strBatchId
				, strBucketType = 'Company Owned'
				, strTransactionType = v.strTransactionType
				, intTransactionRecordId = t.intTransactionDetailId
				, intTransactionRecordHeaderId = t.intTransactionId 
				, strTransactionNumber = t.strTransactionId
				, dtmTransactionDate = t.dtmDate
				, intContractDetailId = iri.intContractDetailId
				, intContractHeaderId = iri.intContractHeaderId
				, intTicketId = v.intTicketId
				, intCommodityId = v.intCommodityId
				, intCommodityUOMId = cuomDefault.intCommodityUnitMeasureId
				, intItemId = t.intItemId
				, intBookId = NULL
				, intSubBookId = NULL
				, intLocationId = v.intLocationId
				, intFutureMarketId = NULL
				, intFutureMonthId = NULL
				, dblNoOfLots = NULL
				--, dblQty = SUM(t.dblQty)
				, dblQty = ISNULL(
							SUM(dbo.fnCalculateQtyBetweenUOM (
									  t.intItemUOMId
									, iuomCDefault.intItemUOMId
									, t.dblQty
								))
							, 0.00)
				, dblPrice = AVG(t.dblCost)
				, intEntityId = v.intEntityId
				, ysnDelete = 0
				, intUserId = t.intCreatedEntityId
				, strNotes = t.strDescription
				, intInventoryTransactionId  = MIN(t.intInventoryTransactionId)
			FROM	
				tblICInventoryTransaction t inner join vyuICGetInventoryValuation v 
					ON t.intInventoryTransactionId = v.intInventoryTransactionId
				INNER JOIN tblICCommodityUnitMeasure cuomDefault
					ON cuomDefault.intCommodityId = v.intCommodityId
					AND cuomDefault.ysnDefault = 1
				INNER JOIN tblICItemUOM iuomCDefault
					ON iuomCDefault.intItemId = t.intItemId
					AND iuomCDefault.intUnitMeasureId = cuomDefault.intUnitMeasureId
				LEFT JOIN tblICItemUOM iuom
					ON iuom.intItemUOMId = t.intItemUOMId
				--INNER JOIN tblICUnitMeasure u
				--	ON u.strUnitMeasure = v.strUOM
				--INNER JOIN tblICCommodityUnitMeasure cum
				--	ON cum.intCommodityId = v.intCommodityId AND cum.intUnitMeasureId = u.intUnitMeasureId
				INNER JOIN tblICInventoryReceiptItem iri 
					ON iri.intInventoryReceiptItemId = t.intTransactionDetailId	
			WHERE
				t.dblQty <> 0 
				AND v.ysnInTransit = 0
				AND ISNULL(t.ysnIsUnposted,0) = 0
				AND v.strTransactionType = 'Inventory Receipt'
			GROUP BY 
				  t.strBatchId
				, v.strTransactionType
				, t.intTransactionDetailId
				, t.intTransactionId
				, t.strTransactionId
				, t.dtmDate
				, iri.intContractDetailId
				, iri.intContractHeaderId
				, v.intTicketId
				, v.intCommodityId
				, cuomDefault.intCommodityUnitMeasureId
				, t.intItemId
				, v.intLocationId
				, v.intEntityId
				, t.intCreatedEntityId
				, t.strDescription
				, v.intSubLocationId
				, v.intStorageLocationId

			UNION ALL
			SELECT 
				  strBatchId = t.strBatchId
				, strBucketType = 'Company Owned'
				, strTransactionType = v.strTransactionType
				, intTransactionRecordId = t.intTransactionDetailId
				, intTransactionRecordHeaderId = t.intTransactionId 
				, strTransactionNumber = t.strTransactionId
				, dtmTransactionDate = t.dtmDate
				, intContractDetailId = isi.intLineNo
				, intContractHeaderId = isi.intOrderId
				, intTicketId = v.intTicketId
				, intCommodityId = v.intCommodityId
				, intCommodityUOMId = cuomDefault.intCommodityUnitMeasureId
				, intItemId = t.intItemId
				, intBookId = NULL
				, intSubBookId = NULL
				, intLocationId = v.intLocationId
				, intFutureMarketId = NULL
				, intFutureMonthId = NULL
				, dblNoOfLots = NULL
				--, dblQty = SUM(t.dblQty)
				, dblQty = ISNULL(
							SUM(dbo.fnCalculateQtyBetweenUOM (
									  t.intItemUOMId
									, iuomCDefault.intItemUOMId
									, t.dblQty
								))
							, 0.00)
				, dblPrice = AVG(t.dblCost)
				, intEntityId = v.intEntityId
				, ysnDelete = 0
				, intUserId = t.intCreatedEntityId
				, strNotes = t.strDescription
				, intInventoryTransactionId  = MIN(t.intInventoryTransactionId)
			FROM	
				tblICInventoryTransaction t inner join vyuICGetInventoryValuation v 
					ON t.intInventoryTransactionId = v.intInventoryTransactionId
				INNER JOIN tblICCommodityUnitMeasure cuomDefault
					ON cuomDefault.intCommodityId = v.intCommodityId
					AND cuomDefault.ysnDefault = 1
				INNER JOIN tblICItemUOM iuomCDefault
					ON iuomCDefault.intItemId = t.intItemId
					AND iuomCDefault.intUnitMeasureId = cuomDefault.intUnitMeasureId
				LEFT JOIN tblICItemUOM iuom
					ON iuom.intItemUOMId = t.intItemUOMId
				--INNER JOIN tblICUnitMeasure u
				--	ON u.strUnitMeasure = v.strUOM
				--INNER JOIN tblICCommodityUnitMeasure cum
				--	ON cum.intCommodityId = v.intCommodityId AND cum.intUnitMeasureId = u.intUnitMeasureId
				INNER JOIN tblICInventoryShipmentItem isi 
					ON isi.intInventoryShipmentItemId = t.intTransactionDetailId	
			WHERE
				t.dblQty <> 0 
				AND v.ysnInTransit = 0
				AND ISNULL(t.ysnIsUnposted,0) = 0
				AND v.strTransactionType = 'Inventory Shipment'
			GROUP BY 
				  t.strBatchId
				, v.strTransactionType
				, t.intTransactionDetailId
				, t.intTransactionId
				, t.strTransactionId
				, t.dtmDate
				, isi.intLineNo
				, isi.intOrderId
				, v.intTicketId
				, v.intCommodityId
				, cuomDefault.intCommodityUnitMeasureId
				, t.intItemId
				, v.intLocationId
				, v.intEntityId
				, t.intCreatedEntityId
				, t.strDescription
				, v.intSubLocationId
				, v.intStorageLocationId

			UNION ALL
			SELECT strBatchId = t.strBatchId
				, strBucketType = 'Sales In-Transit'
				, strTransactionType = v.strTransactionType
				, intTransactionRecordId = t.intTransactionDetailId
				, intTransactionRecordHeaderId = t.intTransactionId 
				, strTransactionNumber = t.strTransactionId
				, dtmTransactionDate = t.dtmDate
				, intContractDetailId = CASE WHEN v.strTransactionType = 'Inventory Shipment' THEN sd.intLineNo
											WHEN v.strTransactionType = 'Invoice' THEN id.intContractDetailId
											WHEN v.strTransactionType = 'Outbound Shipment' THEN ld.intSContractDetailId END
				, intContractHeaderId = CASE WHEN v.strTransactionType = 'Inventory Shipment' THEN cd.intContractHeaderId
											WHEN v.strTransactionType = 'Invoice' THEN cd.intContractHeaderId
											WHEN v.strTransactionType = 'Outbound Shipment' THEN cd.intContractHeaderId END
				, intTicketId = CASE WHEN v.strTransactionType = 'Inventory Shipment' THEN v.intTicketId
											WHEN v.strTransactionType = 'Invoice' THEN id.intTicketId
											WHEN v.strTransactionType = 'Outbound Shipment' THEN v.intTicketId END
				, intCommodityId = v.intCommodityId
				, intCommodityUOMId = cuomDefault.intCommodityUnitMeasureId
				, intItemId = t.intItemId
				, intBookId = NULL
				, intSubBookId = NULL
				, intLocationId = v.intLocationId
				, intFutureMarketId = cd.intFutureMarketId
				, intFutureMonthId = cd.intFutureMonthId
				, dblNoOfLots = NULL
				--, dblQty = SUM(t.dblQty)
				, dblQty = ISNULL(
							SUM(dbo.fnCalculateQtyBetweenUOM (
									  t.intItemUOMId
									, iuomCDefault.intItemUOMId
									, t.dblQty
								))
							, 0.00)
				, dblPrice = AVG(t.dblCost)
				, intEntityId = v.intEntityId
				, ysnDelete = 0
				, intUserId = t.intCreatedEntityId
				, strNotes = t.strDescription
				, intInventoryTransactionId  = MIN(t.intInventoryTransactionId)
			FROM tblICInventoryTransaction t
			INNER JOIN vyuICGetInventoryValuation v ON t.intInventoryTransactionId = v.intInventoryTransactionId
			INNER JOIN tblICCommodityUnitMeasure cuomDefault
				ON cuomDefault.intCommodityId = v.intCommodityId
				AND cuomDefault.ysnDefault = 1
			INNER JOIN tblICItemUOM iuomCDefault
				ON iuomCDefault.intItemId = t.intItemId
				AND iuomCDefault.intUnitMeasureId = cuomDefault.intUnitMeasureId
			LEFT JOIN tblICItemUOM iuom
				ON iuom.intItemUOMId = t.intItemUOMId
			--INNER JOIN tblICUnitMeasure u ON u.strUnitMeasure = v.strUOM
			--INNER JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = v.intCommodityId AND cum.intUnitMeasureId = u.intUnitMeasureId
			LEFT JOIN (
				tblICInventoryShipmentItem sd
				LEFT JOIN tblICInventoryShipment s ON s.intInventoryShipmentId = sd.intInventoryShipmentId
					AND s.intOrderType = 1 ) ON sd.intInventoryShipmentItemId = t.intTransactionDetailId AND v.strTransactionType = 'Inventory Shipment'
			LEFT JOIN tblARInvoiceDetail id ON id.intInvoiceDetailId = t.intTransactionDetailId AND v.strTransactionType = 'Invoice'
			LEFT JOIN tblLGLoadDetail ld ON ld.intLoadDetailId = t.intTransactionDetailId AND v.strTransactionType = 'Outbound Shipment'
			LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = CASE WHEN v.strTransactionType = 'Inventory Shipment' THEN sd.intLineNo
																			WHEN v.strTransactionType = 'Invoice' THEN id.intContractDetailId
																			WHEN v.strTransactionType = 'Outbound Shipment' THEN ld.intSContractDetailId END
			WHERE t.dblQty <> 0 
				AND v.ysnInTransit = 1
				AND v.strTransactionType IN ('Inventory Shipment', 'Outbound Shipment', 'Invoice')
				AND ISNULL(t.ysnIsUnposted,0) = 0
			GROUP BY t.strBatchId
				, v.strTransactionType
				, t.intTransactionDetailId
				, t.intTransactionId
				, t.strTransactionId
				, t.dtmDate
				, v.intTicketId
				, id.intTicketId
				, v.intCommodityId
				, cuomDefault.intCommodityUnitMeasureId
				, t.intItemId
				, v.intLocationId
				, v.intEntityId
				, t.intCreatedEntityId
				, t.strDescription
				, v.intSubLocationId
				, v.intStorageLocationId
				, sd.intLineNo
				, id.intContractDetailId
				, id.intContractHeaderId
				, ld.intSContractDetailId
				, cd.intContractHeaderId
				, cd.intFutureMarketId
				, cd.intFutureMonthId

			UNION ALL
			SELECT strBatchId = t.strBatchId
				, strBucketType = 'Purchase In-Transit'
				, strTransactionType = v.strTransactionType
				, intTransactionRecordId = t.intTransactionDetailId
				, intTransactionRecordHeaderId = t.intTransactionId 
				, strTransactionNumber = t.strTransactionId
				, dtmTransactionDate = t.dtmDate
				, intContractDetailId = ri.intContractDetailId
				, intContractHeaderId = ri.intContractHeaderId
				, intTicketId = v.intTicketId
				, intCommodityId = v.intCommodityId
				, intCommodityUOMId = cuomDefault.intCommodityUnitMeasureId
				, intItemId = t.intItemId
				, intBookId = NULL
				, intSubBookId = NULL
				, intLocationId = v.intLocationId
				, intFutureMarketId = cd.intFutureMarketId
				, intFutureMonthId = cd.intFutureMonthId
				, dblNoOfLots = NULL
				--, dblQty = SUM(t.dblQty)
				, dblQty = ISNULL(
							SUM(dbo.fnCalculateQtyBetweenUOM (
									  t.intItemUOMId
									, iuomCDefault.intItemUOMId
									, t.dblQty
								))
							, 0.00)
				, dblPrice = AVG(t.dblCost)
				, intEntityId = v.intEntityId
				, ysnDelete = 0
				, intUserId = t.intCreatedEntityId
				, strNotes = t.strDescription
				, intInventoryTransactionId  = MIN(t.intInventoryTransactionId)
			FROM tblICInventoryTransaction t
			INNER JOIN vyuICGetInventoryValuation v ON t.intInventoryTransactionId = v.intInventoryTransactionId
			INNER JOIN tblICCommodityUnitMeasure cuomDefault
				ON cuomDefault.intCommodityId = v.intCommodityId
				AND cuomDefault.ysnDefault = 1
			INNER JOIN tblICItemUOM iuomCDefault
				ON iuomCDefault.intItemId = t.intItemId
				AND iuomCDefault.intUnitMeasureId = cuomDefault.intUnitMeasureId
			LEFT JOIN tblICItemUOM iuom
				ON iuom.intItemUOMId = t.intItemUOMId
			--INNER JOIN tblICUnitMeasure u ON u.strUnitMeasure = v.strUOM
			--INNER JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = v.intCommodityId AND cum.intUnitMeasureId = u.intUnitMeasureId
			LEFT JOIN tblICInventoryReceiptItem ri ON t.intTransactionDetailId = ri.intInventoryReceiptItemId AND v.strTransactionType = 'Inventory Receipt'
			LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intContractDetailId
			WHERE t.dblQty <> 0 
				AND v.ysnInTransit = 1
				AND v.strTransactionType IN ('Inventory Receipt','Inbound Shipments','Inventory Transfer with Shipment')
				AND ISNULL(t.ysnIsUnposted,0) = 0
			GROUP BY t.strBatchId
				, v.strTransactionType
				, t.intTransactionDetailId
				, t.intTransactionId
				, t.strTransactionId
				, t.dtmDate
				, v.intTicketId
				, v.intCommodityId
				, cuomDefault.intCommodityUnitMeasureId
				, t.intItemId
				, v.intLocationId
				, v.intEntityId
				, t.intCreatedEntityId
				, t.strDescription
				, v.intSubLocationId
				, v.intStorageLocationId
				, ri.intContractDetailId
				, ri.intContractHeaderId
				, cd.intFutureMarketId
				, cd.intFutureMonthId
		) t
		ORDER BY intInventoryTransactionId
	
		EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0
		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('End Populate RK Summary Log - Inventory')
		DELETE FROM @ExistingHistory

		--=======================================
		--				CUSTOMER OWNED
		--=======================================
		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Populate RK Summary Log - Customer Owned')
		
		SELECT dtmDeliveryDate =  sh.dtmHistoryDate --(CASE WHEN sh.strType IN ('Transfer') THEN  sh.dtmHistoryDate ELSE cs.dtmDeliveryDate END)
			, strBucketType = 'Customer Owned'
			, strTransactionType = CASE WHEN intTransactionTypeId IN (1, 5, 8)
											THEN CASE WHEN sh.intInventoryReceiptId IS NOT NULL THEN 'Inventory Receipt'
													 WHEN sh.intInventoryShipmentId IS NOT NULL THEN 'Inventory Shipment'
													 ELSE 'NONE' END
										WHEN intTransactionTypeId = 3 THEN 'Transfer Storage'
										WHEN intTransactionTypeId = 4 THEN 'Storage Settlement'
										WHEN intTransactionTypeId = 9 THEN 'Inventory Adjustment' END
			, intTransactionRecordId = CASE 
											WHEN intTransactionTypeId IN (1, 5, 8)
												THEN
													nullif(coalesce(sh.intInventoryReceiptId, sh.intInventoryShipmentId, sh.intTicketId, -99), -99)
											WHEN intTransactionTypeId = 3 THEN sh.intTransferStorageId
											WHEN intTransactionTypeId = 4 THEN sh.intSettleStorageId
											WHEN intTransactionTypeId = 9 THEN sh.intInventoryAdjustmentId END
			, strTransactionNo 	= CASE 
									WHEN intTransactionTypeId IN (1, 5, 8)
										THEN CASE 
												WHEN sh.intInventoryReceiptId IS NOT NULL THEN sh.strReceiptNumber
												WHEN sh.intInventoryShipmentId IS NOT NULL THEN sh.strShipmentNumber
												WHEN sh.intTicketId is not null then t.strTicketNumber
												ELSE NULL 
											END
									WHEN intTransactionTypeId = 3 THEN sh.strTransferTicket
									WHEN intTransactionTypeId = 4 THEN sh.strSettleTicket
									WHEN intTransactionTypeId = 9 THEN ISNULL(sh.strAdjustmentNo, sh.strTransactionId) END
			, intTransactionRecordHeaderId = sh.intCustomerStorageId
			, sh.intContractHeaderId
			, cs.intCommodityId
			, cs.intItemId
			, cum.intCommodityUnitMeasureId
			, sh.intCompanyLocationId
			, dblQty = (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)
			, strInOut = (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN 'OUT' ELSE CASE WHEN sh.dblUnits < 0 THEN 'OUT' ELSE 'IN' END END)
			, sh.intTicketId
			, cs.intEntityId
			, strDistributionType = st.strStorageTypeDescription
			, st.strStorageTypeCode
			, intStorageHistoryId
			, ysnReceiptedStorage
			, intTypeId = intTransactionTypeId
			, cs.strStorageType
			, cs.intDeliverySheetId
			, t.strTicketStatus
			, st.ysnDPOwnedType
			, st.strOwnedPhysicalStock
			, st.strStorageTypeDescription
			, st.ysnActive
			, sl.ysnExternal
			, sh.intUserId
		INTO #tmpCustomerOwned
		FROM vyuGRStorageHistory sh
		JOIN tblGRCustomerStorage cs ON cs.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType st ON st.intStorageScheduleTypeId = cs.intStorageTypeId 
			AND st.ysnDPOwnedType = 0
		JOIN tblICItemUOM iuom ON iuom.intItemUOMId = cs.intItemUOMId
		JOIN tblICCommodityUnitMeasure cum ON cum.intUnitMeasureId = iuom.intUnitMeasureId and cum.intCommodityId = cs.intCommodityId
		LEFT JOIN tblSCTicket t ON t.intTicketId = sh.intTicketId
		LEFT JOIN tblSMCompanyLocationSubLocation sl ON sl.intCompanyLocationSubLocationId = t.intSubLocationId AND sl.intCompanyLocationId = t.intProcessingLocationId
		WHERE sh.intTransactionTypeId in (1,3,4,5,8,9)
	
		UNION ALL
		SELECT dtmDeliveryDate =  sh.dtmHistoryDate --(CASE WHEN sh.strType IN ('Transfer','Settlement') THEN  sh.dtmHistoryDate ELSE cs.dtmDeliveryDate END)
			, strBucketType = 'Delayed Pricing'
			, strTransactionType = CASE WHEN intTransactionTypeId IN (1, 5, 8)
											THEN CASE WHEN sh.intInventoryReceiptId IS NOT NULL THEN 'Inventory Receipt'
													 WHEN sh.intInventoryShipmentId IS NOT NULL THEN 'Inventory Shipment'
													 ELSE 'NONE' END
										WHEN intTransactionTypeId = 3 THEN 'Transfer Storage'
										WHEN intTransactionTypeId = 4 THEN 'Storage Settlement'
										WHEN intTransactionTypeId = 9 THEN 'Inventory Adjustment' END
			, intTransactionRecordId = CASE 
										WHEN intTransactionTypeId IN (1, 5)
											THEN 
												nullif(coalesce(sh.intInventoryReceiptId, sh.intInventoryShipmentId, sh.intTicketId, -99), -99)
									WHEN intTransactionTypeId = 3 THEN sh.intTransferStorageId
									WHEN intTransactionTypeId = 4 THEN sh.intSettleStorageId
									WHEN intTransactionTypeId = 9 THEN sh.intInventoryAdjustmentId END
			, strTransactionNo 	= CASE 
										WHEN intTransactionTypeId IN (1, 5, 8)
											THEN CASE 
													WHEN sh.intInventoryReceiptId IS NOT NULL THEN sh.strReceiptNumber
													WHEN sh.intInventoryShipmentId IS NOT NULL THEN sh.strShipmentNumber
													WHEN sh.intTicketId is not null then t.strTicketNumber
													ELSE NULL 
												END
										WHEN intTransactionTypeId = 3 THEN sh.strTransferTicket
										WHEN intTransactionTypeId = 4 THEN sh.strSettleTicket
										WHEN intTransactionTypeId = 9 THEN ISNULL(sh.strAdjustmentNo, sh.strTransactionId) END
			, intTransactionRecordHeaderId = sh.intCustomerStorageId
			, sh.intContractHeaderId
			, cs.intCommodityId
			, cs.intItemId
			, cum.intCommodityUnitMeasureId
			, sh.intCompanyLocationId
			, dblQty = (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)
			, strInOut = (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN 'OUT' ELSE CASE WHEN sh.dblUnits < 0 THEN 'OUT' ELSE 'IN' END END)
			, sh.intTicketId
			, cs.intEntityId
			, strDistributionType = st.strStorageTypeDescription
			, st.strStorageTypeCode
			, intStorageHistoryId
			, ysnReceiptedStorage
			, intTypeId = intTransactionTypeId
			, cs.strStorageType
			, cs.intDeliverySheetId
			, t.strTicketStatus
			, st.ysnDPOwnedType
			, st.strOwnedPhysicalStock
			, st.strStorageTypeDescription
			, st.ysnActive
			, sl.ysnExternal
			, sh.intUserId
		FROM vyuGRStorageHistory sh
		JOIN tblGRCustomerStorage cs ON cs.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType st ON st.intStorageScheduleTypeId = cs.intStorageTypeId 
			and st.ysnDPOwnedType = 1	
		JOIN tblICItemUOM iuom ON iuom.intItemUOMId = cs.intItemUOMId
		JOIN tblICCommodityUnitMeasure cum ON cum.intUnitMeasureId = iuom.intUnitMeasureId and cum.intCommodityId = cs.intCommodityId
		LEFT JOIN tblSCTicket t ON t.intTicketId = sh.intTicketId
		LEFT JOIN tblSMCompanyLocationSubLocation sl ON sl.intCompanyLocationSubLocationId = t.intSubLocationId AND sl.intCompanyLocationId = t.intProcessingLocationId
		WHERE sh.intTransactionTypeId in (1,3,4,5,8,9)
		
		UNION ALL
		SELECT dtmDeliveryDate =  sh.dtmHistoryDate --(CASE WHEN sh.strType IN ('Transfer') THEN  sh.dtmHistoryDate ELSE cs.dtmDeliveryDate END)
			, strBucketType = 'Company Owned'
			, strTransactionType = CASE 
										WHEN intTransactionTypeId = 3 THEN 'Transfer Storage'
										WHEN intTransactionTypeId = 4 THEN 'Storage Settlement'
									END
			, intTransactionRecordId = CASE 
											WHEN intTransactionTypeId = 3 THEN sh.intTransferStorageId
											WHEN intTransactionTypeId = 4 THEN sh.intSettleStorageId
										END
			, strTransactionNo = CASE 
									WHEN intTransactionTypeId = 3 THEN sh.strTransferTicket
									WHEN intTransactionTypeId = 4 THEN sh.strSettleTicket
								END
			, intTransactionRecordHeaderId = sh.intCustomerStorageId
			, sh.intContractHeaderId
			, cs.intCommodityId
			, cs.intItemId
			, cum.intCommodityUnitMeasureId
			, sh.intCompanyLocationId
			, dblQty = CASE 
							WHEN intTransactionTypeId = 3 THEN (CASE WHEN sh.strType = 'Reverse Transfer' THEN - sh.dblUnits ELSE sh.dblUnits END)
							WHEN intTransactionTypeId = 4 THEN (CASE WHEN sh.strType = 'Reverse Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)
						END
			, strInOut = (CASE WHEN sh.strType IN ('Reverse Settlement','Reverse Transfer', 'Transfer' ) THEN 'OUT' ELSE 'IN' END)
			, sh.intTicketId
			, cs.intEntityId
			, strDistributionType = st.strStorageTypeDescription
			, st.strStorageTypeCode
			, intStorageHistoryId
			, ysnReceiptedStorage
			, intTypeId = intTransactionTypeId
			, cs.strStorageType
			, cs.intDeliverySheetId
			, t.strTicketStatus
			, st.ysnDPOwnedType
			, st.strOwnedPhysicalStock
			, st.strStorageTypeDescription
			, st.ysnActive
			, sl.ysnExternal
			, sh.intUserId
		FROM vyuGRStorageHistory sh
		JOIN tblGRCustomerStorage cs ON cs.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType st ON st.intStorageScheduleTypeId = cs.intStorageTypeId 
			AND st.ysnDPOwnedType = 0
		JOIN tblICItemUOM iuom ON iuom.intItemUOMId = cs.intItemUOMId
		JOIN tblICCommodityUnitMeasure cum ON cum.intUnitMeasureId = iuom.intUnitMeasureId and cum.intCommodityId = cs.intCommodityId
		LEFT JOIN tblSCTicket t ON t.intTicketId = sh.intTicketId
		LEFT JOIN tblSMCompanyLocationSubLocation sl ON sl.intCompanyLocationSubLocationId = t.intSubLocationId AND sl.intCompanyLocationId = t.intProcessingLocationId
		WHERE sh.intTransactionTypeId IN(4)
		AND sh.strType IN ('Settlement', 'Reverse Settlement', 'From Transfer','Reverse Transfer', 'Transfer')

		INSERT INTO @ExistingHistory (strBatchId
			, strBucketType
			, strTransactionType
			, intTransactionRecordId 
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber 
			, dtmTransactionDate 
			, intContractHeaderId 
			, intTicketId 
			, intCommodityId 
			, intCommodityUOMId 
			, intItemId 
			, intLocationId 
			, dblQty 
			, intEntityId 
			, intUserId 
			, strNotes
			, strMiscFields
			, strStorageTypeCode
			, ysnReceiptedStorage
			, intTypeId
			, strStorageType
			, intDeliverySheetId
			, strTicketStatus
			, strOwnedPhysicalStock
			, strStorageTypeDescription
			, ysnActive
			, ysnExternal
			, intStorageHistoryId
			, intActionId)
		SELECT strBatchId = NULL
			, strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNo
			, dtmDeliveryDate
			, intContractHeaderId
			, intTicketId
			, intCommodityId
			, intCommodityUnitMeasureId
			, intItemId
			, intCompanyLocationId
			, dblQty
			, intEntityId
			, intUserId
			, strNotes = (CASE WHEN intTransactionRecordId IS NULL THEN 'Actual transaction was deleted historically.' ELSE NULL END)
			, strMiscFields = NULL
			, strStorageTypeCode
			, ysnReceiptedStorage
			, intTypeId
			, strStorageType
			, intDeliverySheetId
			, strTicketStatus
			, strOwnedPhysicalStock
			, strStorageTypeDescription
			, ysnActive
			, ysnExternal
			, intStorageHistoryId
			, intActionId  = 1 --Rebuild
		FROM #tmpCustomerOwned co
		ORDER BY dtmDeliveryDate, intStorageHistoryId
	
		EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0
		INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('End Populate RK Summary Log - Customer Owned')
		DELETE FROM @ExistingHistory

		
        --=======================================
        --                ON HOLD
        --=======================================
        INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Populate RK Summary Log - On Hold')

        INSERT INTO @ExistingHistory (    
            strBatchId
            ,strBucketType
            ,strTransactionType
            ,intTransactionRecordId 
            ,intTransactionRecordHeaderId
            ,strDistributionType
            ,strTransactionNumber 
            ,dtmTransactionDate 
            ,intContractDetailId 
            ,intContractHeaderId 
            ,intTicketId 
            ,intCommodityId 
            ,intCommodityUOMId 
            ,intItemId 
            ,intBookId 
            ,intSubBookId 
            ,intLocationId 
            ,intFutureMarketId 
            ,intFutureMonthId 
            ,dblNoOfLots 
            ,dblQty 
            ,dblPrice 
            ,intEntityId 
            ,ysnDelete 
            ,intUserId 
            ,strNotes
			,intActionId     
        )
         SELECT
            strBatchId = NULL
            ,strBucketType = 'On Hold'
            ,strTransactionType = 'Scale Ticket'
            ,intTransactionRecordId = intTicketId
            ,intTransactionRecordHeaderId = intTicketId
            ,strDistributionType = strStorageTypeDescription
            ,strTransactionNumber = strTicketNumber
            ,dtmTransactionDate  = dtmTicketDateTime
            ,intContractDetailId = intContractId
            ,intContractHeaderId = intContractSequence
            ,intTicketId  = intTicketId
            ,intCommodityId  = TV.intCommodityId
            ,intCommodityUOMId  = CUM.intCommodityUnitMeasureId
            ,intItemId = TV.intItemId
            ,intBookId = NULL
            ,intSubBookId = NULL
            ,intLocationId = intProcessingLocationId
            ,intFutureMarketId = NULL
            ,intFutureMonthId = NULL
            ,dblNoOfLots = 0
            ,dblQty = CASE WHEN strInOutFlag = 'I' THEN dblNetUnits ELSE dblNetUnits * -1 END 
            ,dblPrice = dblUnitPrice
            ,intEntityId 
            ,ysnDelete = 0
            ,intUserId = TV.intEntityScaleOperatorId
            ,strNotes = strTicketComment
			,intActionId  = 1 --Rebuild
        FROM tblSCTicket TV
        LEFT JOIN tblGRStorageType ST on ST.intStorageScheduleTypeId = TV.intStorageScheduleTypeId 
        LEFT JOIN tblICItemUOM IUM ON IUM.intItemUOMId = TV.intItemUOMIdTo
        LEFT JOIN tblICCommodityUnitMeasure CUM ON CUM.intUnitMeasureId = IUM.intUnitMeasureId AND CUM.intCommodityId = TV.intCommodityId
        WHERE ISNULL(strTicketStatus,'') = 'H'
		
        EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0
        INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('End Populate RK Summary Log - On Hold')
        DELETE FROM @ExistingHistory

		END
		
		---------------------------------------------------------------------------------------------------
		-- CB LOG Rebuild for Cancelled, Short Closed, and Completed contracts within 3 month threshold  --
		-- NOTE: WILL ONLY REBUILD CONTRACTS WITHOUT CONTRACT BALANCE LOGS.								 --
		---------------------------------------------------------------------------------------------------
		EXEC uspRKRebuildNonOpenContracts
			@intMonthThreshold = 3
		-------------------------------------------------------------------
		-- FIX FOR COMMON ISSUES IN DERIVATIVES AFTER UPGRADING TO 20.1	 --
		-------------------------------------------------------------------
		EXEC uspRKFixDerivativeCommonIssues
			
		----------------------------------------------------
		-- Run Integration scripts required after rebuild --
		----------------------------------------------------
		EXEC uspRKRunIntegrationAfterRebuild

		UPDATE tblRKRebuildSummaryLog
		SET ysnSuccess = 1
		WHERE intRebuildSummaryLogId = @RebuildLogId

	END
	RETURN;
	
END TRY

BEGIN CATCH
	DECLARE @ErrMsg NVARCHAR(MAX) = ERROR_MESSAGE()
	
	UPDATE tblRKRebuildSummaryLog
	SET ysnSuccess = 0
		, strErrorMessage = @ErrMsg
	WHERE intRebuildSummaryLogId = @RebuildLogId

	IF (@ErrMsg != 'You are not allowed to rebuild the Summary Log!')
	BEGIN
		UPDATE tblRKCompanyPreference
		SET ysnAllowRebuildSummaryLog = 1
	END
	
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH