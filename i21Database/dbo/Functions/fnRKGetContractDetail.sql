CREATE FUNCTION [dbo].[fnRKGetContractDetail]
(
	@dtmToDate  date
)
RETURNS TABLE AS RETURN

WITH Pricing AS
    (
    SELECT c.strCommodityCode
		, c.intCommodityId
		, ch.intContractHeaderId
		, strContractNumber = strContractNumber + '-' + CONVERT(NVARCHAR, intContractSeq)
		, strLocationName
		, dtmEndDate
		, FM.strFutureMonth
		, dblPricedQuantity = SUM(PFD.dblQuantity)
		, dblBalanceQuantity = SUM(CDT.dblBalance)
		, CDT.intUnitMeasureId
		, CDT.intPricingTypeId
		, ch.intContractTypeId
		, cl.intCompanyLocationId
		, ct.strContractType
		, pt.strPricingType
		, ium.intCommodityUnitMeasureId
		, CDT.intContractDetailId
		, CDT.intContractStatusId
		, ch.intEntityId
		, CDT.intCurrencyId
		, CUR.strCurrency
		, IM.intItemId
		, IM.strItemNo
		, ch.dtmContractDate
		, strEntityName
		, ch.strCustomerContract
		, dblRecQty = MAX(CDT.dblQuantity - CDT.dblBalance)
		, dblQuantity = MAX(CDT.dblQuantity)
		, Category.intCategoryId
		, strCategory = Category.strCategoryCode
		, FM.intFutureMonthId
		, FM.intFutureMarketId
		, FM.strFutMarketName
	FROM tblCTPriceFixationDetail PFD
	JOIN tblCTPriceFixation PFX ON PFX.intPriceFixationId = PFD.intPriceFixationId
	JOIN tblCTContractDetail CDT ON CDT.intContractDetailId = PFX.intContractDetailId AND CDT.intPricingTypeId IN (1, 2, 3, 4)
	LEFT JOIN (SELECT intFutureMonthId, strFutureMonth, tblRKFutureMarket.intFutureMarketId, tblRKFutureMarket.strFutMarketName
				FROM tblRKFuturesMonth
				LEFT JOIN tblRKFutureMarket ON tblRKFutureMarket.intFutureMarketId = tblRKFuturesMonth.intFutureMarketId) FM ON CDT.intFutureMonthId = FM.intFutureMonthId
	JOIN tblICItem IM ON IM.intItemId =	CDT.intItemId
	JOIN tblCTContractHeader ch ON ch.intContractHeaderId = CDT.intContractHeaderId AND CDT.intContractStatusId NOT IN (2,3)
	JOIN vyuCTEntity EY	ON EY.intEntityId = ch.intEntityId
		AND 1 = (CASE WHEN ch.intContractTypeId = 1 AND EY.strEntityType = 'Vendor' THEN 1
					WHEN ch.intContractTypeId <> 1 AND EY.strEntityType = 'Customer' THEN 1
					ELSE 0 END)
	JOIN tblICCommodity c ON ch.intCommodityId = c.intCommodityId
	JOIN tblCTPricingType pt ON pt.intPricingTypeId = CDT.intPricingTypeId
	JOIN tblCTContractType ct ON ct.intContractTypeId = ch.intContractTypeId
	JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = CDT.intCompanyLocationId
	JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = ch.intCommodityId AND CDT.intUnitMeasureId = ium.intUnitMeasureId
	JOIN tblSMCurrency CUR ON CDT.intCurrencyId = CUR.intCurrencyID
	JOIN tblICCategory Category ON Category.intCategoryId = IM.intCategoryId
	WHERE CDT.dblQuantity > ISNULL(CDT.dblInvoicedQty, 0) AND ISNULL(CDT.dblBalance, 0) > 0
	AND CONVERT(DATETIME, CONVERT(VARCHAR(10), PFD.dtmFixationDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
	GROUP BY c.strCommodityCode
		, c.intCommodityId
		, ch.intContractHeaderId
		, strContractNumber
		, intContractSeq
		, strLocationName
		, dtmEndDate
		, FM.strFutureMonth
		, CDT.intUnitMeasureId
		, CDT.intPricingTypeId
		, ch.intContractTypeId
		, cl.intCompanyLocationId
		, ct.strContractType
		, pt.strPricingType
		, ium.intCommodityUnitMeasureId
		, CDT.intContractDetailId
		, CDT.intContractStatusId
		, ch.intEntityId
		, CDT.intCurrencyId
		, CUR.strCurrency
		, IM.intItemId
		, IM.strItemNo
		, ch.dtmContractDate
		, strEntityName
		, ch.strCustomerContract
		, Category.intCategoryId
		, Category.strCategoryCode
		, FM.intFutureMonthId
		, FM.intFutureMarketId
		, FM.strFutMarketName)
	
	SELECT * FROM (
		SELECT strCommodityCode
			, intCommodityId
			, intContractHeaderId
			, strContractNumber
			, strLocationName
			, dtmEndDate
			, strFutureMonth
			, dblQuantity
			, dblBalance = dblPricedQuantity - dblRecQty
			, intUnitMeasureId
			, intPricingTypeId
			, intContractTypeId
			, intCompanyLocationId
			, strContractType
			, strPricingType
			, intCommodityUnitMeasureId
			, intContractDetailId
			, intContractStatusId
			, intEntityId
			, intCurrencyId
			, strCurrency
			, strType = strContractType + ' Priced'
			, intItemId
			, strItemNo
			, dtmContractDate
			, strEntityName
			, strCustomerContract
			, intCategoryId
			, strCategory
			, intFutureMonthId
			, intFutureMarketId
			, strFutMarketName
		FROM Pricing WHERE intPricingTypeId = 1
		
		UNION ALL
		SELECT c.strCommodityCode
			, c.intCommodityId
			, ch.intContractHeaderId
			, strContractNumber = ch.strContractNumber + '-' + CONVERT(NVARCHAR, intContractSeq)
			, cl.strLocationName
			, CDT.dtmEndDate
			, FM.strFutureMonth
			, CDT.dblQuantity
			, dblBalance = CDT.dblQuantity  - PRC.dblPricedQuantity
			, CDT.intUnitMeasureId
			, CDT.intPricingTypeId
			, ch.intContractTypeId
			, cl.intCompanyLocationId
			, ct.strContractType
			, pt.strPricingType
			, ium.intCommodityUnitMeasureId
			, CDT.intContractDetailId
			, CDT.intContractStatusId
			, ch.intEntityId
			, CDT.intCurrencyId
			, CUR.strCurrency
			, strType = ct.strContractType + ' Basis'
			, IM.intItemId
			, IM.strItemNo
			, ch.dtmContractDate
			, EY.strEntityName
			, ch.strCustomerContract
			, Category.intCategoryId
			, strCategory = Category.strCategoryCode
			, FM.intFutureMonthId
			, FM.intFutureMarketId
			, FM.strFutMarketName
		FROM tblCTContractDetail CDT
		JOIN Pricing PRC ON CDT.intContractDetailId = PRC.intContractDetailId AND CDT.intPricingTypeId = 2
		LEFT JOIN (SELECT intFutureMonthId, strFutureMonth, tblRKFutureMarket.intFutureMarketId, tblRKFutureMarket.strFutMarketName
				FROM tblRKFuturesMonth
				LEFT JOIN tblRKFutureMarket ON tblRKFutureMarket.intFutureMarketId = tblRKFuturesMonth.intFutureMarketId) FM ON CDT.intFutureMonthId = FM.intFutureMonthId
		JOIN tblCTContractHeader ch ON ch.intContractHeaderId = CDT.intContractHeaderId AND CDT.intContractStatusId NOT IN (2,3)
		JOIN vyuCTEntity EY	ON EY.intEntityId = ch.intEntityId
			AND 1 = (CASE WHEN ch.intContractTypeId = 1 AND EY.strEntityType = 'Vendor' THEN 1
						WHEN ch.intContractTypeId <> 1 AND EY.strEntityType = 'Customer' THEN 1
						ELSE 0 END)
		JOIN tblICItem IM ON IM.intItemId = CDT.intItemId
		JOIN tblICCommodity c ON ch.intCommodityId = c.intCommodityId
		JOIN tblCTPricingType pt ON pt.intPricingTypeId = CDT.intPricingTypeId
		JOIN tblCTContractType ct ON ct.intContractTypeId = ch.intContractTypeId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = CDT.intCompanyLocationId
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = ch.intCommodityId AND CDT.intUnitMeasureId = ium.intUnitMeasureId 
		JOIN tblSMCurrency CUR ON CDT.intCurrencyId = CUR.intCurrencyID
		JOIN tblICCategory Category ON Category.intCategoryId = IM.intCategoryId
		WHERE dblPricedQuantity >= dblRecQty
		
		UNION ALL
		SELECT c.strCommodityCode
			, c.intCommodityId
			, ch.intContractHeaderId
			, strContractNumber = ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq)
			, cl.strLocationName
			, CDT.dtmEndDate
			, FM.strFutureMonth
			, CDT.dblQuantity
			, dblBalance = PRC.dblPricedQuantity + ISNULL(SeqHis.dblTransactionQuantity,0)
			, CDT.intUnitMeasureId
			, CDT.intPricingTypeId
			, ch.intContractTypeId
			, cl.intCompanyLocationId
			, ct.strContractType
			, pt.strPricingType
			, ium.intCommodityUnitMeasureId
			, CDT.intContractDetailId
			, CDT.intContractStatusId
			, ch.intEntityId
			, CDT.intCurrencyId
			, CUR.strCurrency
			, strType = ct.strContractType + ' Priced'
			, IM.intItemId
			, IM.strItemNo
			, ch.dtmContractDate
			, EY.strEntityName
			, ch.strCustomerContract
			, Category.intCategoryId
			, strCategory = Category.strCategoryCode
			, FM.intFutureMonthId
			, FM.intFutureMarketId
			, FM.strFutMarketName
		FROM  tblCTContractDetail CDT
		LEFT JOIN (SELECT intFutureMonthId, strFutureMonth, tblRKFutureMarket.intFutureMarketId, tblRKFutureMarket.strFutMarketName
				FROM tblRKFuturesMonth
				LEFT JOIN tblRKFutureMarket ON tblRKFutureMarket.intFutureMarketId = tblRKFuturesMonth.intFutureMarketId) FM ON CDT.intFutureMonthId = FM.intFutureMonthId
		JOIN Pricing PRC ON CDT.intContractDetailId = PRC.intContractDetailId AND CDT.intPricingTypeId = 2
		JOIN tblCTContractHeader ch ON ch.intContractHeaderId = CDT.intContractHeaderId AND CDT.intContractStatusId NOT IN (2,3)
		JOIN vyuCTEntity EY	ON EY.intEntityId = ch.intEntityId
			AND 1 = (CASE WHEN ch.intContractTypeId = 1 AND EY.strEntityType = 'Vendor' THEN 1
						WHEN ch.intContractTypeId <> 1 AND EY.strEntityType = 'Customer' THEN 1
						ELSE 0 END)
		JOIN tblICItem IM	ON	IM.intItemId =CDT.intItemId
		JOIN tblICCommodity c ON ch.intCommodityId = c.intCommodityId
		JOIN tblCTPricingType pt ON pt.intPricingTypeId = CDT.intPricingTypeId
		JOIN tblCTContractType ct ON ct.intContractTypeId = ch.intContractTypeId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = CDT.intCompanyLocationId
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = ch.intCommodityId AND CDT.intUnitMeasureId = ium.intUnitMeasureId
		JOIN tblSMCurrency CUR ON CDT.intCurrencyId = CUR.intCurrencyID
		JOIN tblICCategory Category ON Category.intCategoryId = IM.intCategoryId
		OUTER APPLY (
			select 
				sum(dblTransactionQuantity) as dblTransactionQuantity
				,intContractDetailId 
			from vyuCTSequenceAudit 
			where strFieldName  = 'Balance' 
				and ysnDeleted = 0
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmScreenDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
				AND intContractDetailId = CDT.intContractDetailId
			group by intContractDetailId
		) SeqHis
		WHERE CDT.dblOriginalQty + ISNULL(SeqHis.dblTransactionQuantity,0) <> 0 --This means the sequence is already close
		
		UNION ALL
		SELECT c.strCommodityCode
			, c.intCommodityId
			, ch.intContractHeaderId
			, strContractNumber = ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq)
			, cl.strLocationName
			, CDT.dtmEndDate
			, FM.strFutureMonth
			, CDT.dblQuantity
			, dblBalance = CDT.dblQuantity - PRC.dblPricedQuantity
			, CDT.intUnitMeasureId
			, CDT.intPricingTypeId
			, ch.intContractTypeId
			, cl.intCompanyLocationId
			, ct.strContractType
			, pt.strPricingType
			, ium.intCommodityUnitMeasureId
			, CDT.intContractDetailId
			, CDT.intContractStatusId
			, ch.intEntityId
			, CDT.intCurrencyId
			, CUR.strCurrency
			, strType = ct.strContractType + ' Basis'
			, IM.intItemId
			, IM.strItemNo
			, ch.dtmContractDate
			, EY.strEntityName
			, ch.strCustomerContract
			, Category.intCategoryId
			, strCategory = Category.strCategoryCode
			, FM.intFutureMonthId
			, FM.intFutureMarketId
			, FM.strFutMarketName
		FROM tblCTContractDetail CDT
		LEFT JOIN (SELECT intFutureMonthId, strFutureMonth, tblRKFutureMarket.intFutureMarketId, tblRKFutureMarket.strFutMarketName
				FROM tblRKFuturesMonth
				LEFT JOIN tblRKFutureMarket ON tblRKFutureMarket.intFutureMarketId = tblRKFuturesMonth.intFutureMarketId) FM ON CDT.intFutureMonthId = FM.intFutureMonthId
		JOIN Pricing PRC ON CDT.intContractDetailId = PRC.intContractDetailId AND CDT.intPricingTypeId = 2
		JOIN tblCTContractHeader ch ON ch.intContractHeaderId = CDT.intContractHeaderId AND CDT.intContractStatusId NOT IN (2,3)
		JOIN vyuCTEntity EY	ON	EY.intEntityId = ch.intEntityId
			AND 1 = (CASE WHEN ch.intContractTypeId = 1 AND EY.strEntityType = 'Vendor' THEN 1
						WHEN ch.intContractTypeId <> 1 AND EY.strEntityType = 'Customer' THEN 1
						ELSE 0 END)
		JOIN tblICItem IM ON IM.intItemId =	CDT.intItemId
		JOIN tblICCommodity c ON ch.intCommodityId = c.intCommodityId
		JOIN tblCTPricingType pt ON pt.intPricingTypeId = CDT.intPricingTypeId
		JOIN tblCTContractType ct ON ct.intContractTypeId = ch.intContractTypeId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = CDT.intCompanyLocationId
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = ch.intCommodityId AND CDT.intUnitMeasureId = ium.intUnitMeasureId
		JOIN tblSMCurrency CUR ON CDT.intCurrencyId = CUR.intCurrencyID
		JOIN tblICCategory Category ON Category.intCategoryId = IM.intCategoryId
		OUTER APPLY (
			select 
				sum(dblTransactionQuantity) as dblTransactionQuantity
				,intContractDetailId 
			from vyuCTSequenceAudit 
			where strFieldName  = 'Balance' 
				and ysnDeleted = 0
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmScreenDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
				AND intContractDetailId = CDT.intContractDetailId
			group by intContractDetailId
		) SeqHis
		WHERE dblPricedQuantity < dblRecQty
		AND CDT.dblOriginalQty + ISNULL(SeqHis.dblTransactionQuantity,0) <> 0 --This means the sequence is already close
		
		UNION ALL
		SELECT c.strCommodityCode
			, c.intCommodityId
			, ch.intContractHeaderId
			, strContractNumber = strContractNumber +'-' +Convert(nvarchar,intContractSeq)
			, strLocationName
			, dtmEndDate
			, FM.strFutureMonth
			, CDT.dblQuantity
			, dblBalance = CDT.dblOriginalQty + ISNULL(SeqHis.dblTransactionQuantity,0)
			, CDT.intUnitMeasureId
			, CDT.intPricingTypeId
			, ch.intContractTypeId
			, cl.intCompanyLocationId
			, ct.strContractType
			, pt.strPricingType
			, ium.intCommodityUnitMeasureId
			, CDT.intContractDetailId
			, CDT.intContractStatusId
			, EY.intEntityId
			, CDT.intCurrencyId
			, CUR.strCurrency
			, strType = ct.strContractType + ' ' + pt.strPricingType 
			, IM.intItemId
			, IM.strItemNo
			, ch.dtmContractDate
			, strEntityName
			, ch.strCustomerContract
			, Category.intCategoryId
			, strCategory = Category.strCategoryCode
			, FM.intFutureMonthId
			, FM.intFutureMarketId
			, FM.strFutMarketName
		FROM tblCTContractDetail CDT
		LEFT JOIN (SELECT intFutureMonthId, strFutureMonth, tblRKFutureMarket.intFutureMarketId, tblRKFutureMarket.strFutMarketName
				FROM tblRKFuturesMonth
				LEFT JOIN tblRKFutureMarket ON tblRKFutureMarket.intFutureMarketId = tblRKFuturesMonth.intFutureMarketId) FM ON CDT.intFutureMonthId = FM.intFutureMonthId
		JOIN tblCTContractHeader ch ON ch.intContractHeaderId = CDT.intContractHeaderId AND CDT.intContractStatusId NOT IN (2,3)
		JOIN vyuCTEntity EY	ON EY.intEntityId = ch.intEntityId
			AND 1 = (CASE WHEN ch.intContractTypeId = 1 AND EY.strEntityType = 'Vendor' THEN 1
						WHEN ch.intContractTypeId <> 1 AND EY.strEntityType = 'Customer' THEN 1
						ELSE 0 END)
		JOIN tblICItem IM ON IM.intItemId =	CDT.intItemId
		JOIN tblICCommodity c ON ch.intCommodityId = c.intCommodityId AND CDT.intPricingTypeId IN (1, 2, 3, 4)
		JOIN tblCTPricingType pt ON pt.intPricingTypeId = CDT.intPricingTypeId
		JOIN tblCTContractType ct ON ct.intContractTypeId = ch.intContractTypeId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = CDT.intCompanyLocationId
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = ch.intCommodityId AND CDT.intUnitMeasureId = ium.intUnitMeasureId
		JOIN tblSMCurrency CUR ON CDT.intCurrencyId = CUR.intCurrencyID
		JOIN tblICCategory Category ON Category.intCategoryId = IM.intCategoryId
		OUTER APPLY (
			select 
				sum(dblTransactionQuantity) as dblTransactionQuantity
				,intContractDetailId 
			from vyuCTSequenceAudit 
			where strFieldName  = 'Balance' 
				and ysnDeleted = 0
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmScreenDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
				AND intContractDetailId = CDT.intContractDetailId
			group by intContractDetailId
		) SeqHis
		WHERE CDT.intContractDetailId NOT IN (SELECT intContractDetailId FROM Pricing)
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), CDT.dtmCreated, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
		
		UNION ALL
		SELECT c.strCommodityCode
			, c.intCommodityId
			, ch.intContractHeaderId
			, strContractNumber = strContractNumber +'-' +Convert(nvarchar,intContractSeq)
			, strLocationName
			, dtmEndDate
			, FM.strFutureMonth
			, CDT.dblQuantity
			, dblBalance = CDT.dblOriginalQty + ISNULL(SeqHis.dblTransactionQuantity,0)
			, CDT.intUnitMeasureId
			, CDT.intPricingTypeId
			, ch.intContractTypeId
			, cl.intCompanyLocationId
			, ct.strContractType
			, pt.strPricingType
			, ium.intCommodityUnitMeasureId
			, CDT.intContractDetailId
			, CDT.intContractStatusId
			, EY.intEntityId
			, CDT.intCurrencyId
			, CUR.strCurrency
			, strType = ct.strContractType + ' ' + strPricingType
			, IM.intItemId
			, IM.strItemNo
			, ch.dtmContractDate
			, strEntityName
			, ch.strCustomerContract
			, Category.intCategoryId
			, strCategory = Category.strCategoryCode
			, FM.intFutureMonthId
			, FM.intFutureMarketId
			, FM.strFutMarketName
		FROM tblCTContractDetail CDT
		LEFT JOIN (SELECT intFutureMonthId, strFutureMonth, tblRKFutureMarket.intFutureMarketId, tblRKFutureMarket.strFutMarketName
				FROM tblRKFuturesMonth
				LEFT JOIN tblRKFutureMarket ON tblRKFutureMarket.intFutureMarketId = tblRKFuturesMonth.intFutureMarketId) FM ON CDT.intFutureMonthId = FM.intFutureMonthId
		JOIN tblCTContractHeader ch ON ch.intContractHeaderId = CDT.intContractHeaderId AND CDT.intContractStatusId  NOT IN (2,3)
		JOIN vyuCTEntity EY	ON EY.intEntityId = ch.intEntityId
			AND 1 = (CASE WHEN ch.intContractTypeId = 1 AND EY.strEntityType = 'Vendor' THEN 1
						WHEN ch.intContractTypeId <> 1 AND EY.strEntityType = 'Customer' THEN 1
						ELSE 0 END)
		JOIN tblICItem IM ON IM.intItemId =	CDT.intItemId
		JOIN tblICCommodity c ON ch.intCommodityId = c.intCommodityId AND CDT.intPricingTypeId NOT IN (1, 2)
		JOIN tblCTPricingType pt ON pt.intPricingTypeId = CDT.intPricingTypeId
		JOIN tblCTContractType ct ON ct.intContractTypeId = ch.intContractTypeId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = CDT.intCompanyLocationId
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = ch.intCommodityId AND CDT.intUnitMeasureId = ium.intUnitMeasureId
		LEFT JOIN tblSMCurrency CUR ON CDT.intCurrencyId = CUR.intCurrencyID
		JOIN tblICCategory Category ON Category.intCategoryId = IM.intCategoryId
		OUTER APPLY (
			select 
				sum(dblTransactionQuantity) as dblTransactionQuantity
				,intContractDetailId 
			from vyuCTSequenceAudit 
			where strFieldName  = 'Balance' 
				and ysnDeleted = 0
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmScreenDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
				AND intContractDetailId = CDT.intContractDetailId
			group by intContractDetailId
		) SeqHis
		WHERE CDT.intContractDetailId NOT IN (SELECT intContractDetailId FROM Pricing)
			AND CDT.dblQuantity > ISNULL(CDT.dblInvoicedQty, 0) AND ISNULL(CDT.dblBalance, 0) > 0
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), CDT.dtmCreated, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
) t