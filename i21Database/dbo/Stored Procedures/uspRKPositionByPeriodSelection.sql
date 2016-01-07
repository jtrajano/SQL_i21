CREATE PROC uspRKPositionByPeriodSelection 
	@intCommodityId nvarchar(max) ,
	@intCompanyLocationId nvarchar(max) ,
	@strGroupings nvarchar(100) = '',
	@dtmDate1 datetime = null,
	@dtmDate2 datetime = null,
	@dtmDate3 datetime = null,
	@dtmDate4 datetime = null,
	@dtmDate5 datetime = null,
	@dtmDate6 datetime = null,
	@dtmDate7 datetime = null,
	@dtmDate8 datetime = null,
	@dtmDate9 datetime = null,
	@dtmDate10 datetime = null,
	@dtmDate11 datetime = null,
	@dtmDate12 datetime = null
AS

DECLARE @MonthList as TABLE (  
     intRowNumber int, 
	 dtmMonth nvarchar(15))

	INSERT INTO @MonthList
	select intRowNumber,dtmMonth from(
			select 1 AS intRowNumber, RIGHT(CONVERT(VARCHAR(11),@dtmDate1,106),8) dtmMonth
			union 
			select 2 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate2,106),8) dtmMonth 
			union 
			select 3 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate3,106),8) dtmMonth
			union 
			select 4 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate4,106),8) dtmMonth
			union 
			select 5 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate5,106),8) dtmMonth
			union 
			select 6 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate6,106),8) dtmMonth
			union 
			select 7 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate7,106),8) dtmMonth
			union 
			select 8 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate8,106),8) dtmMonth
			union 
			select 9 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate9,106),8) dtmMonth
			union 
			select 10 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate10,106),8) dtmMonth
			union
			select 11 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate11,106),8) dtmMonth
			union
			select 12 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate12,106),8) dtmMonth
	)t

	DELETE FROM @MonthList where dtmMonth IS NULL

	DECLARE @MaxDate Datetime 
	SELECT  TOP 1 @MaxDate=CONVERT(DATETIME,'01 '+dtmMonth) from @MonthList order by intRowNumber desc

	 DECLARE @List AS TABLE (  
     intRowNumber int IDENTITY(1,1) PRIMARY KEY , 
	 strCommodity  nvarchar(200),
	 strHeaderValue nvarchar(200),  
     strSubHeading  nvarchar(200),  
	 strSecondSubHeading nvarchar(200),
     strContractEndMonth  nvarchar(100),  
     strContractBasis  nvarchar(200),  
     dblBalance  decimal(24,10),  
     strMarketZoneCode  nvarchar(200),  
     dblFuturesPrice  decimal(24,10),
     dblBasisPrice decimal(24,10),  
     dblCashPrice decimal(24,10),       
     dblWtAvgPriced decimal(24,10),  
     dblQuantity decimal(24,10),
	 strLocationName nvarchar(200),
	 strContractNumber nvarchar(200),
	 strItemNo nvarchar(200),
	 intOrderByOne int,
	 intOrderByTwo int,
	 dblRate  decimal(24,10)
     )   

	 DECLARE @FinalList AS TABLE (  
     intRowNumber int , 
	 strCommodity  nvarchar(200),  
	 strHeaderValue nvarchar(200),
     strSubHeading  nvarchar(200),  
	 strSecondSubHeading nvarchar(200),
     strContractEndMonth  nvarchar(100),  
     strContractBasis  nvarchar(200),  
     dblBalance  decimal(24,10),  
     strMarketZoneCode  nvarchar(200),  
     dblFuturesPrice  decimal(24,10),
     dblBasisPrice decimal(24,10),  
     dblCashPrice decimal(24,10),       
     dblWtAvgPriced decimal(24,10),  
     dblQuantity decimal(24,10),
	 strLocationName nvarchar(200),
	 strContractNumber nvarchar(200),
	 strItemNo nvarchar(200),
	  intOrderByOne int,
	 intOrderByTwo int,
	 dblRate  decimal(24,10)         
     )   

	 DECLARE @Commodity AS TABLE 
	 (
		intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
		intCommodity  INT
	 )
	 INSERT INTO @Commodity(intCommodity)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  


DECLARE @countC1 int = null
DECLARE @MonthC1 nvarchar(50)= null
DECLARE @PreviousMonthC1 nvarchar(50)= null
DECLARE @intMonthC1 int= null
DECLARE @PreviousMonthQumPosition1 numeric(24,10)= null
SELECT @countC1= min(intRowNumber) from @MonthList

DECLARE @MaxMonth nvarchar(50) = null
SELECT TOP 1 @MaxMonth=dtmMonth from @MonthList Order by intRowNumber desc

-- Priced Contract	
IF @strGroupings= 'Contract Terms'
BEGIN

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber)

		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strContractBasis,''),'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,
		isnull((select sum(cv.dblRate) FROM vyuCTContractCostView cv
					JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight'),0) dblRate	
		,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1,2,3,5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  
		AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodity,'Purchase Total','Purchase Total',strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth
		
		------------------Sale start --------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber)
		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strContractBasis,''),'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,
		isnull((select sum(cv.dblRate) FROM vyuCTContractCostView cv
					JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight'),0) dblRate	
		,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1,2,3,5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId,strLocationName
	
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodity,'Sale Total','Sale Total',strContractEndMonth,dblBalance dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @List where strSecondSubHeading='Sale Quantity' 
	
END

IF @strGroupings= 'Market Zone'
BEGIN

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strMarketZoneCode,''),'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId  in(1,2,3,5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  
		AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType
		
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodity,'Purchase Total','Purchase Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth

		------------------Sale start --------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strMarketZoneCode,''),'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId  in(1,2,3,5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
			AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodity,'Sale Total','Sale Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @List where strSecondSubHeading='Sale Quantity' --group by strCommodity,strContractEndMonth
END

IF @strGroupings= 'Market Zone and Contract Terms'
BEGIN

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strContractBasis,'') + ' - ' + isnull(strMarketZoneCode,''),'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1,2,3,5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))			
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType
				
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodity,'Purchase Total','Purchase Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @List where strSecondSubHeading='Purchase Quantity'-- group by strCommodity,strContractEndMonth

		------------------Sale start --------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strContractBasis,'') + ' - ' + isnull(strMarketZoneCode,''),'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1,2,3,5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
			AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType
				
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodity,'Sale Total','Sale Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @List where strSecondSubHeading='Sale Quantity'-- group by strCommodity,strContractEndMonth

END

IF @strGroupings= 'By Item' 
BEGIN

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo)
		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strItemNo,'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strItemNo
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1,2,3,5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
			AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strItemNo,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodity,'Purchase Total','Purchase Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth

		------------------Sale start --------------
		
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo)
	
		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strItemNo,'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strItemNo
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1,2,3,5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
			AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,strContractBasis,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strItemNo,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType
	
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodity,'Sale Total','Sale Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @List where strSecondSubHeading='Sale Quantity' --group by strCommodity,strContractEndMonth

END

----------------------- Futures

INSERT INTO @List (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,dblFuturesPrice,strContractNumber,strLocationName)
SELECT DISTINCT strCommodityCode,'Futures - Long' as strHeaderValue,'Futures - Long' as strSubHeading, 'Futures - Long' as strSecondSubHeading,strFutureMonth, 
				(intNoOfContract-isnull(intOpenContract,0))*dblContractSize intOpenContract,dblPrice,strInternalTradeNo,strLocationName FROM (
SELECT ot.intFutOptTransactionId,ot.strInternalTradeNo, sum(ot.intNoOfContract) intNoOfContract,RIGHT(CONVERT(VARCHAR(11),dtmFutureMonthsDate,106),8) strFutureMonth,ot.dblPrice ,strCommodityCode,
	   (SELECT SUM(CONVERT(int,mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf where ot.intFutOptTransactionId=mf.intLFutOptTransactionId) intOpenContract,strLocationName,dblContractSize
FROM tblRKFutOptTransaction ot 
JOIN tblRKFutureMarket m on ot.intFutureMarketId=m.intFutureMarketId
JOIN tblRKFuturesMonth fm on ot.intFutureMonthId=fm.intFutureMonthId and ysnExpired=0
JOIN tblICCommodity c on ot.intCommodityId=c.intCommodityId
JOIN tblSMCompanyLocation l on ot.intLocationId=l.intCompanyLocationId
WHERE ot.strBuySell='Buy' AND ot.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))   
						  AND ot.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ',')) 
GROUP BY intFutOptTransactionId,strCommodityCode,strLocationName,strInternalTradeNo,RIGHT(CONVERT(VARCHAR(11),dtmFutureMonthsDate,106),8),dblPrice,dblContractSize) t

------------------ short 
INSERT INTO @List (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,dblFuturesPrice,strContractNumber,strLocationName)

SELECT DISTINCT strCommodityCode,'Futures - Short' as strHeaderValue,'Futures - Short' as strSubHeading, 'Futures - Short' as strSecondSubHeading,strFutureMonth,
				-(intNoOfContract-isnull(intOpenContract,0))*dblContractSize intOpenContract,dblPrice,strInternalTradeNo,strLocationName from (
SELECT ot.intFutOptTransactionId,ot.strInternalTradeNo, sum(ot.intNoOfContract) intNoOfContract,RIGHT(CONVERT(VARCHAR(11),dtmFutureMonthsDate,106),8) strFutureMonth,ot.dblPrice ,strCommodityCode,
	   (SELECT SUM(CONVERT(int,mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf where ot.intFutOptTransactionId=mf.intSFutOptTransactionId) intOpenContract,strLocationName,dblContractSize
FROM tblRKFutOptTransaction ot 
JOIN tblRKFutureMarket m on ot.intFutureMarketId=m.intFutureMarketId
JOIN tblRKFuturesMonth fm on ot.intFutureMonthId=fm.intFutureMonthId and fm.ysnExpired=0
JOIN tblICCommodity c on ot.intCommodityId=c.intCommodityId
JOIN tblSMCompanyLocation l on ot.intLocationId=l.intCompanyLocationId
where ot.strBuySell='Sell' AND ot.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))   
						  AND ot.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ',')) 
GROUP BY intFutOptTransactionId,strCommodityCode,strLocationName,strInternalTradeNo,RIGHT(CONVERT(VARCHAR(11),dtmFutureMonthsDate,106),8),dblPrice,dblContractSize) t
 
-- Net Futures
INSERT INTO @List (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractNumber,strLocationName)

SELECT strCommodity,'Net Futures','Net Futures','Net Futures',strContractEndMonth,dblBalance,strContractNumber,strLocationName FROM  @List 
		WHERE strHeaderValue='Futures - Long' and strHeaderValue='Futures - Long' and strSecondSubHeading='Futures - Long'
UNION
SELECT strCommodity,'Net Futures','Net Futures','Net Futures',strContractEndMonth,dblBalance,strContractNumber,strLocationName FROM  @List 
		WHERE strHeaderValue='Futures - Short' and strHeaderValue='Futures - Short' and strSecondSubHeading='Futures - Short'

---Previous

DECLARE @count int
DECLARE @Month nvarchar(50)
DECLARE @PreviousMonth nvarchar(50)
DECLARE @intMonth int
select @count= min(intRowNumber) from @MonthList

WHILE @count Is not null
BEGIN
SELECT @intMonth = intRowNumber,@Month=dtmMonth from @MonthList where intRowNumber=@count
IF @count = 1
BEGIN
	 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo)
	 SELECT strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,
	 dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo FROM @List  where (CONVERT(DATETIME,'01 '+strContractEndMonth)) = (CONVERT(DATETIME,'01 '+@Month)) 
END
ELSE
BEGIN 
	 SELECT @PreviousMonth=dtmMonth from @MonthList where intRowNumber=@count -1
	 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo)
	 SELECT strCommodity,strSubHeading,strSecondSubHeading,@Month strContractEndMonth,strContractBasis,sum(isnull(dblBalance,0)),strMarketZoneCode,sum(isnull(dblFuturesPrice,0)),sum(isnull(dblBasisPrice,0)),sum(isnull(dblCashPrice,0)),dblRate,strLocationName,strContractNumber,strItemNo FROM @List
	 WHERE (CONVERT(DATETIME,'01 '+strContractEndMonth)) > (CONVERT(DATETIME,'01 '+@PreviousMonth)) and (CONVERT(DATETIME,'01 '+strContractEndMonth)) <= (CONVERT(DATETIME,'01 '+@Month)) 
	 GROUP BY strCommodity,strSubHeading,strSecondSubHeading,strContractBasis,strMarketZoneCode,dblRate,strLocationName,strContractNumber,strItemNo
END

SELECT @count = min(intRowNumber) from @MonthList where intRowNumber>@count 
END

DECLARE @Month1 nvarchar(50)
SELECT TOP 1 @Month1=dtmMonth from @MonthList Order by intRowNumber 
-- Previous
	 INSERT INTO @FinalList(intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo)
	 SELECT intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,'Previous' strContractEndMonth,strContractBasis,sum(isnull(dblBalance,0)),strMarketZoneCode,sum(isnull(dblFuturesPrice,0)),sum(isnull(dblBasisPrice,0)),sum(isnull(dblCashPrice,0)),dblRate,strLocationName,strContractNumber,strItemNo FROM @List
	 WHERE (CONVERT(DATETIME,'01 '+strContractEndMonth)) < (CONVERT(DATETIME,'01 '+@Month1)) 
	 GROUP BY intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,strContractBasis,strMarketZoneCode,dblRate,strLocationName,strContractNumber,strItemNo

---- Future

DECLARE @Month2 nvarchar(50)
SELECT TOP 1 @Month2=dtmMonth from @MonthList Order by intRowNumber desc

		 INSERT INTO @FinalList(intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo)
		 SELECT intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,'Future' strContractEndMonth,strContractBasis,sum(isnull(dblBalance,0)),strMarketZoneCode,sum(isnull(dblFuturesPrice,0)),sum(isnull(dblBasisPrice,0)),sum(isnull(dblCashPrice,0)),dblRate,strLocationName,strContractNumber,strItemNo FROM @List
		 WHERE (CONVERT(DATETIME,'01 '+strContractEndMonth)) > (CONVERT(DATETIME,'01 '+@Month2)) 
		 GROUP BY intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,strContractBasis,strMarketZoneCode,dblRate,strLocationName,strContractNumber,strItemNo
	
------ Pulling from header details...

DECLARE @strCommodityh Nvarchar(100)
DECLARE @intCommodityIdentityh int
declare @intCommodityIdh int
DECLARE @intMinRowNumberh int


SELECT @intCommodityIdentityh= min(intCommodityIdentity) from @Commodity
WHILE @intCommodityIdentityh >0
BEGIN
	SELECT @intCommodityIdh =intCommodity FROM @Commodity where intCommodityIdentity=@intCommodityIdentityh
	  IF @intCommodityIdh >0
	  BEGIN
		  INSERT INTO @FinalList(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)	  
		  EXEC uspRKPositionByPeriodSelectionHeader @intCommodityIdh,@intCompanyLocationId
	  END
SELECT @intCommodityIdentityh= min(intCommodityIdentity) FROM @Commodity WHERE intCommodityIdentity > @intCommodityIdentityh
END
-------

DECLARE @strCommodity Nvarchar(100)
DECLARE @intCommodityIdentity int
DECLARE @intMinRowNumber int
DECLARE @dblInventoryQty numeric(24,10)=0
declare @strCommodityCode nvarchar(500)
declare @Ownership numeric (24,10)
declare @PurchaseBasisDel numeric (24,10)
SELECT @intCommodityIdentity= min(intCommodityIdentity) from @Commodity

WHILE @intCommodityIdentity >0
BEGIN
SELECT @intCommodityId =intCommodity FROM @Commodity where intCommodityIdentity=@intCommodityIdentity
 IF @intCommodityId >0
 BEGIN
	SELECT @strCommodityCode=strCommodityCode from tblICCommodity Where intCommodityId=@intCommodityId
	SELECT @dblInventoryQty=sum(dblBalance) from @FinalList  where strCommodity=@strCommodityCode AND strSubHeading='Inventory' 
	SELECT @Ownership=sum(dblBalance) from @FinalList  where strCommodity=@strCommodityCode AND strSubHeading='Inventory' and strSecondSubHeading='Ownership'
	SELECT @PurchaseBasisDel=sum(dblBalance) from @FinalList  where strCommodity=@strCommodityCode AND strSubHeading='Inventory' and strSecondSubHeading='Purchase Basis Delivery'

		 IF EXISTS (SELECT * FROM @FinalList WHERE strCommodity=@strCommodityCode and strContractEndMonth='Previous')
		 BEGIN
		 	 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
 			 SELECT @strCommodityCode,'Purchase Total','Purchase Total','Previous',@dblInventoryQty,'' strContractBasis,'' strLocationName,'' strContractNumber --from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth
			 ---- case exposure
			  INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)
				SELECT @strCommodityCode,'Cash Exposure','Cash Exposure','Previous',@Ownership 
				UNION
				SELECT @strCommodityCode,'Cash Exposure','Cash Exposure','Previous',-@PurchaseBasisDel 

			  INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
			   SELECT strCommodity,'Cash Exposure','Cash Exposure','Previous',dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Purchase-Priced%' and strSecondSubHeading='Purchase Quantity' and strContractEndMonth= 'Previous'
					UNION
				SELECT strCommodity,'Cash Exposure','Cash Exposure','Previous',dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Purchase-HTA%' and strSecondSubHeading='Purchase Quantity' and strContractEndMonth= 'Previous'
				UNION
				   SELECT strCommodity,'Cash Exposure','Cash Exposure','Previous',-dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Sale-Priced%' and strSecondSubHeading='Sale Quantity' and strContractEndMonth= 'Previous'
				UNION
				SELECT strCommodity,'Cash Exposure','Cash Exposure','Previous',-dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Sale-HTA%' and strSecondSubHeading='Sale Quantity' and strContractEndMonth= 'Previous'
				
				 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
					SELECT strCommodity,'Cash Exposure','Cash Exposure','Previous',dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
						WHERE strCommodity= @strCommodityCode and strSubHeading ='Net Futures' and strSecondSubHeading='Net Futures' and strContractEndMonth= 'Previous'

		 ---- Basis exposure

		 		INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)
				SELECT @strCommodityCode,'Basis Exposure','Basis Exposure','Previous',@Ownership 
			
			   INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
			   SELECT strCommodity,'Basis Exposure','Basis Exposure','Previous',dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Purchase-Priced%' and strSecondSubHeading='Purchase Quantity' and strContractEndMonth= 'Previous'
			   UNION
			   SELECT strCommodity,'Basis Exposure','Basis Exposure','Previous',dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Purchase-Basis%' and strSecondSubHeading='Purchase Quantity' and strContractEndMonth= 'Previous'
				UNION

				SELECT strCommodity,'Basis Exposure','Basis Exposure','Previous',-dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
				WHERE strCommodity= @strCommodityCode and strSubHeading like '%Sale-Priced%' and strSecondSubHeading='Sale Quantity' and strContractEndMonth= 'Previous'
			   UNION
			   SELECT strCommodity,'Basis Exposure','Basis Exposure','Previous',-dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Sale-Basis%' and strSecondSubHeading='Sale Quantity' and strContractEndMonth= 'Previous'
		END
		 ELSE
		 BEGIN
			DECLARE @MonthPurTot nvarchar(50)
			
			SELECT TOP 1 @MonthPurTot=dtmMonth from @MonthList m
			JOIN @FinalList f on f.strContractEndMonth=m.dtmMonth and f.dblBalance is not null  Order by m.intRowNumber 
			
		if @MonthPurTot is not null
		BEGIN
			 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
 			 SELECT @strCommodityCode,'Purchase Total','Purchase Total',@MonthPurTot,@dblInventoryQty,'' strContractBasis,'' strLocationName,'' strContractNumber --from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth

			---- case exposure
			  INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)
				SELECT @strCommodityCode,'Cash Exposure','Cash Exposure',@MonthPurTot,@Ownership 
				UNION
				SELECT @strCommodityCode,'Cash Exposure','Cash Exposure',@MonthPurTot,-@PurchaseBasisDel 
			---- Basis exposure

			INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)
			SELECT @strCommodityCode,'Basis Exposure','Basis Exposure',@MonthPurTot,@Ownership 
		END
		ELSE		
		BEGIN
			 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
 			 SELECT @strCommodityCode,'Purchase Total','Purchase Total','Future',@dblInventoryQty,'' strContractBasis,'' strLocationName,'' strContractNumber --from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth

			---- case exposure
			  INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)
				SELECT @strCommodityCode,'Cash Exposure','Cash Exposure','Future',@Ownership 
				UNION
				SELECT @strCommodityCode,'Cash Exposure','Cash Exposure','Future',-@PurchaseBasisDel 
			---- Basis exposure

			INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)
			SELECT @strCommodityCode,'Basis Exposure','Basis Exposure','Future',@Ownership 
		END		
		 END	 
		 --Net Physical position
		    INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
 			 SELECT @strCommodityCode,'Net Physical Position','Net Physical Position',strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber from @FinalList WHERE strSubHeading='Purchase Total' and strCommodity=@strCommodityCode

		 	 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
 			 SELECT @strCommodityCode,'Net Physical Position','Net Physical Position',strContractEndMonth,-dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @FinalList WHERE strSubHeading='Sale Total' and strCommodity=@strCommodityCode

			 ---- case exposure

			  INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
			   SELECT strCommodity,'Cash Exposure','Cash Exposure',strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Purchase-Priced%' and strSecondSubHeading='Purchase Quantity' and strContractEndMonth <> 'Previous'
			  union
			  	   SELECT strCommodity,'Cash Exposure','Cash Exposure',strContractEndMonth,-dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Sale-Priced%' and strSecondSubHeading='Sale Quantity' and strContractEndMonth <> 'Previous'

			 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
				SELECT strCommodity,'Cash Exposure','Cash Exposure',strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Purchase-HTA%' and strSecondSubHeading='Purchase Quantity' and strContractEndMonth <> 'Previous'
				UNION
				SELECT strCommodity,'Cash Exposure','Cash Exposure',strContractEndMonth,-dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Sale-HTA%' and strSecondSubHeading='Sale Quantity' and strContractEndMonth <> 'Previous'
				
				 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
					SELECT strCommodity,'Cash Exposure','Cash Exposure',strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
						WHERE strCommodity= @strCommodityCode and strSubHeading ='Net Futures' and strSecondSubHeading='Net Futures' and strContractEndMonth <> 'Previous'	

			----- Basis Exposure
				INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
			   SELECT strCommodity,'Basis Exposure','Basis Exposure',strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Purchase-Priced%' and strSecondSubHeading='Purchase Quantity' and strContractEndMonth<> 'Previous'
			   UNION
			   SELECT strCommodity,'Basis Exposure','Basis Exposure',strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Purchase-Basis%' and strSecondSubHeading='Purchase Quantity' and strContractEndMonth<> 'Previous'
				UNION

				SELECT strCommodity,'Basis Exposure','Basis Exposure',strContractEndMonth,-dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
				WHERE strCommodity= @strCommodityCode and strSubHeading like '%Sale-Priced%' and strSecondSubHeading='Sale Quantity' and strContractEndMonth<> 'Previous'
			   UNION
			   SELECT strCommodity,'Basis Exposure','Basis Exposure',strContractEndMonth,-dblBalance,strContractBasis,strLocationName,strContractNumber FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Sale-Basis%' and strSecondSubHeading='Sale Quantity' and strContractEndMonth<> 'Previous'
   END
SELECT @intCommodityIdentity= min(intCommodityIdentity) from @Commodity Where intCommodityIdentity > @intCommodityIdentity
END

----------------------  DONE FOR ALL..........
----------Wt Avg --------------
INSERT INTO @FinalList (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber)

SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Price' as strSecondSubHeading,strContractEndMonth,
		dblBalance*dblFuturesPrice / sum(dblBalance) over (partition by strContractEndMonth,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber from  @FinalList
WHERE strSubHeading ='Futures - Long' OR  strSubHeading ='Futures - Short' 
)t 
-------RK Module 


INSERT INTO @FinalList (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber)

SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Futures' as strSecondSubHeading,strContractEndMonth,
		dblBalance*dblFuturesPrice / sum(dblBalance) over (partition by strContractEndMonth,strSecondSubHeading,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber from  @FinalList
WHERE strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity'
)t 
UNION
SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Basis' as strSecondSubHeading,strContractEndMonth,
		dblBalance*dblBasisPrice / sum(dblBalance) over (partition by strContractEndMonth,strSecondSubHeading,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber from  @FinalList
WHERE strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity' 
)t 
UNION
SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Cash' as strSecondSubHeading,strContractEndMonth,
		dblBalance*dblCashPrice / sum(dblBalance) over (partition by strContractEndMonth,strSecondSubHeading,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber from  @FinalList
WHERE strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity' 
)t 
UNION
SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Freight' as strSecondSubHeading,strContractEndMonth,
		dblBalance*dblRate / sum(dblBalance) over (partition by strContractEndMonth,strSecondSubHeading,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber from  @FinalList
WHERE strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity'
)t 
-- end
----------Cumulative Calculation

DECLARE @strCommodityCumulative Nvarchar(100)
DECLARE @intCommodityIdentityCumulative int
declare @intCommodityIdCumulative int
DECLARE @intMinRowNumberCumulative int

SELECT @intCommodityIdentityCumulative= min(intCommodityIdentity) from @Commodity
WHILE @intCommodityIdentityCumulative >0
BEGIN
	SELECT @intCommodityIdCumulative =intCommodity FROM @Commodity where intCommodityIdentity=@intCommodityIdentityCumulative
	select @strCommodityCumulative=strCommodityCode from tblICCommodity Where intCommodityId=@intCommodityIdCumulative
	  IF @intCommodityIdCumulative >0
	  BEGIN




	  
		if exists(select * from @FinalList where strContractEndMonth='Previous')
			BEGIN
				 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)
				 SELECT  strCommodity, 'Cumulative physical position',  'Cumulative physical position','Previous',dblBalance FROM @FinalList where strSubHeading='Net Physical Position' and strContractEndMonth='Previous' and strCommodity= @strCommodityCumulative
			END

		DECLARE @countC int
		DECLARE @MonthC nvarchar(50)
		DECLARE @PreviousMonthC nvarchar(50)
		DECLARE @intMonthC int
		SELECT @countC= min(intRowNumber) from @MonthList
		declare @previousValue numeric(24,10)
		select @previousValue=sum(isnull(dblBalance,0)) from @FinalList where strSubHeading='Cumulative physical position' and strContractEndMonth='Previous' and  strCommodity= @strCommodityCumulative
		WHILE @countC Is not null
		BEGIN
		SELECT @intMonthC = intRowNumber,@MonthC=dtmMonth from @MonthList where intRowNumber=@countC

		IF @countC = 1
		BEGIN	
			BEGIN
	
				INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)
				 SELECT  strCommodity, 'Cumulative physical position',  'Cumulative physical position',@MonthC,sum(dblBalance)+isnull(@previousValue,0) FROM @FinalList where strSubHeading='Net Physical Position' and strContractEndMonth=@MonthC and strCommodity= @strCommodityCumulative
				 GROUP BY strCommodity
		
				SELECT  @previousValue=sum(dblBalance)+ isnull(@previousValue,0) FROM @FinalList where strSubHeading='Net Physical Position' and strContractEndMonth=@MonthC and strCommodity= @strCommodityCumulative
				 GROUP BY strCommodity
			END
		END
		ELSE
		BEGIN 

		DECLARE @PreviousMonthQumPosition numeric(24,10)

			 SELECT @PreviousMonthC=dtmMonth from @MonthList where intRowNumber=@countC -1
			 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)
			 SELECT strCommodity, 'Cumulative physical position',  'Cumulative physical position',@MonthC strContractEndMonth,sum(isnull(dblBalance,0))+@previousValue FROM @FinalList
			 WHERE (CONVERT(DATETIME,'01 '+strContractEndMonth)) > (CONVERT(DATETIME,'01 '+@PreviousMonthC)) and (CONVERT(DATETIME,'01 '+strContractEndMonth)) <= (CONVERT(DATETIME,'01 '+@MonthC)) and  
			 strSubHeading='Net Physical Position' and strContractEndMonth<>'Future' and   strContractEndMonth<>'Previous' and strCommodity= @strCommodityCumulative
			 group by strCommodity

			  SELECT @previousValue = sum(isnull(dblBalance,0))+@previousValue FROM @FinalList
			 WHERE (CONVERT(DATETIME,'01 '+strContractEndMonth)) > (CONVERT(DATETIME,'01 '+@PreviousMonthC)) and (CONVERT(DATETIME,'01 '+strContractEndMonth)) <= (CONVERT(DATETIME,'01 '+@MonthC)) and  
			 strSubHeading='Net Physical Position' and strContractEndMonth<>'Future' and   strContractEndMonth<>'Previous' and strCommodity= @strCommodityCumulative
			 group by strCommodity

		END

		SELECT @countC = min(intRowNumber) from @MonthList where intRowNumber>@countC
		END

IF EXISTS(SELECT * FROM @FinalList where strContractEndMonth='Future')
	BEGIN
		
	INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
 	SELECT strCommodity,'Cumulative physical position','Cumulative physical position',strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber from @FinalList WHERE strSubHeading='Purchase Total' and strCommodity=@strCommodityCumulative and strContractEndMonth='Future'

	INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
 	SELECT strCommodity,'Cumulative physical position','Cumulative physical position',strContractEndMonth,-dblBalance,strContractBasis,strLocationName,strContractNumber from @FinalList WHERE strSubHeading='Sale Total' and strCommodity=@strCommodityCumulative and strContractEndMonth='Future'

	INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)
 	SELECT @strCommodityCumulative,'Cumulative physical position','Cumulative physical position','Future',isnull(@previousValue,0)
    END
 END
SELECT @intCommodityIdentityCumulative= min(intCommodityIdentity) FROM @Commodity WHERE intCommodityIdentity > @intCommodityIdentityCumulative
END
update @FinalList set intOrderByOne=1  Where strSubHeading='Inventory' 
update @FinalList set intOrderByOne=2  Where strSubHeading like '%Purchase-Priced%'
update @FinalList set intOrderByOne=3  Where strSubHeading like '%Purchase-Basis%'
update @FinalList set intOrderByOne=4  Where strSubHeading like '%Purchase-HTA%'
update @FinalList set intOrderByOne=5  Where strSubHeading like '%Purchase-DP%'
update @FinalList set intOrderByOne=6  Where strSubHeading = 'Purchase Total'
update @FinalList set intOrderByOne=7  Where strSubHeading like '%Sale-Priced%'
update @FinalList set intOrderByOne=8  Where strSubHeading like '%Sale-Basis%'
update @FinalList set intOrderByOne=9  Where strSubHeading like '%Sale-HTA%'
update @FinalList set intOrderByOne=10  Where strSubHeading like '%Sale-DP%'
update @FinalList set intOrderByOne=11  Where strSubHeading = 'Sale Total'
update @FinalList set intOrderByOne=12  Where strSubHeading = 'Net Physical Position'
update @FinalList set intOrderByOne=13  Where strSubHeading = 'Cumulative physical position'
update @FinalList set intOrderByOne=14  Where strSubHeading = 'Futures - Long'
update @FinalList set intOrderByOne=15  Where strSubHeading = 'Futures - Short'
update @FinalList set intOrderByOne=16  Where strSubHeading = 'Net Futures'
update @FinalList set intOrderByOne=17  Where strSubHeading = 'Cash Exposure'
update @FinalList set intOrderByOne=18  Where strSubHeading = 'Basis Exposure'

update @FinalList set intOrderByTwo=1 Where strSecondSubHeading ='Purchase Quantity'
update @FinalList set intOrderByTwo=2 Where strSecondSubHeading ='Wt./Avg Futures'
update @FinalList set intOrderByTwo=3 Where strSecondSubHeading ='Wt./Avg Basis'
update @FinalList set intOrderByTwo=4 Where strSecondSubHeading ='Wt./Avg Cash'
update @FinalList set intOrderByTwo=5 Where strSecondSubHeading ='Wt./Avg Freight'

UPDATE @List set dblBalance = null where dblBalance = 0 


DELETE @List
INSERT INTO @List(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne FROM  @FinalList Where strContractEndMonth='Inventory'
INSERT INTO @List(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne FROM  @FinalList Where strContractEndMonth='Previous'
INSERT INTO @List(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,dblRate,strContractNumber,strItemNo,intOrderByOne)
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,dblRate,strContractNumber,strItemNo,intOrderByOne FROM @FinalList Where strContractEndMonth NOT IN('Previous','Future','Inventory') ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)
INSERT INTO @List(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne)
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne FROM @FinalList Where strContractEndMonth='Future'


SELECT * FROM @List where dblBalance IS NOT NULL order by intOrderByOne,intOrderByTwo