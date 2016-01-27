CREATE PROCEDURE [dbo].[uspRKDPRHedgeDailyPositionDetailByMonth]
		 @intCommodityId nvarchar(max)
		,@intLocationId nvarchar(max) = NULL
AS

BEGIN

DECLARE @strCommodityCode NVARCHAR(50)

	 DECLARE @Commodity AS TABLE 
	 (
		intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
		intCommodity  INT
	 )
	 INSERT INTO @Commodity(intCommodity)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  

DECLARE @List AS TABLE (  
     intRowNumber INT IDENTITY(1,1),
	 strCommodityCode NVARCHAR(200),   
     strType  NVARCHAR(50), 
	 strLocationName NVARCHAR(100),
	 strContractEndMonth NVARCHAR(50),
	 dblTotal DECIMAL(24,10)
     ) 

INSERT INTO @List (strCommodityCode,strType,strLocationName,strContractEndMonth,dblTotal)
	SELECT strCommodityCode
		,strContractType+ ' ' + strPricingType [strType]
		,strLocationName,
		RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth
		,isnull(dblBalance, 0) AS dblTotal
	FROM vyuCTContractDetailView  
	WHERE intContractTypeId in(1,2) AND intPricingTypeId IN (1,2,3) and intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
		AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end

INSERT INTO @List (strCommodityCode,strType,strLocationName,strContractEndMonth,dblTotal)		
	SELECT strCommodityCode,'Net Hedge',strLocationName, strFutureMonth,HedgedQty
	FROM (
		SELECT strCommodityCode,(ISNULL(intNoOfContract, 0) - isnull(dblMatchQty, 0)) * m.dblContractSize AS HedgedQty,l.strLocationName,left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) strFutureMonth
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		INNER JOIN tblICCommodity ic on f.intCommodityId=ic.intCommodityId
		INNER JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=f.intFutureMonthId
		INNER JOIN tblSMCompanyLocation l on f.intLocationId=l.intCompanyLocationId
		LEFT JOIN tblRKMatchFuturesPSDetail psd ON f.intFutOptTransactionId = psd.intLFutOptTransactionId
		WHERE f.strBuySell = 'Buy'
			AND ic.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
			AND f.intLocationId= case when isnull(@intLocationId,0)=0 then f.intLocationId else @intLocationId end	

		
		UNION ALL
		
		SELECT strCommodityCode,-(ISNULL(intNoOfContract, 0) - isnull(dblMatchQty, 0)) * m.dblContractSize AS HedgedQty,l.strLocationName,left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) strFutureMonth
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		INNER JOIN tblICCommodity ic on f.intCommodityId=ic.intCommodityId
		INNER JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=f.intFutureMonthId
		INNER JOIN tblSMCompanyLocation l on f.intLocationId=l.intCompanyLocationId
		LEFT JOIN tblRKMatchFuturesPSDetail psd ON f.intFutOptTransactionId = psd.intLFutOptTransactionId
		WHERE f.strBuySell = 'Sell'
			AND ic.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
			AND f.intLocationId= case when isnull(@intLocationId,0)=0 then f.intLocationId else @intLocationId end
			
		) t

END

DECLARE @intUnitMeasureId int
DECLARE @intFromCommodityUnitMeasureId int
DECLARE @intToCommodityUnitMeasureId int
DECLARE @StrUnitMeasure nvarchar(50)

SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference

IF ISNULL(@intUnitMeasureId,'') <> ''
BEGIN
	SELECT @intFromCommodityUnitMeasureId=cuc.intCommodityUnitMeasureId,@intToCommodityUnitMeasureId=cuc1.intCommodityUnitMeasureId 
	FROM tblICCommodity t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
	SELECT @StrUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
END
ELSE
BEGIN
	SELECT @StrUnitMeasure=c.strUnitMeasure
	FROM tblICCommodity t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1
	join tblICUnitMeasure c on c.intUnitMeasureId=cuc.intUnitMeasureId 	
	WHERE t.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
END

BEGIN

		IF ISNULL(@intUnitMeasureId, 0) <> 0
		BEGIN
		SELECT intRowNumber,strCommodityCode , strType,strLocationName,strContractEndMonth, 
		 dbo.fnCTConvertQuantityToTargetCommodityUOM(@intFromCommodityUnitMeasureId,@intToCommodityUnitMeasureId,dblTotal) dblTotal,
		 @StrUnitMeasure as strUnitMeasure
		FROM @List ORDER BY strCommodityCode,CONVERT(DATETIME,'01 '+ strContractEndMonth) asc

		END
		ELSE
		BEGIN
			SELECT intRowNumber,strCommodityCode , strType,strLocationName,strContractEndMonth,dblTotal,@StrUnitMeasure as strUnitMeasure FROM @List ORDER BY CONVERT(DATETIME,'01 '+ strContractEndMonth) asc
		END
END