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

IF ISNULL(@intForecastWeeklyConsumptionUOMId,0) = 0
BEGIN
SET @intForecastWeeklyConsumption = 1
END
IF ISNULL(@intForecastWeeklyConsumptionUOMId,0) = 0
BEGIN
SET @intForecastWeeklyConsumptionUOMId = @intUOMId
END

DECLARE @strRiskView nvarchar(50) 
SELECT @strRiskView = strRiskView FROM tblRKCompanyPreference 

DECLARE @tblFinalDetail TABLE (
		intRowNumber INT
		,strGroup  NVARCHAR(500) COLLATE Latin1_General_CI_AS
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

DECLARE @tblMonthFinal TABLE (
 intRowNum INT identity(1, 1)
 ,strFutureMonth NVARCHAR(500) COLLATE Latin1_General_CI_AS
 ,dblNetMarketRisk DECIMAL(24, 10)
 ,dblPhysicalPosition DECIMAL(24, 10)
 ,Selection NVARCHAR(500) COLLATE Latin1_General_CI_AS
 )

IF @strRiskView <> 'Processor'
BEGIN

		INSERT INTO @tblFinalDetail (intRowNumber,Selection ,PriceStatus ,strFutureMonth ,strAccountNumber ,dblNoOfContract ,strTradeNo ,TransactionDate
										,TranType ,CustVendor ,dblNoOfLot ,dblQuantity ,intOrderByHeading ,intContractHeaderId ,intFutOptTransactionHeaderId)
		EXEC uspRKRiskPositionInquiry @intCommodityId = @intCommodityId
		 ,@intCompanyLocationId = @intCompanyLocationId
		 ,@intFutureMarketId = @intFutureMarketId
		 ,@intFutureMonthId = @intFutureMonthId
		 ,@intUOMId = @intUOMId
		 ,@intDecimal = @intDecimal
		 ,@intForecastWeeklyConsumption=@intForecastWeeklyConsumption
		 ,@intForecastWeeklyConsumptionUOMId=@intForecastWeeklyConsumptionUOMId

	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutureMonth ASC)) intRowNum,
		(select SUM(dblNoOfContract) FROM @tblFinalDetail t1 WHERE t1.Selection = 'Physical position / Basis risk' and t1.strFutureMonth= t.strFutureMonth) dblPhysicalPosition,
		(select SUM(dblNoOfContract) FROM @tblFinalDetail t1 WHERE t1.strAccountNumber='Market risk' and t1.strFutureMonth= t.strFutureMonth) dblNetMarketRisk,
		 strFutureMonth,'' as Selection  FROM @tblFinalDetail t WHERE (Selection = 'Physical position / Basis risk' or strAccountNumber='Market risk') 
	group by  strFutureMonth
	ORDER BY  CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END


END
ELSE
BEGIN
		INSERT INTO @tblFinalDetail (intRowNumber,strGroup,Selection ,PriceStatus ,strFutureMonth ,strAccountNumber ,dblNoOfContract ,strTradeNo ,TransactionDate
										,TranType ,CustVendor ,dblNoOfLot ,dblQuantity ,intOrderByHeading ,intContractHeaderId ,intFutOptTransactionHeaderId)
		EXEC uspRKRiskPositionInquiryBySummary @intCommodityId = @intCommodityId
		 ,@intCompanyLocationId = @intCompanyLocationId
		 ,@intFutureMarketId = @intFutureMarketId
		 ,@intFutureMonthId = @intFutureMonthId
		 ,@intUOMId = @intUOMId
		 ,@intDecimal = @intDecimal
		 ,@intForecastWeeklyConsumption=@intForecastWeeklyConsumption
		 ,@intForecastWeeklyConsumptionUOMId=@intForecastWeeklyConsumptionUOMId 


	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutureMonth ASC)) intRowNum,
		(select SUM(dblNoOfContract) FROM @tblFinalDetail t1 WHERE t1.PriceStatus = 'Outright coverage' and t1.strFutureMonth= t.strFutureMonth) dblPhysicalPosition,
		(select SUM(dblNoOfContract) FROM @tblFinalDetail t1 WHERE t1.PriceStatus='Futures Required' and t1.strFutureMonth= t.strFutureMonth) dblNetMarketRisk,
		 strFutureMonth,'' as Selection  FROM @tblFinalDetail t WHERE PriceStatus in('Outright coverage','Futures Required') 
	group by  strFutureMonth
	ORDER BY  CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END

END

GO