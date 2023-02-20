CREATE PROCEDURE uspRKFutOptTransactionImportValidate
	@intEntityUserId INT = NULL
AS

BEGIN TRY
	DECLARE @tblRKFutOptTransactionHeaderId INT
		, @ErrMsg NVARCHAR(MAX)
		, @strRequiredFieldError NVARCHAR(MAX)
		, @mRowNumber INT
		, @strName NVARCHAR(50)
		, @strAccountNumber NVARCHAR(50)
		, @strFutMarketName NVARCHAR(100)
		, @strInstrumentType NVARCHAR(20)
		, @strCommodityCode NVARCHAR(100)
		, @strLocationName NVARCHAR(100)
		, @strSalespersonId NVARCHAR(100)
		, @strCurrency NVARCHAR(100)
		, @strBuySell NVARCHAR(100)
		, @dblNoOfContract DECIMAL(24, 10)
		, @strBrokerTradeNo NVARCHAR(100)
		, @strFutureMonth NVARCHAR(100)
		, @strOptionMonth NVARCHAR(100)
		, @strOptionType NVARCHAR(100)
		, @strStatus NVARCHAR(100)
		, @dtmFilledDate NVARCHAR(100)
		, @strBook NVARCHAR(100)
		, @strSubBook NVARCHAR(100)
		, @PreviousErrMsg NVARCHAR(MAX)
		, @strCreateDateTime NVARCHAR(100)
		, @strDateTimeFormat NVARCHAR(50)
		, @strDateTimeFormat2 NVARCHAR(50)
		, @ConvertYear INT
		, @dblPrice DECIMAL(24, 10) = NULL
		, @dblStrike DECIMAL(24, 10) = NULL

		, @strSelectedInstrumentType NVARCHAR(100)
		, @strCurrencyExchangeRateTypeId NVARCHAR(100)
		, @strBank NVARCHAR(100)
		, @strBuyBankAccount NVARCHAR(100)
		, @strBankAccount NVARCHAR(100)
		, @strOrderType NVARCHAR(100)
		, @strTransactionDate NVARCHAR(100)
		, @strMaturityDate NVARCHAR(100)
		, @strMarketDate NVARCHAR(100)
		, @dblLimitRate DECIMAL(24, 10) = NULL
		, @dblExchangeRate DECIMAL(24, 10) = NULL
		, @dblContractAmount DECIMAL(24, 10) = NULL
		, @dblMatchAmount DECIMAL(24, 10) = NULL
		, @dblFinanceForwardRate DECIMAL(24, 10) = NULL
		, @ysnGTC BIT = 0
		, @intBook INT = NULL
		, @ysnIsDateValid BIT = CAST(0 AS BIT)
		, @strContractNumber NVARCHAR(100)
		, @strContractSequence NVARCHAR(100)
		, @strAssignOrHedge NVARCHAR(50)
		, @ysnCommissionExempt BIT = 0
		, @ysnCommissionOverride BIT = 0
		, @dblCommission DECIMAL(24, 10) = NULL
		, @ysnAllowDerivativeAssignToMultipleContracts BIT

	DECLARE @tmpOTCBank TABLE
	(
		intBankId INT,
		strBank NVARCHAR(500) COLLATE Latin1_General_CI_AS
	)

	DECLARE @dblFXRateDecimals NUMERIC(18, 6)
	
	-- Checking for User Location Access.
	SELECT locationPermission.intCompanyLocationId 
	INTO #tmpRKUserSecurityLocations
	FROM tblSMUserSecurity userSecurity
	LEFT OUTER JOIN tblSMUserSecurityCompanyLocationRolePermission locationPermission
		ON locationPermission.intEntityId = userSecurity.intEntityId
	WHERE userSecurity.intEntityId = @intEntityUserId

	SELECT @strDateTimeFormat = strDateTimeFormat
		, @ysnAllowDerivativeAssignToMultipleContracts = ysnAllowDerivativeAssignToMultipleContracts 
		, @dblFXRateDecimals = dblFXRateDecimals
	FROM tblRKCompanyPreference

	SELECT @strDateTimeFormat2 = REPLACE(LEFT(LTRIM(RTRIM(strDateTimeFormat)),10), ' ', '-') FROM tblRKCompanyPreference;

	IF (ISNULL(@strDateTimeFormat, '') = '')
	BEGIN
		INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId, strErrorMsg, intConcurrencyId)
		VALUES (1, 'There is no setup for DateTime Format in Company Configuration - Risk Management tab.', 1)
		
		GOTO EXIT_ROUTINE
	END

	SELECT TOP 1 @strSelectedInstrumentType = strSelectedInstrumentType FROM tblRKFutOptTransactionImport

	SELECT DISTINCT ysnOTCOthers = (ISNULL(ysnOTCOthers,0))  
	INTO #tmpCheckOTCOthers
	FROM tblRKFutOptTransactionImport i
	JOIN tblRKBrokerageAccount b ON b.strAccountNumber = i.strAccountNumber
	JOIN tblEMEntity e ON i.strName = e.strName

	IF (@strSelectedInstrumentType <> 'OTC')
	BEGIN
		IF (SELECT COUNT(ysnOTCOthers) FROM #tmpCheckOTCOthers) > 1
		BEGIN
			INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId, strErrorMsg, intConcurrencyId)
			VALUES (1, 'File contains mixed instruments.', 1)
		
			GOTO EXIT_ROUTINE
		END
	
		IF (@strSelectedInstrumentType = 'Exchange Traded' AND ISNULL((SELECT TOP 1 ysnOTCOthers FROM #tmpCheckOTCOthers), 0) <> 0)
		BEGIN
			INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId, strErrorMsg, intConcurrencyId)
			VALUES (1, 'File contains brokers with setup for OTC - Others.', 1)
		
			GOTO EXIT_ROUTINE
		END

		IF (@strSelectedInstrumentType = 'OTC - Others' AND ISNULL((SELECT TOP 1 ysnOTCOthers FROM #tmpCheckOTCOthers), 0) <> 1)
		BEGIN
			INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId, strErrorMsg, intConcurrencyId)
			VALUES (1, 'File contains brokers with setup for Exchange Traded', 1)
		
			GOTO EXIT_ROUTINE
		END
	END

	DROP TABLE #tmpCheckOTCOthers


	IF @ysnAllowDerivativeAssignToMultipleContracts = 0
	BEGIN
		SELECT
			 dblToBeAssignedLots
			, dblToBeHedgedLots
			, intContractDetailId
			, intContractHeaderId
			, strContractType
			, strFutMarketName
			, strFutureMonth
			, strCommodityCode
			, strLocationName
			, strContractNumber
			, intContractSeq
		INTO #tmpAssignPhysicalTransaction
		FROM vyuRKGetAssignPhysicalTransaction
	END

	IF (@strDateTimeFormat = 'MM DD YYYY HH:MI' OR @strDateTimeFormat ='YYYY MM DD HH:MI')
		SELECT @ConvertYear = 101
	ELSE IF (@strDateTimeFormat = 'DD MM YYYY HH:MI' OR @strDateTimeFormat ='YYYY DD MM HH:MI')
		SELECT @ConvertYear = 103
	
	SELECT @mRowNumber = MIN(intFutOptTransactionId) FROM tblRKFutOptTransactionImport
	
	DECLARE @counter INT = 1
	WHILE @mRowNumber > 0
	BEGIN
		SELECT @PreviousErrMsg = ''
		SET @ErrMsg = ''
		SET @strRequiredFieldError = ''

		SET @strName = NULL
		SET @strAccountNumber = NULL
		SET @strFutMarketName = NULL
		SET @strInstrumentType = NULL
		SET @strCommodityCode = NULL
		SET @strLocationName = NULL
		SET @strSalespersonId = NULL
		SET @strCurrency = NULL
		SET @strBuySell = NULL
		SET @dblNoOfContract = NULL
		SET @strFutureMonth = NULL
		SET @strOptionMonth = NULL
		SET @strOptionType = NULL
		SET @strStatus = NULL
		SET @dtmFilledDate = NULL
		SET @strBook = NULL
		SET @strSubBook = NULL
		SET @strCreateDateTime = NULL
		SET @strBrokerTradeNo = NULL
		SET @dblPrice = NULL
		SET @dblStrike = NULL
		SET @counter = @counter + 1
		
		SET @strSelectedInstrumentType = NULL
		SET @strCurrencyExchangeRateTypeId = NULL
		SET @strBank = NULL
		SET @strBuyBankAccount = NULL
		SET @strBankAccount = NULL
		SET @strOrderType = NULL
		SET @strTransactionDate = NULL
		SET @strMaturityDate = NULL
		SET @strMarketDate = NULL
		SET @dblLimitRate = NULL
		SET @dblExchangeRate = NULL
		SET @dblContractAmount = NULL
		SET @dblMatchAmount = NULL
		SET @dblFinanceForwardRate = NULL
		SET @ysnGTC = 0
		SET @strContractNumber = NULL
		SET @strContractSequence = NULL
		SET @strAssignOrHedge = NULL
		SET @ysnCommissionExempt = NULL
		SET @ysnCommissionOverride = NULL
		SET @dblCommission = NULL
		
		SELECT @strName = strName
			, @strAccountNumber = strAccountNumber
			, @strFutMarketName = strFutMarketName
			, @strInstrumentType = strInstrumentType
			, @strCommodityCode = strCommodityCode
			, @strLocationName = strLocationName
			, @strSalespersonId = strSalespersonId
			, @strCurrency = strCurrency
			, @strBrokerTradeNo = strBrokerTradeNo
			, @strBuySell = strBuySell
			, @dblNoOfContract = dblNoOfContract
			, @strFutureMonth = strFutureMonth
			, @strOptionMonth = strOptionMonth
			, @strOptionType = strOptionType
			, @strStatus = strStatus
			, @dtmFilledDate = strFilledDate
			, @strBook = strBook
			, @strSubBook = strSubBook
			, @strCreateDateTime = strCreateDateTime
			, @dblPrice = dblPrice
			, @dblStrike = dblStrike
			, @strSelectedInstrumentType = strSelectedInstrumentType
			, @strCurrencyExchangeRateTypeId = strCurrencyExchangeRateTypeId
			, @strBank = strBank
			, @strBuyBankAccount = strBuyBankAccount
			, @strBankAccount = strBankAccount
			, @strOrderType = strOrderType
			, @strTransactionDate = strTransactionDate
			, @strMaturityDate = strMaturityDate
			, @strMarketDate = strMarketDate
			, @dblLimitRate = dblLimitRate
			, @dblExchangeRate = dblExchangeRate
			, @dblContractAmount = dblContractAmount
			, @dblMatchAmount = dblMatchAmount
			, @dblFinanceForwardRate = dblFinanceForwardRate
			, @ysnGTC = ysnGTC
			, @strContractNumber = strContractNumber
			, @strContractSequence = strContractSequence
			, @strAssignOrHedge = strAssignOrHedge
			, @ysnCommissionExempt = ysnCommissionExempt
			, @ysnCommissionOverride = ysnCommissionOverride
			, @dblCommission = dblCommission

		FROM tblRKFutOptTransactionImport
		WHERE intFutOptTransactionId = @mRowNumber
		
		IF (@strSelectedInstrumentType = 'OTC')
		BEGIN
			IF(@strInstrumentType = '')
			BEGIN
				SET @strRequiredFieldError = 'Instrument Type'
			END

			IF(@strCommodityCode = '')
			BEGIN
				SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Commodity' ELSE 'Commodity' END
			END
			
			IF(@strLocationName = '')
			BEGIN
				SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Location' ELSE 'Location' END
			END
			
			IF(@strBuySell = '')
			BEGIN
				SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Buy/Sell' ELSE 'Buy/Sell' END
			END
			
			IF(@strCurrencyExchangeRateTypeId = '')
			BEGIN
				SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Currency Pair' ELSE 'Currency Pair' END
			END
			
			IF(@strBank = '')
			BEGIN
				SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Bank' ELSE 'Bank' END
			END
			
			IF(@strBuyBankAccount = '')
			BEGIN
				SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Buy Bank Account' ELSE 'Buy Bank Account' END
			END

			IF(@strBankAccount = '')
			BEGIN
				SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Sell Bank Account' ELSE 'Sell Bank Account' END
			END

			IF(@strBuyBankAccount = '')
			BEGIN
				SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Buy Bank Account' ELSE 'Buy Bank Account' END
			END

			IF(@strOrderType = '')
			BEGIN
				SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Order Type' ELSE 'Order Type' END
			END
			
			IF(@strTransactionDate = '')
			BEGIN
				SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Trade Date' ELSE 'Trade Date' END
			END
			
			IF (@strInstrumentType = 'Forward')
			BEGIN
				IF(@strMaturityDate = '')
				BEGIN
					SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Maturity Date' ELSE 'Maturity Date' END
				END
				
				-- Finance Rate
				IF(ISNULL(@dblExchangeRate, 0) <= 0)
				BEGIN
					SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Finance Rate be greater than 0' ELSE 'Finance Rate be greater than 0' END
				END

				-- Buy Amount
				IF(ISNULL(@dblContractAmount, 0) <= 0)
				BEGIN
					SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Buy Amount be greater than 0' ELSE 'Buy Amount be greater than 0' END
				END

				-- Sell Amount
				IF(ISNULL(@dblMatchAmount, 0) <= 0)
				BEGIN
					SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Sell Amount be greater than 0' ELSE 'Sell Amount be greater than 0' END
				END
			
				-- Finance Forward Rate
				IF(ISNULL(@dblFinanceForwardRate, 0) <= 0)
				BEGIN
					SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Finance Forward Rate be greater than 0' ELSE 'Finance Forward Rate be greater than 0' END
				END
			END
			
			DECLARE @dblDecimalCount INT
				, @strDecimalValues NVARCHAR(100)


			-- Finance Rate Decimal Place Validation
			SELECT @strDecimalValues = CAST(CAST(@dblExchangeRate AS float) AS NVARCHAR(100))
			SELECT @dblDecimalCount = LEN(RIGHT(@strDecimalValues, LEN(@strDecimalValues) - CHARINDEX('.', @strDecimalValues)))

			IF ISNULL(@dblDecimalCount, 0) > @dblFXRateDecimals
			BEGIN
				SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' 
						THEN ', Finance Rate Decimals should not exceed FX Rate Decimal config (' + CAST(CAST(@dblFXRateDecimals AS INT) AS NVARCHAR(10)) + ')'  
						ELSE 'Finance Rate Decimals should not exceed FX Rate Decimal config (' + CAST(CAST(@dblFXRateDecimals AS INT) AS NVARCHAR(10)) + ')' END
			END
			
			-- Finance Forward Rate Decimal Place Validation
			SELECT @strDecimalValues = CAST(CAST(@dblFinanceForwardRate AS float) AS NVARCHAR(100))
			SELECT @dblDecimalCount = LEN(RIGHT(@strDecimalValues, LEN(@strDecimalValues) - CHARINDEX('.', @strDecimalValues)))
			IF ISNULL(@dblDecimalCount, 0) > @dblFXRateDecimals
			BEGIN
				SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' 
						THEN ', Finance Forward Rate Decimals should not exceed FX Rate Decimal config (' + CAST(CAST(@dblFXRateDecimals AS INT) AS NVARCHAR(10)) + ')'  
						ELSE 'Finance Forward Rate Decimals should not exceed FX Rate Decimal config (' + CAST(CAST(@dblFXRateDecimals AS INT) AS NVARCHAR(10)) + ')' END
			END
			
			-- Limit Rate Decimal Place Validation
			SELECT @strDecimalValues = CAST(CAST(@dblLimitRate AS float) AS NVARCHAR(100))
			SELECT @dblDecimalCount = LEN(RIGHT(@strDecimalValues, LEN(@strDecimalValues) - CHARINDEX('.', @strDecimalValues)))
			IF ISNULL(@dblDecimalCount, 0) > @dblFXRateDecimals
			BEGIN
				SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' 
						THEN ', Limit Rate Decimals should not exceed FX Rate Decimal config (' + CAST(CAST(@dblFXRateDecimals AS INT) AS NVARCHAR(10)) + ')'  
						ELSE 'Limit Rate Decimals should not exceed FX Rate Decimal config (' + CAST(CAST(@dblFXRateDecimals AS INT) AS NVARCHAR(10)) + ')' END
			END
			
			IF (@strOrderType = 'Limit' AND ISNULL(@dblLimitRate, 0) <= 0)
			BEGIN
				SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Limit Rate be greater than 0 if Order Type is Limit' ELSE 'Limit Rate be greater than 0 if Order Type is Limit' END
			END

			IF (@ysnGTC = 1 AND @strMarketDate = '')
			BEGIN
				SET @strRequiredFieldError = @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Market Date if GTC' ELSE 'Market Date if GTC' END
			END
			
			IF(@strRequiredFieldError <> '')
			BEGIN
				SET @ErrMsg = 'Requires ' + @strRequiredFieldError + '.'
			END
			ELSE
			BEGIN
				IF (@strInstrumentType <> 'Spot' AND @strInstrumentType <> 'Forward' AND @strInstrumentType <> 'Swap')
				BEGIN
					SET @ErrMsg = 'Invalid Instrument Type for OTC Instrument.'
				END

				IF (LOWER(@strCommodityCode) <> 'currency')
				BEGIN
					SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + 'OTC Record Commodity should be Currency.'
				END

				IF NOT EXISTS (SELECT TOP 1 '' FROM tblICCommodity WHERE strCommodityCode = @strCommodityCode)
				BEGIN
					SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + 'Currency commodity needs to be created first.'
				END
				
				IF NOT EXISTS(SELECT TOP 1 '' FROM tblSMCompanyLocation WHERE strLocationName = @strLocationName)
				BEGIN
					SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + ' Location Name does not exists in the system.'
				END
				ELSE 
				BEGIN
					IF NOT EXISTS (SELECT TOP 1 '' FROM #tmpRKUserSecurityLocations securityLocations 
									WHERE intCompanyLocationId IN (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationName = @strLocationName)
								)
					BEGIN
						SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + 'User does not have access in the selected Location.'
					END
				END
				
				IF @strBuySell NOT IN('Buy','Sell')
				BEGIN
					SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + ' Buy/Sell is case sensitive and must be in exact word Buy or Sell.'
				END

				-- CURRENCY PAIR, BANK AND BANK ACCOUNT VALIDATIONS.
				DECLARE @intBuyCurrencyId INT = NULL
					, @intSellCurrencyId INT = NULL
					, @intCurrencyPairId INT = NULL
					, @strBuyCurrency NVARCHAR(100)
					, @strSellCurrency NVARCHAR(100)
					, @intBankId INT = NULL
					, @intLocationId INT = NULL

				SELECT TOP 1 @intLocationId = intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationName = @strLocationName

				--SELECT TOP 1 @intCurrencyPairId = intCurrencyExchangeRateTypeId
				--	, @intBuyCurrencyId = intFromCurrencyId
				--	, @intSellCurrencyId = intToCurrencyId
				--	, @strBuyCurrency = strFromCurrency
				--	, @strSellCurrency = strToCurrency
				--FROM vyuRKGetCurrencyPair
				--WHERE strCurrencyExchangeRateType = @strCurrencyExchangeRateTypeId

				SELECT TOP 1 @intCurrencyPairId = intCurrencyPairId
					, @intBuyCurrencyId = intToCurrencyId
					, @intSellCurrencyId = intFromCurrencyId
					, @strBuyCurrency = strToCurrency
					, @strSellCurrency = strFromCurrency
				FROM vyuRKCurrencyPairSetup
				WHERE strCurrencyPair = @strCurrencyExchangeRateTypeId

				IF (ISNULL(@intCurrencyPairId, 0) = 0)
				BEGIN
					--IF EXISTS (SELECT TOP 1 '' FROM vyuRKCurrencyPairSetup WHERE strCurrencyPair = @strCurrencyExchangeRateTypeId)
					--BEGIN
					--	SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + 'Currency Pair exists in Currency Exchange Rate Types but does not contain setup for Currency Exchange Rates.'
					--END
					--ELSE
					--BEGIN
						SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + 'Currency Pair does not exist in Currency Pair Setup.'
					--END
				END
				ELSE 
				BEGIN
					SELECT TOP 1 @intBankId = intBankId FROM tblCMBank WHERE strBankName = @strBank

					-- CHECK FIRST IF HAS BANK BEFORE PROCEEDING TO OTHER VALIDATIONS.
					IF (ISNULL(@intBankId, 0) = 0)
					BEGIN
						SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + 'Bank does not exists in the system.'
					END
					ELSE
					BEGIN
						INSERT INTO @tmpOTCBank
						EXEC uspRKGetFilteredOTCBank @intBuyCurrencyId, @intSellCurrencyId, @intLocationId, @strInstrumentType

						IF NOT EXISTS (SELECT TOP 1 '' FROM @tmpOTCBank WHERE strBank = @strBank)
						BEGIN
							IF EXISTS (SELECT TOP 1 '' FROM tblCMBankAccount WHERE intBankId = @intBankId AND intCurrencyId = @intBuyCurrencyId) AND
								EXISTS (SELECT TOP 1 '' FROM tblCMBankAccount WHERE intBankId = @intBankId AND intCurrencyId = @intSellCurrencyId)
							BEGIN
								SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + 'Bank should have Bank Accounts with same GL Account Location as the Location selected and should have Bank Accounts with currencies for both ' + @strBuyCurrency + ' and ' + @strSellCurrency + '.'
							END
							ELSE
							BEGIN
								SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + 'Bank should have Bank Accounts with currencies for both ' + @strBuyCurrency + ' and ' + @strSellCurrency + '.'
							END
						END
						ELSE
						BEGIN
							-- BUY BANK ACCOUNT
							IF NOT EXISTS (SELECT TOP 1 '' FROM vyuCMBankAccount WHERE strBankAccountNo = @strBuyBankAccount)
							BEGIN
								SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + 'Buy Bank Account does not exists in the system.'
							END
							ELSE
							BEGIN
								IF NOT EXISTS (SELECT TOP 1 '' FROM vyuCMBankAccount WHERE strBankAccountNo = @strBuyBankAccount AND intBankId = @intBankId)
								BEGIN
									SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + 'Selected Bank is different from the Bank of Buy Bank Account.'
								END

								IF (@intBuyCurrencyId <> ISNULL((SELECT TOP 1 intCurrencyId FROM vyuCMBankAccount WHERE strBankAccountNo = @strBuyBankAccount AND intBankId = @intBankId), @intBuyCurrencyId))
								BEGIN
									SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + 'Currency of Buy Bank Account should be ' + @strBuyCurrency + '.';
								END
							END
					
							-- SELL BANK ACCOUNT
							IF NOT EXISTS(SELECT TOP 1 '' FROM vyuCMBankAccount WHERE strBankAccountNo = @strBankAccount)
							BEGIN
								SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + 'Sell Bank Account does not exists in the system.'
							END
							ELSE 
							BEGIN
								IF NOT EXISTS (SELECT TOP 1 '' FROM vyuCMBankAccount WHERE strBankAccountNo = @strBankAccount AND intBankId = @intBankId)
								BEGIN
									SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + 'Selected Bank is different from the Bank of Sell Bank Account.'
								END
							
								IF (@intSellCurrencyId <> ISNULL((SELECT TOP 1 intCurrencyId FROM vyuCMBankAccount WHERE strBankAccountNo = @strBankAccount AND intBankId = @intBankId), @intSellCurrencyId))
								BEGIN
									SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + 'Currency of Sell Bank Account should be ' + @strSellCurrency + '.';
								END
							END
						END

						DELETE FROM @tmpOTCBank
					END
				END
				
				IF @strOrderType NOT IN ('Limit', 'Market')
				BEGIN
					SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + ' Invalid Order Type. Please Select from Limit or Market.'
				END

				-- VALIDATION OF DATE FORMATS.
				-- MARKET DATE
				IF (@strMarketDate <> '')
				BEGIN
					SELECT @ysnIsDateValid = CAST(0 AS BIT)
					EXEC uspRKStringDateValidate @strMarketDate, @ysnIsDateValid OUTPUT
					
					IF(@ysnIsDateValid = 0)
					BEGIN
						SET @ErrMsg = @ErrMsg + ' Invalid Market Date, format should be in ' + @strDateTimeFormat2 + '.'
						SET @strMarketDate = NULL
					END
				END

				-- TRADE DATE
				IF (@strTransactionDate <> '')
				BEGIN
					SELECT @ysnIsDateValid = CAST(0 AS BIT)
					EXEC uspRKStringDateValidate @strTransactionDate, @ysnIsDateValid OUTPUT
					
					IF(@ysnIsDateValid = 0)
					BEGIN
						SET @ErrMsg = @ErrMsg + ' Invalid Trade Date, format should be in ' + @strDateTimeFormat2 + '.'
						SET @strTransactionDate = NULL
					END
				END

				-- MATURITY DATE
				IF (@strMaturityDate <> '')
				BEGIN
					SELECT @ysnIsDateValid = CAST(0 AS BIT)
					EXEC uspRKStringDateValidate @strMaturityDate, @ysnIsDateValid OUTPUT
					
					IF(@ysnIsDateValid = 0)
					BEGIN
						SET @ErrMsg = @ErrMsg + ' Invalid Maturity Date, format should be in ' + @strDateTimeFormat2 + '.'
						SET @strMaturityDate = NULL
					END
				END
				
				SELECT @intBook = NULL
				SELECT @intBook = intBookId FROM tblCTBook WHERE strBook = @strBook

				IF ISNULL(@strBook, '') <> '' AND ISNULL(@intBook,0) = 0
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Book does not exist in the system.'
				END
	
				IF ISNULL(@strSubBook, '') <> '' AND NOT EXISTS(SELECT * FROM tblCTSubBook WHERE strSubBook = @strSubBook AND intBookId = ISNULL(@intBook,0)) AND ISNULL(@intBook,0) <> 0
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Sub-Book does not exist in Book: ' + @strBook + '.'
				END
				ELSE IF(ISNULL(@strSubBook, '') <> '' AND ISNULL(@strBook, '') = '')
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Book must exists for Sub-Book: ' + @strSubBook + '.'
				END
			END
		END
		ELSE
		BEGIN
			IF(LTRIM(RTRIM(@strInstrumentType)) = '')
			BEGIN
				SET @strRequiredFieldError = 'Instrument Type'
			END

			IF(LTRIM(RTRIM(@strFutMarketName)) = '')
			BEGIN
				SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Futures Market' ELSE 'Futures Market' END
			END

			IF(LTRIM(RTRIM(@strCurrency)) = '')
			BEGIN
				SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Currency' ELSE 'Currency' END
			END

			IF(LTRIM(RTRIM(@strCommodityCode)) = '')
			BEGIN
				SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Commodity' ELSE 'Commodity' END
			END

			IF(LTRIM(RTRIM(@strLocationName)) = '')
			BEGIN
				SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Location' ELSE 'Location' END
			END

			IF(LTRIM(RTRIM(@strName)) = '')
			BEGIN
				SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Broker' ELSE 'Broker' END
			END

			IF(LTRIM(RTRIM(@strAccountNumber)) = '')
			BEGIN
				SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Broker Account' ELSE 'Broker Account' END
			END

			IF(LTRIM(RTRIM(@strSalespersonId)) = '')
			BEGIN
				SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Salesperson' ELSE 'Salesperson' END
			END

			IF(LTRIM(RTRIM(@strBuySell)) = '')
			BEGIN
				SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Buy/Sell' ELSE 'Buy/Sell' END
			END

			IF(LTRIM(RTRIM(@strFutureMonth)) = '')
			BEGIN
				SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Futures Month' ELSE 'Futures Month' END
			END

			IF(@dblPrice IS NULL)
			BEGIN
				SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Price' ELSE 'Price' END
			END

			IF(LTRIM(RTRIM(@strStatus)) = '')
			BEGIN
				SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Status' ELSE 'Status' END
			END

			IF(@dtmFilledDate IS NULL)
			BEGIN
				SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Filled Date' ELSE 'Filled Date' END
			END

			IF(LTRIM(RTRIM(@strInstrumentType)) = 'Options')
			BEGIN
				IF (LTRIM(RTRIM(@strOptionMonth)) = '')
				BEGIN
					SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Option Month' ELSE 'Option Month' END
				END

				IF (LTRIM(RTRIM(@strOptionType)) = '')
				BEGIN
					SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Option Type' ELSE 'Option Type' END
				END

				IF (@dblStrike IS NULL)
				BEGIN
					SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Strike' ELSE 'Strike' END
				END
			END

			IF(@strRequiredFieldError <> '')
			BEGIN
				SET @ErrMsg = @strRequiredFieldError + ' is required.'
			END

			IF(LTRIM(RTRIM(@strInstrumentType)) = 'Futures') AND (LTRIM(RTRIM(@strOptionMonth)) <> '' OR LTRIM(RTRIM(@strOptionType)) <> '')
			BEGIN
				SET @ErrMsg = ' Instrument Type: Futures must not have Option Month or Option Type.'
			END
		
			IF @ErrMsg = ''
			BEGIN
				IF NOT EXISTS(SELECT * FROM tblEMEntity WHERE strName = @strName)
				BEGIN
					SET @ErrMsg =  ' Broker does not exists in the system.'
				END
				ELSE
				BEGIN
					DECLARE @intEntityId INT = NULL
					SELECT @intEntityId=intEntityId from tblEMEntity WHERE strName= @strName

					--Broker Trade No already exists in the transactions for the respective Broker
					IF EXISTS(SELECT * FROM tblRKFutOptTransaction WHERE strBrokerTradeNo=@strBrokerTradeNo and intEntityId = @intEntityId and ISNULL(strBrokerTradeNo, '')<>'' and ISNULL(intSelectedInstrumentTypeId,1) in(1,3))
					BEGIN
						SET @ErrMsg = @ErrMsg + ' Broker Trade No already exists.'
					END

					--Broker Trader Number exists in the current batch
					IF EXISTS(SELECT COUNT(strBrokerTradeNo) 
							FROM(
								SELECT strBrokerTradeNo FROM tblRKFutOptTransactionImport 
								WHERE strBrokerTradeNo=@strBrokerTradeNo 
								AND strName=@strName AND ISNULL(strBrokerTradeNo, '')<>'' 
							)T
							HAVING COUNT(strBrokerTradeNo) > 1)
					BEGIN
						SET @ErrMsg = @ErrMsg + ' More than one transaction with the same Broker Trade No exists in the file.'
					END
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKFutureMarket fm
							JOIN tblSMCurrency cur ON cur.intCurrencyID = fm.intCurrencyId
							WHERE strFutMarketName = @strFutMarketName AND strCurrency = @strCurrency)
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Currency used must be the Future Market Currency.'
				END

				IF NOT EXISTS(SELECT * FROM tblRKBrokerageAccount WHERE strAccountNumber = @strAccountNumber)
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Broker Account does not exists in the system.'
				END

				IF NOT EXISTS(SELECT * FROM tblRKFutureMarket WHERE strFutMarketName = @strFutMarketName)
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Futures Market does not exists in the system.'
				END
				ELSE
				BEGIN
					DECLARE @NotConfiguredErrMsg NVARCHAR(MAX)
					SET @NotConfiguredErrMsg = ''

					IF EXISTS(SELECT * FROM tblEMEntity WHERE strName = @strName) AND 
						NOT EXISTS(SELECT 1 FROM tblRKFutOptTransactionImport ti
											JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
											JOIN tblRKBrokerageCommission am on  am.intFutureMarketId=fm.intFutureMarketId
											JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=am.intBrokerageAccountId  
											JOIN tblEMEntity em on ba.intEntityId=em.intEntityId and em.strName=ti.strName
											WHERE intFutOptTransactionId =@mRowNumber)
					BEGIN
						SET @NotConfiguredErrMsg = @NotConfiguredErrMsg + ' Broker'
					END
					ELSE 
					BEGIN
						IF EXISTS(SELECT * FROM vyuHDSalesPerson WHERE strName = @strSalespersonId) AND 
						NOT EXISTS(SELECT 1
									FROM tblRKFutOptTransactionImport ti
								JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
								JOIN tblRKBrokerageAccount ba on ba.strAccountNumber=ti.strAccountNumber  
								join tblRKTradersbyBrokersAccountMapping bam on bam.intBrokerageAccountId=ba.intBrokerageAccountId
								join vyuHDSalesPerson sp on sp.intEntityId=bam.intEntitySalespersonId and sp.strName=ti.strSalespersonId
								WHERE intFutOptTransactionId =@mRowNumber)
						AND EXISTS(SELECT * FROM tblEMEntity WHERE strName = @strName) AND 
						NOT EXISTS(SELECT 1 FROM tblRKFutOptTransactionImport ti
											JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
											JOIN tblRKBrokerageCommission am on  am.intFutureMarketId=fm.intFutureMarketId
											JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=am.intBrokerageAccountId  
											JOIN tblEMEntity em on ba.intEntityId=em.intEntityId and em.strName=ti.strName
											WHERE intFutOptTransactionId =@mRowNumber)
						BEGIN
							SET @NotConfiguredErrMsg = @NotConfiguredErrMsg +  CASE WHEN @NotConfiguredErrMsg <> '' THEN ', Salesperson' ELSE ' Salesperson' END
						END
					END

					IF @strInstrumentType IN ('Futures','Options') AND 
						NOT EXISTS(SELECT 1
										FROM tblRKFutOptTransactionImport ti
										JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
										join tblRKBrokerageCommission am on  am.intFutureMarketId=fm.intFutureMarketId
										JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=am.intBrokerageAccountId  
										AND ba.intInstrumentTypeId= case when ba.intInstrumentTypeId= 3 then 3 else
												case when ti.strInstrumentType='Futures' then 1
													when ti.strInstrumentType='Options' then 2 end end
										WHERE intFutOptTransactionId =@mRowNumber)
					BEGIN
						SET @NotConfiguredErrMsg = @NotConfiguredErrMsg +  CASE WHEN @NotConfiguredErrMsg <> '' THEN ', Instrument Type' ELSE ' Instrument Type' END
					END

					IF EXISTS(SELECT * FROM tblICCommodity WHERE strCommodityCode = @strCommodityCode) AND 
						NOT EXISTS(SELECT 1
									FROM tblRKFutOptTransactionImport ti
									JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
									Join tblRKCommodityMarketMapping mm on mm.intFutureMarketId=fm.intFutureMarketId 
									join tblICCommodity c on c.intCommodityId=mm.intCommodityId and c.strCommodityCode=ti.strCommodityCode
									WHERE intFutOptTransactionId =@mRowNumber)
					BEGIN
						SET @NotConfiguredErrMsg = @NotConfiguredErrMsg +  CASE WHEN @NotConfiguredErrMsg <> '' THEN ', Commodity' ELSE ' Commodity' END
					END

					IF EXISTS(SELECT * FROM tblSMCurrency WHERE strCurrency = @strCurrency) AND 
						NOT EXISTS(SELECT 1
							FROM tblRKFutOptTransactionImport ti
							JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName 
							join tblSMCurrency c on c.strCurrency=ti.strCurrency
							WHERE intFutOptTransactionId =@mRowNumber)
					BEGIN
						SET @NotConfiguredErrMsg = @NotConfiguredErrMsg +  CASE WHEN @NotConfiguredErrMsg <> '' THEN ', Currency' ELSE ' Currency' END
					END

					IF @strInstrumentType IN ('Futures', 'Options') AND PATINDEX ('[A-z][a-z][a-z]-[0-9][0-9]',RTRIM(LTRIM(@strFutureMonth))) = 0
					BEGIN
						SET @ErrMsg = @ErrMsg + ' Invalid Futures Month, format should be in mmm-yy (Jan-18).'
					END

					ELSE IF @strInstrumentType IN ('Futures', 'Options') AND 
						NOT EXISTS(SELECT 1
							FROM tblRKFutOptTransactionImport ti
							JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName 
							join tblRKFuturesMonth m on fm.intFutureMarketId=m.intFutureMarketId and m.strFutureMonth=replace(ti.strFutureMonth,'-',' ')
							WHERE intFutOptTransactionId = @mRowNumber)
					BEGIN
						--SET @NotConfiguredErrMsg = @NotConfiguredErrMsg +  CASE WHEN @NotConfiguredErrMsg <> '' THEN ', Futures Month' ELSE ' Futures Month' END
						SET @ErrMsg = 'Futures Month does not exist for Future Market: ' + @strFutMarketName + '.'
					END

					IF @strInstrumentType = 'Options' AND (NOT EXISTS(SELECT * FROM tblRKOptionsMonth WHERE strOptionMonth = REPLACE(@strOptionMonth,'-',' ') COLLATE Latin1_General_CS_AS)
						OR PATINDEX ('[A-z][a-z][a-z]-[0-9][0-9]',RTRIM(LTRIM(@strOptionMonth))) = 0)
					BEGIN
						SET @ErrMsg = @ErrMsg + ' Invalid Options Month, format should be in mmm-yy (Jan-18).'
					END
					ELSE IF @strInstrumentType = 'Options' AND
						NOT EXISTS(SELECT 1
							FROM tblRKFutOptTransactionImport ti
						JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName 
						join tblRKOptionsMonth m on fm.intFutureMarketId=m.intFutureMarketId and m.strOptionMonth=replace(ti.strOptionMonth,'-',' ')
						WHERE intFutOptTransactionId =@mRowNumber)
					BEGIN
						SET @NotConfiguredErrMsg = @NotConfiguredErrMsg +  CASE WHEN @NotConfiguredErrMsg <> '' THEN ', Option Month' ELSE ' Option Month' END
					END

					IF @NotConfiguredErrMsg <> ''
					BEGIN
						SET @ErrMsg = @ErrMsg + @NotConfiguredErrMsg + ' is not configured for Futures Market ' + @strFutMarketName + '.'
					END
				END

				IF @strInstrumentType NOT IN('Futures','Options')
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Instrument Type is case sensitive it must be in exact word Futures or Options.'
				END

				IF NOT EXISTS(SELECT * FROM tblICCommodity WHERE strCommodityCode = @strCommodityCode)
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Commodity Code does not exists in the system.'
				END

				IF NOT EXISTS(SELECT * FROM tblSMCompanyLocation WHERE strLocationName = @strLocationName)
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Location Name does not exists in the system.'
				END
				ELSE 
				BEGIN
					IF NOT EXISTS (SELECT TOP 1 '' FROM #tmpRKUserSecurityLocations securityLocations 
									WHERE intCompanyLocationId IN (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationName = @strLocationName)
								)
					BEGIN
						SET @ErrMsg = @ErrMsg + CASE WHEN @ErrMsg <> '' THEN ' ' ELSE '' END + 'User does not have access in the selected Location.'
					END
				END

				IF NOT EXISTS(SELECT * FROM vyuHDSalesPerson WHERE strName = @strSalespersonId)
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Salesperson does not exists in the system.'
				END

				IF NOT EXISTS(SELECT * FROM tblSMCurrency WHERE strCurrency = @strCurrency)
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Currency does not exists in the system.'
				END

				IF @strBuySell NOT IN('Buy','Sell')
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Buy/Sell is case sensitive it must be in exact word Buy or Sell.'
				END

				IF @strInstrumentType = 'Options' AND @strOptionType NOT IN('Call','Put')
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Option Type is case sensitive it must be in exact word Put or Call.'
				END

				IF @strStatus NOT IN('Filled','Unfilled','Cancelled')
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Status is case sensitive it must be in exact word Filled, Unfilled or Cancelled.'
				END

				IF @strInstrumentType = 'Options' AND ISNULL(@dblStrike, 0) = 0
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Strike must not be equal to 0.'
				END

				IF ISNULL(@dblPrice, 0) = 0
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Price must not be equal to 0.'
				END

				DECLARE @isValidFilledDate BIT = 0
				BEGIN
					DECLARE @tempStrDate NVARCHAR(100)
					SELECT  @tempStrDate = strFilledDate 
					FROM tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber

					EXEC uspRKStringDateValidate @tempStrDate, @isValidFilledDate OUTPUT

					IF(@isValidFilledDate = 1)
					BEGIN
						SELECT  @dtmFilledDate=convert(datetime,@dtmFilledDate,@ConvertYear)
		
						-- Reconciled Validation 
						IF EXISTS(SELECT 1 FROM  tblRKReconciliationBrokerStatementHeader t
										JOIN tblRKFutureMarket m on t.intFutureMarketId=m.intFutureMarketId
										JOIN tblRKBrokerageAccount b on b.intBrokerageAccountId=t.intBrokerageAccountId
										JOIN tblICCommodity c on c.intCommodityId=t.intCommodityId
										JOIN tblEMEntity e on e.intEntityId= t.intEntityId
									WHERE m.strFutMarketName=strFutMarketName AND b.strAccountNumber=@strAccountNumber
										AND c.strCommodityCode=strCommodityCode AND e.strName=@strName AND ysnFreezed = 1
										AND convert(datetime,dtmFilledDate,@ConvertYear) = convert(datetime,@dtmFilledDate,@ConvertYear))
						BEGIN
							SET @ErrMsg = @ErrMsg + ' The selected filled date already reconciled.'
						END
					END
					ELSE
					BEGIN
						SET @ErrMsg = @ErrMsg + ' Invalid Filled Date, format should be in ' + @strDateTimeFormat2 + '.'
						SET @dtmFilledDate = NULL
					END
				END
				
				SELECT @intBook = NULL
				SELECT @intBook = intBookId FROM tblCTBook WHERE strBook = @strBook

				IF ISNULL(@strBook, '') <> '' AND ISNULL(@intBook,0) = 0
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Book does not exist in the system.'
				END
	
				IF ISNULL(@strSubBook, '') <> '' AND NOT EXISTS(SELECT * FROM tblCTSubBook WHERE strSubBook = @strSubBook AND intBookId = ISNULL(@intBook,0)) AND ISNULL(@intBook,0) <> 0
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Sub-Book does not exist in Book: ' + @strBook + '.'
				END
				ELSE IF(ISNULL(@strSubBook, '') <> '' AND ISNULL(@strBook, '') = '')
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Book must exists for Sub-Book: ' + @strSubBook + '.'
				END
				
				DECLARE @isValidmCreateDateTime BIT = CAST(0 AS BIT)
				BEGIN
					SELECT @strCreateDateTime = strCreateDateTime 
					FROM tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber

					EXEC uspRKStringDateValidate @strCreateDateTime, @isValidmCreateDateTime OUTPUT

					IF(@isValidmCreateDateTime = 0)
					BEGIN
						SET @ErrMsg = @ErrMsg + ' Invalid Create Date Time, format should be in ' + @strDateTimeFormat2 + '.'
						SET @strCreateDateTime = NULL
					END
				END

				IF @strAssignOrHedge <> '' AND @ysnAllowDerivativeAssignToMultipleContracts = 0
				BEGIN
					IF @strAssignOrHedge NOT IN('Assign','Hedge')
					BEGIN
						SET @ErrMsg = @ErrMsg + ' Assign or Hedge is case sensitive it must be in exact word Assign or Hedge.'
					END

					
					IF NOT EXISTS(SELECT * FROM tblCTContractHeader H
								INNER JOIN tblCTContractDetail D ON D.intContractHeaderId = H.intContractHeaderId
								WHERE strContractNumber = @strContractNumber AND intContractSeq = @strContractSequence)
					BEGIN
						SET @ErrMsg = @ErrMsg + ' Contract Number and Sequence does not exists in the system.'
					END

					IF EXISTS(SELECT * FROM tblCTContractHeader H
								INNER JOIN tblCTContractDetail D ON D.intContractHeaderId = H.intContractHeaderId
								WHERE strContractNumber = @strContractNumber AND intContractSeq = @strContractSequence)
					BEGIN
						
						DECLARE @dblToBeAssignedLots NUMERIC(18,6) 
							,@dblToBeHedgedLots NUMERIC(18,6)
							,@intContractDetailId INT = NULL
							,@intContractHeaderId INT = NULL
							,@dtmCurrentDate DATETIME  = GETDATE()
							,@strContractType NVARCHAR(50)
							,@strFutMarketNameCnt NVARCHAR(50)
							,@strFutureMonthCnt NVARCHAR(50)
							,@strCommodityCodeCnt NVARCHAR(50)
							,@strLocationNameCnt NVARCHAR(100)

						
						select
							@dblToBeAssignedLots = dblToBeAssignedLots
							,@dblToBeHedgedLots = dblToBeHedgedLots
							,@intContractDetailId = intContractDetailId
							,@intContractHeaderId = intContractHeaderId
							,@strContractType = strContractType
							,@strFutMarketNameCnt = strFutMarketName
							,@strFutureMonthCnt = strFutureMonth
							,@strCommodityCodeCnt = strCommodityCode
							,@strLocationNameCnt = strLocationName
						from #tmpAssignPhysicalTransaction where strContractNumber = @strContractNumber and intContractSeq = @strContractSequence



						IF @strAssignOrHedge = 'Assign'
						BEGIN

							IF @dblNoOfContract > @dblToBeAssignedLots
							BEGIN
								UPDATE #tmpAssignPhysicalTransaction SET dblToBeAssignedLots = @dblToBeAssignedLots WHERE strContractNumber = @strContractNumber AND intContractSeq = @strContractSequence

								UPDATE tblRKFutOptTransactionImport
								SET dblToAssignOrHedgeLots = ABS(@dblToBeAssignedLots)
								WHERE intFutOptTransactionId = @mRowNumber

								--SET @ErrMsg = @ErrMsg + ' Derivative lots (' + dbo.fnFormatNumber(@dblNoOfContract)  + ') should not be greater than the Contract ' + @strContractNumber + '-'+ @strContractSequence + ' available lots (' + dbo.fnFormatNumber(@dblToBeAssignedLots) + ') to be assigned.'
							END
							ELSE
							BEGIN
								UPDATE #tmpAssignPhysicalTransaction SET dblToBeAssignedLots = @dblToBeAssignedLots - @dblNoOfContract WHERE strContractNumber = @strContractNumber AND intContractSeq = @strContractSequence
							END

							
						END


						IF @strAssignOrHedge = 'Hedge'
						BEGIN
							
							IF (@strBuySell = 'Buy' AND @strContractType = 'Purchase') OR (@strBuySell = 'Sell' AND @strContractType = 'Sale')
							BEGIN
								SET @ErrMsg = @ErrMsg + ' Please select opposite futures transactions only to hedge a contract, else use Assign instead of Hedge.'
							END


							IF @strFutMarketNameCnt <>  @strFutMarketName OR @strFutureMonthCnt <> REPLACE(@strFutureMonth, '-', ' ') OR @strCommodityCodeCnt <> @strCommodityCode OR @strLocationNameCnt <> @strLocationName
							BEGIN
								SET @ErrMsg = @ErrMsg +' Market, Month, Commodity and Locations should be the same for both Derivative and Contract for hedging.'
							END

							IF ISNULL(@dblToBeHedgedLots, 0) = 0
							BEGIN
								SET @ErrMsg = @ErrMsg + ' Selected Contract has been fully Hedged, Derivative has not been created.'
							END
							ELSE IF @dblNoOfContract > @dblToBeHedgedLots 
							BEGIN
								UPDATE #tmpAssignPhysicalTransaction SET dblToBeHedgedLots = @dblToBeHedgedLots WHERE strContractNumber = @strContractNumber AND intContractSeq = @strContractSequence

								UPDATE tblRKFutOptTransactionImport
								SET dblToAssignOrHedgeLots = ABS(@dblToBeHedgedLots)
								WHERE intFutOptTransactionId = @mRowNumber

								--SET @ErrMsg = @ErrMsg + ' Derivative lot (' + dbo.fnFormatNumber(@dblNoOfContract)  + ') should not be greater than the Contract ' + @strContractNumber + '-'+ @strContractSequence + ' available lots (' + dbo.fnFormatNumber(@dblToBeHedgedLots) + ') to be hedged.'
							END
							ELSE
							BEGIN
								UPDATE #tmpAssignPhysicalTransaction SET dblToBeHedgedLots = @dblToBeHedgedLots - @dblNoOfContract WHERE strContractNumber = @strContractNumber AND intContractSeq = @strContractSequence
							END

						END 
						
					END


				END

				IF @ysnCommissionExempt = 1 AND @ysnCommissionOverride = 1
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Commission Exempt and Override should not be both checked.'
				END

				IF @ysnCommissionExempt = 1 AND @ysnCommissionOverride = 0 AND @dblCommission IS NOT NULL
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Commission field should be blank if Commission Exempt is checked.'
				END

				IF @ysnCommissionExempt = 0 AND @ysnCommissionOverride = 1 AND (@dblCommission IS  NULL OR @dblCommission >= 0 )
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Commission field should have a negative value if Commission Override is checked.'
				END

			END
		END

		IF @ErrMsg <> ''
		BEGIN
			INSERT INTO [dbo].[tblRKFutOptTransactionImport_ErrLog]
				   ( [intFutOptTransactionId]
				   , [strName]
				   , [strAccountNumber]
				   , [strFutMarketName]
				   , [strInstrumentType]
				   , [strCommodityCode]
				   , [strLocationName]
				   , [strSalespersonId]
				   , [strCurrency]
				   , [strBrokerTradeNo]
				   , [strBuySell]
				   , [dblNoOfContract]
				   , [strFutureMonth]
				   , [strOptionMonth]
				   , [strOptionType]
				   , [dblStrike]
				   , [dblPrice]
				   , [strReference]
				   , [strStatus]
				   , [strFilledDate]
				   , [strBook]
				   , [strSubBook]
				   , [intConcurrencyId]
				   , [strErrorMsg]
				   , [strCreateDateTime]
				   , [strSelectedInstrumentType] 
				   , [strCurrencyExchangeRateTypeId] 
				   , [strBank] 
				   , [strBuyBankAccount] 
				   , [strBankAccount] 
				   , [strOrderType] 
				   , [dblLimitRate] 
				   , [strMarketDate] 
				   , [ysnGTC] 
				   , [strTransactionDate] 
				   , [strMaturityDate] 
				   , [dblExchangeRate] 
				   , [dblContractAmount] 
				   , [dblMatchAmount] 
				   , [dblFinanceForwardRate]
				   , [strContractNumber]
				   , [strContractSequence]
				   , [strAssignOrHedge]
				   , [ysnCommissionExempt]
				   , [ysnCommissionOverride]
				   , [dblCommission])
		
			SELECT 
					 [intFutOptTransactionId]
				   , [strName]
				   , [strAccountNumber]
				   , [strFutMarketName]
				   , [strInstrumentType]
				   , [strCommodityCode]
				   , [strLocationName]
				   , [strSalespersonId]
				   , [strCurrency]
				   , [strBrokerTradeNo]
				   , [strBuySell]
				   , [dblNoOfContract]
				   , [strFutureMonth]
				   , [strOptionMonth]
				   , [strOptionType]
				   , [dblStrike]
				   , [dblPrice]
				   , [strReference]
				   , [strStatus]
				   , [strFilledDate]
				   , [strBook]
				   , [strSubBook]
				   , [intConcurrencyId]
				   , 'Error at Line No. '  + Convert(nvarchar(50),@counter) + '. ' + @ErrMsg
				   , [strCreateDateTime]	 
				   , [strSelectedInstrumentType] 
				   , [strCurrencyExchangeRateTypeId] 
				   , [strBank] 
				   , [strBuyBankAccount] 
				   , [strBankAccount] 
				   , [strOrderType] 
				   , [dblLimitRate] 
				   , [strMarketDate] 
				   , [ysnGTC] 
				   , [strTransactionDate] 
				   , [strMaturityDate] 
				   , [dblExchangeRate] 
				   , [dblContractAmount] 
				   , [dblMatchAmount] 
				   , [dblFinanceForwardRate]
				   , [strContractNumber]
				   , [strContractSequence]
				   , [strAssignOrHedge]
				   , [ysnCommissionExempt]
				   , [ysnCommissionOverride]
				   , [dblCommission]
			FROM tblRKFutOptTransactionImport 
			WHERE intFutOptTransactionId = @mRowNumber
		END
		
		SELECT @mRowNumber = MIN(intFutOptTransactionId)	FROM tblRKFutOptTransactionImport	WHERE intFutOptTransactionId > @mRowNumber
	END

	EXIT_ROUTINE:

	SELECT intFutOptTransactionErrLogId
		, intFutOptTransactionId
		, strName
		, strAccountNumber
		, strFutMarketName
		, strInstrumentType
		, strCommodityCode
		, strLocationName
		, strSalespersonId
		, strCurrency
		, strBrokerTradeNo
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, strOptionMonth
		, strOptionType
		, dblStrike
		, dblPrice
		, strReference
		, strStatus
		, strFilledDate
		, strBook
		, strSubBook
		, intConcurrencyId
		, strErrorMsg
		, strCreateDateTime
		, strSelectedInstrumentType
		, strCurrencyExchangeRateTypeId
		, strBank
		, strBuyBankAccount
		, strBankAccount
		, strOrderType
		, dblLimitRate
		, strMarketDate
		, ysnGTC
		, strTransactionDate
		, strMaturityDate
		, dblExchangeRate
		, dblContractAmount
		, dblMatchAmount
		, dblFinanceForwardRate
		, strContractNumber
		, strContractSequence
		, strAssignOrHedge
		, ysnCommissionExempt
		, ysnCommissionOverride
		, dblCommission
	FROM tblRKFutOptTransactionImport_ErrLog
	ORDER BY intFutOptTransactionErrLogId

	DROP TABLE #tmpRKUserSecurityLocations
	
	DELETE FROM tblRKFutOptTransactionImport_ErrLog
END TRY
BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH