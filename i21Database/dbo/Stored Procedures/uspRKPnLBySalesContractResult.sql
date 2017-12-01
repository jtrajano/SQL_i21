﻿CREATE PROCEDURE uspRKPnLBySalesContractResult
		@intUOMId int = null,
		@intPriceUOMId int = null,
		@intContractDetailId int = null
AS

DECLARE @ysnSubCurrency BIT
DECLARE @strQuantityUnitMeasure nvarchar(50) 
DECLARE @strPriceUOM nvarchar(50)
DECLARE @strUnitMeasure nvarchar(200)=''

SELECT @ysnSubCurrency = isnull(ysnSubCurrency, 0) FROM tblSMCurrency WHERE intCurrencyID = @intUOMId
SELECT @strQuantityUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId = @intPriceUOMId
SELECT @strPriceUOM=strDescription from tblSMCurrency where intCurrencyID=@intUOMId

SET @strUnitMeasure = @strPriceUOM + ' Per ' + @strQuantityUnitMeasure

DECLARE @Result TABLE (
	intResultId INT IDENTITY(1, 1) PRIMARY KEY
	,intContractHeaderId INT
	,intContractDetailId INT
	,strContractNumber NVARCHAR(50)
	,strContractType NVARCHAR(50)
	,dblQty NUMERIC(18, 6)
	,dblUSD NUMERIC(18, 6)
	,dblBasis NUMERIC(18, 6)
	,dblAllocatedQty NUMERIC(18, 6)
	,dblInvoicePrice NUMERIC(18, 6)
	,dblBasisUSD NUMERIC(18, 6)
	,dblAllocatedQtyUSD NUMERIC(18, 6)
	,dblCostUSD NUMERIC(18, 6)
	,strUnitMeasure nvarchar(200)
	,dblPriceVariation NUMERIC(18, 6)
	,strUOMVariation  NVARCHAR(100)

	)
DECLARE @PhysicalFuturesResult TABLE (
	intRowNum INT
	,strContractType NVARCHAR(50)
	,strNumber NVARCHAR(50)
	,strDescription NVARCHAR(50)
	,strConfirmed NVARCHAR(50)
	,dblAllocatedQty NUMERIC(18, 6)
	,dblPrice NUMERIC(18, 6)
	,strCurrency NVARCHAR(50)
	,dblFX NUMERIC(18, 6)
	,dblBooked NUMERIC(18, 6)
	,dblAccounting NUMERIC(18, 6)
	,dtmDate DATETIME
	,strType Nvarchar(100)
	,dblTranValue NUMERIC(18, 6)
	,intSort INT
	,dblTransactionValue NUMERIC(18, 6)
	,dblForecast NUMERIC(18, 6)
	,dblBasisUSD NUMERIC(18, 6)
	,dblCostUSD NUMERIC(18, 6)
	,strUnitMeasure nvarchar(200)
	)

INSERT INTO @PhysicalFuturesResult (
	intRowNum
	,strContractType
	,strNumber
	,strDescription
	,strConfirmed
	,dblAllocatedQty
	,dblPrice
	,strCurrency
	,dblFX
	,dblBooked
	,dblAccounting
	,dtmDate
	,strType
	,dblTranValue
	,intSort
	,dblTransactionValue
	,dblForecast

	)
EXEC uspRKPNLPhysicalFuturesResult @intContractDetailId
	,@intPriceUOMId

DECLARE @dblAllocatedQty NUMERIC(18, 6)
DECLARE @dblAllocatedQtyUSD NUMERIC(18, 6)
DECLARE @dtmToDate DATETIME
DECLARE @dblPricePurchase  numeric(18,6)
DECLARE @dblConvertedAllocatedQty  numeric(18,6)
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)

SELECT @dblPricePurchase= sum(dblPrice*dblAllocatedQty)/sum(dblAllocatedQty) FROM @PhysicalFuturesResult WHERE strContractType like 'Purchase -%'

SELECT @dblAllocatedQty = sum(isnull(sa.dblAllocatedQty, 0))
	  ,@dblAllocatedQtyUSD = sum(dbo.fnCTConvertQuantityToTargetItemUOM(sa.intItemId, intUnitMeasureId, 3, sa.dblAllocatedQty))	  
FROM vyuRKPnLGetAllocationDetail sa
JOIN tblICItemUOM u ON u.intItemUOMId = sa.intPItemUOMId
WHERE sa.intContractTypeId = 2 AND sa.intContractDetailId = @intContractDetailId

---------Invoice
INSERT INTO @Result (
	intContractHeaderId
	,intContractDetailId
	,strContractNumber
	,strContractType
	,dblQty
	,dblUSD
	,dblBasis
	,dblAllocatedQty
	,dblInvoicePrice
	,dblBasisUSD
	,strUnitMeasure
	)
SELECT DISTINCT intContractHeaderId
	,intContractDetailId
	,strSequenceNumber
	,'Invoices'
	,(SELECT ISNULL(SUM(dblBooked), 0) FROM @PhysicalFuturesResult	WHERE strDescription = 'Invoice') dblQty
	,(SELECT ISNULL(SUM(dblAccounting), 0) FROM @PhysicalFuturesResult WHERE strDescription = 'Invoice')  dblUSD
	,(sum(dbo.fnCTConvertQuantityToTargetItemUOM(d.intItemId, @intPriceUOMId, intPriceUomId, dblSaleBasis)) / count(dblSaleBasis)) / CASE WHEN isnull(ysnSubCurrency, 0) = @ysnSubCurrency THEN 1 WHEN isnull(ysnSubCurrency, 0) = 1 THEN 100 ELSE 0.01 END dblBasis
	,NULL dblAllocatedQty
	,(SELECT ISNULL(SUM(dblPrice), 0) FROM @PhysicalFuturesResult WHERE strDescription = 'Invoice') 
		/(	SELECT CASE WHEN count(isnull(dblPrice, 0)) = 0 THEN 1 ELSE count(dblPrice) END	FROM @PhysicalFuturesResult	WHERE strDescription = 'Invoice')
	,(sum(dbo.fnCTConvertQuantityToTargetItemUOM(d.intItemId, 3, intPriceUomId, dblSaleBasis)) / count(dblSaleBasis)) / CASE WHEN isnull(ysnSubCurrency, 0) = 1 THEN 100 ELSE 1 END dblBasisUSD
	,@strUnitMeasure
FROM vyuRKPnLGetAllocationDetail d
JOIN tblICItemUOM u ON u.intItemUOMId = d.intPItemUOMId
WHERE intContractTypeId = 2 AND intContractDetailId = @intContractDetailId
GROUP BY intContractHeaderId	,intContractDetailId	,strSequenceNumber	,ysnSubCurrency

---- Purchase
INSERT INTO @Result (
	intContractHeaderId
	,intContractDetailId
	,strContractNumber
	,strContractType
	,dblQty
	,dblUSD
	,dblBasis
	,dblAllocatedQty
	,dblInvoicePrice
	,dblBasisUSD
	,strUnitMeasure
	)
select intContractHeaderId,intContractDetailId,strSequenceNumber,
strContractType,dblQty,dblUSD,dblBasis,dblAllocatedQty,
case when dblUSD =0 then 0 else dblInvoicePrice end dblInvoicePrice,dblBasisUSD,strUnitMeasure
 from (
SELECT DISTINCT intContractHeaderId
	,intContractDetailId
	,strSequenceNumber
	,'Purchase' strContractType
,(SELECT ISNULL(SUM(dblBooked), 0)	FROM @PhysicalFuturesResult	WHERE strDescription = 'Invoice') dblQty
		,(SELECT ISNULL(SUM(dblAccounting), 0)		FROM @PhysicalFuturesResult		WHERE strDescription = 'Supp. Invoice')  dblUSD
	,(sum(dbo.fnCTConvertQuantityToTargetItemUOM(d.intItemId, @intPriceUOMId, intPriceUomId, dblAllocatedQty * dblBasis)) / sum(dblAllocatedQty)) / CASE WHEN isnull(ysnSubCurrency, 0) = @ysnSubCurrency THEN 1 WHEN isnull(ysnSubCurrency, 0) = 1 THEN 100 ELSE 0.01 END dblBasis
	,@dblAllocatedQty dblAllocatedQty
	,@dblPricePurchase dblInvoicePrice
	,(sum(dbo.fnCTConvertQuantityToTargetItemUOM(d.intItemId, 3, intPriceUomId, dblAllocatedQty * dblBasis)) / sum(dblAllocatedQty)) / CASE WHEN isnull(ysnSubCurrency, 0) = 1 THEN 100 ELSE 1 END as dblBasisUSD
	,@strUnitMeasure strUnitMeasure
FROM vyuRKPnLGetAllocationDetail d
WHERE intContractTypeId = 2 AND intContractDetailId = @intContractDetailId
GROUP BY intContractHeaderId
	,intContractDetailId
	,strSequenceNumber
	,ysnSubCurrency)t


DECLARE @dblSaleBasis NUMERIC(18, 6)
DECLARE @dblPurchaseBasis NUMERIC(18, 6)
DECLARE @dblSaleBasisUSD NUMERIC(18, 6)
DECLARE @dblPurchaseBasisUSD NUMERIC(18, 6)
DECLARE @dblQty numeric(18,6)
DECLARE @dblUSDPurchase  numeric(18,6)
DECLARE @dblUSDInvoice  numeric(18,6)
DECLARE @dblInvoicePrice  numeric(18,6)
DECLARE @dblPurchasePrice  numeric(18,6)
DECLARE @POCostUSD numeric(18,6)
DECLARE @SOCostUSD numeric(18,6)

SELECT @dblSaleBasisUSD = sum(dblBasisUSD) ,@dblSaleBasis = sum(dblBasis),@dblQty=sum(dblQty),@dblUSDPurchase=sum(dblUSD),
		@dblUSDInvoice=sum(dblUSD),@dblInvoicePrice=sum(dblInvoicePrice)
FROM @Result
WHERE strContractType = 'Invoices'

SELECT @dblPurchaseBasisUSD = sum(dblBasisUSD),@dblPurchaseBasis = sum(dblBasis),@dblPurchasePrice=sum(dblInvoicePrice),@dblUSDPurchase=sum(dblUSD)
FROM @Result
WHERE strContractType = 'Purchase'

SELECT @dblPurchaseBasisUSD = sum(dblBasisUSD),@dblPurchaseBasis = sum(dblBasis),@dblPurchasePrice=sum(dblInvoicePrice),@dblUSDPurchase=sum(dblUSD)
FROM @Result
WHERE strContractType = 'Purchase'

SELECT @POCostUSD = sum(dblAccounting) FROM @PhysicalFuturesResult WHERE strDescription like  'Purchase -%'
SELECT @SOCostUSD = sum(dblAccounting) FROM @PhysicalFuturesResult WHERE strDescription like  'Sale -%'

--RESULT
INSERT INTO @Result (strContractType,dblQty	,dblUSD	,dblBasis,dblPriceVariation)
	
SELECT DISTINCT 'Gross Profit - USD',@dblQty,(@dblUSDInvoice-@dblUSDPurchase)
	,(@dblSaleBasisUSD - @dblPurchaseBasisUSD) * @dblAllocatedQtyUSD,
	((@dblUSDInvoice-@dblUSDPurchase) - ((@dblSaleBasisUSD - @dblPurchaseBasisUSD) * @dblAllocatedQtyUSD))
FROM @Result

INSERT INTO @Result (strContractType,dblBasis,strUnitMeasure,dblInvoicePrice,dblPriceVariation,strUOMVariation)
SELECT DISTINCT 'Gross Profit - Rate'
	,(@dblSaleBasis - @dblPurchaseBasis),
	 @strUnitMeasure,
	(@dblInvoicePrice-@dblPurchasePrice),
	((@dblInvoicePrice-@dblPurchasePrice)-(@dblSaleBasis - @dblPurchaseBasis)) ,@strUnitMeasure
FROM @Result

INSERT INTO @Result (
	strContractType
	,dblBasis
	,dblUSD
	,dblInvoicePrice
	,dblCostUSD
	,strUnitMeasure
	,dblAllocatedQty
	)
SELECT 'PO Costs'
	,sum(dblBasis * AllocatedQty) / sum(AllocatedQty) dblBasis
	,@POCostUSD
	,(@POCostUSD/sum(AllocatedQty)) * case when @ysnSubCurrency = 1 then 100 else 1 end
	,sum(dblPOCostUSD * AllocatedQty)/ sum(AllocatedQty) dblCostUSD
	,@strUnitMeasure,sum(AllocatedQty) AllocatedQty
FROM (
	SELECT DISTINCT dbo.fnCTConvertQuantityToTargetItemUOM(dv.intItemId, u.intUnitMeasureId, @intPriceUOMId, dv.dblAllocatedQty) AllocatedQty
		,(
			SELECT dbo.fnCTConvertQuantityToTargetItemUOM(dv.intItemId, @intPriceUOMId, intPriceUomId, dblCosts)				
			FROM (
				SELECT sum(dblRate) dblCosts
				FROM vyuCTContractCostView dc
				WHERE dc.intContractDetailId = dv.intPContractDetailId
				) t
			) / CASE WHEN isnull(ysnSubCurrency, 0) = @ysnSubCurrency THEN 1 WHEN isnull(ysnSubCurrency, 0) = 1 THEN 100 ELSE 0.01 END AS dblBasis
		,(
			SELECT dbo.fnCTConvertQuantityToTargetItemUOM(dv.intItemId, 3, intPriceUomId, dblCosts)				
			FROM (
				SELECT sum(dblRate) dblCosts
				FROM vyuCTContractCostView dc
				WHERE dc.intContractDetailId = dv.intPContractDetailId
				) t
			) / CASE WHEN isnull(ysnSubCurrency, 0) = 1 THEN 100 ELSE 1 END AS dblPOCostUSD
	FROM vyuRKPnLGetAllocationDetail dv
	JOIN tblICItemUOM u ON u.intItemUOMId = dv.intPItemUOMId
	WHERE intContractTypeId = 2 AND dv.intContractDetailId = @intContractDetailId
	) t

INSERT INTO @Result (
	strContractType
	,dblBasis
	,dblUSD
	,dblInvoicePrice
	,dblCostUSD
	,strUnitMeasure
	,dblAllocatedQty
	)

SELECT 'SO Costs'
	,sum(dblBasis * AllocatedQty) / sum(AllocatedQty) dblBasis
	,@SOCostUSD
	,(@SOCostUSD/sum(AllocatedQty)) * case when @ysnSubCurrency = 1 then 100 else 1 end
	,sum(dblSOCostUSD * AllocatedQty) / sum(AllocatedQty) dblCostUSD
	,@strUnitMeasure
	,sum(AllocatedQty)AllocatedQty
FROM (
	SELECT DISTINCT dbo.fnCTConvertQuantityToTargetItemUOM(dv.intItemId, u.intUnitMeasureId, @intPriceUOMId, dv.dblAllocatedQty) AllocatedQty
		,(
			SELECT dbo.fnCTConvertQuantityToTargetItemUOM(dv.intItemId, @intPriceUOMId, intPriceUomId, dblCosts)
			FROM (
				SELECT sum(dblRate) dblCosts
				FROM vyuCTContractCostView dc
				WHERE dc.intContractDetailId = dv.intContractDetailId
				) t
			) / CASE WHEN isnull(ysnSubCurrency, 0) = @ysnSubCurrency THEN 1 WHEN isnull(ysnSubCurrency, 0) = 1 THEN 100 ELSE 0.01 END AS dblBasis
		,(
			SELECT dbo.fnCTConvertQuantityToTargetItemUOM(dv.intItemId, 3, intPriceUomId, dblCosts)
			FROM (
				SELECT sum(dblRate) dblCosts
				FROM vyuCTContractCostView dc
				WHERE dc.intContractDetailId = dv.intContractDetailId
				) t
			) /  CASE WHEN isnull(ysnSubCurrency, 0) = 1 THEN 100 ELSE 1 END  AS dblSOCostUSD
	FROM vyuRKPnLGetAllocationDetail dv
	JOIN tblICItemUOM u ON u.intItemUOMId = dv.intPItemUOMId
	WHERE intContractTypeId = 2 AND dv.intContractDetailId = @intContractDetailId
	) t

----Rate
INSERT INTO @Result(strContractType,dblQty,dblUSD,dblBasis,dblPriceVariation)
SELECT 'Total Costs USD',@dblQty,@POCostUSD+@SOCostUSD,sum(dblCostUSD)*@dblAllocatedQtyUSD,sum(dblCostUSD)*@dblAllocatedQtyUSD FROM @Result
WHERE strContractType IN ('PO Costs', 'SO Costs')

INSERT INTO @Result (strContractType,dblBasis,dblInvoicePrice,strUnitMeasure,dblPriceVariation,strUOMVariation)
SELECT 'Total Costs - Rate'
	,sum(dblBasis)

	,((@POCostUSD+@SOCostUSD)/(select sum(dblAllocatedQty) from @Result where strContractType ='PO Costs'))* case when @ysnSubCurrency = 1 then 100 else 1 end
	,@strUnitMeasure
	,sum(dblBasis)
	,@strUnitMeasure
FROM @Result
WHERE strContractType IN ('PO Costs', 'SO Costs')

---- Profit
INSERT INTO @Result (
	strContractType
	,dblQty
	,dblUSD
	,dblBasis
	,dblPriceVariation
	)
select 'Physical Profit - USD',dblQty,dblUSD,dblBasis,isnull(dblUSD,0)-isnull(dblBasis,0) from (
SELECT @dblQty dblQty
	,(
		sum(dblUSD) 
		- ISNULL((
				SELECT SUM(dblUSD)
				FROM @Result
				WHERE strContractType = 'Total Costs USD'
				), 0)
		) dblUSD
		,sum(dblBasis)-(select sum(dblBasis) FROM @Result WHERE strContractType ='Total Costs USD') dblBasis
FROM @Result
WHERE strContractType = 'Gross Profit - USD')t


INSERT INTO @Result (
	strContractType
	,dblBasis
	,strUnitMeasure
	,dblInvoicePrice,
	dblPriceVariation,
	strUOMVariation
	)
	select 'Physical Profit - Rate',dblBasis,strUnitMeasure,dblInvoicePrice,dblInvoicePrice-dblBasis,strUnitMeasure from (
SELECT 
	isnull((select sum(dblBasis) from @Result where strContractType ='Gross Profit - Rate'),0) - 
	 isnull((select sum(dblBasis) from @Result where strContractType ='Total Costs - Rate'),0) dblBasis
		,@strUnitMeasure strUnitMeasure
		,(sum(dblUSD)
				/(select sum(dblAllocatedQty) from @Result where strContractType ='PO Costs'))* case when @ysnSubCurrency = 1 then 100 else 1 end dblInvoicePrice
FROM @Result
WHERE strContractType = 'Physical Profit - USD')t

--
INSERT INTO @Result (
	strContractType
	,dblQty
	,dblUSD
	,dblPriceVariation
	)
SELECT 'Futures Impact - USD',@dblQty
	,sum((isnull(dtmLatestSettlementPrice, 0) - isnull(dblPrice, 0)) * (isnull(intNoOfLots, 0) * isnull(dblContractSize, 0))
	/case when ysnSubCurrency=1 then 100 else 1 end) dblUSD
	,sum((isnull(dtmLatestSettlementPrice, 0) - isnull(dblPrice, 0)) * (isnull(intNoOfLots, 0) * isnull(dblContractSize, 0))
	/case when ysnSubCurrency=1 then 100 else 1 end) dblInvoicePrice
FROM (
	SELECT DISTINCT TP.strContractType
		,CH.strContractNumber + ' - ' + convert(NVARCHAR(100), CD.intContractSeq) AS strNumber
		,CD.intContractDetailId
		,CD.dblQuantity
		,AD.dblSAllocatedQty
		,(AD.dblSAllocatedQty / CD.dblQuantity) * 100 AS dblContractPercentage
		,fm.strFutureMonth + ' - ' + strBuySell strFutureMonth
		,strInternalTradeNo
		,dblAssignedLots
		,t.dblPrice dblContractPrice
		,((isnull(cs.dblAssignedLots, 0) + isnull(cs.intHedgedLots, 0)) * (AD.dblSAllocatedQty / CD.dblQuantity) * 100) / 100 intNoOfLots
		,t.dblPrice
		,t.intFutureMarketId
		,t.intFutureMonthId
		,dbo.fnRKGetLatestClosingPrice(t.intFutureMarketId, t.intFutureMonthId, @dtmToDate) dtmLatestSettlementPrice
		,m.dblContractSize
		,isnull(ysnSubCurrency,0) ysnSubCurrency
	FROM tblLGAllocationDetail AD
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = AD.intPContractDetailId AND intSContractDetailId = @intContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
	LEFT JOIN tblCTPriceFixation PF ON PF.intContractDetailId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN PF.intContractDetailId ELSE CD.intContractDetailId END AND PF.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblRKAssignFuturesToContractSummary cs ON cs.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblRKFutOptTransaction t ON t.intFutOptTransactionId = cs.intFutOptTransactionId
	LEFT JOIN tblRKFutureMarket m ON m.intFutureMarketId = t.intFutureMarketId
	LEFT JOIN tblSMCurrency c on c.intCurrencyID=m.intCurrencyId
	LEFT JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = t.intFutureMonthId
	WHERE intSContractDetailId = @intContractDetailId
	
	UNION ALL
	
	SELECT DISTINCT TP.strContractType
		,CH.strContractNumber + ' - ' + convert(NVARCHAR(100), CD.intContractSeq)
		,CD.intContractDetailId
		,CD.dblQuantity
		,sum(dblSAllocatedQty) OVER (PARTITION BY CD.intContractDetailId) dblSAllocatedQty
		,(sum(dblSAllocatedQty) OVER (PARTITION BY CD.intContractDetailId) / CD.dblQuantity) * 100 AS dblContractPercentage
		,fm.strFutureMonth + ' - ' + strBuySell strFutureMonth
		,strInternalTradeNo
		,dblAssignedLots
		,t.dblPrice dblContractPrice
		,((isnull(cs.dblAssignedLots, 0) + isnull(cs.intHedgedLots, 0)) * (sum(dblSAllocatedQty) OVER (PARTITION BY CD.intContractDetailId) / CD.dblQuantity * 100)) / 100 intNoOfLots
		,t.dblPrice
		,t.intFutureMarketId
		,t.intFutureMonthId
		,dbo.fnRKGetLatestClosingPrice(t.intFutureMarketId, t.intFutureMonthId, @dtmToDate) dtmLatestSettlementPrice
		,m.dblContractSize
		,isnull(ysnSubCurrency,0)  ysnSubCurrency
	FROM tblLGAllocationDetail AD
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = @intContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
	LEFT JOIN tblCTPriceFixation PF ON PF.intContractDetailId = CASE WHEN CH.ysnMultiplePriceFixation = 1 THEN PF.intContractDetailId ELSE CD.intContractDetailId END AND PF.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblRKAssignFuturesToContractSummary cs ON cs.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblRKFutOptTransaction t ON t.intFutOptTransactionId = cs.intFutOptTransactionId
	LEFT JOIN tblRKFutureMarket m ON m.intFutureMarketId = t.intFutureMarketId
	LEFT JOIN tblSMCurrency c on c.intCurrencyID=m.intCurrencyId
	LEFT JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = t.intFutureMonthId
	WHERE intSContractDetailId = @intContractDetailId
	) t

INSERT INTO @Result (
	strContractType
	,dblInvoicePrice
	,dblPriceVariation,
	strUOMVariation
	)
SELECT 'Futures Impact - Rate',(sum(dblUSD)/(select sum(dblAllocatedQty) from @Result where strContractType ='PO Costs'))* case when @ysnSubCurrency = 1 then 100 else 1 end,
	(sum(dblUSD)/(select sum(dblAllocatedQty) from @Result where strContractType ='PO Costs'))* case when @ysnSubCurrency = 1 then 100 else 1 end
	,@strUnitMeasure
 from @Result where strContractType= 'Futures Impact - USD'

---- Profit
INSERT INTO @Result (
	strContractType
	,dblBasis
	,dblQty
	,dblUSD
	,dblPriceVariation
	)
SELECT 'Net SO Profit - USD',
    (select isnull(dblBasis, 0) from @Result where strContractType='Physical Profit - USD')
	,@dblQty
	,isnull(dblUSD, 0) + isnull((select sum(dblUSD) from @Result where strContractType='Futures Impact - USD'),0)
	,isnull(dblUSD, 0) + isnull((select sum(dblUSD) from @Result where strContractType='Futures Impact - USD'),0)-
	 (select isnull(dblBasis, 0) from @Result where strContractType='Physical Profit - USD')
FROM @Result
WHERE strContractType = 'Physical Profit - USD'

INSERT INTO @Result (
	strContractType	
	,dblBasis
	,dblAllocatedQty
	,strUnitMeasure
	,dblInvoicePrice
	,dblPriceVariation,
	strUOMVariation
	)
SELECT 'Net SO Profit - Rate'
	,(select isnull(dblBasis, 0) from @Result where strContractType='Physical Profit - Rate')
	,NULL
	,@strUnitMeasure
	,(dblUSD/(select sum(dblAllocatedQty) from @Result where strContractType ='PO Costs'))* case when @ysnSubCurrency = 1 then 100 else 1 end	
	,isnull((dblUSD/(select sum(dblAllocatedQty) from @Result where strContractType ='PO Costs'))* case when @ysnSubCurrency = 1 then 100 else 1 end,0) 
	-isnull((select isnull(dblBasis, 0) from @Result where strContractType='Physical Profit - Rate'),0)
	,@strUnitMeasure
FROM @Result
WHERE strContractType = 'Net SO Profit - USD'

SELECT *
FROM @Result
ORDER BY intResultId
