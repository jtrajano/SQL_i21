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
		, @ErrMsg NVARCHAR(MAX) = NULL

	SELECT @strSellCurrency = strCurrency FROM tblSMCurrency WHERE intCurrencyID = @intSellCurrencyId
	SELECT @strBuyCurrency = strCurrency FROM tblSMCurrency WHERE intCurrencyID = @intBuyCurrencyId

	SELECT TOP 1 @intCommodityId = intCommodityId FROM tblICCommodity
	WHERE strCommodityCode = 'Currency'

	IF (ISNULL(@intCommodityId, '') = '')
	BEGIN
		SET @ErrMsg = 'The Commodity ''Currency'' is not existing.'

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
		, strFromCurrency
		, strToCurrency
		, dtmMaturityDate
		, dblContractRate
		, dtmCreateDateTime
		, intContractHeaderId
		, intContractDetailId
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
		, strFromCurrency = @strBuyCurrency
		, strToCurrency = @strSellCurrency
		, dtmMaturityDate = @dtmMaturityDate
		, dblContractRate = @dblContractRate
		, dtmCreateDateTime = GETDATE()
		, intContractHeaderId = @intContractHeaderId
		, intContractDetailId = @intContractDetailId

	SELECT @intFutOptTransactionId = SCOPE_IDENTITY()

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH