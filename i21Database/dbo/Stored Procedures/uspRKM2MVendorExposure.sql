CREATE PROC [dbo].[uspRKM2MVendorExposure]  
                  @intM2MBasisId int = null,
                  @intFutureSettlementPriceId int = null,
                  @intQuantityUOMId int = null,
                  @intPriceUOMId int = null,
                  @intCurrencyUOMId int= null,
                  @dtmTransactionDateUpTo datetime= null,
                  @strRateType nvarchar(50)= null,
                  @intCommodityId int=Null,
                  @intLocationId int= null,
                  @intMarketZoneId int= null
AS

DECLARE @tblFinalDetail TABLE (
	 intRowNum INT
	,intConcurrencyId INT
	,intContractHeaderId INT
	,intContractDetailId INT
	,strContractOrInventoryType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strContractSeq NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strEntityName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intEntityId INT
	,intFutureMarketId INT
	,strFutMarketName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intFutureMonthId INT
	,strFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblOpenQty NUMERIC(24, 10)
	,strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intCommodityId INT
	,intItemId INT
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strOrgin NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strPosition NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strPeriod NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strPriOrNotPriOrParPriced NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intPricingTypeId INT
	,strPricingType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblContractBasis NUMERIC(24, 10)
	,dblFutures NUMERIC(24, 10)
	,dblCash NUMERIC(24, 10)
	,dblCosts NUMERIC(24, 10)
	,dblMarketBasis NUMERIC(24, 10)
	,dblFuturePrice NUMERIC(24, 10)
	,intContractTypeId INT
	,dblAdjustedContractPrice NUMERIC(24, 10)
	,dblCashPrice NUMERIC(24, 10)
	,dblMarketPrice NUMERIC(24, 10)
	,dblResult NUMERIC(24, 10)
	,dblResultBasis NUMERIC(24, 10)
	,dblMarketFuturesResult NUMERIC(24, 10)
	,dblResultCash NUMERIC(24, 10)
	,dblContractPrice NUMERIC(24, 10)
	)

INSERT INTO @tblFinalDetail
EXEC [uspRKM2MInquiryTransaction]   @intM2MBasisId  = @intM2MBasisId,
                  @intFutureSettlementPriceId  = @intFutureSettlementPriceId,
                  @intQuantityUOMId  = @intQuantityUOMId,
                  @intPriceUOMId  = @intPriceUOMId,
                  @intCurrencyUOMId = @intCurrencyUOMId,
                  @dtmTransactionDateUpTo = @dtmTransactionDateUpTo,
                  @strRateType = @strRateType,
                  @intCommodityId =@intCommodityId,
                  @intLocationId = @intLocationId,
                  @intMarketZoneId = @intMarketZoneId

SELECT convert(int,row_number() OVER(ORDER BY strEntityName)) intRowNum,strEntityName strVendorName,20.1 dblRating,dblFixedPurchaseVolume,dblUnfixedPurchaseVolume,dblTotalCommittedVolume,dblFixedPurchaseValue,dblUnfixedPurchaseValue,dblTotalCommittedValue
		 ,convert(numeric(16,6),((isnull(dblTotalCommittedValue,0)/SUM(dblTotalCommittedValue) OVER ())*100),4) as dblTotalSpend
		 , convert(numeric(16,6),((isnull(dblTotalCommittedVolume,0)/ 20 /*hardcoad */ )*100),4) as dblShareWithSupplier
		 ,dblResult as dblMToM, 0.0 as dblPotentialAdditionalVolume,0 as intConcurrencyId
FROM (
SELECT strEntityName,convert(numeric(16,6),dblFixedPurchaseVolume) as dblFixedPurchaseVolume,
					 convert(numeric(16,6),dblUnfixedPurchaseVolume) as dblUnfixedPurchaseVolume,
					 convert(numeric(16,6),(dblFixedPurchaseVolume + dblUnfixedPurchaseVolume)) as dblTotalCommittedVolume,
					 convert(numeric(16,6),dblFixedPurchaseValue) dblFixedPurchaseValue,
					 convert(numeric(16,6),dblUnfixedPurchaseValue) dblUnfixedPurchaseValue,
					 convert(numeric(16,6),(dblFixedPurchaseValue + dblUnfixedPurchaseValue)) as dblTotalCommittedValue,
					 convert(numeric(16,6),(dblResult)) as dblResult
					 
FROM (
		SELECT strEntityName,
		SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblOpenQty else 0 end) dblFixedPurchaseVolume,
		SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblOpenQty else 0 end) dblUnfixedPurchaseVolume,
		SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblQtyPrice else 0 end) dblFixedPurchaseValue,
		SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblQtyUnFixedPrice else 0 end) dblUnfixedPurchaseValue,
		sum(dblResult) as dblResult
		FROM (
				SELECT strEntityName,sum(dblOpenQty) as dblOpenQty,sum(dblQtyPrice) dblQtyPrice,sum(dblQtyUnFixedPrice) dblQtyUnFixedPrice,strPriOrNotPriOrParPriced,sum(dblResult) dblResult from(
				SELECT strEntityName,dblOpenQty as dblOpenQty,
						dblOpenQty*(isnull(dblContractBasis,0)+isnull(dblFutures,0)) dblQtyPrice,
						dblOpenQty*(isnull(dblContractBasis,0)+ isnull(dblMarketBasis,0) + isnull(dblFuturePrice,0) ) dblQtyUnFixedPrice,
						CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN 'Unpriced' 
						WHEN  ISNULL(strPriOrNotPriOrParPriced,'') = '' THEN 'Priced' ELSE strPriOrNotPriOrParPriced END strPriOrNotPriOrParPriced
						,isnull(dblResult,0) dblResult
				FROM @tblFinalDetail  fd
				WHERE strContractOrInventoryType in('Contract(P)','In-transit(P)','Inventory(P)') )t
GROUP BY strEntityName,strPriOrNotPriOrParPriced)t1
GROUP BY strEntityName)t2)t2 