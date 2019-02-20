﻿CREATE PROC uspRKCurExpForNonSelectedCurrency
	  @intCommodityId int
	, @dtmClosingPrice datetime=null
	, @intCurrencyId int

AS

BEGIN
		SELECT *,dblQuantity*dblPrice dblUSDValue
		 FROM(
		SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY intContractSeq)) as intRowNum,
			 (ch.strContractNumber + '-' + CONVERT(NVARCHAR, cd.intContractSeq)) COLLATE Latin1_General_CI_AS strContractNumber
			, e.strName
			, cd.dblQuantity - (SELECT ISNULL(SUM(dblQtyShipped),0) from tblARInvoice i
								JOIN tblARInvoiceDetail id on i.intInvoiceId=id.intInvoiceId 
								WHERE id.intContractDetailId=cd.intContractDetailId) dblQuantity
			, um.strUnitMeasure strUnitMeasure
			, isnull(dbo.fnRKGetSequencePrice(cd.intContractDetailId,dbo.fnRKGetLatestClosingPrice(fm.intFutureMarketId, 
																	   (SELECT TOP 1 intFutureMonthId FROM tblRKFuturesMonth mon
																		WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND mon.intFutureMarketId = fm.intFutureMarketId 
																		ORDER BY 1 DESC), @dtmClosingPrice) ),0) dblOrigPrice

			, (c.strCurrency + '/' + um.strUnitMeasure) COLLATE Latin1_General_CI_AS strOrigPriceUOM
			, (CONVERT(VARCHAR(11), cd.dtmStartDate, 106) + '-' + CONVERT(VARCHAR(11), cd.dtmEndDate, 106)) COLLATE Latin1_General_CI_AS dtmPeriod
			, 'S' COLLATE Latin1_General_CI_AS strContractType
			, strCompanyName
			, 1 as intConcurrencyId,cd.intContractDetailId,ch.intEntityId,u.intUnitMeasureId,cd.intCurrencyId,ch.intCompanyId,
			 isnull([dbo].[fnRKGetCurrencyConvertion](cd.intCurrencyId,@intCurrencyId)*(dbo.fnRKGetSequencePrice(cd.intContractDetailId,dbo.fnRKGetLatestClosingPrice(fm.intFutureMarketId, 
																	   (SELECT TOP 1 intFutureMonthId FROM tblRKFuturesMonth mon
																		WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND mon.intFutureMarketId = fm.intFutureMarketId 
																		ORDER BY 1 DESC), @dtmClosingPrice) )),0) dblPrice
		FROM tblCTContractHeader ch
		JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and ch.intContractTypeId=2
		JOIN tblRKFutureMarket fm on fm.intFutureMarketId=cd.intFutureMarketId
		JOIN tblEMEntity e on e.intEntityId=ch.intEntityId
		JOIN tblICItemUOM u on u.intItemUOMId=cd.intItemUOMId 
		JOIN tblICUnitMeasure um on um.intUnitMeasureId=u.intUnitMeasureId
		JOIN tblSMCurrency c on c.intCurrencyID=cd.intCurrencyId and strCheckDescription='NON-FUNCTIONAL CURRENCY EXPOSURE'
		LEFT JOIN tblSMMultiCompany mc on mc.intMultiCompanyId=ch.intCompanyId
		WHERE cd.intCurrencyId<>@intCurrencyId and ch.intCommodityId=@intCommodityId)t where dblQuantity <>0
END