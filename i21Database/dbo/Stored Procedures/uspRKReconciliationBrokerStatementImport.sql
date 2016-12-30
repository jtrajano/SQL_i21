CREATE PROC uspRKReconciliationBrokerStatementImport
	@dtmFilledDate datetime,
	@intFutureMarketId	int,
	@intCommodityId	int ,
	@intBrokerId	int ,
	@intBorkerageAccountId	int=null,
	@intReconciliationBrokerStatementHeaderIdOut int  out
   ,@strStatus nvarchar(50)  OUT
AS

BEGIN TRY

DECLARE @strDateTimeFormat nvarchar(50)
DECLARE @ConvertYear int
DECLARE @ErrMsg nvarchar(max)
DECLARE @strFutMarketName  nvarchar(50)
DECLARE @strCommodityCode nvarchar(50)
DECLARE @strName nvarchar(50)
DECLARE @strAccountNumber nvarchar(50)

SELECT @strFutMarketName=strFutMarketName from tblRKFutureMarket where intFutureMarketId=@intFutureMarketId
SELECT @strCommodityCode=strCommodityCode from tblICCommodity where intCommodityId=@intCommodityId
SELECT @strName=strName from tblEMEntity where intEntityId=@intBrokerId
SELECT @strAccountNumber=strAccountNumber from tblRKBrokerageAccount where intBrokerageAccountId=@intBorkerageAccountId

SELECT @strDateTimeFormat = strDateTimeFormat FROM tblRKCompanyPreference

IF (@strDateTimeFormat = 'MM DD YYYY HH:MI' OR @strDateTimeFormat ='YYYY MM DD HH:MI')
SELECT @ConvertYear=101
ELSE IF (@strDateTimeFormat = 'DD MM YYYY HH:MI' OR @strDateTimeFormat ='YYYY DD MM HH:MI')
SELECT @ConvertYear=103

DECLARE @ImportedRec TABLE
    (
	[ImportId] INT identity(1,1),
    [strName] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,	
	[strAccountNumber] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strFutMarketName] nvarchar(30) COLLATE Latin1_General_CI_AS NULL,
	[strCommodityCode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strBuySell] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intNoOfContract] int,
	[strFutureMonth] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,	
	[dblPrice] decimal(24,10) ,	
	[dtmFilledDate] nvarchar(50) COLLATE Latin1_General_CI_AS NULL
	)

DECLARE @tblTransRec TABLE
(
	Id INT identity(1,1),
    [strName] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,	
	[strAccountNumber] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strFutMarketName] nvarchar(30) COLLATE Latin1_General_CI_AS NULL,
	[strCommodityCode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strBuySell] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intNoOfContract] int,
	[strFutureMonth] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,	
	[dblPrice] decimal(24,10) ,	
	[dtmFilledDate] nvarchar(50) COLLATE Latin1_General_CI_AS NULL
)

INSERT INTO @ImportedRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate)
SELECT strName,
strAccountNumber,
strFutMarketName,
strCommodityCode,
strBuySell,
sum(intNoOfContract) intNoOfContract,
replace(strFutureMonth,'-',' ') strFutureMonth,
dblPrice,
replace(dtmFilledDate,'-','/') dtmFilledDate 
FROM [tblRKReconciliationBrokerStatementImport] 
WHERE strFutMarketName=@strFutMarketName 
and strCommodityCode=@strCommodityCode 
and strName = @strName 
AND strAccountNumber=case when isnull(@strAccountNumber,'')='' then strAccountNumber else @strAccountNumber end 
AND convert(datetime,(convert(varchar, replace(dtmFilledDate,'-','/'), @ConvertYear)),@ConvertYear) = convert(datetime,(convert(varchar, replace(@dtmFilledDate,'-','/'), @ConvertYear)),@ConvertYear)
GROUP BY strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,strFutureMonth,dblPrice,dtmFilledDate

INSERT INTO @tblTransRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate)
SELECT strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell, sum(intNoOfContract) intNoOfContract,strFutureMonth,dblPrice,
CONVERT(VARCHAR,@dtmFilledDate, @ConvertYear) dtmFilledDate 
FROM (SELECT e.strName,strAccountNumber,fm.strFutMarketName,
	case when f.intInstrumentTypeId = 1 then 'Futures' 
		 when f.intInstrumentTypeId =2 then  'Options' 
	end as strInstrumentType,
		 strCommodityCode, l.strLocationName,
		 en.strName strSalesPersionId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,fmon.strFutureMonth,dblPrice,strReference,strStatus,
		 dtmFilledDate
 FROM tblRKFutOptTransaction f
join tblEMEntity e on e.intEntityId=f.intEntityId and f.intInstrumentTypeId = 1
join tblRKBrokerageAccount ba on ba.intBrokerageAccountId=f.intBrokerageAccountId
join tblRKFutureMarket fm on fm.intFutureMarketId=f.intFutureMarketId
join tblICCommodity c on c.intCommodityId=f.intCommodityId
JOIN tblSMCompanyLocation l on l.intCompanyLocationId=f.intLocationId
JOIN tblSMCurrency cur on cur.intCurrencyID=f.intCurrencyId
JOIN tblEMEntity en on en.intEntityId=intTraderId
JOIN tblRKFuturesMonth fmon on fmon.intFutureMonthId=f.intFutureMonthId
WHERE 
f.intFutureMarketId=@intFutureMarketId and f.intCommodityId=@intCommodityId and f.intEntityId = @intBrokerId 
AND CONVERT(VARCHAR,f.dtmFilledDate, @ConvertYear) = CONVERT(VARCHAR,@dtmFilledDate, @ConvertYear)  
and f.intBrokerageAccountId=case when isnull(@intBorkerageAccountId,0)=0 then f.intBrokerageAccountId else @intBorkerageAccountId end 
and isnull(f.ysnFreezed,0) = 0
)t
GROUP BY strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
strSalesPersionId,strCurrency,strBrokerTradeNo,strBuySell,strFutureMonth,dblPrice,strReference,strStatus,dtmFilledDate
	

SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,t.intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
	   t.ImportId,t1.Id,t1.dtmFilledDate a , t.dtmFilledDate c INTO #impRec
FROM @ImportedRec t
JOIN @tblTransRec t1 on t.strName=t1.strName
	 and t.strAccountNumber=t1.strAccountNumber 
	 and t.strFutMarketName=t1.strFutMarketName 
	 and t.strCommodityCode=t1.strCommodityCode 
	 and t.strBuySell=t1.strBuySell 
	 and t.intNoOfContract=t1.intNoOfContract
	 and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
	 and t.dblPrice=t1.dblPrice 
	 AND  t.dtmFilledDate= convert(varchar, t1.dtmFilledDate, @ConvertYear)
	 
BEGIN TRANSACTION    

	DECLARE @intReconciliationBrokerStatementHeaderId INT

IF EXISTS(SELECT 1 FROM @ImportedRec WHERE ImportId NOT IN (SELECT ImportId FROM #impRec) 
			UNION
			SELECT 1 FROM @tblTransRec WHERE Id NOT IN (SELECT Id FROM #impRec))
BEGIN

	INSERT INTO tblRKReconciliationBrokerStatementHeader
	(intConcurrencyId,dtmReconciliationDate,dtmFilledDate,intEntityId,intBrokerageAccountId,intFutureMarketId,intCommodityId,strImportStatus,strComments)
	SELECT 1 AS intConcurrencyId
	,GETDATE() AS dtmReconciliationDate
	,@dtmFilledDate AS dtmFilledDate
	,@intBrokerId AS intEntityId
	,@intBorkerageAccountId as intBorkerageAccountId
	,@intFutureMarketId AS intFutureMarketId
	,@intCommodityId AS intCommodityId
	,'Failed'  AS ysnImportStatus
	,'' AS strComments
	SET @intReconciliationBrokerStatementHeaderId=SCOPE_IDENTITY()
	SET @strStatus = 'Failed'
END	
ELSE
BEGIN

	INSERT INTO tblRKReconciliationBrokerStatementHeader
	(intConcurrencyId,dtmReconciliationDate,dtmFilledDate,intEntityId,intBrokerageAccountId,intFutureMarketId,intCommodityId,strImportStatus,strComments)
	SELECT 1 AS intConcurrencyId
	,GETDATE() AS dtmReconciliationDate
	,@dtmFilledDate AS dtmFilledDate
	,@intBrokerId AS intEntityId
	,@intBorkerageAccountId as intBorkerageAccountId
	,@intFutureMarketId AS intFutureMarketId
	,@intCommodityId AS intCommodityId
	,'Success'  AS ysnImportStatus
	,'' AS strComments
	SET @intReconciliationBrokerStatementHeaderId=SCOPE_IDENTITY()
	SET @strStatus = 'Success'

	UPDATE tblRKFutOptTransaction set ysnFreezed=1 
    where intFutureMarketId=@intFutureMarketId and intCommodityId=@intCommodityId and intEntityId = @intBrokerId 
	AND CONVERT(VARCHAR,dtmFilledDate, @ConvertYear) = CONVERT(VARCHAR,@dtmFilledDate, @ConvertYear)  AND intBrokerageAccountId= case when isnull(@intBorkerageAccountId,0)=0 then intBrokerageAccountId else @intBorkerageAccountId end 
	and intInstrumentTypeId=1  and intSelectedInstrumentTypeId = 1 and isnull(ysnFreezed,0) = 0

END

SELECT  t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,sum(t.balQty) balQty,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
	   t.ImportId, convert(nvarchar,sum(balQty))+'Number of contract is mismatch between broker statement and i21. Broker statement has: '+convert(nvarchar,sum(imptQty))+' and i21 has: '+convert(nvarchar,sum(tranQty))+'.' AS strErrMessage into #MisMatchedQty FROM (
	SELECT *,imptQty-tranQty as balQty  FROM(
			SELECT *,intNoOfContract as imptQty, 0 as tranQty FROM @ImportedRec WHERE ImportId NOT IN (SELECT ImportId FROM #impRec)
			UNION
			SELECT *,0 as tranQty,intNoOfContract as imptQty FROM @tblTransRec WHERE Id NOT IN (SELECT Id FROM #impRec)
		)t1
)t 
group by t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,t.ImportId

INSERT INTO tblRKReconciliationBrokerStatement
(intReconciliationBrokerStatementHeaderId,intConcurrencyId,strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,strErrMessage)
SELECT @intReconciliationBrokerStatementHeaderId,1 AS intConcurrencyId,strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,convert(datetime,(convert(varchar, replace(dtmFilledDate,'-','/'), @ConvertYear)),@ConvertYear) , strErrMessage
FROM (	
	SELECT Id,strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,'Success' AS strErrMessage FROM @tblTransRec WHERE Id  IN (SELECT Id FROM #impRec)
	UNION
	SELECT ImportId Id,strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,balQty as intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,strErrMessage from #MisMatchedQty
	UNION
	SELECT ImportId Id,strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,'Reconciliate Failed.' AS strErrMessage FROM @ImportedRec WHERE ImportId NOT IN (SELECT ImportId FROM #impRec union SELECT ImportId FROM #MisMatchedQty) 
	UNION
	SELECT Id Id,strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,'Reconciliate Failed.' AS strErrMessage FROM @tblTransRec WHERE Id NOT IN (SELECT Id FROM #impRec union SELECT ImportId FROM #MisMatchedQty)
)t

SELECT @intReconciliationBrokerStatementHeaderIdOut = @intReconciliationBrokerStatementHeaderId,@strStatus = @strStatus

COMMIT TRAN    
    
END TRY    

BEGIN CATCH
 SET @ErrMsg = ERROR_MESSAGE()  
 IF XACT_STATE() != 0 ROLLBACK TRANSACTION  
 If @ErrMsg != ''   
 BEGIN  
  RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
 END  
END CATCH

