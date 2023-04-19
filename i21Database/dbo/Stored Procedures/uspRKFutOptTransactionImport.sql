CREATE PROCEDURE uspRKFutOptTransactionImport
	@intEntityUserId NVARCHAR(100) = NULL

AS

BEGIN TRY
	DECLARE @tblRKFutOptTransactionHeaderId INT
		, @ErrMsg NVARCHAR(MAX)
		, @strDateTimeFormat NVARCHAR(50)
		, @strDateTimeFormat2 NVARCHAR(50)
		, @ConvertYear INT
		, @ysnAllowDerivativeAssignToMultipleContracts BIT
	
	SELECT @strDateTimeFormat = strDateTimeFormat, @ysnAllowDerivativeAssignToMultipleContracts = ysnAllowDerivativeAssignToMultipleContracts FROM tblRKCompanyPreference
	SELECT @strDateTimeFormat2 = REPLACE(LEFT(LTRIM(RTRIM(strDateTimeFormat)),10), ' ', '-') FROM tblRKCompanyPreference;
	
	IF (@strDateTimeFormat = 'MM DD YYYY HH:MI' OR @strDateTimeFormat ='YYYY MM DD HH:MI' OR @strDateTimeFormat = 'MM DD YYYY' OR @strDateTimeFormat ='YYYY MM DD')
		SET @ConvertYear = 101
	ELSE IF (@strDateTimeFormat = 'DD MM YYYY HH:MI' OR @strDateTimeFormat ='YYYY DD MM HH:MI' OR @strDateTimeFormat = 'DD MM YYYY' OR @strDateTimeFormat ='YYYY DD MM')
		SET @ConvertYear = 103
	
	DECLARE @strInternalTradeNo NVARCHAR(100) = NULL
		, @intFutOptTransactionHeaderId INT = NULL
		, @intFutOptTransactionDetailId INT = NULL
		, @MaxTranNumber INT = NULL
		, @strInstrumentType NVARCHAR(50)

	DECLARE @tmpOTCTable TABLE(
		  intFutOptTransactionHeaderId INT
		, intFutOptTransactionId INT
	)

	DECLARE @tmpInstrumentTypeTable TABLE (
		 intSelectedInstrumentTypeId INT
		, strSelectedInstrumentType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	)

	DECLARE @tmpInstrumentType2Table TABLE (
		 intInstrumentTypeId INT
		, strInstrumentType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	)

	DECLARE @tmpOrderTypeTable TABLE (
		 intOrderTypeId INT
		, strOrderType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	)

	DECLARE @tmpAssignOrHedgeResult TABLE(
		  strResultOutput NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		  ,strInternalTradeNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	)
	
	INSERT INTO @tmpInstrumentTypeTable (intSelectedInstrumentTypeId, strSelectedInstrumentType)
	VALUES (1, 'Exchange Traded')
		 , (2, 'OTC')
		 , (3, 'OTC - Others')

	INSERT INTO @tmpInstrumentType2Table (intInstrumentTypeId, strInstrumentType)
	VALUES (1, 'Futures')
		 , (2, 'Options')
		 , (3, 'Spot')
		 , (4, 'Forward')
		 , (5, 'Swap')

	INSERT INTO @tmpOrderTypeTable (intOrderTypeId, strOrderType)
	VALUES (2, 'Limit')
		 , (3, 'Market')

	-- INSTRUMENT TYPE: EXCHANGE TRADED, OTC or OTC - Others.
	SELECT TOP 1 @strInstrumentType = strSelectedInstrumentType  FROM tblRKFutOptTransactionImport 
	
	BEGIN TRAN
	
	IF NOT EXISTS(SELECT intFutOptTransactionId FROM tblRKFutOptTransactionImport_ErrLog)
	BEGIN
		DECLARE @intInstrument INT
			, @strInstrument NVARCHAR(50)

		IF (@strInstrumentType = 'OTC')
		BEGIN
			SELECT * 
			INTO #tempTblOTC
			FROM (
				SELECT DISTINCT intConcurrencyId = 1 
					, strInternalTradeNo = ROW_NUMBER() OVER(ORDER BY intFutOptTransactionId) 
					, intSelectedInstrumentTypeId = instrument.intSelectedInstrumentTypeId
					, strSelectedInstrumentType = instrument.strSelectedInstrumentType
					, intInstrumentTypeId = instrument2.intInstrumentTypeId
					, intCommodityId = c.intCommodityId
					, intCompanyLocationId = l.intCompanyLocationId
					, strBuySell = ti.strBuySell
					, intCurrencyPairId = currencyPair.intCurrencyPairId
					, intFromCurrencyId = currencyPair.intToCurrencyId
					, intToCurrencyId = currencyPair.intFromCurrencyId
					, strFromCurrency = currencyPair.strToCurrency
					, strToCurrency = currencyPair.strFromCurrency
					, intBankId = bank.intBankId
					, intBuyBankAccountId = buyBankAcct.intBankAccountId
					, intBankAccountId = sellBankAcct.intBankAccountId
					, strBrokerTradeNo = ti.strBrokerTradeNo
					, intOrderTypeId = orderType.intOrderTypeId
					, strReference = ti.strReference
					, intBookId = b.intBookId
					, intSubBookId = sb.intSubBookId
					, dblLimitRate = ti.dblLimitRate
					, dblExchangeRate = ti.dblExchangeRate -- Finance Rate
					, dblContractAmount = ti.dblContractAmount -- Buy Amount
					, dblMatchAmount = ti.dblMatchAmount -- Sell Amount
					, dblFinanceForwardRate = ti.dblFinanceForwardRate
					, dtmCreateDateTime = CASE WHEN ISNULL(ti.strTransactionDate, '') <> '' THEN CONVERT(DATETIME, ti.strTransactionDate, @ConvertYear) ELSE GETDATE() END
					, dtmTransactionDate = CASE WHEN ISNULL(ti.strTransactionDate, '') <> '' THEN CONVERT(DATETIME, ti.strTransactionDate, @ConvertYear) ELSE NULL END 
					, dtmMarketDate = CASE WHEN ISNULL(ti.strMarketDate, '') <> '' THEN CONVERT(DATETIME, ti.strMarketDate, @ConvertYear) ELSE NULL END 
					, dtmMaturityDate = CASE WHEN ISNULL(ti.strMaturityDate, '') <> '' THEN CONVERT(DATETIME, ti.strMaturityDate, @ConvertYear) ELSE NULL END
					, ysnGTC = ti.ysnGTC
					, strSource = 'Import' COLLATE Latin1_General_CI_AS
				FROM tblRKFutOptTransactionImport ti
				JOIN tblICCommodity c ON c.strCommodityCode = ti.strCommodityCode
				JOIN tblSMCompanyLocation l ON l.strLocationName = ti.strLocationName
				LEFT JOIN tblCTBook b ON b.strBook = ti.strBook
				LEFT JOIN tblCTSubBook sb ON sb.strSubBook = ti.strSubBook AND b.intBookId = sb.intBookId
				LEFT JOIN @tmpInstrumentTypeTable instrument ON instrument.strSelectedInstrumentType = ti.strSelectedInstrumentType
				LEFT JOIN @tmpInstrumentType2Table instrument2 ON instrument2.strInstrumentType = ti.strInstrumentType
				LEFT JOIN vyuRKCurrencyPairSetup currencyPair ON currencyPair.strCurrencyPair = ti.strCurrencyExchangeRateTypeId
				LEFT JOIN tblCMBank bank ON bank.strBankName = ti.strBank
				LEFT JOIN vyuCMBankAccount buyBankAcct ON buyBankAcct.strBankAccountNo = ti.strBuyBankAccount
				LEFT JOIN vyuCMBankAccount sellBankAcct ON sellBankAcct.strBankAccountNo = ti.strBankAccount
				LEFT JOIN @tmpOrderTypeTable orderType ON orderType.strOrderType = ti.strOrderType
				WHERE ISNULL(ti.strInstrumentType, '') <> ''
				AND ISNULL(ti.strCommodityCode, '') <> '' 
				AND ISNULL(ti.strLocationName, '') <> '' 
				AND ISNULL(ti.strBuySell, '') <> '' 
				AND ISNULL(ti.strCurrencyExchangeRateTypeId, '') <> '' 
				AND ISNULL(ti.strBank, '') <> '' 
				AND ISNULL(ti.strBuyBankAccount, '') <> '' 
				AND ISNULL(ti.strBankAccount, '') <> '' 
			) t ORDER BY strInternalTradeNo

			DECLARE @rowId INT = NULL

			WHILE EXISTS (SELECT TOP 1 '' FROM #tempTblOTC)
			BEGIN
				SELECT TOP 1 @rowId = strInternalTradeNo FROM #tempTblOTC
				SELECT @intFutOptTransactionHeaderId = NULL
					, @intFutOptTransactionDetailId = NULL

				-- CREATE HEADER
				INSERT INTO tblRKFutOptTransactionHeader (
					  intConcurrencyId
					, dtmTransactionDate
					, intSelectedInstrumentTypeId
					, strSelectedInstrumentType
				)
				SELECT 
					  intConcurrencyId
					, dtmTransactionDate
					, intSelectedInstrumentTypeId
					, strSelectedInstrumentType
				FROM #tempTblOTC
				WHERE strInternalTradeNo = @rowId

				SELECT @intFutOptTransactionHeaderId = SCOPE_IDENTITY()
				
				EXEC uspSMGetStartingNumber 45, @strInternalTradeNo OUTPUT

				INSERT INTO tblRKFutOptTransaction (
					  intConcurrencyId 
					, intFutOptTransactionHeaderId
					, strInternalTradeNo
					, intSelectedInstrumentTypeId
					, intInstrumentTypeId
					, intCommodityId 
					, intLocationId
					, strBuySell
					, intCurrencyPairId 
					, intFromCurrencyId
					, intToCurrencyId
					, strFromCurrency
					, strToCurrency
					, intBankId
					, intBuyBankAccountId
					, intBankAccountId
					, strBrokerTradeNo 
					, intOrderTypeId
					, strReference
					, intBookId
					, intSubBookId
					, dblLimitRate
					, dblExchangeRate -- Finance Rate
					, dblContractAmount -- Buy Amount
					, dblMatchAmount -- Sell Amount
					, dblFinanceForwardRate
					, dtmCreateDateTime
					, dtmTransactionDate 
					, dtmMarketDate 
					, dtmMaturityDate 
					, strSource
					, ysnGTC
				)
				SELECT
					  intConcurrencyId 
					, intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId
					, strInternalTradeNo = @strInternalTradeNo
					, intSelectedInstrumentTypeId
					, intInstrumentTypeId
					, intCommodityId 
					, intLocationId = intCompanyLocationId
					, strBuySell
					, intCurrencyPairId 
					, intFromCurrencyId
					, intToCurrencyId
					, strFromCurrency
					, strToCurrency
					, intBankId
					, intBuyBankAccountId
					, intBankAccountId
					, strBrokerTradeNo 
					, intOrderTypeId
					, strReference
					, intBookId
					, intSubBookId
					, dblLimitRate
					, dblExchangeRate -- Finance Rate
					, dblContractAmount -- Buy Amount
					, dblMatchAmount -- Sell Amount
					, dblFinanceForwardRate
					, dtmCreateDateTime
					, dtmTransactionDate 
					, dtmMarketDate 
					, dtmMaturityDate 
					, strSource
					, ysnGTC
				FROM #tempTblOTC
				WHERE strInternalTradeNo = @rowId

				SELECT @intFutOptTransactionDetailId = SCOPE_IDENTITY()
				
				-- LIST RECORD
				INSERT INTO @tmpOTCTable (intFutOptTransactionHeaderId, intFutOptTransactionId)
				VALUES (@intFutOptTransactionHeaderId, @intFutOptTransactionDetailId)
			
				DELETE FROM #tempTblOTC WHERE strInternalTradeNo = @rowId
			END
			
			DROP TABLE #tempTblOTC
		END
		ELSE
		BEGIN
			SELECT TOP 1 @strInstrument = CASE WHEN ISNULL(ysnOTCOthers, 1) = 0 THEN 'Exchange Traded' ELSE 'OTC - Others' END
				, @intInstrument = CASE WHEN ISNULL(ysnOTCOthers, 1) = 0 THEN 1 ELSE 3 END
			FROM (
				SELECT DISTINCT ysnOTCOthers = ISNULL(ysnOTCOthers, 0)
				FROM tblRKFutOptTransactionImport i
				JOIN tblRKBrokerageAccount b ON b.strAccountNumber = i.strAccountNumber
			) t
		
			INSERT INTO tblRKFutOptTransactionHeader (intConcurrencyId, dtmTransactionDate, intSelectedInstrumentTypeId, strSelectedInstrumentType)
			VALUES (1, GETDATE(), @intInstrument, @strInstrument)
		
			SELECT @intFutOptTransactionHeaderId = SCOPE_IDENTITY()

			DECLARE @tmpCommission TABLE (
				dblCommissionRate NUMERIC(18,6)
				,strCommissionRateType NVARCHAR(50)
				,intBrokerageCommissionId INT
			)
			
			SELECT * INTO #temp
			FROM (
				SELECT DISTINCT @intFutOptTransactionHeaderId intFutOptTransactionHeaderId
					, 1 intConcurrencyId
					, GETDATE() dtmTransactionDate
					, em.intEntityId
					, intBrokerageAccountId
					, fm.intFutureMarketId
					, CASE WHEN ti.strInstrumentType = 'Futures' THEN 1 ELSE 2 END intInstrumentTypeId
					, c.intCommodityId
					, l.intCompanyLocationId
					, sp.intEntityId intTraderId
					, cur.intCurrencyID
					, ROW_NUMBER() OVER(ORDER BY intFutOptTransactionId) strInternalTradeNo
					, ti.strBrokerTradeNo
					, ti.strBuySell
					, dblNoOfContract = ABS(ti.dblNoOfContract)
					, m.intFutureMonthId
					, intOptionMonthId
					, strOptionType
					, ti.dblStrike
					, ti.dblPrice
					, strReference
					, strStatus
					, CONVERT(DATETIME, ti.strFilledDate, @ConvertYear) dtmFilledDate
					, b.intBookId
					, sb.intSubBookId
					, CONVERT(DATETIME, strCreateDateTime, @ConvertYear) dtmCreateDateTime
					, strContractNumber
					, strContractSequence
					, strAssignOrHedge
					, ysnCommissionExempt
					, ysnCommissionOverride
					, dblCommission
					, ti.dblToAssignOrHedgeLots
				FROM tblRKFutOptTransactionImport ti
				JOIN tblRKFutureMarket fm ON fm.strFutMarketName = ti.strFutMarketName
				JOIN tblRKBrokerageAccount ba ON ba.strAccountNumber = ti.strAccountNumber
				JOIN tblEMEntity em ON ba.intEntityId = em.intEntityId AND em.strName = ti.strName
				JOIN tblICCommodity c ON c.strCommodityCode = ti.strCommodityCode
				JOIN tblSMCompanyLocation l ON l.strLocationName = ti.strLocationName
				JOIN vyuHDSalesPerson sp ON sp.strName = ti.strSalespersonId AND sp.strSalesPersonType = 'Sales Rep Entity' AND sp.ysnActiveSalesPerson = 1
				JOIN tblSMCurrency cur ON cur.strCurrency = ti.strCurrency
				JOIN tblRKFuturesMonth m ON m.strFutureMonth = REPLACE(ti.strFutureMonth, '-', ' ') AND m.intFutureMarketId = fm.intFutureMarketId
				LEFT JOIN tblRKOptionsMonth om ON om.strOptionMonth = REPLACE(ti.strOptionMonth, '-', ' ') AND om.intFutureMarketId = fm.intFutureMarketId
				LEFT JOIN tblCTBook b ON b.strBook = ti.strBook
				LEFT JOIN tblCTSubBook sb ON sb.strSubBook = ti.strSubBook AND b.intBookId = sb.intBookId
				WHERE ISNULL(ti.strName, '') <> '' AND ISNULL(ti.strFutMarketName, '') <> '' AND ISNULL(ti.strInstrumentType, '') <> ''
					AND ISNULL(ti.strAccountNumber, '') <> '' AND ISNULL(ti.strCommodityCode, '') <> '' AND ISNULL(ti.strLocationName, '') <> '' AND ISNULL(ti.strSalespersonId, '') <> ''
			)t ORDER BY strInternalTradeNo

		
			WHILE EXISTS (SELECT TOP 1 1 FROM #temp)
			BEGIN
				DECLARE @id INT
					, @newTransactionId INT
					, @strContractNumber NVARCHAR(100)
					, @strContractSequence NVARCHAR(100)
					, @strAssignOrHedge NVARCHAR(100)
					, @dblNoOfContract NUMERIC(18,6)
					, @intFutOptTransactionId INT
					, @strBuySell NVARCHAR(10)
					, @intBrokerageAccountId INT
					, @intFutureMarketId INT
					, @dtmTransactionDate DATETIME
					, @intInstrumentTypeId INT
					, @strResultOutput NVARCHAR(MAX)
					, @dblCommissionRate NUMERIC(18,6)
					, @strCommissionRateType NVARCHAR(50)
					, @intBrokerageCommissionId INT
					, @dblToAssignOrHedgeLots NUMERIC(18,6)
					
					
				
				
				SELECT TOP 1 
					@id = strInternalTradeNo 
					, @strContractNumber = strContractNumber
					, @strContractSequence = strContractSequence
					, @strAssignOrHedge = strAssignOrHedge
					, @dblNoOfContract  = dblNoOfContract
					, @strBuySell = strBuySell
					, @intBrokerageAccountId = intBrokerageAccountId
					, @intFutureMarketId = intFutureMarketId
					, @dtmTransactionDate = GETDATE()
					, @intInstrumentTypeId = intInstrumentTypeId
					, @dblToAssignOrHedgeLots = dblToAssignOrHedgeLots
				FROM #temp

				--Call uspRKGetCommission
				INSERT INTO @tmpCommission
				EXEC uspRKGetCommission @intBrokerageAccountId , @intFutureMarketId , @dtmTransactionDate , @intInstrumentTypeId 
				

				SELECT TOP 1
					 @dblCommissionRate = dblCommissionRate
					,@strCommissionRateType = strCommissionRateType
					,@intBrokerageCommissionId = intBrokerageCommissionId
				FROM @tmpCommission

			
				EXEC uspSMGetStartingNumber 45, @strInternalTradeNo OUTPUT
			
				INSERT INTO tblRKFutOptTransaction (intSelectedInstrumentTypeId
					, intFutOptTransactionHeaderId
					, intConcurrencyId
					, dtmTransactionDate
					, intEntityId
					, intBrokerageAccountId
					, intFutureMarketId
					, intInstrumentTypeId
					, intCommodityId
					, intLocationId
					, intTraderId
					, intCurrencyId
					, strInternalTradeNo
					, strBrokerTradeNo
					, strBuySell
					, dblNoOfContract
					, intFutureMonthId
					, intOptionMonthId
					, strOptionType
					, dblStrike
					, dblPrice
					, strReference
					, strStatus
					, dtmFilledDate
					, intBookId
					, intSubBookId
					, dtmCreateDateTime
					, dblSContractBalanceLots
					, dblPContractBalanceLots
					, intBrokerageCommissionId
					, strCommissionRateType 
					, dblBrokerageRate
					, dblCommission
					, ysnCommissionExempt
					, ysnCommissionOverride)
				SELECT @intInstrument
					, intFutOptTransactionHeaderId
					, intConcurrencyId
					, dtmTransactionDate
					, intEntityId
					, intBrokerageAccountId
					, intFutureMarketId
					, intInstrumentTypeId
					, intCommodityId
					, intCompanyLocationId
					, intTraderId
					, intCurrencyID
					, @strInternalTradeNo
					, strBrokerTradeNo
					, strBuySell
					, dblNoOfContract
					, intFutureMonthId
					, intOptionMonthId
					, strOptionType
					, dblStrike
					, dblPrice
					, strReference
					, strStatus
					, dtmFilledDate
					, intBookId
					, intSubBookId
					, dtmCreateDateTime
					, dblNoOfContract
					, dblNoOfContract
					, @intBrokerageCommissionId
					, @strCommissionRateType
					, @dblCommissionRate
					, dblCommission = CASE WHEN ysnCommissionExempt = 1 THEN NULL WHEN ysnCommissionOverride = 1 THEN dblCommission ELSE (@dblCommissionRate * dblNoOfContract) * -1 END
					, ysnCommissionExempt
					, ysnCommissionOverride
				FROM #temp 
				WHERE strInternalTradeNo = @id


				DELETE FROM @tmpCommission

				
				IF @ysnAllowDerivativeAssignToMultipleContracts = 0 
				BEGIN
					DECLARE @dblLotsToAssignOrHedge NUMERIC(18, 6)
					SELECT @dblLotsToAssignOrHedge = CASE WHEN ISNULL(@dblToAssignOrHedgeLots, 0) <> 0 
														THEN @dblToAssignOrHedgeLots
														ELSE @dblNoOfContract 
														END

					SELECT @intFutOptTransactionId = SCOPE_IDENTITY()

					IF @strAssignOrHedge = 'Assign'
					BEGIN
						
						EXEC uspRKAutoAssignDerivative @strContractNumber, @strContractSequence, @intFutOptTransactionId, @strInternalTradeNo, @dblLotsToAssignOrHedge, @strResultOutput OUTPUT

						IF ISNULL(@strResultOutput,'') <> ''
						BEGIN
							INSERT INTO @tmpAssignOrHedgeResult(strResultOutput,strInternalTradeNo)
							SELECT @strResultOutput, @strInternalTradeNo
						END
					END

					IF @strAssignOrHedge = 'Hedge'
					BEGIN

						EXEC uspRKAutoHedgeDerivative @strContractNumber, @strContractSequence, @intFutOptTransactionId, @intEntityUserId, @strResultOutput OUTPUT

						IF ISNULL(@strResultOutput,'') <> ''
						BEGIN
							INSERT INTO @tmpAssignOrHedgeResult(strResultOutput,strInternalTradeNo)
							SELECT @strResultOutput, @strInternalTradeNo
						END
					END 
				END

		
				DELETE FROM  #temp WHERE strInternalTradeNo = @id
			END
		END
	END

	COMMIT TRAN

	IF (@strInstrumentType = 'OTC')
	BEGIN
		SELECT * 
		INTO #tmpOTCTable
		FROM @tmpOTCTable

		WHILE EXISTS (SELECT TOP 1 '' FROM #tmpOTCTable)
		BEGIN
			SELECT @intFutOptTransactionHeaderId = NULL
				, @intFutOptTransactionDetailId = NULL

			SELECT TOP 1 @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId
				, @intFutOptTransactionDetailId = intFutOptTransactionId
			FROM #tmpOTCTable
			
			EXEC [uspRKFutOptTransactionHistory] @intFutOptTransactionId = @intFutOptTransactionDetailId
				, @intFutOptTransactionHeaderId = NULL
				, @strScreenName = 'Derivative Entry Import'
				, @intUserId = @intEntityUserId
				, @action = 'ADD'
				
			EXEC uspIPInterCompanyPreStageFutOptTransaction 
					  @intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId
					, @strRowState = 'Added'
					, @intUserId = @intEntityUserId
				
			EXEC dbo.uspSMAuditLog @keyValue = @intFutOptTransactionHeaderId -- Primary Key Value of the Derivative Entry. 
				, @screenName = 'RiskManagement.view.DerivativeEntry'		 -- Screen Namespace
				, @entityId = @intEntityUserId                   			 -- Entity Id
				, @actionType = 'Imported'									 -- Action Type
				, @changeDescription = ''									 -- Description
				, @fromValue = ''											 -- Previous Value
				, @toValue = ''												 -- New Value

			DELETE FROM #tmpOTCTable 
			WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId
			AND intFutOptTransactionId = @intFutOptTransactionDetailId
		END

		--This will return the newly created Derivative Entry
		SELECT DE.strInternalTradeNo AS Result1
			, DE.strBrokerTradeNo AS Result2
			, DE.dtmFilledDate AS Result3
		FROM tblRKFutOptTransaction DE
		WHERE intFutOptTransactionHeaderId IN (SELECT intFutOptTransactionHeaderId FROM @tmpOTCTable)
	END
	ELSE
	BEGIN
		SELECT intFutOptTransactionId 
		INTO #tmpDerivativeIds
		FROM tblRKFutOptTransaction
		WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId
		ORDER BY intFutOptTransactionId

		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpDerivativeIds)
		BEGIN
			SELECT TOP 1 @newTransactionId = intFutOptTransactionId FROM #tmpDerivativeIds ORDER BY intFutOptTransactionId

			EXEC [uspRKFutOptTransactionHistory] @intFutOptTransactionId = @newTransactionId
					, @intFutOptTransactionHeaderId = NULL
					, @strScreenName = 'Derivative Entry Import'
					, @intUserId = @intEntityUserId
					, @action = 'ADD'

			DELETE FROM #tmpDerivativeIds WHERE intFutOptTransactionId = @newTransactionId
		END

		EXEC uspIPInterCompanyPreStageFutOptTransaction @intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId
				, @strRowState = 'Added'
				, @intUserId = @intEntityUserId

		--This will return the newly created Derivative Entry
		SELECT DE.strInternalTradeNo AS Result1
			, DE.strBrokerTradeNo AS Result2
			, DE.dtmFilledDate AS Result3
			, AH.strResultOutput AS Result4
		FROM tblRKFutOptTransaction DE
		LEFT JOIN @tmpAssignOrHedgeResult AH ON AH.strInternalTradeNo = DE.strInternalTradeNo
		WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId


	
		EXEC dbo.uspSMAuditLog @keyValue = @intFutOptTransactionHeaderId			  -- Primary Key Value of the Derivative Entry. 
			, @screenName = 'RiskManagement.view.DerivativeEntry'  -- Screen Namespace
			, @entityId = @intEntityUserId                   	  -- Entity Id
			, @actionType = 'Imported'                             -- Action Type
			, @changeDescription = ''							  -- Description
			, @fromValue = ''									  -- Previous Value
			, @toValue = ''										  -- New Value
	END

	DELETE FROM tblRKFutOptTransactionImport
END TRY
BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH