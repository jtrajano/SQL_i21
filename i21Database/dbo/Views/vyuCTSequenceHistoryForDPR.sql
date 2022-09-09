CREATE VIEW vyuCTSequenceHistoryForDPR

AS 

WITH ContractCreation AS (
	SELECT intContractDetailId
		, intInitialId = MIN(intSequenceHistoryId)
		, dtmInitialDate = MIN(dtmHistoryCreated)
	FROM tblCTSequenceHistory
	GROUP BY intContractDetailId)

SELECT sh.intSequenceHistoryId
	, dtmDate = sh.dtmHistoryCreated
	, sh.intCommodityId
	, sh.intContractHeaderId
	, sh.intContractDetailId
	, sh.intContractTypeId
	, ch.strContractNumber
	, sh.intContractSeq
	, strContractNoSeq = ch.strContractNumber  + '-' + CAST(sh.intContractSeq AS NVARCHAR)
	, ysnNewPriced = CASE WHEN sh.intSequenceHistoryId = cc.intInitialId AND sh.intPricingTypeId = 1 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	, ysnNewHTA = CASE WHEN sh.intSequenceHistoryId = cc.intInitialId AND sh.intPricingTypeId = 3 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	, intHeaderPricingTypeId = ch.intPricingTypeId
	, sh.intPricingTypeId
	, ysnCancelled = CASE WHEN sh.intContractStatusId = 3 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	, ysnShortClosed = CASE WHEN sh.intContractStatusId = 6 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	, sh.dblQuantity
	, sh.dblOldQuantity
	, dblDifference = sh.dblQuantity - sh.dblOldQuantity
	, ysnQtyChange = ISNULL(sh.ysnQtyChange, CAST(0 AS BIT))
	, dblQtyPriced = ISNULL(dblQtyPriced, 0)
	, dblPrevQtyPriced = LAG(ISNULL(dblQtyPriced, 0)) OVER (PARTITION BY sh.intContractDetailId ORDER BY sh.dtmHistoryCreated ASC)
FROM tblCTSequenceHistory sh
JOIN ContractCreation cc ON cc.intContractDetailId = sh.intContractDetailId
JOIN tblCTContractHeader ch ON ch.intContractHeaderId = sh.intContractHeaderId 