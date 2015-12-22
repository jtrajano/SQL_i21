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
	 intOrderByTwo int
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
	 intOrderByTwo int          
     )   

	 DECLARE @Commodity AS TABLE 
	 (
		intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
		intCommodity  INT
	 )
	 INSERT INTO @Commodity(intCommodity)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  

-- Priced Contract	
IF @strGroupings= 'Contract Terms'
BEGIN

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strContractBasis,'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-Priced' +' - ' +strContractBasis,'Wt./Avg Futures',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),
		strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblFutures,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber 
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)

		SELECT StrCommodity,'Purchase-Priced' +' - ' +strContractBasis,'Wt./Avg Basis',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblBasis,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber 
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-Priced' +' - ' +strContractBasis,'Wt./Avg Cash',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblCashPrice,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-Priced' +' - ' +strContractBasis,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
				select StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strContractBasis,strLocationName,strContractNumber from (
				SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		

		-----------------   Purchase Basis--------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strContractBasis,'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)

		SELECT StrCommodity,'Purchase-Basis' +' - ' +strContractBasis,'Wt./Avg Basis',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblBasis,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-Basis' +' - ' +strContractBasis,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strContractBasis,strLocationName,strContractNumber FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName,
		cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		

		-------------  Purchases HTA

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strContractBasis,'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)

		SELECT StrCommodity,'Purchase-HTA' +' - ' +strContractBasis,'Wt./Avg Futures',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblFutures,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-HTA' +' - ' +strContractBasis,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strContractBasis,strLocationName,strContractNumber from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		

		------------------------Purchase DP

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strContractBasis,'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth
		,strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-DP' +' - ' +strContractBasis,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strContractBasis,strLocationName,strContractNumber from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName,
		cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(5)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		
		
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodity,'Purchase Total','Purchase Total',strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth
		
		------------------Sale start --------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strContractBasis,'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,strLocationName

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)

		SELECT StrCommodity,'Sale-Priced' +' - ' +strContractBasis,'Wt./Avg Futures',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblFutures,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)

		SELECT StrCommodity,'Sale-Priced' +' - ' +strContractBasis,'Wt./Avg Basis',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblBasis,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Sale-Priced' +' - ' +strContractBasis,'Wt./Avg Cash',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblCashPrice,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Sale-Priced' +' - ' +strContractBasis,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
				select StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strContractBasis,strLocationName,strContractNumber from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName,
		cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		

		-----------------   Sale Basis--------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strContractBasis,'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)

		SELECT StrCommodity,'Sale-Basis' +' - ' +strContractBasis,'Wt./Avg Basis',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblBasis,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Sale-Basis' +' - ' +strContractBasis,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
				select StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strContractBasis,strLocationName,strContractNumber from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		

		-------------  Sale HTA

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strContractBasis,'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Sale-HTA' +' - ' +strContractBasis,'Wt./Avg Futures',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblFutures,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Sale-HTA' +' - ' +strContractBasis,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strContractBasis,strLocationName,strContractNumber from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		

		------------------------Sale DP

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strContractBasis,'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Sale-DP' +' - ' +strContractBasis,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strContractBasis,strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strContractBasis,strLocationName,strContractNumber from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(5)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodity,'Sale Total','Sale Total',strContractEndMonth,dblBalance dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @List where strSecondSubHeading='Sale Quantity' 

END

IF @strGroupings= 'Market Zone'--strContractBasis
BEGIN

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strMarketZoneCode,''),'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
			AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)

		SELECT StrCommodity,'Purchase-Priced' +' - ' +isnull(strMarketZoneCode,''),'Wt./Avg Futures' strSubHeading,strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblFutures,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber 
		,strMarketZoneCode,strContractBasis
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,strContractBasis,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)

		SELECT StrCommodity,'Purchase-Priced' +' - ' +isnull(strMarketZoneCode,''),'Wt./Avg Basis',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblBasis,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber 
		,strMarketZoneCode,strContractBasis
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strMarketZoneCode,strContractBasis,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-Priced' +' - ' +isnull(strMarketZoneCode,''),'Wt./Avg Cash',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblCashPrice,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		,strMarketZoneCode,strContractBasis
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strContractBasis,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-Priced' +' - ' +isnull(strMarketZoneCode,''),'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
				select StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strLocationName,strContractNumber,strMarketZoneCode,strContractBasis from (
				SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				strMarketZoneCode,strContractBasis,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,strContractBasis,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		

		-----------------   Purchase Basis--------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strMarketZoneCode,''),'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)

		SELECT StrCommodity,'Purchase-Basis' +' - ' +strMarketZoneCode,'Wt./Avg Basis',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblBasis,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strContractBasis
		,strMarketZoneCode
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strContractBasis,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-Basis' +' - ' +strMarketZoneCode,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strLocationName,strContractNumber,strMarketZoneCode,strContractBasis FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,
		cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strMarketZoneCode,strContractBasis,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,strContractBasis,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		

		-------------  Purchases HTA

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strMarketZoneCode,''),'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)

		SELECT StrCommodity,'Purchase-HTA' +' - ' +strMarketZoneCode,'Wt./Avg Futures',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblFutures,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		,strMarketZoneCode,strContractBasis
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strContractBasis,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-HTA' +' - ' +strMarketZoneCode,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strLocationName,strContractNumber,strMarketZoneCode,strContractBasis from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strMarketZoneCode,strContractBasis,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,strContractBasis,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		

		------------------------Purchase DP

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strMarketZoneCode,''),'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth
		,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-DP' +' - ' +strMarketZoneCode,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strLocationName,strContractNumber,strMarketZoneCode,strContractBasis from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,
		cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strMarketZoneCode,strContractBasis,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(5)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,strContractBasis,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodity,'Purchase Total','Purchase Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth

		------------------Sale start --------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strMarketZoneCode,''),'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
			AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)

		SELECT StrCommodity,'Sale-Priced' +' - ' +strMarketZoneCode,'Wt./Avg Futures' strSubHeading,strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblFutures,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber 
		,strMarketZoneCode,strContractBasis
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strContractBasis,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)

		SELECT StrCommodity,'Sale-Priced' +' - ' +strMarketZoneCode,'Wt./Avg Basis',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblBasis,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber 
		,strMarketZoneCode,strContractBasis
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strContractBasis,strMarketZoneCode,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)
		SELECT StrCommodity,'Sale-Priced' +' - ' +strMarketZoneCode,'Wt./Avg Cash',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblCashPrice,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		,strMarketZoneCode,strContractBasis
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strContractBasis,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)
		SELECT StrCommodity,'Sale-Priced' +' - ' +strMarketZoneCode,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
				select StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strLocationName,strContractNumber,strMarketZoneCode,strContractBasis from (
				SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				strMarketZoneCode,strContractBasis,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,strContractBasis,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		

		-----------------   Purchase Basis--------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strMarketZoneCode,''),'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)

		SELECT StrCommodity,'Sale-Basis' +' - ' +strMarketZoneCode,'Wt./Avg Basis',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblBasis,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		,strMarketZoneCode,strContractBasis
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strContractBasis,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)
		SELECT StrCommodity,'Sale-Basis' +' - ' +strMarketZoneCode,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strLocationName,strContractNumber,strMarketZoneCode,strContractBasis FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,
		cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strMarketZoneCode,strContractBasis,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,strContractBasis,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		

		-------------  Purchases HTA

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strMarketZoneCode,''),'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)

		SELECT StrCommodity,'Sale-HTA' +' - ' +strMarketZoneCode,'Wt./Avg Futures',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblFutures,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strContractBasis
		,strMarketZoneCode
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strContractBasis,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)
		SELECT StrCommodity,'Sale-HTA' +' - ' +strMarketZoneCode,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strLocationName,strContractNumber,strMarketZoneCode,strContractBasis from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strMarketZoneCode,strContractBasis,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,strContractBasis,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		

		------------------------Purchase DP

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strMarketZoneCode,''),'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth
		,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber)
		SELECT StrCommodity,'Sale-DP' +' - ' +strMarketZoneCode,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strLocationName,strContractNumber,strMarketZoneCode,strContractBasis from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,
		cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strMarketZoneCode,strContractBasis,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(5)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,strContractBasis,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodity,'Sale Total','Sale Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @List where strSecondSubHeading='Sale Quantity' --group by strCommodity,strContractEndMonth

END

IF @strGroupings= 'Market Zone and Contract Terms'--strContractBasis
BEGIN

	INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strContractBasis,'') + ' - ' + isnull(strMarketZoneCode,''),'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))			
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)

		SELECT StrCommodity,'Purchase-Priced' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Futures',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblFutures,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber 
		,strMarketZoneCode
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)

		SELECT StrCommodity,'Purchase-Priced' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Basis',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblBasis,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber 
		,strMarketZoneCode
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-Priced' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Cash',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblCashPrice,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		,strMarketZoneCode
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-Priced' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
				select StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber from (
				SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strMarketZoneCode,strContractBasis,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t

		-----------------   Purchase Basis--------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strContractBasis+ ' - ' + strMarketZoneCode,'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)

		SELECT StrCommodity,'Purchase-Basis' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Basis',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblBasis,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strMarketZoneCode,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-Basis' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strMarketZoneCode,strContractBasis,strLocationName,
		cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t

		-------------  Purchases HTA

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strContractBasis+ ' - ' + strMarketZoneCode,'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)

		SELECT StrCommodity,'Purchase-HTA' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Futures',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblFutures,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strMarketZoneCode,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t


		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-HTA' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strMarketZoneCode,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t


		------------------------Purchase DP

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strContractBasis+ ' - ' + strMarketZoneCode,'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth
		,strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-DP' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strMarketZoneCode,strContractBasis,strLocationName,
		cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(5)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t


		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodity,'Purchase Total','Purchase Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @List where strSecondSubHeading='Purchase Quantity'-- group by strCommodity,strContractEndMonth

		------------------Sale start --------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strContractBasis,'') + ' - ' + isnull(strMarketZoneCode,''),'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
			AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)

		SELECT StrCommodity,'Sale-Priced' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Futures',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblFutures,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber 
		,strMarketZoneCode
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t


		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)

		SELECT StrCommodity,'Sale-Priced' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Basis',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblBasis,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber 
		,strMarketZoneCode
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t


		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Sale-Priced' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Cash',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblCashPrice,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strContractBasis,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		,strMarketZoneCode
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t


		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Sale-Priced' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
				select StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber from (
				SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strMarketZoneCode,strContractBasis,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t


		-----------------   Purchase Basis--------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strContractBasis+ ' - ' + strMarketZoneCode,'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)

		SELECT StrCommodity,'Sale-Basis' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Basis',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblBasis,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strMarketZoneCode,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t


		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Sale-Basis' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strMarketZoneCode,strContractBasis,strLocationName,
		cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t


		-------------  Purchases HTA

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strContractBasis+ ' - ' + strMarketZoneCode,'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)

		SELECT StrCommodity,'Sale-HTA' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Futures',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblFutures,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strMarketZoneCode,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
	

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Purchase-HTA' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strMarketZoneCode,strContractBasis,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t


		------------------------Purchase DP

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)

		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strContractBasis+ ' - ' + strMarketZoneCode,'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth
		,strContractBasis,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber)
		SELECT StrCommodity,'Sale-DP' +' - ' +isnull(strContractBasis,'')+ ' - ' + isnull(strMarketZoneCode,''),'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strMarketZoneCode,strContractBasis,strLocationName,strContractNumber
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strMarketZoneCode,strContractBasis,strLocationName,strContractNumber from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strMarketZoneCode,strContractBasis,strLocationName,
		cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(5)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,strContractBasis,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodity,'Sale Total','Sale Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @List where strSecondSubHeading='Sale Quantity'-- group by strCommodity,strContractEndMonth

END

IF @strGroupings= 'By Item'--strContractBasis
BEGIN

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo)

		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strItemNo,'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strItemNo
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
			AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strItemNo,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)

		SELECT StrCommodity,'Purchase-Priced' +' - ' +strItemNo,'Wt./Avg Futures' strSubHeading,strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
		SELECT strCommodityCode as [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblFutures,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber 
		,strMarketZoneCode,strItemNo,strContractBasis
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,strContractBasis,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,strItemNo)t
	

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)

		SELECT StrCommodity,'Purchase-Priced' +' - ' +strItemNo,'Wt./Avg Basis',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblBasis,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber 
		,strMarketZoneCode,strItemNo,strContractBasis
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strContractBasis,strItemNo,strMarketZoneCode,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		
	
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)
		SELECT StrCommodity,'Purchase-Priced' +' - ' +strItemNo,'Wt./Avg Cash',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblCashPrice,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		,strMarketZoneCode,strItemNo,strContractBasis
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strContractBasis,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)
		SELECT StrCommodity,'Purchase-Priced' +' - ' +strItemNo,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
				select StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strLocationName,strContractNumber,strMarketZoneCode,strItemNo,strContractBasis from (
				SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				strMarketZoneCode,strItemNo,strContractBasis,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,strContractBasis,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
	

		-----------------   Purchase Basis--------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo)

		SELECT strCommodityCode as [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strItemNo,'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strItemNo
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)

		SELECT StrCommodity,'Purchase-Basis' +' - ' +strItemNo,'Wt./Avg Basis',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblBasis,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strContractBasis
		,strMarketZoneCode,strItemNo
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strContractBasis,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)
		SELECT StrCommodity,'Purchase-Basis' +' - ' +strItemNo,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strLocationName,strContractNumber,strMarketZoneCode,strItemNo,strContractBasis FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,
		cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strMarketZoneCode,strItemNo,strContractBasis,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,strContractBasis,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
	

		-------------  Purchases HTA

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo)

		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strItemNo,'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strItemNo
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)

		SELECT StrCommodity,'Purchase-HTA' +' - ' +strItemNo,'Wt./Avg Futures',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblFutures,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strContractBasis
		,strMarketZoneCode,strItemNo
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strContractBasis,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
	

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)
		SELECT StrCommodity,'Purchase-HTA' +' - ' +strItemNo,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strLocationName,strContractNumber,strMarketZoneCode,strItemNo,strContractBasis from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strMarketZoneCode,strItemNo,strContractBasis,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,strContractBasis,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
	

		------------------------Purchase DP

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo)

		SELECT strCommodityCode as [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strItemNo,'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth
		,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strItemNo
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)
		SELECT StrCommodity,'Purchase-DP' +' - ' +strItemNo,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strLocationName,strContractNumber,strMarketZoneCode,strItemNo,strContractBasis from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,
		cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strMarketZoneCode,strItemNo,strContractBasis,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(5)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId,strContractBasis
				)t1
				)t
	

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodity,'Purchase Total','Purchase Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth

		------------------Sale start --------------

		
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo)
	
		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strItemNo,'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strItemNo
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
			AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,strContractBasis,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strItemNo,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType
	
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)

		SELECT StrCommodity,'Sale-Priced' +' - ' +strItemNo,'Wt./Avg Futures' strSubHeading,strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
		SELECT strCommodityCode as [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblFutures,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber 
		,strMarketZoneCode,strItemNo,strContractBasis
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,strContractBasis,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,strItemNo)t
	
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)

		SELECT StrCommodity,'Sale-Priced' +' - ' +strItemNo,'Wt./Avg Basis',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblBasis,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber 
		,strMarketZoneCode,strItemNo,strContractBasis
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strItemNo,strMarketZoneCode,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,strContractBasis)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)
		SELECT StrCommodity,'Sale-Priced' +' - ' +strItemNo,'Wt./Avg Cash',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
		SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblCashPrice,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		,strMarketZoneCode,strItemNo,strContractBasis
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,strContractBasis)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)
		SELECT StrCommodity,'Sale-Priced' +' - ' +strItemNo,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
				select StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strLocationName,strContractNumber,strMarketZoneCode,strItemNo,strContractBasis from (
				SELECT strCommodityCode as   [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,
				strMarketZoneCode,strItemNo,strContractBasis,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,strContractBasis,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
	

		-----------------   Sale Basis--------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo)

		SELECT strCommodityCode as [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strItemNo,'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strItemNo
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)

		SELECT StrCommodity,'Sale-Basis' +' - ' +strItemNo,'Wt./Avg Basis',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblBasis,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		,strMarketZoneCode,strItemNo,strContractBasis
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strContractBasis,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
		

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)
		SELECT StrCommodity,'Sale-Basis' +' - ' +strItemNo,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strLocationName,strContractNumber,strMarketZoneCode,strItemNo,strContractBasis FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,
		cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strMarketZoneCode,strItemNo,strContractBasis,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(2)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,strContractBasis,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
	

		-------------  Sale HTA

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo)

		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strItemNo,'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strItemNo
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)

		SELECT StrCommodity,'Sale-HTA' +' - ' +strItemNo,'Wt./Avg Futures',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)*isnull(dblFutures,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber
		,strMarketZoneCode,strItemNo,strContractBasis
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strContractBasis,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType)t
	

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)
		SELECT StrCommodity,'Sale-HTA' +' - ' +strItemNo,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strLocationName,strContractNumber,strMarketZoneCode,strItemNo,strContractBasis from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strMarketZoneCode,strItemNo,strContractBasis,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(3)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,strContractBasis,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t	

		------------------------Purchase DP

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo)

		SELECT strCommodityCode as [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strItemNo,'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth
		,sum(isnull(dblBalance,0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,strLocationName
		,cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strItemNo
		FROM vyuCTContractDetailView cd
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strLocationName,strContractNumber,strItemNo)
		SELECT StrCommodity,'Sale-DP' +' - ' +strItemNo,'Wt./Avg Freight',strContractEndMonth,(Balance)/sum(sumBalance) over (partition by strContractBasis,strContractEndMonth,strLocationName),strLocationName,strContractNumber,strItemNo
		FROM (
				SELECT StrCommodity,strContractEndMonth,(Balance) * (dblRate) Balance,(sumBalance) sumBalance,strLocationName,strContractNumber,strMarketZoneCode,strItemNo,strContractBasis from (
		SELECT strCommodityCode as    [StrCommodity],RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,sum(isnull(dblBalance,0)) Balance,sum(isnull(dblBalance,0)) sumBalance,strLocationName,
		cd.strContractNumber+' - ' + convert(nvarchar,intContractSeq) as strContractNumber,strMarketZoneCode,strItemNo,strContractBasis,
				(select sum(cv.dblRate) FROM vyuCTContractCostView cv
				JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight') dblRate	
				FROM vyuCTContractDetailView cd
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(5)
				WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
				GROUP BY strCommodityCode,strLocationName,strContractBasis,strItemNo,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strMarketZoneCode,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId
				)t1
				)t
	

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber)
		SELECT strCommodity,'Sale Total','Sale Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber from @List where strSecondSubHeading='Sale Quantity' --group by strCommodity,strContractEndMonth

END

---------------------------------- Futures

INSERT INTO @List (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,dblFuturesPrice,strContractNumber,strLocationName)
SELECT DISTINCT strCommodityCode,'Futures - Long' as strHeaderValue,'Futures - Long' as strSubHeading, 'Futures - Long' as strSecondSubHeading,strFutureMonth, 
				(intNoOfContract-isnull(intOpenContract,0))*dblContractSize intOpenContract,dblPrice,strInternalTradeNo,strLocationName FROM (
SELECT ot.intFutOptTransactionId,ot.strInternalTradeNo, sum(ot.intNoOfContract) intNoOfContract,RIGHT(CONVERT(VARCHAR(11),dtmFutureMonthsDate,106),8) strFutureMonth,ot.dblPrice ,strCommodityCode,
	   (SELECT SUM(CONVERT(int,mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf where ot.intFutOptTransactionId=mf.intLFutOptTransactionId) intOpenContract,strLocationName,dblContractSize
FROM tblRKFutOptTransaction ot 
JOIN tblRKFutureMarket m on ot.intFutureMarketId=m.intFutureMarketId
JOIN tblRKFuturesMonth fm on ot.intFutureMonthId=fm.intFutureMonthId 
JOIN tblICCommodity c on ot.intCommodityId=c.intCommodityId
JOIN tblSMCompanyLocation l on ot.intLocationId=l.intCompanyLocationId
WHERE ot.strBuySell='Buy' AND ot.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  
						  AND ot.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ',')) 
GROUP BY intFutOptTransactionId,strCommodityCode,strLocationName,strInternalTradeNo,RIGHT(CONVERT(VARCHAR(11),dtmFutureMonthsDate,106),8),dblPrice,dblContractSize) t

--- weighted avg for long
INSERT INTO @List (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,dblFuturesPrice,strContractNumber,strLocationName)

SELECT strCommodityCode,'Futures - Long' as strHeaderValue,'Futures - Long' as strSubHeading, 'Wt./Avg Price' as strSecondSubHeading,strFutureMonth,
		(ContractPrice)/sum(intOpenContract) over (partition by strFutureMonth,strLocationName)
		,dblPrice,strInternalTradeNo,strLocationName FROM(
SELECT DISTINCT strCommodityCode,strFutureMonth,
				sum(intNoOfContract-isnull(intOpenContract,0)) as intOpenContract, (intNoOfContract-isnull(intOpenContract,0)) * dblPrice ContractPrice,dblPrice,strInternalTradeNo,strLocationName FROM (
SELECT ot.intFutOptTransactionId,ot.strInternalTradeNo, sum(ot.intNoOfContract) intNoOfContract,RIGHT(CONVERT(VARCHAR(11),dtmFutureMonthsDate,106),8) strFutureMonth,ot.dblPrice ,strCommodityCode,
	   (SELECT SUM(CONVERT(int,mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf where ot.intFutOptTransactionId=mf.intLFutOptTransactionId) intOpenContract,strLocationName
FROM tblRKFutOptTransaction ot 
JOIN tblRKFuturesMonth fm on ot.intFutureMonthId=fm.intFutureMonthId 
JOIN tblICCommodity c on ot.intCommodityId=c.intCommodityId
JOIN tblSMCompanyLocation l on ot.intLocationId=l.intCompanyLocationId
WHERE ot.strBuySell='Buy' AND ot.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  
						  AND ot.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ',')) 
GROUP BY intFutOptTransactionId,strCommodityCode,strLocationName,strInternalTradeNo,RIGHT(CONVERT(VARCHAR(11),dtmFutureMonthsDate,106),8),dblPrice) t
GROUP BY strCommodityCode,strFutureMonth,dblPrice,strInternalTradeNo,strLocationName,intNoOfContract,intOpenContract
)t2
------------------ short 
INSERT INTO @List (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,dblFuturesPrice,strContractNumber,strLocationName)

SELECT DISTINCT strCommodityCode,'Futures - Short' as strHeaderValue,'Futures - Short' as strSubHeading, 'Futures - Short' as strSecondSubHeading,strFutureMonth,
				-(intNoOfContract-isnull(intOpenContract,0))*dblContractSize intOpenContract,dblPrice,strInternalTradeNo,strLocationName from (
SELECT ot.intFutOptTransactionId,ot.strInternalTradeNo, sum(ot.intNoOfContract) intNoOfContract,RIGHT(CONVERT(VARCHAR(11),dtmFutureMonthsDate,106),8) strFutureMonth,ot.dblPrice ,strCommodityCode,
	   (SELECT SUM(CONVERT(int,mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf where ot.intFutOptTransactionId=mf.intSFutOptTransactionId) intOpenContract,strLocationName,dblContractSize
FROM tblRKFutOptTransaction ot 
JOIN tblRKFutureMarket m on ot.intFutureMarketId=m.intFutureMarketId
JOIN tblRKFuturesMonth fm on ot.intFutureMonthId=fm.intFutureMonthId 
JOIN tblICCommodity c on ot.intCommodityId=c.intCommodityId
JOIN tblSMCompanyLocation l on ot.intLocationId=l.intCompanyLocationId
where ot.strBuySell='Sell' AND ot.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  
						  AND ot.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ',')) 
GROUP BY intFutOptTransactionId,strCommodityCode,strLocationName,strInternalTradeNo,RIGHT(CONVERT(VARCHAR(11),dtmFutureMonthsDate,106),8),dblPrice,dblContractSize) t
 
---- weighted avg for Short
INSERT INTO @List (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,dblFuturesPrice,strContractNumber,strLocationName)

SELECT strCommodityCode,'Futures - Short' as strHeaderValue,'Futures - Short' as strSubHeading, 'Wt./Avg Price' as strSecondSubHeading,strFutureMonth,
		(ContractPrice)/sum(intOpenContract) over (partition by strFutureMonth,strLocationName)
		,dblPrice,strInternalTradeNo,strLocationName FROM(
SELECT DISTINCT strCommodityCode,strFutureMonth,sum(intNoOfContract-isnull(intOpenContract,0)) as intOpenContract, (intNoOfContract-isnull(intOpenContract,0)) * dblPrice ContractPrice,dblPrice,strInternalTradeNo,strLocationName FROM (
SELECT ot.intFutOptTransactionId,ot.strInternalTradeNo, sum(ot.intNoOfContract) intNoOfContract,RIGHT(CONVERT(VARCHAR(11),dtmFutureMonthsDate,106),8) strFutureMonth,ot.dblPrice ,strCommodityCode,
	   (SELECT SUM(CONVERT(int,mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf where ot.intFutOptTransactionId=mf.intSFutOptTransactionId) intOpenContract,strLocationName
FROM tblRKFutOptTransaction ot 
JOIN tblRKFuturesMonth fm on ot.intFutureMonthId=fm.intFutureMonthId 
JOIN tblICCommodity c on ot.intCommodityId=c.intCommodityId
JOIN tblSMCompanyLocation l on ot.intLocationId=l.intCompanyLocationId
WHERE ot.strBuySell='Sell' AND ot.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))  
						  AND ot.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ',')) 
GROUP BY intFutOptTransactionId,strCommodityCode,strLocationName,strInternalTradeNo,RIGHT(CONVERT(VARCHAR(11),dtmFutureMonthsDate,106),8),dblPrice) t
GROUP BY strCommodityCode,strFutureMonth,dblPrice,strInternalTradeNo,strLocationName,intNoOfContract,intOpenContract
)t2
---- 
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
	 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo)
	 SELECT strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,
	 dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo FROM @List  where (CONVERT(DATETIME,'01 '+strContractEndMonth)) = (CONVERT(DATETIME,'01 '+@Month)) 
END
ELSE
BEGIN 
	 SELECT @PreviousMonth=dtmMonth from @MonthList where intRowNumber=@count -1
	 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo)
	 SELECT strCommodity,strSubHeading,strSecondSubHeading,@Month strContractEndMonth,strContractBasis,sum(isnull(dblBalance,0)),strMarketZoneCode,sum(isnull(dblFuturesPrice,0)),sum(isnull(dblBasisPrice,0)),sum(isnull(dblCashPrice,0)),strLocationName,strContractNumber,strItemNo FROM @List
	 WHERE (CONVERT(DATETIME,'01 '+strContractEndMonth)) > (CONVERT(DATETIME,'01 '+@PreviousMonth)) and (CONVERT(DATETIME,'01 '+strContractEndMonth)) <= (CONVERT(DATETIME,'01 '+@Month)) 
	 GROUP BY strCommodity,strSubHeading,strSecondSubHeading,strContractBasis,strMarketZoneCode,strLocationName,strContractNumber,strItemNo
END

SELECT @count = min(intRowNumber) from @MonthList where intRowNumber>@count 
END

DECLARE @Month1 nvarchar(50)
SELECT TOP 1 @Month1=dtmMonth from @MonthList Order by intRowNumber 
-- Previous
	 INSERT INTO @FinalList(intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo)
	 SELECT intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,'Previous' strContractEndMonth,strContractBasis,sum(isnull(dblBalance,0)),strMarketZoneCode,sum(isnull(dblFuturesPrice,0)),sum(isnull(dblBasisPrice,0)),sum(isnull(dblCashPrice,0)),strLocationName,strContractNumber,strItemNo FROM @List
	 WHERE (CONVERT(DATETIME,'01 '+strContractEndMonth)) < (CONVERT(DATETIME,'01 '+@Month1)) --and strSubHeading='Purchase Total'
	 GROUP BY intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,strContractBasis,strMarketZoneCode,strLocationName,strContractNumber,strItemNo

---- Future

DECLARE @Month2 nvarchar(50)
SELECT TOP 1 @Month2=dtmMonth from @MonthList Order by intRowNumber desc

		 INSERT INTO @FinalList(intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo)
		 SELECT intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,'Future' strContractEndMonth,strContractBasis,sum(isnull(dblBalance,0)),strMarketZoneCode,sum(isnull(dblFuturesPrice,0)),sum(isnull(dblBasisPrice,0)),sum(isnull(dblCashPrice,0)),strLocationName,strContractNumber,strItemNo FROM @List
		 WHERE (CONVERT(DATETIME,'01 '+strContractEndMonth)) > (CONVERT(DATETIME,'01 '+@Month2)) 
		 GROUP BY intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,strContractBasis,strMarketZoneCode,strLocationName,strContractNumber,strItemNo
	
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
	SELECT @dblInventoryQty=sum(dblBalance) from @FinalList  where strCommodity=@strCommodityCode AND strSubHeading='Inventory' --and strSecondSubHeading='Ownership'
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

if exists(select * from @FinalList where strContractEndMonth='Previous')
	BEGIN
		 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)
		 SELECT  strCommodity, 'Cumulative physical position',  'Cumulative physical position','Previous',dblBalance FROM @FinalList where strSubHeading='Net Physical Position' and strContractEndMonth='Previous'
    END

DECLARE @countC int
DECLARE @MonthC nvarchar(50)
DECLARE @PreviousMonthC nvarchar(50)
DECLARE @intMonthC int
select @countC= min(intRowNumber) from @MonthList
declare @previousValue numeric(24,10)
select @previousValue=sum(isnull(dblBalance,0)) from @FinalList where strSubHeading='Cumulative physical position' and strContractEndMonth='Previous'
WHILE @countC Is not null
BEGIN
SELECT @intMonthC = intRowNumber,@MonthC=dtmMonth from @MonthList where intRowNumber=@countC

IF @countC = 1
BEGIN	
	BEGIN
	
		INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)
		 SELECT  strCommodity, 'Cumulative physical position',  'Cumulative physical position',@MonthC,sum(dblBalance)+isnull(@previousValue,0) FROM @FinalList where strSubHeading='Net Physical Position' and strContractEndMonth=@MonthC
		 GROUP BY strCommodity
		
		SELECT  @previousValue=sum(dblBalance)+ isnull(@previousValue,0) FROM @FinalList where strSubHeading='Net Physical Position' and strContractEndMonth=@MonthC
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
	 strSubHeading='Net Physical Position' and strContractEndMonth<>'Future' and   strContractEndMonth<>'Previous'
	 group by strCommodity

	  SELECT @previousValue = sum(isnull(dblBalance,0))+@previousValue FROM @FinalList
	 WHERE (CONVERT(DATETIME,'01 '+strContractEndMonth)) > (CONVERT(DATETIME,'01 '+@PreviousMonthC)) and (CONVERT(DATETIME,'01 '+strContractEndMonth)) <= (CONVERT(DATETIME,'01 '+@MonthC)) and  
	 strSubHeading='Net Physical Position' and strContractEndMonth<>'Future' and   strContractEndMonth<>'Previous'
	 group by strCommodity

END

SELECT @countC = min(intRowNumber) from @MonthList where intRowNumber>@countC
END

IF EXISTS(SELECT * FROM @FinalList where strContractEndMonth='Future')
	BEGIN
		
	INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
 	SELECT strCommodity,'Cumulative physical position','Cumulative physical position',strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber from @FinalList WHERE strSubHeading='Purchase Total' and strCommodity=@strCommodityCode and strContractEndMonth='Future'

	INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber)
 	SELECT strCommodity,'Cumulative physical position','Cumulative physical position',strContractEndMonth,-dblBalance,strContractBasis,strLocationName,strContractNumber from @FinalList WHERE strSubHeading='Sale Total' and strCommodity=@strCommodityCode and strContractEndMonth='Future'

	INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)
 	SELECT @strCommodityCode,'Cumulative physical position','Cumulative physical position','Future',isnull(@previousValue,0)

    END
	 --intOrderByOne,	 intOrderByTwo 
--select * from @FinalList  intOrderByOne


DELETE @List
INSERT INTO @List(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo FROM  @FinalList Where strContractEndMonth='Inventory'
INSERT INTO @List(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo FROM  @FinalList Where strContractEndMonth='Previous'
INSERT INTO @List(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo)
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo FROM @FinalList Where strContractEndMonth NOT IN('Previous','Future','Inventory') ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)
INSERT INTO @List(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo)
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,strItemNo FROM @FinalList Where strContractEndMonth='Future'


update @List set intOrderByOne=1  Where strSubHeading='Inventory' 
update @List set intOrderByOne=2  Where strSubHeading like '%Purchase-Priced%'
update @List set intOrderByOne=3  Where strSubHeading like '%Purchase-Basis%'
update @List set intOrderByOne=4  Where strSubHeading like '%Purchase-HTA%'
update @List set intOrderByOne=5  Where strSubHeading like '%Purchase-DP%'
update @List set intOrderByOne=6  Where strSubHeading = 'Purchase Total'

update @List set intOrderByOne=7  Where strSubHeading like '%Sale-Priced%'
update @List set intOrderByOne=8  Where strSubHeading like '%Sale-Basis%'
update @List set intOrderByOne=9  Where strSubHeading like '%Sale-HTA%'
update @List set intOrderByOne=10  Where strSubHeading like '%Sale-DP%'
update @List set intOrderByOne=11  Where strSubHeading = 'Sale Total'

update @List set intOrderByOne=12  Where strSubHeading = 'Net Physical Position'
update @List set intOrderByOne=13  Where strSubHeading = 'Cumulative physical position'
update @List set intOrderByOne=14  Where strSubHeading = 'Futures - Long'
update @List set intOrderByOne=15  Where strSubHeading = 'Futures - Short'
update @List set intOrderByOne=16  Where strSubHeading = 'Net Futures'

update @List set intOrderByOne=17  Where strSubHeading = 'Cash Exposure'
update @List set intOrderByOne=18  Where strSubHeading = 'Basis Exposure'
UPDATE @List set dblBalance = null where dblBalance = 0 

SELECT * FROM @List where dblBalance IS NOT NULL order by strCommodity,intOrderByOne

