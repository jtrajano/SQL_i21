CREATE VIEW [dbo].[vyuRKGetReplacementPriceByForecast]

AS

SELECT DISTINCT
	strItemNo = Item.strDescription + '(' + BundleItem.strItemNo + ')'
	, dblFOB = BD.dblBasisOrDiscount
	, BookPort.BookPortName
	, dblCNFCost = ISNULL(BD.dblBasisOrDiscount, 0.0) + ISNULL((((1 * BookPort.dblTotalCostPerContainer) / 
								dbo.fnCalculateCostBetweenUOM(
									(SELECT intItemUOMId FROM tblICItemUOM WHERE intItemId=BD.intItemId AND intUnitMeasureId=BD.intUnitMeasureId), 
									(SELECT intItemUOMId FROM tblICItemUOM WHERE intItemId=BD.intItemId AND ysnStockUnit=1), 
									19200)) * CASE WHEN Cur.ysnSubCurrency = 1 THEN Cur.intCent ELSE 1 END), 0.0)
FROM tblRKM2MBasisDetail BD
JOIN (
	SELECT TOP 1 * FROM tblRKM2MBasis
	WHERE strPricingType = 'Forecast'
	ORDER BY dtmM2MBasisDate DESC
) H ON H.intM2MBasisId = BD.intM2MBasisId
LEFT JOIN tblICItem Item ON Item.intItemId = BD.intItemId
LEFT JOIN tblICItemBundle IB ON IB.intBundleItemId = BD.intItemId
LEFT JOIN tblICItem BundleItem ON BundleItem.intItemId = IB.intItemId
LEFT JOIN tblICCommodityAttribute Origin ON Origin.intCommodityAttributeId = Item.intOriginId
LEFT JOIN tblSMCountry Country ON Country.intCountryID = Origin.intCountryID
LEFT JOIN tblSMCity City ON City.intCountryId = Country.intCountryID
LEFT JOIN tblSMCurrency Cur ON Cur.intCurrencyID = BD.intCurrencyId
LEFT JOIN (
	SELECT DISTINCT BookPortName = 'C&F-' + BE.strBook + '-' + City.strCity
		, BE.strBook
		, strDestinationCountry = Country.strCountry
		, strDestinationCity = City.strCity
		, FM.dblTotalCostPerContainer
		, FM.strOriginPort
	FROM vyuCTBookVsEntity BE
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = BE.intEntityId
	LEFT JOIN tblSMCountry Country ON Country.strCountry = EL.strCountry
	LEFT JOIN tblSMCity City ON City.intCountryId = Country.intCountryID
	LEFT JOIN tblLGFreightRateMatrix FM ON FM.strDestinationCity = City.strCity
		AND CAST(FLOOR(CAST(FM.dtmValidFrom AS FLOAT)) AS DATETIME) <= GETDATE()
		AND CAST(FLOOR(CAST(FM.dtmValidTo AS FLOAT)) AS DATETIME) >= GETDATE()
	WHERE EL.ysnDefaultLocation = 1
		AND City.ysnPort = 1 AND City.ysnDefault = 1
		AND FM.intType = 1
) BookPort ON BookPort.strOriginPort = City.strCity
WHERE City.ysnPort = 1 AND ISNULL(BookPort.dblTotalCostPerContainer, 0.0) <> 0.0