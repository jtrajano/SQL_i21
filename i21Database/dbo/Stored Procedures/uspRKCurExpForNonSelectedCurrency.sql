CREATE PROC uspRKCurExpForNonSelectedCurrency
	@intWeightUOMId int = null
	, @intCompanyId int = null
	, @intCommodityId int
	, @dtmMarketPremium datetime =null
	, @dtmClosingPrice datetime=null
	, @intCurrencyId int

AS

SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY intContractSeq)) as intRowNum
	, (ch.strContractNumber + '-' + CONVERT(NVARCHAR, cd.intContractSeq)) COLLATE Latin1_General_CI_AS strContractNumber
	, e.strName
	, cd.dblBalance dblQuantity
	, um.strUnitMeasure strUnitMeasure
	, 10.3 dblOrigPrice
	, (c.strCurrency + '/' + um.strUnitMeasure) COLLATE Latin1_General_CI_AS strOrigPriceUOM
	, 9.5 dblPrice
	, (CONVERT(VARCHAR(11), cd.dtmStartDate, 106) + '-' + CONVERT(VARCHAR(11), cd.dtmEndDate, 106)) COLLATE Latin1_General_CI_AS dtmPeriod
	, 'S' COLLATE Latin1_General_CI_AS strContractType
	, 909.5 dblUSDValue
	, strCompanyName
	, 1 as intConcurrencyId
FROM tblCTContractHeader ch
JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and ch.intContractTypeId=2
JOIN tblEMEntity e on e.intEntityId=ch.intEntityId
JOIN tblICItemUOM u on u.intItemUOMId=cd.intItemUOMId 
JOIN tblICUnitMeasure um on um.intUnitMeasureId=u.intUnitMeasureId
JOIN tblSMCurrency c on c.intCurrencyID=cd.intCurrencyId
LEFT JOIN tblSMMultiCompany mc on mc.intMultiCompanyId=ch.intCompanyId
WHERE cd.intCurrencyId<>@intCurrencyId and ch.intCommodityId=@intCommodityId