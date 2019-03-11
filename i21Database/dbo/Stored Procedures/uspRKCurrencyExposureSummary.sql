CREATE PROC [dbo].[uspRKCurrencyExposureSummary]
	 @intCommodityId int
	,@dtmFutureClosingDate datetime=null
	,@intCurrencyId int
	,@dblAP numeric(24,10)
	,@dblAR numeric(24,10)
	,@dblMoneyMarket numeric(24,10)

AS

DECLARE @tblRKSummary TABLE (strSum nvarchar(100),dblValue numeric(24,10))

INSERT INTO @tblRKSummary (strSum,dblValue)
SELECT '1. Treasury', sum(dblAmount) FROM(
SELECT sum(case when strBuySell = 'Buy' then -dblMatchAmount else dblMatchAmount end) dblAmount
	FROM tblRKFutOptTransaction ft
	JOIN tblRKFutOptTransactionHeader  t on ft.intFutOptTransactionHeaderId=t.intFutOptTransactionHeaderId
	JOIN tblCMBank b on b.intBankId=ft.intBankId AND ft.intSelectedInstrumentTypeId=2
	JOIN tblSMCurrencyExchangeRateType rt on rt.intCurrencyExchangeRateTypeId=ft.intCurrencyExchangeRateTypeId
	JOIN tblSMCurrency c on c.strCurrency =ft.strFromCurrency
	LEFT JOIN tblSMMultiCompany mc on mc.intMultiCompanyId=t.intCompanyId
	WHERE ft.intCommodityId=@intCommodityId and isnull(ft.ysnLiquidation,0) =0 
UNION
SELECT sum(Balance.Value) as dblAmount
FROM vyuCMBankAccount CM
OUTER APPLY (SELECT [dbo].[fnGetBankBalance] (intBankAccountId, getdate()) Value) Balance
OUTER APPLY (SELECT TOP 1 strCompanyName from tblSMCompanySetup)SM
OUTER APPLY (SELECT TOP 1 intCompanySetupID from tblSMCompanySetup)SM1
LEFT JOIN tblSMCurrency SMC on SMC.intCurrencyID =  CM.intCurrencyId
LEFT JOIN vyuGLAccountDetail GL on CM.strGLAccountId = GL.strAccountId
WHERE GL.strAccountType='Asset' 

UNION
SELECT @dblMoneyMarket dblAmount
)t

INSERT INTO @tblRKSummary (strSum,dblValue) 
select '2. Liabilities/Receivables',isnull(@dblAR,0)-isnull(@dblAP,0)


INSERT INTO @tblRKSummary (strSum,dblValue)
SELECT 
	 '3. Stock Value ',sum(dblQty * (isnull(dblSettlementPrice,0)+isnull(dblMarketPremium,0))) dblValue

FROM (
	SELECT 
		[dbo].[fnRKGetCurrencyConvertion](fm.intCurrencyId,@intCurrencyId)*
		dbo.fnRKGetLatestClosingPrice(fm.intFutureMarketId, (SELECT TOP 1 intFutureMonthId FROM tblRKFuturesMonth mon
																WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND mon.intFutureMarketId = fm.intFutureMarketId 
																ORDER BY 1 DESC), @dtmFutureClosingDate) dblSettlementPrice
		,[dbo].[fnRKGetCurrencyConvertion](fm.intCurrencyId,@intCurrencyId)
			*dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId,um.intUnitMeasureId,fm.intUnitMeasureId,dblBasis) dblMarketPremium		
		, l.dblQty

	FROM tblCTContractHeader ch
	JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and cd.intCurrencyId=@intCurrencyId
	join tblRKFutureMarket fm on cd.intFutureMarketId=fm.intFutureMarketId
	JOIN tblICInventoryReceiptItem ri on cd.intContractDetailId=ri.intLineNo
	JOIN tblICInventoryReceiptItemLot rl on ri.intInventoryReceiptItemId=rl.intInventoryReceiptItemId
	join tblICStorageLocation sl on sl.intStorageLocationId=rl.intStorageLocationId
	JOIN tblICLot l on rl.intLotId=l.intLotId
	JOIN tblICItem item on item.intItemId=l.intItemId
	join tblSMCurrency c on c.intCurrencyID=cd.intBasisCurrencyId
	join tblICItemUOM iu on iu.intItemUOMId=cd.intBasisUOMId
	join tblICUnitMeasure um on um.intUnitMeasureId=iu.intUnitMeasureId
	join tblSMCurrency cur on cur.intCurrencyID=fm.intCurrencyId
	LEFT join tblSMMultiCompany mc on mc.intMultiCompanyId=ch.intCompanyId
	WHERE ch.intCommodityId=@intCommodityId and dblQty<>0
) t 


INSERT INTO @tblRKSummary (strSum,dblValue)
SELECT '4. Non-USD Sales',sum(dblQuantity*dblPrice) -dblUSDValue
		 FROM(
		select  cd.dblQuantity - (SELECT ISNULL(SUM(dblQtyShipped),0) from tblARInvoice i
								JOIN tblARInvoiceDetail id on i.intInvoiceId=id.intInvoiceId 
								WHERE id.intContractDetailId=cd.intContractDetailId) dblQuantity
			, 1 as intConcurrencyId,cd.intContractDetailId,ch.intEntityId,u.intUnitMeasureId,cd.intCurrencyId,ch.intCompanyId,
			 [dbo].[fnRKGetCurrencyConvertion](cd.intCurrencyId,@intCurrencyId)*(dbo.fnRKGetSequencePrice(cd.intContractDetailId,dbo.fnRKGetLatestClosingPrice(fm.intFutureMarketId, 
																	   (SELECT TOP 1 intFutureMonthId FROM tblRKFuturesMonth mon
																		WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND mon.intFutureMarketId = fm.intFutureMarketId 
																		ORDER BY 1 DESC), @dtmFutureClosingDate) )) dblPrice
		FROM tblCTContractHeader ch
		JOIN tblCTContractDetail cd on ch.intContractHeaderId=cd.intContractHeaderId and ch.intContractTypeId=2
		JOIN tblRKFutureMarket fm on fm.intFutureMarketId=cd.intFutureMarketId
		JOIN tblEMEntity e on e.intEntityId=ch.intEntityId
		JOIN tblICItemUOM u on u.intItemUOMId=cd.intItemUOMId 
		JOIN tblICUnitMeasure um on um.intUnitMeasureId=u.intUnitMeasureId
		JOIN tblSMCurrency c on c.intCurrencyID=cd.intCurrencyId
		LEFT JOIN tblSMMultiCompany mc on mc.intMultiCompanyId=ch.intCompanyId
		WHERE cd.intCurrencyId<>@intCurrencyId and ch.intCommodityId=@intCommodityId)t


INSERT INTO @tblRKSummary(strSum,dblValue)
select 'Exposure',SUM(dblValue) FROM @tblRKSummary

select CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strSum)) as intRowNum,strSum,ISNULL(dblValue,0) dblUSD,1 intConcurrencyId from @tblRKSummary