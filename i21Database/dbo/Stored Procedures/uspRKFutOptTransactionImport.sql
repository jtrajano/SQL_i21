CREATE PROC uspRKFutOptTransactionImport
	@intEntityUserId VARCHAR (100) = NULL
AS
BEGIN TRY
DECLARE @tblRKFutOptTransactionHeaderId int 
DECLARE @ErrMsg nvarchar(Max)

DECLARE @strDateTimeFormat nvarchar(50)
DECLARE @ConvertYear int

SELECT @strDateTimeFormat = strDateTimeFormat FROM tblRKCompanyPreference

IF (@strDateTimeFormat = 'MM DD YYYY HH:MI' OR @strDateTimeFormat ='YYYY MM DD HH:MI' OR @strDateTimeFormat = 'MM DD YYYY' OR @strDateTimeFormat ='YYYY MM DD')
SELECT @ConvertYear=101
ELSE IF (@strDateTimeFormat = 'DD MM YYYY HH:MI' OR @strDateTimeFormat ='YYYY DD MM HH:MI' OR @strDateTimeFormat = 'DD MM YYYY' OR @strDateTimeFormat ='YYYY DD MM')
SELECT @ConvertYear=103

DECLARE @strInternalTradeNo nvarchar(50)= null
DECLARE @intFutOptTransactionHeaderId int = null
declare @MaxTranNumber int = null

BEGIN TRAN
IF NOT EXISTS(SELECT intFutOptTransactionId FROM tblRKFutOptTransactionImport_ErrLog)
BEGIN
INSERT INTO tblRKFutOptTransactionHeader (intConcurrencyId,dtmTransactionDate,intSelectedInstrumentTypeId,strSelectedInstrumentType) 
		VALUES (1,getdate(),1,'Exchange Traded')
SELECT @intFutOptTransactionHeaderId = scope_Identity()

SELECT * INTO #temp FROM(
SELECT DISTINCT @intFutOptTransactionHeaderId intFutOptTransactionHeaderId ,1 intConcurrencyId,
		getdate() dtmTransactionDate,em.intEntityId,intBrokerageAccountId, fm.intFutureMarketId,
	   CASE WHEN ti.strInstrumentType ='Futures' THEN 1 ELSE 2 END intInstrumentTypeId,c.intCommodityId,l.intCompanyLocationId,sp.intEntityId intTraderId,
	   cur.intCurrencyID, ROW_NUMBER() over(order by intFutOptTransactionId) strInternalTradeNo,ti.strBrokerTradeNo,ti.strBuySell,ti.intNoOfContract,
	   m.intFutureMonthId, intOptionMonthId,strOptionType,ti.dblStrike,ti.dblPrice,strReference,strStatus,convert(datetime,ti.dtmFilledDate,@ConvertYear) dtmFilledDate,b.intBookId,sb.intSubBookId,convert(datetime,dtmCreateDateTime,@ConvertYear) dtmCreateDateTime
FROM tblRKFutOptTransactionImport ti
JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
JOIN tblRKBrokerageAccount ba on ba.strAccountNumber=ti.strAccountNumber
JOIN tblEMEntity em on ba.intEntityId=em.intEntityId and em.strName=ti.strName
JOIN tblICCommodity c on c.strCommodityCode=ti.strCommodityCode
JOIN tblSMCompanyLocation l on l.strLocationName=ti.strLocationName 
JOIN vyuHDSalesPerson sp on sp.strName=ti.strSalespersonId and sp.strSalesPersonType=  'Sales Rep Entity' and sp.ysnActiveSalesPerson=1
JOIN tblSMCurrency cur on  cur.strCurrency=ti.strCurrency 
JOIN tblRKFuturesMonth m on m.strFutureMonth=replace(ti.strFutureMonth,'-',' ') and m.intFutureMarketId=fm.intFutureMarketId
Left JOIN tblRKOptionsMonth om on om.strOptionMonth=replace(ti.strOptionMonth,'-',' ') and om.intFutureMarketId=fm.intFutureMarketId 
LEFT JOIN tblCTBook b on b.strBook=ti.strBook
LEFT JOIN tblCTSubBook sb on sb.strSubBook=ti.strSubBook
where isnull(ti.strName,'') <> '' and isnull(ti.strFutMarketName,'') <> '' and isnull(ti.strInstrumentType,'') <> ''
AND isnull(ti.strAccountNumber,'') <> '' and isnull(ti.strCommodityCode,'') <> '' and isnull(ti.strLocationName,'') <> '' and isnull(ti.strSalespersonId,'') <> ''
)t order by strInternalTradeNo


WHILE EXISTS (SELECT TOP 1 * FROM #temp)
BEGIN
	DECLARE @id int

	SELECT TOP 1 @id = strInternalTradeNo FROM #temp

	EXEC uspSMGetStartingNumber 45, @strInternalTradeNo OUTPUT

	INSERT INTO tblRKFutOptTransaction (
		intSelectedInstrumentTypeId
		,intFutOptTransactionHeaderId
		,intConcurrencyId
		,dtmTransactionDate
		,intEntityId
		,intBrokerageAccountId
		,intFutureMarketId
		,intInstrumentTypeId
		,intCommodityId
		,intLocationId
		,intTraderId
		,intCurrencyId
		,strInternalTradeNo
		,strBrokerTradeNo
		,strBuySell
		,dblNoOfContract
		,intFutureMonthId
		,intOptionMonthId
		,strOptionType
		,dblStrike
		,dblPrice
		,strReference
		,strStatus
		,dtmFilledDate
		,intBookId
		,intSubBookId
		,dtmCreateDateTime)

	SELECT 1
		,intFutOptTransactionHeaderId
		,intConcurrencyId
		,dtmTransactionDate
		,intEntityId
		,intBrokerageAccountId
		,intFutureMarketId
		,intInstrumentTypeId
		,intCommodityId
		,intCompanyLocationId
		,intTraderId
		,intCurrencyID
		,@strInternalTradeNo
		,strBrokerTradeNo
		,strBuySell
		,intNoOfContract
		,intFutureMonthId
		,intOptionMonthId
		,strOptionType
		,dblStrike
		,dblPrice
		,strReference
		,strStatus
		,dtmFilledDate
		,intBookId
		,intSubBookId
		,dtmCreateDateTime 
	FROM #temp 
	WHERE strInternalTradeNo = @id
	
	DELETE FROM  #temp WHERE strInternalTradeNo = @id

END


END
--SELECT @MaxTranNumber=max(strInternalTradeNo) +1 from #temp

--UPDATE tblSMStartingNumber SET intNumber= intNumber + 1 where intStartingNumberId=45
COMMIT TRAN
--SELECT  intFutOptTransactionErrLogId,intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
--		strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,dblStrike,dblPrice,strReference,strStatus,
--		dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg,dtmCreateDateTime FROM tblRKFutOptTransactionImport_ErrLog

--This will return the newly created Derivative Entry
SELECT DE.strInternalTradeNo AS Result1,DE.strBrokerTradeNo AS Result2,DE.dtmFilledDate AS Result3 
FROM tblRKFutOptTransaction DE 
WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId

BEGIN
EXEC	dbo.uspSMAuditLog 
		@keyValue = @intFutOptTransactionHeaderId			  -- Primary Key Value of the Derivative Entry. 
		,@screenName = 'RiskManagement.view.DerivativeEntry'  -- Screen Namespace
		,@entityId = @intEntityUserId                   	  -- Entity Id
		,@actionType = 'Imported'                             -- Action Type
		,@changeDescription = ''							  -- Description
		,@fromValue = ''									  -- Previous Value
		,@toValue = ''										  -- New Value
END

DELETE FROM tblRKFutOptTransactionImport

END TRY
BEGIN CATCH
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION    
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
End Catch	