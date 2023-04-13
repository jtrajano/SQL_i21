CREATE VIEW [dbo].[vyuCTPriceContractViewZug]

AS

SELECT
	strPricingType,
	strPriceContractNo,
	strContractType,
	strEntityName,
	strCommodityDescription,
	strLocationName,
	strContractNumber,
	intContractSeq,
	strFutMarketName,
	strFutureMonth,
	dblBasis,
	dblQuantity,
	dblQuantityPriced,
	dblQuantityUnpriced,
	dblAppliedQty,
	dblQuantityAppliedUnpriced,
	dblLoadPriced,
	dblLoadUnpriced,
	dblLoadAppliedUnpriced,
	strUOM,
	dblNoOfLots,
	strStatus,
	dblLotsFixed as dblLotsPrice,
	dblBalanceNoOfLots,
	dblFinalPrice,
	strEntityContract,
	dtmStartDate,
	dtmEndDate,
	strBook,
	strSubBook,
	strCurrency,
	ysnLoad,
	strItemDescription,
	strItemNo,
	strItemShortName,
	strMainCurrency,
	strPriceUOM
FROM vyuCTSearchPriceContract
GO


