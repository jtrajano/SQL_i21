CREATE PROCEDURE [dbo].[uspRKCurExpForNonSelectedCurrency]
	@intCommodityId int
	, @dtmClosingPrice datetime = null
	, @intCurrencyId int

AS

BEGIN
	SELECT *
		, dblOrigPrice dblPrice
		, dblOrigPrice * dblQuantity dblUSDValue		
	FROM (
		SELECT CONVERT(INT, ROW_NUMBER() OVER(ORDER BY intContractSeq)) as intRowNum
			, (ch.strContractNumber + '-' + CONVERT(NVARCHAR, cd.intContractSeq)) COLLATE Latin1_General_CI_AS strContractNumber
			, e.strName
			, cd.dblQuantity - (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblARInvoice i
								JOIN tblARInvoiceDetail id ON i.intInvoiceId = id.intInvoiceId
								WHERE id.intContractDetailId = cd.intContractDetailId) dblQuantity
			, um.strUnitMeasure strUnitMeasure
			, dblOrigPrice = [dbo].[fnRKGetCurrencyConvertion](cd.intCurrencyId, @intCurrencyId, DEFAULT) * (dbo.fnRKGetSequencePrice(cd.intContractDetailId, dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId, cd.intFutureMonthId, @dtmClosingPrice), @dtmClosingPrice))
			, (c.strCurrency + '/' + um.strUnitMeasure) COLLATE Latin1_General_CI_AS strOrigPriceUOM
			, (CONVERT(VARCHAR(11), cd.dtmStartDate, 106) + '-' + CONVERT(VARCHAR(11), cd.dtmEndDate, 106)) COLLATE Latin1_General_CI_AS dtmPeriod
			, 'S' COLLATE Latin1_General_CI_AS strContractType
			, strCompanyName
			, 1 as intConcurrencyId
			, cd.intContractDetailId
			, ch.intEntityId
			, u.intUnitMeasureId
			, cd.intCurrencyId
			, ch.intCompanyId
		FROM tblCTContractHeader ch
		JOIN tblCTContractDetail cd ON ch.intContractHeaderId = cd.intContractHeaderId AND ch.intContractTypeId = 2
		JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = cd.intFutureMarketId
		JOIN tblEMEntity e ON e.intEntityId = ch.intEntityId
		JOIN tblICItemUOM u ON u.intItemUOMId = cd.intItemUOMId 
		JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
		JOIN tblSMCurrency c ON c.intCurrencyID = cd.intCurrencyId
		LEFT JOIN tblSMMultiCompany mc ON mc.intMultiCompanyId = ch.intCompanyId
		WHERE cd.intCurrencyId <> @intCurrencyId AND ch.intCommodityId = @intCommodityId
	)t where dblQuantity <> 0
END