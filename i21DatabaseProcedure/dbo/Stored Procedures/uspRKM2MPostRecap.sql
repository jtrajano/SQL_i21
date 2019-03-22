 CREATE PROC [dbo].[uspRKM2MPostRecap] 
	@intM2MInquiryId INT,
	@intUserId int 
AS

DECLARE @intCurrencyId INT
DECLARE @strRecordName NVARCHAR(100)

if Exists(SELECT * FROM tblRKM2MPostRecap where intM2MInquiryId=@intM2MInquiryId)
RETURN

DECLARE @intUnrealizedGainOnBasisId INT
	,@intUnrealizedGainOnFuturesId INT
	,@intUnrealizedGainOnCashId INT
	,@intUnrealizedLossOnBasisId INT
	,@intUnrealizedLossOnFuturesId INT
	,@intUnrealizedLossOnCashId INT
	,@intUnrealizedGainOnInventoryBasisIOSId INT
	,@intUnrealizedGainOnInventoryFuturesIOSId INT
	,@intUnrealizedGainOnInventoryCashIOSId INT
	,@intUnrealizedLossOnInventoryBasisIOSId INT
	,@intUnrealizedLossOnInventoryFuturesIOSId INT
	,@intUnrealizedLossOnInventoryCashIOSId INT
	,@intUnrealizedGainOnInventoryIntransitIOSId INT
	,@intUnrealizedLossOnInventoryIntransitIOSId INT
	,@intUnrealizedGainOnRatioId INT
	,@intUnrealizedLossOnRatioId INT
	,@intUnrealizedGainOnInventoryRatioIOSId INT
	,@intUnrealizedLossOnInventoryRatioIOSId INT
SELECT @intUnrealizedGainOnBasisId = intUnrealizedGainOnBasisId
	,@intUnrealizedGainOnFuturesId = intUnrealizedGainOnFuturesId
	,@intUnrealizedGainOnCashId = intUnrealizedGainOnCashId
	,@intUnrealizedLossOnBasisId = intUnrealizedLossOnBasisId
	,@intUnrealizedLossOnFuturesId = intUnrealizedLossOnFuturesId
	,@intUnrealizedLossOnCashId = intUnrealizedLossOnCashId
	,@intUnrealizedGainOnInventoryBasisIOSId = intUnrealizedGainOnInventoryBasisIOSId
	,@intUnrealizedGainOnInventoryFuturesIOSId = intUnrealizedGainOnInventoryFuturesIOSId
	,@intUnrealizedGainOnInventoryCashIOSId = intUnrealizedGainOnInventoryCashIOSId
	,@intUnrealizedLossOnInventoryBasisIOSId = intUnrealizedLossOnInventoryBasisIOSId
	,@intUnrealizedLossOnInventoryFuturesIOSId = intUnrealizedLossOnInventoryFuturesIOSId
 	,@intUnrealizedLossOnInventoryCashIOSId = intUnrealizedLossOnInventoryCashIOSId
	,@intUnrealizedGainOnInventoryIntransitIOSId= intUnrealizedGainOnInventoryIntransitIOSId
 	,@intUnrealizedLossOnInventoryIntransitIOSId = intUnrealizedLossOnInventoryIntransitIOSId
	,@intUnrealizedGainOnRatioId = intUnrealizedGainOnRatioId
	,@intUnrealizedLossOnRatioId = intUnrealizedLossOnRatioId
	,@intUnrealizedGainOnInventoryRatioIOSId = intUnrealizedGainOnInventoryRatioIOSId
	,@intUnrealizedLossOnInventoryRatioIOSId = intUnrealizedLossOnInventoryRatioIOSId 
FROM tblRKCompanyPreference
declare @strUnrealizedGainOnBasisId NVARCHAR(MAX)
	,@strUnrealizedGainOnFuturesId NVARCHAR(MAX)
	,@strUnrealizedGainOnCashId NVARCHAR(MAX)
	,@strUnrealizedLossOnBasisId NVARCHAR(MAX)
	,@strUnrealizedLossOnFuturesId NVARCHAR(MAX)
	,@strUnrealizedLossOnCashId NVARCHAR(MAX)
	,@strUnrealizedGainOnInventoryBasisIOSId NVARCHAR(MAX)
	,@strUnrealizedGainOnInventoryFuturesIOSId NVARCHAR(MAX)
	,@strUnrealizedGainOnInventoryCashIOSId NVARCHAR(MAX)
	,@strUnrealizedLossOnInventoryBasisIOSId NVARCHAR(MAX)
	,@strUnrealizedLossOnInventoryFuturesIOSId NVARCHAR(MAX)
	,@strUnrealizedLossOnInventoryCashIOSId NVARCHAR(MAX)
	,@strUnrealizedGainOnInventoryIntransitIOSId NVARCHAR(MAX)
	,@strUnrealizedLossOnInventoryIntransitIOSId NVARCHAR(MAX)
	,@strUnrealizedGainOnRatioId NVARCHAR(MAX)
	,@strUnrealizedLossOnRatioId NVARCHAR(MAX)
	,@strUnrealizedGainOnInventoryRatioIOSId NVARCHAR(MAX)
	,@strUnrealizedLossOnInventoryRatioIOSId NVARCHAR(MAX)
SELECT @strUnrealizedGainOnBasisId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedGainOnBasisId
SELECT @strUnrealizedGainOnFuturesId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedGainOnCashId
select @strUnrealizedGainOnCashId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedGainOnCashId
select @strUnrealizedLossOnBasisId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedLossOnBasisId
select @strUnrealizedLossOnFuturesId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedLossOnFuturesId
select @strUnrealizedLossOnCashId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedLossOnCashId
select @strUnrealizedGainOnInventoryBasisIOSId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedGainOnInventoryBasisIOSId
select @strUnrealizedGainOnInventoryFuturesIOSId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedGainOnInventoryFuturesIOSId
select @strUnrealizedGainOnInventoryCashIOSId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedGainOnInventoryCashIOSId
select @strUnrealizedLossOnInventoryBasisIOSId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedLossOnInventoryBasisIOSId
select @strUnrealizedLossOnInventoryFuturesIOSId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedLossOnInventoryFuturesIOSId
select @strUnrealizedLossOnInventoryCashIOSId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedLossOnInventoryCashIOSId
select @strUnrealizedGainOnInventoryIntransitIOSId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedGainOnInventoryIntransitIOSId
select @strUnrealizedLossOnInventoryIntransitIOSId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedLossOnInventoryIntransitIOSId
select @strUnrealizedGainOnRatioId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedGainOnRatioId
select @strUnrealizedLossOnRatioId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedLossOnRatioId
select @strUnrealizedGainOnInventoryRatioIOSId=strAccountId from tblGLAccount where intAccountId=@intUnrealizedGainOnInventoryRatioIOSId
select @strUnrealizedLossOnInventoryRatioIOSId=strAccountId from tblGLAccount where intAccountId=@strUnrealizedLossOnInventoryRatioIOSId

DECLARE @dtmGLPostDate DATETIME
DECLARE @intCommodityId int
DECLARE @Todate datetime 
DECLARE @intUnitMeasureId int  
DECLARE @intLocationId int
declare @strRateType nvarchar(50)
SELECT @dtmGLPostDate=ISNULL(dtmGLPostDate,GETDATE()),@intCurrencyId=intCurrencyId,@intCommodityId=intCommodityId,@Todate = dtmTransactionUpTo ,@strRecordName=strRecordName
,@intLocationId=intCompanyLocationId,@intUnitMeasureId=intUnitMeasureId,@strRateType=strRateType
FROM tblRKM2MInquiry WHERE intM2MInquiryId=@intM2MInquiryId

if @strRateType='Stress Test' return
----Derivative unrealized start

DECLARE @Result AS TABLE (
	intFutOptTransactionId INT,
	dblGrossPnL NUMERIC(24, 10),
	dblLong NUMERIC(24, 10),
	dblShort NUMERIC(24, 10),
	dblFutCommission NUMERIC(24, 10),
	strFutMarketName NVARCHAR(100),
	strFutureMonth NVARCHAR(100),
	dtmTradeDate DATETIME,
	strInternalTradeNo NVARCHAR(100),
	strName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strBook NVARCHAR(100),
	strSubBook NVARCHAR(100),
	strSalespersonId NVARCHAR(100),
	strCommodityCode NVARCHAR(100),
	strLocationName NVARCHAR(100),
	dblLong1 INT,
	dblSell1 INT,
	dblNet INT,
	dblActual NUMERIC(24, 10),
	dblClosing NUMERIC(24, 10),
	dblPrice NUMERIC(24, 10),
	dblContractSize NUMERIC(24, 10),
	dblFutCommission1 NUMERIC(24, 10),
	dblMatchLong NUMERIC(24, 10),
	dblMatchShort NUMERIC(24, 10),
	dblNetPnL NUMERIC(24, 10),
	intFutureMarketId INT,
	intFutureMonthId INT,
	intOriginalQty INT,
	intFutOptTransactionHeaderId INT,
	strMonthOrder NVARCHAR(100),
	RowNum INT,
	intCommodityId INT,
	ysnExpired BIT,
	dblVariationMargin NUMERIC(24, 10),
	dblInitialMargin NUMERIC(24, 10),
	LongWaitedPrice NUMERIC(24, 10),
	ShortWaitedPrice NUMERIC(24, 10)
	)
	INSERT INTO @Result (
	RowNum,
	strMonthOrder,
	intFutOptTransactionId,
	dblGrossPnL,
	dblLong,
	dblShort,
	dblFutCommission,
	strFutMarketName,
	strFutureMonth,
	dtmTradeDate,
	strInternalTradeNo,
	strName,
	strAccountNumber,
	strBook,
	strSubBook,
	strSalespersonId,
	strCommodityCode,
	strLocationName,
	dblLong1,
	dblSell1,
	dblNet,
	dblActual,
	dblClosing,
	dblPrice,
	dblContractSize,
	dblFutCommission1,
	dblMatchLong,
	dblMatchShort,
	dblNetPnL,
	intFutureMarketId,
	intFutureMonthId,
	intOriginalQty,
	intFutOptTransactionHeaderId,
	intCommodityId,
	ysnExpired,
	dblVariationMargin,
	dblInitialMargin,
	LongWaitedPrice,
	ShortWaitedPrice
	)

exec uspRKUnrealizedPnL  @dtmFromDate ='01-01-1900',
		@dtmToDate = @Todate,
	@intCommodityId  = @intCommodityId,
	@ysnExpired =0,
	@intFutureMarketId  = NULL,
	@intEntityId  = NULL,
	@intBrokerageAccountId  = NULL,
	@intFutureMonthId  = NULL,
	@strBuySell  = NULL,
	@intBookId  = NULL,
	@intSubBookId  = NULL	
	
--------- end

--Basis entry
INSERT INTO tblRKM2MPostRecap (intM2MInquiryId,
	[dtmDate] ,[intAccountId] ,[strAccountId],[dblDebit],[dblCredit],[dblDebitUnit]  ,[dblCreditUnit]  ,[strDescription], [intCurrencyId]  ,[dtmTransactionDate],
	[strTransactionId]  ,[intTransactionId] ,[strTransactionType],[strTransactionForm],[strModuleName] ,[intConcurrencyId],[dblExchangeRate],[dtmDateEntered],
	[ysnIsUnposted],intEntityId,strReference,intUserId,[intSourceLocationId],[intSourceUOMId])
SELECT @intM2MInquiryId intM2MInquiryId, @dtmGLPostDate AS dtmPostDate,
CASE WHEN isnull(dblResultBasis,0) >= 0 then @intUnrealizedGainOnBasisId  else @intUnrealizedLossOnBasisId end intAccountId,
CASE WHEN isnull(dblResultBasis,0) >= 0 then @strUnrealizedGainOnBasisId  else @strUnrealizedLossOnBasisId end strAccountId,
CASE WHEN isnull(dblResultBasis,0) >= 0 then 0.0  else abs(dblResultBasis) end [dblDebit],
CASE WHEN isnull(dblResultBasis,0) <= 0 then 0.0  else abs(dblResultBasis) end [dblCredit],
CASE WHEN isnull(dblOpenQty,0) >= 0 then 0.0 else abs(dblOpenQty) end dblDebitUnit,
CASE WHEN isnull(dblOpenQty,0) <= 0 then 0.0 else abs(dblOpenQty) end [dblCreditUnit],
'Mark To Market-Basis',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Basis','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('Contract(P)','Contract(S)')
and strPricingType <> 'Cash' and isnull(dblResultBasis,0) <> 0
UNION ALL
--Basis entry Offset
SELECT @intM2MInquiryId intM2MInquiryId,@dtmGLPostDate AS dtmPostDate,
	CASE WHEN isnull(dblResultBasis,0) >= 0 then @intUnrealizedGainOnInventoryBasisIOSId  else @intUnrealizedLossOnInventoryBasisIOSId end intAccountId,
	CASE WHEN isnull(dblResultBasis,0) >= 0 then @strUnrealizedGainOnInventoryBasisIOSId  else @strUnrealizedLossOnInventoryBasisIOSId end strAccountId,
CASE WHEN isnull(dblResultBasis,0) <= 0 then 0.0  else abs(dblResultBasis) end [dblDebit],
CASE WHEN isnull(dblResultBasis,0) >= 0 then 0.0  else abs(dblResultBasis) end [dblCredit],
CASE WHEN isnull(dblOpenQty,0) <= 0 then 0.0 else abs(dblOpenQty) end dblDebitUnit,
CASE WHEN isnull(dblOpenQty,0) >= 0 then 0.0 else abs(dblOpenQty) end [dblCreditUnit],
'Mark To Market-Basis Offset',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Basis Offset','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('Contract(P)','Contract(S)')
and strPricingType <> 'Cash' and isnull(dblResultBasis,0) <> 0
-- Futures
UNION ALL
SELECT @intM2MInquiryId intM2MInquiryId, @dtmGLPostDate AS dtmPostDate,
CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then @intUnrealizedGainOnFuturesId else @intUnrealizedLossOnFuturesId end intAccountId,
CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then @strUnrealizedGainOnFuturesId else @strUnrealizedLossOnFuturesId end strAccountId,
CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then 0.0  else abs(dblMarketFuturesResult) end [dblDebit],
CASE WHEN isnull(dblMarketFuturesResult,0) <= 0 then 0.0  else abs(dblMarketFuturesResult) end [dblCredit],
CASE WHEN isnull(dblOpenQty,0) >= 0 then 0.0 else abs(dblOpenQty) end dblDebitUnit,
CASE WHEN isnull(dblOpenQty,0) <= 0 then 0.0 else abs(dblOpenQty) end [dblCreditUnit],
'Mark To Market-Futures',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Futures','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('Contract(P)','Contract(S)')
and strPricingType <> 'Cash' and isnull(dblMarketFuturesResult,0) <> 0
UNION ALL
--Futures Offset
SELECT @intM2MInquiryId intM2MInquiryId,@dtmGLPostDate AS dtmPostDate,
	CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then @intUnrealizedGainOnInventoryFuturesIOSId else @intUnrealizedLossOnInventoryFuturesIOSId end intAccountId,
	CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then @strUnrealizedGainOnInventoryFuturesIOSId else @strUnrealizedLossOnInventoryFuturesIOSId end strAccountId
,CASE WHEN isnull(dblMarketFuturesResult,0) <= 0 then 0.0  else abs(dblMarketFuturesResult) end [dblDebit],
CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then 0.0  else abs(dblMarketFuturesResult) end [dblCredit],
CASE WHEN isnull(dblOpenQty,0) <= 0 then 0.0 else abs(dblOpenQty) end dblDebitUnit,
CASE WHEN isnull(dblOpenQty,0) >= 0 then 0.0 else abs(dblOpenQty) end [dblCreditUnit],
'Mark To Market-Futures Offset',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Futures Offset','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('Contract(P)','Contract(S)')
	and strPricingType <> 'Cash' and isnull(dblMarketFuturesResult,0) <> 0
--Cash
UNION ALL
SELECT @intM2MInquiryId intM2MInquiryId, @dtmGLPostDate AS dtmPostDate,
CASE WHEN isnull(dblResultCash,0) >= 0 then @intUnrealizedGainOnCashId else @intUnrealizedLossOnCashId end intAccountId,
CASE WHEN isnull(dblResultCash,0) >= 0 then @strUnrealizedGainOnCashId else @strUnrealizedLossOnCashId end strAccountId
,CASE WHEN isnull(dblResultCash,0) >= 0 then 0.0  else abs(dblResultCash) end [dblDebit],
CASE WHEN isnull(dblResultCash,0) <= 0 then 0.0  else abs(dblResultCash) end [dblCredit],
CASE WHEN isnull(dblOpenQty,0) >= 0 then 0.0 else abs(dblOpenQty) end dblDebitUnit,
CASE WHEN isnull(dblOpenQty,0) <= 0 then 0.0 else abs(dblOpenQty) end [dblCreditUnit],
'Mark To Market-Cash',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Cash','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction 
where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('Contract(P)','Contract(S)') and strPricingType = 'Cash' and isnull(dblResultCash,0)<>0
UNION ALL
--Cash Offset
SELECT @intM2MInquiryId intM2MInquiryId,@dtmGLPostDate AS dtmPostDate,
	CASE WHEN isnull(dblResultCash,0) >= 0 then @intUnrealizedGainOnInventoryCashIOSId else @intUnrealizedLossOnInventoryCashIOSId end intAccountId,
	CASE WHEN isnull(dblResultCash,0) >= 0 then @strUnrealizedGainOnInventoryCashIOSId else @strUnrealizedLossOnInventoryCashIOSId end strAccountId
,CASE WHEN isnull(dblResultCash,0) <= 0 then 0.0  else abs(dblResultCash) end [dblDebit],
CASE WHEN isnull(dblResultCash,0) >= 0 then 0.0  else abs(dblResultCash) end [dblCredit],
CASE WHEN isnull(dblOpenQty,0) <= 0 then 0.0 else abs(dblOpenQty) end dblDebitUnit,
CASE WHEN isnull(dblOpenQty,0) >= 0 then 0.0 else abs(dblOpenQty) end [dblCreditUnit],
'Mark To Market-Cash Offset',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Cash Offset','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('Contract(P)','Contract(S)')
	and strPricingType = 'Cash' and isnull(dblResultCash,0)<>0

--Ratio
UNION ALL
SELECT @intM2MInquiryId intM2MInquiryId, @dtmGLPostDate AS dtmPostDate,
CASE WHEN isnull(dblResultRatio,0) >= 0 then @intUnrealizedGainOnRatioId else @intUnrealizedLossOnRatioId end intAccountId,
CASE WHEN isnull(dblResultRatio,0) >= 0 then @strUnrealizedGainOnRatioId else @strUnrealizedLossOnRatioId end strAccountId
,CASE WHEN isnull(dblResultRatio,0) >= 0 then 0.0 else abs(dblResultRatio) end [dblDebit],
CASE WHEN isnull(dblResultRatio,0) <= 0 then 0.0 else abs(dblResultRatio) end [dblCredit],
CASE WHEN isnull(dblOpenQty,0) >= 0 then 0.0 else abs(dblOpenQty) end dblDebitUnit,
CASE WHEN isnull(dblOpenQty,0) <= 0 then 0.0 else abs(dblOpenQty) end [dblCreditUnit]
,'Mark To Market-Ratio',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Ratio','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction 
where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('Contract(P)','Contract(S)') and isnull(dblResultRatio,0)<>0

--Ratio Offset
UNION ALL
SELECT @intM2MInquiryId intM2MInquiryId, @dtmGLPostDate AS dtmPostDate,
CASE WHEN isnull(dblResultRatio,0) >= 0 then @intUnrealizedGainOnInventoryRatioIOSId else @intUnrealizedLossOnInventoryRatioIOSId end intAccountId,
CASE WHEN isnull(dblResultRatio,0) >= 0 then @strUnrealizedGainOnInventoryRatioIOSId else @strUnrealizedLossOnInventoryRatioIOSId end strAccountId
,CASE WHEN isnull(dblResultRatio,0) <= 0 then 0.0 else abs(dblResultRatio) end [dblDebit],
CASE WHEN isnull(dblResultRatio,0) >= 0 then 0.0 else abs(dblResultRatio) end [dblCredit],
CASE WHEN isnull(dblOpenQty,0) <= 0 then 0.0 else abs(dblOpenQty) end dblDebitUnit,
CASE WHEN isnull(dblOpenQty,0) >= 0 then 0.0 else abs(dblOpenQty) end [dblCreditUnit],
'Mark To Market-Ratio Offset',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Ratio Offset','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction 
where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('Contract(P)','Contract(S)') and isnull(dblResultRatio,0)<>0


-------- intransit Offset
UNION ALL
SELECT @intM2MInquiryId intM2MInquiryId,@dtmGLPostDate AS dtmPostDate,
	CASE WHEN isnull(dblResultBasis,0) >= 0 then @intUnrealizedGainOnInventoryBasisIOSId  else @intUnrealizedLossOnInventoryBasisIOSId end intAccountId,
	CASE WHEN isnull(dblResultBasis,0) >= 0 then @strUnrealizedGainOnInventoryBasisIOSId  else @strUnrealizedLossOnInventoryBasisIOSId end strAccountId
,CASE WHEN isnull(dblResultBasis,0) >= 0 then 0.0  else abs(dblResultBasis) end [dblDebit],
CASE WHEN isnull(dblResultBasis,0) <= 0 then 0.0  else abs(dblResultBasis) end [dblCredit],
CASE WHEN isnull(dblOpenQty,0) >= 0 then 0.0 else abs(dblOpenQty) end dblDebitUnit,
CASE WHEN isnull(dblOpenQty,0) <= 0 then 0.0 else abs(dblOpenQty) end [dblCreditUnit],
'Mark To Market-Basis Intransit',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Basis Intransit','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('In-transit(P)','In-transit(S)')
and strPricingType <> 'Cash'  and isnull(dblResultBasis,0) <> 0
UNION ALL
SELECT @intM2MInquiryId intM2MInquiryId,@dtmGLPostDate AS dtmPostDate,
	CASE WHEN isnull(dblResultBasis,0) >= 0 then @intUnrealizedGainOnInventoryIntransitIOSId  else @intUnrealizedLossOnInventoryIntransitIOSId end intAccountId,
	CASE WHEN isnull(dblResultBasis,0) >= 0 then @strUnrealizedGainOnInventoryBasisIOSId  else @strUnrealizedLossOnInventoryIntransitIOSId end strAccountId
,CASE WHEN isnull(dblResultBasis,0) <= 0 then 0.0  else abs(dblResultBasis) end [dblDebit],
CASE WHEN isnull(dblResultBasis,0) >= 0 then 0.0  else abs(dblResultBasis) end [dblCredit],
CASE WHEN isnull(dblOpenQty,0) <= 0 then 0.0 else abs(dblOpenQty) end dblDebitUnit,
CASE WHEN isnull(dblOpenQty,0) >= 0 then 0.0 else abs(dblOpenQty) end [dblCreditUnit],
'Mark To Market-Basis Intransit Offset',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Basis Intransit Offset','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('In-transit(P)','In-transit(S)')
and strPricingType <> 'Cash'  and isnull(dblResultBasis,0) <> 0


UNION ALL
SELECT @intM2MInquiryId intM2MInquiryId, @dtmGLPostDate AS dtmPostDate,
CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then @intUnrealizedGainOnFuturesId else @intUnrealizedLossOnFuturesId end intAccountId,
CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then @strUnrealizedGainOnFuturesId else @strUnrealizedLossOnFuturesId end strAccountId
,CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then 0.0  else abs(dblMarketFuturesResult) end [dblDebit],
CASE WHEN isnull(dblMarketFuturesResult,0) <= 0 then 0.0  else abs(dblMarketFuturesResult) end [dblCredit],
CASE WHEN isnull(dblOpenQty,0) >= 0 then 0.0 else abs(dblOpenQty) end dblDebitUnit,
CASE WHEN isnull(dblOpenQty,0) <= 0 then 0.0 else abs(dblOpenQty) end [dblCreditUnit],
'Mark To Market-Futures Intransit',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Futures Intransit','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('In-transit(P)','In-transit(S)')
and strPricingType <> 'Cash'  and isnull(dblMarketFuturesResult,0) <> 0

UNION ALL
SELECT @intM2MInquiryId intM2MInquiryId,@dtmGLPostDate AS dtmPostDate,
	CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then @intUnrealizedGainOnInventoryIntransitIOSId  else @intUnrealizedLossOnInventoryIntransitIOSId end intAccountId,
	CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then @strUnrealizedGainOnInventoryBasisIOSId  else @strUnrealizedLossOnInventoryIntransitIOSId end strAccountId
,CASE WHEN isnull(dblMarketFuturesResult,0) <= 0 then 0.0  else abs(dblMarketFuturesResult) end [dblDebit],
CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then 0.0  else abs(dblMarketFuturesResult) end [dblCredit],
CASE WHEN isnull(dblOpenQty,0) <= 0 then 0.0 else abs(dblOpenQty) end dblDebitUnit,
CASE WHEN isnull(dblOpenQty,0) >= 0 then 0.0 else abs(dblOpenQty) end [dblCreditUnit],
'Mark To Market-Futures Intransit Offset',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Futures Intransit Offset','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('In-transit(P)','In-transit(S)')
and strPricingType <> 'Cash'  and isnull(dblMarketFuturesResult,0) <> 0

UNION ALL

SELECT @intM2MInquiryId intM2MInquiryId, @dtmGLPostDate AS dtmPostDate,
	   CASE WHEN isnull(dblResultCash,0) >= 0 then @intUnrealizedGainOnCashId else @intUnrealizedLossOnCashId end intAccountId,
	   CASE WHEN isnull(dblResultCash,0) >= 0 then @strUnrealizedGainOnCashId else @strUnrealizedLossOnCashId end strAccountId
,CASE WHEN isnull(dblResultCash,0) >= 0 then 0.0  else abs(dblResultCash) end [dblDebit],
CASE WHEN isnull(dblResultCash,0) <= 0 then 0.0  else abs(dblResultCash) end [dblCredit],
CASE WHEN isnull(dblOpenQty,0) >= 0 then 0.0 else abs(dblOpenQty) end dblDebitUnit,
CASE WHEN isnull(dblOpenQty,0) <= 0 then 0.0 else abs(dblOpenQty) end [dblCreditUnit],
'Mark To Market-Cash Intransit',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Cash Intransit','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('In-transit(P)','In-transit(S)')
and strPricingType = 'Cash' and isnull(dblResultCash,0) <> 0
Union ALL

SELECT @intM2MInquiryId intM2MInquiryId,@dtmGLPostDate AS dtmPostDate,
	CASE WHEN isnull(dblResultCash,0) >= 0 then @intUnrealizedGainOnInventoryIntransitIOSId  else @intUnrealizedLossOnInventoryIntransitIOSId end intAccountId,
	CASE WHEN isnull(dblResultCash,0) >= 0 then @strUnrealizedGainOnInventoryBasisIOSId  else @strUnrealizedLossOnInventoryIntransitIOSId end strAccountId
,CASE WHEN isnull(dblResultCash,0) <= 0 then 0.0  else abs(dblResultCash) end [dblDebit],
CASE WHEN isnull(dblResultCash,0) >= 0 then 0.0  else abs(dblResultCash) end [dblCredit],
CASE WHEN isnull(dblOpenQty,0) <= 0 then 0.0 else abs(dblOpenQty) end dblDebitUnit,
CASE WHEN isnull(dblOpenQty,0) >= 0 then 0.0 else abs(dblOpenQty) end [dblCreditUnit],
'Mark To Market-Futures Intransit Offset',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Futures Intransit Offset','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('In-transit(P)','In-transit(S)')
and strPricingType = 'Cash'  and isnull(dblResultCash,0) <> 0

-- Derivative Transaction
INSERT INTO tblRKM2MPostRecap (intM2MInquiryId,
	[dtmDate] ,[intAccountId] ,[strAccountId],[dblDebit],[dblCredit],[dblDebitUnit]  ,[dblCreditUnit]  ,[strDescription], [intCurrencyId]  ,[dtmTransactionDate],
	[strTransactionId]  ,[intTransactionId] ,[strTransactionType],[strTransactionForm],[strModuleName] ,[intConcurrencyId],[dblExchangeRate],[dtmDateEntered],
	[ysnIsUnposted],intEntityId,strReference,intUserId,[intSourceLocationId],[intSourceUOMId],dblPrice)

SELECT @intM2MInquiryId intM2MInquiryId, @dtmGLPostDate AS dtmPostDate,
CASE WHEN isnull(dblGrossPnL,0) >= 0 then @intUnrealizedGainOnFuturesId else @intUnrealizedLossOnFuturesId end intAccountId,
CASE WHEN isnull(dblGrossPnL,0) >= 0 then @strUnrealizedGainOnFuturesId else @strUnrealizedLossOnFuturesId end strAccountId
,CASE WHEN isnull(dblGrossPnL,0) >= 0 then 0.0  else abs(dblGrossPnL) end [dblDebit],
CASE WHEN isnull(dblGrossPnL,0) <= 0 then 0.0  else abs(dblGrossPnL) end [dblCredit],
CASE WHEN isnull(dblNetPnL,0) >= 0 then 0.0 else abs(dblNetPnL) end dblDebitUnit,
CASE WHEN isnull(dblNetPnL,0) <= 0 then 0.0  else abs(dblNetPnL) end [dblCreditUnit],
'Mark To Market-Futures Derivative',@intCurrencyId,@dtmGLPostDate,t.strInternalTradeNo,t.intFutOptTransactionId,
		'Mark To Market-Futures Derivative','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,
		@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId,t.dblPrice
FROM @Result t
join tblEMEntity e on t.strName=e.strName
--join tblRKFutOptTransaction tr on tr.intFutOptTransactionId=t.intFutOptTransactionId
WHERE ISNULL(dblGrossPnL,0) <> 0

UNION ALL

SELECT @intM2MInquiryId intM2MInquiryId,@dtmGLPostDate AS dtmPostDate,
	CASE WHEN isnull(dblGrossPnL,0) >= 0 then @intUnrealizedGainOnFuturesId else @intUnrealizedLossOnFuturesId end intAccountId,
	CASE WHEN isnull(dblGrossPnL,0) >= 0 then @strUnrealizedGainOnFuturesId else @strUnrealizedLossOnFuturesId end strAccountId
,CASE WHEN isnull(dblGrossPnL,0) <= 0 then 0.0  else abs(dblGrossPnL) end [dblDebit],
CASE WHEN isnull(dblGrossPnL,0) >= 0 then 0.0  else abs(dblGrossPnL) end [dblCredit],
CASE WHEN isnull(dblNetPnL,0) <= 0 then 0.0  else abs(dblNetPnL) end dblDebitUnit,
CASE WHEN isnull(dblNetPnL,0) >= 0 then 0.0  else abs(dblNetPnL) end [dblCreditUnit],
'Mark To Market-Futures Derivative Offset',@intCurrencyId,@dtmGLPostDate,t.strInternalTradeNo,t.intFutOptTransactionId,
'Mark To Market-Futures Derivative Offset','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,
@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId,t.dblPrice
FROM @Result t
join tblEMEntity e on t.strName=e.strName
--JOIN tblRKFutOptTransaction tr on tr.intFutOptTransactionId=t.intFutOptTransactionId
WHERE ISNULL(dblGrossPnL,0) <> 0

--=====================================================================
--		Update the proper GL Account for each transaction
--		Set null if GL Account not exist
--=====================================================================
SELECT * INTO #tmpPostRecap
FROM tblRKM2MPostRecap 
WHERE intM2MInquiryId = @intM2MInquiryId

DECLARE @tblResult  TABLE (
	Result nvarchar(200)
)


WHILE EXISTS (SELECT TOP 1 1 FROM #tmpPostRecap)
BEGIN

	DECLARE @strTransactionId NVARCHAR(50)
			,@strContractNumber NVARCHAR(50)
			,@intContractSeq NVARCHAR(20)
			,@intUsedCommoidtyId INT
			,@intUseCompanyLocationId INT
			,@strCommodityCode NVARCHAR(100)
			,@intM2MTransactionId INT
			,@strTransactionType NVARCHAR(100)
			,@dblAmount NUMERIC(18,6)

	SELECT TOP 1 
		@intM2MTransactionId = intM2MTransactionId
		,@strTransactionId = strTransactionId
		,@strTransactionType = strTransactionType
		,@dblAmount = (dblDebit + dblCredit)
	FROM #tmpPostRecap

	
	IF @strTransactionType = 'Mark To Market-Futures Derivative' OR @strTransactionType = 'Mark To Market-Futures Derivative Offset'
	BEGIN

		--Get the used Commodity and Location in the Derivative Entry
		SELECT 
			@intUsedCommoidtyId = DE.intCommodityId
			,@strCommodityCode = C.strCommodityCode
			,@intUseCompanyLocationId = DE.intLocationId 
		FROM tblRKFutOptTransaction  DE
			INNER JOIN tblICCommodity C ON DE.intCommodityId = C.intCommodityId
		WHERE strInternalTradeNo = @strTransactionId

	END
	ELSE
	BEGIN

		--Parse strTransactionId to get strContractNumber and intContractSeq
		--Before dash(-) is the contract number after that is the contract sequence
		SET @strContractNumber = SUBSTRING(@strTransactionId,0,CHARINDEX('-',@strTransactionId))
		--SET @intContractSeq = SUBSTRING(@strTransactionId,CHARINDEX('-',@strTransactionId) + 1,LEN(@strTransactionId) - CHARINDEX('-',@strTransactionId)) 
		SET @intContractSeq = RIGHT(@strTransactionId , CHARINDEX ('-',REVERSE(@strTransactionId))-1)
		
		--Get the used Commodity and Location in the Contract
		SELECT 
			@intUsedCommoidtyId = H.intCommodityId
			,@strCommodityCode = C.strCommodityCode
			,@intUseCompanyLocationId = D.intCompanyLocationId 
		FROM tblCTContractHeader  H
			INNER JOIN tblCTContractDetail D ON H.intContractHeaderId = D.intContractHeaderId
			INNER JOIN tblICCommodity C ON H.intCommodityId = C.intCommodityId
		WHERE 
			H.strContractNumber = @strContractNumber 
			AND D.intContractSeq = @intContractSeq

	END

	DECLARE @strPrimaryAccountCode NVARCHAR(50)
			,@strLocationAccountCode NVARCHAR(50)
			,@strLOBAccountCode NVARCHAR(50)
			,@intAccountIdFromCompPref INT
			,@strAccountNumberToBeUse NVARCHAR(50)
			,@strErrorMessage NVARCHAR(200)

	SELECT @intAccountIdFromCompPref = (CASE WHEN @strTransactionType = 'Mark To Market-Basis' OR @strTransactionType = 'Mark To Market-Basis Intransit' THEN
												case when isnull(@dblAmount,0) >= 0 then compPref.intUnrealizedGainOnBasisId else compPref.intUnrealizedLossOnBasisId end
											 WHEN @strTransactionType = 'Mark To Market-Basis Offset' OR @strTransactionType = 'Mark To Market-Basis Intransit Offset' THEN
												case when isnull(@dblAmount,0) >= 0 then compPref.intUnrealizedGainOnInventoryBasisIOSId else compPref.intUnrealizedLossOnInventoryBasisIOSId end
											 WHEN @strTransactionType = 'Mark To Market-Futures Derivative' OR @strTransactionType = 'Mark To Market-Futures'  OR @strTransactionType = 'Mark To Market-Futures Intransit' THEN
												case when isnull(@dblAmount,0) >= 0 then compPref.intUnrealizedGainOnFuturesId else compPref.intUnrealizedLossOnFuturesId end
											 WHEN @strTransactionType = 'Mark To Market-Futures Derivative Offset' OR @strTransactionType = 'Mark To Market-Futures Offset' OR @strTransactionType = 'Mark To Market-Futures Intransit Offset' THEN
												case when isnull(@dblAmount,0) >= 0 then compPref.intUnrealizedGainOnInventoryFuturesIOSId else compPref.intUnrealizedLossOnInventoryFuturesIOSId end
											 WHEN @strTransactionType = 'Mark To Market-Cash' OR @strTransactionType = 'Mark To Market-Cash Intransit' THEN
												case when isnull(@dblAmount,0) >= 0 then compPref.intUnrealizedGainOnCashId else compPref.intUnrealizedLossOnCashId end
											 WHEN @strTransactionType = 'Mark To Market-Cash Offset' OR @strTransactionType = 'Mark To Market-Futures Intransit Offset' THEN
												case when isnull(@dblAmount,0) >= 0 then compPref.intUnrealizedGainOnInventoryCashIOSId else compPref.intUnrealizedLossOnInventoryCashIOSId end
											 WHEN @strTransactionType = 'Mark To Market-Ratio' THEN
												case when isnull(@dblAmount,0) >= 0 then compPref.intUnrealizedGainOnRatioId else compPref.intUnrealizedLossOnRatioId end
											 WHEN @strTransactionType = 'Mark To Market-Ratio Offset' THEN
												case when isnull(@dblAmount,0) >= 0 then compPref.intUnrealizedGainOnInventoryRatioIOSId else compPref.intUnrealizedLossOnInventoryRatioIOSId end
											 ELSE
												0
										END)
	FROM tblRKCompanyPreference compPref

	--Get the account code for Primary
	SET @strPrimaryAccountCode = ''
	select 
	@strPrimaryAccountCode = acct.[Primary Account]
	from vyuGLAccountView acct
	WHERE
	 acct.intAccountId = @intAccountIdFromCompPref


	--Get the account code for Location
	SET @strLocationAccountCode = ''
	SELECT 
	@strLocationAccountCode = acctSgmt.strCode
	FROM tblSMCompanyLocation compLoc
	LEFT OUTER JOIN tblGLAccountSegment acctSgmt ON compLoc.intProfitCenter = acctSgmt.intAccountSegmentId
	WHERE intCompanyLocationId = @intUseCompanyLocationId

	--If LOB is setup on GL Account Structure. intStructureType 5 is equal to Line of Bussiness on default data
	IF EXISTS (SELECT TOP 1 1 FROM tblGLAccountStructure WHERE intStructureType = 5)
	BEGIN
		--Get the account code for LOB
		SET @strLOBAccountCode = ''
		SELECT 
		@strLOBAccountCode = acctSgmt.strCode
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
		UPDATE tblRKM2MPostRecap SET
			intAccountId = NULL
			,strAccountId = NULL
		WHERE intM2MTransactionId = @intM2MTransactionId
	
	END
	ELSE
	BEGIN
		DECLARE @intAccountIdToBeUse INT
		SELECT TOP 1 @intAccountIdToBeUse = intAccountId FROM tblGLAccount WHERE strAccountId = ISNULL(@strAccountNumberToBeUse,'')
		
		--Update the Post Recap table to the right GL Account
		UPDATE tblRKM2MPostRecap SET
			intAccountId = @intAccountIdToBeUse
			,strAccountId = @strAccountNumberToBeUse
		WHERE intM2MTransactionId = @intM2MTransactionId

	END
	
	DELETE FROM #tmpPostRecap WHERE intM2MTransactionId = @intM2MTransactionId

END