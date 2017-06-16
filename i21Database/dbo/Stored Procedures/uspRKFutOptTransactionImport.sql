CREATE PROC uspRKFutOptTransactionImport
AS
BEGIN TRY
DECLARE @tblRKFutOptTransactionHeaderId int 
DECLARE @ErrMsg nvarchar(Max)

DECLARE @strDateTimeFormat nvarchar(50)
DECLARE @ConvertYear int

SELECT @strDateTimeFormat = strDateTimeFormat FROM tblRKCompanyPreference

IF (@strDateTimeFormat = 'MM DD YYYY HH:MI' OR @strDateTimeFormat ='YYYY MM DD HH:MI')
SELECT @ConvertYear=101
ELSE IF (@strDateTimeFormat = 'DD MM YYYY HH:MI' OR @strDateTimeFormat ='YYYY DD MM HH:MI')
SELECT @ConvertYear=103

DECLARE @strInternalTradeNo int= null
DECLARE @intFutOptTransactionHeaderId int = null
declare @MaxTranNumber int = null
select @strInternalTradeNo=isnull(intNumber,0)-1 from tblSMStartingNumber where strModule='Risk Management' and strTransactionType='FutOpt Transaction'

BEGIN TRAN
IF NOT EXISTS(SELECT intFutOptTransactionId FROM tblRKFutOptTransactionImport_ErrLog)
BEGIN
INSERT INTO tblRKFutOptTransactionHeader values (1)
SELECT @intFutOptTransactionHeaderId = scope_Identity()

SELECT * INTO #temp FROM(
SELECT DISTINCT @intFutOptTransactionHeaderId intFutOptTransactionHeaderId ,1 intConcurrencyId,
		getdate() dtmTransactionDate,em.intEntityId,intBrokerageAccountId, fm.intFutureMarketId,
	   CASE WHEN ti.strInstrumentType ='Futures' THEN 1 ELSE 2 END intInstrumentTypeId,c.intCommodityId,l.intCompanyLocationId,sp.intEntityId intTraderId,
	   cur.intCurrencyID,isnull(@strInternalTradeNo,0) + ROW_NUMBER() over(order by intFutOptTransactionId) strInternalTradeNo,ti.strBrokerTradeNo,ti.strBuySell,ti.intNoOfContract,
	   m.intFutureMonthId, intOptionMonthId,strOptionType,ti.dblStrike,ti.dblPrice,strReference,strStatus,convert(datetime,dtmCreateDateTime,@ConvertYear) dtmFilledDate,b.intBookId,sb.intSubBookId,convert(datetime,dtmCreateDateTime,@ConvertYear) dtmCreateDateTime
FROM tblRKFutOptTransactionImport ti
JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
JOIN tblRKBrokerageAccount ba on ba.strAccountNumber=ti.strAccountNumber
JOIN tblEMEntity em on ba.intEntityId=em.intEntityId and em.strName=ti.strName
JOIN tblICCommodity c on c.strCommodityCode=ti.strCommodityCode
JOIN tblSMCompanyLocation l on l.strLocationName=ti.strLocationName 
JOIN vyuHDSalesPerson sp on sp.strName=ti.strSalespersonId and sp.strSalesPersonType=  'Sales Rep Entity' and sp.ysnActiveSalesPerson=1
JOIN tblSMCurrency cur on fm.intCurrencyId=cur.intCurrencyID and cur.strCurrency=ti.strCurrency 
JOIN tblRKFuturesMonth m on m.strFutureMonth=replace(ti.strFutureMonth,'-',' ') and m.intFutureMarketId=fm.intFutureMarketId
Left JOIN tblRKOptionsMonth om on om.strOptionMonth=replace(ti.strOptionMonth,'-',' ') and om.intFutureMarketId=fm.intFutureMarketId 
LEFT JOIN tblCTBook b on b.strBook=ti.strBook
LEFT JOIN tblCTSubBook sb on sb.strSubBook=ti.strSubBook)t order by strInternalTradeNo

INSERT INTO tblRKFutOptTransaction (intSelectedInstrumentTypeId,intFutOptTransactionHeaderId,intConcurrencyId,dtmTransactionDate,intEntityId,intBrokerageAccountId,intFutureMarketId,
									intInstrumentTypeId,intCommodityId,intLocationId,intTraderId,intCurrencyId,strInternalTradeNo,strBrokerTradeNo,
									strBuySell,intNoOfContract,intFutureMonthId,intOptionMonthId,strOptionType,dblStrike,dblPrice,strReference,strStatus,
									dtmFilledDate,intBookId,intSubBookId,dtmCreateDateTime)

SELECT 1,* FROM #temp 
END
select @MaxTranNumber=max(strInternalTradeNo) +1 from #temp

UPDATE tblSMStartingNumber SET intNumber=@MaxTranNumber where strModule='Risk Management' and strTransactionType='FutOpt Transaction'
COMMIT TRAN
SELECT  intFutOptTransactionErrLogId,intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
		strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,dblStrike,dblPrice,strReference,strStatus,
		dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg,dtmCreateDateTime FROM tblRKFutOptTransactionImport_ErrLog
DELETE FROM tblRKFutOptTransactionImport

END TRY
BEGIN CATCH
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION    
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
End Catch	