CREATE PROCEDURE [dbo].uspRKUnpostMatchPnS
	@intMatchNo INT
	, @strUserName NVARCHAR(100) = NULL

AS

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		, @intCurrencyId INT
		, @intMatchFuturesPSHeaderId INT
		, @GLEntries AS RecapTableType
		, @strBatchId NVARCHAR(100)
		, @intEntityId INT
	
	SELECT TOP 1 @intMatchFuturesPSHeaderId = intMatchFuturesPSHeaderId FROM tblRKMatchFuturesPSHeader WHERE intMatchNo = @intMatchNo

	SELECT TOP 1 @intEntityId = E.intEntityId
	FROM tblEMEntity E
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = E.intEntityId
	WHERE EC.strUserName = @strUserName
	
	BEGIN TRANSACTION
	INSERT INTO tblRKStgMatchPnS(intConcurrencyId
		, intMatchFuturesPSHeaderId
		, intMatchNo
		, dtmMatchDate
		, strCurrency
		, intCompanyLocationId
		, intCommodityId
		, intFutureMarketId
		, intFutureMonthId
		, intEntityId
		, intBrokerageAccountId
		, dblMatchQty
		, dblCommission
		, dblNetPnL
		, dblGrossPnL
		, strBrokerName
		, strBrokerAccount
		, dtmPostingDate
		, strStatus
		, strMessage
		, strUserName
		, strReferenceNo
		, strLocationName
		, strFutMarketName
		, strBook
		, strSubBook
		, ysnPost)
	SELECT TOP 1 1
		, intMatchFuturesPSHeaderId
		, intMatchNo
		, dtmMatchDate
		, strCurrency
		, intCompanyLocationId
		, intCommodityId
		, intFutureMarketId
		, intFutureMonthId
		, intEntityId
		, intBrokerageAccountId
		, -dblMatchQty
		, dblCommission
		, case when dblNetPnL<0 then abs(dblNetPnL) else -dblNetPnL end dblNetPnL
		, case when dblGrossPnL<0 then abs(dblGrossPnL) else -dblGrossPnL end dblGrossPnL
		, strBrokerName
		, strBrokerAccount
		, dtmPostingDate
		, '' strStatus
		, strMessage
		, @strUserName
		, strReferenceNo
		, strLocationName
		, strFutMarketName
		, strBook
		, strSubBook
		, 0
	FROM tblRKStgMatchPnS WHERE intMatchNo = @intMatchNo ORDER BY intStgMatchPnSId DESC
	
	--GL Account Validation
	IF ((SELECT COUNT(intAccountId) FROM tblRKMatchDerivativesPostRecap WHERE intTransactionId = @intMatchFuturesPSHeaderId AND intAccountId IS NULL) > 0)
	BEGIN
		RAISERROR('GL Account is not setup.',16,1)
	END

	IF ((SELECT COUNT(intAccountId) FROM tblRKMatchDerivativesPostRecap WHERE intTransactionId = @intMatchFuturesPSHeaderId ) = 0)
	BEGIN
		
		UPDATE tblRKMatchFuturesPSHeader
		SET ysnPosted = 0
		WHERE intMatchNo = @intMatchNo

		EXEC uspSMAuditLog 
		   @keyValue = @intMatchFuturesPSHeaderId       -- Primary Key Value of the Match Derivatives. 
		   ,@screenName = 'RiskManagement.view.MatchDerivatives'        -- Screen Namespace
		   ,@entityId = @intEntityId     -- Entity Id.
		   ,@actionType = 'Unposted'       -- Action Type
		   ,@changeDescription = ''     -- Description
		   ,@fromValue = ''          -- Previous Value
		   ,@toValue = ''           -- New Value

		COMMIT TRAN
		RETURN
	END
	
	UPDATE tblRKMatchFuturesPSHeader
	SET ysnPosted = 0
	WHERE intMatchNo = @intMatchNo
	
	UPDATE tblRKMatchDerivativesPostRecap
	SET ysnIsUnposted = 0
	WHERE intTransactionId = @intMatchFuturesPSHeaderId

	EXEC uspSMAuditLog 
	   @keyValue = @intMatchFuturesPSHeaderId       -- Primary Key Value of the Match Derivatives. 
	   ,@screenName = 'RiskManagement.view.MatchDerivatives'        -- Screen Namespace
	   ,@entityId = @intEntityId     -- Entity Id.
	   ,@actionType = 'Unposted'       -- Action Type
	   ,@changeDescription = ''     -- Description
	   ,@fromValue = ''          -- Previous Value
	   ,@toValue = ''           -- New Value
	
	COMMIT TRAN
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION
	
	IF @ErrMsg != ''
	BEGIN
		RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH