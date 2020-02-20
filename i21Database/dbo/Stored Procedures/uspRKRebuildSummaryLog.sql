CREATE PROCEDURE [dbo].[uspRKRebuildSummaryLog]
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
		ORDER BY dtmTransactionDate, CD.intContractDetailId, intOrderBy

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
		DELETE FROM @cbLog

		--=======================================
		--				BASIS DELIVERIES
		--=======================================
		PRINT 'Populate RK Summary Log - Basis Deliveries'

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
							else suh.dblTransactionQuantity * cd.dblQuantityPerLoad end) * -1
			, intQtyUOMId = ch.intCommodityUOMId
			, sh.intPricingTypeId
			, sh.strPricingType
			, strTransactionType = strScreenName
			, intTransactionId = suh.intExternalId
			, strTransactionId = suh.strNumber
			, sh.intContractStatusId
			, ch.intContractTypeId
		into #tblBasisDeliveries
		from vyuCTSequenceUsageHistory suh
			inner join tblCTSequenceHistory sh on sh.intSequenceUsageHistoryId = suh.intSequenceUsageHistoryId
			inner join tblCTContractDetail cd on cd.intContractDetailId = sh.intContractDetailId
			inner join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
		where strFieldName = 'Balance'
		and sh.strPricingStatus = 'Unpriced'
		and sh.strPricingType = 'Basis'

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
				, strTransactionReferenceNo = strTransactionId
			from #tblBasisDeliveries

			union all
			select 
				 strType  = 'Purchase Basis Deliveries'
				, b.dtmBillDate
				, bd.intContractHeaderId
				, bd.intContractDetailId
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
				, intTransactionId = bd.intBillDetailId
				, strTransactionId = b.strBillId
			from tblAPBillDetail bd
			inner join tblAPBill b on b.intBillId = bd.intBillId
			inner join #tblBasisDeliveries ba on ba.intTransactionId = bd.intInventoryReceiptItemId and ba.strTransactionType <> 'Load Schedule' and ba.intContractTypeId = 1
	
			union all
			select 
				 strType  = 'Purchase Basis Deliveries'
				, b.dtmBillDate
				, bd.intContractHeaderId
				, bd.intContractDetailId
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
				, intTransactionId = bd.intBillDetailId
				, strTransactionId = b.strBillId
			from tblAPBillDetail bd
			inner join tblAPBill b on b.intBillId = bd.intBillId
			inner join #tblBasisDeliveries ba on ba.intTransactionId = bd.intLoadDetailId and ba.strTransactionType = 'Load Schedule' and ba.intContractTypeId = 1

			union all
			select 
				 strType  = 'Sales Basis Deliveries'
				, i.dtmDate
				, id.intContractHeaderId
				, id.intContractDetailId
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
				, intTransactionId = id.intInvoiceDetailId
				, strTransactionId = i.strInvoiceNumber
			from tblARInvoiceDetail id
			inner join tblARInvoice i on i.intInvoiceId = id.intInvoiceId
			inner join #tblBasisDeliveries ba on ba.intTransactionId = id.intInventoryShipmentItemId and ba.strTransactionType <> 'Load Schedule' and ba.intContractTypeId = 2
	
			union all
			select 
				 strType  = 'Sales Basis Deliveries'
				, i.dtmDate
				, id.intContractHeaderId
				, id.intContractDetailId
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
				, intTransactionId = id.intInvoiceDetailId
				, strTransactionId = i.strInvoiceNumber
			from tblARInvoiceDetail id
			inner join tblARInvoice i on i.intInvoiceId = id.intInvoiceId
			inner join #tblBasisDeliveries ba on ba.intTransactionId = id.intLoadDetailId and ba.strTransactionType = 'Load Schedule' and ba.intContractTypeId = 2

		) t

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
			, dblQty
			, intQtyUOMId
			, intPricingTypeId
			, intContractStatusId
		)
		SELECT 
			strBatch = NULL
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
			, intCompanyLocationId
			, dblQty
			, intQtyUOMId
			, intPricingTypeId
			, intContractStatusId
		FROM #tblFinalBasisDeliveries 

		EXEC uspCTLogContractBalance @cbLog, 1

		PRINT 'End Populate RK Summary Log - Basis Deliveries'
		
		--=======================================
		--				DERIVATIVES
		--=======================================
		PRINT 'Populate RK Summary Log - Derivatives'
		
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
			, intFutureMarketId
			, intFutureMonthId
			, dblNoOfLots
			, dblPrice
			, intEntityId
			, intUserId
			, intLocationId
			, intCommodityUOMId
			, strNotes)
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
			, intFutureMarketId
			, intFutureMonthId
			, strNotes
			, dblNoOfLots
			, dblPrice
			, intEntityId
			, intUserId
			, intCommodityUOMId)
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

		PRINT 'End Populate RK Summary Log - Match Derivatives'
		DELETE FROM @ExistingHistory

		--=======================================
		--			Option Derivatives
		--=======================================
		PRINT 'Populate RK Summary Log - Option Derivatives'
		
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
			, intFutureMarketId
			, intFutureMonthId
			, strNotes
			, dblNoOfLots
			, dblPrice
			, intEntityId
			, intUserId
			, intCommodityUOMId)
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
			, intFutureMarketId
			, intFutureMonthId
			, strNotes
			, dblNoOfLots
			, dblPrice
			, intEntityId
			, intUserId
			, intCommodityUOMId
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
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, strNotes = CASE WHEN de.strBuySell = 'Buy' THEN 'IN' ELSE 'OUT' END
				, dblNoOfLots = detail.dblLots * - 1
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = @intCurrentUserId
				, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
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
				, intFutureMarketId = de.intFutureMarketId
				, intFutureMonthId = de.intFutureMonthId
				, strNotes = CASE WHEN de.strBuySell = 'Buy' THEN 'IN' ELSE 'OUT' END
				, dblNoOfLots = detail.dblLots * - 1
				, dblPrice = de.dblPrice
				, intEntityId = de.intEntityId
				, intUserId = @intCurrentUserId
				, intCommodityUOMId = cUOM.intCommodityUnitMeasureId
			FROM tblRKOptionsPnSExercisedAssigned detail
			JOIN tblRKOptionsMatchPnSHeader header ON header.intOptionsMatchPnSHeaderId = detail.intOptionsMatchPnSHeaderId
			JOIN tblRKFutOptTransaction de ON de.intFutOptTransactionId = detail.intFutOptTransactionId
			LEFT JOIN tblRKFutureMarket FutMarket ON FutMarket.intFutureMarketId = de.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = de.intCommodityId AND cUOM.intUnitMeasureId = FutMarket.intUnitMeasureId
		) tbl

		EXEC uspRKLogRiskPosition @ExistingHistory, 1

		PRINT 'End Populate RK Summary Log - Option Derivatives'
		DELETE FROM @ExistingHistory

		--=======================================
		--				COLLATERAL
		--=======================================
		PRINT 'Populate RK Summary Log - Collateral'
		
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
			, intLocationId
			, dblQty
			, intUserId
			, strNotes)
		SELECT
			  strBucketType = 'Collateral' 
			, strTransactionType = 'Collateral'
			, intTransactionRecordId = intCollateralId
			, intTransactionRecordHeaderId = intCollateralId
			, strDistributionType = strType
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
			, dblQty
			, intUserId
			, strNotes)
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
		)
		SELECT
			strBatchId
			,strBucketType
			,strTransactionType
			,intTransactionRecordId 
			,intTransactionRecordHeaderId 
			,strDistributionType = ''
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
				,strBucketType = 'Company Owned'
				,strTransactionType = v.strTransactionType
				,intTransactionRecordId = t.intTransactionDetailId
				,intTransactionRecordHeaderId = t.intTransactionId 
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
				,strBucketType = 'Company Owned'
				,strTransactionType = v.strTransactionType
				,intTransactionRecordId = t.intTransactionDetailId
				,intTransactionRecordHeaderId = t.intTransactionId 
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
				,strBucketType = 'Company Owned'
				,strTransactionType = v.strTransactionType
				,intTransactionRecordId = t.intTransactionDetailId
				,intTransactionRecordHeaderId = t.intTransactionId 
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
				,strBucketType = 'Sales In-Transit'
				,strTransactionType = v.strTransactionType
				,intTransactionRecordId = t.intTransactionDetailId
				,intTransactionRecordHeaderId = t.intTransactionId 
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
				,strBucketType = 'Purchase In-Transit'
				,strTransactionType = v.strTransactionType
				,intTransactionRecordId = t.intTransactionDetailId
				,intTransactionRecordHeaderId = t.intTransactionId 
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
		DELETE FROM @ExistingHistory

		--=======================================
		--				CUSTOMER OWNED
		--=======================================
		PRINT 'Populate RK Summary Log - Customer Owned'
		
		SELECT 
			 dtmHistoryDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), sh.dtmHistoryDate, 110), 110)
			, strBucketType = 'Customer Owned'
			, strTransactionType = CASE WHEN intTransactionTypeId IN(1,5) THEN
												CASE WHEN sh.intInventoryReceiptId IS NOT NULL THEN 'Inventory Receipt'
													 WHEN sh.intInventoryShipmentId IS NOT NULL THEN 'Inventory Shipment'
													 ELSE 'NONE'
												END
											 WHEN intTransactionTypeId = 3 THEN
												'Transfer Storage'
											 WHEN intTransactionTypeId = 4 THEN
												'Settle Storage'
											 WHEN intTransactionTypeId = 9 THEN
												'Inventory Adjustment'
											END
			, intTransactionHeaderRecordId = CASE WHEN intTransactionTypeId IN(1,5)THEN
												CASE WHEN sh.intInventoryReceiptId IS NOT NULL THEN sh.intInventoryReceiptId
													 WHEN sh.intInventoryShipmentId IS NOT NULL THEN sh.intInventoryShipmentId
													 ELSE NULL
												END
											 WHEN intTransactionTypeId = 3 THEN
												sh.intTransferStorageId
											 WHEN intTransactionTypeId = 4 THEN
												sh.intSettleStorageId
											 WHEN intTransactionTypeId = 9 THEN
												sh.intInventoryAdjustmentId
											END
			, strTransactioneNo = CASE WHEN intTransactionTypeId IN(1,5) THEN
												CASE WHEN sh.intInventoryReceiptId IS NOT NULL THEN sh.strReceiptNumber
													 WHEN sh.intInventoryShipmentId IS NOT NULL THEN sh.strShipmentNumber
													 ELSE NULL
												END
											 WHEN intTransactionTypeId = 3 THEN
												sh.strTransferTicket
											 WHEN intTransactionTypeId = 4 THEN
												sh.strSettleTicket
											 WHEN intTransactionTypeId = 9 THEN
												sh.strAdjustmentNo
											END

			, sh.intContractHeaderId
			, cs.intCommodityId
			, cs.intItemId
			, cs.intItemUOMId
			, sh.intCompanyLocationId
			, dblQty = (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)
			, strInOut = (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN 'OUT' ELSE CASE WHEN sh.dblUnits < 0 THEN 'OUT' ELSE 'IN' END END)
			, sh.intTicketId
			, cs.intEntityId
			, strDistributionType = st.strStorageTypeDescription
			, st.strStorageTypeCode
			, intStorageHistoryId
		INTO #tmpCustomerOwned
		FROM vyuGRStorageHistory sh
			JOIN tblGRCustomerStorage cs ON cs.intCustomerStorageId = sh.intCustomerStorageId
			JOIN tblGRStorageType st ON st.intStorageScheduleTypeId = cs.intStorageTypeId and ysnDPOwnedType = 0
	
		UNION ALL
		SELECT 
			 dtmHistoryDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), sh.dtmHistoryDate, 110), 110)
			, strBucketType = 'Delayed Pricing'
			, strTransactionType = CASE WHEN intTransactionTypeId IN(1,5) THEN
												CASE WHEN sh.intInventoryReceiptId IS NOT NULL THEN 'Inventory Receipt'
													 WHEN sh.intInventoryShipmentId IS NOT NULL THEN 'Inventory Shipment'
													 ELSE 'NONE'
												END
											 WHEN intTransactionTypeId = 3 THEN
												'Transfer Storage'
											 WHEN intTransactionTypeId = 4 THEN
												'Settle Storage'
											 WHEN intTransactionTypeId = 9 THEN
												'Inventory Adjustment'
											END
			, intTransactionHeaderRecordId = CASE WHEN intTransactionTypeId IN(1,5)THEN
												CASE WHEN sh.intInventoryReceiptId IS NOT NULL THEN sh.intInventoryReceiptId
													 WHEN sh.intInventoryShipmentId IS NOT NULL THEN sh.intInventoryShipmentId
													 ELSE NULL
												END
											 WHEN intTransactionTypeId = 3 THEN
												sh.intTransferStorageId
											 WHEN intTransactionTypeId = 4 THEN
												sh.intSettleStorageId
											 WHEN intTransactionTypeId = 9 THEN
												sh.intInventoryAdjustmentId
											END
			, strTransactioneNo = CASE WHEN intTransactionTypeId IN(1,5) THEN
												CASE WHEN sh.intInventoryReceiptId IS NOT NULL THEN sh.strReceiptNumber
													 WHEN sh.intInventoryShipmentId IS NOT NULL THEN sh.strShipmentNumber
													 ELSE NULL
												END
											 WHEN intTransactionTypeId = 3 THEN
												sh.strTransferTicket
											 WHEN intTransactionTypeId = 4 THEN
												sh.strSettleTicket
											 WHEN intTransactionTypeId = 9 THEN
												sh.strAdjustmentNo
											END

			, sh.intContractHeaderId
			, cs.intCommodityId
			, cs.intItemId
			, cs.intItemUOMId
			, sh.intCompanyLocationId
			, dblQty = (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)
			, strInOut = (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN 'OUT' ELSE CASE WHEN sh.dblUnits < 0 THEN 'OUT' ELSE 'IN' END END)
			, sh.intTicketId
			, cs.intEntityId
			, strDistributionType = st.strStorageTypeDescription
			, st.strStorageTypeCode
			, intStorageHistoryId
		FROM vyuGRStorageHistory sh
			JOIN tblGRCustomerStorage cs ON cs.intCustomerStorageId = sh.intCustomerStorageId
			JOIN tblGRStorageType st ON st.intStorageScheduleTypeId = cs.intStorageTypeId and ysnDPOwnedType = 1

		INSERT INTO @ExistingHistory (	
			strBatchId
			,strBucketType
			,strTransactionType
			,intTransactionRecordId 
			,intTransactionRecordHeaderId
			,strDistributionType
			,strTransactionNumber 
			,dtmTransactionDate 
			,intContractHeaderId 
			,intTicketId 
			,intCommodityId 
			,intCommodityUOMId 
			,intItemId 
			,intLocationId 
			,dblQty 
			,intEntityId 
			,intUserId 
			,strNotes
			,strMiscFields 	
		)
		SELECT
			 strBatchId = NULL
			,strBucketType
			,strTransactionType
			,intTransactionRecordId = NULL
			,intTransactionHeaderRecordId
			,strDistributionType
			,strTransactioneNo
			,dtmHistoryDate
			,intContractHeaderId
			,intTicketId
			,intCommodityId
			,intItemUOMId
			,intItemId
			,intCompanyLocationId
			,dblQty
			,intEntityId
			,@intCurrentUserId
			,strNotes = (CASE WHEN intTransactionHeaderRecordId IS NULL THEN 'Actual transaction was deleted historically.' ELSE NULL END)
			,strMiscFields = '{strStorageTypeCode = "'+ strStorageTypeCode +'"}'
		FROM #tmpCustomerOwned co
		ORDER BY dtmHistoryDate, intStorageHistoryId
	
		EXEC uspRKLogRiskPosition @ExistingHistory, 1, 0
		PRINT 'End Populate RK Summary Log - Customer Owned'
		DELETE FROM @ExistingHistory
		
	--Update ysnAllowRebuildSummaryLog to FALSE
	UPDATE tblRKCompanyPreference SET ysnAllowRebuildSummaryLog = 0

	--TODO: Log to table Rebuild Summary Log Activities
	--User, DateTime
	DECLARE @strCurrentUserName NVARCHAR(100)

	SElECT @strCurrentUserName = strName FROM tblEMEntity WHERE intEntityId = @intCurrentUserId

	PRINT 'Rebuild by User: ' + @strCurrentUserName + ' on ' + CAST(GETDATE() AS NVARCHAR(100))

	
	END
	
END