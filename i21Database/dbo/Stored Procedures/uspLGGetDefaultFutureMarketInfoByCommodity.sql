CREATE PROCEDURE uspLGGetDefaultFutureMarketInfoByCommodity 
	@intCommodityId INT,
	@intItemId INT
AS
BEGIN
	SELECT CO.intCommodityId
		,CO.strCommodityCode
		,FM.intFutureMarketId
		,C.intCurrencyID
		,C.strCurrency
		,UM.intUnitMeasureId
		,UM.strUnitMeasure
		,IU.intItemUOMId
	FROM tblICCommodity CO
	LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CO.intFutureMarketId
	LEFT JOIN tblSMCurrency C ON C.intCurrencyID = FM.intCurrencyId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = FM.intUnitMeasureId
	LEFT JOIN tblICItemUOM IU ON IU.intUnitMeasureId = UM.intUnitMeasureId
	WHERE CO.intCommodityId = @intCommodityId
		AND IU.intItemId = @intItemId
END