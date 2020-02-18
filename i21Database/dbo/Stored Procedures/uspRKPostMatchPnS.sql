CREATE PROCEDURE [dbo].[uspRKPostMatchPnS]
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
		, @strLocationName NVARCHAR(100)
		, @strFutMarketName NVARCHAR(100)
		, @intMatchFuturesPSHeaderId INT
		, @GLEntries AS RecapTableType
		, @strBatchId NVARCHAR(100)
		, @intCommodityId INT

	DECLARE @tblResult TABLE (Result NVARCHAR(MAX))
	
	SELECT TOP 1 @intMatchFuturesPSHeaderId = intMatchFuturesPSHeaderId
		, @intCommodityId = intCommodityId
	FROM tblRKMatchFuturesPSHeader WHERE intMatchNo = @intMatchNo
	
	SELECT @dblGrossPL = SUM(dblGrossPL)
		, @dblNetPnL = SUM(dblNetPL)
	FROM vyuRKMatchedPSTransaction
	WHERE intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId
	
	SELECT TOP 1 @strUserName = strExternalERPId
	FROM tblEMEntity
	WHERE strName = @strUserName

	SELECT @intCurrencyId = intCurrencyId
		, @BrokerAccount = strClearingAccountNumber
		, @BrokerName = strName
		, @strBook = strBook
		, @strSubBook = strSubBook
		, @strFutMarketName = strFutMarketName
		, @strLocationName = strLocationName
	FROM tblRKMatchFuturesPSHeader h
	JOIN tblRKFutureMarket fm ON h.intFutureMarketId = fm.intFutureMarketId
	JOIN tblRKBrokerageAccount ba ON ba.intBrokerageAccountId = h.intBrokerageAccountId
	JOIN tblEMEntity e ON h.intEntityId = e.intEntityId
	JOIN tblSMCompanyLocation l ON l.intCompanyLocationId = h.intCompanyLocationId
	LEFT JOIN tblCTBook b ON b.intBookId = h.intBookId
	LEFT JOIN tblCTSubBook sb ON sb.intSubBookId = h.intSubBookId
	WHERE intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId

	IF EXISTS (SELECT TOP 1 1 FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyId)
	BEGIN
		IF EXISTS (SELECT TOP 1 1 FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyId AND ysnSubCurrency = 1)
		BEGIN
			SELECT @intCurrencyId = intMainCurrencyId
			FROM tblSMCurrency
			WHERE intCurrencyID = @intCurrencyId
				AND ysnSubCurrency = 1
		END
	END

	SELECT @strCurrency = strCurrency
	FROM tblSMCurrency
	WHERE intCurrencyID = @intCurrencyId

	--GL Account Validation
	SELECT * INTO #tmpPostRecap
	FROM tblRKMatchDerivativesPostRecap 
	WHERE intTransactionId = @intMatchFuturesPSHeaderId

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpPostRecap)
	BEGIN
		DECLARE @intMatchDerivativesPostRecapId INT
			, @intAccountId INT

		SELECT TOP 1 @intMatchDerivativesPostRecapId = intMatchDerivativesPostRecapId
			, @intAccountId = intAccountId
		FROM #tmpPostRecap

		DECLARE @intFuturesGainOrLossRealized INT
			, @intFuturesGainOrLossRealizedOffset INT
			, @strFuturesGainOrLossRealized NVARCHAR(100)
			, @strFuturesGainOrLossRealizedOffset NVARCHAR(100)
			, @strFuturesGainOrLossRealizedDescription NVARCHAR(100)
			, @strFuturesGainOrLossRealizedOffsetDescription NVARCHAR(100)

		IF (SELECT intPostToGLId FROM tblRKCompanyPreference) = 1
		BEGIN
			SELECT @intFuturesGainOrLossRealized = intFuturesGainOrLossRealizedId
				, @intFuturesGainOrLossRealizedOffset = intFuturesGainOrLossRealizedOffsetId
			FROM tblRKCompanyPreference

			IF ISNULL(@intFuturesGainOrLossRealized, 0) = 0 
			BEGIN
				INSERT INTO @tblResult(Result)
				VALUES('Futures Gain or Loss Realized cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.')
			END
			ELSE
			BEGIN
				IF ISNULL(@intAccountId, 0) = 0
				BEGIN
					SELECT @strFuturesGainOrLossRealized = strAccountId
						, @strFuturesGainOrLossRealizedDescription = strDescription
					FROM tblGLAccount 
					WHERE intAccountId = @intFuturesGainOrLossRealized

					UPDATE tblRKMatchDerivativesPostRecap
					SET intAccountId = @intFuturesGainOrLossRealized
						, strAccountId = @strFuturesGainOrLossRealized
						, strAccountDescription = @strFuturesGainOrLossRealizedDescription
					WHERE dblCredit <> 0 AND intMatchDerivativesPostRecapId = @intMatchDerivativesPostRecapId
				END
			END

			IF ISNULL(@intFuturesGainOrLossRealizedOffset, 0) = 0 
			BEGIN
				INSERT INTO @tblResult(Result)
				VALUES('Futures Gain or Loss Realized Offset cannot be blank. Please set up the default account(s) in Company Configuration Risk Management GL Account tab.')
			END
			ELSE
			BEGIN
				IF ISNULL(@intAccountId, 0) = 0
				BEGIN
					SELECT @strFuturesGainOrLossRealizedOffset = strAccountId 
						, @strFuturesGainOrLossRealizedOffsetDescription = strDescription
					FROM tblGLAccount 
					WHERE intAccountId = @intFuturesGainOrLossRealizedOffset

					UPDATE tblRKMatchDerivativesPostRecap
					SET intAccountId = @intFuturesGainOrLossRealizedOffset
						, strAccountId = @strFuturesGainOrLossRealizedOffset
						, strAccountDescription = @strFuturesGainOrLossRealizedOffsetDescription
					WHERE dblDebit <> 0 AND intMatchDerivativesPostRecapId = @intMatchDerivativesPostRecapId
				END
			END
		END
		ELSE
		BEGIN
			SELECT @intFuturesGainOrLossRealized = dbo.fnGetCommodityGLAccountM2M(DEFAULT, @intCommodityId, 'Futures Gain or Loss Realized')
			SELECT @intFuturesGainOrLossRealizedOffset = dbo.fnGetCommodityGLAccountM2M(DEFAULT, @intCommodityId, 'Futures Gain or Loss Realized Offset')

			IF ISNULL(@intFuturesGainOrLossRealized, 0) = 0 
			BEGIN
				INSERT INTO @tblResult(Result)
				VALUES('Futures Gain or Loss Realized cannot be blank. Please set up the default account(s) in Commodity GL Accounts M2M tab.')
			END
			ELSE
			BEGIN
				IF ISNULL(@intAccountId, 0) = 0
				BEGIN
					SELECT @strFuturesGainOrLossRealized = strAccountId 
						, @strFuturesGainOrLossRealizedDescription = strDescription
					FROM tblGLAccount 
					WHERE intAccountId = @intFuturesGainOrLossRealized

					UPDATE tblRKMatchDerivativesPostRecap
					SET intAccountId = @intFuturesGainOrLossRealized
						, strAccountId = @strFuturesGainOrLossRealized
						, strAccountDescription = @strFuturesGainOrLossRealizedDescription
					WHERE dblCredit <> 0 AND intMatchDerivativesPostRecapId = @intMatchDerivativesPostRecapId
				END
			END

			IF ISNULL(@intFuturesGainOrLossRealizedOffset, 0) = 0 
			BEGIN
				INSERT INTO @tblResult(Result)
				VALUES('Futures Gain or Loss Realized Offset cannot be blank. Please set up the default account(s) in Commodity GL Accounts M2M tab.')
			END
			ELSE
			BEGIN
				IF ISNULL(@intAccountId, 0) = 0
				BEGIN
					SELECT @strFuturesGainOrLossRealizedOffset = strAccountId 
						, @strFuturesGainOrLossRealizedOffsetDescription = strDescription
					FROM tblGLAccount 
					WHERE intAccountId = @intFuturesGainOrLossRealizedOffset

					UPDATE tblRKMatchDerivativesPostRecap
					SET intAccountId = @intFuturesGainOrLossRealizedOffset
						, strAccountId = @strFuturesGainOrLossRealizedOffset
						, strAccountDescription = @strFuturesGainOrLossRealizedOffsetDescription
					WHERE dblDebit <> 0 AND intMatchDerivativesPostRecapId = @intMatchDerivativesPostRecapId
				END
			END
		END

		Delete_Routine:
		
		DELETE FROM #tmpPostRecap WHERE intMatchDerivativesPostRecapId = @intMatchDerivativesPostRecapId
	END
	
	IF (SELECT COUNT(Result) FROM @tblResult) > 0 
	BEGIN
		SELECT DISTINCT * FROM @tblResult
		GOTO Exit_Routine
	END
	
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

	IF (@strBatchId IS NULL)
	BEGIN
		EXEC uspSMGetStartingNumber 3, @strBatchId OUT
	END

	INSERT INTO @GLEntries (dtmDate
		, strBatchId
		, intAccountId
		, dblDebit
		, dblCredit
		, dblDebitUnit
		, dblCreditUnit
		, strDescription
		, intCurrencyId
		, dtmTransactionDate
		, strTransactionId
		, intTransactionId
		, strTransactionType
		, strTransactionForm
		, strModuleName
		, intConcurrencyId
		, dblExchangeRate
		, dtmDateEntered
		, ysnIsUnposted
		, strCode
		, strReference
		, intEntityId
		, intUserId
		, intSourceLocationId
		, intSourceUOMId
		, intCommodityId)
	SELECT dtmPostDate
		, @strBatchId
		, intAccountId
		, ROUND(dblDebit, 2)
		, ROUND(dblCredit, 2)
		, ROUND(dblDebitUnit, 2)
		, ROUND(dblCreditUnit, 2)
		, strAccountDescription
		, intCurrencyId
		, dtmTransactionDate
		, strTransactionId
		, intTransactionId
		, strTransactionType
		, strTransactionForm
		, strModuleName
		, intConcurrencyId
		, dblExchangeRate
		, dtmDateEntered
		, ysnIsUnposted
		, strCode
		, strReference
		, intEntityId
		, intUserId
		, intSourceLocationId
		, intSourceUOMId
		, intCommodityId
	FROM tblRKMatchDerivativesPostRecap
	WHERE intTransactionId = @intMatchFuturesPSHeaderId 

	EXEC dbo.uspGLBookEntries @GLEntries, 1

	UPDATE tblRKMatchFuturesPSHeader
	SET ysnPosted = 1
	WHERE intMatchNo = @intMatchNo

	UPDATE tblRKMatchDerivativesPostRecap
	SET ysnIsUnposted = 1
		, strBatchId = @strBatchId
	WHERE intTransactionId = @intMatchFuturesPSHeaderId

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

Exit_Routine: