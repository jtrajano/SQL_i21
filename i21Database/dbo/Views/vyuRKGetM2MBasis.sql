CREATE VIEW vyuRKGetM2MBasis

AS
	SELECT DISTINCT strCommodityCode
			,cd.strItemNo
			,ca.strDescription strOriginDest
			,cd.strFutMarketName
			,strFutureMonth
			,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) AS strPeriodTo
			,strLocationName
			,strMarketZoneCode
			,CASE WHEN ISNULL(muc.strCurrency,'') = '' THEN cd.strCurrency ELSE muc.strCurrency END strCurrency
			,strPricingType
			,'Contract' as strContractInventory
			,strContractType
			,NULL dblCashOrFuture
			,NULL dblBasisOrDiscount
			,CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.strUnitMeasure ELSE mum.strUnitMeasure END strUnitMeasure
			,cd.intCommodityId
			,cd.intItemId
			,i.intOriginId intOriginId
			,cd.intFutureMarketId
			,intFutureMonthId
			,intCompanyLocationId
			,intMarketZoneId
			,CASE WHEN ISNULL(muc.intCurrencyID,'') = '' THEN cd.intCurrencyId ELSE muc.intCurrencyID END  intCurrencyId
			,intPricingTypeId
			,intContractTypeId
			,CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.intUnitMeasureId ELSE mum.intUnitMeasureId END AS intUnitMeasureId
			,0 as intConcurrencyId,
			i.strMarketValuation
		FROM vyuCTContractDetailView cd
		LEFT JOIN tblICItem i on i.intItemId=cd.intItemId and cd.intContractStatusId <> 3	 
		LEFT join tblICCommodityAttribute ca on ca.intCommodityAttributeId=i.intOriginId
		LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = cd.intFutureMarketId
		LEFT JOIN tblICUnitMeasure mum ON mum.intUnitMeasureId = fm.intUnitMeasureId
		LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = fm.intCurrencyId
		LEFT JOIN tblICItemUOM u ON cd.intItemUOMId = u.intItemUOMId
		LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
		WHERE LEFT(strPricingType,2) <> 'DP' and dblBalance > 0
		
	UNION

		SELECT DISTINCT strCommodityCode
				,cd.strItemNo
				,ca.strDescription strOriginDest
				,cd.strFutMarketName
				,strFutureMonth
				,Null AS strPeriodTo
				,strLocationName
				,strMarketZoneCode
				,CASE WHEN ISNULL(muc.strCurrency,'') = '' THEN cd.strCurrency ELSE muc.strCurrency END strCurrency
				,strPricingType
				,'Inventory' as strContractInventory
				,strContractType
				,NULL dblCashOrFuture
				,NULL dblBasisOrDiscount
				,CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.strUnitMeasure ELSE mum.strUnitMeasure END strUnitMeasure
				,cd.intCommodityId
				,cd.intItemId
				,i.intOriginId intOriginId
				,cd.intFutureMarketId
				,intFutureMonthId
				,intCompanyLocationId
				,intMarketZoneId
				,CASE WHEN ISNULL(muc.intCurrencyID,'') = '' THEN cd.intCurrencyId ELSE muc.intCurrencyID END  intCurrencyId
				,intPricingTypeId
				,intContractTypeId
				,CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.intUnitMeasureId ELSE mum.intUnitMeasureId END AS intUnitMeasureId
				,0 as intConcurrencyId,
				i.strMarketValuation
			FROM tblICItemStock iis		
			JOIN tblICItem i on i.intItemId=iis.intItemId 
			LEFT join tblICCommodityAttribute ca on ca.intCommodityAttributeId=i.intOriginId
			LEFT JOIN vyuCTContractDetailView cd on iis.intItemId=cd.intItemId  and cd.intContractStatusId <> 3
			LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = cd.intFutureMarketId
			LEFT JOIN tblICUnitMeasure mum ON mum.intUnitMeasureId = fm.intUnitMeasureId
			LEFT JOIN tblICItemUOM u ON cd.intItemUOMId = u.intItemUOMId
			LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = fm.intCurrencyId
			LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
			WHERE LEFT(strPricingType,2) <> 'DP' and (iis.dblUnitOnHand > 0 or iis.dblUnitStorage>0) and strContractType <> 'Sale'
			   and i.strLotTracking = case when (select top 1 strRiskView from tblRKCompanyPreference) = 'Processor' then i.strLotTracking else 'No' end

