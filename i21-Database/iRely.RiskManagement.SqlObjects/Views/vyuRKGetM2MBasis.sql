CREATE VIEW [dbo].[vyuRKGetM2MBasis]

AS
SELECT DISTINCT strCommodityCode
			,im.strItemNo
			,ca.strDescription strOriginDest
			,fm.strFutMarketName
			,fm1.strFutureMonth
			,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) AS strPeriodTo
			,strLocationName
			,strMarketZoneCode
			,CASE WHEN ISNULL(muc.strCurrency,'') = '' THEN strCurrency ELSE muc.strCurrency END strCurrency
			,strPricingType
			,'Contract' as strContractInventory
			,strContractType
			,NULL dblCashOrFuture
			,NULL dblBasisOrDiscount
			,CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.strUnitMeasure ELSE mum.strUnitMeasure END strUnitMeasure
			,ch.intCommodityId
			,cd.intItemId
			,i.intOriginId intOriginId
			,cd.intFutureMarketId
			,cd.intFutureMonthId
			,cd.intCompanyLocationId
			,mz.intMarketZoneId
			,CASE WHEN ISNULL(muc.intCurrencyID,'') = '' THEN cd.intCurrencyId ELSE muc.intCurrencyID END  intCurrencyId
			,ch.intPricingTypeId
			,ct.intContractTypeId
			,CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.intUnitMeasureId ELSE mum.intUnitMeasureId END AS intUnitMeasureId
			,0 as intConcurrencyId,
			i.strMarketValuation
		FROM tblCTContractHeader ch 
		join tblCTContractDetail  cd on ch.intContractHeaderId=cd.intContractHeaderId
		LEFT join tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
		LEFT join tblCTPricingType pt on pt.intPricingTypeId=cd.intPricingTypeId
		LEFT join tblICCommodity c on c.intCommodityId=ch.intCommodityId
		LEFT JOIN tblSMCompanyLocation			cl	ON	cl.intCompanyLocationId		=	cd.intCompanyLocationId
		LEFT JOIN tblICItem						im	ON	im.intItemId				=	cd.intItemId
		LEFT JOIN tblICItem i on i.intItemId=cd.intItemId  
		LEFT join tblICCommodityAttribute ca on ca.intCommodityAttributeId=i.intOriginId
		LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = cd.intFutureMarketId
		LEFT JOIN tblRKFuturesMonth fm1 ON fm1.intFutureMonthId = cd.intFutureMonthId
		LEFT JOIN tblICUnitMeasure mum ON mum.intUnitMeasureId = fm.intUnitMeasureId
		LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = fm.intCurrencyId
		LEFT JOIN tblICItemUOM u ON cd.intItemUOMId = u.intItemUOMId
		LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
		LEFT JOIN	tblARMarketZone					mz	ON	mz.intMarketZoneId			=	cd.intMarketZoneId
		
		WHERE  dblBalance > 0 and cd.intPricingTypeId <> 5 and cd.intContractStatusId <> 3	
	union
	SELECT DISTINCT strCommodityCode
			,im.strItemNo
			,ca.strDescription strOriginDest
			,fm.strFutMarketName
			,fm1.strFutureMonth
			,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) AS strPeriodTo
			,strLocationName
			,strMarketZoneCode
			,CASE WHEN ISNULL(muc.strCurrency,'') = '' THEN strCurrency ELSE muc.strCurrency END strCurrency
			,strPricingType
			,'Contract' as strContractInventory
			,strContractType
			,NULL dblCashOrFuture
			,NULL dblBasisOrDiscount
			,CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.strUnitMeasure ELSE mum.strUnitMeasure END strUnitMeasure
			,ch.intCommodityId
			,cd.intItemId
			,i.intOriginId intOriginId
			,fmm.intFutureMarketId
			,cd.intFutureMonthId
			,cd.intCompanyLocationId
			,mz.intMarketZoneId
			,CASE WHEN ISNULL(muc.intCurrencyID,'') = '' THEN cd.intCurrencyId ELSE muc.intCurrencyID END  intCurrencyId
			,ch.intPricingTypeId
			,ct.intContractTypeId
			,CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.intUnitMeasureId ELSE mum.intUnitMeasureId END AS intUnitMeasureId
			,0 as intConcurrencyId,
			i.strMarketValuation
		FROM tblCTContractHeader ch 
		join tblCTContractDetail  cd on ch.intContractHeaderId=cd.intContractHeaderId
		LEFT join tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
		LEFT join tblCTPricingType pt on pt.intPricingTypeId=cd.intPricingTypeId
		LEFT join tblICCommodity c on c.intCommodityId=ch.intCommodityId
		LEFT JOIN tblSMCompanyLocation			cl	ON	cl.intCompanyLocationId		=	cd.intCompanyLocationId
		LEFT JOIN tblICItem						im	ON	im.intItemId				=	cd.intItemId
		LEFT JOIN tblICItem i on i.intItemId=cd.intItemId 
		LEFT join tblICCommodityAttribute ca on ca.intCommodityAttributeId=i.intOriginId		
		LEFT JOIN tblRKCommodityMarketMapping fmm ON fmm.intCommodityId = ch.intCommodityId
		LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = fmm.intFutureMarketId
		LEFT JOIN tblRKFuturesMonth fm1 ON fm1.intFutureMonthId = cd.intFutureMonthId
		LEFT JOIN tblICUnitMeasure mum ON mum.intUnitMeasureId = fm.intUnitMeasureId
		LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = fm.intCurrencyId
		LEFT JOIN tblICItemUOM u ON cd.intItemUOMId = u.intItemUOMId
		LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
		LEFT JOIN	tblARMarketZone					mz	ON	mz.intMarketZoneId			=	cd.intMarketZoneId
		
		WHERE   cd.intPricingTypeId = 5	and cd.intContractStatusId <> 3	 
		
	UNION

		SELECT DISTINCT strCommodityCode
				,i.strItemNo
				,ca.strDescription strOriginDest
				,fm.strFutMarketName
				,strFutureMonth
				,Null AS strPeriodTo
				,strLocationName
				,strMarketZoneCode
				,CASE WHEN ISNULL(muc.strCurrency,'') = '' THEN strCurrency ELSE muc.strCurrency END strCurrency
				,strPricingType
				,'Inventory' as strContractInventory
				,strContractType
				,NULL dblCashOrFuture
				,NULL dblBasisOrDiscount
				,CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.strUnitMeasure ELSE mum.strUnitMeasure END strUnitMeasure
				,ch.intCommodityId
				,cd.intItemId
				,i.intOriginId intOriginId
				,cd.intFutureMarketId
				,cd.intFutureMonthId
				,cd.intCompanyLocationId
				,cd.intMarketZoneId
				,CASE WHEN ISNULL(muc.intCurrencyID,'') = '' THEN cd.intCurrencyId ELSE muc.intCurrencyID END  intCurrencyId
				,ch.intPricingTypeId
				,ch.intContractTypeId
				,CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.intUnitMeasureId ELSE mum.intUnitMeasureId END AS intUnitMeasureId
				,0 as intConcurrencyId,
				i.strMarketValuation
			FROM tblICItemStock iis		
			JOIN tblICItem i on i.intItemId=iis.intItemId 
			LEFT join tblICCommodityAttribute ca on ca.intCommodityAttributeId=i.intOriginId
			LEFT JOIN tblCTContractDetail cd on iis.intItemId=cd.intItemId 
			LEFT JOIN tblCTContractHeader ch on ch.intContractHeaderId=cd.intContractHeaderId
			LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = cd.intFutureMarketId
			LEFT JOIN tblRKFuturesMonth fmon ON fmon.intFutureMonthId = cd.intFutureMonthId
			LEFT JOIN tblICUnitMeasure mum ON mum.intUnitMeasureId = fm.intUnitMeasureId
			LEFT JOIN tblICItemUOM u ON cd.intItemUOMId = u.intItemUOMId
			LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = fm.intCurrencyId
			LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
			LEFT JOIN tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
			LEFT JOIN tblCTPricingType pt on pt.intPricingTypeId=cd.intPricingTypeId
			LEFT JOIN tblICCommodity c on c.intCommodityId=ch.intCommodityId
			LEFT JOIN tblSMCompanyLocation			cl	ON	cl.intCompanyLocationId		=	cd.intCompanyLocationId
			LEFT JOIN	tblARMarketZone					mz	ON	mz.intMarketZoneId			=	cd.intMarketZoneId
			WHERE (iis.dblUnitOnHand > 0 or iis.dblUnitStorage>0) and strContractType <> 'Sale'  and cd.intContractStatusId <> 3
			   and i.strLotTracking = case when (select top 1 strRiskView from tblRKCompanyPreference) = 'Processor' then i.strLotTracking else 'No' end