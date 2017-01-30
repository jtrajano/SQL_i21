CREATE VIEW vyuRKGetFilledDate
AS
SELECT top 100 percent CONVERT(INT,ROW_NUMBER() OVER(ORDER BY CONVERT(VARCHAR(10),dtmFilledDate,110))) intRowNum,CONVERT(VARCHAR(11),dtmFilledDate,106) dtmFilledDate from 
(	SELECT DISTINCT  convert(datetime,CONVERT(VARCHAR(10),dtmFilledDate,110)) dtmFilledDate FROM  tblRKFutOptTransaction 
	WHERE CONVERT(VARCHAR(10),dtmFilledDate,110) NOT IN(SELECT CONVERT(VARCHAR(10),dtmFilledDate,110) FROM tblRKReconciliationBrokerStatementHeader 
															WHERE isnull(ysnFreezed,0) = 1) 	
)t order by convert(datetime,CONVERT(VARCHAR(10),dtmFilledDate,110)) asc