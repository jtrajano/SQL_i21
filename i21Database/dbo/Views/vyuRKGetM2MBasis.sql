﻿CREATE VIEW vyuRKGetM2MBasis

AS
	SELECT DISTINCT strCommodityCode
			,strItemNo
			,c.strCountry strOriginDest
			,cd.strFutMarketName
			,strFutureMonth
			,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) AS strPeriodTo
			,strLocationName
			,strMarketZoneCode
			,strCurrency
			,strPricingType
			,'Contract' as strContractInventory
			,strContractType
			,NULL dblCashOrFuture
			,NULL dblBasisOrDiscount
			,CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.strUnitMeasure ELSE mum.strUnitMeasure END strUnitMeasure
			,intCommodityId
			,cd.intItemId
			,intOriginId
			,cd.intFutureMarketId
			,intFutureMonthId
			,intCompanyLocationId
			,intMarketZoneId
			,cd.intCurrencyId
			,intPricingTypeId
			,intContractTypeId
			,CASE WHEN ISNULL(mum.strUnitMeasure,'') = '' THEN um.intUnitMeasureId ELSE mum.intUnitMeasureId END AS intUnitMeasureId
			,0 as intConcurrencyId
		FROM vyuCTContractDetailView cd
		LEFT JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = cd.intFutureMarketId
		LEFT JOIN tblICUnitMeasure mum ON mum.intUnitMeasureId = fm.intUnitMeasureId
		LEFT JOIN tblICItemUOM u ON cd.intItemUOMId = u.intItemUOMId
		LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
		LEFT JOIN tblSMCountry c ON cd.intOriginId = c.intCountryID
		WHERE LEFT(strPricingType,2) <> 'DP'

