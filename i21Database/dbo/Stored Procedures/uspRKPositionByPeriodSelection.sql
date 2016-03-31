﻿CREATE PROC uspRKPositionByPeriodSelection 
	@intCommodityId NVARCHAR(max) ,
	@intCompanyLocationId NVARCHAR(max) ,
	@intQuantityUOMId int,
	@strGroupings NVARCHAR(100) = '',
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
	@dtmDate12 datetime = null,
	@ysnSummary bit = null
AS

DECLARE @MonthList as TABLE (  
     intRowNumber INT, 
	 dtmMonth NVARCHAR(15))

	INSERT INTO @MonthList
	SELECT intRowNumber,dtmMonth from(
			SELECT 1 AS intRowNumber, RIGHT(CONVERT(VARCHAR(11),@dtmDate1,106),8) dtmMonth
			UNION 
			SELECT 2 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate2,106),8) dtmMonth 
			UNION 
			SELECT 3 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate3,106),8) dtmMonth
			UNION 
			SELECT 4 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate4,106),8) dtmMonth
			UNION 
			SELECT 5 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate5,106),8) dtmMonth
			UNION 
			SELECT 6 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate6,106),8) dtmMonth
			UNION 
			SELECT 7 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate7,106),8) dtmMonth
			UNION 
			SELECT 8 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate8,106),8) dtmMonth
			UNION 
			SELECT 9 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate9,106),8) dtmMonth
			UNION 
			SELECT 10 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate10,106),8) dtmMonth
			UNION
			SELECT 11 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate11,106),8) dtmMonth
			UNION
			SELECT 12 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate12,106),8) dtmMonth
	)t

	DELETE FROM @MonthList where dtmMonth IS NULL

	DECLARE @MaxDate Datetime 
	DECLARE @intCurrencyId INT
	DECLARE @strCurrencyName nvarchar(max)
	SELECT  TOP 1 @MaxDate=CONVERT(DATETIME,'01 '+dtmMonth) from @MonthList order by intRowNumber desc
	select @intCurrencyId=intCurrencyId from tblRKCompanyPreference
	select top 1 @strCurrencyName=strCurrency from tblSMCurrency where intCurrencyID =@intCurrencyId

	 DECLARE @List AS TABLE (  
     intRowNumber INT IDENTITY(1,1) PRIMARY KEY , 
	 strCommodity  NVARCHAR(200),
	 strHeaderValue NVARCHAR(200),  
     strSubHeading  NVARCHAR(200),  
	 strSecondSubHeading NVARCHAR(200),
     strContractEndMonth  NVARCHAR(100),  
     strContractBasis  NVARCHAR(200),  
     dblBalance  DECIMAL(24,10),  
     strMarketZoneCode  NVARCHAR(200),  
     dblFuturesPrice  DECIMAL(24,10),
     dblBasisPrice DECIMAL(24,10),  
     dblCashPrice DECIMAL(24,10),       
     dblWtAvgPriced DECIMAL(24,10),  
     dblQuantity DECIMAL(24,10),
	 strLocationName NVARCHAR(200),
	 strContractNumber NVARCHAR(200),
	 strItemNo NVARCHAR(200),
	 intOrderByOne INT,
	 intOrderByTwo INT,
	 dblRate  DECIMAL(24,10),
	 ExRate DECIMAL(24,10),
	 strCurrencyExchangeRateType NVARCHAR(200),
	 intContractHeaderId int ,
	 intFutOptTransactionHeaderId int	  
	 )   

	 DECLARE @FinalList AS TABLE (  
     intRowNumber INT , 
	 strCommodity  NVARCHAR(200),  
	 strHeaderValue NVARCHAR(200),
     strSubHeading  NVARCHAR(200),  
	 strSecondSubHeading NVARCHAR(200),
     strContractEndMonth  NVARCHAR(100),  
     strContractBasis  NVARCHAR(200),  
     dblBalance  DECIMAL(24,10),  
     strMarketZoneCode  NVARCHAR(200),  
     dblFuturesPrice  DECIMAL(24,10),
     dblBasisPrice DECIMAL(24,10),  
     dblCashPrice DECIMAL(24,10),       
     dblWtAvgPriced DECIMAL(24,10),  
     dblQuantity DECIMAL(24,10),
	 strLocationName NVARCHAR(200),
	 strContractNumber NVARCHAR(200),
	 strItemNo NVARCHAR(200),
	 intOrderByOne INT,
	 intOrderByTwo INT,
	 dblRate  DECIMAL(24,10),
	 ExRate DECIMAL(24,10),
	 strCurrencyExchangeRateType NVARCHAR(200),
	 intContractHeaderId int ,
	 intFutOptTransactionHeaderId int	        
     )   

	 DECLARE @Commodity AS TABLE 
	 (	intCommodityIdentity INT IDENTITY(1,1) PRIMARY KEY, 
		intCommodity  INT
	 )
	 INSERT INTO @Commodity(intCommodity)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  



DECLARE @countC1 INT = null
DECLARE @MonthC1 NVARCHAR(50)= null
DECLARE @PreviousMonthC1 NVARCHAR(50)= null
DECLARE @intMonthC1 INT= null
DECLARE @PreviousMonthQumPosition1 numeric(24,10)= null
SELECT @countC1= min(intRowNumber) from @MonthList

DECLARE @MaxMonth NVARCHAR(50) = null
SELECT TOP 1 @MaxMonth=dtmMonth from @MonthList Order by intRowNumber desc

-- Priced Contract	
IF @strGroupings= 'Contract Terms'
BEGIN

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)

		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strContractBasis,''),'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblBalance,0)),0)) Balance,strMarketZoneCode,isnull(dblFutures,0),isnull(dblBasis,0),isnull(dblCashPrice,0),
		isnull((SELECT sum(cv.dblRate) FROM vyuCTContractCostView cv
					JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight'),0) dblRate,	
		strLocationName,cd.strContractNumber+' - ' + convert(NVARCHAR,intContractSeq) as strContractNumber,
		(
		SELECT case WHEN (@intCurrencyId <> c1.intCurrencyID and @intCurrencyId <> c.intCurrencyID) then null
					 when @intCurrencyId = c1.intCurrencyID Then 1/isnull(cd1.dblRate,1) 
					 else isnull(cd1.dblRate,0) end
		FROM tblCTContractDetail cd1
		JOIN tblSMCurrencyExchangeRate et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateId
		JOIN tblSMCurrency c on et.intFromCurrencyId=c.intCurrencyID
		JOIN tblSMCurrency c1 on et.intToCurrencyId=c1.intCurrencyID
		WHERE cd.intContractDetailId=cd1.intContractDetailId
		) AS ExRate,
		(
		SELECT strCurrencyExchangeRateType
		FROM tblCTContractDetail cd1
		JOIN tblSMCurrencyExchangeRate et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateId
		JOIN tblSMCurrencyExchangeRateType et1 on cd1.intCurrencyExchangeRateId=et1.intCurrencyExchangeRateTypeId
		WHERE cd.intContractDetailId=cd1.intContractDetailId
		) AS strCurrencyExchangeRateType,CH.intContractHeaderId,null intFutOptTransactionHeaderId
		FROM vyuCTContractDetailView cd
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=cd.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1,2,3,5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  
		AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId,CH.intContractHeaderId

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodity,'Purchase Total','Purchase Total',strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth
		

		------------------Sale start --------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodityCode as    [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strContractBasis,''),'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblBalance,0)),0)) Balance,strMarketZoneCode,isnull(dblFutures,0),isnull(dblBasis,0),isnull(dblCashPrice,0),
		isnull((SELECT sum(cv.dblRate) FROM vyuCTContractCostView cv
					JOIN tblICItem i ON cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight'),0) dblRate	
		,strLocationName
		,cd.strContractNumber+' - ' + convert(NVARCHAR,intContractSeq) as strContractNumber,
		(
		SELECT case WHEN (@intCurrencyId <> c1.intCurrencyID and @intCurrencyId <> c.intCurrencyID) then null
					 when @intCurrencyId = c1.intCurrencyID Then 1/isnull(cd1.dblRate,1) 
					 else isnull(cd1.dblRate,0) end
		FROM tblCTContractDetail cd1
		JOIN tblSMCurrencyExchangeRate et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateId
		JOIN tblSMCurrency c on et.intFromCurrencyId=c.intCurrencyID
		JOIN tblSMCurrency c1 on et.intToCurrencyId=c1.intCurrencyID
		WHERE cd.intContractDetailId=cd1.intContractDetailId
		) AS ExRate,
		(
		SELECT strCurrencyExchangeRateType
		FROM tblCTContractDetail cd1
		JOIN tblSMCurrencyExchangeRateType et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateTypeId
		WHERE cd.intContractDetailId=cd1.intContractDetailId
		) AS strCurrencyExchangeRateType,CH.intContractHeaderId,null intFutOptTransactionHeaderId
		FROM vyuCTContractDetailView cd
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=cd.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1,2,3,5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId,strLocationName,CH.intContractHeaderId
	
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodity,'Sale Total','Sale Total',strContractEndMonth,dblBalance dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from @List where strSecondSubHeading='Sale Quantity' 
	
END

IF @strGroupings= 'Market Zone'
BEGIN
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strMarketZoneCode,''),'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblBalance,0)),0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,
				isnull((SELECT sum(cv.dblRate) FROM vyuCTContractCostView cv
					JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight'),0) dblRate,	
		strLocationName,cd.strContractNumber+' - ' + convert(NVARCHAR,intContractSeq) as strContractNumber,
		(
		SELECT case WHEN (@intCurrencyId <> c1.intCurrencyID and @intCurrencyId <> c.intCurrencyID) then null
					 when @intCurrencyId = c1.intCurrencyID Then 1/isnull(cd1.dblRate,1) 
					 else isnull(cd1.dblRate,0) end
		FROM tblCTContractDetail cd1
		JOIN tblSMCurrencyExchangeRate et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateId
		JOIN tblSMCurrency c on et.intFromCurrencyId=c.intCurrencyID
		JOIN tblSMCurrency c1 on et.intToCurrencyId=c1.intCurrencyID
		WHERE cd.intContractDetailId=cd1.intContractDetailId
		) AS ExRate,
		(
		SELECT strCurrencyExchangeRateType
		FROM tblCTContractDetail cd1
		JOIN tblSMCurrencyExchangeRateType et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateTypeId
		WHERE cd.intContractDetailId=cd1.intContractDetailId
		) AS strCurrencyExchangeRateType
		,CH.intContractHeaderId,null intFutOptTransactionHeaderId
		FROM vyuCTContractDetailView cd
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=cd.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId  in(1,2,3,5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  
		AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblRate,dblFutures,dblBasis,dblCashPrice,dblRate,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId,CH.intContractHeaderId
		
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType)
		SELECT strCommodity,'Purchase Total','Purchase Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth

		------------------Sale start --------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strMarketZoneCode,''),'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblBalance,0)),0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,
		isnull((SELECT sum(cv.dblRate) FROM vyuCTContractCostView cv
					JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight'),0) dblRate,
		strLocationName,cd.strContractNumber+' - ' + convert(NVARCHAR,intContractSeq) as strContractNumber,
		(
		SELECT case WHEN (@intCurrencyId <> c1.intCurrencyID and @intCurrencyId <> c.intCurrencyID) then null
					 when @intCurrencyId = c1.intCurrencyID Then 1/isnull(cd1.dblRate,1) 
					 else isnull(cd1.dblRate,0) end
		FROM tblCTContractDetail cd1
		JOIN tblSMCurrencyExchangeRate et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateId
		JOIN tblSMCurrency c on et.intFromCurrencyId=c.intCurrencyID
		JOIN tblSMCurrency c1 on et.intToCurrencyId=c1.intCurrencyID
		WHERE cd.intContractDetailId=cd1.intContractDetailId
		) AS ExRate,
		(
		SELECT strCurrencyExchangeRateType
		FROM tblCTContractDetail cd1
		JOIN tblSMCurrencyExchangeRateType et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateTypeId
		WHERE cd.intContractDetailId=cd1.intContractDetailId
		) AS strCurrencyExchangeRateType
		,CH.intContractHeaderId,null intFutOptTransactionHeaderId
		FROM vyuCTContractDetailView cd
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=cd.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId  in(1,2,3,5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
			AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,dblRate,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId,CH.intContractHeaderId

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodity,'Sale Total','Sale Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from @List where strSecondSubHeading='Sale Quantity' --group by strCommodity,strContractEndMonth
END

IF @strGroupings= 'Market Zone and Contract Terms'
BEGIN
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)

		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strContractBasis,'') + ' - ' + isnull(strMarketZoneCode,''),'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblBalance,0)),0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,
		isnull((SELECT sum(cv.dblRate) FROM vyuCTContractCostView cv
					JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight'),0) dblRate,
		strLocationName,cd.strContractNumber+' - ' + convert(NVARCHAR,intContractSeq) as strContractNumber,
		(
		SELECT case WHEN (@intCurrencyId <> c1.intCurrencyID and @intCurrencyId <> c.intCurrencyID) then null
					 when @intCurrencyId = c1.intCurrencyID Then 1/isnull(cd1.dblRate,1) 
					 else isnull(cd1.dblRate,0) end
		FROM tblCTContractDetail cd1
		JOIN tblSMCurrencyExchangeRate et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateId
		JOIN tblSMCurrency c on et.intFromCurrencyId=c.intCurrencyID
		JOIN tblSMCurrency c1 on et.intToCurrencyId=c1.intCurrencyID
		WHERE cd.intContractDetailId=cd1.intContractDetailId
		) AS ExRate,
		(
		SELECT strCurrencyExchangeRateType
		FROM tblCTContractDetail cd1
		JOIN tblSMCurrencyExchangeRateType et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateTypeId
		WHERE cd.intContractDetailId=cd1.intContractDetailId
		) AS strCurrencyExchangeRateType
		,CH.intContractHeaderId,null intFutOptTransactionHeaderId
		FROM vyuCTContractDetailView cd
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=cd.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1,2,3,5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))			
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,dblRate,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId,CH.intContractHeaderId
				
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodity,'Purchase Total','Purchase Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from @List where strSecondSubHeading='Purchase Quantity'-- group by strCommodity,strContractEndMonth

		------------------Sale start --------------

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strContractBasis,'') + ' - ' + isnull(strMarketZoneCode,''),'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblBalance,0)),0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,
		isnull((SELECT sum(cv.dblRate) FROM vyuCTContractCostView cv
					JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight'),0) dblRate,
		strLocationName,cd.strContractNumber+' - ' + convert(NVARCHAR,intContractSeq) as strContractNumber,
		(
		SELECT case WHEN (@intCurrencyId <> c1.intCurrencyID and @intCurrencyId <> c.intCurrencyID) then null
					 when @intCurrencyId = c1.intCurrencyID Then 1/isnull(cd1.dblRate,1) 
					 else isnull(cd1.dblRate,0) end
		FROM tblCTContractDetail cd1
		JOIN tblSMCurrencyExchangeRate et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateId
		JOIN tblSMCurrency c on et.intFromCurrencyId=c.intCurrencyID
		JOIN tblSMCurrency c1 on et.intToCurrencyId=c1.intCurrencyID
		WHERE cd.intContractDetailId=cd1.intContractDetailId
		) AS ExRate,
		(
		SELECT strCurrencyExchangeRateType
		FROM tblCTContractDetail cd1
		JOIN tblSMCurrencyExchangeRateType et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateTypeId
		WHERE cd.intContractDetailId=cd1.intContractDetailId
		) AS strCurrencyExchangeRateType
		,CH.intContractHeaderId,null intFutOptTransactionHeaderId
		FROM vyuCTContractDetailView cd
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=cd.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1,2,3,5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
			AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strContractBasis,dblFutures,dblBasis,dblCashPrice,dblRate,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId,CH.intContractHeaderId
				
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodity,'Sale Total','Sale Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from @List where strSecondSubHeading='Sale Quantity'-- group by strCommodity,strContractEndMonth

END

IF @strGroupings= 'By Item' 
BEGIN
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strItemNo,'Purchase Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblBalance,0)),0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,
		isnull((SELECT sum(cv.dblRate) FROM vyuCTContractCostView cv
					JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight'),0) dblRate,
		strLocationName,cd.strContractNumber+' - ' + convert(NVARCHAR,intContractSeq) as strContractNumber,strItemNo,
		(
		SELECT case WHEN (@intCurrencyId <> c1.intCurrencyID and @intCurrencyId <> c.intCurrencyID) then null
					 when @intCurrencyId = c1.intCurrencyID Then 1/isnull(cd1.dblRate,1) 
					 else isnull(cd1.dblRate,0) end
		FROM tblCTContractDetail cd1
		JOIN tblSMCurrencyExchangeRate et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateId
		JOIN tblSMCurrency c on et.intFromCurrencyId=c.intCurrencyID
		JOIN tblSMCurrency c1 on et.intToCurrencyId=c1.intCurrencyID
		WHERE cd.intContractDetailId=cd1.intContractDetailId
		) AS ExRate,
		(
		SELECT strCurrencyExchangeRateType
		FROM tblCTContractDetail cd1
		JOIN tblSMCurrencyExchangeRateType et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateTypeId
		WHERE cd.intContractDetailId=cd1.intContractDetailId
		) AS strCurrencyExchangeRateType
		,CH.intContractHeaderId,null intFutOptTransactionHeaderId
		FROM vyuCTContractDetailView cd
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=cd.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 1
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1,2,3,5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
			AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strItemNo,dblFutures,dblBasis,dblCashPrice,dblRate,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId,CH.intContractHeaderId

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodity,'Purchase Total','Purchase Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth

		------------------Sale start --------------
		
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
	
		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strItemNo,'Sale Quantity',RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblBalance,0)),0)) Balance,strMarketZoneCode,dblFutures,dblBasis,dblCashPrice,
		isnull((SELECT sum(cv.dblRate) FROM vyuCTContractCostView cv
					JOIN tblICItem i on cv.intItemId=i.intItemId WHERE cd.intContractDetailId=cv.intContractDetailId and strCostType='Freight'),0) dblRate,
		strLocationName,cd.strContractNumber+' - ' + convert(NVARCHAR,intContractSeq) as strContractNumber,strItemNo,
		(
		SELECT case WHEN (@intCurrencyId <> c1.intCurrencyID and @intCurrencyId <> c.intCurrencyID) then null
					 when @intCurrencyId = c1.intCurrencyID Then 1/isnull(cd1.dblRate,1) 
					 else isnull(cd1.dblRate,0) end
		FROM tblCTContractDetail cd1
		JOIN tblSMCurrencyExchangeRate et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateId
		JOIN tblSMCurrency c on et.intFromCurrencyId=c.intCurrencyID
		JOIN tblSMCurrency c1 on et.intToCurrencyId=c1.intCurrencyID
		WHERE cd.intContractDetailId=cd1.intContractDetailId
		) AS ExRate,
		(
		SELECT strCurrencyExchangeRateType
		FROM tblCTContractDetail cd1
		JOIN tblSMCurrencyExchangeRateType et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateTypeId
		WHERE cd.intContractDetailId=cd1.intContractDetailId
		) AS strCurrencyExchangeRateType
		,CH.intContractHeaderId,null intFutOptTransactionHeaderId
		FROM vyuCTContractDetailView cd
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=cd.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId AND CH.intContractTypeId = 2
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1,2,3,5)
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
			AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,strContractBasis,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,strMarketZoneCode,strItemNo,dblFutures,dblBasis,dblCashPrice,dblRate,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,intContractDetailId,CH.intContractHeaderId
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodity,'Sale Total','Sale Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from @List where strSecondSubHeading='Sale Quantity' --group by strCommodity,strContractEndMonth

END

----------------------- Futures

INSERT INTO @List (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,dblFuturesPrice,strContractNumber,strLocationName,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT DISTINCT strCommodityCode,'Futures - Long' as strHeaderValue,'Futures - Long' as strSubHeading, 'Futures - Long' as strSecondSubHeading,strFutureMonth, 
				(intNoOfContract-isnull(intOpenContract,0))*dblContractSize intOpenContract,dblPrice,strInternalTradeNo,strLocationName,intContractHeaderId,intFutOptTransactionHeaderId FROM (
SELECT ot.intFutOptTransactionId,ot.strInternalTradeNo, sum(ot.intNoOfContract) intNoOfContract,RIGHT(CONVERT(VARCHAR(11),dtmFutureMonthsDate,106),8) strFutureMonth,ot.dblPrice ,strCommodityCode,
	   (SELECT SUM(CONVERT(INT,mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf where ot.intFutOptTransactionId=mf.intLFutOptTransactionId) intOpenContract,strLocationName,dblContractSize
	   ,null as intContractHeaderId,ot.intFutOptTransactionHeaderId
FROM tblRKFutOptTransaction ot 
JOIN tblRKFutureMarket m on ot.intFutureMarketId=m.intFutureMarketId
JOIN tblRKFuturesMonth fm on ot.intFutureMonthId=fm.intFutureMonthId and ysnExpired=0
JOIN tblICCommodity c on ot.intCommodityId=c.intCommodityId
JOIN tblSMCompanyLocation l on ot.intLocationId=l.intCompanyLocationId
WHERE ot.strBuySell='Buy' AND ot.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))   
						  AND ot.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ',')) 
GROUP BY intFutOptTransactionId,strCommodityCode,strLocationName,strInternalTradeNo,RIGHT(CONVERT(VARCHAR(11),dtmFutureMonthsDate,106),8),dblPrice,dblContractSize,ot.intFutOptTransactionHeaderId
) t

------------------ short 
INSERT INTO @List (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,dblFuturesPrice,strContractNumber,strLocationName   ,intContractHeaderId,intFutOptTransactionHeaderId)

SELECT DISTINCT strCommodityCode,'Futures - Short' as strHeaderValue,'Futures - Short' as strSubHeading, 'Futures - Short' as strSecondSubHeading,strFutureMonth,
				-(intNoOfContract-isnull(intOpenContract,0))*dblContractSize intOpenContract,dblPrice,strInternalTradeNo,strLocationName,intContractHeaderId,intFutOptTransactionHeaderId from (
SELECT ot.intFutOptTransactionId,ot.strInternalTradeNo, sum(ot.intNoOfContract) intNoOfContract,RIGHT(CONVERT(VARCHAR(11),dtmFutureMonthsDate,106),8) strFutureMonth,ot.dblPrice ,strCommodityCode,
	   (SELECT SUM(CONVERT(INT,mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf where ot.intFutOptTransactionId=mf.intSFutOptTransactionId) intOpenContract,strLocationName,dblContractSize
,null intContractHeaderId,ot.intFutOptTransactionHeaderId
FROM tblRKFutOptTransaction ot 
JOIN tblRKFutureMarket m on ot.intFutureMarketId=m.intFutureMarketId
JOIN tblRKFuturesMonth fm on ot.intFutureMonthId=fm.intFutureMonthId and fm.ysnExpired=0
JOIN tblICCommodity c on ot.intCommodityId=c.intCommodityId
JOIN tblSMCompanyLocation l on ot.intLocationId=l.intCompanyLocationId
where ot.strBuySell='Sell' AND ot.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))   
						  AND ot.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ',')) 
GROUP BY intFutOptTransactionId,strCommodityCode,strLocationName,strInternalTradeNo,RIGHT(CONVERT(VARCHAR(11),dtmFutureMonthsDate,106),8),dblPrice,dblContractSize,ot.intFutOptTransactionHeaderId) t
 
-- Net Futures
INSERT INTO @List (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractNumber,strLocationName,intContractHeaderId,intFutOptTransactionHeaderId)

SELECT strCommodity,'Net Futures','Net Futures','Net Futures',strContractEndMonth,dblBalance,strContractNumber,strLocationName,intContractHeaderId,intFutOptTransactionHeaderId FROM  @List 
		WHERE strHeaderValue='Futures - Long' and strHeaderValue='Futures - Long' and strSecondSubHeading='Futures - Long'
UNION
SELECT strCommodity,'Net Futures','Net Futures','Net Futures',strContractEndMonth,dblBalance,strContractNumber,strLocationName,intContractHeaderId,intFutOptTransactionHeaderId FROM  @List 
		WHERE strHeaderValue='Futures - Short' and strHeaderValue='Futures - Short' and strSecondSubHeading='Futures - Short'

---Previous

DECLARE @count INT
DECLARE @Month NVARCHAR(50)
DECLARE @PreviousMonth NVARCHAR(50)
DECLARE @intMonth INT
SELECT @count= min(intRowNumber) from @MonthList

WHILE @count Is not null
BEGIN
SELECT @intMonth = intRowNumber,@Month=dtmMonth from @MonthList where intRowNumber=@count
IF @count = 1
BEGIN

	 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
	 SELECT strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,
	 dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
	 FROM @List WHERE (CONVERT(DATETIME,'01 '+strContractEndMonth)) = (CONVERT(DATETIME,'01 '+@Month)) 
END
ELSE
BEGIN 

	 SELECT @PreviousMonth=dtmMonth from @MonthList where intRowNumber=@count -1
	 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
	 SELECT strCommodity,strSubHeading,strSecondSubHeading,@Month strContractEndMonth,strContractBasis,sum(isnull(dblBalance,0)),strMarketZoneCode,sum(isnull(dblFuturesPrice,0)),sum(isnull(dblBasisPrice,0)),sum(isnull(dblCashPrice,0)),dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM @List
	 WHERE (CONVERT(DATETIME,'01 '+strContractEndMonth)) > (CONVERT(DATETIME,'01 '+@PreviousMonth)) and (CONVERT(DATETIME,'01 '+strContractEndMonth)) <= (CONVERT(DATETIME,'01 '+@Month)) 
	 GROUP BY strCommodity,strSubHeading,strSecondSubHeading,strContractBasis,strMarketZoneCode,dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId

END

SELECT @count = min(intRowNumber) from @MonthList where intRowNumber>@count 
END

DECLARE @Month1 NVARCHAR(50)
SELECT TOP 1 @Month1=dtmMonth from @MonthList Order by intRowNumber 
-- Previous
	 INSERT INTO @FinalList(intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
	 SELECT intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,'Previous' strContractEndMonth,strContractBasis,sum(isnull(dblBalance,0)),strMarketZoneCode,sum(isnull(dblFuturesPrice,0)),sum(isnull(dblBasisPrice,0)),sum(isnull(dblCashPrice,0)),dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM @List
	 WHERE (CONVERT(DATETIME,'01 '+strContractEndMonth)) < (CONVERT(DATETIME,'01 '+@Month1))
	 GROUP BY intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,strContractBasis,strMarketZoneCode,dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId

---- Future

DECLARE @Month2 NVARCHAR(50)
SELECT TOP 1 @Month2=dtmMonth from @MonthList Order by intRowNumber desc

		 INSERT INTO @FinalList(intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		 SELECT intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,'Future' strContractEndMonth,strContractBasis,sum(isnull(dblBalance,0)),strMarketZoneCode,sum(isnull(dblFuturesPrice,0)),sum(isnull(dblBasisPrice,0)),sum(isnull(dblCashPrice,0)),dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM @List
		 WHERE (CONVERT(DATETIME,'01 '+strContractEndMonth)) > (CONVERT(DATETIME,'01 '+@Month2)) 
		 GROUP BY intRowNumber,strCommodity,strSubHeading,strSecondSubHeading,strContractBasis,strMarketZoneCode,dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId
	
------ Pulling from header details...

DECLARE @strCommodityh NVARCHAR(100)
DECLARE @intCommodityIdentityh INT
declare @intCommodityIdh INT
DECLARE @intMinRowNumberh INT


SELECT @intCommodityIdentityh= min(intCommodityIdentity) from @Commodity
WHILE @intCommodityIdentityh >0
BEGIN
	SELECT @intCommodityIdh =intCommodity FROM @Commodity where intCommodityIdentity=@intCommodityIdentityh
	  IF @intCommodityIdh >0
	  BEGIN
		  INSERT INTO @FinalList(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)	  
		  EXEC uspRKPositionByPeriodSelectionHeader @intCommodityIdh,@intCompanyLocationId,@intQuantityUOMId
	  END
SELECT @intCommodityIdentityh= min(intCommodityIdentity) FROM @Commodity WHERE intCommodityIdentity > @intCommodityIdentityh
END
-------

DECLARE @strCommodity NVARCHAR(100)
DECLARE @intCommodityIdentity INT
DECLARE @intMinRowNumber INT
DECLARE @dblInventoryQty numeric(24,10)=0
declare @strCommodityCode NVARCHAR(500)
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
			DECLARE @MonthPurTot NVARCHAR(50)
			
			SELECT TOP 1 @MonthPurTot=dtmMonth from @MonthList m
			JOIN @FinalList f on f.strContractEndMonth=m.dtmMonth and f.dblBalance is not null  Order by m.intRowNumber 
			
		if @MonthPurTot is not null
		BEGIN
			 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId)
 			 SELECT @strCommodityCode,'Purchase Total','Purchase Total',@MonthPurTot,@dblInventoryQty,'' strContractBasis,'' strLocationName,'' strContractNumber,null intContractHeaderId,null intFutOptTransactionHeaderId --from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth

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
			 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId)
 			 SELECT @strCommodityCode,'Purchase Total','Purchase Total','Future',@dblInventoryQty,'' strContractBasis,'' strLocationName,'' strContractNumber,null intContractHeaderId,null intFutOptTransactionHeaderId --from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth

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
		    INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId)
 			 SELECT @strCommodityCode,'Net Physical Position','Net Physical Position',strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId from @FinalList WHERE strSubHeading='Purchase Total' and strCommodity=@strCommodityCode

		 	 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId)
 			 SELECT @strCommodityCode,'Net Physical Position','Net Physical Position',strContractEndMonth,-dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId from @FinalList WHERE strSubHeading='Sale Total' and strCommodity=@strCommodityCode

			 ---- case exposure

			  INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId)
			   SELECT strCommodity,'Cash Exposure','Cash Exposure',strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Purchase-Priced%' and strSecondSubHeading='Purchase Quantity' and strContractEndMonth <> 'Previous'
			  UNION
			  	   SELECT strCommodity,'Cash Exposure','Cash Exposure',strContractEndMonth,-dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Sale-Priced%' and strSecondSubHeading='Sale Quantity' and strContractEndMonth <> 'Previous'

			 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId)
				SELECT strCommodity,'Cash Exposure','Cash Exposure',strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Purchase-HTA%' and strSecondSubHeading='Purchase Quantity' and strContractEndMonth <> 'Previous'
				UNION
				SELECT strCommodity,'Cash Exposure','Cash Exposure',strContractEndMonth,-dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Sale-HTA%' and strSecondSubHeading='Sale Quantity' and strContractEndMonth <> 'Previous'
				
				 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId)
					SELECT strCommodity,'Cash Exposure','Cash Exposure',strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId FROM @FinalList 
						WHERE strCommodity= @strCommodityCode and strSubHeading ='Net Futures' and strSecondSubHeading='Net Futures' and strContractEndMonth <> 'Previous'	

			----- Basis Exposure
				INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId)
			   SELECT strCommodity,'Basis Exposure','Basis Exposure',strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Purchase-Priced%' and strSecondSubHeading='Purchase Quantity' and strContractEndMonth<> 'Previous'
			   UNION
			   SELECT strCommodity,'Basis Exposure','Basis Exposure',strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Purchase-Basis%' and strSecondSubHeading='Purchase Quantity' and strContractEndMonth<> 'Previous'
				UNION

				SELECT strCommodity,'Basis Exposure','Basis Exposure',strContractEndMonth,-dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId FROM @FinalList 
				WHERE strCommodity= @strCommodityCode and strSubHeading like '%Sale-Priced%' and strSecondSubHeading='Sale Quantity' and strContractEndMonth<> 'Previous'
			   UNION
			   SELECT strCommodity,'Basis Exposure','Basis Exposure',strContractEndMonth,-dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId FROM @FinalList 
					WHERE strCommodity= @strCommodityCode and strSubHeading like '%Sale-Basis%' and strSecondSubHeading='Sale Quantity' and strContractEndMonth<> 'Previous'
   END
SELECT @intCommodityIdentity= min(intCommodityIdentity) from @Commodity Where intCommodityIdentity > @intCommodityIdentity
END

----------------------  DONE FOR ALL..........

----------Cumulative Calculation

DECLARE @strCommodityCumulative NVARCHAR(100)
DECLARE @intCommodityIdentityCumulative INT
declare @intCommodityIdCumulative INT
DECLARE @intMinRowNumberCumulative INT

SELECT @intCommodityIdentityCumulative= min(intCommodityIdentity) from @Commodity
WHILE @intCommodityIdentityCumulative >0
BEGIN
	SELECT @intCommodityIdCumulative =intCommodity FROM @Commodity WHERE intCommodityIdentity=@intCommodityIdentityCumulative
	SELECT @strCommodityCumulative=strCommodityCode FROM tblICCommodity WHERE intCommodityId=@intCommodityIdCumulative
	  IF @intCommodityIdCumulative >0
BEGIN

----------Wt Avg --------------
INSERT INTO @FinalList (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)

SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Price' as strSecondSubHeading,strContractEndMonth,
		dblBalance*dblFuturesPrice / sum(dblBalance) over (partition by strCommodity,strContractEndMonth,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSubHeading ='Futures - Long' OR  strSubHeading ='Futures - Short')  and strCommodity= @strCommodityCumulative
)t 


---------RK Module 
INSERT INTO @FinalList (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)

SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Futures' as strSecondSubHeading,strContractEndMonth,
		dblBalance*dblFuturesPrice / sum(dblBalance) over (partition by strCommodity,strContractEndMonth,strSecondSubHeading,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative
)t 
UNION
SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Futures' as strSecondSubHeading,'Total',
		(dblBalance*dblFuturesPrice / sum(dblBalance) over (partition by strCommodity,strSecondSubHeading,strSubHeading)) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative)t

UNION
SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Basis' as strSecondSubHeading,strContractEndMonth,
		dblBalance*dblBasisPrice / sum(dblBalance) over (partition by @strCommodityCumulative,strContractEndMonth,strSecondSubHeading,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative)t 
UNION
SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Basis' as strSecondSubHeading,'Total',
		dblBalance*dblBasisPrice / sum(dblBalance) over (partition by @strCommodityCumulative,strSecondSubHeading,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative)t 
UNION

SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Cash' as strSecondSubHeading,strContractEndMonth,
		dblBalance*dblCashPrice / sum(dblBalance) over (partition by @strCommodityCumulative,strContractEndMonth,strSecondSubHeading,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative
)t 
UNION
SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Cash' as strSecondSubHeading,'Total',
		dblBalance*dblCashPrice / sum(dblBalance) over (partition by @strCommodityCumulative,strSecondSubHeading,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative)t 
UNION

SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Freight' as strSecondSubHeading,strContractEndMonth,
		dblBalance*dblRate / sum(dblBalance) over (partition by @strCommodityCumulative,strContractEndMonth,strSecondSubHeading,strSubHeading,ExRate,strCurrencyExchangeRateType) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative)t
UNION
SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Freight' as strSecondSubHeading,'Total',
		dblBalance*dblRate / sum(dblBalance) over (partition by @strCommodityCumulative,strSecondSubHeading,strSubHeading,ExRate,strCurrencyExchangeRateType) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative)t

UNION
SELECT strCommodity,strHeaderValue,strSubHeading, strCurrencyExchangeRateType as strSecondSubHeading,strContractEndMonth,
		dblBalance*ExRate / sum(dblBalance) over (partition by @strCommodityCumulative,strContractEndMonth,strSecondSubHeading,strCurrencyExchangeRateType) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative)t

UNION
SELECT strCommodity,strHeaderValue,strSubHeading, strCurrencyExchangeRateType as strSecondSubHeading,'Total',
		dblBalance*ExRate / sum(dblBalance) over (partition by @strCommodityCumulative,strSecondSubHeading,strCurrencyExchangeRateType) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative)t

-- Cumulative start
	  if exists(SELECT * from @FinalList where strContractEndMonth='Previous')
			BEGIN
				 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)
				 SELECT  strCommodity, 'Cumulative physical position',  'Cumulative physical position','Previous',dblBalance FROM @FinalList where strSubHeading='Net Physical Position' and strContractEndMonth='Previous' and strCommodity= @strCommodityCumulative
			END

		DECLARE @countC INT
		DECLARE @MonthC NVARCHAR(50)
		DECLARE @PreviousMonthC NVARCHAR(50)
		DECLARE @intMonthC INT
		SELECT @countC= min(intRowNumber) from @MonthList
		declare @previousValue numeric(24,10)
		SELECT @previousValue=sum(isnull(dblBalance,0)) from @FinalList where strSubHeading='Cumulative physical position' and strContractEndMonth='Previous' and  strCommodity= @strCommodityCumulative
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
			 and   strContractEndMonth<>'Total'
			 group by strCommodity

			  SELECT @previousValue = sum(isnull(dblBalance,0))+@previousValue FROM @FinalList
			 WHERE (CONVERT(DATETIME,'01 '+strContractEndMonth)) > (CONVERT(DATETIME,'01 '+@PreviousMonthC)) and (CONVERT(DATETIME,'01 '+strContractEndMonth)) <= (CONVERT(DATETIME,'01 '+@MonthC)) and  
			 strSubHeading='Net Physical Position' and strContractEndMonth<>'Future' and   strContractEndMonth<>'Previous' and strCommodity= @strCommodityCumulative
			  and   strContractEndMonth<>'Total'
			 group by strCommodity

		END

		SELECT @countC = min(intRowNumber) from @MonthList where intRowNumber>@countC
		END

IF EXISTS(SELECT * FROM @FinalList where strContractEndMonth='Future')
	BEGIN
		
	INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId)
 	SELECT strCommodity,'Cumulative physical position','Cumulative physical position',strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId from @FinalList WHERE strSubHeading='Purchase Total' and strCommodity=@strCommodityCumulative and strContractEndMonth='Future'

	INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId)
 	SELECT strCommodity,'Cumulative physical position','Cumulative physical position',strContractEndMonth,-dblBalance,strContractBasis,strLocationName,strContractNumber,intContractHeaderId,intFutOptTransactionHeaderId from @FinalList WHERE strSubHeading='Sale Total' and strCommodity=@strCommodityCumulative and strContractEndMonth='Future'

	INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance)
 	SELECT @strCommodityCumulative,'Cumulative physical position','Cumulative physical position','Future',isnull(@previousValue,0)
    END
 END
SELECT @intCommodityIdentityCumulative= min(intCommodityIdentity) FROM @Commodity WHERE intCommodityIdentity > @intCommodityIdentityCumulative
END 


DELETE @List

INSERT INTO @List(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId FROM  @FinalList Where strContractEndMonth='Inventory'
INSERT INTO @List(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId FROM  @FinalList Where strContractEndMonth='Previous'
INSERT INTO @List(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId FROM @FinalList Where strContractEndMonth NOT IN('Previous','Future','Inventory','Total') ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @List(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId FROM @FinalList Where strContractEndMonth='Future'

INSERT INTO @List(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId FROM @FinalList Where strContractEndMonth='Total'

INSERT INTO @List(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,'Total',strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId from @List where (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity')

INSERT INTO @List(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,'Total',strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId from @List WHERE (strSubHeading ='Futures - Long' OR  strSubHeading ='Futures - Short')

UPDATE @List set dblBalance = null where dblBalance = 0 

update @List set intOrderByOne=1  Where strSubHeading='Inventory' 
update @List set intOrderByOne=2  Where strSubHeading like '%Purchase-Priced%'
update @List set intOrderByOne=3  Where strSubHeading like '%Purchase-Basis%'
update @List set intOrderByOne=4  Where strSubHeading like '%Purchase-HTA%'
update @List set intOrderByOne=5  Where strSubHeading like '%Purchase-DP%'
update @List set intOrderByOne=6  Where strSubHeading = 'Purchase Total'
update @List set intOrderByOne=7  Where strSubHeading like '%Sale-Priced%'
update @List set intOrderByOne=8  Where strSubHeading like '%Sale-Basis%'
update @List set intOrderByOne=9  Where strSubHeading like '%Sale-HTA%'
update @List set intOrderByOne=10 Where strSubHeading like '%Sale-DP%'
update @List set intOrderByOne=11 Where strSubHeading = 'Sale Total'
update @List set intOrderByOne=12 Where strSubHeading = 'Net Physical Position'
update @List set intOrderByOne=13 Where strSubHeading = 'Cumulative physical position'
update @List set intOrderByOne=14 Where strSubHeading = 'Futures - Long'
update @List set intOrderByOne=15 Where strSubHeading = 'Futures - Short'
update @List set intOrderByOne=16 Where strSubHeading = 'Net Futures'
update @List set intOrderByOne=17 Where strSubHeading = 'Cash Exposure'
update @List set intOrderByOne=18 Where strSubHeading = 'Basis Exposure'
update @List set intOrderByTwo=1 Where strSecondSubHeading ='Purchase Quantity'
update @List set intOrderByTwo=1 Where strSecondSubHeading ='Sale Quantity'
update @List set intOrderByTwo=2 Where strSecondSubHeading ='Wt./Avg Futures'
update @List set intOrderByTwo=3 Where strSecondSubHeading ='Wt./Avg Basis'
update @List set intOrderByTwo=4 Where strSecondSubHeading ='Wt./Avg Cash'
update @List set intOrderByTwo=5 Where strSecondSubHeading ='Wt./Avg Freight'
update @List set intOrderByTwo=6 Where strSecondSubHeading like '%' + @strCurrencyName + '%'

IF ISNULL(@ysnSummary,0) = 0
BEGIN 
	SELECT * FROM @List WHERE dblBalance IS NOT NULL 
	ORDER BY intOrderByOne,intOrderByTwo--,strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading
END
ELSE
BEGIN

	SELECT * from @List WHERE strSecondSubHeading  not like '%Wt./Avg%'
	and strSecondSubHeading not like '%' + @strCurrencyName + '%' and	dblBalance IS NOT NULL 	
	ORDER BY intOrderByOne,intOrderByTwo--,strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading

END