CREATE PROCEDURE [dbo].[uspRKCreateOtcForwardFromCT]
	  @intSellCurrencyId INT
	, @intBuyCurrencyId INT
	, @dblBuyAmount NUMERIC(24, 10)
	, @dblSellAmount NUMERIC(24, 10)
	, @dtmMaturityDate DATETIME
	, @dtmTradeDate DATETIME
	, @dblContractRate NUMERIC(24, 10)
	, @intLocationId INT
	, @intUserId INT
	, @intContractHeaderId INT
	, @intContractDetailId INT
	, @intFutOptTransactionHeaderId INT OUTPUT
	, @intFutOptTransactionId INT OUTPUT
	, @strInternalTradeNo NVARCHAR(200) OUTPUT
	, @intOrderTypeId INT = NULL
	, @dblLimitRate NUMERIC(24, 10) = NULL
	, @dtmMarketDate DATETIME = NULL
	, @ysnGTC BIT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @intCommodityId INT
		, @strBuyCurrency NVARCHAR(200)
		, @strSellCurrency NVARCHAR(200)
		, @intCurrencyPairId INT = NULL
		, @ErrMsg NVARCHAR(MAX) = NULL
		, @dblFXRateDecimals NUMERIC(16, 8)
		
	SELECT @strBuyCurrency = strCurrency FROM tblSMCurrency WHERE intCurrencyID = @intBuyCurrencyId
	SELECT @strSellCurrency = strCurrency FROM tblSMCurrency WHERE intCurrencyID = @intSellCurrencyId
	SELECT @dblFXRateDecimals = dblFXRateDecimals FROM tblRKCompanyPreference
	
	SELECT @intCurrencyPairId = intCurrencyPairId 
	FROM 
	(
		--SELECT TOP 1 intRateTypeId
		--FROM tblSMCurrencyExchangeRateDetail fxRateDetail
		--CROSS APPLY (SELECT TOP 1 intCurrencyExchangeRateId FROM tblSMCurrencyExchangeRate fxr
		--	WHERE fxr.intFromCurrencyId = @intBuyCurrencyId 
		--	AND fxr.intToCurrencyId = @intSellCurrencyId 
		--	AND fxr.intCurrencyExchangeRateId = fxRateDetail.intCurrencyExchangeRateId
		--) fxRate
		--WHERE dtmValidFromDate <= GETDATE()
		--ORDER BY dtmValidFromDate DESC

		SELECT TOP 1 intCurrencyPairId = intCurrencyPairId
		FROM vyuRKCurrencyPairSetup
		WHERE intFromCurrencyId = @intSellCurrencyId 
		AND intToCurrencyId = @intBuyCurrencyId 
	) t

	IF (ISNULL(@intCurrencyPairId, 0) = 0)
	BEGIN
		SET @ErrMsg = 'The Currency Pair Setup for Sell (' + @strSellCurrency + ') and Buy (' + @strBuyCurrency + ') Currencies is not existing.'
		RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
		RETURN
	END

	SELECT TOP 1 @intCommodityId = intCommodityId FROM tblICCommodity
	WHERE strCommodityCode = 'Currency'

	IF (ISNULL(@intCommodityId, '') = '')
	BEGIN
		SET @ErrMsg = 'The Commodity ''Currency'' is not existing.'
		RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
		RETURN
	END

	DECLARE @dblDecimalCount INT
		, @strDecimalValues NVARCHAR(100)

	-- CONTRACT RATE DECIMAL PLACE VALIDATION
	SELECT @strDecimalValues = CAST(CAST(@dblContractRate AS float) AS NVARCHAR(100))
	SELECT @dblDecimalCount = LEN(RIGHT(@strDecimalValues, LEN(@strDecimalValues) - CHARINDEX('.', @strDecimalValues)))

	IF ISNULL(@dblDecimalCount, 0) > @dblFXRateDecimals
	BEGIN
		SET @ErrMsg = 'Contract Rate Decimals should not exceed FX Rate Decimal config (' + CAST(CAST(@dblFXRateDecimals AS INT) AS NVARCHAR(10)) + ').'
		RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
		RETURN
	END
	
	-- LIMIT RATE DECIMAL PLACE VALIDATION
	SELECT @strDecimalValues = CAST(CAST(@dblLimitRate AS float) AS NVARCHAR(100))
	SELECT @dblDecimalCount = LEN(RIGHT(@strDecimalValues, LEN(@strDecimalValues) - CHARINDEX('.', @strDecimalValues)))

	IF ISNULL(@dblDecimalCount, 0) > @dblFXRateDecimals
	BEGIN
		SET @ErrMsg = 'Limit Rate Decimals should not exceed FX Rate Decimal config (' + CAST(CAST(@dblFXRateDecimals AS INT) AS NVARCHAR(10)) + ').'
		RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
		RETURN
	END

	IF (ISNULL(@ErrMsg, '') <> '')
	BEGIN 
		RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
		RETURN
	END

	-- CREATE DERIVATIVE HEADER
	INSERT INTO tblRKFutOptTransactionHeader (
		intConcurrencyId
		, dtmTransactionDate
		, intSelectedInstrumentTypeId
		, strSelectedInstrumentType
	)
	SELECT 
		  intConcurrencyId = @intUserId
		, dtmTransactionDate = @dtmTradeDate
		, intSelectedInstrumentTypeId = 2
		, strSelectedInstrumentType = 'OTC'
		
	-- GET ID OF CREATED HEADER
	SELECT @intFutOptTransactionHeaderId = SCOPE_IDENTITY()

	-- GENERATE TRADE NO
	EXEC uspSMGetStartingNumber 45, @strInternalTradeNo OUT

	-- CREATE DERIVATIVE DETAILS
	INSERT INTO tblRKFutOptTransaction (
		  intFutOptTransactionHeaderId
		, intConcurrencyId
		, dtmTransactionDate
		, intInstrumentTypeId 
		, intCommodityId
		, intLocationId
		, strInternalTradeNo
		, strBuySell
		, intBankId
		, intBankAccountId
		, intSelectedInstrumentTypeId
		, intFromCurrencyId
		, intToCurrencyId
		, strFromCurrency
		, strToCurrency
		, dtmMaturityDate
		, dblContractRate
		, dtmCreateDateTime
		, intContractHeaderId
		, intContractDetailId
		, dblContractAmount
		, dblMatchAmount
		, intOrderTypeId
		--, intCurrencyExchangeRateTypeId
		, intCurrencyPairId
		, dblLimitRate
		, dtmMarketDate
		, ysnGTC
		, strSource
	)
	SELECT 
		intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId
		, intConcurrencyId = @intUserId
		, dtmTransactionDate = @dtmTradeDate
		, intInstrumentTypeId = 4 -- 4 = FORWARD
		, intCommodityId = @intCommodityId
		, intLocationId = @intLocationId
		, strInternalTradeNo = @strInternalTradeNo
		, strBuySell = 'Buy'
		, intBankId = NULL
		, intBankAccountId = NULL 
		, intSelectedInstrumentTypeId = 2 -- 2 = OTC
		, intFromCurrencyId = @intBuyCurrencyId
		, intToCurrencyId = @intSellCurrencyId
		, strFromCurrency = @strBuyCurrency
		, strToCurrency = @strSellCurrency
		, dtmMaturityDate = @dtmMaturityDate
		, dblContractRate = @dblContractRate
		, dtmCreateDateTime = GETDATE()
		, intContractHeaderId = @intContractHeaderId
		, intContractDetailId = @intContractDetailId
		, dblContractAmount = @dblBuyAmount
		, dblMatchAmount = @dblSellAmount
		, intOrderTypeId = @intOrderTypeId
		--, intCurrencyExchangeRateTypeId = @intCurrencyPair
		, intCurrencyPairId = @intCurrencyPairId
		, dblLimitRate = @dblLimitRate 
		, dtmMarketDate = @dtmMarketDate 
		, ysnGTC = @ysnGTC 
		, strSource = 'Contract'

	SELECT @intFutOptTransactionId = SCOPE_IDENTITY()

	EXEC uspRKFutOptTransactionHistory @intFutOptTransactionId, @intFutOptTransactionHeaderId, 'FutOptTransaction', @intUserId, 'ADD', 0
	
	EXEC dbo.uspSMAuditLog @keyValue = @intFutOptTransactionHeaderId				-- Primary Key Value of the Derivative Entry. 
		, @screenName = 'RiskManagement.view.DerivativeEntry'						-- Screen Namespace
		, @entityId = @intUserId                   									-- Entity Id
		, @actionType = 'Created'													-- Action Type
		, @changeDescription = ''													-- Description
		, @fromValue = ''															-- Previous Value
		, @toValue = ''																-- New Value

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH