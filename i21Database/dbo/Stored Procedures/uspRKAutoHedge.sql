CREATE PROCEDURE uspRKAutoHedge
	@XML NVARCHAR(MAX)
	, @intUserId INT = NULL
	, @intFutOptTransactionId INT OUTPUT
	, @ysnReassign BIT = 0

AS

BEGIN TRY
	DECLARE @dtmTransactionDate DATETIME
		, @intEntityId INT
		, @intBrokerageAccountId INT
		, @intFutureMarketId INT
		, @intFutureMonthId INT
		, @intInstrumentTypeId INT
		, @intCommodityId INT
		, @intLocationId INT
		, @intTraderId INT
		, @strInternalTradeNo NVARCHAR(10)
		, @strBrokerTradeNo NVARCHAR(50)
		, @strBuySell NVARCHAR(10)
		, @dblNoOfContract NUMERIC(18, 6)
		, @dblPrice NUMERIC(18, 6)
		, @strStatus NVARCHAR(50)
		, @dtmFilledDate DATETIME
		, @strReserveForFix NVARCHAR(50)
		, @intBookId INT
		, @intSubBookId INT
		, @ysnOffset bit
		, @intFutOptTransactionHeaderId INT
		, @ErrMsg NVARCHAR(max)
		, @intCurrencyId INT
		, @intContractHeaderId INT
		, @intContractDetailId INT
		, @strXml  NVARCHAR(max)
		, @intMatchedLots INT
		, @ysnMultiplePriceFixation BIT
		, @strXmlNew  NVARCHAR(max)
		, @dblNoOfLots NUMERIC(18, 6)
		, @intSelectedInstrumentTypeId INT
		, @intHeaderPricingTypeId INT
		, @ysnIsHedged BIT = 1
	
	DECLARE @idoc INT
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML
	
	SELECT @intFutOptTransactionId = intFutOptTransactionId
		, @dtmTransactionDate = dtmTransactionDate
		, @intEntityId = intEntityId
		, @intBrokerageAccountId = intBrokerageAccountId
		, @intFutureMarketId = intFutureMarketId
		, @intFutureMonthId = intFutureMonthId
		, @intInstrumentTypeId = intInstrumentTypeId
		, @intCommodityId = intCommodityId
		, @intLocationId = intLocationId
		, @intTraderId = intTraderId
		, @strInternalTradeNo = strInternalTradeNo
		, @strBrokerTradeNo = strBrokerTradeNo
		, @strBuySell = strBuySell
		, @dblNoOfContract = dblNoOfContract
		, @dblPrice = dblPrice
		, @strStatus = strStatus
		, @dtmFilledDate = dtmFilledDate
		, @strReserveForFix = strReserveForFix
		, @intBookId = intBookId
		, @intSubBookId = intSubBookId
		, @ysnOffset = ysnOffset
		, @intCurrencyId = intCurrencyId
		, @intContractHeaderId = intContractHeaderId
		, @intContractDetailId = intContractDetailId
		, @intSelectedInstrumentTypeId = intSelectedInstrumentTypeId
	FROM OPENXML(@idoc, 'root', 2)
	WITH (intFutOptTransactionId INT
		, dtmTransactionDate DATETIME
		, intEntityId INT
		, intBrokerageAccountId INT
		, intFutureMarketId INT
		, intFutureMonthId INT
		, intInstrumentTypeId INT
		, intCommodityId INT
		, intLocationId INT
		, intTraderId INT
		, strInternalTradeNo NVARCHAR(10)
		, strBrokerTradeNo NVARCHAR(50)
		, strBuySell NVARCHAR(10)
		, dblNoOfContract NUMERIC(18, 6)
		, dblPrice NUMERIC(18, 6)
		, strStatus NVARCHAR(50)
		, dtmFilledDate DATETIME
		, strReserveForFix NVARCHAR(50)
		, intBookId INT
		, intSubBookId INT
		, ysnOffset BIT
		, intCurrencyId INT
		, CurrentDate DATETIME
		, intContractHeaderId INT
		, intContractDetailId INT
		, intSelectedInstrumentTypeId INT)
	
	INSERT INTO tblRKFutOptTransactionHeader (intConcurrencyId
		, dtmTransactionDate
		, intSelectedInstrumentTypeId
		, strSelectedInstrumentType)
	VALUES (1
		, @dtmTransactionDate
		, @intSelectedInstrumentTypeId
		, CASE WHEN ISNULL(@intSelectedInstrumentTypeId, 1) = 1 THEN 'Exchange Traded'
				WHEN @intSelectedInstrumentTypeId = 2 THEN 'OTC'
				ELSE 'OTC - Others' END)
	
	SELECT @intFutOptTransactionHeaderId = SCOPE_IDENTITY() 

	SELECT @ysnMultiplePriceFixation = ysnMultiplePriceFixation
		, @intHeaderPricingTypeId = intPricingTypeId
		, @ysnIsHedged = CASE WHEN ISNULL(ysnMultiplePriceFixation, 0) = 1 AND intPricingTypeId = 1 THEN  0 ELSE 1 END
	FROM tblCTContractHeader
	WHERE intContractHeaderId = @intContractHeaderId
	
	IF EXISTS (SELECT TOP 1 1 FROM tblRKReconciliationBrokerStatementHeader t
				WHERE t.intFutureMarketId = @intFutureMarketId
					AND t.intBrokerageAccountId = @intBrokerageAccountId
					AND t.intCommodityId = @intCommodityId
					AND t.intEntityId = @intEntityId
					AND ysnFreezed = 1
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmFilledDate, 110), 110) = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFilledDate, 110), 110))
	BEGIN
		RAISERROR('The selected filled date already reconciled.', 16, 1)
	END
	
	IF ISNULL(@intFutureMarketId, 0) = 0
	BEGIN
		RAISERROR('Market cannot be blank while creating hedge transaction.', 16, 1)
	END

	IF ISNULL(@intFutOptTransactionId, 0) > 0
	BEGIN
		SELECT @intMatchedLots = ISNULL(SUM(ISNULL(dblLots, 0.00)), 0.00) FROM tblRKOptionsPnSExercisedAssigned WHERE intFutOptTransactionId = @intFutOptTransactionId
		SELECT @intMatchedLots += ISNULL(SUM(ISNULL(dblMatchQty, 0.00)), 0.00) FROM tblRKMatchFuturesPSDetail WHERE intLFutOptTransactionId = @intFutOptTransactionId OR intSFutOptTransactionId = @intFutOptTransactionId
		
		IF (@ysnReassign = 0)
		BEGIN
			IF (@dblNoOfContract - @intMatchedLots) <= 0 
			BEGIN
				RAISERROR('Cannot change number of hedged lots as it is used in Match Futures Purchase and sales.', 16, 1)
			END
		END

		UPDATE tblRKFutOptTransaction
		SET intEntityId = @intEntityId
			, intBrokerageAccountId = @intBrokerageAccountId
			, intFutureMarketId =     @intFutureMarketId
			, intFutureMonthId =      @intFutureMonthId
			, dblNoOfContract = @dblNoOfContract
			, dtmFilledDate = @dtmFilledDate
			, dblPrice =  @dblPrice
		WHERE intFutOptTransactionId = @intFutOptTransactionId

		IF ISNULL(@intContractDetailId, 0) > 0
		BEGIN
			UPDATE tblRKAssignFuturesToContractSummary SET dblHedgedLots = @dblNoOfContract WHERE intContractDetailId = @intContractDetailId AND intFutOptTransactionId = @intFutOptTransactionId
		END
		ELSE
		BEGIN
			UPDATE tblRKAssignFuturesToContractSummary SET dblHedgedLots = @dblNoOfContract WHERE intContractHeaderId = @intContractHeaderId AND intFutOptTransactionId = @intFutOptTransactionId
		END

		
	END
	ELSE
	BEGIN
		IF ISNULL(@strInternalTradeNo, '') = ''
		BEGIN
			SELECT @strInternalTradeNo = strPrefix + LTRIM(intNumber)+ CASE WHEN @ysnIsHedged = 1 THEN '-H' ELSE '' END
			FROM tblSMStartingNumber WHERE intStartingNumberId = 45
			
			UPDATE tblSMStartingNumber SET intNumber = intNumber + 1 WHERE intStartingNumberId = 45
		END
		
		INSERT INTO tblRKFutOptTransaction (dtmTransactionDate
			, intFutOptTransactionHeaderId
			, intEntityId
			, intBrokerageAccountId
			, intFutureMarketId
			, intFutureMonthId
			, intInstrumentTypeId
			, intCommodityId
			, intLocationId
			, intTraderId
			, strInternalTradeNo
			, strBrokerTradeNo
			, strBuySell
			, dblNoOfContract
			, dblPrice
			, strStatus
			, dtmFilledDate
			, strReserveForFix
			, intBookId
			, intSubBookId
			, ysnOffset
			, intCurrencyId
			, intConcurrencyId
			, intSelectedInstrumentTypeId
			, dtmCreateDateTime)
		VALUES (CONVERT(DATETIME, CONVERT(CHAR(10), @dtmTransactionDate, 110))
			, @intFutOptTransactionHeaderId
			, @intEntityId
			, @intBrokerageAccountId
			, @intFutureMarketId
			, @intFutureMonthId
			, @intInstrumentTypeId
			, @intCommodityId
			, @intLocationId
			, @intTraderId
			, @strInternalTradeNo
			, @strBrokerTradeNo
			, @strBuySell
			, @dblNoOfContract
			, @dblPrice
			, @strStatus
			, CONVERT(DATETIME, CONVERT(CHAR(10), @dtmFilledDate, 110))
			, @strReserveForFix
			, @intBookId
			, @intSubBookId
			, @ysnOffset
			, @intCurrencyId
			, 1
			, @intSelectedInstrumentTypeId
			, GETDATE())
		
		SET @intFutOptTransactionId = SCOPE_IDENTITY()

		EXEC uspRKSaveDerivativeEntry @intFutOptTransactionId, NULL, @intUserId, ''
		
		SET @strXml = '<root><Transaction>';
		IF ISNULL(@ysnMultiplePriceFixation, 0) = 1
			SET @strXml = @strXml + '<intContractHeaderId>' + LTRIM(@intContractHeaderId) + '</intContractHeaderId>'
		IF ISNULL(@ysnMultiplePriceFixation, 0) = 0
			SET @strXml = @strXml + '<intContractDetailId>'+LTRIM(@intContractDetailId)+'</intContractDetailId>'
			
		SET @strXml = @strXml + '<dtmMatchDate>' + LTRIM(GETDATE()) + '</dtmMatchDate>'
		SET @strXml = @strXml + '<intFutOptTransactionId>' + LTRIM(@intFutOptTransactionId) + '</intFutOptTransactionId>'
		IF @ysnIsHedged = 1
		BEGIN
			SET @strXml = @strXml + '<dblHedgedLots>'+LTRIM(@dblNoOfContract)+'</dblHedgedLots>'
			SET @strXml = @strXml + '<dblAssignedLots>0</dblAssignedLots>'
		END
		ELSE
		BEGIN
			SET @strXml = @strXml + '<dblHedgedLots>0</dblHedgedLots>'
			SET @strXml = @strXml + '<dblAssignedLots>'+LTRIM(@dblNoOfContract)+'</dblAssignedLots>'
		END

		SET @strXml = @strXml + '<ysnIsHedged>'+LTRIM(@ysnIsHedged)+'</ysnIsHedged>'
		SET @strXml = @strXml + '</Transaction></root>'
		EXEC uspRKAssignFuturesToContractSummarySave @strXml
	END
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH