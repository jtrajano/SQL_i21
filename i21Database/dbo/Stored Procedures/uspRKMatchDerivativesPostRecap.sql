CREATE PROCEDURE [dbo].[uspRKMatchDerivativesPostRecap]
	@intMatchFuturesPSHeaderId INT
	, @intUserId INT
AS

BEGIN

	DECLARE @intPostToGLId INT
		, @intCommodityId INT
		, @intLocationId INT
		, @intFuturesGainOrLossRealized INT
		, @intFuturesGainOrLossRealizedOffset INT
		, @strFuturesGainOrLossRealized NVARCHAR(100)
		, @strFuturesGainOrLossRealizedOffset NVARCHAR(100)
		, @strFuturesGainOrLossRealizedDescription NVARCHAR(250)
		, @strFuturesGainOrLossRealizedOffsetDescription NVARCHAR(250)
		, @strType NVARCHAR(50)
	
	SELECT @intCommodityId = intCommodityId
		, @strType = strType
		, @intLocationId = intCompanyLocationId
	FROM tblRKMatchFuturesPSHeader
	WHERE intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId
	
	IF @strType = 'Roll' RETURN

	DECLARE @GLAccounts TABLE(strCategory NVARCHAR(100)
		, intAccountId INT
		, strAccountNo NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, ysnHasError BIT
		, strErrorMessage NVARCHAR(250) COLLATE Latin1_General_CI_AS)

	INSERT INTO @GLAccounts
	EXEC uspRKGetGLAccountsForPosting @intCommodityId = @intCommodityId
		, @intLocationId = @intLocationId

	SELECT TOP 1 @intFuturesGainOrLossRealized = rk.intAccountId
		, @strFuturesGainOrLossRealized = strAccountNo
		, @strFuturesGainOrLossRealizedDescription = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE gl.strDescription END
	FROM @GLAccounts rk
	LEFT JOIN tblGLAccount gl ON gl.intAccountId = rk.intAccountId
	WHERE strCategory = 'intFuturesGainOrLossRealizedId'

	SELECT TOP 1 @intFuturesGainOrLossRealizedOffset = rk.intAccountId
		, @strFuturesGainOrLossRealizedOffset = strAccountNo
		, @strFuturesGainOrLossRealizedOffsetDescription = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE gl.strDescription END
	FROM @GLAccounts rk
	LEFT JOIN tblGLAccount gl ON gl.intAccountId = rk.intAccountId
	WHERE strCategory = 'intFuturesGainOrLossRealizedOffsetId'
	
	DELETE FROM tblRKMatchDerivativesPostRecap WHERE intTransactionId = @intMatchFuturesPSHeaderId

	INSERT INTO tblRKMatchDerivativesPostRecap (dtmPostDate
		, strBatchId
		, intAccountId
		, strAccountId
		, dblDebit
		, dblCredit
		, dblDebitUnit
		, dblCreditUnit
		, strAccountDescription
		, intCurrencyId
		, dblExchangeRate
		, dtmTransactionDate
		, strTransactionId
		, intTransactionId
		, strReference
		, strTransactionType
		, strTransactionForm
		, strModuleName
		, strCode
		, dtmDateEntered
		, ysnIsUnposted
		, intUserId
		, intEntityId
		, intSourceLocationId
		, intSourceUOMId
		, intCommodityId)
	SELECT dtmPostDate
		, strBatchId
		, intAccountId
		, strAccountId
		, dblDebit
		, dblCredit
		, dblDebitUnit
		, dblCreditUnit
		, strAccountDescription
		, intCurrencyId
		, dblExchangeRate
		, dtmTransactionDate
		, strTransactionId
		, intTransactionId
		, strReference
		, strTransactionType
		, strTransactionForm
		, strModuleName
		, strCode
		, dtmDateEntered
		, ysnIsUnposted
		, intUserId
		, intEntityId
		, intSourceLocationId
		, intSourceUOMId
		, intCommodityId
	FROM (
		SELECT dtmPostDate = H.dtmMatchDate
			, strBatchId = NULL
			, intAccountId = @intFuturesGainOrLossRealized
			, strAccountId = ISNULL(@strFuturesGainOrLossRealized , 'Invalid Account Id')
			, dblDebit = CASE WHEN ISNULL(dblNetPL, 0) >= 0 THEN 0.00 ELSE ABS(dblNetPL) END
			, dblCredit = CASE WHEN ISNULL(dblNetPL, 0) >= 0 THEN ABS(dblNetPL) ELSE 0.00 END
			, dblDebitUnit = CASE WHEN ISNULL(dblNetPL, 0) >= 0 THEN 0.00 ELSE ABS(dblMatchQty) END
			, dblCreditUnit = CASE WHEN ISNULL(dblNetPL, 0) >= 0 THEN ABS(dblMatchQty) ELSE 0.00 END
			, strAccountDescription = @strFuturesGainOrLossRealizedDescription
			, intCurrencyId
			, dblExchangeRate = 1.00
			, dtmTransactionDate = dtmMatchDate
			, strTransactionId = H.intMatchNo
			, intTransactionId = H.intMatchFuturesPSHeaderId
			, strReference = H.intMatchNo
			, strTransactionType = 'Match Derivatives'
			, strTransactionForm = 'Match Derivatives'
			, strModuleName = 'Risk Management'
			, strCode = 'RK'
			, dtmDateEntered = GETDATE()
			, ysnIsUnposted = 0
			, intEntityId = @intUserId
			, intUserId = @intUserId 
			, intSourceLocationId = H.intCompanyLocationId
			, intSourceUOMId = intCurrencyId
			, H.intCommodityId
			, M.intMatchFuturesPSDetailId
			, intSort = 1
		FROM tblRKMatchFuturesPSHeader H
		INNER JOIN vyuRKMatchedPSTransaction M ON M.intMatchFuturesPSHeaderId = H.intMatchFuturesPSHeaderId
		WHERE H.intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId

		--Offset
		UNION ALL SELECT dtmPostDate = H.dtmMatchDate
			, strBatchId = NULL
			, intAccountId = @intFuturesGainOrLossRealizedOffset 
			, strAccountId = ISNULL(@strFuturesGainOrLossRealizedOffset , 'Invalid Account Id')
			, dblDebit = CASE WHEN ISNULL(dblNetPL, 0) <= 0 THEN 0.00 ELSE ABS(dblNetPL) END
			, dblCredit = CASE WHEN ISNULL(dblNetPL, 0) <= 0 THEN ABS(dblNetPL) ELSE 0.00 END
			, dblDebitUnit = CASE WHEN ISNULL(dblNetPL, 0) <= 0 THEN 0.00 ELSE ABS(dblMatchQty) END
			, dblCreditUnit = CASE WHEN ISNULL(dblNetPL, 0) <= 0 THEN ABS(dblMatchQty) ELSE 0.00 END
			, strAccountDescription = @strFuturesGainOrLossRealizedOffsetDescription
			, intCurrencyId
			, dblExchangeRate = 1.00
			, dtmTransactionDate = dtmMatchDate
			, strTransactionId = H.intMatchNo
			, intTransactionId = H.intMatchFuturesPSHeaderId
			, strReference = H.intMatchNo
			, strTransactionType = 'Match Derivatives'
			, strTransactionForm = 'Match Derivatives'
			, strModuleName = 'Risk Management'
			, strCode = 'RK'
			, dtmDateEntered = GETDATE()
			, ysnIsUnposted = 0
			, intEntityId = @intUserId
			, intUserId = @intUserId 
			, intSourceLocationId = H.intCompanyLocationId
			, intSourceUOMId = intCurrencyId
			, H.intCommodityId
			, M.intMatchFuturesPSDetailId
			, intSort = 2
		FROM tblRKMatchFuturesPSHeader H
		INNER JOIN vyuRKMatchedPSTransaction M ON M.intMatchFuturesPSHeaderId = H.intMatchFuturesPSHeaderId
		WHERE H.intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId
	) t
	ORDER BY intMatchFuturesPSDetailId, intSort
END