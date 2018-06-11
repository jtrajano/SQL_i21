CREATE PROC [dbo].[uspRKGetOpenContractByDate] 
 
	@intCommodityId int=null,
	@dtmToDate datetime=null
AS

set @dtmToDate=convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
declare @strCommodityCode nvarchar(max)
select @strCommodityCode=strCommodityCode from tblICCommodity where intCommodityId=@intCommodityId

SELECT DISTINCT intFutOptTransactionId,(intNoOfContract-isnull(intOpenContract,0)) intOpenContract from (
SELECT intFutOptTransactionId,sum(intNoOfContract) intNoOfContract,
(SELECT SUM(mf.dblMatchQty) FROM tblRKMatchFuturesPSDetail mf where intFutOptTransactionId=mf.intLFutOptTransactionId) intOpenContract from (
SELECT ROW_NUMBER() OVER (PARTITION BY ot.intFutOptTransactionId ORDER BY ot.dtmTransactionDate DESC) intRowNum,
		ot.intFutOptTransactionId,ot.intNewNoOfContract intNoOfContract	 
FROM tblRKFutOptTransactionHistory ot 
 where ot.strNewBuySell='Buy' and isnull(ot.strInstrumentType,'') = 'Futures'
and convert(DATETIME, CONVERT(VARCHAR(10), ot.dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate)  
and ot.strCommodity=case when isnull(@strCommodityCode,'')='' then ot.strCommodity else @strCommodityCode end 
)t
 WHERE t.intRowNum =1 GROUP BY intFutOptTransactionId) t1

UNION 

SELECT DISTINCT intFutOptTransactionId,-(intNoOfContract-isnull(intOpenContract,0)) intOpenContract from (
SELECT intFutOptTransactionId,sum(intNoOfContract) intNoOfContract,
(SELECT SUM(mf.dblMatchQty) FROM tblRKMatchFuturesPSDetail mf where intFutOptTransactionId=mf.intLFutOptTransactionId) intOpenContract from (
SELECT ROW_NUMBER() OVER (PARTITION BY ot.intFutOptTransactionId ORDER BY ot.dtmTransactionDate DESC) intRowNum,
		ot.intFutOptTransactionId,ot.intNewNoOfContract intNoOfContract	 
FROM tblRKFutOptTransactionHistory ot 
where ot.strNewBuySell='Sell' and isnull(ot.strInstrumentType,'') = 'Futures'
and convert(DATETIME, CONVERT(VARCHAR(10), ot.dtmTransactionDate, 110), 110) <= convert(datetime,@dtmToDate) 
and ot.strCommodity=case when isnull(@strCommodityCode,'')='' then ot.strCommodity else @strCommodityCode end 
)t WHERE t.intRowNum =1 GROUP BY intFutOptTransactionId) t1

UNION

SELECT distinct intFutOptTransactionId,(isnull(intNoOfContract,0)-isnull(intOpenContract,0)) intOpenContract from (
SELECT ot.intFutOptTransactionId,sum(isnull(ot.intNoOfContract,0)) intNoOfContract,
	   (SELECT SUM(mf.intMatchQty) FROM tblRKOptionsMatchPnS mf where ot.intFutOptTransactionId=mf.intLFutOptTransactionId) intOpenContract
FROM tblRKFutOptTransaction ot where ot.strBuySell='Buy' and intInstrumentTypeId = 2
Group by intFutOptTransactionId) t

UNION 

SELECT distinct intFutOptTransactionId,-(intNoOfContract-isnull(intOpenContract,0)) intOpenContract from (
SELECT ot.intFutOptTransactionId,sum(ot.intNoOfContract) intNoOfContract,
	   (SELECT SUM(mf.intMatchQty) FROM tblRKOptionsMatchPnS mf where ot.intFutOptTransactionId=mf.intSFutOptTransactionId) intOpenContract
FROM tblRKFutOptTransaction ot where ot.strBuySell='Sell' and intInstrumentTypeId = 2
GROUP BY intFutOptTransactionId) t