CREATE PROCEDURE [dbo].[uspRKCurrencyExposureSummary]
	@intCommodityId INT
	, @dtmFutureClosingDate DATETIME = NULL
	, @intCurrencyId INT
	, @dblAP NUMERIC(24, 10)
	, @dblAR NUMERIC(24, 10)

AS

BEGIN
	SET @dtmFutureClosingDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFutureClosingDate, 110), 110)

	DECLARE @tblRKSummary TABLE (strSum NVARCHAR(100)
		, dblValue NUMERIC(24,10))

	INSERT INTO @tblRKSummary (strSum
		, dblValue)
	SELECT '1. Treasury'
		, SUM(dblAmount)
	FROM (
		SELECT dblAmount = SUM(CASE WHEN strBuySell = 'Buy' THEN dblContractAmount + (- dblMatchAmount) ELSE (- dblContractAmount) + (dblMatchAmount) END)
		FROM tblRKFutOptTransaction ft
		JOIN tblRKFutOptTransactionHeader t ON ft.intFutOptTransactionHeaderId = t.intFutOptTransactionHeaderId
		JOIN tblCMBank b ON b.intBankId = ft.intBankId AND ft.intSelectedInstrumentTypeId = 2
		JOIN tblSMCurrencyExchangeRateType rt ON rt.intCurrencyExchangeRateTypeId = ft.intCurrencyExchangeRateTypeId
		JOIN tblSMCurrency c ON c.strCurrency = ft.strFromCurrency
		LEFT JOIN tblSMMultiCompany mc ON mc.intMultiCompanyId = t.intCompanyId
		WHERE ft.intCommodityId = @intCommodityId AND ISNULL(ft.ysnLiquidation, 0) = 0
	) t
	
	INSERT INTO @tblRKSummary (strSum, dblValue)
	SELECT '2. Liabilities/Receivables'
		, ISNULL(@dblAR, 0) - ISNULL(@dblAP,0)

	INSERT INTO @tblRKSummary (strSum, dblValue)
	SELECT '3. Stock Value '
		, SUM(dblQty * (ISNULL(dblSettlementPrice, 0) + ISNULL(dblMarketPremium, 0))) dblValue
	FROM (
		SELECT [dbo].[fnRKGetCurrencyConvertion](fm.intCurrencyId, @intCurrencyId, DEFAULT)
				* dbo.fnRKGetLatestClosingPrice(fm.intFutureMarketId, (SELECT TOP 1 intFutureMonthId FROM tblRKFuturesMonth mon
																	WHERE ysnExpired = 0 AND dtmSpotDate <= GETDATE() AND mon.intFutureMarketId = fm.intFutureMarketId
																	ORDER BY 1 DESC), @dtmFutureClosingDate) dblSettlementPrice
			, [dbo].[fnRKGetCurrencyConvertion](fm.intCurrencyId, @intCurrencyId, DEFAULT)
				* dbo.[fnCTConvertQuantityToTargetItemUOM](cd.intItemId, um.intUnitMeasureId, fm.intUnitMeasureId, dblBasis) dblMarketPremium
			, l.dblQty
		FROM tblCTContractHeader ch
		JOIN tblCTContractDetail cd ON ch.intContractHeaderId = cd.intContractHeaderId
		JOIN tblRKFutureMarket fm ON cd.intFutureMarketId = fm.intFutureMarketId
		JOIN tblICInventoryReceiptItem ri ON cd.intContractDetailId = ri.intLineNo
		JOIN tblICInventoryReceiptItemLot rl ON ri.intInventoryReceiptItemId = rl.intInventoryReceiptItemId
		JOIN tblICStorageLocation sl ON sl.intStorageLocationId = rl.intStorageLocationId
		JOIN tblICLot l ON rl.intLotId = l.intLotId
		JOIN tblICItem item ON item.intItemId = l.intItemId
		JOIN tblSMCurrency c ON c.intCurrencyID = cd.intBasisCurrencyId
		JOIN tblICItemUOM iu ON iu.intItemUOMId = cd.intBasisUOMId
		JOIN tblICUnitMeasure um ON um.intUnitMeasureId = iu.intUnitMeasureId
		JOIN tblSMCurrency cur ON cur.intCurrencyID = fm.intCurrencyId
		WHERE ch.intCommodityId = @intCommodityId AND dblQty <> 0
	) t
	
	INSERT INTO @tblRKSummary (strSum, dblValue)
	SELECT '4. Non-USD Sales'
		, - SUM(dblQuantity*dblPrice) dblUSDValue
	FROM (
		SELECT cd.dblQuantity - (SELECT ISNULL(SUM(dblQtyShipped), 0) FROM tblARInvoice i
								JOIN tblARInvoiceDetail id ON i.intInvoiceId = id.intInvoiceId
								WHERE id.intContractDetailId = cd.intContractDetailId) dblQuantity
			, intConcurrencyId = 1
			, cd.intContractDetailId
			, ch.intEntityId
			, u.intUnitMeasureId
			, cd.intCurrencyId
			, ch.intCompanyId
			, dblPrice = [dbo].[fnRKGetCurrencyConvertion](cd.intCurrencyId, @intCurrencyId, DEFAULT) * (dbo.fnRKGetSequencePrice(cd.intContractDetailId, dbo.fnRKGetLatestClosingPrice(cd.intFutureMarketId, cd.intFutureMonthId, @dtmFutureClosingDate), @dtmFutureClosingDate))
		FROM tblCTContractHeader ch
		JOIN tblCTContractDetail cd ON ch.intContractHeaderId = cd.intContractHeaderId AND ch.intContractTypeId = 2
		JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = cd.intFutureMarketId
		JOIN tblEMEntity e ON e.intEntityId = ch.intEntityId
		JOIN tblICItemUOM u ON u.intItemUOMId = cd.intItemUOMId 
		JOIN tblICUnitMeasure um ON um.intUnitMeasureId = u.intUnitMeasureId
		JOIN tblSMCurrency c ON c.intCurrencyID = cd.intCurrencyId
		LEFT JOIN tblSMMultiCompany mc ON mc.intMultiCompanyId = ch.intCompanyId
		WHERE cd.intCurrencyId <> @intCurrencyId AND ch.intCommodityId = @intCommodityId
	) t
	
	INSERT INTO @tblRKSummary(strSum, dblValue)
	SELECT 'Exposure', SUM(dblValue) FROM @tblRKSummary
	
	SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strSum))
		, strSum
		, dblUSD = ISNULL(dblValue, 0)
		, 1 intConcurrencyId
	FROM @tblRKSummary
END