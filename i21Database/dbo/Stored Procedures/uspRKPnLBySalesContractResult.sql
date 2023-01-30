CREATE PROCEDURE uspRKPnLBySalesContractResult
		@intSContractDetailId	INT,
		@intCurrencyId			INT,-- currency
		@intUnitMeasureId		INT,--- Price uom	
		@intWeightUOMId			INT -- weight 		
AS

BEGIN
	DECLARE @ysnSubCurrency BIT
	DECLARE @strQuantityUnitMeasure NVARCHAR(50) 
	DECLARE @strPriceUOM NVARCHAR(50)
	DECLARE @strUnitMeasure NVARCHAR(200) = ''

	SELECT @ysnSubCurrency = ISNULL(ysnSubCurrency, 0) FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyId
	SELECT @strQuantityUnitMeasure = strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = @intUnitMeasureId
	SELECT @strPriceUOM = strDescription FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyId

	SET @strUnitMeasure = @strPriceUOM + ' Per ' + @strQuantityUnitMeasure

	DECLARE @Result TABLE (intResultId INT IDENTITY PRIMARY KEY
		, intContractHeaderId INT
		, intContractDetailId INT
		, strContractNumber NVARCHAR(50)
		, strContractType NVARCHAR(50)
		, dblQty NUMERIC(18, 6)
		, dblUSD NUMERIC(18, 6)
		, dblBasis NUMERIC(18, 6)
		, dblAllocatedQty NUMERIC(18, 6)
		, dblInvoicePrice NUMERIC(18, 6)
		, dblBasisUSD NUMERIC(18, 6)
		, dblAllocatedQtyUSD NUMERIC(18, 6)
		, dblCostUSD NUMERIC(18, 6)
		, strUnitMeasure NVARCHAR(200)
		, dblPriceVariation NUMERIC(18, 6)
		, strUOMVariation NVARCHAR(100))

	DECLARE @PhysicalFuturesResult TABLE (intRowNum INT
		, strContractType NVARCHAR(50)
		, strNumber NVARCHAR(50)
		, strDescription NVARCHAR(50)
		, strConfirmed NVARCHAR(50)
		, dblAllocatedQty NUMERIC(18, 6)
		, dblPrice NUMERIC(18, 6)
		, strCurrency NVARCHAR(50)
		, dblFX NUMERIC(18, 6)
		, dblBooked NUMERIC(18, 6)
		, dblAccounting NUMERIC(18, 6)
		, dtmDate DATETIME
		, strType NVARCHAR(100)
		, dblTranValue NUMERIC(18, 6)
		, intSort INT
		, dblTransactionValue NUMERIC(18, 6)
		, dblForecast NUMERIC(18, 6)
		, dblBasisUSD NUMERIC(18, 6)
		, dblCostUSD NUMERIC(18, 6)
		, strUnitMeasure NVARCHAR(200)
		, intContractDetailId INT
		, ysnPosted BIT)

	INSERT INTO @PhysicalFuturesResult (intRowNum
		, strContractType
		, strNumber
		, strDescription
		, strConfirmed
		, dblAllocatedQty
		, dblPrice
		, strCurrency
		, dblFX
		, dblBooked
		, dblAccounting
		, dtmDate
		, strType
		, dblTranValue
		, intSort
		, ysnPosted
		, dblTransactionValue
		, dblForecast
		, intContractDetailId)
	EXEC uspRKPNLPhysicalFuturesResult @intSContractDetailId, @intCurrencyId, @intUnitMeasureId, @intWeightUOMId 

	DECLARE @dblAllocatedQty NUMERIC(18, 6)
		, @dblAllocatedQtyUSD NUMERIC(18, 6)
		, @dtmToDate DATETIME
		, @dblPricePurchase NUMERIC(18, 6)
		, @dblConvertedAllocatedQty NUMERIC(18, 6)

	SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110), 110)

	SELECT @dblPricePurchase = SUM(dblPrice * dblAllocatedQty) / CASE WHEN ISNULL(SUM(dblAllocatedQty), 0) = 0 THEN 1 ELSE SUM(dblAllocatedQty) END FROM @PhysicalFuturesResult WHERE strContractType LIKE 'Purchase -%'

	SELECT @dblAllocatedQty = SUM(ISNULL(sa.dblAllocatedQty, 0))
		, @dblAllocatedQtyUSD = SUM(dbo.fnCTConvertQuantityToTargetItemUOM(sa.intItemId, intUnitMeasureId, 3, sa.dblAllocatedQty))
	FROM vyuRKPnLGetAllocationDetail sa
	JOIN tblICItemUOM u ON u.intItemUOMId = sa.intPItemUOMId
	WHERE sa.intContractTypeId = 2 AND sa.intContractDetailId = @intSContractDetailId

	DECLARE @dblBooked NUMERIC(18, 6)
		, @dblAccounting NUMERIC(18, 6)
		, @dblSuppAccounting NUMERIC(18, 6)

	SELECT @dblBooked = ISNULL(SUM(dblBooked), 0)
		, @dblAccounting = ISNULL(SUM(dblAccounting), 0)
	FROM @PhysicalFuturesResult WHERE strDescription = 'Invoice'
	SELECT @dblSuppAccounting = ISNULL(SUM(dblAccounting), 0) FROM @PhysicalFuturesResult WHERE strDescription = 'Supp. Invoice'

	---------Invoice
	INSERT INTO @Result (intContractHeaderId
		, intContractDetailId
		, strContractNumber
		, strContractType
		, dblQty
		, dblUSD
		, dblBasis
		, dblAllocatedQty
		, dblInvoicePrice
		, dblBasisUSD
		, strUnitMeasure)
	SELECT DISTINCT intContractHeaderId
		, intContractDetailId
		, strSequenceNumber
		, 'Invoices'
		, dblQty = @dblBooked
		, dblUSD = @dblAccounting
		, dblBasis = (SUM(dbo.fnCTConvertQuantityToTargetItemUOM(d.intItemId, @intUnitMeasureId, intPriceUomId, dblSaleBasis)) / COUNT(dblSaleBasis)) / CASE WHEN ISNULL(ysnSubCurrency, 0) = @ysnSubCurrency THEN 1 WHEN ISNULL(ysnSubCurrency, 0) = 1 THEN 100 ELSE 0.01 END
		, dblAllocatedQty = NULL
		, (SELECT ISNULL(SUM(dblPrice), 0) FROM @PhysicalFuturesResult WHERE strDescription = 'Invoice') 
			/ CASE WHEN ISNULL((SELECT CASE WHEN count(ISNULL(dblPrice, 0)) = 0 THEN 1 ELSE count(dblPrice) END	FROM @PhysicalFuturesResult	WHERE strDescription = 'Invoice'), 0)=0 
			 THEN 1 ELSE (SELECT CASE WHEN count(ISNULL(dblPrice, 0)) = 0 THEN 1 ELSE count(dblPrice) END	FROM @PhysicalFuturesResult	WHERE strDescription = 'Invoice') END
		, (SUM(dbo.fnCTConvertQuantityToTargetItemUOM(d.intItemId, 3, intPriceUomId, dblSaleBasis)) / count(dblSaleBasis)) / CASE WHEN ISNULL(ysnSubCurrency, 0) = 1 THEN 100 ELSE 1 END dblBasisUSD
		, @strUnitMeasure
	FROM vyuRKPnLGetAllocationDetail d
	JOIN tblICItemUOM u ON u.intItemUOMId = d.intPItemUOMId
	WHERE intContractTypeId = 2 AND intContractDetailId = @intSContractDetailId
	GROUP BY intContractHeaderId
		, intContractDetailId
		, strSequenceNumber
		, ysnSubCurrency

	---- Purchase
	INSERT INTO @Result (intContractHeaderId
		, intContractDetailId
		, strContractNumber
		, strContractType
		, dblQty
		, dblUSD
		, dblBasis
		, dblAllocatedQty
		, dblInvoicePrice
		, dblBasisUSD
		, strUnitMeasure)
	SELECT intContractHeaderId
		, intContractDetailId
		, strSequenceNumber
		, strContractType
		, dblQty
		, dblUSD
		, dblBasis
		, dblAllocatedQty
		, dblInvoicePrice = CASE WHEN dblUSD = 0 THEN 0 ELSE dblInvoicePrice END
		, dblBasisUSD
		, strUnitMeasure
	FROM (
		SELECT DISTINCT intContractHeaderId
			, intContractDetailId
			, strSequenceNumber
			, strContractType = 'Purchase'
			, dblQty = @dblBooked
			, dblUSD = @dblSuppAccounting
			, dblBasis = (SUM(dbo.fnCTConvertQuantityToTargetItemUOM(d.intItemId, @intUnitMeasureId, intPriceUomId, dblAllocatedQty * dblBasis)) / CASE WHEN ISNULL(SUM(dblAllocatedQty), 0) = 0 THEN 1 ELSE SUM(dblAllocatedQty) END) / CASE WHEN ISNULL(ysnSubCurrency, 0) = @ysnSubCurrency THEN 1 WHEN ISNULL(ysnSubCurrency, 0) = 1 THEN 100 ELSE 0.01 END
			, dblAllocatedQty = @dblAllocatedQty
			, dblInvoicePrice = @dblPricePurchase
			, dblBasisUSD = (SUM(dbo.fnCTConvertQuantityToTargetItemUOM(d.intItemId, 3, intPriceUomId, dblAllocatedQty * dblBasis)) / SUM(dblAllocatedQty)) / CASE WHEN ISNULL(ysnSubCurrency, 0) = 1 THEN 100 ELSE 1 END
			, strUnitMeasure = @strUnitMeasure
		FROM vyuRKPnLGetAllocationDetail d
		WHERE intContractDetailId = @intSContractDetailId AND intContractTypeId = 1
		GROUP BY intContractHeaderId
			, intContractDetailId
			, strSequenceNumber
			, ysnSubCurrency
	) t

	DECLARE @dblSaleBasis NUMERIC(18, 6)
		, @dblPurchaseBasis NUMERIC(18, 6)
		, @dblSaleBasisUSD NUMERIC(18, 6)
		, @dblPurchaseBasisUSD NUMERIC(18, 6)
		, @dblQty NUMERIC(18, 6)
		, @dblUSDPurchase NUMERIC(18, 6)
		, @dblUSDInvoice NUMERIC(18, 6)
		, @dblInvoicePrice NUMERIC(18, 6)
		, @dblPurchasePrice NUMERIC(18, 6)
		, @POCostUSD NUMERIC(18, 6)
		, @SOCostUSD NUMERIC(18, 6)

	SELECT @dblSaleBasisUSD = SUM(dblBasisUSD)
		, @dblSaleBasis = SUM(dblBasis)
		, @dblQty = SUM(dblQty)
		, @dblUSDPurchase = SUM(dblUSD)
		, @dblUSDInvoice = SUM(dblUSD)
		, @dblInvoicePrice = SUM(dblInvoicePrice)
	FROM @Result
	WHERE strContractType = 'Invoices'

	SELECT @dblPurchaseBasisUSD = SUM(dblBasisUSD)
		, @dblPurchaseBasis = SUM(dblBasis)
		, @dblPurchasePrice = SUM(dblInvoicePrice)
		, @dblUSDPurchase = SUM(dblUSD)
	FROM @Result
	WHERE strContractType = 'Purchase'

	SELECT @POCostUSD = SUM(dblAccounting) FROM @PhysicalFuturesResult WHERE strDescription NOT IN ('Invoice', 'Supp. Invoice')
	SELECT @SOCostUSD = 0 FROM @PhysicalFuturesResult WHERE strDescription NOT IN ('Invoice', 'Supp. Invoice')

	--RESULT
	INSERT INTO @Result (strContractType
		, dblBasis
		, strUnitMeasure
		, dblInvoicePrice
		, dblPriceVariation
		, strUOMVariation)
	SELECT DISTINCT 'Gross Profit - Rate'
		, (@dblSaleBasis - @dblPurchaseBasis)
		, @strUnitMeasure
		, (@dblInvoicePrice-@dblPurchasePrice)
		, ((@dblInvoicePrice-@dblPurchasePrice)-(@dblSaleBasis - @dblPurchaseBasis))
		, @strUnitMeasure
	FROM @Result

	INSERT INTO @Result (strContractType
		, dblQty
		, dblUSD
		, dblBasis
		, dblPriceVariation)
	SELECT DISTINCT 'Gross Profit - USD'
		, @dblQty
		, (@dblUSDInvoice + @dblUSDPurchase)
		, @dblQty * ROUND((@dblSaleBasis - @dblPurchaseBasis),2)
		, ((@dblUSDInvoice - @dblUSDPurchase) - ((@dblSaleBasisUSD - @dblPurchaseBasisUSD) * @dblAllocatedQtyUSD))
	FROM @Result

	INSERT INTO @Result (strContractType
		, dblBasis
		, dblUSD
		, dblInvoicePrice
		, dblCostUSD
		, strUnitMeasure
		, dblAllocatedQty)
	SELECT 'PO Costs'
		, dblBasis = SUM(dblBasis * AllocatedQty) / CASE WHEN ISNULL(SUM(AllocatedQty), 0) = 0 THEN 1 ELSE SUM(AllocatedQty) END
		, @POCostUSD
		, (@POCostUSD / SUM(AllocatedQty)) * CASE WHEN @ysnSubCurrency = 1 THEN 100 ELSE 1 END
		, dblCostUSD = SUM(dblBasis * AllocatedQty) / CASE WHEN ISNULL(SUM(AllocatedQty), 0) = 0 THEN 1 ELSE SUM(AllocatedQty) END
		, @strUnitMeasure
		, AllocatedQty = SUM(AllocatedQty)
	FROM (
		SELECT AllocatedQty = MAX(dblAllocatedQty)
			, dblBasis = SUM(dblPrice)
		FROM @PhysicalFuturesResult WHERE strDescription like ('Purchase%')
	) t

	INSERT INTO @Result (strContractType
		, dblBasis
		, dblUSD
		, dblInvoicePrice
		, dblCostUSD
		, strUnitMeasure
		, dblAllocatedQty)
	SELECT 'SO Costs'
		, dblBasis = SUM(dblBasis * AllocatedQty) / SUM(AllocatedQty)
		, @SOCostUSD
		, (@SOCostUSD / SUM(AllocatedQty)) * CASE WHEN @ysnSubCurrency = 1 THEN 100 ELSE 1 END
		, dblCostUSD = SUM(dblBasis * AllocatedQty) / SUM(AllocatedQty)
		, @strUnitMeasure
		, AllocatedQty = SUM(AllocatedQty)
	FROM (
		SELECT AllocatedQty = MAX(dblAllocatedQty)
			, dblBasis = SUM(dblPrice)
		FROM @PhysicalFuturesResult WHERE strDescription LIKE ('Sale%')
	) t

	DECLARE @FinalAllocatedQty NUMERIC(18, 6)

	SELECT @FinalAllocatedQty = ISNULL(SUM(dblAllocatedQty), 0) FROM @Result WHERE strContractType ='PO Costs'

	----Rate
	INSERT INTO @Result (strContractType
		, dblBasis
		, dblInvoicePrice
		, strUnitMeasure
		, dblPriceVariation
		, strUOMVariation)
	SELECT 'Total Costs - Rate'
		, SUM(dblBasis)
		, ((@POCostUSD + @SOCostUSD) / (@FinalAllocatedQty)) * CASE WHEN @ysnSubCurrency = 1 THEN 100 ELSE 1 END
		, @strUnitMeasure
		, SUM(dblBasis)
		, @strUnitMeasure
	FROM @Result
	WHERE strContractType IN ('PO Costs', 'SO Costs')

	INSERT INTO @Result(strContractType
		, dblQty
		, dblUSD
		, dblBasis
		, dblPriceVariation)
	SELECT 'Total Costs USD'
		, @dblQty
		, @POCostUSD + @SOCostUSD
		, ROUND(SUM(dblBasis),2) * @dblQty
		, SUM(dblCostUSD) * @dblAllocatedQtyUSD
	FROM @Result
	WHERE strContractType IN ('PO Costs', 'SO Costs')

	DECLARE @GrossProfitRate NUMERIC(18, 6)
		, @TotalCostRate NUMERIC(18, 6)

	SELECT @FinalAllocatedQty = ISNULL(SUM(dblAllocatedQty), 0) FROM @Result WHERE strContractType ='PO Costs'
	SELECT @GrossProfitRate = SUM(dblBasis) FROM @Result WHERE strContractType ='Gross Profit - Rate'
	SELECT @TotalCostRate = SUM(dblBasis) FROM @Result WHERE strContractType ='Total Costs - Rate'

	---- Profit
	INSERT INTO @Result (strContractType
		, dblBasis
		, strUnitMeasure
		, dblInvoicePrice
		, dblPriceVariation
		, strUOMVariation)
	SELECT 'Physical Profit - Rate'
		, dblBasis
		, strUnitMeasure
		, dblInvoicePrice
		, dblInvoicePrice - dblBasis
		, strUnitMeasure
	FROM (
		SELECT dblBasis = ISNULL(@GrossProfitRate, 0)
							+ ISNULL(@TotalCostRate, 0)
			, strUnitMeasure = @strUnitMeasure
			, dblInvoicePrice = (SUM(dblUSD) / @FinalAllocatedQty) * CASE WHEN @ysnSubCurrency = 1 THEN 100 ELSE 1 END
		FROM @Result
		WHERE strContractType = 'Physical Profit - USD'
	) t

	DECLARE @dblUSD NUMERIC(18, 6)
		, @dblBasis NUMERIC(18, 6)

	SELECT @dblUSD = SUM(dblUSD)
		, @dblBasis = SUM(dblBasis)
	FROM @Result WHERE strContractType = 'Total Costs USD'

	INSERT INTO @Result (strContractType
		, dblQty
		, dblUSD
		, dblBasis
		, dblPriceVariation)
	SELECT 'Physical Profit - USD'
		, dblQty
		, dblUSD
		, dblBasis
		, ISNULL(dblUSD, 0) - ISNULL(dblBasis, 0)
	FROM (
		SELECT dblQty = @dblQty
			, dblUSD = (SUM(dblUSD) + ISNULL(@dblUSD, 0))
			, dblBasis =  (ISNULL(@GrossProfitRate, 0) + ISNULL(@TotalCostRate, 0)) * @FinalAllocatedQty
		FROM @Result
		WHERE strContractType = 'Gross Profit - USD'
	) t

	--
	INSERT INTO @Result (strContractType
		, dblQty
		, dblUSD
		, dblBasis
		, dblPriceVariation)
	SELECT 'Futures Impact - USD'
		, @dblQty
		, dblUSD = SUM((ISNULL(dblLatestSettlementPrice, 0) - ISNULL(dblPrice, 0)) * (ISNULL(dblNoOfLots, 0) * ISNULL(dblContractSize, 0))
					/ CASE WHEN ysnSubCurrency = 1 THEN 100 ELSE 1 END)
		, dblBasis = SUM((ISNULL(dblLatestSettlementPrice, 0) - ISNULL(dblPrice, 0)) * (ISNULL(dblNoOfLots, 0) * ISNULL(dblContractSize, 0))
					/ CASE WHEN ysnSubCurrency = 1 THEN 100 ELSE 1 END)
		, dblInvoicePrice = SUM((ISNULL(dblLatestSettlementPrice, 0) - ISNULL(dblPrice, 0)) * (ISNULL(dblNoOfLots, 0) * ISNULL(dblContractSize, 0))
					/ CASE WHEN ysnSubCurrency = 1 THEN 100 ELSE 1 END)
	FROM (
	SELECT DISTINCT * FROM (
			SELECT DISTINCT TP.strContractType
				, strContractNumber = CH.strContractNumber + ' - ' + CONVERT(NVARCHAR(100), CD.intContractSeq)
				, CD.intContractHeaderId
				, CD.dblQuantity
				, AD.dblSAllocatedQty
				, dblContractPercentage = (AD.dblSAllocatedQty / CD.dblQuantity) * 100
				, strFutureMonth = fm.strFutureMonth + ' - ' + strBuySell
				, strInternalTradeNo
				, dblAssignedLots = (ISNULL(cs.dblAssignedLots, 0) + ISNULL(cs.dblHedgedLots, 0))
				, dblContractPrice = t.dblPrice
				, dblNoOfLots = - ((ISNULL(cs.dblAssignedLots, 0) + ISNULL(cs.dblHedgedLots, 0)) * (AD.dblSAllocatedQty / CD.dblQuantity) * 100) / 100
				, t.dblPrice
				, t.intFutureMarketId
				, t.intFutureMonthId
				, dblLatestSettlementPrice = dbo.fnRKGetLatestClosingPrice(t.intFutureMarketId, t.intFutureMonthId, @dtmToDate)
				, m.dblContractSize
				, intFutOptTransactionHeaderId
				, c.ysnSubCurrency
			FROM tblLGAllocationDetail AD
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = AD.intPContractDetailId AND intSContractDetailId = @intSContractDetailId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
			LEFT JOIN tblCTPriceFixation PF ON PF.intContractDetailId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN PF.intContractDetailId
																			ELSE CD.intContractDetailId	END	AND PF.intContractHeaderId = CD.intContractHeaderId
			LEFT JOIN tblRKAssignFuturesToContractSummary cs ON cs.intContractDetailId = CD.intContractDetailId
			LEFT JOIN tblRKFutOptTransaction t ON t.intFutOptTransactionId = cs.intFutOptTransactionId
			LEFT JOIN tblRKFutureMarket m ON m.intFutureMarketId = t.intFutureMarketId
			LEFT JOIN tblSMCurrency c ON c.intCurrencyID = m.intCurrencyId
			LEFT JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = t.intFutureMonthId
			WHERE intSContractDetailId = @intSContractDetailId
		
			UNION ALL 
			SELECT DISTINCT TP.strContractType
				, strContractNumber = CH.strContractNumber +' - ' + CONVERT(NVARCHAR(100),CD.intContractSeq)
				, CD.intContractHeaderId
				, CD.dblQuantity
				, dblSAllocatedQty = SUM(dblSAllocatedQty) OVER (PARTITION BY CD.intContractDetailId)
				, dblContractPercentage = (SUM(dblSAllocatedQty) OVER (PARTITION BY CD.intContractDetailId) / CD.dblQuantity) * 100
				, strFutureMonth = fm.strFutureMonth + ' - ' + strBuySell
				, strInternalTradeNo
				, dblAssignedLots = (ISNULL(cs.dblAssignedLots, 0) + ISNULL(cs.dblHedgedLots, 0))
				, dblContractPrice = t.dblPrice
				, dblNoOfLots = ((ISNULL(cs.dblAssignedLots, 0) + ISNULL(cs.dblHedgedLots, 0)) * (SUM(dblSAllocatedQty) OVER (PARTITION BY CD.intContractDetailId, t.intFutOptTransactionId) / CD.dblQuantity * 100)) / 100
				, t.dblPrice
				, t.intFutureMarketId
				, t.intFutureMonthId
				, dblLatestSettlementPrice = dbo.fnRKGetLatestClosingPrice(t.intFutureMarketId, t.intFutureMonthId, @dtmToDate)
				, m.dblContractSize
				, intFutOptTransactionHeaderId
				, c.ysnSubCurrency
			FROM tblLGAllocationDetail AD
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = @intSContractDetailId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
			LEFT JOIN tblCTPriceFixation PF ON PF.intContractDetailId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN PF.intContractDetailId
																			ELSE CD.intContractDetailId	END	AND PF.intContractHeaderId = CD.intContractHeaderId
			LEFT JOIN tblRKAssignFuturesToContractSummary cs ON cs.intContractDetailId = CD.intContractDetailId
			LEFT JOIN tblRKFutOptTransaction t ON t.intFutOptTransactionId = cs.intFutOptTransactionId
			LEFT JOIN tblRKFutureMarket m ON m.intFutureMarketId = t.intFutureMarketId
			LEFT JOIN tblSMCurrency c ON c.intCurrencyID = m.intCurrencyId
			LEFT JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = t.intFutureMonthId
			WHERE intSContractDetailId = @intSContractDetailId
		
			UNION ALL SELECT DISTINCT TP.strContractType
				, strContractNumber = CH.strContractNumber +' - ' + CONVERT(NVARCHAR(100),CD.intContractSeq)
				, CD.intContractHeaderId
				, CD.dblQuantity
				, dblSAllocatedQty = SUM(LD.dblQuantity) OVER (PARTITION BY CD.intContractDetailId)
				, dblContractPercentage = (SUM(LD.dblQuantity) OVER (PARTITION BY CD.intContractDetailId) / CD.dblQuantity) * 100
				, strFutureMonth = fm.strFutureMonth + ' - ' + strBuySell
				, strInternalTradeNo
				, dblAssignedLots = (ISNULL(cs.dblAssignedLots, 0) + ISNULL(cs.dblHedgedLots, 0))
				, dblContractPrice = t.dblPrice
				, dblNoOfLots = ((ISNULL(cs.dblAssignedLots, 0) + ISNULL(cs.dblHedgedLots, 0)) * (SUM(LD.dblQuantity) OVER (PARTITION BY CD.intContractDetailId, t.intFutOptTransactionId) / CD.dblQuantity * 100)) / 100
				, t.dblPrice
				, t.intFutureMarketId
				, t.intFutureMonthId
				, dblLatestSettlementPrice = dbo.fnRKGetLatestClosingPrice(t.intFutureMarketId, t.intFutureMonthId, @dtmToDate)
				, m.dblContractSize
				, intFutOptTransactionHeaderId
				, c.ysnSubCurrency
			FROM tblLGLoad AD
			JOIN tblLGLoadDetail LD ON AD.intLoadId = LD.intLoadId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId AND CD.intContractDetailId = @intSContractDetailId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
			LEFT JOIN tblCTPriceFixation PF ON PF.intContractDetailId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN PF.intContractDetailId
																			ELSE CD.intContractDetailId	END	AND PF.intContractHeaderId = CD.intContractHeaderId
			LEFT JOIN tblRKAssignFuturesToContractSummary cs ON cs.intContractDetailId = CD.intContractDetailId
			LEFT JOIN tblRKFutOptTransaction t ON t.intFutOptTransactionId = cs.intFutOptTransactionId
			LEFT JOIN tblRKFutureMarket m ON m.intFutureMarketId = t.intFutureMarketId
			LEFT JOIN tblSMCurrency c ON c.intCurrencyID = m.intCurrencyId
			LEFT JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = t.intFutureMonthId
			WHERE intSContractDetailId = @intSContractDetailId
			AND AD.intShipmentType = 1
		
			UNION ALL SELECT DISTINCT TP.strContractType
				, strContractNumber = CH.strContractNumber + ' - ' + CONVERT(NVARCHAR(100),CD.intContractSeq)
				, CD.intContractHeaderId
				, CD.dblQuantity
				, dblSAllocatedQty = SUM(LD.dblQuantity) OVER (PARTITION BY CD.intContractDetailId)
				, dblContractPercentage = (SUM(LD.dblQuantity) OVER (PARTITION BY CD.intContractDetailId) / CD.dblQuantity) * 100
				, strFutureMonth = fm.strFutureMonth + ' - ' + strBuySell
				, strInternalTradeNo
				, dblAssignedLots = (ISNULL(cs.dblAssignedLots, 0) + ISNULL(cs.dblHedgedLots, 0))
				, dblContractPrice = t.dblPrice
				, dblNoOfLots = - ((ISNULL(cs.dblAssignedLots, 0) + ISNULL(cs.dblHedgedLots, 0)) * (SUM(LD.dblQuantity) OVER (PARTITION BY CD.intContractDetailId, t.intFutOptTransactionId) / CD.dblQuantity * 100)) / 100
				, t.dblPrice
				, t.intFutureMarketId
				, t.intFutureMonthId
				, dblLatestSettlementPrice = dbo.fnRKGetLatestClosingPrice(t.intFutureMarketId, t.intFutureMonthId, @dtmToDate)
				, m.dblContractSize
				, intFutOptTransactionHeaderId
				, c.ysnSubCurrency
			FROM tblLGLoad AD
			JOIN tblLGLoadDetail LD ON AD.intLoadId = LD.intLoadId
			JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
			JOIN tblICInventoryReceiptItemLot IL ON IL.intLotId = LDL.intLotId
			JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = IL.intInventoryReceiptItemId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = RI.intLineNo
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
			LEFT JOIN tblCTPriceFixation PF ON PF.intContractDetailId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN PF.intContractDetailId
																			ELSE CD.intContractDetailId	END	AND PF.intContractHeaderId = CD.intContractHeaderId
			LEFT JOIN tblRKAssignFuturesToContractSummary cs ON cs.intContractDetailId = CD.intContractDetailId
			LEFT JOIN tblRKFutOptTransaction t ON t.intFutOptTransactionId = cs.intFutOptTransactionId
			LEFT JOIN tblRKFutureMarket m ON m.intFutureMarketId = t.intFutureMarketId
			LEFT JOIN tblSMCurrency c ON c.intCurrencyID = m.intCurrencyId
			LEFT JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = t.intFutureMonthId																					
			WHERE intSContractDetailId = @intSContractDetailId
		) t
	) t

	DECLARE @dblFutureImpact NUMERIC(18, 6)
	SELECT @dblBasis = ISNULL(dblBasis, 0) FROM @Result WHERE strContractType = 'Physical Profit - Rate'
	SELECT @dblFutureImpact = ISNULL(dblBasis, 0) FROM @Result WHERE strContractType = 'Futures Impact - USD'
	SELECT @FinalAllocatedQty = ISNULL(SUM(dblAllocatedQty), 0) FROM @Result WHERE strContractType ='PO Costs'

	---- Profit
	INSERT INTO @Result (strContractType	
		, dblBasis
		, dblAllocatedQty
		, strUnitMeasure
		, dblInvoicePrice
		, dblPriceVariation
		, strUOMVariation)
	SELECT 'Net SO Profit - Rate'
		, @dblBasis
		, NULL
		, @strUnitMeasure
		, (dblUSD / @FinalAllocatedQty) * CASE WHEN @ysnSubCurrency = 1 THEN 100 ELSE 1 END	
		, ISNULL((dblUSD / @FinalAllocatedQty) * CASE WHEN @ysnSubCurrency = 1 THEN 100 ELSE 1 END, 0) - ISNULL(@dblBasis, 0)
		, @strUnitMeasure
	FROM @Result
	WHERE strContractType = 'Net SO Profit - USD'

	INSERT INTO @Result (strContractType
		, dblBasis
		, dblQty
		, dblUSD
		, dblInvoicePrice
		, dblPriceVariation)
	SELECT *
		, dblUSD / CASE WHEN ISNULL(dblQty, 0) = 0 THEN 1 ELSE dblQty END
		, ISNULL(dblBasis, 0) + ISNULL(dblUSD, 0)
	FROM (
		SELECT DISTINCT strContractType = 'Net SO Profit - USD'
			, dblBasis = ISNULL(dblBasis, 0) + @dblFutureImpact
			, dblQty = @dblQty
			, dblUSD = ISNULL(dblUSD, 0) + ISNULL((select SUM(dblUSD) FROM @Result WHERE strContractType='Futures Impact - USD'), 0)
		FROM @Result
		WHERE strContractType = 'Physical Profit - USD'
	) t

	SELECT *
	FROM @Result
	ORDER BY intResultId
END