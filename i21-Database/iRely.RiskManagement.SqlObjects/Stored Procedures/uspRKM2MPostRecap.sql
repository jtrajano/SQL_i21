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
DECLARE @Result TABLE (
	RowNum int ,
	MonthOrder nvarchar(100)  ,
	intFutOptTransactionId int  ,
	GrossPnL numeric(24,10) ,
	dblLong numeric(24,10)  ,
	dblShort numeric(24,10)  ,
	dblFutCommission numeric(24,10) ,
	strFutMarketName nvarchar(100)  ,
	strFutureMonth nvarchar(100)  ,
	dtmTradeDate datetime ,
	strInternalTradeNo nvarchar(20) ,
	strName nvarchar(100)  ,
	strAccountNumber nvarchar(100)  ,
	strBook nvarchar(2100) ,
	strSubBook nvarchar(2100) ,
	strSalespersonId nvarchar(100) ,
	strCommodityCode nvarchar(100) ,
	strLocationName nvarchar(100)  ,
	Long1 int  ,
	Sell1 int  ,
	intNet int ,
	dblActual numeric(24, 10) ,
	dblClosing numeric(24, 10) ,
	dblPrice numeric(24, 10)  ,
	dblContractSize numeric(24, 10)  ,
	dblFutCommission1 numeric(24, 10)  ,
	MatchLong numeric(24,10)  ,
	MatchShort numeric(24,10)  ,
	NetPnL numeric(24,10) ,
	intFutureMarketId int ,
	intFutureMonthId int ,
	intOriginalQty int ,
	intFutOptTransactionHeaderId int  ,
	intCommodityId int ,
	ysnExpired bit  ,
	dblVariationMargin numeric(24,10) ,
	dblInitialMargin numeric(24, 10)  , 
	LongWaitedPrice numeric(24,10)  ,
	ShortWaitedPrice numeric(24,10)  
)

INSERT INTO @Result (RowNum,MonthOrder,intFutOptTransactionId,GrossPnL,dblLong,dblShort,dblFutCommission,strFutMarketName,strFutureMonth,dtmTradeDate,strInternalTradeNo,
					strName,strAccountNumber,strBook,strSubBook,strSalespersonId,strCommodityCode,strLocationName,Long1,Sell1,intNet,dblActual,dblClosing,dblPrice,dblContractSize,dblFutCommission1,
					MatchLong,MatchShort,NetPnL,intFutureMarketId,intFutureMonthId,intOriginalQty,intFutOptTransactionHeaderId,intCommodityId,ysnExpired,dblVariationMargin,dblInitialMargin,
					LongWaitedPrice,ShortWaitedPrice)
EXEC uspRKUnrealizedPnL @dtmFromDate ='01/01/2000'	,@dtmToDate  = @Todate,@intCommodityId  = @intCommodityId,@ysnExpired  = 0	,@intFutureMarketId  = null


--------- end

--Basis entry
INSERT INTO tblRKM2MPostRecap (intM2MInquiryId,
	[dtmDate] ,[intAccountId] ,[strAccountId],[dblDebit],[dblCredit],[dblDebitUnit]  ,[dblCreditUnit]  ,[strDescription], [intCurrencyId]  ,[dtmTransactionDate],
	[strTransactionId]  ,[intTransactionId] ,[strTransactionType],[strTransactionForm],[strModuleName] ,[intConcurrencyId],[dblExchangeRate],[dtmDateEntered],
	[ysnIsUnposted],intEntityId,strReference,intUserId,[intSourceLocationId],[intSourceUOMId])
SELECT @intM2MInquiryId intM2MInquiryId, @dtmGLPostDate AS dtmPostDate,
CASE WHEN isnull(dblResultBasis,0) >= 0 then @intUnrealizedGainOnBasisId  else @intUnrealizedLossOnBasisId end intAccountId,
CASE WHEN isnull(dblResultBasis,0) >= 0 then @strUnrealizedGainOnBasisId  else @strUnrealizedLossOnBasisId end strAccountId
,dblResultBasis,0.0,dblOpenQty,0.0,'Mark To Market-Basis',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Basis','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('Contract(P)','Contract(S)')
and strPricingType <> 'Cash' and isnull(dblResultBasis,0) <> 0
UNION ALL
--Basis entry Offset
SELECT @intM2MInquiryId intM2MInquiryId,@dtmGLPostDate AS dtmPostDate,
	CASE WHEN isnull(dblResultBasis,0) >= 0 then @intUnrealizedGainOnInventoryBasisIOSId  else @intUnrealizedLossOnInventoryBasisIOSId end intAccountId,
	CASE WHEN isnull(dblResultBasis,0) >= 0 then @strUnrealizedGainOnInventoryBasisIOSId  else @strUnrealizedLossOnInventoryBasisIOSId end strAccountId
,0.0,dblResultBasis,0.0,dblOpenQty,'Mark To Market-Basis Offset',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Basis Offset','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('Contract(P)','Contract(S)')
and strPricingType <> 'Cash' and isnull(dblResultBasis,0) <> 0
-- Futures
UNION ALL
SELECT @intM2MInquiryId intM2MInquiryId, @dtmGLPostDate AS dtmPostDate,
CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then @intUnrealizedGainOnFuturesId else @intUnrealizedLossOnFuturesId end intAccountId,
CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then @strUnrealizedGainOnFuturesId else @strUnrealizedLossOnFuturesId end strAccountId
,dblMarketFuturesResult,0.0,dblOpenQty,0.0,'Mark To Market-Futures',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Futures','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('Contract(P)','Contract(S)')
and strPricingType <> 'Cash' and isnull(dblMarketFuturesResult,0) <> 0
UNION ALL
--Futures Offset
SELECT @intM2MInquiryId intM2MInquiryId,@dtmGLPostDate AS dtmPostDate,
	CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then @intUnrealizedGainOnInventoryFuturesIOSId else @intUnrealizedLossOnInventoryFuturesIOSId end intAccountId,
	CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then @strUnrealizedGainOnInventoryFuturesIOSId else @strUnrealizedLossOnInventoryFuturesIOSId end strAccountId
,0.0,dblMarketFuturesResult,0.0,dblOpenQty,'Mark To Market-Futures Offset',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Futures Offset','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('Contract(P)','Contract(S)')
	and strPricingType <> 'Cash' and isnull(dblMarketFuturesResult,0) <> 0
--Cash
UNION ALL
SELECT @intM2MInquiryId intM2MInquiryId, @dtmGLPostDate AS dtmPostDate,
CASE WHEN isnull(dblResultCash,0) >= 0 then @intUnrealizedGainOnCashId else @intUnrealizedLossOnCashId end intAccountId,
CASE WHEN isnull(dblResultCash,0) >= 0 then @strUnrealizedGainOnCashId else @strUnrealizedLossOnCashId end strAccountId
,dblResultCash,0.0,dblOpenQty,0.0,'Mark To Market-Cash',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Cash','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction 
where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('Contract(P)','Contract(S)') and strPricingType = 'Cash' and isnull(dblResultCash,0)<>0
UNION ALL
--Cash Offset
SELECT @intM2MInquiryId intM2MInquiryId,@dtmGLPostDate AS dtmPostDate,
	CASE WHEN isnull(dblResultCash,0) >= 0 then @intUnrealizedGainOnInventoryCashIOSId else @intUnrealizedLossOnInventoryCashIOSId end intAccountId,
	CASE WHEN isnull(dblResultCash,0) >= 0 then @strUnrealizedGainOnInventoryCashIOSId else @strUnrealizedLossOnInventoryCashIOSId end strAccountId
,0.0,dblResultCash,0.0,dblOpenQty,'Mark To Market-Cash Offset',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Cash Offset','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('Contract(P)','Contract(S)')
	and strPricingType = 'Cash' and isnull(dblResultCash,0)<>0

--Ratio
UNION ALL
SELECT @intM2MInquiryId intM2MInquiryId, @dtmGLPostDate AS dtmPostDate,
CASE WHEN isnull(dblResultRatio,0) >= 0 then @intUnrealizedGainOnRatioId else @intUnrealizedLossOnRatioId end intAccountId,
CASE WHEN isnull(dblResultRatio,0) >= 0 then @strUnrealizedGainOnRatioId else @strUnrealizedLossOnRatioId end strAccountId
,dblResultRatio,0.0,dblOpenQty,0.0,'Mark To Market-Ratio',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Ratio','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction 
where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('Contract(P)','Contract(S)') and isnull(dblResultRatio,0)<>0

--Ratio Offset
UNION ALL
SELECT @intM2MInquiryId intM2MInquiryId, @dtmGLPostDate AS dtmPostDate,
CASE WHEN isnull(dblResultRatio,0) >= 0 then @intUnrealizedGainOnInventoryRatioIOSId else @intUnrealizedLossOnInventoryRatioIOSId end intAccountId,
CASE WHEN isnull(dblResultRatio,0) >= 0 then @strUnrealizedGainOnInventoryRatioIOSId else @strUnrealizedLossOnInventoryRatioIOSId end strAccountId
,0.0,dblResultRatio,dblOpenQty,0.0,'Mark To Market-Ratio Offset',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Ratio Offset','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction 
where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('Contract(P)','Contract(S)') and isnull(dblResultRatio,0)<>0


-------- intransit Offset
UNION ALL
SELECT @intM2MInquiryId intM2MInquiryId,@dtmGLPostDate AS dtmPostDate,
	CASE WHEN isnull(dblResultBasis,0) >= 0 then @intUnrealizedGainOnInventoryBasisIOSId  else @intUnrealizedLossOnInventoryBasisIOSId end intAccountId,
	CASE WHEN isnull(dblResultBasis,0) >= 0 then @strUnrealizedGainOnInventoryBasisIOSId  else @strUnrealizedLossOnInventoryBasisIOSId end strAccountId
,0.0,dblResultBasis,0.0,dblOpenQty,'Mark To Market-Basis Intransit',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Basis Intransit','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('In-transit(P)','In-transit(S)')
and strPricingType <> 'Cash'  and isnull(dblResultBasis,0) <> 0
UNION ALL
SELECT @intM2MInquiryId intM2MInquiryId,@dtmGLPostDate AS dtmPostDate,
	CASE WHEN isnull(dblResultBasis,0) >= 0 then @intUnrealizedGainOnInventoryIntransitIOSId  else @intUnrealizedLossOnInventoryIntransitIOSId end intAccountId,
	CASE WHEN isnull(dblResultBasis,0) >= 0 then @strUnrealizedGainOnInventoryBasisIOSId  else @strUnrealizedLossOnInventoryIntransitIOSId end strAccountId
,dblResultBasis,0.0,dblOpenQty,0.0,'Mark To Market-Basis Intransit Offset',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Basis Intransit Offset','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('In-transit(P)','In-transit(S)')
and strPricingType <> 'Cash'  and isnull(dblResultBasis,0) <> 0


UNION ALL
SELECT @intM2MInquiryId intM2MInquiryId, @dtmGLPostDate AS dtmPostDate,
CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then @intUnrealizedGainOnFuturesId else @intUnrealizedLossOnFuturesId end intAccountId,
CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then @strUnrealizedGainOnFuturesId else @strUnrealizedLossOnFuturesId end strAccountId
,dblMarketFuturesResult,0.0,dblOpenQty,0.0,'Mark To Market-Futures Intransit',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Futures Intransit','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('In-transit(P)','In-transit(S)')
and strPricingType <> 'Cash'  and isnull(dblMarketFuturesResult,0) <> 0

UNION ALL
SELECT @intM2MInquiryId intM2MInquiryId,@dtmGLPostDate AS dtmPostDate,
	CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then @intUnrealizedGainOnInventoryIntransitIOSId  else @intUnrealizedLossOnInventoryIntransitIOSId end intAccountId,
	CASE WHEN isnull(dblMarketFuturesResult,0) >= 0 then @strUnrealizedGainOnInventoryBasisIOSId  else @strUnrealizedLossOnInventoryIntransitIOSId end strAccountId
,0.0,dblMarketFuturesResult,0.0,dblOpenQty,'Mark To Market-Futures Intransit Offset',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Futures Intransit Offset','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('In-transit(P)','In-transit(S)')
and strPricingType <> 'Cash'  and isnull(dblMarketFuturesResult,0) <> 0

UNION ALL

SELECT @intM2MInquiryId intM2MInquiryId, @dtmGLPostDate AS dtmPostDate,
	   CASE WHEN isnull(dblResultCash,0) >= 0 then @intUnrealizedGainOnCashId else @intUnrealizedLossOnCashId end intAccountId,
	   CASE WHEN isnull(dblResultCash,0) >= 0 then @strUnrealizedGainOnCashId else @strUnrealizedLossOnCashId end strAccountId
,dblResultCash,0.0,dblOpenQty,0.0,'Mark To Market-Cash Intransit',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Cash Intransit','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('In-transit(P)','In-transit(S)')
and strPricingType = 'Cash' and isnull(dblResultCash,0) <> 0
Union ALL

SELECT @intM2MInquiryId intM2MInquiryId,@dtmGLPostDate AS dtmPostDate,
	CASE WHEN isnull(dblResultCash,0) >= 0 then @intUnrealizedGainOnInventoryIntransitIOSId  else @intUnrealizedLossOnInventoryIntransitIOSId end intAccountId,
	CASE WHEN isnull(dblResultCash,0) >= 0 then @strUnrealizedGainOnInventoryBasisIOSId  else @strUnrealizedLossOnInventoryIntransitIOSId end strAccountId
,0.0,dblResultCash,0.0,dblOpenQty,'Mark To Market-Futures Intransit Offset',@intCurrencyId,@dtmGLPostDate, strContractSeq,intContractDetailId,
'Mark To Market-Futures Intransit Offset','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId
FROM tblRKM2MInquiryTransaction where intM2MInquiryId=@intM2MInquiryId and strContractOrInventoryType in('In-transit(P)','In-transit(S)')
and strPricingType = 'Cash'  and isnull(dblResultCash,0) <> 0

-- Derivative Transaction
INSERT INTO tblRKM2MPostRecap (intM2MInquiryId,
	[dtmDate] ,[intAccountId] ,[strAccountId],[dblDebit],[dblCredit],[dblDebitUnit]  ,[dblCreditUnit]  ,[strDescription], [intCurrencyId]  ,[dtmTransactionDate],
	[strTransactionId]  ,[intTransactionId] ,[strTransactionType],[strTransactionForm],[strModuleName] ,[intConcurrencyId],[dblExchangeRate],[dtmDateEntered],
	[ysnIsUnposted],intEntityId,strReference,intUserId,[intSourceLocationId],[intSourceUOMId],dblPrice)

SELECT @intM2MInquiryId intM2MInquiryId, @dtmGLPostDate AS dtmPostDate,
CASE WHEN isnull(GrossPnL,0) >= 0 then @intUnrealizedGainOnFuturesId else @intUnrealizedLossOnFuturesId end intAccountId,
CASE WHEN isnull(GrossPnL,0) >= 0 then @strUnrealizedGainOnFuturesId else @strUnrealizedLossOnFuturesId end strAccountId
,GrossPnL,0.0,intNet,0.0,'Mark To Market-Futures Derivative',@intCurrencyId,@dtmGLPostDate,t.strInternalTradeNo,t.intFutOptTransactionId,
		'Mark To Market-Futures Derivative','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,
		@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId,tr.dblPrice
FROM @Result t
join tblRKFutOptTransaction tr on tr.intFutOptTransactionId=t.intFutOptTransactionId
WHERE ISNULL(GrossPnL,0) <> 0

UNION ALL

SELECT @intM2MInquiryId intM2MInquiryId,@dtmGLPostDate AS dtmPostDate,
	CASE WHEN isnull(GrossPnL,0) >= 0 then @intUnrealizedGainOnFuturesId else @intUnrealizedLossOnFuturesId end intAccountId,
	CASE WHEN isnull(GrossPnL,0) >= 0 then @strUnrealizedGainOnFuturesId else @strUnrealizedLossOnFuturesId end strAccountId
,0.0,GrossPnL,0.0,intNet,'Mark To Market-Futures Derivative Offset',@intCurrencyId,@dtmGLPostDate,t.strInternalTradeNo,t.intFutOptTransactionId,
'Mark To Market-Futures Derivative Offset','Mark To Market','Risk Management',1,1,getdate(),0,intEntityId,@strRecordName strRecordName,@intUserId intUserId,
@intLocationId intLocationId,@intUnitMeasureId intUnitMeasureId,tr.dblPrice
FROM @Result t
JOIN tblRKFutOptTransaction tr on tr.intFutOptTransactionId=t.intFutOptTransactionId
WHERE ISNULL(GrossPnL,0) <> 0

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
		SET @intContractSeq = SUBSTRING(@strTransactionId,CHARINDEX('-',@strTransactionId) + 1,LEN(@strTransactionId) - CHARINDEX('-',@strTransactionId)) 

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