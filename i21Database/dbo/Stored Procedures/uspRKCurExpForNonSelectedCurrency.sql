CREATE PROC [dbo].[uspRKCurExpForNonSelectedCurrency]
         @intCommodityId int
       , @dtmClosingPrice datetime = null
       , @intCurrencyId int

AS

BEGIN
              SELECT *,[dbo].[fnRKGetCurrencyConvertion](intCurrencyId,@intCurrencyId)*dblOrigPrice dblPrice, 
              ([dbo].[fnRKGetCurrencyConvertion](intCurrencyId,@intCurrencyId)*dblOrigPrice)*dblQuantity dblUSDValue,intCurrencyId,@intCurrencyId
              FROM(
              SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY intContractSeq)) as intRowNum,
                     (ch.strContractNumber + '-' + CONVERT(NVARCHAR, cd.intContractSeq)) COLLATE Latin1_General_CI_AS strContractNumber
                     , e.strName
                     , cd.dblQuantity - (SELECT ISNULL(SUM(dblQtyShipped),0) from tblARInvoice i
                                                       JOIN tblARInvoiceDetail id on i.intInvoiceId=id.intInvoiceId 
                                                       WHERE id.intContractDetailId=cd.intContractDetailId) dblQuantity
                     , um.strUnitMeasure strUnitMeasure
                     ,
                     dbo.fnRKGetSequencePrice(cd.intContractDetailId,
					 dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId, cd.intFutureMonthId
														, @dtmClosingPrice),@dtmClosingPrice) dblOrigPrice -- remove the basis from function then convert the price uom only settlement price. then we have added the basis

                     , (c.strCurrency + '/' + um.strUnitMeasure) COLLATE Latin1_General_CI_AS strOrigPriceUOM
                     , (CONVERT(VARCHAR(11), cd.dtmStartDate, 106) + '-' + CONVERT(VARCHAR(11), cd.dtmEndDate, 106)) COLLATE Latin1_General_CI_AS dtmPeriod
                     , 'S' COLLATE Latin1_General_CI_AS strContractType
                     , strCompanyName
                     , 1 as intConcurrencyId,cd.intContractDetailId,ch.intEntityId,u.intUnitMeasureId,cd.intCurrencyId,ch.intCompanyId
              FROM tblCTContractHeader ch
              JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and ch.intContractTypeId=2
              JOIN tblRKFutureMarket fm on fm.intFutureMarketId=cd.intFutureMarketId
              JOIN tblEMEntity e on e.intEntityId=ch.intEntityId
              JOIN tblICItemUOM u on u.intItemUOMId=cd.intItemUOMId 
              JOIN tblICUnitMeasure um on um.intUnitMeasureId=u.intUnitMeasureId
              JOIN tblSMCurrency c on c.intCurrencyID=cd.intCurrencyId and strCheckDescription='NON-FUNCTIONAL CURRENCY EXPOSURE'
              LEFT JOIN tblSMMultiCompany mc on mc.intMultiCompanyId=ch.intCompanyId
              WHERE cd.intCurrencyId<>@intCurrencyId and ch.intCommodityId=@intCommodityId
			  )t where dblQuantity <>0
END