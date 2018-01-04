CREATE PROC uspRKFutOptTransactionLimit 
	@strXml nvarchar(max)
	
AS
DECLARE @idoc int     
EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml    

DECLARE @tblTransaction table          
  (     
  intFutOptTransactionId Int  
  )    
  
INSERT INTO @tblTransaction  
SELECT    
 intFutOptTransactionId
  FROM OPENXML(@idoc,'root/Transaction', 2)        
 WITH      
 (    
 [intFutOptTransactionId] INT
 )  

 select  convert(int,ROW_NUMBER() OVER(ORDER BY strFutMarketName ASC)) intRowNumber ,* from (
SELECT * FROM (
SELECT 
	fm.strFutMarketName
	,m.strFutureMonth
	,c.strCommodityCode
	,b.strBook
	,sb.strSubBook	
	,sum(oc.intOpenContract) dblOpenContract
	,dblLimit
FROM vyuRKGetOpenContract oc
JOIN tblRKFutOptTransaction fot on oc.intFutOptTransactionId=fot.intFutOptTransactionId 
JOIN tblCTLimit l on fot.intBookId = l.intBookId AND fot.intFutureMarketId=l.intFutureMarketId 
									AND fot.intFutureMonthId=l.intFutureMonthId 
									and fot.intSubBookId=l.intSubBookId
									AND fot.intCommodityId=l.intCommodityId 
									
JOIN tblCTBook b ON b.intBookId = l.intBookId and isnull(ysnLimitForMonth,0) = 1
JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = l.intFutureMarketId
JOIN tblRKFuturesMonth m ON m.intFutureMonthId = l.intFutureMonthId
JOIN tblICCommodity c ON c.intCommodityId = l.intCommodityId
JOIN tblCTSubBook sb ON sb.intSubBookId = l.intSubBookId
WHERE fot.intBookId IS NOT NULL AND fot.intSubBookId IS NOT NULL 
	AND fot.intFutOptTransactionId IN(SELECT intFutOptTransactionId FROM @tblTransaction)
GROUP BY 
 l.intBookId
,l.intLimitId
,l.intFutureMarketId
,l.intFutureMonthId
,l.intCommodityId
,l.intSubBookId	
,dblLimit
,fm.strFutMarketName
,m.strFutureMonth
,c.strCommodityCode
,sb.strSubBook
,b.strBook) t where dblOpenContract > dblLimit

UNION

SELECT * FROM (
SELECT 
	fm.strFutMarketName
	,null strFutureMonth
	,c.strCommodityCode
	,b.strBook
	,sb.strSubBook	
	,sum(oc.intOpenContract) dblOpenContract
	,dblLimit
FROM vyuRKGetOpenContract oc
JOIN tblRKFutOptTransaction fot on oc.intFutOptTransactionId=fot.intFutOptTransactionId 
JOIN tblCTLimit l on fot.intBookId = l.intBookId AND fot.intFutureMarketId=l.intFutureMarketId 									
									and fot.intSubBookId=l.intSubBookId
									AND fot.intCommodityId=l.intCommodityId									
JOIN tblCTBook b ON b.intBookId = l.intBookId and isnull(ysnLimitForMonth,0) = 0
JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = l.intFutureMarketId
JOIN tblICCommodity c ON c.intCommodityId = l.intCommodityId
JOIN tblCTSubBook sb ON sb.intSubBookId = l.intSubBookId
WHERE fot.intBookId IS NOT NULL AND fot.intSubBookId IS NOT NULL
	AND fot.intFutOptTransactionId IN(SELECT intFutOptTransactionId FROM @tblTransaction)
GROUP BY 
 l.intBookId
,l.intLimitId
,l.intFutureMarketId
,l.intCommodityId
,l.intSubBookId	
,dblLimit
,fm.strFutMarketName
,c.strCommodityCode
,sb.strSubBook
,b.strBook) t where dblOpenContract > dblLimit )t1