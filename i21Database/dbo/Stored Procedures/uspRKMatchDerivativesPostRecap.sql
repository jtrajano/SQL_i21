CREATE PROCEDURE [dbo].[uspRKMatchDerivativesPostRecap]
	@intMatchFuturesPSHeaderId INT
	, @intUserId INT
AS

BEGIN

	DECLARE @intPostToGLId INT
		, @intCommodityId INT
		, @intFuturesGainOrLossRealized INT
		, @intFuturesGainOrLossRealizedOffset INT
		, @strFuturesGainOrLossRealized NVARCHAR(100)
		, @strFuturesGainOrLossRealizedOffset NVARCHAR(100)
		, @strFuturesGainOrLossRealizedDescription NVARCHAR(100)
		, @strFuturesGainOrLossRealizedOffsetDescription NVARCHAR(100)
		, @strType NVARCHAR(50)
	
	SELECT @intCommodityId = intCommodityId
		, @strType = strType
	FROM tblRKMatchFuturesPSHeader
	WHERE intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId
	
	IF @strType = 'Roll' RETURN
	
	SELECT @intPostToGLId = intPostToGLId
	FROM tblRKCompanyPreference
	
	IF @intPostToGLId = 1
	BEGIN
		SELECT @intFuturesGainOrLossRealized = intFuturesGainOrLossRealizedId
			, @intFuturesGainOrLossRealizedOffset = intFuturesGainOrLossRealizedOffsetId
		FROM tblRKCompanyPreference
		
		SELECT @strFuturesGainOrLossRealized = strAccountId
			, @strFuturesGainOrLossRealizedDescription = strDescription
		FROM tblGLAccount
		WHERE intAccountId = @intFuturesGainOrLossRealized
		
		SELECT @strFuturesGainOrLossRealizedOffset = strAccountId
			, @strFuturesGainOrLossRealizedOffsetDescription = strDescription
		FROM tblGLAccount
		WHERE intAccountId = @intFuturesGainOrLossRealizedOffset
	END
	ELSE
	BEGIN
		SELECT @intFuturesGainOrLossRealized = dbo.fnGetCommodityGLAccountM2M(DEFAULT, @intCommodityId, 'Futures Gain or Loss Realized')
		SELECT @intFuturesGainOrLossRealizedOffset = dbo.fnGetCommodityGLAccountM2M(DEFAULT, @intCommodityId, 'Futures Gain or Loss Realized Offset')

		SELECT @strFuturesGainOrLossRealized = strAccountId
			, @strFuturesGainOrLossRealizedDescription = strDescription
		FROM tblGLAccount 
		WHERE intAccountId = @intFuturesGainOrLossRealized
	
		SELECT @strFuturesGainOrLossRealizedOffset = strAccountId
			, @strFuturesGainOrLossRealizedOffsetDescription = strDescription
		FROM tblGLAccount 
		WHERE intAccountId = @intFuturesGainOrLossRealizedOffset
	END

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
	SELECT dtmPostDate = GETDATE()
		, strBatchId = NULL
		, intAccountId = @intFuturesGainOrLossRealized
		, strAccountId = ISNULL(@strFuturesGainOrLossRealized , 'Invalid Account Id')
		, dblDebit = CASE WHEN ISNULL(dblNetPL, 0) >= 0 THEN 0.00 ELSE ABS(dblNetPL) END
		, dblCredit = CASE WHEN ISNULL(dblNetPL, 0) >= 0 THEN ABS(dblNetPL) ELSE 0.00 END
		, dblDebitUnit = CASE WHEN ISNULL(dblNetPL, 0) >= 0 THEN 0.00 ELSE ABS(dblMatchQty) END
		, dblCreditUnit = CASE WHEN ISNULL(dblNetPL, 0) >= 0 THEN ABS(dblMatchQty) ELSE 0.00 END
		, strAccountDescription = ISNULL(@strFuturesGainOrLossRealizedDescription , 'No Account Id setup on Company Configuration for Futures Gain or Loss Realized')
		, intCurrencyId
		, dblExchangeRate = 0.00
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
	FROM tblRKMatchFuturesPSHeader H
	INNER JOIN vyuRKMatchedPSTransaction M ON M.intMatchFuturesPSHeaderId = H.intMatchFuturesPSHeaderId
	WHERE H.intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId

	--Offset
	UNION ALL SELECT dtmPostDate = GETDATE()
		, strBatchId = NULL
		, intAccountId = @intFuturesGainOrLossRealizedOffset 
		, strAccountId = ISNULL(@strFuturesGainOrLossRealizedOffset , 'Invalid Account Id')
		, dblDebit = CASE WHEN ISNULL(dblNetPL, 0) <= 0 THEN 0.00 ELSE ABS(dblNetPL) END
		, dblCredit = CASE WHEN ISNULL(dblNetPL, 0) <= 0 THEN ABS(dblNetPL) ELSE 0.00 END
		, dblDebitUnit = CASE WHEN ISNULL(dblNetPL, 0) <= 0 THEN 0.00 ELSE ABS(dblMatchQty) END
		, dblCreditUnit = CASE WHEN ISNULL(dblNetPL, 0) <= 0 THEN ABS(dblMatchQty) ELSE 0.00 END
		, strAccountDescription = ISNULL(@strFuturesGainOrLossRealizedDescription , 'No Account Id setup on Company Configuration for Futures Gain or Loss Realized Offset')
		, intCurrencyId
		, dblExchangeRate = 0.00
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
	FROM tblRKMatchFuturesPSHeader H
	INNER JOIN vyuRKMatchedPSTransaction M ON M.intMatchFuturesPSHeaderId = H.intMatchFuturesPSHeaderId
	WHERE H.intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId
END