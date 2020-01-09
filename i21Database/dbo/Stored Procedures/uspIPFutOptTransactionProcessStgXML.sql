﻿CREATE PROCEDURE uspIPFutOptTransactionProcessStgXML @intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intFutOptTransactionHeaderStageId INT
		,@intFutOptTransactionHeaderId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@intMultiCompanyId INT
		,@strUserName NVARCHAR(100)
		,@strTransactionType NVARCHAR(MAX)
	DECLARE @dtmTransactionDate DATETIME
	DECLARE @intLastModifiedUserId INT
		,@intNewFutOptTransactionHeaderId INT
		,@intFutOptTransactionHeaderRefId INT
	DECLARE @strFutOptTransactionXML NVARCHAR(MAX)
		,@intFutOptTransactionId INT
	DECLARE @strHeaderCondition NVARCHAR(MAX)
		,@strAckHeaderXML NVARCHAR(MAX)
		,@strAckFutOptTransactionXML NVARCHAR(MAX)
		,@intTransactionId INT
		,@intCompanyId INT
		,@intScreenId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT

	SELECT @intFutOptTransactionHeaderStageId = MIN(intFutOptTransactionHeaderStageId)
	FROM tblRKFutOptTransactionHeaderStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intMultiCompanyId = @intToCompanyId

	WHILE @intFutOptTransactionHeaderStageId > 0
	BEGIN
		SELECT @intFutOptTransactionHeaderId = NULL
			,@strHeaderXML = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@strTransactionType = NULL
			,@strUserName = NULL
			,@strFutOptTransactionXML = NULL
			,@intTransactionId = NULL
			,@intCompanyId = NULL
			,@intScreenId = NULL
			,@intTransactionRefId = NULL
			,@intCompanyRefId = NULL

		SELECT @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId
			,@strHeaderXML = strHeaderXML
			,@strFutOptTransactionXML = strFutOptTransactionXML
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@strTransactionType = strTransactionType
			,@strUserName = strUserName
			,@intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
		FROM tblRKFutOptTransactionHeaderStage
		WHERE intFutOptTransactionHeaderStageId = @intFutOptTransactionHeaderStageId

		BEGIN TRY
			SELECT @intFutOptTransactionHeaderRefId = @intFutOptTransactionHeaderId

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @dtmTransactionDate = NULL

			SELECT @dtmTransactionDate = dtmTransactionDate
			FROM OPENXML(@idoc, 'vyuIPGetFutOptTransactionHeaders/vyuIPGetFutOptTransactionHeader', 2) WITH (dtmTransactionDate DATETIME) x

			SELECT @intLastModifiedUserId = NULL

			SELECT @intLastModifiedUserId = t.intEntityId
			FROM tblEMEntity t
			JOIN tblEMEntityType ET ON ET.intEntityId = t.intEntityId
			WHERE ET.strType = 'User'
				AND t.strName = @strUserName
				AND t.strEntityNo <> ''

			IF @intLastModifiedUserId IS NULL
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblSMUserSecurity
						WHERE strUserName = 'irelyadmin'
						)
					SELECT TOP 1 @intLastModifiedUserId = intEntityId
					FROM tblSMUserSecurity
					WHERE strUserName = 'irelyadmin'
				ELSE
					SELECT TOP 1 @intLastModifiedUserId = intEntityId
					FROM tblSMUserSecurity
			END

			IF @strRowState <> 'Delete'
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblRKFutOptTransactionHeader
						WHERE intFutOptTransactionHeaderRefId = @intFutOptTransactionHeaderRefId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intNewFutOptTransactionHeaderId = intFutOptTransactionHeaderId
					,@dtmTransactionDate = dtmTransactionDate
				FROM tblRKFutOptTransactionHeader
				WHERE intFutOptTransactionHeaderRefId = @intFutOptTransactionHeaderRefId

				DELETE
				FROM tblRKFutOptTransactionHeader
				WHERE intFutOptTransactionHeaderRefId = @intFutOptTransactionHeaderRefId

				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				INSERT INTO tblRKFutOptTransactionHeader (
					intConcurrencyId
					,dtmTransactionDate
					,intSelectedInstrumentTypeId
					,strSelectedInstrumentType
					,intFutOptTransactionHeaderRefId
					)
				SELECT 1
					,dtmTransactionDate
					,intSelectedInstrumentTypeId
					,strSelectedInstrumentType
					,@intFutOptTransactionHeaderRefId
				FROM OPENXML(@idoc, 'vyuIPGetFutOptTransactionHeaders/vyuIPGetFutOptTransactionHeader', 2) WITH (
						dtmTransactionDate DATETIME
						,intSelectedInstrumentTypeId INT
						,strSelectedInstrumentType NVARCHAR(30)
						)

				SELECT @intNewFutOptTransactionHeaderId = SCOPE_IDENTITY()
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE tblRKFutOptTransactionHeader
				SET intConcurrencyId = intConcurrencyId + 1
					,dtmTransactionDate = x.dtmTransactionDate
					,intSelectedInstrumentTypeId = x.intSelectedInstrumentTypeId
					,strSelectedInstrumentType = x.strSelectedInstrumentType
				FROM OPENXML(@idoc, 'vyuIPGetFutOptTransactionHeaders/vyuIPGetFutOptTransactionHeader', 2) WITH (
						dtmTransactionDate DATETIME
						,intSelectedInstrumentTypeId INT
						,strSelectedInstrumentType NVARCHAR(30)
						) x
				WHERE tblRKFutOptTransactionHeader.intFutOptTransactionHeaderRefId = @intFutOptTransactionHeaderRefId

				SELECT @intNewFutOptTransactionHeaderId = intFutOptTransactionHeaderId
					,@dtmTransactionDate = dtmTransactionDate
				FROM tblRKFutOptTransactionHeader
				WHERE intFutOptTransactionHeaderRefId = @intFutOptTransactionHeaderRefId
			END

			EXEC sp_xml_removedocument @idoc

			------------------------------------Detail--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strFutOptTransactionXML

			DECLARE @tblRKFutOptTransaction TABLE (intFutOptTransactionId INT)

			INSERT INTO @tblRKFutOptTransaction (intFutOptTransactionId)
			SELECT intFutOptTransactionId
			FROM OPENXML(@idoc, 'vyuIPGetFutOptTransactions/vyuIPGetFutOptTransaction', 2) WITH (intFutOptTransactionId INT)

			SELECT @intFutOptTransactionId = MIN(intFutOptTransactionId)
			FROM @tblRKFutOptTransaction

			DECLARE @strName NVARCHAR(100)
				,@strAccountNumber NVARCHAR(50)
				,@strFutMarketName NVARCHAR(30)
				,@strCommodityCode NVARCHAR(50)
				,@strLocationName NVARCHAR(50)
				,@strTrader NVARCHAR(100)
				,@strCurrency NVARCHAR(40)
				,@strFutureMonth NVARCHAR(20)
				,@strRollingMonth NVARCHAR(20)
				,@strOptionMonth NVARCHAR(20)
				,@strBook NVARCHAR(100)
				,@strSubBook NVARCHAR(100)
				,@strBankName NVARCHAR(250)
				,@strBankAccountNo NVARCHAR(MAX)
				,@strCurrencyExchangeRateType NVARCHAR(20)
				,@intEntityId INT
				,@intBrokerageAccountId INT
				,@intFutureMarketId INT
				,@intBrokerageCommissionId INT
				,@intCommodityId INT
				,@intLocationId INT
				,@intTraderId INT
				,@intCurrencyId INT
				,@intFutureMonthId INT
				,@intRollingMonthId INT
				,@intOptionMonthId INT
				,@intBookId INT
				,@intSubBookId INT
				,@intBankId INT
				,@intBankAccountId INT
				,@intCurrencyExchangeRateTypeId INT

			DELETE
			FROM tblRKFutOptTransaction
			WHERE intFutOptTransactionHeaderId = @intNewFutOptTransactionHeaderId

			WHILE @intFutOptTransactionId IS NOT NULL
			BEGIN
				SELECT @strName = NULL
					,@strAccountNumber = NULL
					,@strFutMarketName = NULL
					,@strCommodityCode = NULL
					,@strLocationName = NULL
					,@strTrader = NULL
					,@strCurrency = NULL
					,@strFutureMonth = NULL
					,@strRollingMonth = NULL
					,@strOptionMonth = NULL
					,@strBook = NULL
					,@strSubBook = NULL
					,@strBankName = NULL
					,@strBankAccountNo = NULL
					,@strCurrencyExchangeRateType = NULL

				SELECT @strName = strName
					,@strAccountNumber = strAccountNumber
					,@strFutMarketName = strFutMarketName
					,@strCommodityCode = strCommodityCode
					,@strLocationName = strLocationName
					,@strTrader = strTrader
					,@strCurrency = strCurrency
					,@strFutureMonth = strFutureMonth
					,@strRollingMonth = strRollingMonth
					,@strOptionMonth = strOptionMonth
					,@strBook = strBook
					,@strSubBook = strSubBook
					,@strBankName = strBankName
					,@strBankAccountNo = strBankAccountNo
					,@strCurrencyExchangeRateType = strCurrencyExchangeRateType
				FROM OPENXML(@idoc, 'vyuIPGetFutOptTransactions/vyuIPGetFutOptTransaction', 2) WITH (
						strName NVARCHAR(100) Collate Latin1_General_CI_AS
						,strAccountNumber NVARCHAR(50) Collate Latin1_General_CI_AS
						,strFutMarketName NVARCHAR(30) Collate Latin1_General_CI_AS
						,strCommodityCode NVARCHAR(50) Collate Latin1_General_CI_AS
						,strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
						,strTrader NVARCHAR(100) Collate Latin1_General_CI_AS
						,strCurrency NVARCHAR(40) Collate Latin1_General_CI_AS
						,strFutureMonth NVARCHAR(20) Collate Latin1_General_CI_AS
						,strRollingMonth NVARCHAR(20) Collate Latin1_General_CI_AS
						,strOptionMonth NVARCHAR(20) Collate Latin1_General_CI_AS
						,strBook NVARCHAR(100) Collate Latin1_General_CI_AS
						,strSubBook NVARCHAR(100) Collate Latin1_General_CI_AS
						,strBankName NVARCHAR(250) Collate Latin1_General_CI_AS
						,strBankAccountNo NVARCHAR(MAX) Collate Latin1_General_CI_AS
						,strCurrencyExchangeRateType NVARCHAR(20) Collate Latin1_General_CI_AS
						,intFutOptTransactionId INT
						) SD
				WHERE intFutOptTransactionId = @intFutOptTransactionId

				IF @strName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblEMEntity t
						WHERE t.strName = @strName
						)
				BEGIN
					SELECT @strErrorMessage = 'Broker ' + @strName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strAccountNumber IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblRKBrokerageAccount t
						WHERE t.strAccountNumber = @strAccountNumber
						)
				BEGIN
					SELECT @strErrorMessage = 'Broker Account ' + @strAccountNumber + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strFutMarketName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblRKFutureMarket t
						WHERE t.strFutMarketName = @strFutMarketName
						)
				BEGIN
					SELECT @strErrorMessage = 'Future Market Name ' + @strFutMarketName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strCommodityCode IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblICCommodity t
						WHERE t.strCommodityCode = @strCommodityCode
						)
				BEGIN
					SELECT @strErrorMessage = 'Commodity ' + @strCommodityCode + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strLocationName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblSMCompanyLocation t
						WHERE t.strLocationName = @strLocationName
						)
				BEGIN
					SELECT @strErrorMessage = 'Location ' + @strLocationName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strTrader IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblEMEntity t
						WHERE t.strName = @strTrader
						)
				BEGIN
					SELECT @strErrorMessage = 'Trader ' + @strTrader + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strCurrency IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblSMCurrency t
						WHERE t.strCurrency = @strCurrency
						)
				BEGIN
					SELECT @strErrorMessage = 'Currency ' + @strCurrency + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strFutureMonth IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblRKFuturesMonth t
						WHERE t.strFutureMonth = @strFutureMonth
						)
				BEGIN
					SELECT @strErrorMessage = 'Future Month ' + @strFutureMonth + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strRollingMonth IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblRKFuturesMonth t
						WHERE t.strFutureMonth = @strRollingMonth
						)
				BEGIN
					SELECT @strErrorMessage = 'Rolling Month ' + @strRollingMonth + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strOptionMonth IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblRKOptionsMonth t
						WHERE t.strOptionMonth = @strOptionMonth
						)
				BEGIN
					SELECT @strErrorMessage = 'Option Month ' + @strOptionMonth + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strBook IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblCTBook t
						WHERE t.strBook = @strBook
						)
				BEGIN
					SELECT @strErrorMessage = 'Book ' + @strBook + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strSubBook IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblCTSubBook t
						WHERE t.strSubBook = @strSubBook
						)
				BEGIN
					SELECT @strErrorMessage = 'Sub Book ' + @strSubBook + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strBankName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblCMBank t
						WHERE t.strBankName = @strBankName
						)
				BEGIN
					SELECT @strErrorMessage = 'Bank Name ' + @strBankName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strBankAccountNo IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblCMBankAccount t
						WHERE t.strBankAccountNo = @strBankAccountNo
						)
				BEGIN
					SELECT @strErrorMessage = 'Bank Account No ' + @strBankAccountNo + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strCurrencyExchangeRateType IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblSMCurrencyExchangeRateType t
						WHERE t.strCurrencyExchangeRateType = @strCurrencyExchangeRateType
						)
				BEGIN
					SELECT @strErrorMessage = 'Currency Exchange Rate Type ' + @strCurrencyExchangeRateType + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intEntityId = NULL
					,@intBrokerageAccountId = NULL
					,@intFutureMarketId = NULL
					,@intBrokerageCommissionId = NULL
					,@intCommodityId = NULL
					,@intLocationId = NULL
					,@intTraderId = NULL
					,@intCurrencyId = NULL
					,@intFutureMonthId = NULL
					,@intRollingMonthId = NULL
					,@intOptionMonthId = NULL
					,@intBookId = NULL
					,@intSubBookId = NULL
					,@intBankId = NULL
					,@intBankAccountId = NULL
					,@intCurrencyExchangeRateTypeId = NULL

				SELECT @intEntityId = t.intEntityId
				FROM tblEMEntity t
				WHERE t.strName = @strName

				SELECT @intBrokerageAccountId = t.intBrokerageAccountId
				FROM tblRKBrokerageAccount t
				WHERE t.strAccountNumber = @strAccountNumber

				SELECT @intFutureMarketId = t.intFutureMarketId
				FROM tblRKFutureMarket t
				WHERE t.strFutMarketName = @strFutMarketName

				SELECT @intBrokerageCommissionId = t.intBrokerageCommissionId
				FROM tblRKBrokerageCommission t
				WHERE t.intBrokerageAccountId = @intBrokerageAccountId
					AND t.intFutureMarketId = @intFutureMarketId

				SELECT @intCommodityId = t.intCommodityId
				FROM tblICCommodity t
				WHERE t.strCommodityCode = @strCommodityCode

				SELECT @intLocationId = t.intCompanyLocationId
				FROM tblSMCompanyLocation t
				WHERE t.strLocationName = @strLocationName

				SELECT @intTraderId = t.intEntityId
				FROM tblEMEntity t
				WHERE t.strName = @strTrader

				SELECT @intCurrencyId = t.intCurrencyID
				FROM tblSMCurrency t
				WHERE t.strCurrency = @strCurrency

				SELECT @intFutureMonthId = t.intFutureMonthId
				FROM tblRKFuturesMonth t
				WHERE t.strFutureMonth = @strFutureMonth
					AND t.intFutureMarketId = @intFutureMarketId

				IF @intFutureMonthId IS NULL
				BEGIN
					SELECT @strErrorMessage = 'Future Market - Month ' + @strFutureMonth + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intRollingMonthId = t.intFutureMonthId
				FROM tblRKFuturesMonth t
				WHERE t.strFutureMonth = @strRollingMonth
					AND t.intFutureMarketId = @intFutureMarketId

				SELECT @intOptionMonthId = t.intOptionMonthId
				FROM tblRKOptionsMonth t
				WHERE t.strOptionMonth = @strOptionMonth

				SELECT @intBookId = t.intBookId
				FROM tblCTBook t
				WHERE t.strBook = @strBook

				SELECT @intSubBookId = t.intSubBookId
				FROM tblCTSubBook t
				WHERE t.strSubBook = @strSubBook

				SELECT @intBankId = t.intBankId
				FROM tblCMBank t
				WHERE t.strBankName = @strBankName

				SELECT @intBankAccountId = t.intBankAccountId
				FROM tblCMBankAccount t
				WHERE t.strBankAccountNo = @strBankAccountNo

				SELECT @intCurrencyExchangeRateTypeId = t.intCurrencyExchangeRateTypeId
				FROM tblSMCurrencyExchangeRateType t
				WHERE t.strCurrencyExchangeRateType = @strCurrencyExchangeRateType

				INSERT INTO tblRKFutOptTransaction (
					intFutOptTransactionHeaderId
					,intConcurrencyId
					,dtmTransactionDate
					,intEntityId
					,intBrokerageAccountId
					,intFutureMarketId
					,dblCommission
					,intBrokerageCommissionId
					,intInstrumentTypeId
					,intCommodityId
					,intLocationId
					,intTraderId
					,intCurrencyId
					,strInternalTradeNo
					,strBrokerTradeNo
					,strBuySell
					,dblNoOfContract
					,intFutureMonthId
					,intOptionMonthId
					,strOptionType
					,dblStrike
					,dblPrice
					,strReference
					,strStatus
					,dtmFilledDate
					,strReserveForFix
					,intBookId
					,intSubBookId
					,ysnOffset
					,intBankId
					,intBankAccountId
					--,intContractDetailId
					--,intContractHeaderId
					,intSelectedInstrumentTypeId
					,intCurrencyExchangeRateTypeId
					,strFromCurrency
					,strToCurrency
					,dtmMaturityDate
					,dblContractAmount
					,dblExchangeRate
					,dblMatchAmount
					,dblAllocatedAmount
					,dblUnAllocatedAmount
					,dblSpotRate
					,ysnLiquidation
					,ysnSwap
					,strRefSwapTradeNo
					--,intRefFutOptTransactionId
					,dtmCreateDateTime
					,ysnFreezed
					,intRollingMonthId
					,intFutOptTransactionRefId
					,ysnPreCrush
					)
				SELECT @intNewFutOptTransactionHeaderId
					,1
					,dtmTransactionDate
					,@intEntityId
					,@intBrokerageAccountId
					,@intFutureMarketId
					,dblCommission
					,@intBrokerageCommissionId
					,intInstrumentTypeId
					,@intCommodityId
					,@intLocationId
					,@intTraderId
					,@intCurrencyId
					,strInternalTradeNo
					,strBrokerTradeNo
					,strBuySell
					,dblNoOfContract
					,@intFutureMonthId
					,@intOptionMonthId
					,strOptionType
					,dblStrike
					,dblPrice
					,strReference
					,strStatus
					,dtmFilledDate
					,strReserveForFix
					,@intBookId
					,@intSubBookId
					,ysnOffset
					,@intBankId
					,@intBankAccountId
					--,intContractDetailId
					--,intContractHeaderId
					,intSelectedInstrumentTypeId
					,@intCurrencyExchangeRateTypeId
					,strFromCurrency
					,strToCurrency
					,dtmMaturityDate
					,dblContractAmount
					,dblExchangeRate
					,dblMatchAmount
					,dblAllocatedAmount
					,dblUnAllocatedAmount
					,dblSpotRate
					,ysnLiquidation
					,ysnSwap
					,strRefSwapTradeNo
					--,intRefFutOptTransactionId
					,dtmCreateDateTime
					,ysnFreezed
					,@intRollingMonthId
					,@intFutOptTransactionId
					,ysnPreCrush
				FROM OPENXML(@idoc, 'vyuIPGetFutOptTransactions/vyuIPGetFutOptTransaction', 2) WITH (
						dtmTransactionDate DATETIME
						,dblCommission NUMERIC(18, 6)
						,intInstrumentTypeId INT
						,strInternalTradeNo NVARCHAR(10)
						,strBrokerTradeNo NVARCHAR(50)
						,strBuySell NVARCHAR(10)
						,dblNoOfContract NUMERIC(18, 6)
						,strOptionType NVARCHAR(10)
						,dblStrike NUMERIC(18, 6)
						,dblPrice NUMERIC(18, 6)
						,strReference NVARCHAR(250)
						,strStatus NVARCHAR(250)
						,dtmFilledDate DATETIME
						,strReserveForFix NVARCHAR(50)
						,ysnOffset BIT
						,intSelectedInstrumentTypeId INT
						,strFromCurrency NVARCHAR(50)
						,strToCurrency NVARCHAR(50)
						,dtmMaturityDate DATETIME
						,dblContractAmount NUMERIC(18, 6)
						,dblExchangeRate NUMERIC(18, 6)
						,dblMatchAmount NUMERIC(18, 6)
						,dblAllocatedAmount NUMERIC(18, 6)
						,dblUnAllocatedAmount NUMERIC(18, 6)
						,dblSpotRate NUMERIC(18, 6)
						,ysnLiquidation BIT
						,ysnSwap BIT
						,strRefSwapTradeNo NVARCHAR(50)
						,dtmCreateDateTime DATETIME
						,ysnFreezed BIT
						,ysnPreCrush BIT
						,intFutOptTransactionId INT
						) x
				WHERE x.intFutOptTransactionId = @intFutOptTransactionId

				SELECT @intFutOptTransactionId = MIN(intFutOptTransactionId)
				FROM @tblRKFutOptTransaction
				WHERE intFutOptTransactionId > @intFutOptTransactionId
			END

			SELECT @strHeaderCondition = 'intFutOptTransactionHeaderId = ' + LTRIM(@intNewFutOptTransactionHeaderId)

			EXEC uspCTGetTableDataInXML 'vyuIPGetFutOptTransactionHeader'
				,@strHeaderCondition
				,@strAckHeaderXML OUTPUT

			EXEC uspCTGetTableDataInXML 'vyuIPGetFutOptTransaction'
				,@strHeaderCondition
				,@strAckFutOptTransactionXML OUTPUT

			ext:

			EXEC sp_xml_removedocument @idoc

			SELECT @intCompanyRefId = intCompanyId
			FROM tblRKFutOptTransactionHeader
			WHERE intFutOptTransactionHeaderId = @intNewFutOptTransactionHeaderId

			-- Audit Log
			IF (@intNewFutOptTransactionHeaderId > 0)
			BEGIN
				DECLARE @StrDescription AS NVARCHAR(MAX)

				IF @strRowState = 'Added'
				BEGIN
					SELECT @StrDescription = 'Created '

					EXEC uspSMAuditLog @keyValue = @intNewFutOptTransactionHeaderId
						,@screenName = 'RiskManagement.view.DerivativeEntry'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @dtmTransactionDate
				END
				ELSE IF @strRowState = 'Modified'
				BEGIN
					SELECT @StrDescription = 'Updated '

					EXEC uspSMAuditLog @keyValue = @intNewFutOptTransactionHeaderId
						,@screenName = 'RiskManagement.view.DerivativeEntry'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @dtmTransactionDate
				END
			END

			SELECT @intScreenId = intScreenId
			FROM tblSMScreen
			WHERE strNamespace = 'RiskManagement.view.DerivativeEntry'

			SELECT @intTransactionRefId = intTransactionId
			FROM tblSMTransaction
			WHERE intRecordId = @intNewFutOptTransactionHeaderId
				AND intScreenId = @intScreenId

			INSERT INTO tblRKFutOptTransactionHeaderAckStage (
				intFutOptTransactionHeaderId
				,strAckHeaderXML
				,strAckFutOptTransactionXML
				,strRowState
				,dtmFeedDate
				,strMessage
				,intMultiCompanyId
				,strTransactionType
				,intTransactionId
				,intCompanyId
				,intTransactionRefId
				,intCompanyRefId
				)
			SELECT @intNewFutOptTransactionHeaderId
				,@strAckHeaderXML
				,@strAckFutOptTransactionXML
				,@strRowState
				,GETDATE()
				,'Success'
				,@intMultiCompanyId
				,@strTransactionType
				,@intTransactionId
				,@intCompanyId
				,@intTransactionRefId
				,@intCompanyRefId

			EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionRefId
				,@referenceTransactionId = @intTransactionId
				,@referenceCompanyId = @intCompanyId

			UPDATE tblRKFutOptTransactionHeaderStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
			WHERE intFutOptTransactionHeaderStageId = @intFutOptTransactionHeaderStageId

			IF @intTransactionCount = 0
				COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			IF @idoc <> 0
				EXEC sp_xml_removedocument @idoc

			IF XACT_STATE() != 0
				AND @intTransactionCount = 0
				ROLLBACK TRANSACTION

			UPDATE tblRKFutOptTransactionHeaderStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
			WHERE intFutOptTransactionHeaderStageId = @intFutOptTransactionHeaderStageId
		END CATCH

		SELECT @intFutOptTransactionHeaderStageId = MIN(intFutOptTransactionHeaderStageId)
		FROM tblRKFutOptTransactionHeaderStage
		WHERE intFutOptTransactionHeaderStageId > @intFutOptTransactionHeaderStageId
			AND ISNULL(strFeedStatus, '') = ''
			AND intMultiCompanyId = @intToCompanyId
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
