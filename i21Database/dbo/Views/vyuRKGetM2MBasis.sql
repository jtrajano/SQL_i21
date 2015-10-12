CREATE VIEW vyuRKGetM2MBasis

AS
	SELECT DISTINCT strCommodityCode
			,cd.strItemNo
			,c.strCountry strOriginDest
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
			,cd.intOriginId
			,cd.intFutureMarketId
			,intFutureMonthId
			,intCompanyLocationId
			,intMarketZoneId
			,CASE WHEN ISNULL(muc.intCurrencyID,'') = '' THEN cd.intCurrencyId ELSE muc.intCurrencyID END  intCurrencyId
			,intPricingTypeId
			,intContractTypeId
			,CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.intUnitMeasureId ELSE mum.intUnitMeasureId END AS intUnitMeasureId
			,0 as intConcurrencyId
		FROM vyuCTContractDetailView cd
		LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = cd.intFutureMarketId
		LEFT JOIN tblICUnitMeasure mum ON mum.intUnitMeasureId = fm.intUnitMeasureId
		LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = fm.intCurrencyId
		LEFT JOIN tblICItemUOM u ON cd.intItemUOMId = u.intItemUOMId
		LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
		LEFT JOIN tblSMCountry c ON cd.intOriginId = c.intCountryID
		WHERE LEFT(strPricingType,2) <> 'DP' and dblBalance > 0
		
	UNION

		SELECT DISTINCT strCommodityCode
				,cd.strItemNo
				,c.strCountry strOriginDest
				,cd.strFutMarketName
				,strFutureMonth
				,RIGHT(CONVERT(VARCHAR(11),UPPER(dtmEndDate),106),8) AS strPeriodTo
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
				,cd.intOriginId
				,cd.intFutureMarketId
				,intFutureMonthId
				,intCompanyLocationId
				,intMarketZoneId
				,CASE WHEN ISNULL(muc.intCurrencyID,'') = '' THEN cd.intCurrencyId ELSE muc.intCurrencyID END  intCurrencyId
				,intPricingTypeId
				,intContractTypeId
				,CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.intUnitMeasureId ELSE mum.intUnitMeasureId END AS intUnitMeasureId
				,0 as intConcurrencyId
			FROM tblICItemStock iis		
			LEFT JOIN vyuCTContractDetailView cd on iis.intItemId=cd.intItemId 
			LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = cd.intFutureMarketId
			LEFT JOIN tblICUnitMeasure mum ON mum.intUnitMeasureId = fm.intUnitMeasureId
			LEFT JOIN tblICItemUOM u ON cd.intItemUOMId = u.intItemUOMId
			LEFT JOIN tblSMCurrency muc ON muc.intCurrencyID = fm.intCurrencyId
			LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
			LEFT JOIN tblSMCountry c ON cd.intOriginId = c.intCountryID
			WHERE LEFT(strPricingType,2) <> 'DP' and (iis.dblUnitOnHand > 0 or iis.dblUnitStorage>0) and strContractType <> 'Sale'
	