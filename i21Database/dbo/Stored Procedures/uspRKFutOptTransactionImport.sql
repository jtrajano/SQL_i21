﻿CREATE PROC uspRKFutOptTransactionImport
AS
Begin Try
DECLARE @tblRKFutOptTransactionHeaderId int 
Declare @ErrMsg nvarchar(Max)

DECLARE @strDateTimeFormat nvarchar(50)
DECLARE @ConvertYear int

SELECT @strDateTimeFormat = strDateTimeFormat FROM tblRKCompanyPreference

IF (@strDateTimeFormat = 'MM DD YYYY' OR @strDateTimeFormat ='YYYY MM DD')
SELECT @ConvertYear=101
ELSE IF (@strDateTimeFormat = 'DD MM YYYY' OR @strDateTimeFormat ='YYYY DD MM')
SELECT @ConvertYear=103


DECLARE @strInternalTradeNo int= null
DECLARE @intFutOptTransactionHeaderId int = null
SELECT @strInternalTradeNo=max(convert(int,replace(strInternalTradeNo,'O-',''))) from tblRKFutOptTransaction

BEGIN TRAN
IF NOT EXISTS(SELECT intFutOptTransactionId FROM tblRKFutOptTransactionImport_ErrLog)
BEGIN
INSERT INTO tblRKFutOptTransactionHeader values (1)
SELECT @intFutOptTransactionHeaderId = scope_Identity()
INSERT INTO tblRKFutOptTransaction (intFutOptTransactionHeaderId,intConcurrencyId,dtmTransactionDate,intEntityId,intBrokerageAccountId,intFutureMarketId,
									intInstrumentTypeId,intCommodityId,intLocationId,intTraderId,intCurrencyId,strInternalTradeNo,strBrokerTradeNo,
									strBuySell,intNoOfContract,intFutureMonthId,intOptionMonthId,strOptionType,dblStrike,dblPrice,strReference,strStatus,
									dtmFilledDate,intBookId,intSubBookId)

SELECT DISTINCT @intFutOptTransactionHeaderId,1,getdate(),em.intEntityId,intBrokerageAccountId, fm.intFutureMarketId,
	   CASE WHEN ti.strInstrumentType ='Futures' THEN 1 ELSE 0 END,c.intCommodityId,l.intCompanyLocationId,sp.intEntityId,
	   cur.intCurrencyID,@strInternalTradeNo+1,ti.strBrokerTradeNo,ti.strBuySell,ti.intNoOfContract,
	   m.intFutureMonthId, intOptionMonthId intOptionMonthId,strOptionType,ti.dblStrike,ti.dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,@ConvertYear),b.intBookId,sb.intSubBookId
FROM tblRKFutOptTransactionImport ti
JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
JOIN tblRKBrokerageAccount ba on ba.strAccountNumber=ti.strAccountNumber
JOIN tblEMEntity em on ba.intEntityId=em.intEntityId and em.strName=ti.strName
JOIN tblICCommodity c on c.strCommodityCode=ti.strCommodityCode
JOIN tblSMCompanyLocation l on l.strLocationName=ti.strLocationName 
JOIN vyuHDSalesPerson sp on sp.strName=ti.strSalespersonId
JOIN tblSMCurrency cur on fm.intCurrencyId=cur.intCurrencyID and cur.strCurrency=ti.strCurrency 
JOIN tblRKFuturesMonth m on m.strFutureMonth=replace(ti.strFutureMonth,'-',' ') and m.intFutureMarketId=fm.intFutureMarketId
Left JOIN tblRKOptionsMonth om on om.strOptionMonth=replace(ti.strOptionMonth,'-',' ') and om.intFutureMarketId=fm.intFutureMarketId 
LEFT JOIN tblCTBook b on b.strBook=ti.strBook
LEFT JOIN tblCTSubBook sb on sb.strSubBook=ti.strSubBook 

END

COMMIT TRAN
SELECT  intFutOptTransactionErrLogId,intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
		strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,dblStrike,dblPrice,strReference,strStatus,
		dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg FROM tblRKFutOptTransactionImport_ErrLog
DELETE FROM tblRKFutOptTransactionImport

END TRY
BEGIN CATCH
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
End Catch	
