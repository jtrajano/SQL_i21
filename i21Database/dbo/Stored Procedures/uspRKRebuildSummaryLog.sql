﻿CREATE PROCEDURE [dbo].[uspRKRebuildSummaryLog]
	@intCurrentUserId INT	
AS

BEGIN
	--IF EXISTS (SELECT TOP 1 1 FROM tblRKCompanyPreference WHERE ysnAllowRebuildSummaryLog = 0)
	--BEGIN
	--	RAISERROR('You are not allowed to rebuild the Summary Log!', 16, 1)
	--END

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKSummaryLog')
	BEGIN
		DECLARE @ExistingHistory AS RKSummaryLog

		--=======================================
		--				CONTRACTS
		--=======================================
		PRINT 'Populate RK Summary Log - Contract'
		
		DECLARE @cbLog AS CTContractBalanceLog

		SELECT DISTINCT
			strBatchId = NULL
			, dtmTransactionDate
			, dtmCreatedDate =  dtmTransactionDate
			, strTransactionType = 'Contract Balance'
			, strTransactionReference = strTransactionType
			, intTransactionReferenceId = intTransactionId
			, strTransactionReferenceNo = strTransactionId
			, CD.intContractDetailId
			, CH.intContractHeaderId
			, CH.strContractNumber
			, CD.intContractSeq
			, intContractTypeId
			, intEntityId
			, CH.intCommodityId
			, strCommodityCode
			, intItemId
			, intLocationId = CD.intCompanyLocationId
			, t.intPricingTypeId
			, t.strPricingType
			, CD.intFutureMarketId
			, CD.intFutureMonthId
			, CD.dtmStartDate
			, CD.dtmEndDate
			, t.dblQty
			, intQtyUOMId
			, t.dblFutures
			, t.dblBasis
			, t.intBasisUOMId
			, t.intBasisCurrencyId
			, t.intPriceUOMId
			, t.intContractStatusId
			, CD.intBookId
			, CD.intSubBookId
			, strNotes = ''
			, intOrderBy
		INTO #tblContractBalance
		FROM(
			select 
				Row_Number() OVER (PARTITION BY sh.intContractDetailId ORDER BY cd.dtmCreated  DESC, sh.intSequenceHistoryId DESC) AS Row_Num
				, dtmTransactionDate = dbo.fnRemoveTimeOnDate(cd.dtmCreated)
				, sh.intContractHeaderId
				, sh.intContractDetailId
				, dblQty = sh.dblBalance - isnull(sh.dblOldQuantity,0)
				, intQtyUOMId = ch.intCommodityUOMId
				, sh.intPricingTypeId
				, sh.strPricingType
				, strTransactionType = 'Contract Sequence'
				, intTransactionId = sh.intContractDetailId
				, strTransactionId = sh.strContractNumber + '-' + CAST(sh.intContractSeq AS NVARCHAR(10))
				, sh.dblFutures
				, sh.dblBasis
				, cd.intBasisUOMId
				, cd.intBasisCurrencyId
				, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
				, sh.intContractStatusId
				, intOrderBy = 1
			from tblCTSequenceHistory sh
			inner join tblCTContractDetail cd on cd.intContractDetailId = sh.intContractDetailId
			inner join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
			where intSequenceUsageHistoryId is null and strPricingStatus not in ( 'Partially Priced', 'Fully Priced')

			union
			select 
				Row_Number() OVER (PARTITION BY sh.intContractDetailId ORDER BY cd.dtmCreated  DESC, sh.intSequenceHistoryId) AS Row_Num
				, dtmTransactionDate = dbo.fnRemoveTimeOnDate(cd.dtmCreated)
				, sh.intContractHeaderId
				, sh.intContractDetailId
				, dblQty = sh.dblBalance
				, intQtyUOMId = ch.intCommodityUOMId
				, sh.intPricingTypeId
				, sh.strPricingType
				, strTransactionType = 'Contract Sequence'
				, intTransactionId = sh.intContractDetailId
				, strTransactionId = sh.strContractNumber + '-' + CAST(sh.intContractSeq AS NVARCHAR(10))
				, sh.dblFutures
				, sh.dblBasis
				, cd.intBasisUOMId
				, cd.intBasisCurrencyId
				, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
				, sh.intContractStatusId
				, intOrderBy = 1
			from tblCTSequenceHistory sh
			inner join tblCTContractDetail cd on cd.intContractDetailId = sh.intContractDetailId
			inner join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
			where intSequenceUsageHistoryId is null 

			union all --HTA (Priced) decrease
			select 
				1 as Row_Num
				, dtmTransactionDate = min(dbo.fnRemoveTimeOnDate(a.dtmHistoryCreated))
				, a.intContractHeaderId
				, a.intContractDetailId
				, dblQty = a.dblQuantity * -1
				, intQtyUOMId = NULL
				, b.intPricingTypeId
				, b.strPricingType
				, strTransactionType = 'Contract Sequence'
				, intTransactionId = a.intContractDetailId
				, strTransactionId = a.strContractNumber + '-' + CAST(a.intContractSeq AS NVARCHAR(10))
				, a.dblFutures
				, a.dblBasis
				, cd.intBasisUOMId
				, cd.intBasisCurrencyId
				, intPriceUOMId = a.intPriceItemUOMId
				, a.intContractStatusId
				, intOrderBy = 1
			from tblCTSequenceHistory a
			INNER JOIN tblCTSequenceHistory b on a.intContractDetailId = b.intContractDetailId
			INNER JOIN tblCTContractDetail cd on cd.intContractDetailId = a.intContractDetailId
			AND a.intPricingTypeId = 1 AND b.intPricingTypeId = 3
			group by 
				a.dblQuantity,
				b.intPricingTypeId,
				b.strPricingType,
				a.intContractHeaderId,
				a.intContractDetailId,
				a.strContractNumber,
				a.intContractSeq,
				a.dblFutures,
				a.dblBasis,
				cd.intBasisUOMId,
				cd.intBasisCurrencyId,
				a.intPriceItemUOMId,
				a.intContractStatusId

			union all --HTA (Priced) increase
			select 
				1 as Row_Num
				, dtmTransactionDate = min(dbo.fnRemoveTimeOnDate(b.dtmHistoryCreated))
				, a.intContractHeaderId
				, a.intContractDetailId
				, dblQty = b.dblQuantity
				, intQtyUOMId = NULL
				, b.intPricingTypeId
				, b.strPricingType
				, strTransactionType = 'Contract Sequence'
				, intTransactionId = a.intContractDetailId
				, strTransactionId = a.strContractNumber + '-' + CAST(a.intContractSeq AS NVARCHAR(10))
				, b.dblFutures
				, b.dblBasis
				, cd.intBasisUOMId
				, cd.intBasisCurrencyId
				, intPriceUOMId = b.intPriceItemUOMId
				, b.intContractStatusId
				, intOrderBy = 4
			from tblCTSequenceHistory a
			INNER JOIN tblCTSequenceHistory b on a.intContractDetailId = b.intContractDetailId
			INNER JOIN tblCTContractDetail cd on cd.intContractDetailId = a.intContractDetailId
			AND a.intPricingTypeId = 3 AND b.intPricingTypeId = 1
			group by 
				b.dblQuantity,
				b.intPricingTypeId,
				b.strPricingType,
				a.intContractHeaderId,
				a.intContractDetailId,
				a.strContractNumber,
				a.intContractSeq,
				b.dblFutures,
				b.dblBasis,
				cd.intBasisUOMId,
				cd.intBasisCurrencyId,
				b.intPriceItemUOMId,
				b.intContractStatusId
	
			union all
			select  
				1 AS Row_Num
				, dtmTransactionDate = dbo.fnRemoveTimeOnDate(dtmTransactionDate)
				, sh.intContractHeaderId
				, sh.intContractDetailId
				, dblQty = (case when isnull(cd.intNoOfLoad,0) = 0 then suh.dblTransactionQuantity 
								else suh.dblTransactionQuantity * cd.dblQuantityPerLoad end)
				, intQtyUOMId = ch.intCommodityUOMId
				, sh.intPricingTypeId
				, sh.strPricingType
				, strTransactionType = strScreenName
				, intTransactionId = suh.intExternalId
				, strTransactionId = suh.strNumber
				, sh.dblFutures
				, sh.dblBasis
				, cd.intBasisUOMId
				, cd.intBasisCurrencyId
				, intPriceUOMId = sh.intDtlQtyInCommodityUOMId
				, sh.intContractStatusId
				, intOrderBy = 2
			from vyuCTSequenceUsageHistory suh
			inner join tblCTSequenceHistory sh on sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
			inner join tblCTContractDetail cd on cd.intContractDetailId = sh.intContractDetailId
			inner join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
			where strFieldName = 'Balance'

			union all
			SELECT	
				Row_Number() OVER (PARTITION BY pf.intContractDetailId, fd.intPriceFixationDetailId ORDER BY fd.dtmFixationDate  DESC) AS Row_Num
				, dtmTransactionDate = dbo.fnRemoveTimeOnDate(fd.dtmFixationDate)
				, pf.intContractHeaderId
				, pf.intContractDetailId
				, dblQty = (fd.dblQuantity - fd.dblQuantityAppliedAndPriced) * -1
				, intQtyUOMId = ch.intCommodityUOMId
				, intPricingTypeId = 2
				, strPricingTypeId = 'Basis'
				, strTransactionType = 'Price Fixation'
				, intTransactionId = fd.intPriceFixationDetailId
				, strTransactionId = pc.strPriceContractNo
				, dblFutures = NULL
				, cd.dblBasis
				, cd.intBasisUOMId
				, cd.intBasisCurrencyId
				, intPriceUOMId = fd.intPricingUOMId
				, cd.intContractStatusId
				, intOrderBy = 3
			FROM	tblCTPriceFixationDetail fd
			JOIN	tblCTPriceFixation		 pf	ON	pf.intPriceFixationId =	fd.intPriceFixationId
			JOIN	tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId
			JOIN tblCTContractDetail		 cd ON cd.intContractDetailId = pf.intContractDetailId
			inner join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
			WHERE (fd.dblQuantity - fd.dblQuantityAppliedAndPriced) <> 0

			union all
			SELECT	
				Row_Number() OVER (PARTITION BY pf.intContractDetailId, fd.intPriceFixationDetailId ORDER BY fd.dtmFixationDate  DESC) AS Row_Num
				, dtmTransactionDate = dbo.fnRemoveTimeOnDate(fd.dtmFixationDate)
				, pf.intContractHeaderId
				, pf.intContractDetailId
				, dblQty = fd.dblQuantity - fd.dblQuantityAppliedAndPriced
				, intQtyUOMId = ch.intCommodityUOMId
				, intPricingTypeId = 1
				, strPricingTypeId = 'Priced'
				, strTransactionType = 'Price Fixation'
				, intTransactionId = fd.intPriceFixationDetailId
				, strTransactionId = pc.strPriceContractNo
				, dblFutures = fd.dblFixationPrice
				, cd.dblBasis
				, cd.intBasisUOMId
				, cd.intBasisCurrencyId
				, intPriceUOMId = fd.intPricingUOMId
				, cd.intContractStatusId
				, intOrderBy = 4
			FROM	tblCTPriceFixationDetail fd
			JOIN	tblCTPriceFixation		 pf	ON	pf.intPriceFixationId =	fd.intPriceFixationId
			JOIN	tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId
			JOIN tblCTContractDetail		 cd ON cd.intContractDetailId = pf.intContractDetailId
			inner join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
			WHERE (fd.dblQuantity - fd.dblQuantityAppliedAndPriced) <> 0

		) t
		INNER JOIN tblCTContractHeader CH on CH.intContractHeaderId = t.intContractHeaderId 
		INNER JOIN tblCTContractDetail CD on CD.intContractDetailId = t.intContractDetailId
		INNER JOIN tblICCommodity C  on C.intCommodityId = CH.intCommodityId
		WHERE Row_Num = 1
		ORDER BY dtmTransactionDate,  t.intContractDetailId, intOrderBy

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
			, strNotes)
		SELECT strBatchId
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
			, dblQty
			, intContractStatusId
			, intBookId
			, intSubBookId
			, strNotes 		
		FROM #tblContractBalance
		ORDER BY dtmTransactionDate,  intContractDetailId, intOrderBy


		EXEC uspCTLogContractBalance @cbLog, 1

		PRINT 'End Populate RK Summary Log - Contract'
		
		--=======================================
		--				DERIVATIVES
		--=======================================
		PRINT 'Populate RK Summary Log - Derivatives'
		
		INSERT INTO @ExistingHistory(strTransactionType
			, intTransactionRecordId
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intBookId
			, intSubBookId
			, intFutureMarketId
			, intFutureMonthId
			, dblNoOfLots
			, dblPrice
			, intEntityId
			, intUserId
			, intLocationId
			, intCommodityUOMId
			, strNotes)
		SELECT strTransactionType = 'Derivatives'
			, intTransactionRecordId = der.intFutOptTransactionId
			, strTransactionNumber = der.strInternalTradeNo
			, dtmTransactionDate = der.dtmTransactionDate
			, intContractDetailId = der.intContractDetailId
			, intContractHeaderId = der.intContractHeaderId
			, intCommodityId = der.intCommodityId
			, intBookId = der.intBookId
			, intSubBookId = der.intSubBookId
			, intFutureMarketId = der.intFutureMarketId
			, intFutureMonthId = der.intFutureMonthId
			, dblNoOfLots = der.dblNewNoOfLots
			, dblPrice = der.dblPrice
			, intEntityId = der.intEntityId
			, intUserId = der.intUserId
			, der.intLocationId
			, cUOM.intCommodityUnitMeasureId
			, strNotes = strNotes
		FROM vyuRKGetFutOptTransactionHistory der
		JOIN tblRKFutureMarket m ON m.intFutureMarketId = der.intFutureMarketId
		LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = der.intCommodityId AND cUOM.intUnitMeasureId = m.intUnitMeasureId

		EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0

		PRINT 'End Populate RK Summary Log - Derivatives'
		DELETE FROM @ExistingHistory

		--=======================================
		--			MATCH DERIVATIVES
		--=======================================
		PRINT 'Populate RK Summary Log - Match Derivatives'
		
		INSERT INTO @ExistingHistory(strTransactionType
			, intTransactionRecordId
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intLocationId
			, intBookId
			, intSubBookId
			, intFutureMarketId
			, intFutureMonthId
			, strNotes
			, dblNoOfLots
			, dblPrice
			, intEntityId
			, intUserId
			, intCommodityUOMId)
		SELECT strTransactionType
			, intTransactionRecordId
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intLocationId
			, intBookId
			, intSubBookId
			, intFutureMarketId
			, intFutureMonthId
			, strNotes
			, dblNoOfLots
			, dblPrice
			, intEntityId
			, intUserId
			, intCommodityUOMId
		FROM (
			SELECT strTransactionType = 'Match Derivatives'
				, intTransactionRecordId = history.intLFutOptTransactionId
				, strTransactionNumber = de.strInternalTradeNo
				, dtmTransactionDate = history.dtmMatchDate
				, intContractDetailId = history.intMatchFuturesPSDetailId
				, intContractHeaderId = history.intMatchFuturesPSHeaderId
				, intCommodityId = de.intCommodityId
				, de.intLocationId
				, intBookId = de.intBookId
				, intSubBookId = de.intSubBookId
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, strNotes = 'IN'
				, dblNoOfLots = history.dblMatchQty
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = e.intEntityId
				, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
				, intMatchDerivativeHistoryId
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
				, strTransactionNumber = de.strInternalTradeNo
				, dtmTransactionDate = history.dtmMatchDate
				, intContractDetailId = history.intMatchFuturesPSDetailId
				, intContractHeaderId = history.intMatchFuturesPSHeaderId
				, intCommodityId = de.intCommodityId
				, intLocationId
				, intBookId = de.intBookId
				, intSubBookId = de.intSubBookId
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, strNotes = 'OUT'
				, dblNoOfLots = history.dblMatchQty * - 1
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = e.intEntityId
				, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
				, intMatchDerivativeHistoryId
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

		EXEC uspRKLogRiskPosition @ExistingHistory, 1

		PRINT 'End Populate RK Summary Log'
		DELETE FROM @ExistingHistory

		--=======================================
		--				COLLATERAL
		--=======================================
		PRINT 'Populate RK Summary Log - Collateral'
		
		INSERT INTO @ExistingHistory(strTransactionType
			, intTransactionRecordId
			, strTransactionNumber
			, dtmTransactionDate
			, intContractHeaderId
			, intCommodityId
			, intLocationId
			, dblQty
			, intUserId
			, strNotes)
		SELECT strTransactionType = 'Collateral'
			, intTransactionRecordId = intCollateralId
			, strTransactionNumber = strReceiptNo
			, dtmTransactionDate = dtmOpenDate
			, intContractHeaderId = intContractHeaderId
			, intCommodityId = intCommodityId
			, intLocationId = intLocationId
			, dblQty = dblOriginalQuantity
			, intUserId = (SELECT TOP 1 e.intEntityId
							FROM (tblEMEntity e LEFT JOIN tblEMEntityType et ON et.intEntityId = e.intEntityId AND et.strType = 'User')
							INNER JOIN tblRKCollateralHistory colhis on colhis.strUserName = e.strName where colhis.intCollateralId = a.intCollateralId and colhis.strAction = 'ADD')
			, strNotes = strType + ' Collateral'
		FROM tblRKCollateral a
		
		INSERT INTO @ExistingHistory(strTransactionType
			, intTransactionRecordId
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intLocationId
			, dblQty
			, intUserId
			, strNotes)
		SELECT strTransactionType = 'Collateral Adjustments'
			, intTransactionRecordId = C.intCollateralId
			, strTransactionNumber = strAdjustmentNo
			, dtmTransactionDate = dtmAdjustmentDate
			, intContractDetailId = CA.intCollateralAdjustmentId
			, intContractHeaderId = C.intContractHeaderId
			, intCommodityId = intCommodityId
			, intLocationId = intLocationId
			, dblQty = CA.dblAdjustmentAmount
			, intUserId = (SELECT TOP 1 e.intEntityId
							FROM (tblEMEntity e LEFT JOIN tblEMEntityType et ON et.intEntityId = e.intEntityId AND et.strType = 'User')
							INNER JOIN tblRKCollateralHistory colhis on colhis.strUserName = e.strName where colhis.intCollateralId = C.intCollateralId and colhis.strAction = 'ADD')
			, strNotes = strType + ' Collateral'
		FROM tblRKCollateralAdjustment CA
		JOIN tblRKCollateral C ON C.intCollateralId = CA.intCollateralId
		WHERE intCollateralAdjustmentId NOT IN (SELECT DISTINCT adj.intCollateralAdjustmentId
				FROM tblRKCollateralAdjustment adj
				JOIN tblRKSummaryLog history ON history.intTransactionRecordId = adj.intCollateralId AND strTransactionType = 'Collateral Adjustments'
					AND adj.dtmAdjustmentDate = history.dtmTransactionDate
					AND adj.strAdjustmentNo = history.strTransactionNumber
					AND adj.dblAdjustmentAmount = history.dblOrigQty
				WHERE adj.intCollateralId = C.intCollateralId)
		
		EXEC uspRKLogRiskPosition @ExistingHistory, 1

		PRINT 'End Populate RK Summary Log - Collateral'
		DELETE FROM @ExistingHistory

		--=======================================
		--				INVENTORY
		--=======================================
		PRINT 'Populate RK Summary Log - Inventory'
		
		INSERT INTO @ExistingHistory (	
			strBatchId
			,strTransactionType
			,intTransactionRecordId 
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
		)
		SELECT
			strBatchId
			,strTransactionType
			,intTransactionRecordId 
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
		FROM (
			SELECT 
				strBatchId = t.strBatchId
				,strTransactionType = v.strTransactionType
				,intTransactionRecordId = ISNULL(t.intTransactionDetailId, t.intTransactionId) 
				,strTransactionNumber = t.strTransactionId
				,dtmTransactionDate = t.dtmDate
				,intContractDetailId = NULL
				,intContractHeaderId = NULL
				,intTicketId = v.intTicketId
				,intCommodityId = v.intCommodityId
				,intCommodityUOMId = cum.intCommodityUnitMeasureId
				,intItemId = t.intItemId
				,intBookId = NULL
				,intSubBookId = NULL
				,intLocationId = v.intLocationId
				,intFutureMarketId = NULL
				,intFutureMonthId = NULL
				,dblNoOfLots = NULL
				,dblQty = SUM(t.dblQty)
				,dblPrice = AVG(t.dblCost)
				,intEntityId = v.intEntityId
				,ysnDelete = 0
				,intUserId = t.intCreatedEntityId
				,strNotes = t.strDescription
				,intInventoryTransactionId  = MIN(t.intInventoryTransactionId)
			FROM	
				tblICInventoryTransaction t inner join vyuICGetInventoryValuation v 
					ON t.intInventoryTransactionId = v.intInventoryTransactionId
				INNER JOIN tblICUnitMeasure u
					ON u.strUnitMeasure = v.strUOM
				INNER JOIN tblICCommodityUnitMeasure cum
					ON cum.intCommodityId = v.intCommodityId AND cum.intUnitMeasureId = u.intUnitMeasureId	
			WHERE
				t.dblQty <> 0 
				AND v.ysnInTransit = 0
				AND ISNULL(t.ysnIsUnposted,0) = 0
				AND v.strTransactionType NOT IN ('Inventory Receipt','Inventory Shipment')
			GROUP BY 
				t.strBatchId
				,v.strTransactionType
				,t.intTransactionDetailId
				,t.intTransactionId
				,t.strTransactionId
				,t.dtmDate
				,v.intTicketId
				,v.intCommodityId
				,cum.intCommodityUnitMeasureId
				,t.intItemId
				,v.intLocationId
				,v.intEntityId
				,t.intCreatedEntityId
				,t.strDescription
				,v.intSubLocationId
				,v.intStorageLocationId

			UNION ALL
			SELECT 
				strBatchId = t.strBatchId
				,strTransactionType = v.strTransactionType
				,intTransactionRecordId = ISNULL(t.intTransactionDetailId, t.intTransactionId) 
				,strTransactionNumber = t.strTransactionId
				,dtmTransactionDate = t.dtmDate
				,intContractDetailId = iri.intContractDetailId
				,intContractHeaderId = iri.intContractHeaderId
				,intTicketId = v.intTicketId
				,intCommodityId = v.intCommodityId
				,intCommodityUOMId = cum.intCommodityUnitMeasureId
				,intItemId = t.intItemId
				,intBookId = NULL
				,intSubBookId = NULL
				,intLocationId = v.intLocationId
				,intFutureMarketId = NULL
				,intFutureMonthId = NULL
				,dblNoOfLots = NULL
				,dblQty = SUM(t.dblQty)
				,dblPrice = AVG(t.dblCost)
				,intEntityId = v.intEntityId
				,ysnDelete = 0
				,intUserId = t.intCreatedEntityId
				,strNotes = t.strDescription
				,intInventoryTransactionId  = MIN(t.intInventoryTransactionId)
			FROM	
				tblICInventoryTransaction t inner join vyuICGetInventoryValuation v 
					ON t.intInventoryTransactionId = v.intInventoryTransactionId
				INNER JOIN tblICUnitMeasure u
					ON u.strUnitMeasure = v.strUOM
				INNER JOIN tblICCommodityUnitMeasure cum
					ON cum.intCommodityId = v.intCommodityId AND cum.intUnitMeasureId = u.intUnitMeasureId
				INNER JOIN tblICInventoryReceiptItem iri 
					ON iri.intInventoryReceiptItemId = t.intTransactionDetailId	
			WHERE
				t.dblQty <> 0 
				AND v.ysnInTransit = 0
				AND ISNULL(t.ysnIsUnposted,0) = 0
				AND v.strTransactionType = 'Inventory Receipt'
			GROUP BY 
				t.strBatchId
				,v.strTransactionType
				,t.intTransactionDetailId
				,t.intTransactionId
				,t.strTransactionId
				,t.dtmDate
				,iri.intContractDetailId
				,iri.intContractHeaderId
				,v.intTicketId
				,v.intCommodityId
				,cum.intCommodityUnitMeasureId
				,t.intItemId
				,v.intLocationId
				,v.intEntityId
				,t.intCreatedEntityId
				,t.strDescription
				,v.intSubLocationId
				,v.intStorageLocationId

			UNION ALL
			SELECT 
				strBatchId = t.strBatchId
				,strTransactionType = v.strTransactionType
				,intTransactionRecordId = ISNULL(t.intTransactionDetailId, t.intTransactionId) 
				,strTransactionNumber = t.strTransactionId
				,dtmTransactionDate = t.dtmDate
				,intContractDetailId = isi.intLineNo
				,intContractHeaderId = isi.intOrderId
				,intTicketId = v.intTicketId
				,intCommodityId = v.intCommodityId
				,intCommodityUOMId = cum.intCommodityUnitMeasureId
				,intItemId = t.intItemId
				,intBookId = NULL
				,intSubBookId = NULL
				,intLocationId = v.intLocationId
				,intFutureMarketId = NULL
				,intFutureMonthId = NULL
				,dblNoOfLots = NULL
				,dblQty = SUM(t.dblQty)
				,dblPrice = AVG(t.dblCost)
				,intEntityId = v.intEntityId
				,ysnDelete = 0
				,intUserId = t.intCreatedEntityId
				,strNotes = t.strDescription
				,intInventoryTransactionId  = MIN(t.intInventoryTransactionId)
			FROM	
				tblICInventoryTransaction t inner join vyuICGetInventoryValuation v 
					ON t.intInventoryTransactionId = v.intInventoryTransactionId
				INNER JOIN tblICUnitMeasure u
					ON u.strUnitMeasure = v.strUOM
				INNER JOIN tblICCommodityUnitMeasure cum
					ON cum.intCommodityId = v.intCommodityId AND cum.intUnitMeasureId = u.intUnitMeasureId
				INNER JOIN tblICInventoryShipmentItem isi 
					ON isi.intInventoryShipmentItemId = t.intTransactionDetailId	
			WHERE
				t.dblQty <> 0 
				AND v.ysnInTransit = 0
				AND ISNULL(t.ysnIsUnposted,0) = 0
				AND v.strTransactionType = 'Inventory Shipment'
			GROUP BY 
				t.strBatchId
				,v.strTransactionType
				,t.intTransactionDetailId
				,t.intTransactionId
				,t.strTransactionId
				,t.dtmDate
				,isi.intLineNo
				,isi.intOrderId
				,v.intTicketId
				,v.intCommodityId
				,cum.intCommodityUnitMeasureId
				,t.intItemId
				,v.intLocationId
				,v.intEntityId
				,t.intCreatedEntityId
				,t.strDescription
				,v.intSubLocationId
				,v.intStorageLocationId

			UNION ALL
			SELECT 
				strBatchId = t.strBatchId
				,strTransactionType = 'Sales In-Transit'
				,intTransactionRecordId = ISNULL(t.intTransactionDetailId, t.intTransactionId) 
				,strTransactionNumber = t.strTransactionId
				,dtmTransactionDate = t.dtmDate
				,intContractDetailId = NULL
				,intContractHeaderId = NULL
				,intTicketId = v.intTicketId
				,intCommodityId = v.intCommodityId
				,intCommodityUOMId = cum.intCommodityUnitMeasureId
				,intItemId = t.intItemId
				,intBookId = NULL
				,intSubBookId = NULL
				,intLocationId = v.intLocationId
				,intFutureMarketId = NULL
				,intFutureMonthId = NULL
				,dblNoOfLots = NULL
				,dblQty = SUM(t.dblQty)
				,dblPrice = AVG(t.dblCost)
				,intEntityId = v.intEntityId
				,ysnDelete = 0
				,intUserId = t.intCreatedEntityId
				,strNotes = t.strDescription
				,intInventoryTransactionId  = MIN(t.intInventoryTransactionId)
			FROM	
				tblICInventoryTransaction t inner join vyuICGetInventoryValuation v 
					ON t.intInventoryTransactionId = v.intInventoryTransactionId
				INNER JOIN tblICUnitMeasure u
					ON u.strUnitMeasure = v.strUOM
				INNER JOIN tblICCommodityUnitMeasure cum
					ON cum.intCommodityId = v.intCommodityId AND cum.intUnitMeasureId = u.intUnitMeasureId
			WHERE
				t.dblQty <> 0 
				AND v.ysnInTransit = 1
				AND v.strTransactionType IN ('Inventory Shipment', 'Outbound Shipment', 'Invoice')
				AND ISNULL(t.ysnIsUnposted,0) = 0
			GROUP BY 
				t.strBatchId
				,v.strTransactionType
				,t.intTransactionDetailId
				,t.intTransactionId
				,t.strTransactionId
				,t.dtmDate
				,v.intTicketId
				,v.intCommodityId
				,cum.intCommodityUnitMeasureId
				,t.intItemId
				,v.intLocationId
				,v.intEntityId
				,t.intCreatedEntityId
				,t.strDescription
				,v.intSubLocationId
				,v.intStorageLocationId

			UNION ALL
			SELECT 
				strBatchId = t.strBatchId
				,strTransactionType = 'Purchase In-Transit'
				,intTransactionRecordId = ISNULL(t.intTransactionDetailId, t.intTransactionId) 
				,strTransactionNumber = t.strTransactionId
				,dtmTransactionDate = t.dtmDate
				,intContractDetailId = NULL
				,intContractHeaderId = NULL
				,intTicketId = v.intTicketId
				,intCommodityId = v.intCommodityId
				,intCommodityUOMId = cum.intCommodityUnitMeasureId
				,intItemId = t.intItemId
				,intBookId = NULL
				,intSubBookId = NULL
				,intLocationId = v.intLocationId
				,intFutureMarketId = NULL
				,intFutureMonthId = NULL
				,dblNoOfLots = NULL
				,dblQty = SUM(t.dblQty)
				,dblPrice = AVG(t.dblCost)
				,intEntityId = v.intEntityId
				,ysnDelete = 0
				,intUserId = t.intCreatedEntityId
				,strNotes = t.strDescription
				,intInventoryTransactionId  = MIN(t.intInventoryTransactionId)
			FROM	
				tblICInventoryTransaction t inner join vyuICGetInventoryValuation v 
					ON t.intInventoryTransactionId = v.intInventoryTransactionId
				INNER JOIN tblICUnitMeasure u
					ON u.strUnitMeasure = v.strUOM
				INNER JOIN tblICCommodityUnitMeasure cum
					ON cum.intCommodityId = v.intCommodityId AND cum.intUnitMeasureId = u.intUnitMeasureId
			WHERE
				t.dblQty <> 0 
				AND v.ysnInTransit = 1
				AND v.strTransactionType IN ('Inventory Receipt', 'Inventory Transfer with Shipment')
				AND ISNULL(t.ysnIsUnposted,0) = 0
			GROUP BY 
				t.strBatchId
				,v.strTransactionType
				,t.intTransactionDetailId
				,t.intTransactionId
				,t.strTransactionId
				,t.dtmDate
				,v.intTicketId
				,v.intCommodityId
				,cum.intCommodityUnitMeasureId
				,t.intItemId
				,v.intLocationId
				,v.intEntityId
				,t.intCreatedEntityId
				,t.strDescription
				,v.intSubLocationId
				,v.intStorageLocationId

		) t
		ORDER BY intInventoryTransactionId
	
		EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0

		PRINT 'End Populate RK Summary Log - Inventory'
		
	--Update ysnAllowRebuildSummaryLog to FALSE
	UPDATE tblRKCompanyPreference SET ysnAllowRebuildSummaryLog = 0

	--TODO: Log to table Rebuild Summary Log Activities
	--User, DateTime
	DECLARE @strCurrentUserName NVARCHAR(100)

	SElECT @strCurrentUserName = strName FROM tblEMEntity WHERE intEntityId = @intCurrentUserId

	PRINT 'Rebuild by User: ' + @strCurrentUserName + ' on ' + CAST(GETDATE() AS NVARCHAR(100))

	
	END
	
END