CREATE VIEW vyuCTFutureMarketItem

AS

SELECT DISTINCT CM.intCommodityMarketId
    , MA.intFutureMarketId
    , CO.intCommodityId
    , CO.strCommodityCode
    , MA.strFutMarketName
    , MA.strFutSymbol
    , MA.dblContractSize
    , UM.intUnitMeasureId
    , UM.strUnitMeasure
    , CY.intCurrencyID
    , CY.strCurrency
    , CM.strCommodityAttributeId
    , strMainCurrency = MY.strCurrency
    , MY.intMainCurrencyId
    , CY.ysnSubCurrency
    , CY.intCent
    , IT.intItemId
    , ITUOM.intItemUOMId
FROM tblICCommodity CO
JOIN tblRKCommodityMarketMapping	CM	ON	CO.intCommodityId		=    CM.intCommodityId
JOIN tblRKFutureMarket				MA	ON	MA.intFutureMarketId	=    CM.intFutureMarketId
JOIN tblICUnitMeasure				UM	ON	MA.intUnitMeasureId		=    UM.intUnitMeasureId
JOIN tblSMCurrency					CY	ON	CY.intCurrencyID		=    MA.intCurrencyId
JOIN tblICItem						IT  ON  IT.intCommodityId		=    CO.intCommodityId
JOIN tblICItemUOM                ITUOM	ON	ITUOM.intItemId			=    IT.intItemId            AND    ITUOM.intUnitMeasureId = UM.intUnitMeasureId
LEFT JOIN tblSMCurrency				MY	ON	MY.intCurrencyID		=    CY.intMainCurrencyId