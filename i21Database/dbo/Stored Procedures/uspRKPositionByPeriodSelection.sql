CREATE PROC [dbo].[uspRKPositionByPeriodSelection] 
	@intCommodityId NVARCHAR(max) ,
	@intCompanyLocationId NVARCHAR(max) ,
	@intQuantityUOMId int,	
	@intUnitMeasureId int,
	@intCurrencyID int,
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
	@ysnSummary bit = null,
	@intItemId int = null,
	@ysnCanadianCustomer bit = null
AS
DECLARE @intCent int
DECLARE @ysnSubCurrency int
DECLARE @intMainCurrencyId int
declare @intCurrencyID1 int

SELECT @intCent=intCent,@ysnSubCurrency=ysnSubCurrency,@intMainCurrencyId=intMainCurrencyId FROM tblSMCurrency WHERE intCurrencyID=@intCurrencyID

if (isnull(@ysnSubCurrency,0) = 1)
BEGIN
SET @intCurrencyID1=@intMainCurrencyId
END
ELSE
BEGIN
SET @intCurrencyID1=@intCurrencyID
END

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
	DECLARE @strCurrencyName nvarchar(max)
	SELECT  TOP 1 @MaxDate=CONVERT(DATETIME,'01 '+dtmMonth) from @MonthList order by intRowNumber desc
	select top 1 @strCurrencyName=strCurrency from tblSMCurrency where intCurrencyID =@intCurrencyID1

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
	 intOrderByThree INT,
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
	 intOrderByThree INT,
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

DECLARE @ContractRateDetail AS TABLE 
(
intContractDetailId int, 
dblExRate  numeric(24,10)
)

INSERT INTO @ContractRateDetail (intContractDetailId,dblExRate)
SELECT cd.intContractDetailId, case WHEN (@intCurrencyID1 <> c1.intCurrencyID and @intCurrencyID1 <> c.intCurrencyID) then null
				when @intCurrencyID1 = c1.intCurrencyID Then 1/isnull(cd.dblRate,1) 
				else case when isnull(cd.dblRate,0) =0 then isnull(RD.dblRate,0) else isnull(cd.dblRate,0) end  end
FROM vyuRKPositionByPeriodContDetView cd
JOIN tblSMCurrencyExchangeRate et on cd.intCurrencyExchangeRateId=et.intCurrencyExchangeRateId 
JOIN tblSMCurrency c on et.intFromCurrencyId=c.intCurrencyID
JOIN tblSMCurrency c1 on et.intToCurrencyId=c1.intCurrencyID
LEFT JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = et.intCurrencyExchangeRateId
where cd.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0 

DECLARE @ContractCost AS TABLE 
(
intContractDetailId int, 
dblRate  numeric(24,10)
)
INSERT INTO @ContractCost (intContractDetailId,dblRate)
SELECT intContractDetailId,SUM(dblRate) from (
	SELECT dbo.[fnRKGetCurrencyConversionRate](ccv.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,sum(dblAmountPer),
			case when ccv.strCostMethod='Percentage' then cd.intCurrencyId else ccv.intCurrencyId end)  dblRate,ccv.intContractDetailId
	FROM vyuRKPositionByPeriodContDetView cd
	join vyuCTContractCostView ccv on cd.intContractDetailId=ccv.intContractDetailId
	join vyuCTContractCostEnquiryCost cv on cv.intContractCostId=ccv.intContractCostId
		where ccv.strItemNo='Freight' and (isnull(ysnAccrue,0)=1 OR (isnull(ysnAccrue,0) =0 and isnull(ysnPrice,0) =0 and isnull(ysnBasis,0)=0))
		AND cd.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0 
		group by ccv.intCurrencyId,ccv.strCostMethod,ccv.intContractDetailId,cd.intCurrencyId)t group by intContractDetailId

-- Priced Contract	
IF @strGroupings= 'Contract Terms'
BEGIN

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)		
		SELECT 		
		strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strContractBasis,''),
		case when CH.intContractTypeId=1 then 'Purchase Quantity' else 'Sale Quantity' end,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblBalance,0)),0)) Balance,strMarketZoneCode,
		
		
		case when c.ysnSubCurrency=1 and isnull(@ysnSubCurrency,0)=1 Then			
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblFutures,0),null)*100
		when c.ysnSubCurrency = 1 and isnull(@ysnSubCurrency,0)=0 THEN
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblFutures,0),null)*100/100
		when c.ysnSubCurrency = 0 and isnull(@ysnSubCurrency,0)=1 THEN
		        dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblFutures,0),null)*100 
		else
			    dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblFutures,0),null)
		end dblFuturesPrice, 
		
		case when isnull(cd.intPricingTypeId,0)=3 then 0 else
		case when isnull(@ysnCanadianCustomer,0) = 1 then 
		isnull(	case when c.ysnSubCurrency=1 and isnull(@ysnSubCurrency,0)=1 Then			
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100
		when c.ysnSubCurrency = 1 and isnull(@ysnSubCurrency,0)=0 THEN
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100/100
		when c.ysnSubCurrency = 0 and isnull(@ysnSubCurrency,0)=1 THEN
		        dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100 
		else
			    dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)
		end,0)
		- isnull(cd.dblFutures,0)

		 else
		case when c.ysnSubCurrency=1 and isnull(@ysnSubCurrency,0)=1 Then			
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblBasis,0),null)*100
		when c.ysnSubCurrency = 1 and isnull(@ysnSubCurrency,0)=0 THEN
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblBasis,0),null)*100/100
		when c.ysnSubCurrency = 0 and isnull(@ysnSubCurrency,0)=1 THEN
		        dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblBasis,0),null)*100 
		else
			    dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblBasis,0),null)
		end end 
		end dblBasisPrice,

		case when c.ysnSubCurrency=1 and isnull(@ysnSubCurrency,0)=1 Then			
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100
		when c.ysnSubCurrency = 1 and isnull(@ysnSubCurrency,0)=0 THEN
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100/100
		when c.ysnSubCurrency = 0 and isnull(@ysnSubCurrency,0)=1 THEN
		        dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100 
		else
			    dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)
		end dblCashPrice,		

		 (select cc.dblRate from @ContractCost cc where cd.intContractDetailId=cc.intContractDetailId) dblRate,
		strLocationName,cd.strContractNumber+' - ' + convert(NVARCHAR,intContractSeq) as strContractNumber,
		(SELECT TOP 1 a.dblExRate from @ContractRateDetail a where a.intContractDetailId=cd.intContractDetailId) AS ExRate,
		dbo.fnRKGetCurrencyExchangeRateType(cd.intContractDetailId) AS strCurrencyExchangeRateType,
		CH.intContractHeaderId,null intFutOptTransactionHeaderId
		FROM vyuRKPositionByPeriodContDetView cd
		JOIN tblSMCurrency c on c.intCurrencyID =cd.intCurrencyId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId and cd.intContractStatusId <> 3
		JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=cd.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId 
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1,2,3,5)		
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  
		AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		ANd cd.intItemId = case when isnull(@intItemId,0) = 0 then cd.intItemId else @intItemId end
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,cd.intCurrencyId,cd.intItemId,cd.intPriceUnitMeasureId,strMarketZoneCode,strContractBasis,cd.dblFutures,
		dblBasis,dblCashPrice,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,cd.intContractDetailId,CH.intContractHeaderId,c.ysnSubCurrency,cd.dblRate

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodity,'Purchase Total','Purchase Total',strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth
				
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodity,'Sale Total','Sale Total',strContractEndMonth,dblBalance dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from @List where strSecondSubHeading='Sale Quantity' 
	
END

IF @strGroupings= 'Market Zone'
BEGIN
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strMarketZoneCode,''),
		case when CH.intContractTypeId=1 then 'Purchase Quantity' else 'Sale Quantity' end,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		SUM(ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblBalance,0)),0)) Balance,strMarketZoneCode,
		
		case when c.ysnSubCurrency=1 and isnull(@ysnSubCurrency,0)=1 Then			
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblFutures,0),null)*100
		when c.ysnSubCurrency = 1 and isnull(@ysnSubCurrency,0)=0 THEN
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblFutures,0),null)*100/100
		when c.ysnSubCurrency = 0 and isnull(@ysnSubCurrency,0)=1 THEN
		        dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblFutures,0),null)*100 
		else
			    dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblFutures,0),null)
		end  dblFuturesPrice, 
		
		case when isnull(cd.intPricingTypeId,0)=3 then 0 else
		case when isnull(@ysnCanadianCustomer,0) = 1 then 
		isnull(	case when c.ysnSubCurrency=1 and isnull(@ysnSubCurrency,0)=1 Then			
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100
		when c.ysnSubCurrency = 1 and isnull(@ysnSubCurrency,0)=0 THEN
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100/100
		when c.ysnSubCurrency = 0 and isnull(@ysnSubCurrency,0)=1 THEN
		        dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100 
		else
			    dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)
		end,0)
		- isnull(cd.dblFutures,0)

		 else
		case when c.ysnSubCurrency=1 and isnull(@ysnSubCurrency,0)=1 Then			
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblBasis,0),null)*100
		when c.ysnSubCurrency = 1 and isnull(@ysnSubCurrency,0)=0 THEN
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblBasis,0),null)*100/100
		when c.ysnSubCurrency = 0 and isnull(@ysnSubCurrency,0)=1 THEN
		        dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblBasis,0),null)*100 
		else
			    dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblBasis,0),null)
		end end
		end dblBasisPrice,

		case when c.ysnSubCurrency=1 and isnull(@ysnSubCurrency,0)=1 Then			
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100
		when c.ysnSubCurrency = 1 and isnull(@ysnSubCurrency,0)=0 THEN
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100/100
		when c.ysnSubCurrency = 0 and isnull(@ysnSubCurrency,0)=1 THEN
		        dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100 
		else
			    dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)
		end dblCashPrice,	

		 (select cc.dblRate from @ContractCost cc where cd.intContractDetailId=cc.intContractDetailId) dblRate,
		strLocationName,cd.strContractNumber+' - ' + convert(NVARCHAR,intContractSeq) as strContractNumber,
		(SELECT TOP 1 a.dblExRate from @ContractRateDetail a where a.intContractDetailId=cd.intContractDetailId) AS ExRate,
		dbo.fnRKGetCurrencyExchangeRateType(cd.intContractDetailId) AS strCurrencyExchangeRateType,
		CH.intContractHeaderId,null intFutOptTransactionHeaderId
		FROM vyuRKPositionByPeriodContDetView cd
		JOIN tblSMCurrency c on c.intCurrencyID =cd.intCurrencyId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId and cd.intContractStatusId <> 3
		JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=cd.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId  in(1,2,3,5)		
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  
		AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		AND cd.intItemId = case when isnull(@intItemId,0) = 0 then cd.intItemId else @intItemId end
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,cd.intCurrencyId,cd.intItemId,cd.intPriceUnitMeasureId,
		strMarketZoneCode,dblRate,cd.dblFutures,dblBasis,dblCashPrice,dblRate,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,cd.intContractDetailId,
		CH.intContractHeaderId,c.ysnSubCurrency,cd.dblRate
		
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType)
		SELECT strCommodity,'Purchase Total','Purchase Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth
				
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodity,'Sale Total','Sale Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,
		dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from @List where strSecondSubHeading='Sale Quantity' --group by strCommodity,strContractEndMonth
END

IF @strGroupings= 'Market Zone and Contract Terms'
BEGIN
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)

		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + isnull(strContractBasis,'') + ' - ' + isnull(strMarketZoneCode,''),
		case when CH.intContractTypeId=1 then 'Purchase Quantity' else 'Sale Quantity' end, RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		strContractBasis,sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblBalance,0)),0)) Balance,strMarketZoneCode,
		
		case when c.ysnSubCurrency=1 and isnull(@ysnSubCurrency,0)=1 Then			
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblFutures,0),null)*100
		when c.ysnSubCurrency = 1 and isnull(@ysnSubCurrency,0)=0 THEN
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblFutures,0),null)*100/100
		when c.ysnSubCurrency = 0 and isnull(@ysnSubCurrency,0)=1 THEN
		        dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblFutures,0),null)*100 
		else
			    dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblFutures,0),null)
		end dblFuturesPrice, 
		
		case when isnull(cd.intPricingTypeId,0)=3 then 0 else
		case when isnull(@ysnCanadianCustomer,0) = 1 then 
		isnull(	case when c.ysnSubCurrency=1 and isnull(@ysnSubCurrency,0)=1 Then			
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100
		when c.ysnSubCurrency = 1 and isnull(@ysnSubCurrency,0)=0 THEN
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100/100
		when c.ysnSubCurrency = 0 and isnull(@ysnSubCurrency,0)=1 THEN
		        dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100 
		else
			    dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)
		end,0)
		- isnull(cd.dblFutures,0)

		 else
		case when c.ysnSubCurrency=1 and isnull(@ysnSubCurrency,0)=1 Then			
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblBasis,0),null)*100
		when c.ysnSubCurrency = 1 and isnull(@ysnSubCurrency,0)=0 THEN
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblBasis,0),null)*100/100
		when c.ysnSubCurrency = 0 and isnull(@ysnSubCurrency,0)=1 THEN
		        dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblBasis,0),null)*100 
		else
			    dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblBasis,0),null)
		end end
		end dblBasisPrice,

		case when c.ysnSubCurrency=1 and isnull(@ysnSubCurrency,0)=1 Then			
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100
		when c.ysnSubCurrency = 1 and isnull(@ysnSubCurrency,0)=0 THEN
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100/100
		when c.ysnSubCurrency = 0 and isnull(@ysnSubCurrency,0)=1 THEN
		        dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100 
		else
			    dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)
		end dblCashPrice,
	(select cc.dblRate from @ContractCost cc where cd.intContractDetailId=cc.intContractDetailId) dblRate,
		strLocationName,cd.strContractNumber+' - ' + convert(NVARCHAR,intContractSeq) as strContractNumber,
		(SELECT TOP 1 a.dblExRate from @ContractRateDetail a where a.intContractDetailId=cd.intContractDetailId) AS ExRate,
		dbo.fnRKGetCurrencyExchangeRateType(cd.intContractDetailId) AS strCurrencyExchangeRateType,
		CH.intContractHeaderId,null intFutOptTransactionHeaderId
		FROM vyuRKPositionByPeriodContDetView cd
		JOIN tblSMCurrency c on c.intCurrencyID =cd.intCurrencyId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId and cd.intContractStatusId <> 3
		JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=cd.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1,2,3,5)		
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0  AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))			
		AND cd.intItemId = case when isnull(@intItemId,0) = 0 then cd.intItemId else @intItemId end
		GROUP BY strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,cd.intCurrencyId,cd.intItemId,cd.intPriceUnitMeasureId,strMarketZoneCode,strContractBasis,cd.dblFutures,dblBasis,dblCashPrice,cd.dblRate,CH.intContractTypeId,cd.intPricingTypeId,cd.strPricingType,cd.intContractDetailId,CH.intContractHeaderId,c.ysnSubCurrency,cd.dblRate
				
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodity,'Purchase Total','Purchase Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from @List where strSecondSubHeading='Purchase Quantity'-- group by strCommodity,strContractEndMonth

		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodity,'Sale Total','Sale Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from @List where strSecondSubHeading='Sale Quantity'-- group by strCommodity,strContractEndMonth

END

IF @strGroupings= 'By Item' 
BEGIN
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodityCode [StrCommodity],strContractType +'-' + cd.strPricingType + ' - ' + strItemNo,
		case when CH.intContractTypeId=1 then 'Purchase Quantity' else 'Sale Quantity' end,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		sum(isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,isnull(dblBalance,0)),0)) Balance,strMarketZoneCode,
		
		--case when isnull(@ysnCanadianCustomer,0) = 1 then cd.dblFutures else
		case when c.ysnSubCurrency=1 and isnull(@ysnSubCurrency,0)=1 Then			
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblFutures,0),null)*100
		when c.ysnSubCurrency = 1 and isnull(@ysnSubCurrency,0)=0 THEN
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblFutures,0),null)*100/100
		when c.ysnSubCurrency = 0 and isnull(@ysnSubCurrency,0)=1 THEN
		        dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblFutures,0),null)*100 
		else
			    dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblFutures,0),null)
		end  dblFuturesPrice, 

		case when isnull(cd.intPricingTypeId,0)=3 then 0 else
		case when (isnull(@ysnCanadianCustomer,0) = 0 and isnull(cd.dblFutures,0)<>0) then 
		isnull(	case when c.ysnSubCurrency=1 and isnull(@ysnSubCurrency,0)=1 Then			
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100
		when c.ysnSubCurrency = 1 and isnull(@ysnSubCurrency,0)=0 THEN
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100/100
		when c.ysnSubCurrency = 0 and isnull(@ysnSubCurrency,0)=1 THEN
		        dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100 
		else
			    dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)
		end,0)
		- isnull(cd.dblFutures,0)

		 else
		case when c.ysnSubCurrency=1 and isnull(@ysnSubCurrency,0)=1 Then			
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblBasis,0),null)*100
		when c.ysnSubCurrency = 1 and isnull(@ysnSubCurrency,0)=0 THEN
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblBasis,0),null)*100/100
		when c.ysnSubCurrency = 0 and isnull(@ysnSubCurrency,0)=1 THEN
		        dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblBasis,0),null)*100 
		else
			    dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(cd.dblBasis,0),null)
		end end 
		end 
		dblBasisPrice,

		case when c.ysnSubCurrency=1 and isnull(@ysnSubCurrency,0)=1 Then			
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100
		when c.ysnSubCurrency = 1 and isnull(@ysnSubCurrency,0)=0 THEN
				dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100/100
		when c.ysnSubCurrency = 0 and isnull(@ysnSubCurrency,0)=1 THEN
		        dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)*100 
		else
			    dbo.[fnRKGetCurrencyConversionRate](cd.intContractDetailId,@intCurrencyID1,@intUnitMeasureId,isnull(dblCashPrice,0),null)
		end dblCashPrice,	
   	(select cc.dblRate from @ContractCost cc where cd.intContractDetailId=cc.intContractDetailId) dblRate,
		strLocationName,cd.strContractNumber+' - ' + convert(NVARCHAR,intContractSeq) as strContractNumber,strItemNo,
		(SELECT TOP 1 a.dblExRate from @ContractRateDetail a where a.intContractDetailId=cd.intContractDetailId) AS ExRate,
		dbo.fnRKGetCurrencyExchangeRateType(cd.intContractDetailId) AS strCurrencyExchangeRateType,CH.intContractHeaderId,null intFutOptTransactionHeaderId
		FROM vyuRKPositionByPeriodContDetView cd
		JOIN tblSMCurrency c on c.intCurrencyID =cd.intCurrencyId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId and cd.intContractStatusId <> 3
		JOIN tblICCommodityUnitMeasure ium1 on ium1.intCommodityId=cd.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId 
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId and cd.intPricingTypeId in(1,2,3,5)		
		WHERE CH.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')) and dblBalance > 0 
			AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
			AND cd.intItemId = case when isnull(@intItemId,0) = 0 then cd.intItemId else @intItemId end
			--and cd.intContractDetailId=454
		GROUP BY CH.intContractTypeId,strCommodityCode,strLocationName,cd.strContractNumber,cd.intContractSeq,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8),strContractType,cd.intCurrencyId,
		cd.intItemId,cd.intPriceUnitMeasureId,strMarketZoneCode,strItemNo,cd.dblFutures,dblBasis,dblCashPrice,dblRate,CH.intContractTypeId,cd.intPricingTypeId,
		cd.strPricingType,cd.intContractDetailId,CH.intContractHeaderId,c.ysnSubCurrency,cd.dblRate
		ORDER BY CH.intContractTypeId,cd.intPricingTypeId
		INSERT INTO @List(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		SELECT strCommodity,'Purchase Total','Purchase Total',strContractEndMonth,(dblBalance) dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from @List where strSecondSubHeading='Purchase Quantity' --group by strCommodity,strContractEndMonth
				
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
		WHERE strHeaderValue='Futures - Long'  and strSecondSubHeading='Futures - Long'
UNION
SELECT strCommodity,'Net Futures','Net Futures','Net Futures',strContractEndMonth,dblBalance,strContractNumber,strLocationName,intContractHeaderId,intFutOptTransactionHeaderId FROM  @List 
		WHERE strHeaderValue='Futures - Short' and strSecondSubHeading='Futures - Short'

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
	 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
	 SELECT strCommodity,strSubHeading,strSecondSubHeading,'Previous' strContractEndMonth,strContractBasis,sum(isnull(dblBalance,0)),strMarketZoneCode,sum(isnull(dblFuturesPrice,0)),sum(isnull(dblBasisPrice,0)),sum(isnull(dblCashPrice,0)),dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM @List
	 WHERE (CONVERT(DATETIME,'01 '+strContractEndMonth)) < (CONVERT(DATETIME,'01 '+@Month1))
	 GROUP BY strCommodity,strSubHeading,strSecondSubHeading,strContractBasis,strMarketZoneCode,dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId

---- Future

DECLARE @Month2 NVARCHAR(50)
SELECT TOP 1 @Month2=dtmMonth from @MonthList Order by intRowNumber desc

		 INSERT INTO @FinalList(strCommodity,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)
		 SELECT strCommodity,strSubHeading,strSecondSubHeading,'Future' strContractEndMonth,strContractBasis,sum(isnull(dblBalance,0)),strMarketZoneCode,sum(isnull(dblFuturesPrice,0)) dblFuturesPrice,sum(isnull(dblBasisPrice,0)) dblBasisPrice,sum(isnull(dblCashPrice,0)) dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM @List
		 WHERE (CONVERT(DATETIME,'01 '+strContractEndMonth)) > (CONVERT(DATETIME,'01 '+@Month2)) 
		 GROUP BY strCommodity,strSubHeading,strSecondSubHeading,strContractBasis,strMarketZoneCode,dblRate,strLocationName,strContractNumber,strItemNo,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId
	
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
		isnull(dblBalance,0)*isnull(dblFuturesPrice,0) / sum(isnull(dblBalance,0)) over (partition by strCommodity,strContractEndMonth,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSubHeading ='Futures - Long' OR  strSubHeading ='Futures - Short')  and strCommodity= @strCommodityCumulative and dblBalance<>0 and isnull(dblFuturesPrice,0) <> 0
)t 
union
SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Price' as strSecondSubHeading,'Total',
		isnull(dblBalance,0)*isnull(dblFuturesPrice,0) / sum(isnull(dblBalance,0)) over (partition by strCommodity,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSubHeading ='Futures - Long' OR  strSubHeading ='Futures - Short')  and strCommodity= @strCommodityCumulative and dblBalance<>0 and isnull(dblFuturesPrice,0) <> 0 and strSecondSubHeading <> 'Wt./Avg Price'
)t 
---------RK Module 


INSERT INTO @FinalList (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId)

SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Futures' as strSecondSubHeading,strContractEndMonth,
		dblBalance*dblFuturesPrice / sum(isnull(dblBalance,0)) over (partition by strCommodity,strContractEndMonth,strSecondSubHeading,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative and dblBalance<>0 and isnull(dblFuturesPrice,0) <> 0)t 
UNION
SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Futures' as strSecondSubHeading,'Total',
		(dblBalance*dblFuturesPrice / sum(isnull(dblBalance,0)) over (partition by strCommodity,strSecondSubHeading,strSubHeading)) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative and dblBalance<>0 and isnull(dblFuturesPrice,0) <> 0)t

UNION
SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Basis' as strSecondSubHeading,strContractEndMonth,
		dblBalance*dblBasisPrice / sum(isnull(dblBalance,0)) over (partition by @strCommodityCumulative,strContractEndMonth,strSecondSubHeading,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,
	dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative and dblBalance<>0 and isnull(dblBasisPrice,0) <> 0)t 
UNION
SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Basis' as strSecondSubHeading,'Total',
		dblBalance*dblBasisPrice / sum(isnull(dblBalance,0)) over (partition by @strCommodityCumulative,strSecondSubHeading,strSubHeading),
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,
	dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative and dblBalance<>0 and isnull(dblBasisPrice,0) <> 0)t 
UNION

SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Cash' as strSecondSubHeading,strContractEndMonth,
		dblBalance*dblCashPrice / sum(isnull(dblBalance,0)) over (partition by @strCommodityCumulative,strContractEndMonth,strSecondSubHeading,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative and dblBalance<>0 and isnull(dblCashPrice,0) <> 0)t 
UNION
SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Cash' as strSecondSubHeading,'Total',
		dblBalance*dblCashPrice / sum(isnull(dblBalance,0)) over (partition by @strCommodityCumulative,strSecondSubHeading,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative and dblBalance<>0 and isnull(dblCashPrice,0) <> 0)t 
UNION

SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Freight' as strSecondSubHeading,strContractEndMonth,
		dblBalance*dblRate / sum(isnull(dblBalance,0)) over (partition by @strCommodityCumulative,strContractEndMonth,strSecondSubHeading,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative and dblBalance<>0 and dblRate > 0)t
UNION
SELECT strCommodity,strHeaderValue,strSubHeading, 'Wt./Avg Freight' as strSecondSubHeading,'Total',
		dblBalance*dblRate / sum(isnull(dblBalance,0)) over (partition by @strCommodityCumulative,strSecondSubHeading,strSubHeading) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative and dblBalance<>0 and dblRate > 0)t

UNION
SELECT strCommodity,strHeaderValue,strSubHeading, 'Exchange -'+strCurrencyExchangeRateType as strSecondSubHeading,strContractEndMonth,
		dblBalance*ExRate / sum(isnull(dblBalance,0)) over (partition by @strCommodityCumulative,strContractEndMonth,strSecondSubHeading,strCurrencyExchangeRateType) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative and dblBalance<>0 and isnull(ExRate,0) <> 0)t

UNION
SELECT strCommodity,strHeaderValue,strSubHeading, 'Exchange -'+strCurrencyExchangeRateType as strSecondSubHeading,'Total',
		dblBalance*ExRate / sum(isnull(dblBalance,0)) over (partition by @strCommodityCumulative,strSubHeading,strSecondSubHeading,strCurrencyExchangeRateType) ,
		strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId FROM(
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,dblBalance,strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId from  @FinalList
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity') and strCommodity= @strCommodityCumulative and dblBalance<>0 and isnull(ExRate,0) <> 0)t

-- Cumulative start
	  IF EXISTS(SELECT * from @FinalList where strContractEndMonth='Previous')
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

INSERT INTO @FinalList(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,
						strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,
						intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,'Total',strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,
   	   dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,
	   intFutOptTransactionHeaderId from @FinalList 
WHERE strSubHeading ='Wt./Avg Price' and strSecondSubHeading='Total' 

INSERT INTO @FinalList(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,
						strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,
						intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,'Total',strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,
   	   dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,
	   intFutOptTransactionHeaderId from @FinalList 
WHERE (strSecondSubHeading ='Purchase Quantity' OR  strSecondSubHeading ='Sale Quantity' 
		OR strSubHeading ='Purchase Total' OR  strSubHeading ='Sale Total' OR  strSubHeading ='Net Futures' OR  strSubHeading ='Cumulative physical position'
		OR strSubHeading ='Net Physical Position' OR strSubHeading ='Cash Exposure' OR strSubHeading ='Basis Exposure' OR strSubHeading ='Basis Exposure' OR strSubHeading ='Basis Exposure'
) 

INSERT INTO @FinalList(strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,
						strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,
						intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,'Total',strContractBasis,dblBalance,strMarketZoneCode,dblFuturesPrice,
   	   dblBasisPrice,dblCashPrice,dblRate,strLocationName,strContractNumber,strItemNo,intOrderByOne,intOrderByTwo,ExRate,intContractHeaderId,
	   intFutOptTransactionHeaderId from @List 
WHERE strSubHeading ='Futures - Long' OR strSubHeading ='Futures - Short' and strSecondSubHeading<>'Total' 

DELETE @List

UPDATE @FinalList set dblBalance = null where dblBalance = 0 

DECLARE @Result AS TABLE (  
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
	 intOrderByThree INT,
	 dblRate  DECIMAL(24,10),
	 ExRate DECIMAL(24,10),
	 strCurrencyExchangeRateType NVARCHAR(200),
	 intContractHeaderId int ,
	 intFutOptTransactionHeaderId int	  
	 )  

 declare @strCommodityName nvarchar(100)
	 declare @strSubHeading nvarchar(100)
	 declare @strSecondSubHeading nvarchar(100)
	 declare @strHeaderValue nvarchar(100)
	 declare @strContractEndMonth nvarchar(100)

 SELECT TOP 1  @strCommodityName=strCommodity,@strHeaderValue=strHeaderValue,@strSubHeading=strSubHeading,@strSecondSubHeading=strSecondSubHeading,@strContractEndMonth=strContractEndMonth
 FROM @FinalList where strSecondSubHeading='Purchase Quantity'

DECLARE @DistinctMonth AS TABLE (  
     strContractEndMonth nvarchar(100))
INSERT INTO @DistinctMonth(strContractEndMonth)
SELECT DISTINCT strContractEndMonth FROM @FinalList WHERE strCommodity=@strCommodityName and strSecondSubHeading='Purchase Quantity'

 INSERT INTO @FinalList (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
 SELECT DISTINCT @strCommodityName,@strHeaderValue,@strSubHeading,@strSecondSubHeading,strContractEndMonth,null ,null ,  
				    null,null,null,null,null,null,null,null,null,null,
					null,null,null,null,null,null,null
FROM @FinalList  
WHERE strContractEndMonth
 NOT IN (SELECT strContractEndMonth from @DistinctMonth)


INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strSubHeading='Inventory' 

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' 
	and (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or  strSubHeading like '%Purchase-HTA%' or  strSubHeading like '%Purchase-DP%') 
	and strSecondSubHeading='Purchase Quantity' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 

SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or strSubHeading like '%Purchase-HTA%' or strSubHeading like '%Purchase-DP%') and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
				and strSecondSubHeading='Purchase Quantity' 
ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') 
	and (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or  strSubHeading like '%Purchase-HTA%' or  strSubHeading like '%Purchase-DP%') 
		and strSecondSubHeading='Purchase Quantity' 


INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' 
	and (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or  strSubHeading like '%Purchase-HTA%' or  strSubHeading like '%Purchase-DP%') 
	and strSecondSubHeading='Wt./Avg Futures' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 

SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or strSubHeading like '%Purchase-HTA%' or strSubHeading like '%Purchase-DP%') and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
				and strSecondSubHeading='Wt./Avg Futures'
ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') 
	and (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or  strSubHeading like '%Purchase-HTA%' or  strSubHeading like '%Purchase-DP%') 
		and strSecondSubHeading='Wt./Avg Futures' 

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' 
	and (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or  strSubHeading like '%Purchase-HTA%' or  strSubHeading like '%Purchase-DP%') 
	and strSecondSubHeading='Wt./Avg Basis' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 

SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or strSubHeading like '%Purchase-HTA%' or strSubHeading like '%Purchase-DP%') and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
				and strSecondSubHeading='Wt./Avg Basis'
ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)


INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') 
	and (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or  strSubHeading like '%Purchase-HTA%' or  strSubHeading like '%Purchase-DP%') 
		and strSecondSubHeading='Wt./Avg Basis' 

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' 
	and (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or  strSubHeading like '%Purchase-HTA%' or  strSubHeading like '%Purchase-DP%') 
	and strSecondSubHeading='Wt./Avg Price' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 

SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or strSubHeading like '%Purchase-HTA%' or strSubHeading like '%Purchase-DP%') and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
				and strSecondSubHeading='Wt./Avg Price'
ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)


INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') 
	and (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or  strSubHeading like '%Purchase-HTA%' or  strSubHeading like '%Purchase-DP%') 
		and strSecondSubHeading='Wt./Avg Price' 

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' 
	and (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or  strSubHeading like '%Purchase-HTA%' or  strSubHeading like '%Purchase-DP%') 
	and strSecondSubHeading='Wt./Avg Cash' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 

SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or strSubHeading like '%Purchase-HTA%' or strSubHeading like '%Purchase-DP%') and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
and strSecondSubHeading='Wt./Avg Cash'
ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') 
	and (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or  strSubHeading like '%Purchase-HTA%' or  strSubHeading like '%Purchase-DP%') 
		and strSecondSubHeading='Wt./Avg Cash' 

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' 
	and (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or  strSubHeading like '%Purchase-HTA%' or  strSubHeading like '%Purchase-DP%') 
	and strSecondSubHeading='Wt./Avg Freight' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 

SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or strSubHeading like '%Purchase-HTA%' or strSubHeading like '%Purchase-DP%') and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
and strSecondSubHeading='Wt./Avg Freight'
ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
					strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
					strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') 
	and (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or  strSubHeading like '%Purchase-HTA%' or  strSubHeading like '%Purchase-DP%') 
and strSecondSubHeading='Wt./Avg Freight'	
-------------------
INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' 
	and (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or  strSubHeading like '%Purchase-HTA%' or  strSubHeading like '%Purchase-DP%') 
	and strSecondSubHeading like'Exchange -%' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 

SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or strSubHeading like '%Purchase-HTA%' or strSubHeading like '%Purchase-DP%') and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
and strSecondSubHeading like'Exchange -%'
ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

						INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
											strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
											intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
						SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
											strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
											intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
						FROM @FinalList WHERE strContractEndMonth in('Future','Total') 
							and (strSubHeading like '%Purchase-Priced%' or strSubHeading like '%Purchase-Basis%' or  strSubHeading like '%Purchase-HTA%' or  strSubHeading like '%Purchase-DP%') 
						and strSecondSubHeading like'Exchange -%'

----------------------------

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' and strSubHeading = 'Purchase Total' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strSubHeading = 'Purchase Total' and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
			ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') and strSubHeading = 'Purchase Total' and strContractEndMonth<>'Inventory'
--------------  sale
INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' 
	and (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or  strSubHeading like '%Sale-HTA%' or  strSubHeading like '%Sale-DP%') 
	and strSecondSubHeading='Sale Quantity' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 

SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or strSubHeading like '%Sale-HTA%' or strSubHeading like '%Sale-DP%') and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
				and strSecondSubHeading='Sale Quantity' 
ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') 
	and (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or  strSubHeading like '%Sale-HTA%' or  strSubHeading like '%Sale-DP%') 
		and strSecondSubHeading='Sale Quantity' 


INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' 
	and (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or  strSubHeading like '%Sale-HTA%' or  strSubHeading like '%Sale-DP%') 
	and strSecondSubHeading='Wt./Avg Futures' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 

SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or strSubHeading like '%Sale-HTA%' or strSubHeading like '%Sale-DP%') and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
				and strSecondSubHeading='Wt./Avg Futures'
ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') 
	and (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or  strSubHeading like '%Sale-HTA%' or  strSubHeading like '%Sale-DP%') 
		and strSecondSubHeading='Wt./Avg Futures' 

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' 
	and (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or  strSubHeading like '%Sale-HTA%' or  strSubHeading like '%Sale-DP%') 
	and strSecondSubHeading='Wt./Avg Basis' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 

SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or strSubHeading like '%Sale-HTA%' or strSubHeading like '%Sale-DP%') and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
				and strSecondSubHeading='Wt./Avg Basis'
ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)


INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') 
	and (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or  strSubHeading like '%Sale-HTA%' or  strSubHeading like '%Sale-DP%') 
		and strSecondSubHeading='Wt./Avg Basis' 

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' 
	and (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or  strSubHeading like '%Sale-HTA%' or  strSubHeading like '%Sale-DP%') 
	and strSecondSubHeading='Wt./Avg Price' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 

SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or strSubHeading like '%Sale-HTA%' or strSubHeading like '%Sale-DP%') and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
				and strSecondSubHeading='Wt./Avg Price'
ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)


INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') 
	and (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or  strSubHeading like '%Sale-HTA%' or  strSubHeading like '%Sale-DP%') 
		and strSecondSubHeading='Wt./Avg Price' 

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' 
	and (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or  strSubHeading like '%Sale-HTA%' or  strSubHeading like '%Sale-DP%') 
	and strSecondSubHeading='Wt./Avg Cash' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 

SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or strSubHeading like '%Sale-HTA%' or strSubHeading like '%Sale-DP%') and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
and strSecondSubHeading='Wt./Avg Cash'
ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') 
	and (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or  strSubHeading like '%Sale-HTA%' or  strSubHeading like '%Sale-DP%') 
		and strSecondSubHeading='Wt./Avg Cash' 

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' 
	and (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or  strSubHeading like '%Sale-HTA%' or  strSubHeading like '%Sale-DP%') 
	and strSecondSubHeading='Wt./Avg Freight' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 

SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or strSubHeading like '%Sale-HTA%' or strSubHeading like '%Sale-DP%') and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
and strSecondSubHeading='Wt./Avg Freight'
ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
					strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
					strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') 
	and (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or  strSubHeading like '%Sale-HTA%' or  strSubHeading like '%Sale-DP%') 
and strSecondSubHeading='Wt./Avg Freight'	

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' 
	and (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or  strSubHeading like '%Sale-HTA%' or  strSubHeading like '%Sale-DP%') 
	and strSecondSubHeading like'Exchange -%' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 

SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or strSubHeading like '%Sale-HTA%' or strSubHeading like '%Sale-DP%') and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
and strSecondSubHeading like'Exchange -%'
ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

						INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
											strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
											intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
						SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
											strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
											intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
						FROM @FinalList WHERE strContractEndMonth in('Future','Total') 
							and (strSubHeading like '%Sale-Priced%' or strSubHeading like '%Sale-Basis%' or  strSubHeading like '%Sale-HTA%' or  strSubHeading like '%Sale-DP%') 
						and strSecondSubHeading like'Exchange -%'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' and strSubHeading = 'Sale Total' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strSubHeading = 'Sale Total' and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
			ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') and strSubHeading = 'Sale Total' and strContractEndMonth<>'Inventory'
----------------------------------- end
INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' and strSubHeading = 'Net Physical Position' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strSubHeading = 'Net Physical Position' and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
			ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') and strSubHeading = 'Net Physical Position' and strContractEndMonth<>'Inventory'


INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' and strSubHeading = 'Cumulative physical position' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strSubHeading = 'Cumulative physical position' and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
			ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') and strSubHeading = 'Cumulative physical position' and strContractEndMonth<>'Inventory'


INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' and strSubHeading = 'Futures - Long' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strSubHeading = 'Futures - Long' and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
			ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') and strSubHeading = 'Futures - Long' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' and strSubHeading = 'Futures - Short' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strSubHeading = 'Futures - Short' and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
			ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') and strSubHeading = 'Futures - Short' and strContractEndMonth<>'Inventory'


INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' and strSubHeading = 'Net Futures' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strSubHeading = 'Net Futures' and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
			ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') and strSubHeading = 'Net Futures' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' and strSubHeading = 'Cash Exposure' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strSubHeading = 'Cash Exposure' and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
			ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') and strSubHeading = 'Cash Exposure' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth='Previous' and strSubHeading = 'Basis Exposure' and strContractEndMonth<>'Inventory'

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strSubHeading = 'Basis Exposure' and strContractEndMonth NOT IN('Previous','Future','Inventory','Total')
			ORDER BY CONVERT(DATETIME,'01 '+strContractEndMonth)

INSERT INTO @Result (strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis ,dblBalance ,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId) 
SELECT strCommodity,strHeaderValue,strSubHeading,strSecondSubHeading,strContractEndMonth,strContractBasis,dblBalance,  
				    strMarketZoneCode,dblFuturesPrice,dblBasisPrice,dblCashPrice,dblWtAvgPriced,dblQuantity,strLocationName,strContractNumber,strItemNo,intOrderByOne,
					intOrderByTwo,intOrderByThree,dblRate,ExRate,strCurrencyExchangeRateType,intContractHeaderId,intFutOptTransactionHeaderId 
FROM @FinalList WHERE strContractEndMonth in('Future','Total') and strSubHeading = 'Basis Exposure' and strContractEndMonth<>'Inventory'

IF ISNULL(@ysnSummary,0) = 0
BEGIN 
	SELECT * FROM @Result  order by intRowNumber
END
ELSE
BEGIN
	SELECT * FROM @Result WHERE strSecondSubHeading  not like '%Wt./Avg%'
	AND strSecondSubHeading not like '%' + @strCurrencyName + '%' 	
END