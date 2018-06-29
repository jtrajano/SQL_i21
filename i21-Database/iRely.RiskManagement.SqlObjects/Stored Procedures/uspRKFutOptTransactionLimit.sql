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

SELECT intFutureMarketId,intCommodityId,intFutureMonthId,intBookId,intSubBookId INTO #temp  FROM tblRKFutOptTransaction WHERE intFutOptTransactionId IN(SELECT intFutOptTransactionId FROM @tblTransaction)

SELECT  CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName ASC)) intRowNumber ,* from (
SELECT * FROM (
SELECT strFutMarketName,strFutureMonth,strCommodityCode,strBook,strSubBook, sum(dblOpenContract1) dblOpenContract,dblLimit FROM (
SELECT 
       fm.strFutMarketName
       ,m.strFutureMonth
       ,c.strCommodityCode
       ,b.strBook
       ,sb.strSubBook       
       ,case when strBuySell= 'Buy' then intNoOfContract else -intNoOfContract end dblOpenContract1
       ,dblLimit
FROM tblRKFutOptTransaction fot 
JOIN tblCTBook b ON b.intBookId = fot.intBookId and isnull(b.ysnLimitForMonth,0) = 1
JOIN tblCTLimit l on b.intBookId = l.intBookId AND fot.intFutureMarketId=l.intFutureMarketId 
                                                              AND fot.intFutureMonthId=l.intFutureMonthId 
                                                              and fot.intSubBookId=l.intSubBookId
                                                              AND fot.intCommodityId=l.intCommodityId                                                             

JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = fot.intFutureMarketId
JOIN tblRKFuturesMonth m ON m.intFutureMonthId = fot.intFutureMonthId
JOIN tblICCommodity c ON c.intCommodityId = fot.intCommodityId
JOIN tblCTSubBook sb ON sb.intSubBookId = fot.intSubBookId
WHERE fot.intBookId IS NOT NULL AND fot.intSubBookId IS NOT NULL 
       AND fot.intFutureMarketId IN(SELECT intFutureMarketId FROM #temp)
           AND fot.intCommodityId IN(SELECT intCommodityId FROM #temp)
       AND fot.intFutureMonthId in(SELECT intFutureMonthId FROM #temp)
           AND fot.intBookId in(SELECT intBookId FROM #temp)
              AND fot.intSubBookId in(SELECT intSubBookId FROM #temp)
) t
group by strFutMarketName,strFutureMonth,strCommodityCode,strBook,strSubBook, dblLimit
)t1
where dblOpenContract > dblLimit

UNION

SELECT * FROM (
SELECT strFutMarketName,strFutureMonth,strCommodityCode,strBook,strSubBook, sum(dblOpenContract1) dblOpenContract,dblLimit FROM (
SELECT 
       fm.strFutMarketName
       ,null strFutureMonth
       ,c.strCommodityCode
       ,b.strBook
       ,sb.strSubBook       
       ,case when strBuySell= 'Buy' then intNoOfContract else -intNoOfContract end dblOpenContract1
       ,dblLimit
FROM  tblRKFutOptTransaction fot
JOIN tblCTLimit l on fot.intBookId = l.intBookId AND fot.intFutureMarketId=l.intFutureMarketId                                                        
                                                              and fot.intSubBookId=l.intSubBookId
                                                              AND fot.intCommodityId=l.intCommodityId                                                              
JOIN tblCTBook b ON b.intBookId = fot.intBookId and isnull(ysnLimitForMonth,0) = 0
JOIN tblRKFutureMarket fm ON fm.intFutureMarketId = fot.intFutureMarketId
JOIN tblICCommodity c ON c.intCommodityId = fot.intCommodityId
JOIN tblCTSubBook sb ON sb.intSubBookId = fot.intSubBookId
WHERE fot.intBookId IS NOT NULL AND fot.intSubBookId IS NOT NULL
       AND fot.intFutureMarketId IN(SELECT intFutureMarketId FROM #temp)
          AND fot.intCommodityId IN(SELECT intCommodityId FROM #temp)
                  AND fot.intBookId in(SELECT intBookId FROM #temp)
              AND fot.intSubBookId in(SELECT intSubBookId FROM #temp)
          )t1
GROUP BY 
 strFutMarketName,strFutureMonth,strCommodityCode,strBook,strSubBook,dblLimit) t where dblOpenContract > dblLimit )t1