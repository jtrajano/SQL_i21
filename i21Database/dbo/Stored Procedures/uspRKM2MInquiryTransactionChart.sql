CREATE PROC [dbo].[uspRKM2MInquiryTransactionChart]  
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
	,intQuantityUOMId INT
	,intCommodityUnitMeasureId INT
	,intPriceUOMId INT
	,intCent int
	,dtmPlannedAvailabilityDate datetime
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


DECLARE @tblMonthFinal TABLE (
  intRowNum INT identity(1, 1)
 ,strFutureMonth NVARCHAR(500) COLLATE Latin1_General_CI_AS
 ,dblResult DECIMAL(24, 10)
 ,dblResultBasis DECIMAL(24, 10)
 ,dblMarketFuturesResult DECIMAL(24, 10)
 ,dblResultCash DECIMAL(24, 10)
 )
 SET DATEFORMAT dmy

 INSERT INTO @tblMonthFinal (strFutureMonth,dblResult,dblResultBasis,dblMarketFuturesResult,dblResultCash)
	SELECT strFutureMonth,sum(dblResult),sum(dblResultBasis), sum(dblMarketFuturesResult),sum(dblResultCash) from (
		SELECT RIGHT(CONVERT(VARCHAR(10),CONVERT(DATETIME,'01/' +RIGHT(strPeriod,5)),6),6) strFutureMonth,
		dblResult,
		dblResultBasis, 
		dblMarketFuturesResult,
		dblResultCash
		FROM @tblFinalDetail ) t
	GROUP BY strFutureMonth 
	ORDER BY CONVERT(DATETIME,'01 ' +strFutureMonth) ASC
SET DATEFORMAT mdy

SELECT intRowNum,strFutureMonth,dblResult,dblResultBasis,dblMarketFuturesResult,dblResultCash from @tblMonthFinal