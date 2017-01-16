CREATE PROC uspRKGetBlendDemandNetMonth
		    @intCommodityId INTEGER, 
		    @intFutureMarketId INTEGER
AS
DECLARE @DemandQty as Table (  
     intRowNumber int identity(1,1),  
     dblQuantity  numeric(24,10),  
     intUOMId  int,  
     dtmPeriod  datetime,  
     strPeriod  nvarchar(200),
	 strItemName nvarchar(200),
	 intItemId int,
	 strDescription nvarchar(200)
     )  

DECLARE @DemandFinal as Table (  
     intRowNumber int identity(1,1),  
     dblQuantity  numeric(24,10),  
     intUOMId  int,  
     dtmPeriod  datetime,  
     strPeriod  nvarchar(200),
	 strItemName nvarchar(200),
	 intItemId int,
	 strDescription nvarchar(200)
     )

INSERT INTO @DemandQty
SELECT dblQuantity,d.intUOMId,CONVERT(DATETIME,'01 '+strPeriod) dtmPeriod,strPeriod,strItemName,d.intItemId,c.strDescription FROM tblRKStgBlendDemand d
join tblICItem i on i.intItemId=d.intItemId
JOIN tblICCommodityAttribute c on c.intCommodityId = i.intCommodityId
JOIN tblRKCommodityMarketMapping m on m.intCommodityId=c.intCommodityId and   intProductTypeId=intCommodityAttributeId
			AND intCommodityAttributeId in (select Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS from [dbo].[fnSplitString](m.strCommodityAttributeId, ','))
JOIN tblRKFutureMarket fm on fm.intFutureMarketId=m.intFutureMarketId
WHERE m.intCommodityId=@intCommodityId and fm.intFutureMarketId =@intFutureMarketId

DECLARE @intRowNumber INT
DECLARE @dblQuantity  numeric(24,10)
DECLARE @intUOMId  int
DECLARE @dtmPeriod  datetime
DECLARE @strFutureMonth nvarchar(20)
declare @strItemName nvarchar(200)
declare @intItemId int
declare @strDescription nvarchar(200)

SELECT @intRowNumber = min(intRowNumber) from @DemandQty
WHILE @intRowNumber >0
BEGIN
SELECT @strFutureMonth = null, @dtmPeriod = null,@intUOMId = null , @dtmPeriod = null,@strItemName = null,@intItemId = null,@strDescription = null

SELECT @dblQuantity=dblQuantity,@intUOMId=intUOMId,@dtmPeriod=dtmPeriod,@strItemName=strItemName,@intItemId=intItemId,@strDescription=strDescription
FROM @DemandQty WHERE intRowNumber=@intRowNumber
SELECT @strFutureMonth=strFutureMonth FROM tblRKFuturesMonth fm
JOIN tblRKCommodityMarketMapping mm on mm.intFutureMarketId= fm.intFutureMarketId 
WHERE @dtmPeriod=CONVERT(DATETIME,'01 '+strFutureMonth) 
AND fm.intFutureMarketId = @intFutureMarketId and mm.intCommodityId=@intCommodityId

IF @strFutureMonth IS NULL
	SELECT @strFutureMonth=strFutureMonth FROM tblRKFuturesMonth where @dtmPeriod<CONVERT(DATETIME,'01 '+strFutureMonth)
	INSERT INTO @DemandFinal(dblQuantity,intUOMId,strPeriod,strItemName,intItemId,strDescription)
	SELECT @dblQuantity,@intUOMId,@strFutureMonth,@strItemName,@intItemId,@strDescription

SELECT @intRowNumber= min(intRowNumber) FROM @DemandQty WHERE intRowNumber > @intRowNumber
END
SELECT sum(dblQuantity) as dblQuantity,intUOMId, strPeriod,strItemName,CONVERT(DATETIME,'01 '+strPeriod) dtmPeriod,intItemId,strDescription from  @DemandFinal
GROUP BY intUOMId, strPeriod,strItemName,intItemId,strDescription ORDER BY CONVERT(DATETIME,'01 '+strPeriod)