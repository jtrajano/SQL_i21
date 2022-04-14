﻿CREATE PROCEDURE [dbo].[uspRKPostMatchPnS]
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

	DECLARE @GLAccounts TABLE(strCategory NVARCHAR(100)
		, intAccountId INT
		, strAccountNo NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, ysnHasError BIT
		, strErrorMessage NVARCHAR(250) COLLATE Latin1_General_CI_AS)

	INSERT INTO @GLAccounts
	EXEC uspRKGetGLAccountsForPosting @intCommodityId = @intCommodityId
		, @intLocationId = @intLocationId

	--GL Account Validation
	SELECT * INTO #tmpPostRecap
	FROM tblRKMatchDerivativesPostRecap 
	WHERE intTransactionId = @intMatchFuturesPSHeaderId

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpPostRecap)
	BEGIN
		DECLARE @intMatchDerivativesPostRecapId INT
			, @intAccountId INT
			, @strAccountNo NVARCHAR(50)
			, @strDescription NVARCHAR(MAX)
			, @strTransactionType NVARCHAR(250)
			, @strErrorMessage NVARCHAR(MAX)
			, @ysnHasError BIT

		SELECT TOP 1 @intMatchDerivativesPostRecapId = intMatchDerivativesPostRecapId
			, @strTransactionType = CASE WHEN vyu.dblNetPL > 0
											THEN CASE WHEN r.dblDebit > 0 THEN 'Futures Gain or Loss Realized Offset' ELSE 'Futures Gain or Loss Realized' END
										ELSE CASE WHEN r.dblDebit > 0 THEN 'Futures Gain or Loss Realized' ELSE 'Futures Gain or Loss Realized Offset' END END
		FROM #tmpPostRecap r
		LEFT JOIN vyuRKMatchedPSTransaction vyu ON vyu.intMatchFuturesPSHeaderId = r.intTransactionId


		DECLARE @intFuturesGainOrLossAccountId INT
			, @strFuturesGainOrLossAccountNo NVARCHAR(100)
			, @strFuturesGainOrLossAccountDescription NVARCHAR(250)

		IF (@strTransactionType = 'Futures Gain or Loss Realized')
		BEGIN
			SELECT TOP 1 @intFuturesGainOrLossAccountId = rk.intAccountId
				, @strFuturesGainOrLossAccountNo = strAccountNo
				, @strFuturesGainOrLossAccountDescription = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE gl.strDescription END
				, @strErrorMessage = strErrorMessage
				, @ysnHasError = ysnHasError
			FROM @GLAccounts rk
			LEFT JOIN tblGLAccount gl ON gl.intAccountId = rk.intAccountId
			WHERE strCategory = 'intFuturesGainOrLossRealizedId'
		END
		ELSE IF (@strTransactionType = 'Futures Gain or Loss Realized Offset')
		BEGIN
			SELECT TOP 1 @intFuturesGainOrLossAccountId = rk.intAccountId
				, @strFuturesGainOrLossAccountNo = strAccountNo
				, @strFuturesGainOrLossAccountDescription = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE gl.strDescription END
				, @strErrorMessage = strErrorMessage
				, @ysnHasError = ysnHasError
			FROM @GLAccounts rk
			LEFT JOIN tblGLAccount gl ON gl.intAccountId = rk.intAccountId
			WHERE strCategory = 'intFuturesGainOrLossRealizedOffsetId'
		END

		IF (@ysnHasError = 1)
		BEGIN
			INSERT INTO @tblResult(Result)
			VALUES(@strErrorMessage)
		END
		ELSE
		BEGIN
			UPDATE tblRKMatchDerivativesPostRecap
			SET intAccountId = @intFuturesGainOrLossAccountId
				, strAccountId = @strFuturesGainOrLossAccountNo
				, strAccountDescription = @strFuturesGainOrLossAccountDescription
			WHERE intMatchDerivativesPostRecapId = @intMatchDerivativesPostRecapId
		END
		
		DELETE FROM #tmpPostRecap WHERE intMatchDerivativesPostRecapId = @intMatchDerivativesPostRecapId
	END
	
	DROP TABLE #tmpPostRecap

	IF EXISTS (SELECT TOP 1 '' FROM @tblResult)
	BEGIN
		SELECT DISTINCT Result
		FROM @tblResult

		GOTO Exit_Routine
	END
	
	SELECT	  Result = '' -- No Error Message
			, intAccountId
			, strAccountId
			, strAccountDescription
			, dblDebit = ROUND(dblDebit, 2)
			, dblCredit = ROUND(dblCredit, 2)
			, dblDebitUnit = ROUND(dblDebitUnit, 2)
			, dblCreditUnit = ROUND(dblCreditUnit, 2)
			, intCurrencyId
	INTO #tmpMatchDerivativesPostRecap
	FROM tblRKMatchDerivativesPostRecap
	WHERE intTransactionId = @intMatchFuturesPSHeaderId 
	AND (	(ROUND(dblDebit, 2) <> 0 AND ROUND(dblCredit, 2) = 0)
			OR (ROUND(dblCredit, 2) <> 0 AND ROUND(dblDebit, 2) = 0)
		)

	IF NOT EXISTS (SELECT TOP 1 '' FROM #tmpMatchDerivativesPostRecap)
	BEGIN
		SELECT Result = 'Match could not be posted due to matching of derivatives resulting to 0 Gross PnL.'
	END
	ELSE 
	BEGIN
		SELECT * FROM #tmpMatchDerivativesPostRecap
	END

	DROP TABLE #tmpMatchDerivativesPostRecap
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