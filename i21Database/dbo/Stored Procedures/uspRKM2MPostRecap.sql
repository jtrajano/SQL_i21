CREATE PROCEDURE [dbo].[uspRKM2MPostRecap]
	@intM2MInquiryId INT
	, @intUserId INT

AS

BEGIN
	DECLARE @intCurrencyId INT
	DECLARE @strRecordName NVARCHAR(100)
	
	IF EXISTS(SELECT TOP 1 1 FROM tblRKM2MPostRecap WHERE intM2MInquiryId = @intM2MInquiryId)
	RETURN

	DECLARE @dtmGLPostDate DATETIME
		, @intCommodityId INT
		, @Todate DATETIME
		, @intUnitMeasureId INT
		, @intLocationId INT
		, @strRateType NVARCHAR(50)
	
	SELECT @dtmGLPostDate = ISNULL(dtmGLPostDate, GETDATE())
		, @intCurrencyId = intCurrencyId
		, @intCommodityId = intCommodityId
		, @Todate = dtmTransactionUpTo
		, @strRecordName = strRecordName
		, @intLocationId = intCompanyLocationId
		, @intUnitMeasureId = intUnitMeasureId
		, @strRateType = strRateType
	FROM tblRKM2MInquiry WHERE intM2MInquiryId = @intM2MInquiryId

	IF @strRateType = 'Stress Test' RETURN

	DECLARE @GLAccounts TABLE(strCategory NVARCHAR(100)
		, intAccountId INT
		, strAccountNo NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, ysnHasError BIT
		, strErrorMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS)

	DECLARE @intUnrealizedGainOnBasisId INT
		, @intUnrealizedGainOnFuturesId INT
		, @intUnrealizedGainOnCashId INT
		, @intUnrealizedLossOnBasisId INT
		, @intUnrealizedLossOnFuturesId INT
		, @intUnrealizedLossOnCashId INT
		, @intUnrealizedGainOnInventoryBasisIOSId INT
		, @intUnrealizedGainOnInventoryFuturesIOSId INT
		, @intUnrealizedGainOnInventoryCashIOSId INT
		, @intUnrealizedLossOnInventoryBasisIOSId INT
		, @intUnrealizedLossOnInventoryFuturesIOSId INT
		, @intUnrealizedLossOnInventoryCashIOSId INT
		, @intUnrealizedGainOnInventoryIntransitIOSId INT
		, @intUnrealizedLossOnInventoryIntransitIOSId INT
		, @intUnrealizedGainOnRatioId INT
		, @intUnrealizedLossOnRatioId INT
		, @intUnrealizedGainOnInventoryRatioIOSId INT
		, @intUnrealizedLossOnInventoryRatioIOSId INT
		, @intUnrealizedGainOnInventoryIOSId INT
		, @intUnrealizedLossOnInventoryIOSId INT
		, @strUnrealizedGainOnBasisId NVARCHAR(250)
		, @strUnrealizedGainOnFuturesId NVARCHAR(250)
		, @strUnrealizedGainOnCashId NVARCHAR(250)
		, @strUnrealizedLossOnBasisId NVARCHAR(250)
		, @strUnrealizedLossOnFuturesId NVARCHAR(250)
		, @strUnrealizedLossOnCashId NVARCHAR(250)
		, @strUnrealizedGainOnInventoryBasisIOSId NVARCHAR(250)
		, @strUnrealizedGainOnInventoryFuturesIOSId NVARCHAR(250)
		, @strUnrealizedGainOnInventoryCashIOSId NVARCHAR(250)
		, @strUnrealizedLossOnInventoryBasisIOSId NVARCHAR(250)
		, @strUnrealizedLossOnInventoryFuturesIOSId NVARCHAR(250)
		, @strUnrealizedLossOnInventoryCashIOSId NVARCHAR(250)
		, @strUnrealizedGainOnInventoryIntransitIOSId NVARCHAR(250)
		, @strUnrealizedLossOnInventoryIntransitIOSId NVARCHAR(250)
		, @strUnrealizedGainOnRatioId NVARCHAR(250)
		, @strUnrealizedLossOnRatioId NVARCHAR(250)
		, @strUnrealizedGainOnInventoryRatioIOSId NVARCHAR(250)
		, @strUnrealizedLossOnInventoryRatioIOSId NVARCHAR(250)
		, @strUnrealizedGainOnInventoryIOSId NVARCHAR(250)
		, @strUnrealizedLossOnInventoryIOSId NVARCHAR(250)


	INSERT INTO @GLAccounts
	EXEC uspRKGetGLAccountsForPosting @intCommodityId = @intCommodityId
		, @intLocationId = @intLocationId

	SELECT @intUnrealizedGainOnBasisId = intAccountId
		, @strUnrealizedGainOnBasisId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedGainOnBasisId'

	SELECT @intUnrealizedGainOnFuturesId = intAccountId
		, @strUnrealizedGainOnFuturesId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedGainOnFuturesId'

	SELECT @intUnrealizedGainOnCashId = intAccountId
		, @strUnrealizedGainOnCashId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedGainOnCashId'

	SELECT @intUnrealizedLossOnBasisId = intAccountId
		, @strUnrealizedLossOnBasisId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedLossOnBasisId'

	SELECT @intUnrealizedLossOnFuturesId = intAccountId
		, @strUnrealizedLossOnFuturesId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedLossOnFuturesId'

	SELECT @intUnrealizedLossOnCashId = intAccountId
		, @strUnrealizedLossOnCashId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedLossOnCashId'

	SELECT @intUnrealizedGainOnInventoryBasisIOSId = intAccountId
		, @strUnrealizedGainOnInventoryBasisIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedGainOnInventoryBasisIOSId'

	SELECT @intUnrealizedGainOnInventoryFuturesIOSId = intAccountId
		, @strUnrealizedGainOnInventoryFuturesIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedGainOnInventoryFuturesIOSId'

	SELECT @intUnrealizedGainOnInventoryCashIOSId = intAccountId
		, @strUnrealizedGainOnInventoryCashIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedGainOnInventoryCashIOSId'

	SELECT @intUnrealizedLossOnInventoryBasisIOSId = intAccountId
		, @strUnrealizedLossOnInventoryBasisIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedLossOnInventoryBasisIOSId'

	SELECT @intUnrealizedLossOnInventoryFuturesIOSId = intAccountId
		, @strUnrealizedLossOnInventoryFuturesIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedLossOnInventoryFuturesIOSId'

	SELECT @intUnrealizedLossOnInventoryCashIOSId = intAccountId
		, @strUnrealizedLossOnInventoryCashIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedLossOnInventoryCashIOSId'

	SELECT @intUnrealizedGainOnInventoryIntransitIOSId = intAccountId
		, @strUnrealizedGainOnInventoryIntransitIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedGainOnInventoryIntransitIOSId'

	SELECT @intUnrealizedLossOnInventoryIntransitIOSId = intAccountId
		, @strUnrealizedLossOnInventoryIntransitIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedLossOnInventoryIntransitIOSId'

	SELECT @intUnrealizedGainOnRatioId = intAccountId
		, @strUnrealizedGainOnRatioId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedGainOnRatioId'

	SELECT @intUnrealizedLossOnRatioId = intAccountId
		, @strUnrealizedLossOnRatioId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedLossOnRatioId'

	SELECT @intUnrealizedGainOnInventoryRatioIOSId = intAccountId
		, @strUnrealizedGainOnInventoryRatioIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedGainOnInventoryRatioIOSId'

	SELECT @intUnrealizedLossOnInventoryRatioIOSId = intAccountId
		, @strUnrealizedLossOnInventoryRatioIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedLossOnInventoryRatioIOSId'

	SELECT @intUnrealizedGainOnInventoryIOSId = intAccountId
		, @strUnrealizedGainOnInventoryIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedGainOnInventoryIOSId'

	SELECT @intUnrealizedLossOnInventoryIOSId = intAccountId
		, @strUnrealizedLossOnInventoryIOSId = CASE WHEN ysnHasError = 1 THEN strErrorMessage ELSE strAccountNo END
	FROM @GLAccounts
	WHERE strCategory = 'intUnrealizedLossOnInventoryIOSId'

	----Derivative unrealized start

	DECLARE @Result AS TABLE (intFutOptTransactionId INT
		, dblGrossPnL NUMERIC(24, 10)
		, dblLong NUMERIC(24, 10)
		, dblShort NUMERIC(24, 10)
		, dblFutCommission NUMERIC(24, 10)
		, strFutMarketName NVARCHAR(100)
		, strFutureMonth NVARCHAR(100)
		, dtmTradeDate DATETIME
		, strInternalTradeNo NVARCHAR(100)
		, strName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strBook NVARCHAR(100)
		, strSubBook NVARCHAR(100)
		, strSalespersonId NVARCHAR(100)
		, strCommodityCode NVARCHAR(100)
		, strLocationName NVARCHAR(100)
		, dblLong1 INT
		, dblSell1 INT
		, dblNet INT
		, dblActual NUMERIC(24, 10)
		, dblClosing NUMERIC(24, 10)
		, dblPrice NUMERIC(24, 10)
		, dblContractSize NUMERIC(24, 10)
		, dblFutCommission1 NUMERIC(24, 10)
		, dblMatchLong NUMERIC(24, 10)
		, dblMatchShort NUMERIC(24, 10)
		, dblNetPnL NUMERIC(24, 10)
		, intFutureMarketId INT
		, intFutureMonthId INT
		, intOriginalQty INT
		, intFutOptTransactionHeaderId INT
		, strMonthOrder NVARCHAR(100)
		, RowNum INT
		, intCommodityId INT
		, ysnExpired BIT
		, dblVariationMargin NUMERIC(24, 10)
		, dblInitialMargin NUMERIC(24, 10)
		, LongWaitedPrice NUMERIC(24, 10)
		, ShortWaitedPrice NUMERIC(24, 10)
		, intSelectedInstrumentTypeId INT)
	
	INSERT INTO @Result (RowNum
		, strMonthOrder
		, intFutOptTransactionId
		, dblGrossPnL
		, dblLong
		, dblShort
		, dblFutCommission
		, strFutMarketName
		, strFutureMonth
		, dtmTradeDate
		, strInternalTradeNo
		, strName
		, strAccountNumber
		, strBook
		, strSubBook
		, strSalespersonId
		, strCommodityCode
		, strLocationName
		, dblLong1
		, dblSell1
		, dblNet
		, dblActual
		, dblClosing
		, dblPrice
		, dblContractSize
		, dblFutCommission1
		, dblMatchLong
		, dblMatchShort
		, dblNetPnL
		, intFutureMarketId
		, intFutureMonthId
		, intOriginalQty
		, intFutOptTransactionHeaderId
		, intCommodityId
		, ysnExpired
		, dblVariationMargin
		, dblInitialMargin
		, LongWaitedPrice
		, ShortWaitedPrice
		, intSelectedInstrumentTypeId)
	EXEC uspRKUnrealizedPnL @dtmFromDate = '01-01-1900'
		, @dtmToDate = @Todate
		, @intCommodityId  = @intCommodityId
		, @ysnExpired =0
		, @intFutureMarketId  = NULL
		, @intEntityId  = NULL
		, @intBrokerageAccountId  = NULL
		, @intFutureMonthId  = NULL
		, @strBuySell  = NULL
		, @intBookId  = NULL
		, @intSubBookId  = NULL
	
	--------- end
	
	--Basis entry
	INSERT INTO tblRKM2MPostRecap (intM2MInquiryId
		, dtmDate
		, intAccountId
		, strAccountId
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
		, intEntityId
		, strReference
		, intUserId
		, intSourceLocationId
		, intSourceUOMId)
	SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN @intUnrealizedGainOnBasisId ELSE @intUnrealizedLossOnBasisId END intAccountId
		, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN @strUnrealizedGainOnBasisId ELSE @strUnrealizedLossOnBasisId END strAccountId
		, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblDebit
		, CASE WHEN ISNULL(dblResultBasis, 0) <= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
		, 'Mark To Market-Basis'
		, @intCurrencyId
		, @dtmGLPostDate
		, strContractSeq
		, intContractDetailId
		, 'Mark To Market-Basis'
		, 'Mark To Market'
		, 'Risk Management'
		, 1
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
	FROM tblRKM2MInquiryTransaction
	WHERE intM2MInquiryId = @intM2MInquiryId
		AND strContractOrInventoryType IN ('Contract(P)', 'Contract(S)')
		AND ISNULL(strPricingType, '') <> 'Cash'
		AND ISNULL(dblResultBasis, 0) <> 0
	
	--Basis entry Offset
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN @intUnrealizedGainOnInventoryBasisIOSId ELSE @intUnrealizedLossOnInventoryBasisIOSId END intAccountId
		, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN @strUnrealizedGainOnInventoryBasisIOSId ELSE @strUnrealizedLossOnInventoryBasisIOSId END strAccountId
		, CASE WHEN ISNULL(dblResultBasis, 0) <= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblDebit
		, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
		, 'Mark To Market-Basis Offset'
		, @intCurrencyId
		, @dtmGLPostDate
		, strContractSeq
		, intContractDetailId
		, 'Mark To Market-Basis Offset'
		, 'Mark To Market'
		, 'Risk Management'
		, 1
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
	FROM tblRKM2MInquiryTransaction
	WHERE intM2MInquiryId = @intM2MInquiryId
		AND strContractOrInventoryType IN ('Contract(P)', 'Contract(S)')
		AND ISNULL(strPricingType, '') <> 'Cash'
		AND ISNULL(dblResultBasis, 0) <> 0
		
	-- Futures
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		,  @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN @intUnrealizedGainOnFuturesId ELSE @intUnrealizedLossOnFuturesId END intAccountId
		, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN @strUnrealizedGainOnFuturesId ELSE @strUnrealizedLossOnFuturesId END strAccountId
		, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblDebit
		, CASE WHEN ISNULL(dblMarketFuturesResult, 0) <= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
		, 'Mark To Market-Futures'
		, @intCurrencyId
		, @dtmGLPostDate
		, strContractSeq
		, intContractDetailId
		, 'Mark To Market-Futures'
		, 'Mark To Market'
		, 'Risk Management'
		, 1
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
	FROM tblRKM2MInquiryTransaction
	WHERE intM2MInquiryId = @intM2MInquiryId
		AND strContractOrInventoryType IN ('Contract(P)', 'Contract(S)')
		AND ISNULL(strPricingType, '') <> 'Cash'
		AND ISNULL(dblMarketFuturesResult, 0) <> 0
	
	--Futures Offset
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN @intUnrealizedGainOnInventoryFuturesIOSId ELSE @intUnrealizedLossOnInventoryFuturesIOSId END intAccountId
		, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN @strUnrealizedGainOnInventoryFuturesIOSId ELSE @strUnrealizedLossOnInventoryFuturesIOSId END strAccountId
		, CASE WHEN ISNULL(dblMarketFuturesResult, 0) <= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblDebit
		, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
		, 'Mark To Market-Futures Offset'
		, @intCurrencyId
		, @dtmGLPostDate
		, strContractSeq
		, intContractDetailId
		, 'Mark To Market-Futures Offset'
		, 'Mark To Market'
		, 'Risk Management'
		, 1
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
	FROM tblRKM2MInquiryTransaction
	WHERE intM2MInquiryId = @intM2MInquiryId
		AND strContractOrInventoryType IN ('Contract(P)', 'Contract(S)')
		AND ISNULL(strPricingType, '') <> 'Cash'
		AND ISNULL(dblMarketFuturesResult, 0) <> 0

	--Cash
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @intUnrealizedGainOnCashId ELSE @intUnrealizedLossOnCashId END intAccountId
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @strUnrealizedGainOnCashId ELSE @strUnrealizedLossOnCashId END strAccountId
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
		, CASE WHEN ISNULL(dblResultCash, 0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
		, 'Mark To Market-Cash'
		, @intCurrencyId
		, @dtmGLPostDate
		, strContractSeq
		, intContractDetailId
		, 'Mark To Market-Cash'
		, 'Mark To Market'
		, 'Risk Management'
		, 1
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
	FROM tblRKM2MInquiryTransaction
	WHERE intM2MInquiryId = @intM2MInquiryId
		AND strContractOrInventoryType IN ('Contract(P)', 'Contract(S)')
		AND ISNULL(strPricingType, '') = 'Cash'
		AND ISNULL(dblResultCash, 0) <> 0
	
	--Cash Offset
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @intUnrealizedGainOnInventoryCashIOSId ELSE @intUnrealizedLossOnInventoryCashIOSId END intAccountId
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @strUnrealizedGainOnInventoryCashIOSId ELSE @strUnrealizedLossOnInventoryCashIOSId END strAccountId
		, CASE WHEN ISNULL(dblResultCash, 0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
		, 'Mark To Market-Cash Offset'
		, @intCurrencyId
		, @dtmGLPostDate
		, strContractSeq
		, intContractDetailId
		, 'Mark To Market-Cash Offset'
		, 'Mark To Market'
		, 'Risk Management'
		, 1
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
	FROM tblRKM2MInquiryTransaction
	WHERE intM2MInquiryId = @intM2MInquiryId
		AND strContractOrInventoryType IN ('Contract(P)', 'Contract(S)')
		AND ISNULL(strPricingType, '') = 'Cash'
		AND ISNULL(dblResultCash, 0) <> 0

	--Ratio
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultRatio, 0) >= 0 THEN @intUnrealizedGainOnRatioId ELSE @intUnrealizedLossOnRatioId END intAccountId
		, CASE WHEN ISNULL(dblResultRatio, 0) >= 0 THEN @strUnrealizedGainOnRatioId ELSE @strUnrealizedLossOnRatioId END strAccountId
		, CASE WHEN ISNULL(dblResultRatio, 0) >= 0 THEN 0.0 ELSE ABS(dblResultRatio) END dblDebit
		, CASE WHEN ISNULL(dblResultRatio, 0) <= 0 THEN 0.0 ELSE ABS(dblResultRatio) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
		, 'Mark To Market-Ratio'
		, @intCurrencyId
		, @dtmGLPostDate
		, strContractSeq
		, intContractDetailId
		, 'Mark To Market-Ratio'
		, 'Mark To Market'
		, 'Risk Management'
		, 1
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
	FROM tblRKM2MInquiryTransaction
	WHERE intM2MInquiryId = @intM2MInquiryId
		AND strContractOrInventoryType IN ('Contract(P)', 'Contract(S)')
		AND ISNULL(dblResultRatio, 0) <> 0
		
	--Ratio Offset
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultRatio, 0) >= 0 THEN @intUnrealizedGainOnInventoryRatioIOSId ELSE @intUnrealizedLossOnInventoryRatioIOSId END intAccountId
		, CASE WHEN ISNULL(dblResultRatio, 0) >= 0 THEN @strUnrealizedGainOnInventoryRatioIOSId ELSE @strUnrealizedLossOnInventoryRatioIOSId END strAccountId
		, CASE WHEN ISNULL(dblResultRatio, 0) <= 0 THEN 0.0 ELSE ABS(dblResultRatio) END dblDebit
		, CASE WHEN ISNULL(dblResultRatio, 0) >= 0 THEN 0.0 ELSE ABS(dblResultRatio) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
		, 'Mark To Market-Ratio Offset'
		, @intCurrencyId
		, @dtmGLPostDate
		, strContractSeq
		, intContractDetailId
		, 'Mark To Market-Ratio Offset'
		, 'Mark To Market'
		, 'Risk Management'
		, 1
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
	FROM tblRKM2MInquiryTransaction
	WHERE intM2MInquiryId = @intM2MInquiryId
		AND strContractOrInventoryType IN ('Contract(P)', 'Contract(S)')
		AND ISNULL(dblResultRatio, 0) <> 0
	
	-------- intransit Offset
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN @intUnrealizedGainOnInventoryBasisIOSId ELSE @intUnrealizedLossOnInventoryBasisIOSId END intAccountId
		, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN @strUnrealizedGainOnInventoryBasisIOSId ELSE @strUnrealizedLossOnInventoryBasisIOSId END strAccountId
		, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblDebit
		, CASE WHEN ISNULL(dblResultBasis, 0) <= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
		, 'Mark To Market-Basis Intransit'
		, @intCurrencyId
		, @dtmGLPostDate
		, strContractSeq
		, intContractDetailId
		, 'Mark To Market-Basis Intransit'
		, 'Mark To Market'
		, 'Risk Management'
		, 1
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
	FROM tblRKM2MInquiryTransaction
	WHERE intM2MInquiryId = @intM2MInquiryId
		AND strContractOrInventoryType IN ('In-transit(P)', 'In-transit(S)')
		AND ISNULL(strPricingType, '') <> 'Cash'
		AND ISNULL(dblResultBasis, 0) <> 0

	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN @intUnrealizedGainOnInventoryIntransitIOSId ELSE @intUnrealizedLossOnInventoryIntransitIOSId END intAccountId
		, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN @strUnrealizedGainOnInventoryBasisIOSId ELSE @strUnrealizedLossOnInventoryIntransitIOSId END strAccountId
		, CASE WHEN ISNULL(dblResultBasis, 0) <= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblDebit
		, CASE WHEN ISNULL(dblResultBasis, 0) >= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
		, 'Mark To Market-Basis Intransit Offset'
		, @intCurrencyId
		, @dtmGLPostDate
		, strContractSeq
		, intContractDetailId
		, 'Mark To Market-Basis Intransit Offset'
		, 'Mark To Market'
		, 'Risk Management'
		, 1
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
	FROM tblRKM2MInquiryTransaction
	WHERE intM2MInquiryId = @intM2MInquiryId
		AND strContractOrInventoryType IN ('In-transit(P)', 'In-transit(S)')
		AND ISNULL(strPricingType, '') <> 'Cash'
		AND ISNULL(dblResultBasis, 0) <> 0
	
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN @intUnrealizedGainOnFuturesId ELSE @intUnrealizedLossOnFuturesId END intAccountId
		, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN @strUnrealizedGainOnFuturesId ELSE @strUnrealizedLossOnFuturesId END strAccountId
		, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblDebit
		, CASE WHEN ISNULL(dblMarketFuturesResult, 0) <= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
		, 'Mark To Market-Futures Intransit'
		, @intCurrencyId
		, @dtmGLPostDate
		, strContractSeq
		, intContractDetailId
		, 'Mark To Market-Futures Intransit'
		, 'Mark To Market'
		, 'Risk Management'
		, 1
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
	FROM tblRKM2MInquiryTransaction WHERE intM2MInquiryId = @intM2MInquiryId
		AND strContractOrInventoryType IN ('In-transit(P)', 'In-transit(S)')
		AND ISNULL(strPricingType, '') <> 'Cash'
		AND ISNULL(dblMarketFuturesResult, 0) <> 0

	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN @intUnrealizedGainOnInventoryIntransitIOSId ELSE @intUnrealizedLossOnInventoryIntransitIOSId END intAccountId
		, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN @strUnrealizedGainOnInventoryBasisIOSId ELSE @strUnrealizedLossOnInventoryIntransitIOSId END strAccountId
		, CASE WHEN ISNULL(dblMarketFuturesResult, 0) <= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblDebit
		, CASE WHEN ISNULL(dblMarketFuturesResult, 0) >= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
		, 'Mark To Market-Futures Intransit Offset'
		, @intCurrencyId
		, @dtmGLPostDate
		, strContractSeq
		, intContractDetailId
		, 'Mark To Market-Futures Intransit Offset'
		, 'Mark To Market'
		, 'Risk Management'
		, 1
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
	FROM tblRKM2MInquiryTransaction
	WHERE intM2MInquiryId = @intM2MInquiryId
		AND strContractOrInventoryType IN ('In-transit(P)', 'In-transit(S)')
		AND ISNULL(strPricingType, '') <> 'Cash'
		AND ISNULL(dblMarketFuturesResult, 0) <> 0

	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @intUnrealizedGainOnCashId ELSE @intUnrealizedLossOnCashId END intAccountId
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @strUnrealizedGainOnCashId ELSE @strUnrealizedLossOnCashId END strAccountId
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
		, CASE WHEN ISNULL(dblResultCash, 0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
		, 'Mark To Market-Cash Intransit'
		, @intCurrencyId
		, @dtmGLPostDate
		, strContractSeq
		, intContractDetailId
		, 'Mark To Market-Cash Intransit'
		, 'Mark To Market'
		, 'Risk Management'
		, 1
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
	FROM tblRKM2MInquiryTransaction
	WHERE intM2MInquiryId = @intM2MInquiryId
		AND strContractOrInventoryType IN ('In-transit(P)', 'In-transit(S)')
		AND ISNULL(strPricingType, '') = 'Cash'
		AND ISNULL(dblResultCash, 0) <> 0
		
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @intUnrealizedGainOnInventoryIntransitIOSId ELSE @intUnrealizedLossOnInventoryIntransitIOSId END intAccountId
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @strUnrealizedGainOnInventoryIntransitIOSId ELSE @strUnrealizedLossOnInventoryIntransitIOSId END strAccountId
		, CASE WHEN ISNULL(dblResultCash, 0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
		, 'Mark To Market-Cash Intransit Offset'
		, @intCurrencyId
		, @dtmGLPostDate
		, strContractSeq
		, intContractDetailId
		, 'Mark To Market-Cash Intransit Offset'
		, 'Mark To Market'
		, 'Risk Management'
		, 1 
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
	FROM tblRKM2MInquiryTransaction
	WHERE intM2MInquiryId = @intM2MInquiryId
		AND strContractOrInventoryType IN ('In-transit(P)', 'In-transit(S)')
		AND ISNULL(strPricingType, '') = 'Cash'
		AND ISNULL(dblResultCash, 0) <> 0

	--Inventory Cash
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @intUnrealizedGainOnCashId ELSE @intUnrealizedLossOnCashId END intAccountId
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @strUnrealizedGainOnCashId ELSE @strUnrealizedLossOnCashId END strAccountId
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
		, CASE WHEN ISNULL(dblResultCash, 0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
		, 'Mark To Market-Cash Inventory'
		, @intCurrencyId
		, @dtmGLPostDate
		, strContractSeq = @strRecordName
		, intContractDetailId = @intM2MInquiryId
		, 'Mark To Market-Cash Inventory'
		, 'Mark To Market'
		, 'Risk Management'
		, 1
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
	FROM tblRKM2MInquiryTransaction
	WHERE intM2MInquiryId=@intM2MInquiryId
		AND strContractOrInventoryType IN ('Inventory','In-transit(I)')
		AND ISNULL(dblResultCash, 0) <> 0
	
	--Inventory Cash Offset	
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @intUnrealizedGainOnInventoryIOSId ELSE @intUnrealizedLossOnInventoryIOSId END intAccountId
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN @strUnrealizedGainOnInventoryIOSId ELSE @strUnrealizedLossOnInventoryIOSId END strAccountId
		, CASE WHEN ISNULL(dblResultCash, 0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
		, CASE WHEN ISNULL(dblResultCash, 0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty, 0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty, 0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
		, 'Mark To Market-Cash Inventory Offset'
		, @intCurrencyId
		, @dtmGLPostDate
		, strContractSeq = @strRecordName
		, intContractDetailId = @intM2MInquiryId
		, 'Mark To Market-Cash Inventory Offset'
		, 'Mark To Market'
		, 'Risk Management'
		, 1 
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
	FROM tblRKM2MInquiryTransaction
	WHERE intM2MInquiryId = @intM2MInquiryId
		AND strContractOrInventoryType IN ('Inventory','In-transit(I)')
		AND ISNULL(dblResultCash, 0) <> 0



	-- Derivative Transaction
	INSERT INTO tblRKM2MPostRecap (intM2MInquiryId
		, dtmDate
		, intAccountId
		, strAccountId
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
		, intEntityId
		, strReference
		, intUserId
		, intSourceLocationId
		, intSourceUOMId
		, dblPrice)
	SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblGrossPnL, 0) >= 0 THEN @intUnrealizedGainOnFuturesId ELSE @intUnrealizedLossOnFuturesId END intAccountId
		, CASE WHEN ISNULL(dblGrossPnL, 0) >= 0 THEN @strUnrealizedGainOnFuturesId ELSE @strUnrealizedLossOnFuturesId END strAccountId
		, CASE WHEN ISNULL(dblGrossPnL, 0) >= 0 THEN 0.0 ELSE ABS(dblGrossPnL) END dblDebit
		, CASE WHEN ISNULL(dblGrossPnL, 0) <= 0 THEN 0.0 ELSE ABS(dblGrossPnL) END dblCredit
		, CASE WHEN ISNULL(dblNetPnL, 0) >= 0 THEN 0.0 ELSE ABS(dblNetPnL) END dblDebitUnit
		, CASE WHEN ISNULL(dblNetPnL, 0) <= 0 THEN 0.0 ELSE ABS(dblNetPnL) END dblCreditUnit
		, 'Mark To Market-Futures Derivative'
		, @intCurrencyId
		, @dtmGLPostDate
		, t.strInternalTradeNo
		, t.intFutOptTransactionId
		, 'Mark To Market-Futures Derivative'
		, 'Mark To Market'
		, 'Risk Management'
		, 1
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
		, t.dblPrice
	FROM @Result t
	JOIN tblEMEntity e ON t.strName = e.strName
	WHERE ISNULL(dblGrossPnL, 0) <> 0
	
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblGrossPnL, 0) >= 0 THEN @intUnrealizedGainOnFuturesId ELSE @intUnrealizedLossOnFuturesId END intAccountId
		, CASE WHEN ISNULL(dblGrossPnL, 0) >= 0 THEN @strUnrealizedGainOnFuturesId ELSE @strUnrealizedLossOnFuturesId END strAccountId
		, CASE WHEN ISNULL(dblGrossPnL, 0) <= 0 THEN 0.0 ELSE ABS(dblGrossPnL) END dblDebit
		, CASE WHEN ISNULL(dblGrossPnL, 0) >= 0 THEN 0.0 ELSE ABS(dblGrossPnL) END dblCredit
		, CASE WHEN ISNULL(dblNetPnL, 0) <= 0 THEN 0.0 ELSE ABS(dblNetPnL) END dblDebitUnit
		, CASE WHEN ISNULL(dblNetPnL, 0) >= 0 THEN 0.0 ELSE ABS(dblNetPnL) END dblCreditUnit
		, 'Mark To Market-Futures Derivative Offset'
		, @intCurrencyId
		, @dtmGLPostDate
		, t.strInternalTradeNo
		, t.intFutOptTransactionId
		, 'Mark To Market-Futures Derivative Offset'
		, 'Mark To Market'
		, 'Risk Management'
		, 1
		, 1
		, GETDATE()
		, 0
		, intEntityId
		, @strRecordName strRecordName
		, @intUserId intUserId
		, @intLocationId intLocationId
		, @intUnitMeasureId intUnitMeasureId
		, t.dblPrice
	FROM @Result t
	JOIN tblEMEntity e on t.strName = e.strName
	WHERE ISNULL(dblGrossPnL, 0) <> 0
END