CREATE PROC [dbo].uspRKUnpostMatchPnS
 @intMatchNo INT 
	,@strUserName NVARCHAR(100) = null
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(Max)
	DECLARE @intCurrencyId INT
	DECLARE @intMatchFuturesPSHeaderId INT
	DECLARE @GLEntries AS RecapTableType
	DECLARE @strBatchId NVARCHAR(100)

	select top 1 @intMatchFuturesPSHeaderId=intMatchFuturesPSHeaderId from tblRKMatchFuturesPSHeader where intMatchNo=@intMatchNo

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

	--GL Account Validation
	IF ((SELECT COUNT(intAccountId) FROM tblRKMatchDerivativesPostRecap WHERE intTransactionId = @intMatchFuturesPSHeaderId AND intAccountId IS NULL) > 0)
	BEGIN
		RAISERROR('GL Account is not setup.',16,1)
	END

	IF (@strBatchId IS NULL)
	BEGIN
		EXEC uspSMGetStartingNumber 3, @strBatchId OUT
	END

	INSERT INTO @GLEntries (
		 [dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[intCurrencyId]
		,[dtmTransactionDate]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[ysnIsUnposted]
		,[strCode]
		,[strReference]  
		,[intEntityId]
		,[intUserId]      
		,[intSourceLocationId]
		,[intSourceUOMId]
		,[intCommodityId]
		)
	SELECT 
		dtmPostDate
		,@strBatchId
		,intAccountId
		,ROUND(dblCredit,2)
		,ROUND(dblDebit,2)
		,ROUND(dblCreditUnit,2)
		,ROUND(dblDebitUnit,2)
		,strAccountDescription
		,intCurrencyId
		,dtmTransactionDate
		,strTransactionId
		,intTransactionId
		,strTransactionType
		,strTransactionForm
		,strModuleName
		,intConcurrencyId
		,dblExchangeRate
		,dtmDateEntered
		,ysnIsUnposted
		,strCode
		,strReference
		,intEntityId
		,intUserId
		,intSourceLocationId
		,intSourceUOMId
		,intCommodityId
	FROM tblRKMatchDerivativesPostRecap
	WHERE intTransactionId = @intMatchFuturesPSHeaderId 

	EXEC dbo.uspGLBookEntries @GLEntries,0

	UPDATE tblRKMatchFuturesPSHeader
	SET ysnPosted = 0
	WHERE intMatchNo = @intMatchNo

	UPDATE tblRKMatchDerivativesPostRecap
	SET ysnIsUnposted = 0, strReversalBatchId = @strBatchId
	WHERE intTransactionId = @intMatchFuturesPSHeaderId

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