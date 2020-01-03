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
	DECLARE @intCommodityId INT
	DECLARE @Todate DATETIME
	DECLARE @intUnitMeasureId INT
	DECLARE @intLocationId INT
	DECLARE @strRateType NVARCHAR(50)
	SELECT @dtmGLPostDate = ISNULL(dtmGLPostDate, GETDATE())
		, @intCurrencyId = intCurrencyId
		, @intCommodityId = intCommodityId
		, @Todate = dtmTransactionUpTo
		, @strRecordName = strRecordName
		, @intLocationId = intCompanyLocationId
		, @intUnitMeasureId = intUnitMeasureId
		, @strRateType = strRateType
	FROM tblRKM2MInquiry WHERE intM2MInquiryId = @intM2MInquiryId


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


	IF (SELECT intPostToGLId FROM tblRKCompanyPreference) = 1
	BEGIN

		SELECT @intUnrealizedGainOnBasisId = intUnrealizedGainOnBasisId
			, @intUnrealizedGainOnFuturesId = intUnrealizedGainOnFuturesId
			, @intUnrealizedGainOnCashId = intUnrealizedGainOnCashId
			, @intUnrealizedLossOnBasisId = intUnrealizedLossOnBasisId
			, @intUnrealizedLossOnFuturesId = intUnrealizedLossOnFuturesId
			, @intUnrealizedLossOnCashId = intUnrealizedLossOnCashId
			, @intUnrealizedGainOnInventoryBasisIOSId = intUnrealizedGainOnInventoryBasisIOSId
			, @intUnrealizedGainOnInventoryFuturesIOSId = intUnrealizedGainOnInventoryFuturesIOSId
			, @intUnrealizedGainOnInventoryCashIOSId = intUnrealizedGainOnInventoryCashIOSId
			, @intUnrealizedLossOnInventoryBasisIOSId = intUnrealizedLossOnInventoryBasisIOSId
			, @intUnrealizedLossOnInventoryFuturesIOSId = intUnrealizedLossOnInventoryFuturesIOSId
 			, @intUnrealizedLossOnInventoryCashIOSId = intUnrealizedLossOnInventoryCashIOSId
			, @intUnrealizedGainOnInventoryIntransitIOSId= intUnrealizedGainOnInventoryIntransitIOSId
 			, @intUnrealizedLossOnInventoryIntransitIOSId = intUnrealizedLossOnInventoryIntransitIOSId
			, @intUnrealizedGainOnRatioId = intUnrealizedGainOnRatioId
			, @intUnrealizedLossOnRatioId = intUnrealizedLossOnRatioId
			, @intUnrealizedGainOnInventoryRatioIOSId = intUnrealizedGainOnInventoryRatioIOSId
			, @intUnrealizedLossOnInventoryRatioIOSId = intUnrealizedLossOnInventoryRatioIOSId 
			, @intUnrealizedGainOnInventoryIOSId = intUnrealizedGainOnInventoryIOSId
			, @intUnrealizedLossOnInventoryIOSId = intUnrealizedLossOnInventoryIOSId 
		FROM tblRKCompanyPreference
	
	END 
	ELSE
	BEGIN
		SELECT @intUnrealizedGainOnBasisId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Gain on Basis')
			, @intUnrealizedGainOnFuturesId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Gain on Futures')
			, @intUnrealizedGainOnCashId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Gain on Cash')
			, @intUnrealizedGainOnRatioId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Gain on Ratio')
			, @intUnrealizedLossOnBasisId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Loss on Basis')
			, @intUnrealizedLossOnFuturesId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Loss on Futures')
			, @intUnrealizedLossOnCashId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Loss on Cash')
			, @intUnrealizedLossOnRatioId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Loss on Ratio')
			, @intUnrealizedGainOnInventoryBasisIOSId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Gain on Basis (Inventory Offset)')
			, @intUnrealizedGainOnInventoryFuturesIOSId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Gain on Futures (Inventory Offset)')
			, @intUnrealizedGainOnInventoryCashIOSId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Gain on Cash (Inventory Offset)')
			, @intUnrealizedGainOnInventoryRatioIOSId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Gain on Ratio (Inventory Offset)')
			, @intUnrealizedGainOnInventoryIntransitIOSId= dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Gain on Intransit (Inventory Offset)')
			, @intUnrealizedGainOnInventoryIOSId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Gain on Inventory (Inventory Offset)')
			, @intUnrealizedLossOnInventoryBasisIOSId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Loss on Basis (Inventory Offset)')
			, @intUnrealizedLossOnInventoryFuturesIOSId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Loss on Futures (Inventory Offset)')
 			, @intUnrealizedLossOnInventoryCashIOSId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Loss on Cash (Inventory Offset)')
			, @intUnrealizedLossOnInventoryRatioIOSId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Loss on Ratio (Inventory Offset)') 
 			, @intUnrealizedLossOnInventoryIntransitIOSId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Loss on Intransit (Inventory Offset)')
			, @intUnrealizedLossOnInventoryIOSId = dbo.fnGetCommodityGLAccountM2M(DEFAULT,@intCommodityId,'Unrealized Loss on Inventory (Inventory Offset)') 
	END
	
	DECLARE @strUnrealizedGainOnBasisId NVARCHAR(50)
		, @strUnrealizedGainOnFuturesId NVARCHAR(50)
		, @strUnrealizedGainOnCashId NVARCHAR(50)
		, @strUnrealizedLossOnBasisId NVARCHAR(50)
		, @strUnrealizedLossOnFuturesId NVARCHAR(50)
		, @strUnrealizedLossOnCashId NVARCHAR(50)
		, @strUnrealizedGainOnInventoryBasisIOSId NVARCHAR(50)
		, @strUnrealizedGainOnInventoryFuturesIOSId NVARCHAR(50)
		, @strUnrealizedGainOnInventoryCashIOSId NVARCHAR(50)
		, @strUnrealizedLossOnInventoryBasisIOSId NVARCHAR(50)
		, @strUnrealizedLossOnInventoryFuturesIOSId NVARCHAR(50)
		, @strUnrealizedLossOnInventoryCashIOSId NVARCHAR(50)
		, @strUnrealizedGainOnInventoryIntransitIOSId NVARCHAR(50)
		, @strUnrealizedLossOnInventoryIntransitIOSId NVARCHAR(50)
		, @strUnrealizedGainOnRatioId NVARCHAR(50)
		, @strUnrealizedLossOnRatioId NVARCHAR(50)
		, @strUnrealizedGainOnInventoryRatioIOSId NVARCHAR(50)
		, @strUnrealizedLossOnInventoryRatioIOSId NVARCHAR(50)
		, @strUnrealizedGainOnInventoryIOSId NVARCHAR(50)
		, @strUnrealizedLossOnInventoryIOSId NVARCHAR(50)

	SELECT @strUnrealizedGainOnBasisId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedGainOnBasisId
	SELECT @strUnrealizedGainOnFuturesId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedGainOnFuturesId
	SELECT @strUnrealizedGainOnCashId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedGainOnCashId
	SELECT @strUnrealizedLossOnBasisId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedLossOnBasisId
	SELECT @strUnrealizedLossOnFuturesId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedLossOnFuturesId
	SELECT @strUnrealizedLossOnCashId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedLossOnCashId
	SELECT @strUnrealizedGainOnInventoryBasisIOSId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedGainOnInventoryBasisIOSId
	SELECT @strUnrealizedGainOnInventoryFuturesIOSId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedGainOnInventoryFuturesIOSId
	SELECT @strUnrealizedGainOnInventoryCashIOSId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedGainOnInventoryCashIOSId
	SELECT @strUnrealizedLossOnInventoryBasisIOSId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedLossOnInventoryBasisIOSId
	SELECT @strUnrealizedLossOnInventoryFuturesIOSId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedLossOnInventoryFuturesIOSId
	SELECT @strUnrealizedLossOnInventoryCashIOSId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedLossOnInventoryCashIOSId
	SELECT @strUnrealizedGainOnInventoryIntransitIOSId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedGainOnInventoryIntransitIOSId
	SELECT @strUnrealizedLossOnInventoryIntransitIOSId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedLossOnInventoryIntransitIOSId
	SELECT @strUnrealizedGainOnRatioId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedGainOnRatioId
	SELECT @strUnrealizedLossOnRatioId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedLossOnRatioId
	SELECT @strUnrealizedGainOnInventoryRatioIOSId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedGainOnInventoryRatioIOSId
	SELECT @strUnrealizedLossOnInventoryRatioIOSId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedLossOnInventoryRatioIOSId
	SELECT @strUnrealizedGainOnInventoryIOSId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedGainOnInventoryIOSId
	SELECT @strUnrealizedLossOnInventoryIOSId = strAccountId FROM tblGLAccount WHERE intAccountId = @intUnrealizedLossOnInventoryIOSId


	
	IF @strRateType = 'Stress Test' RETURN
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
		, CASE WHEN ISNULL(dblResultBasis,0) >= 0 THEN @intUnrealizedGainOnBasisId ELSE @intUnrealizedLossOnBasisId END intAccountId
		, CASE WHEN ISNULL(dblResultBasis,0) >= 0 THEN @strUnrealizedGainOnBasisId ELSE @strUnrealizedLossOnBasisId END strAccountId
		, CASE WHEN ISNULL(dblResultBasis,0) >= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblDebit
		, CASE WHEN ISNULL(dblResultBasis,0) <= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty,0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty,0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
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
		AND strContractOrInventoryType IN ('Contract(P)','Contract(S)')
		AND strPricingType <> 'Cash'
		AND ISNULL(dblResultBasis,0) <> 0
	
	--Basis entry Offset
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultBasis,0) >= 0 THEN @intUnrealizedGainOnInventoryBasisIOSId ELSE @intUnrealizedLossOnInventoryBasisIOSId END intAccountId
		, CASE WHEN ISNULL(dblResultBasis,0) >= 0 THEN @strUnrealizedGainOnInventoryBasisIOSId ELSE @strUnrealizedLossOnInventoryBasisIOSId END strAccountId
		, CASE WHEN ISNULL(dblResultBasis,0) <= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblDebit
		, CASE WHEN ISNULL(dblResultBasis,0) >= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty,0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty,0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
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
		AND strContractOrInventoryType IN ('Contract(P)','Contract(S)')
		AND strPricingType <> 'Cash' AND ISNULL(dblResultBasis,0) <> 0
		
	-- Futures
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		,  @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblMarketFuturesResult,0) >= 0 THEN @intUnrealizedGainOnFuturesId ELSE @intUnrealizedLossOnFuturesId END intAccountId
		, CASE WHEN ISNULL(dblMarketFuturesResult,0) >= 0 THEN @strUnrealizedGainOnFuturesId ELSE @strUnrealizedLossOnFuturesId END strAccountId
		, CASE WHEN ISNULL(dblMarketFuturesResult,0) >= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblDebit
		, CASE WHEN ISNULL(dblMarketFuturesResult,0) <= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty,0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty,0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
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
		AND strContractOrInventoryType IN ('Contract(P)','Contract(S)')
		AND strPricingType <> 'Cash' AND ISNULL(dblMarketFuturesResult,0) <> 0
	
	--Futures Offset
	UNION ALL
	SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblMarketFuturesResult,0) >= 0 THEN @intUnrealizedGainOnInventoryFuturesIOSId ELSE @intUnrealizedLossOnInventoryFuturesIOSId END intAccountId
		, CASE WHEN ISNULL(dblMarketFuturesResult,0) >= 0 THEN @strUnrealizedGainOnInventoryFuturesIOSId ELSE @strUnrealizedLossOnInventoryFuturesIOSId END strAccountId
		, CASE WHEN ISNULL(dblMarketFuturesResult,0) <= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblDebit
		, CASE WHEN ISNULL(dblMarketFuturesResult,0) >= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty,0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty,0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
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
	WHERE intM2MInquiryId=@intM2MInquiryId AND strContractOrInventoryType in('Contract(P)','Contract(S)')
		AND strPricingType <> 'Cash' AND ISNULL(dblMarketFuturesResult,0) <> 0

	--Cash
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN @intUnrealizedGainOnCashId ELSE @intUnrealizedLossOnCashId END intAccountId
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN @strUnrealizedGainOnCashId ELSE @strUnrealizedLossOnCashId END strAccountId
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
		, CASE WHEN ISNULL(dblResultCash,0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty,0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty,0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
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
	WHERE intM2MInquiryId = @intM2MInquiryId AND strContractOrInventoryType in('Contract(P)','Contract(S)') AND strPricingType = 'Cash' AND ISNULL(dblResultCash,0)<>0
	UNION ALL
	--Cash Offset
	SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN @intUnrealizedGainOnInventoryCashIOSId ELSE @intUnrealizedLossOnInventoryCashIOSId END intAccountId
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN @strUnrealizedGainOnInventoryCashIOSId ELSE @strUnrealizedLossOnInventoryCashIOSId END strAccountId
		, CASE WHEN ISNULL(dblResultCash,0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty,0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty,0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
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
	WHERE intM2MInquiryId = @intM2MInquiryId AND strContractOrInventoryType IN ('Contract(P)','Contract(S)')
		AND strPricingType = 'Cash' AND ISNULL(dblResultCash,0)<>0

	--Ratio
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultRatio,0) >= 0 THEN @intUnrealizedGainOnRatioId ELSE @intUnrealizedLossOnRatioId END intAccountId
		, CASE WHEN ISNULL(dblResultRatio,0) >= 0 THEN @strUnrealizedGainOnRatioId ELSE @strUnrealizedLossOnRatioId END strAccountId
		, CASE WHEN ISNULL(dblResultRatio,0) >= 0 THEN 0.0 ELSE ABS(dblResultRatio) END dblDebit
		, CASE WHEN ISNULL(dblResultRatio,0) <= 0 THEN 0.0 ELSE ABS(dblResultRatio) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty,0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty,0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
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
		AND strContractOrInventoryType in('Contract(P)','Contract(S)') AND ISNULL(dblResultRatio,0)<>0
		
	--Ratio Offset
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultRatio,0) >= 0 THEN @intUnrealizedGainOnInventoryRatioIOSId ELSE @intUnrealizedLossOnInventoryRatioIOSId END intAccountId
		, CASE WHEN ISNULL(dblResultRatio,0) >= 0 THEN @strUnrealizedGainOnInventoryRatioIOSId ELSE @strUnrealizedLossOnInventoryRatioIOSId END strAccountId
		, CASE WHEN ISNULL(dblResultRatio,0) <= 0 THEN 0.0 ELSE ABS(dblResultRatio) END dblDebit
		, CASE WHEN ISNULL(dblResultRatio,0) >= 0 THEN 0.0 ELSE ABS(dblResultRatio) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty,0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty,0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
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
	WHERE intM2MInquiryId = @intM2MInquiryId AND strContractOrInventoryType IN('Contract(P)','Contract(S)') AND ISNULL(dblResultRatio,0)<>0
	
	-------- intransit Offset
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultBasis,0) >= 0 THEN @intUnrealizedGainOnInventoryBasisIOSId ELSE @intUnrealizedLossOnInventoryBasisIOSId END intAccountId
		, CASE WHEN ISNULL(dblResultBasis,0) >= 0 THEN @strUnrealizedGainOnInventoryBasisIOSId ELSE @strUnrealizedLossOnInventoryBasisIOSId END strAccountId
		, CASE WHEN ISNULL(dblResultBasis,0) >= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblDebit
		, CASE WHEN ISNULL(dblResultBasis,0) <= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty,0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty,0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
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
	WHERE intM2MInquiryId = @intM2MInquiryId AND strContractOrInventoryType in ('In-transit(P)','In-transit(S)')
		and strPricingType <> 'Cash' AND ISNULL(dblResultBasis,0) <> 0

	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultBasis,0) >= 0 THEN @intUnrealizedGainOnInventoryIntransitIOSId ELSE @intUnrealizedLossOnInventoryIntransitIOSId END intAccountId
		, CASE WHEN ISNULL(dblResultBasis,0) >= 0 THEN @strUnrealizedGainOnInventoryBasisIOSId ELSE @strUnrealizedLossOnInventoryIntransitIOSId END strAccountId
		, CASE WHEN ISNULL(dblResultBasis,0) <= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblDebit
		, CASE WHEN ISNULL(dblResultBasis,0) >= 0 THEN 0.0 ELSE ABS(dblResultBasis) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty,0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty,0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
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
	WHERE intM2MInquiryId = @intM2MInquiryId AND strContractOrInventoryType in('In-transit(P)','In-transit(S)')
		and strPricingType <> 'Cash' AND ISNULL(dblResultBasis,0) <> 0
	
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblMarketFuturesResult,0) >= 0 THEN @intUnrealizedGainOnFuturesId ELSE @intUnrealizedLossOnFuturesId END intAccountId
		, CASE WHEN ISNULL(dblMarketFuturesResult,0) >= 0 THEN @strUnrealizedGainOnFuturesId ELSE @strUnrealizedLossOnFuturesId END strAccountId
		, CASE WHEN ISNULL(dblMarketFuturesResult,0) >= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblDebit
		, CASE WHEN ISNULL(dblMarketFuturesResult,0) <= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty,0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty,0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
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
	FROM tblRKM2MInquiryTransaction WHERE intM2MInquiryId=@intM2MInquiryId AND strContractOrInventoryType in('In-transit(P)','In-transit(S)')
		and strPricingType <> 'Cash' AND ISNULL(dblMarketFuturesResult,0) <> 0

	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblMarketFuturesResult,0) >= 0 THEN @intUnrealizedGainOnInventoryIntransitIOSId ELSE @intUnrealizedLossOnInventoryIntransitIOSId END intAccountId
		, CASE WHEN ISNULL(dblMarketFuturesResult,0) >= 0 THEN @strUnrealizedGainOnInventoryBasisIOSId ELSE @strUnrealizedLossOnInventoryIntransitIOSId END strAccountId
		, CASE WHEN ISNULL(dblMarketFuturesResult,0) <= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblDebit
		, CASE WHEN ISNULL(dblMarketFuturesResult,0) >= 0 THEN 0.0 ELSE ABS(dblMarketFuturesResult) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty,0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty,0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
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
	WHERE intM2MInquiryId=@intM2MInquiryId AND strContractOrInventoryType in('In-transit(P)','In-transit(S)')
		AND strPricingType <> 'Cash' AND ISNULL(dblMarketFuturesResult,0) <> 0

	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN @intUnrealizedGainOnCashId ELSE @intUnrealizedLossOnCashId END intAccountId
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN @strUnrealizedGainOnCashId ELSE @strUnrealizedLossOnCashId END strAccountId
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
		, CASE WHEN ISNULL(dblResultCash,0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty,0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty,0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
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
	WHERE intM2MInquiryId=@intM2MInquiryId AND strContractOrInventoryType in('In-transit(P)','In-transit(S)')
		AND strPricingType = 'Cash' AND ISNULL(dblResultCash,0) <> 0
		
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN @intUnrealizedGainOnInventoryIntransitIOSId ELSE @intUnrealizedLossOnInventoryIntransitIOSId END intAccountId
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN @strUnrealizedGainOnInventoryIntransitIOSId ELSE @strUnrealizedLossOnInventoryIntransitIOSId END strAccountId
		, CASE WHEN ISNULL(dblResultCash,0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty,0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty,0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
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
	WHERE intM2MInquiryId = @intM2MInquiryId AND strContractOrInventoryType in('In-transit(P)','In-transit(S)')
		AND strPricingType = 'Cash' AND ISNULL(dblResultCash,0) <> 0

	--Inventory Cash
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN @intUnrealizedGainOnCashId ELSE @intUnrealizedLossOnCashId END intAccountId
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN @strUnrealizedGainOnCashId ELSE @strUnrealizedLossOnCashId END strAccountId
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
		, CASE WHEN ISNULL(dblResultCash,0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty,0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty,0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
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
	WHERE intM2MInquiryId=@intM2MInquiryId AND strContractOrInventoryType in('Inventory','In-transit(I)')
		AND ISNULL(dblResultCash,0) <> 0
	
	--Inventory Cash Offset	
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN @intUnrealizedGainOnInventoryIOSId ELSE @intUnrealizedLossOnInventoryIOSId END intAccountId
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN @strUnrealizedGainOnInventoryIOSId ELSE @strUnrealizedLossOnInventoryIOSId END strAccountId
		, CASE WHEN ISNULL(dblResultCash,0) <= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblDebit
		, CASE WHEN ISNULL(dblResultCash,0) >= 0 THEN 0.0 ELSE ABS(dblResultCash) END dblCredit
		, CASE WHEN ISNULL(dblOpenQty,0) <= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblDebitUnit
		, CASE WHEN ISNULL(dblOpenQty,0) >= 0 THEN 0.0 ELSE ABS(dblOpenQty) END dblCreditUnit
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
	WHERE intM2MInquiryId = @intM2MInquiryId AND strContractOrInventoryType in('Inventory','In-transit(I)')
		AND ISNULL(dblResultCash,0) <> 0



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
		, CASE WHEN ISNULL(dblGrossPnL,0) >= 0 THEN @intUnrealizedGainOnFuturesId ELSE @intUnrealizedLossOnFuturesId END intAccountId
		, CASE WHEN ISNULL(dblGrossPnL,0) >= 0 THEN @strUnrealizedGainOnFuturesId ELSE @strUnrealizedLossOnFuturesId END strAccountId
		, CASE WHEN ISNULL(dblGrossPnL,0) >= 0 THEN 0.0 ELSE ABS(dblGrossPnL) END dblDebit
		, CASE WHEN ISNULL(dblGrossPnL,0) <= 0 THEN 0.0 ELSE ABS(dblGrossPnL) END dblCredit
		, CASE WHEN ISNULL(dblNetPnL,0) >= 0 THEN 0.0 ELSE ABS(dblNetPnL) END dblDebitUnit
		, CASE WHEN ISNULL(dblNetPnL,0) <= 0 THEN 0.0 ELSE ABS(dblNetPnL) END dblCreditUnit
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
	WHERE ISNULL(dblGrossPnL,0) <> 0
	
	UNION ALL SELECT @intM2MInquiryId intM2MInquiryId
		, @dtmGLPostDate AS dtmPostDate
		, CASE WHEN ISNULL(dblGrossPnL,0) >= 0 THEN @intUnrealizedGainOnFuturesId ELSE @intUnrealizedLossOnFuturesId END intAccountId
		, CASE WHEN ISNULL(dblGrossPnL,0) >= 0 THEN @strUnrealizedGainOnFuturesId ELSE @strUnrealizedLossOnFuturesId END strAccountId
		, CASE WHEN ISNULL(dblGrossPnL,0) <= 0 THEN 0.0 ELSE ABS(dblGrossPnL) END dblDebit
		, CASE WHEN ISNULL(dblGrossPnL,0) >= 0 THEN 0.0 ELSE ABS(dblGrossPnL) END dblCredit
		, CASE WHEN ISNULL(dblNetPnL,0) <= 0 THEN 0.0 ELSE ABS(dblNetPnL) END dblDebitUnit
		, CASE WHEN ISNULL(dblNetPnL,0) >= 0 THEN 0.0 ELSE ABS(dblNetPnL) END dblCreditUnit
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
	WHERE ISNULL(dblGrossPnL,0) <> 0

	--No need this if Post to GL Using Commodity GL
	IF (SELECT intPostToGLId FROM tblRKCompanyPreference) = 2
	BEGIN
		RETURN
	END
	--=====================================================================
	--		Update the proper GL Account for each transaction
	--		Set null if GL Account not exist
	--=====================================================================
	SELECT * INTO #tmpPostRecap
	FROM tblRKM2MPostRecap 
	WHERE intM2MInquiryId = @intM2MInquiryId

	DECLARE @tblResult TABLE (Result NVARCHAR(200))
	
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpPostRecap)
	BEGIN
		DECLARE @strTransactionId NVARCHAR(50)
			, @strContractNumber NVARCHAR(50)
			, @intContractSeq NVARCHAR(20)
			, @intTransactionId INT
			, @intUsedCommoidtyId INT
			, @intUseCompanyLocationId INT
			, @strCommodityCode NVARCHAR(100)
			, @intM2MTransactionId INT
			, @strTransactionType NVARCHAR(100)
			, @dblAmount NUMERIC(18,6)

		SELECT TOP 1 @intM2MTransactionId = intM2MTransactionId
			, @strTransactionId = strTransactionId
			, @intTransactionId = intTransactionId
			, @strTransactionType = strTransactionType
			, @dblAmount = (dblDebit + dblCredit)
		FROM #tmpPostRecap
		
		IF @strTransactionType = 'Mark To Market-Futures Derivative' OR @strTransactionType = 'Mark To Market-Futures Derivative Offset'
		BEGIN
			--Get the used Commodity AND Location in the Derivative Entry
			SELECT @intUsedCommoidtyId = DE.intCommodityId
				, @strCommodityCode = C.strCommodityCode
				, @intUseCompanyLocationId = DE.intLocationId
			FROM tblRKFutOptTransaction DE
			INNER JOIN tblICCommodity C ON DE.intCommodityId = C.intCommodityId
			WHERE strInternalTradeNo = @strTransactionId
		END
		ELSE
		BEGIN
			--Parse strTransactionId to get strContractNumber AND intContractSeq
			--Before dash(-) is the contract number after that is the contract sequence
			SET @strContractNumber = SUBSTRING(@strTransactionId,0,CHARINDEX('-',@strTransactionId))
			--SET @intContractSeq = SUBSTRING(@strTransactionId,CHARINDEX('-',@strTransactionId) + 1,LEN(@strTransactionId) - CHARINDEX('-',@strTransactionId)) 
			SET @intContractSeq = RIGHT(@strTransactionId , CHARINDEX ('-',REVERSE(@strTransactionId))-1)
		
			--Get the used Commodity AND Location in the Contract
			SELECT @intUsedCommoidtyId = H.intCommodityId
				, @strCommodityCode = C.strCommodityCode
				, @intUseCompanyLocationId = D.intCompanyLocationId 
			FROM tblCTContractHeader H
			INNER JOIN tblCTContractDetail D ON H.intContractHeaderId = D.intContractHeaderId
			INNER JOIN tblICCommodity C ON H.intCommodityId = C.intCommodityId
			WHERE D.intContractDetailId = @intTransactionId

		END
		
		DECLARE @strPrimaryAccountCode NVARCHAR(50)
			, @strLocationAccountCode NVARCHAR(50)
			, @strLOBAccountCode NVARCHAR(50)
			, @intAccountIdFromCompPref INT
			, @strAccountNumberToBeUse NVARCHAR(50)
			, @strErrorMessage NVARCHAR(200)

		SELECT @intAccountIdFromCompPref = (CASE WHEN @strTransactionType = 'Mark To Market-Basis' OR @strTransactionType = 'Mark To Market-Basis Intransit'
													THEN CASE WHEN ISNULL(@dblAmount,0) >= 0 THEN compPref.intUnrealizedGainOnBasisId ELSE compPref.intUnrealizedLossOnBasisId END
												 WHEN @strTransactionType = 'Mark To Market-Basis Offset' OR @strTransactionType = 'Mark To Market-Basis Intransit Offset'
													THEN CASE WHEN ISNULL(@dblAmount,0) >= 0 THEN compPref.intUnrealizedGainOnInventoryBasisIOSId ELSE compPref.intUnrealizedLossOnInventoryBasisIOSId END
												 WHEN @strTransactionType = 'Mark To Market-Futures Derivative' OR @strTransactionType = 'Mark To Market-Futures'  OR @strTransactionType = 'Mark To Market-Futures Intransit'
													THEN CASE WHEN ISNULL(@dblAmount,0) >= 0 THEN compPref.intUnrealizedGainOnFuturesId ELSE compPref.intUnrealizedLossOnFuturesId END
												 WHEN @strTransactionType = 'Mark To Market-Futures Derivative Offset' OR @strTransactionType = 'Mark To Market-Futures Offset' OR @strTransactionType = 'Mark To Market-Futures Intransit Offset'
													THEN CASE WHEN ISNULL(@dblAmount,0) >= 0 THEN compPref.intUnrealizedGainOnInventoryFuturesIOSId ELSE compPref.intUnrealizedLossOnInventoryFuturesIOSId END
												 WHEN @strTransactionType = 'Mark To Market-Cash' OR @strTransactionType = 'Mark To Market-Cash Intransit' OR @strTransactionType = 'Mark To Market-Cash Inventory'
													THEN CASE WHEN ISNULL(@dblAmount,0) >= 0 THEN compPref.intUnrealizedGainOnCashId ELSE compPref.intUnrealizedLossOnCashId END
												 WHEN @strTransactionType = 'Mark To Market-Cash Offset' OR @strTransactionType = 'Mark To Market-Futures Intransit Offset'
													THEN CASE WHEN ISNULL(@dblAmount,0) >= 0 THEN compPref.intUnrealizedGainOnInventoryCashIOSId ELSE compPref.intUnrealizedLossOnInventoryCashIOSId END
												 WHEN @strTransactionType = 'Mark To Market-Ratio'
													THEN CASE WHEN ISNULL(@dblAmount,0) >= 0 THEN compPref.intUnrealizedGainOnRatioId ELSE compPref.intUnrealizedLossOnRatioId END
												 WHEN @strTransactionType = 'Mark To Market-Ratio Offset'
													THEN CASE WHEN ISNULL(@dblAmount,0) >= 0 THEN compPref.intUnrealizedGainOnInventoryRatioIOSId ELSE compPref.intUnrealizedLossOnInventoryRatioIOSId END
												 WHEN @strTransactionType = 'Mark To Market-Cash Inventory Offset'
													THEN CASE WHEN ISNULL(@dblAmount,0) >= 0 THEN compPref.intUnrealizedGainOnInventoryIOSId ELSE compPref.intUnrealizedLossOnInventoryIOSId END
												 ELSE 0 END)
		FROM tblRKCompanyPreference compPref

		--Get the account code for Primary
		SET @strPrimaryAccountCode = ''
		SELECT @strPrimaryAccountCode = acct.[Primary Account]
		FROM vyuGLAccountView acct
		WHERE acct.intAccountId = @intAccountIdFromCompPref

		--Get the account code for Location
		SET @strLocationAccountCode = ''
		SELECT @strLocationAccountCode = acctSgmt.strCode
		FROM tblSMCompanyLocation compLoc
		LEFT OUTER JOIN tblGLAccountSegment acctSgmt ON compLoc.intProfitCenter = acctSgmt.intAccountSegmentId
		WHERE intCompanyLocationId = @intUseCompanyLocationId

		--If LOB is setup on GL Account Structure. intStructureType 5 is equal to Line of Bussiness on default data
		IF EXISTS (SELECT TOP 1 1 FROM tblGLAccountStructure WHERE intStructureType = 5)
		BEGIN
			--Get the account code for LOB
			SET @strLOBAccountCode = ''
			SELECT @strLOBAccountCode = acctSgmt.strCode
			FROM tblICCommodity com
			INNER JOIN tblSMLineOfBusiness lob ON com.intLineOfBusinessId = lob.intLineOfBusinessId
			LEFT OUTER JOIN tblGLAccountSegment acctSgmt ON lob.intSegmentCodeId = acctSgmt.intAccountSegmentId
			WHERE intCommodityId = @intUsedCommoidtyId

			--Build the account number with LOB
			SET @strAccountNumberToBeUse = ''

			IF ISNULL(@strPrimaryAccountCode,'') <> '' AND ISNULL(@strLocationAccountCode,'') <> '' AND ISNULL(@strLOBAccountCode,'') <> '' 
			BEGIN
				SET @strAccountNumberToBeUse =  @strPrimaryAccountCode +'-'+ @strLocationAccountCode +'-'+ @strLOBAccountCode
			END
		END 
		ELSE
		BEGIN
			--Build the account number without LOB
			SET @strAccountNumberToBeUse = ''

			IF ISNULL(@strPrimaryAccountCode,'') <> '' AND ISNULL(@strLocationAccountCode,'') <> ''
			BEGIN
				SET @strAccountNumberToBeUse =  @strPrimaryAccountCode +'-'+ @strLocationAccountCode
			END
		END

		--Check if GL Account Number exists. Set null of not exist.
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLAccount WHERE strAccountId = ISNULL(@strAccountNumberToBeUse,''))
		BEGIN
			UPDATE tblRKM2MPostRecap
			SET intAccountId = NULL
				, strAccountId = NULL
			WHERE intM2MTransactionId = @intM2MTransactionId
		END
		ELSE
		BEGIN
			DECLARE @intAccountIdToBeUse INT
			SELECT TOP 1 @intAccountIdToBeUse = intAccountId FROM tblGLAccount WHERE strAccountId = ISNULL(@strAccountNumberToBeUse,'')
		
			--Update the Post Recap table to the right GL Account
			UPDATE tblRKM2MPostRecap
			SET intAccountId = @intAccountIdToBeUse
				, strAccountId = @strAccountNumberToBeUse
			WHERE intM2MTransactionId = @intM2MTransactionId
		END	
		DELETE FROM #tmpPostRecap WHERE intM2MTransactionId = @intM2MTransactionId
	END

END