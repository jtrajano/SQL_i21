CREATE VIEW vyuRKGetFilledDate
AS
SELECT top 100 percent CONVERT(INT,ROW_NUMBER() OVER(ORDER BY CONVERT(VARCHAR(10),dtmFilledDate,110))) intRowNum,CONVERT(VARCHAR(11),dtmFilledDate,106) dtmFilledDate from 
(	SELECT DISTINCT  convert(datetime,CONVERT(VARCHAR(10),dtmFilledDate,110)) dtmFilledDate FROM  tblRKFutOptTransaction t
	WHERE CONVERT(VARCHAR(10),dtmFilledDate,110) NOT IN(SELECT CONVERT(VARCHAR(10),dtmFilledDate,110) FROM tblRKReconciliationBrokerStatementHeader t1
															WHERE isnull(t.ysnFreezed,0) = 1 and t.intFutureMarketId=t1.intFutureMarketId
																and t.intBrokerageAccountId=t1.intBrokerageAccountId and t.intCommodityId=t1.intCommodityId
																and t.intEntityId=t1.intEntityId) 	
)t  WHERE dtmFilledDate IS NOT NULL ORDER BY CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmFilledDate,110)) asc