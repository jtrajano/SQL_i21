CREATE PROC [dbo].uspRKUnpostMatchPnS
 @intMatchNo INT 
	,@strUserName NVARCHAR(100) = null
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(Max)
	DECLARE @intCurrencyId INT

BEGIN TRANSACTION
INSERT INTO tblRKStgMatchPnS(intConcurrencyId,
intMatchFuturesPSHeaderId,
intMatchNo,
dtmMatchDate,
strCurrency,
intCompanyLocationId,
intCommodityId,
intFutureMarketId,
intFutureMonthId,
intEntityId,
intBrokerageAccountId,
dblMatchQty,
dblCommission,
dblNetPnL,
dblGrossPnL,
strBrokerName,
strBrokerAccount,
dtmPostingDate,
strStatus,
strMessage,
strUserName,
strReferenceNo,
strLocationName,
strFutMarketName,
strBook,
strSubBook
,ysnPost)

SELECT top 1 1,
intMatchFuturesPSHeaderId,
intMatchNo,
dtmMatchDate,
strCurrency,
intCompanyLocationId,
intCommodityId,
intFutureMarketId,
intFutureMonthId,
intEntityId,
intBrokerageAccountId,
-dblMatchQty,
dblCommission,
case when dblNetPnL<0 then abs(dblNetPnL) else -dblNetPnL end dblNetPnL,
case when dblGrossPnL<0 then abs(dblGrossPnL) else -dblGrossPnL end dblGrossPnL,
strBrokerName,
strBrokerAccount,
dtmPostingDate,
'' strStatus,
strMessage,
@strUserName ,
strReferenceNo,
strLocationName,
strFutMarketName,
strBook,
strSubBook,
0
FROM tblRKStgMatchPnS WHERE intMatchNo = @intMatchNo order by intStgMatchPnSId desc

	UPDATE tblRKMatchFuturesPSHeader
	SET ysnPosted = 0
	WHERE intMatchNo = @intMatchNo

	COMMIT TRAN
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	IF @ErrMsg != ''
	BEGIN
		RAISERROR (
				@ErrMsg
				,16
				,1
				,'WITH NOWAIT'
				)
	END
END CATCH