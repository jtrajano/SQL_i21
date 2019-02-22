CREATE VIEW vyuRKGetNonOTC

AS

SELECT  
	s.intCurExpNonOpenSalesId,
	s.intCurrencyExposureId,
	s.intCustomerId,
	s.dblQuantity,
	s.intQuantityUOMId,
	s.dblOrigPrice,
	s.intOrigPriceUOMId,
	s.intOrigPriceCurrencyId,
	s.dblPrice,
	s.strPeriod,
	s.strContractType,
	isnull(s.dblValueUSD,0) dblUSDValue,
	s.intCompanyId,um.strUnitMeasure,c.strCurrency,
	(c.strCurrency + '/' + um.strUnitMeasure) COLLATE Latin1_General_CI_AS strOrigPriceUOM,s.intConcurrencyId,
	 (ch.strContractNumber + '-' + CONVERT(NVARCHAR, cd.intContractSeq)) COLLATE Latin1_General_CI_AS strContractNumber
	 ,e.strName
FROM tblRKCurExpNonOpenSales s
JOIN tblCTContractDetail cd on cd.intContractDetailId=s.intContractDetailId 
join tblCTContractHeader ch on ch.intContractHeaderId=cd.intContractHeaderId
JOIN tblICUnitMeasure um on um.intUnitMeasureId=s.intQuantityUOMId
JOIN tblSMCurrency c on c.intCurrencyID=s.intOrigPriceCurrencyId
JOIN tblEMEntity e on e.intEntityId=ch.intEntityId