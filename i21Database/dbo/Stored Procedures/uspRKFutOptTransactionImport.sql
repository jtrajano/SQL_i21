CREATE PROCEDURE uspRKFutOptTransactionImport
	@intEntityUserId NVARCHAR(100) = NULL

AS

BEGIN TRY
	DECLARE @tblRKFutOptTransactionHeaderId INT
		, @ErrMsg NVARCHAR(MAX)
		, @strDateTimeFormat NVARCHAR(50)
		, @ConvertYear INT
	
	SELECT @strDateTimeFormat = strDateTimeFormat FROM tblRKCompanyPreference
	
	IF (@strDateTimeFormat = 'MM DD YYYY HH:MI' OR @strDateTimeFormat ='YYYY MM DD HH:MI' OR @strDateTimeFormat = 'MM DD YYYY' OR @strDateTimeFormat ='YYYY MM DD')
		SET @ConvertYear = 101
	ELSE IF (@strDateTimeFormat = 'DD MM YYYY HH:MI' OR @strDateTimeFormat ='YYYY DD MM HH:MI' OR @strDateTimeFormat = 'DD MM YYYY' OR @strDateTimeFormat ='YYYY DD MM')
		SET @ConvertYear = 103
	
	DECLARE @strInternalTradeNo NVARCHAR(50) = NULL
		, @intFutOptTransactionHeaderId INT = NULL
		, @MaxTranNumber INT = NULL
		
	BEGIN TRAN
	
	IF NOT EXISTS(SELECT intFutOptTransactionId FROM tblRKFutOptTransactionImport_ErrLog)
	BEGIN
		DECLARE @intInstrument INT
			, @strInstrument NVARCHAR(30)
			
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
				, ti.dblNoOfContract
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
			SELECT TOP 1 @id = strInternalTradeNo FROM #temp
			
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
				, dblPContractBalanceLots)
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
			FROM #temp 
			WHERE strInternalTradeNo = @id

		
			DELETE FROM  #temp WHERE strInternalTradeNo = @id
		END
	END

	COMMIT TRAN

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
	FROM tblRKFutOptTransaction DE
	WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId
	
	EXEC dbo.uspSMAuditLog @keyValue = @intFutOptTransactionHeaderId			  -- Primary Key Value of the Derivative Entry. 
		, @screenName = 'RiskManagement.view.DerivativeEntry'  -- Screen Namespace
		, @entityId = @intEntityUserId                   	  -- Entity Id
		, @actionType = 'Imported'                             -- Action Type
		, @changeDescription = ''							  -- Description
		, @fromValue = ''									  -- Previous Value
		, @toValue = ''										  -- New Value

	DELETE FROM tblRKFutOptTransactionImport

END TRY
BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH