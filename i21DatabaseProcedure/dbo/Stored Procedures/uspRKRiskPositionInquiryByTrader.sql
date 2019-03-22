CREATE PROC [dbo].[uspRKRiskPositionInquiryByTrader]  
        @intCommodityId INTEGER = NULL,  
        @intCompanyLocationId INTEGER = NULL,  
        @intFutureMarketId INTEGER = NULL,  
        @intFutureMonthId INTEGER = NULL,  
        @intUOMId INTEGER = NULL,  
        @intDecimal INTEGER = NULL,  
        @intForecastWeeklyConsumption INTEGER = null,
        @intForecastWeeklyConsumptionUOMId INTEGER = null,
		@intBookId int = NULL, 
		@intSubBookId int = NULL,
		@strPositionBy nvarchar(100) = NULL,
		@intCompanyId int
AS  

DECLARE @Commodity AS TABLE 
(
intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
intCommodity  INT,
intFutureMarketId INT
)

if (isnull(@intFutureMarketId,0))= 0
BEGIN 
INSERT INTO @Commodity(intCommodity,intFutureMarketId)
SELECT DISTINCT mm.intCommodityId,m.intFutureMarketId FROM tblRKCommodityMarketMapping mm
JOIN tblRKFutureMarket m on m.intFutureMarketId=mm.intFutureMarketId ORDER BY m.intFutureMarketId  
END
ELSE
BEGIN
INSERT INTO @Commodity(intCommodity,intFutureMarketId)
SELECT @intCommodityId,@intFutureMarketId
END

DECLARE @List AS TABLE (
 intRowNumber INT identity(1, 1)
 ,intSumRowNum INT
,strFutMarketName NVARCHAR(max) COLLATE Latin1_General_CI_AS
,strBook NVARCHAR(max) COLLATE Latin1_General_CI_AS
,strProductType NVARCHAR(max) COLLATE Latin1_General_CI_AS
,strProductLine NVARCHAR(200) COLLATE Latin1_General_CI_AS
,strContractType NVARCHAR(max) COLLATE Latin1_General_CI_AS
,strTranType NVARCHAR(max) COLLATE Latin1_General_CI_AS
,strPhysicalOrFuture nvarchar(100) COLLATE Latin1_General_CI_AS
,strFutureMonth nvarchar(100) COLLATE Latin1_General_CI_AS
,dblNoOfContract Numeric(24, 10)
,dblNoOfLot Numeric(24, 10)
,dblQuantity Numeric(24, 10)
,strTradeNo nvarchar(100) COLLATE Latin1_General_CI_AS
,intContractHeaderId INT
,intFutOptTransactionHeaderId int
,TransactionDate DATETIME
,TranType nvarchar(100) COLLATE Latin1_General_CI_AS
,CustVendor nvarchar(100) COLLATE Latin1_General_CI_AS
,strItemOrigin nvarchar(100) COLLATE Latin1_General_CI_AS
,strLocationName nvarchar(100) COLLATE Latin1_General_CI_AS
,strItemDescription nvarchar(100) COLLATE Latin1_General_CI_AS
,strCompanyName nvarchar(100) COLLATE Latin1_General_CI_AS
,strShipmentPeriod nvarchar(100) COLLATE Latin1_General_CI_AS
)
DECLARE @FinalList AS TABLE (
 intRowNumber INT identity(1, 1)
 ,intSumRowNum INT
,strFutMarketName NVARCHAR(max) COLLATE Latin1_General_CI_AS
,strBook NVARCHAR(max) COLLATE Latin1_General_CI_AS
,strProductType NVARCHAR(max) COLLATE Latin1_General_CI_AS
,strProductLine NVARCHAR(200) COLLATE Latin1_General_CI_AS
,strContractType NVARCHAR(max) COLLATE Latin1_General_CI_AS
,strTranType NVARCHAR(max) COLLATE Latin1_General_CI_AS
,strPhysicalOrFuture nvarchar(100) COLLATE Latin1_General_CI_AS
,strFutureMonth nvarchar(100) COLLATE Latin1_General_CI_AS
,dblNoOfContract Numeric(24, 10)
,dblNoOfLot Numeric(24, 10)
,dblQuantity Numeric(24, 10)
,strTradeNo nvarchar(100) COLLATE Latin1_General_CI_AS
,intContractHeaderId INT
,intFutOptTransactionHeaderId int
,TransactionDate DATETIME
,TranType nvarchar(100) COLLATE Latin1_General_CI_AS
,CustVendor nvarchar(100) COLLATE Latin1_General_CI_AS
,strItemOrigin nvarchar(100) COLLATE Latin1_General_CI_AS
,strLocationName nvarchar(100) COLLATE Latin1_General_CI_AS
,strItemDescription nvarchar(100) COLLATE Latin1_General_CI_AS
,strCompanyName nvarchar(100) COLLATE Latin1_General_CI_AS
,strShipmentPeriod nvarchar(100) COLLATE Latin1_General_CI_AS
)

DECLARE @dblForecastWeeklyConsumption NUMERIC(24, 10)= null
DECLARE @strParamFutureMonth NVARCHAR(max)= null
DECLARE @strMarketSymbol NVARCHAR(max)= null
declare @mRowNumber int= null
declare @intFCommodityId int= null
declare @intFMarketId int= null
declare @intFMonthId int= null


SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity where intCommodityIdentity is not null
WHILE @mRowNumber >0
BEGIN

	SELECT @intFCommodityId = intCommodity,@intFMarketId=intFutureMarketId FROM @Commodity WHERE intCommodityIdentity = @mRowNumber

IF ISNULL(@intFutureMonthId,0) = 0
BEGIN
	SELECT TOP 1 @intFMonthId = intFutureMonthId
	FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND  dtmSpotDate <= GETDATE() AND intFutureMarketId = @intFMarketId ORDER BY intFutureMonthId DESC
END
ELSE 
BEGIN
	SET @intFMonthId=@intFutureMonthId 
END

IF ISNULL(@intUOMId,0) = 0
BEGIN	
SELECT @intUOMId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intFCommodityId AND ysnDefault=1
	
	
END

INSERT INTO @List( intSumRowNum, strFutMarketName,strBook ,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod)
EXEC uspRKRiskPositionInquiryByTraderSub 
        @intCommodityId  = @intFCommodityId,  
        @intCompanyLocationId  = @intCompanyLocationId,  
        @intFutureMarketId  = @intFMarketId,  
        @intFutureMonthId  = @intFMonthId,  
        @intUOMId  = @intUOMId,  
        @intDecimal  = @intDecimal,  
		@intBookId  = @intBookId, 
		@intSubBookId  = @intSubBookId,
		@strPositionBy  = @strPositionBy,
		@intCompanyId= @intCompanyId
	
SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber	
END

insert into @FinalList ( intSumRowNum,strFutMarketName,strBook ,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod)
SELECT 	 intRowNumber,strFutMarketName,strBook,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod
FROM @List where strFutureMonth not in('Total','Delta Ratio','Delta Total') and strPhysicalOrFuture='Physical'
--strTranType not in ('PTBF Buy','PTBF Sell') 
 order by strFutureMonth,intRowNumber

insert into @FinalList ( intSumRowNum,strFutMarketName,strBook ,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod)
SELECT 	 intRowNumber,strFutMarketName,strBook,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod
FROM @List where strFutureMonth not in('Total','Delta Ratio','Delta Total') and strTranType='PTBF Buy' and strPhysicalOrFuture='Futures'
 order by strFutureMonth,intRowNumber

 insert into @FinalList ( intSumRowNum,strFutMarketName,strBook ,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod)
SELECT 	 intRowNumber,strFutMarketName,strBook,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod
FROM @List where strFutureMonth not in('Total','Delta Ratio','Delta Total') and strTranType='PTBF Sell' and strPhysicalOrFuture='Futures'
 order by strFutureMonth,intRowNumber

  insert into @FinalList ( intSumRowNum,strFutMarketName,strBook ,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod)
SELECT 	 intRowNumber,strFutMarketName,strBook,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod
FROM @List where strFutureMonth not in('Total','Delta Ratio','Delta Total') and strTranType not in('PTBF Sell','PTBF Buy') and strPhysicalOrFuture='Futures'
 order by strFutureMonth,intRowNumber

insert into @FinalList ( intSumRowNum,strFutMarketName,strBook,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod)
SELECT 	 intRowNumber,strFutMarketName,strBook ,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod
FROM @List where strFutureMonth in ('Total')  order by strFutureMonth,intRowNumber

insert into @FinalList ( intSumRowNum,strFutMarketName,strBook ,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod)
SELECT 	 intRowNumber,strFutMarketName,strBook ,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod
FROM @List where strFutureMonth='Delta Ratio'  order by strFutureMonth,intRowNumber
insert into @FinalList ( intSumRowNum,strFutMarketName,strBook ,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod)
SELECT 	 intRowNumber,strFutMarketName,strBook ,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod
FROM @List where strFutureMonth='Delta Total'  order by strFutureMonth,intRowNumber

SELECT intSumRowNum,strFutMarketName,strBook ,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,
		case when isnull(mc.intMultiCompanyParentId,0) =0 then 'Parent' else 'Subsidiary' end strCompanyName,l.strCompanyName strName,strShipmentPeriod 
		,case when strPhysicalOrFuture='Futures' and strProductLine in('PTBF Buy','PTBF Sell') then strProductLine
			  when strPhysicalOrFuture='Futures' and strProductLine not in('PTBF Buy','PTBF Sell') then 'Hedges (Clearing)'
			  else 'Physical'  end strProductLineBuySell
FROM @FinalList l
JOIN tblSMMultiCompany mc on l.strCompanyName=mc.strCompanyName
ORDER BY  intRowNumber,strFutMarketName,strCompanyName
