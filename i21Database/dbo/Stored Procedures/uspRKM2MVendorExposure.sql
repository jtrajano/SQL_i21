﻿CREATE PROC [dbo].[uspRKM2MVendorExposure]  
                  @intM2MBasisId int = null,
                  @intFutureSettlementPriceId int = null,
                  @intQuantityUOMId int = null,
                  @intPriceUOMId int = null,
                  @intCurrencyUOMId int= null,
                  @dtmTransactionDateUpTo datetime= null,
                  @strRateType nvarchar(50)= null,
                  @intCommodityId int=Null,
                  @intLocationId int= null,
                  @intMarketZoneId int= null,
				  @ysnVendorProducer bit = null
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

SELECT cd.*,e.strName as strProducer into #temp FROM @tblFinalDetail cd
JOIN tblCTContractHeader ch on ch.intContractHeaderId=cd.intContractHeaderId
LEFT JOIN tblEMEntity e on e.intEntityId=ch.intProducerId

IF (ISNULL(@ysnVendorProducer,0)=0)
BEGIN

	SELECT convert(int,row_number() OVER(ORDER BY strVendorName)) intRowNum,strVendorName,strRating,
			dblFixedPurchaseVolume,dblUnfixedPurchaseVolume,dblTotalCommittedVolume,dblFixedPurchaseValue,dblUnfixedPurchaseValue,dblTotalCommittedValue,
			CONVERT(NUMERIC(16,2),dblTotalSpend) as dblTotalSpend ,
			CONVERT(NUMERIC(16,2),dblShareWithSupplier) as dblShareWithSupplier ,dblMToM,
			dblTotalCommittedVolume ,ISNULL(dblTotalSpend,0) dblTotalSpend,dblCompanyExposurePercentage,
			(dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend,0) = 0 then 1 else dblTotalSpend end) * dblCompanyExposurePercentage a,
			(dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 then 1 else dblShareWithSupplier end) *dblSupplierSalesPercentage b,
	CASE WHEN 
		(dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend,0) = 0 then 1 else dblTotalSpend end) * dblCompanyExposurePercentage <=
		(dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 then 1 else dblShareWithSupplier end) *dblSupplierSalesPercentage 
	THEN (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend,0) = 0 then 1 else dblTotalSpend end) * dblCompanyExposurePercentage 
	ELSE
		(dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 then 1 else dblShareWithSupplier end) *dblSupplierSalesPercentage 
	end dblPotentialAdditionalVolume,
	0 as intConcurrencyId
	FROM(
	SELECT strEntityName strVendorName,strRiskIndicator strRating,
				dblFixedPurchaseVolume,dblUnfixedPurchaseVolume,dblTotalCommittedVolume,dblFixedPurchaseValue,dblUnfixedPurchaseValue,dblTotalCommittedValue
			 ,(isnull(dblTotalCommittedValue,0)/ SUM(CASE WHEN ISNULL(dblTotalCommittedValue,0)=0 then 1 else dblTotalCommittedValue end) OVER ())*100 as dblTotalSpend
			 , (isnull(dblTotalCommittedVolume,0)/ CASE WHEN ISNULL(dblRiskTotalBusinessVolume,0) =0 then 1 else dblRiskTotalBusinessVolume end)*100 as dblShareWithSupplier
			 ,dblResult as dblMToM,dblCompanyExposurePercentage,dblSupplierSalesPercentage
	FROM (
	SELECT strEntityName,CONVERT(NUMERIC(16,2),dblFixedPurchaseVolume) as dblFixedPurchaseVolume,
						 CONVERT(NUMERIC(16,2),dblUnfixedPurchaseVolume) as dblUnfixedPurchaseVolume,
						 CONVERT(NUMERIC(16,2),(dblFixedPurchaseVolume + dblUnfixedPurchaseVolume)) as dblTotalCommittedVolume,
						 CONVERT(NUMERIC(16,2),dblFixedPurchaseValue) dblFixedPurchaseValue,
						 CONVERT(NUMERIC(16,2),dblUnfixedPurchaseValue) dblUnfixedPurchaseValue,
						 CONVERT(NUMERIC(16,2),(dblFixedPurchaseValue + dblUnfixedPurchaseValue)) as dblTotalCommittedValue,
						 CONVERT(NUMERIC(16,2),(dblResult)) as dblResult
						 ,strRiskIndicator,intRiskUnitOfMeasureId,dblRiskTotalBusinessVolume,dblCompanyExposurePercentage,dblSupplierSalesPercentage		 			 
	FROM (
			SELECT strEntityName,
			SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblOpenQty else 0 end) dblFixedPurchaseVolume,
			SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblOpenQty else 0 end) dblUnfixedPurchaseVolume,
			SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblQtyPrice else 0 end) dblFixedPurchaseValue,
			SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblQtyUnFixedPrice else 0 end) dblUnfixedPurchaseValue,
			sum(dblResult) as dblResult
			,strRiskIndicator,dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,dblCompanyExposurePercentage,dblSupplierSalesPercentage
			FROM (
					SELECT strEntityName,sum(dblOpenQty) as dblOpenQty,sum(dblQtyPrice) dblQtyPrice,sum(dblQtyUnFixedPrice) dblQtyUnFixedPrice,strPriOrNotPriOrParPriced,
					sum(dblResult) dblResult,strRiskIndicator,dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,dblCompanyExposurePercentage,dblSupplierSalesPercentage from(
					SELECT strEntityName,dblOpenQty as dblOpenQty,
							dblOpenQty*(round(isnull(dblContractBasis,0),2)+round(isnull(dblFutures,0),2)) dblQtyPrice,
							dblOpenQty*(round(isnull(dblContractBasis,0),2) + round(isnull(dblFuturePrice,0),2) ) dblQtyUnFixedPrice,
							CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN 'Unpriced' 
							WHEN  ISNULL(strPriOrNotPriOrParPriced,'') = '' THEN 'Priced' ELSE strPriOrNotPriOrParPriced END strPriOrNotPriOrParPriced
							,round(isnull(dblResult,0),2) dblResult,
							strRiskIndicator,round(isnull(dblRiskTotalBusinessVolume,0),2) as dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,
							round(isnull(dblCompanyExposurePercentage,0),2) as dblCompanyExposurePercentage ,round(isnull(dblSupplierSalesPercentage,0),2) as dblSupplierSalesPercentage
					FROM #temp  fd
					LEFT JOIN tblAPVendor e on e.intEntityVendorId=fd.intEntityId
					LEFT JOIN tblRKVendorPriceFixationLimit pf on pf.intVendorPriceFixationLimitId=e.intRiskVendorPriceFixationLimitId
					WHERE strContractOrInventoryType in('Contract(P)','In-transit(P)','Inventory(P)' ) )t
	GROUP BY strEntityName,strPriOrNotPriOrParPriced,strRiskIndicator,dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,dblCompanyExposurePercentage,dblSupplierSalesPercentage)t1
	GROUP BY strEntityName,strRiskIndicator,dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,dblCompanyExposurePercentage,dblSupplierSalesPercentage)t2)t2 
	)t3
END

ELSE

BEGIN

	SELECT convert(int,row_number() OVER(ORDER BY strVendorName)) intRowNum,strVendorName,strRating,
			dblFixedPurchaseVolume,dblUnfixedPurchaseVolume,dblTotalCommittedVolume,dblFixedPurchaseValue,dblUnfixedPurchaseValue,dblTotalCommittedValue,
			CONVERT(NUMERIC(16,2),dblTotalSpend) as dblTotalSpend ,
			CONVERT(NUMERIC(16,2),dblShareWithSupplier) as dblShareWithSupplier ,dblMToM,
			dblTotalCommittedVolume ,ISNULL(dblTotalSpend,0) dblTotalSpend,dblCompanyExposurePercentage,
			(dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend,0) = 0 then 1 else dblTotalSpend end) * dblCompanyExposurePercentage a,
			(dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 then 1 else dblShareWithSupplier end) *dblSupplierSalesPercentage b,
	CASE WHEN 
		(dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend,0) = 0 then 1 else dblTotalSpend end) * dblCompanyExposurePercentage <=
		(dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 then 1 else dblShareWithSupplier end) *dblSupplierSalesPercentage 
	THEN (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend,0) = 0 then 1 else dblTotalSpend end) * dblCompanyExposurePercentage 
	ELSE
		(dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier,0) = 0 then 1 else dblShareWithSupplier end) *dblSupplierSalesPercentage 
	end dblPotentialAdditionalVolume,
	0 as intConcurrencyId
	FROM(
	SELECT strEntityName strVendorName,strRiskIndicator strRating,
				dblFixedPurchaseVolume,dblUnfixedPurchaseVolume,dblTotalCommittedVolume,dblFixedPurchaseValue,dblUnfixedPurchaseValue,dblTotalCommittedValue
			 ,(isnull(dblTotalCommittedValue,0)/ SUM(CASE WHEN ISNULL(dblTotalCommittedValue,0)=0 then 1 else dblTotalCommittedValue end) OVER ())*100 as dblTotalSpend
			 , (isnull(dblTotalCommittedVolume,0)/ CASE WHEN ISNULL(dblRiskTotalBusinessVolume,0) =0 then 1 else dblRiskTotalBusinessVolume end)*100 as dblShareWithSupplier
			 ,dblResult as dblMToM,dblCompanyExposurePercentage,dblSupplierSalesPercentage
	FROM (
	SELECT strEntityName,CONVERT(NUMERIC(16,2),dblFixedPurchaseVolume) as dblFixedPurchaseVolume,
						 CONVERT(NUMERIC(16,2),dblUnfixedPurchaseVolume) as dblUnfixedPurchaseVolume,
						 CONVERT(NUMERIC(16,2),(dblFixedPurchaseVolume + dblUnfixedPurchaseVolume)) as dblTotalCommittedVolume,
						 CONVERT(NUMERIC(16,2),dblFixedPurchaseValue) dblFixedPurchaseValue,
						 CONVERT(NUMERIC(16,2),dblUnfixedPurchaseValue) dblUnfixedPurchaseValue,
						 CONVERT(NUMERIC(16,2),(dblFixedPurchaseValue + dblUnfixedPurchaseValue)) as dblTotalCommittedValue,
						 CONVERT(NUMERIC(16,2),(dblResult)) as dblResult
						 ,strRiskIndicator,intRiskUnitOfMeasureId,dblRiskTotalBusinessVolume,dblCompanyExposurePercentage,dblSupplierSalesPercentage		 			 
	FROM (
			SELECT strEntityName,
			SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblOpenQty else 0 end) dblFixedPurchaseVolume,
			SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblOpenQty else 0 end) dblUnfixedPurchaseVolume,
			SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Priced' then dblQtyPrice else 0 end) dblFixedPurchaseValue,
			SUM(CASE WHEN strPriOrNotPriOrParPriced = 'Unpriced' then dblQtyUnFixedPrice else 0 end) dblUnfixedPurchaseValue,
			sum(dblResult) as dblResult
			,strRiskIndicator,dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,dblCompanyExposurePercentage,dblSupplierSalesPercentage
			FROM (
					SELECT strEntityName,sum(dblOpenQty) as dblOpenQty,sum(dblQtyPrice) dblQtyPrice,sum(dblQtyUnFixedPrice) dblQtyUnFixedPrice,strPriOrNotPriOrParPriced,
					sum(dblResult) dblResult,strRiskIndicator,dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,dblCompanyExposurePercentage,dblSupplierSalesPercentage 
					FROM(
					SELECT isnull(strProducer,strEntityName) strEntityName,dblOpenQty as dblOpenQty,
							dblOpenQty*(round(isnull(dblContractBasis,0),2)+round(isnull(dblFutures,0),2)) dblQtyPrice,
							dblOpenQty*(round(isnull(dblContractBasis,0),2) + round(isnull(dblFuturePrice,0),2) ) dblQtyUnFixedPrice,
							CASE WHEN strPriOrNotPriOrParPriced = 'Partially Priced' THEN 'Unpriced' 
							WHEN  ISNULL(strPriOrNotPriOrParPriced,'') = '' THEN 'Priced' ELSE strPriOrNotPriOrParPriced END strPriOrNotPriOrParPriced
							,round(isnull(dblResult,0),2) dblResult,
							strRiskIndicator,round(isnull(dblRiskTotalBusinessVolume,0),2) as dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,
							round(isnull(dblCompanyExposurePercentage,0),2) as dblCompanyExposurePercentage ,round(isnull(dblSupplierSalesPercentage,0),2) as dblSupplierSalesPercentage
					FROM #temp  fd
					LEFT JOIN tblAPVendor e on e.intEntityVendorId=fd.intEntityId
					LEFT JOIN tblRKVendorPriceFixationLimit pf on pf.intVendorPriceFixationLimitId=e.intRiskVendorPriceFixationLimitId
					WHERE strContractOrInventoryType in('Contract(P)','In-transit(P)','Inventory(P)' ) )t
	GROUP BY strEntityName,strPriOrNotPriOrParPriced,strRiskIndicator,dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,dblCompanyExposurePercentage,dblSupplierSalesPercentage)t1
	GROUP BY strEntityName,strRiskIndicator,dblRiskTotalBusinessVolume,intRiskUnitOfMeasureId,dblCompanyExposurePercentage,dblSupplierSalesPercentage)t2)t2 
	)t3
END