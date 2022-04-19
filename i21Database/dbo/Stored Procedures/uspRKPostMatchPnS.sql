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
		, @intBankTransactionId INT = NULL
		, @strBrokerBankAccount NVARCHAR(MAX) = NULL
		, @strBankTransactionId NVARCHAR(100)
		, @intBankAccountCurrencyId INT = NULL
		, @strBankAccountCurrency NVARCHAR(100)
		, @intFunctionalCurrencyId INT = NULL
		, @strFunctionalCurrency NVARCHAR(100)
		

	DECLARE @tblResult TABLE (Result NVARCHAR(MAX))

	SELECT @intFunctionalCurrencyId = intDefaultCurrencyId 
		, @strFunctionalCurrency = curr.strCurrency
	FROM tblSMCompanyPreference sm
	LEFT JOIN tblSMCurrency curr
		ON curr.intCurrencyID = sm.intDefaultCurrencyId

	IF ISNULL(@intFunctionalCurrencyId, 0) = 0
	BEGIN
		SELECT Result = 'Missing Functional Currency Setup.'
			, intBankTransactionId = @intBankTransactionId
		
		GOTO Exit_Routine
	END

	SELECT TOP 1 @intBankTransactionId = bth.intTransactionId 
			, @strBankTransactionId = bth.strTransactionId FROM tblCMBankTransactionDetail btd
	LEFT JOIN tblCMBankTransaction bth
		ON bth.intTransactionId = btd.intTransactionId
	WHERE intMatchDerivativeNo = @intMatchNo

	IF ISNULL(@intBankTransactionId, 0) <> 0
	BEGIN
		SELECT Result = 'Match already has Bank Transaction created. Please refer to ' + @strBankTransactionId + '.'
			, intBankTransactionId = @intBankTransactionId
		
		GOTO Exit_Routine
	END
	
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

	SELECT @intCurrencyId = fm.intCurrencyId
		, @BrokerAccount = strClearingAccountNumber
		, @BrokerName = strName
		, @strBook = strBook
		, @strSubBook = strSubBook
		, @strFutMarketName = strFutMarketName
		, @strLocationName = strLocationName
		, @intLocationId = h.intCompanyLocationId
		, @strBrokerBankAccount = bankAcct.strBankAccountNo
		, @intBankAccountCurrencyId = bankAcct.intCurrencyId
		, @strBankAccountCurrency = curr.strCurrency
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
	
	IF ISNULL(@intBankAccountCurrencyId, 0) = 0
	BEGIN
		SELECT Result = 'Brokerage Account Selected is not assigned to Any Bank Account.'
		GOTO Exit_Routine
	END

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
			-- CONVERSION TO FUNCTIONAL CURRENCY DUE TO CHANGES FOR POSTING TO BANK TRANSACTION
			, dblDebit = ROUND(dbo.fnRKGetCurrencyConvertion(@intCurrencyId, @intFunctionalCurrencyId) * dblDebit, 2)
			, dblCredit = ROUND(dbo.fnRKGetCurrencyConvertion(@intCurrencyId, @intFunctionalCurrencyId) * dblCredit, 2)
			, dblDebitUnit = ROUND(dblDebitUnit, 2)
			, dblCreditUnit = ROUND(dblCreditUnit, 2)
			, intCurrencyId
			, strSourceTransactionNo
			, ysnForeignCurrency = CASE WHEN ISNULL(@intBankAccountCurrencyId, 0) = 0 THEN CAST(0 AS BIT)
								WHEN @intFunctionalCurrencyId <> @intBankAccountCurrencyId 
									THEN CAST(1 AS BIT) 
								ELSE CAST(0 AS BIT)
								END
	INTO #tmpMatchDerivativesPostRecap
	FROM tblRKMatchDerivativesPostRecap
	WHERE intTransactionId = @intMatchFuturesPSHeaderId 
	AND (	(ROUND(dblDebit, 2) <> 0 AND ROUND(dblCredit, 2) = 0)
			OR (ROUND(dblCredit, 2) <> 0 AND ROUND(dblDebit, 2) = 0)
		)

	IF NOT EXISTS (SELECT TOP 1 '' FROM #tmpMatchDerivativesPostRecap)
	BEGIN
		SELECT Result = 'Match could not be posted due to matching of derivatives resulting to 0 Gross PnL.'
		GOTO Exit_Routine
	END
	
	DECLARE @dblRate NUMERIC(24, 10) = 1
		, @intCurrencyExchangeRateTypeId INT = NULL
		, @ysnForeignCurrency BIT = 0

	SELECT TOP 1 @ysnForeignCurrency = ysnForeignCurrency FROM #tmpMatchDerivativesPostRecap WHERE ysnForeignCurrency = 1

	SELECT TOP 1 @dblRate = rd.dblRate
		, @intCurrencyExchangeRateTypeId = rd.intRateTypeId
	FROM tblSMCurrencyExchangeRate er
	JOIN tblSMCurrencyExchangeRateDetail rd ON er.intCurrencyExchangeRateId = rd.intCurrencyExchangeRateId
	WHERE intFromCurrencyId = @intBankAccountCurrencyId AND intToCurrencyId = @intFunctionalCurrencyId
		AND dtmValidFromDate <= GETDATE()
	ORDER BY dtmValidFromDate DESC

	-- CHECK IF HAS EXCHANGE RATE SETUP FOR FOREIGN CURRENCIES
	IF  @ysnForeignCurrency = 1 AND ISNULL(@intCurrencyExchangeRateTypeId, 0) = 0
	BEGIN
		SELECT Result = 'Missing Currency Exchange Rate Setup for ' + @strBankAccountCurrency + ' to ' + @strFunctionalCurrency
		GOTO Exit_Routine
	END

	SELECT Result = '' -- No Error Message
		, intAccountId
		, strAccountId
		, strAccountDescription
		, strBrokerBankAccount = @strBrokerBankAccount
		-- CHECKING IF DEBIT/CREDIT OR DEBIT/CREDIT FOREIGN
		, dblDebit = CASE WHEN ysnForeignCurrency = 0 THEN dblDebit
							ELSE 0
							END
		, dblCredit = CASE WHEN ysnForeignCurrency = 0 THEN dblCredit
							ELSE 0
							END
		, dblDebitForeign = CASE WHEN ysnForeignCurrency = 0 THEN 0
							ELSE ROUND(dblDebit / @dblRate, 2)
							END
		, dblCreditForeign = CASE WHEN ysnForeignCurrency = 0 THEN dblCredit
							ELSE ROUND(dblCredit / @dblRate, 2)
							END
		, dblDebitUnit
		, dblCreditUnit
		, intCurrencyId
		, strSourceTransactionNo
		, ysnForeignCurrency = @ysnForeignCurrency
		, dblExchangeRate = CASE WHEN @ysnForeignCurrency = 1 THEN @dblRate ELSE NULL END
		, intCurrencyExchangeRateTypeId = CASE WHEN @ysnForeignCurrency = 1 THEN @intCurrencyExchangeRateTypeId ELSE NULL END
	FROM #tmpMatchDerivativesPostRecap

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