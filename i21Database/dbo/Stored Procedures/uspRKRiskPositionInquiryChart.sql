CREATE PROC [dbo].[uspRKRiskPositionInquiryChart] 
  @intCommodityId INTEGER
 ,@intCompanyLocationId INTEGER
 ,@intFutureMarketId INTEGER
 ,@intFutureMonthId INTEGER
 ,@intUOMId INTEGER
 ,@intDecimal INTEGER,
 @intForecastWeeklyConsumption INTEGER = null,
 @intForecastWeeklyConsumptionUOMId INTEGER = null   
AS

if isnull(@intForecastWeeklyConsumptionUOMId,0)=0
BEGIN
set @intForecastWeeklyConsumption = 1
END
If isnull(@intForecastWeeklyConsumptionUOMId,0) = 0
BEGIN
set @intForecastWeeklyConsumptionUOMId = @intUOMId
END

DECLARE @strRiskView nvarchar(50) 
SELECT @strRiskView = strRiskView FROM tblRKCompanyPreference 

DECLARE @tblFinalDetail TABLE (
 intRowNumber INT
 ,Selection NVARCHAR(500) COLLATE Latin1_General_CI_AS
 ,PriceStatus NVARCHAR(500) COLLATE Latin1_General_CI_AS
 ,strFutureMonth NVARCHAR(500) COLLATE Latin1_General_CI_AS
 ,strAccountNumber NVARCHAR(500) COLLATE Latin1_General_CI_AS
 ,dblNoOfContract DECIMAL(24, 10)
 ,strTradeNo NVARCHAR(500) COLLATE Latin1_General_CI_AS
 ,TransactionDate DATETIME
 ,TranType NVARCHAR(500) COLLATE Latin1_General_CI_AS
 ,CustVendor NVARCHAR(500) COLLATE Latin1_General_CI_AS
 ,dblNoOfLot DECIMAL(24, 10)
 ,dblQuantity DECIMAL(24, 10)
 ,intOrderByHeading INT
 ,intContractHeaderId INT
 ,intFutOptTransactionHeaderId INT
 )

INSERT INTO @tblFinalDetail
EXEC uspRKRiskPositionInquiry @intCommodityId = @intCommodityId
 ,@intCompanyLocationId = @intCompanyLocationId
 ,@intFutureMarketId = @intFutureMarketId
 ,@intFutureMonthId = @intFutureMonthId
 ,@intUOMId = @intUOMId
 ,@intDecimal = @intDecimal
 ,@intForecastWeeklyConsumption=@intForecastWeeklyConsumption
 ,@intForecastWeeklyConsumptionUOMId=@intForecastWeeklyConsumptionUOMId
DECLARE @tblMonthFinal TABLE (
 intRowNum INT identity(1, 1)
 ,strFutureMonth NVARCHAR(500) COLLATE Latin1_General_CI_AS
 ,dblNetMarketRisk DECIMAL(24, 10)
 ,dblPhysicalPosition DECIMAL(24, 10)
 ,Selection NVARCHAR(500) COLLATE Latin1_General_CI_AS
 )

-- Equal previous
INSERT INTO @tblMonthFinal (
 strFutureMonth
 ,dblNetMarketRisk
 ,dblPhysicalPosition
 )
SELECT strFutureMonth
 ,convert(DECIMAL(24, 10), sum(isnull(dblNoOfContract, 0))) dblNoOfContract
 ,NULL
FROM @tblFinalDetail
WHERE Selection =  CASE WHEN @strRiskView='Processor' THEN 'Outright coverage' ELSE 'Net market risk' END
 AND strFutureMonth = 'Previous'
GROUP BY strFutureMonth
 ,Selection

INSERT INTO @tblMonthFinal (
 strFutureMonth
 ,dblNetMarketRisk
 ,dblPhysicalPosition
 )
SELECT strFutureMonth
 ,NULL
 ,convert(DECIMAL(24, 10), sum(isnull(dblNoOfContract, 0))) dblNoOfContract
FROM @tblFinalDetail
WHERE Selection = CASE WHEN @strRiskView='Processor' then 'Physical position / Differential cover' else 'Physical position / Basis risk' end
 AND strFutureMonth = 'Previous'
GROUP BY strFutureMonth
 ,Selection

--Not Equal previous 
INSERT INTO @tblMonthFinal (
 strFutureMonth
 ,dblNetMarketRisk
 ,dblPhysicalPosition
 )
SELECT strFutureMonth
 ,convert(DECIMAL(24, 10), sum(isnull(dblNoOfContract, 0))) dblNoOfContract
 ,NULL
FROM @tblFinalDetail
WHERE Selection =  CASE WHEN @strRiskView='Processor' then 'Physical position / Differential cover' else 'Physical position / Basis risk' end
 AND strFutureMonth <> 'Previous'
GROUP BY strFutureMonth
 ,Selection
ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth) ASC

INSERT INTO @tblMonthFinal (
 strFutureMonth
 ,dblNetMarketRisk
 ,dblPhysicalPosition
 )
SELECT strFutureMonth
 ,NULL
 ,convert(DECIMAL(24, 10), sum(isnull(dblNoOfContract, 0))) dblNoOfContract
FROM @tblFinalDetail
WHERE Selection = 'Physical position / Basis risk'
 AND strFutureMonth <> 'Previous'
GROUP BY strFutureMonth
 ,Selection
ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth) ASC

DECLARE @tblRMMonthFinal TABLE (
 intRowNum INT identity(1, 1)
 ,strFutureMonth NVARCHAR(500) COLLATE Latin1_General_CI_AS
 ,dblNetMarketRisk DECIMAL(24, 10)
 ,dblPhysicalPosition DECIMAL(24, 10)
 ,Selection NVARCHAR(500) COLLATE Latin1_General_CI_AS
 )

INSERT INTO @tblRMMonthFinal (
 strFutureMonth
 ,dblNetMarketRisk
 ,dblPhysicalPosition
 )
SELECT strFutureMonth
 ,SUM(isnull(dblNetMarketRisk, 0))
 ,SUM(isnull(dblPhysicalPosition, 0))
FROM @tblMonthFinal
WHERE strFutureMonth = 'Previous'
GROUP BY strFutureMonth

INSERT INTO @tblRMMonthFinal (
 strFutureMonth
 ,dblNetMarketRisk
 ,dblPhysicalPosition
 )
SELECT strFutureMonth
 ,sum(isnull(dblNetMarketRisk, 0))
 ,sum(isnull(dblPhysicalPosition, 0))
FROM @tblMonthFinal
WHERE strFutureMonth <> 'Previous'
GROUP BY strFutureMonth
ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth)

SELECT *
FROM @tblRMMonthFinal