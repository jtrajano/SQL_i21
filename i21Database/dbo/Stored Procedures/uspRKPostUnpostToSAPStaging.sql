CREATE PROCEDURE [dbo].[uspRKPostUnpostToSAPStaging]
	  @intMatchNo INT
	, @ysnPost BIT = 0
	, @strUserName NVARCHAR(100) = NULL

AS
BEGIN
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
		, @dblGrossPL NUMERIC(24, 10)
		, @dblNetPnL NUMERIC(24, 10)
		
	SELECT TOP 1 @intMatchFuturesPSHeaderId = intMatchFuturesPSHeaderId
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

	SELECT @intCurrencyId = fm.intCurrencyId
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
	OUTER APPLY (
		SELECT TOP 1 
			  cmba.intBrokerageAccountId
			, cmba.intCurrencyId
			, cmba.strBankAccountNo
		FROM vyuCMBankAccount cmba
		WHERE cmba.intBrokerageAccountId = h.intBrokerageAccountId
	) bankAcct
	LEFT JOIN tblSMCurrency curr
		ON curr.intCurrencyID = bankAcct.intCurrencyId
	WHERE intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId

	SELECT @strCurrency = strCurrency
	FROM tblSMCurrency
	WHERE intCurrencyID = @intCurrencyId
	
	IF (SELECT TOP 1 ysnPost FROM tblRKStgMatchPnS WHERE intMatchNo = @intMatchNo ORDER BY intStgMatchPnSId DESC) = 1
	BEGIN
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
	END
	
	IF (@ysnPost = 1)
	BEGIN
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
	END
END