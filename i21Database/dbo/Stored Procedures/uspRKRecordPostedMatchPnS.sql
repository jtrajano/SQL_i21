CREATE PROCEDURE [dbo].[uspRKRecordPostedMatchPnS]
	@intMatchNo INT
	, @dblGrossPL NUMERIC(24, 10)
	, @dblNetPnL NUMERIC(24, 10)
	, @strUserName NVARCHAR(100) = NULL

AS

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		, @intCurrencyId INT
		, @strCurrency NVARCHAR(50)
		, @BrokerName NVARCHAR(100)
		, @BrokerAccount NVARCHAR(100)
		, @strBook NVARCHAR(100)
		, @strSubBook NVARCHAR(100)
		, @intLocationId INT
		, @strLocationName NVARCHAR(100)
		, @strFutMarketName NVARCHAR(100)
		, @intMatchFuturesPSHeaderId INT
		, @intCommodityId INT
		, @intEntityId INT
		
	DECLARE @tblResult TABLE (Result NVARCHAR(MAX))
	
	SELECT TOP 1 @intMatchFuturesPSHeaderId = intMatchFuturesPSHeaderId
		, @intCommodityId = intCommodityId
	FROM tblRKMatchFuturesPSHeader WHERE intMatchNo = @intMatchNo
	

	SELECT @dblGrossPL = SUM(dblGrossPL)
		, @dblNetPnL = SUM(dblNetPL)
	FROM vyuRKMatchedPSTransaction
	WHERE intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId
	
	SELECT TOP 1 @strUserName = strExternalERPId
		,@intEntityId = E.intEntityId
	FROM tblEMEntity E
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = E.intEntityId
	WHERE EC.strUserName = @strUserName

	SELECT @intCurrencyId = intCurrencyId
		, @BrokerAccount = strClearingAccountNumber
		, @BrokerName = strName
		, @strBook = strBook
		, @strSubBook = strSubBook
		, @strFutMarketName = strFutMarketName
		, @strLocationName = strLocationName
		, @intLocationId = h.intCompanyLocationId
	FROM tblRKMatchFuturesPSHeader h
	JOIN tblRKFutureMarket fm ON h.intFutureMarketId = fm.intFutureMarketId
	JOIN tblRKBrokerageAccount ba ON ba.intBrokerageAccountId = h.intBrokerageAccountId
	JOIN tblEMEntity e ON h.intEntityId = e.intEntityId
	JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = h.intCompanyLocationId
	LEFT JOIN tblCTBook b ON b.intBookId = h.intBookId
	LEFT JOIN tblCTSubBook sb ON sb.intSubBookId = h.intSubBookId
	WHERE intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId

	SELECT @strCurrency = strCurrency
	FROM tblSMCurrency
	WHERE intCurrencyID = @intCurrencyId

	BEGIN TRANSACTION

	INSERT INTO tblRKStgMatchPnS (intConcurrencyId
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
		, dblNetPnL
		, dblGrossPnL
		, strStatus
		, strBrokerName
		, strBrokerAccount
		, dtmPostingDate
		, strUserName
		, strBook
		, strSubBook
		, strLocationName
		, strFutMarketName
		, ysnPost)
	SELECT 0
		, intMatchFuturesPSHeaderId
		, intMatchNo
		, dtmMatchDate
		, @strCurrency
		, intCompanyLocationId
		, intCommodityId
		, intFutureMarketId
		, intFutureMonthId
		, intEntityId
		, intBrokerageAccountId
		, dblMatchQty = ISNULL((SELECT SUM(ISNULL(dblMatchQty, 0))
								FROM tblRKMatchFuturesPSDetail m
								WHERE intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId), 0)
		, @dblNetPnL
		, @dblGrossPL
		, ''
		, @BrokerName
		, @BrokerAccount
		, dtmMatchDate
		, @strUserName
		, @strBook
		, @strSubBook
		, @strLocationName
		, @strFutMarketName
		, 1
	FROM tblRKMatchFuturesPSHeader h
	WHERE intMatchNo = @intMatchNo

	UPDATE tblRKMatchFuturesPSHeader
	SET ysnPosted = 1
	WHERE intMatchNo = @intMatchNo

	UPDATE tblRKMatchDerivativesPostRecap
	SET ysnIsUnposted = 1
	WHERE intTransactionId = @intMatchFuturesPSHeaderId

	EXEC uspSMAuditLog 
	   @keyValue = @intMatchFuturesPSHeaderId       -- Primary Key Value of the Match Derivatives. 
	   ,@screenName = 'RiskManagement.view.MatchDerivatives'        -- Screen Namespace
	   ,@entityId = @intEntityId     -- Entity Id.
	   ,@actionType = 'Posted'       -- Action Type
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