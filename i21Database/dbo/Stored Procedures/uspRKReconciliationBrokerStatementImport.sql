CREATE PROC uspRKReconciliationBrokerStatementImport
	@dtmFilledDate datetime,
	@intFutureMarketId	int,
	@intCommodityId	int ,
	@intBrokerId	int ,
	@intBorkerageAccountId	int=null,
	@intReconciliationBrokerStatementHeaderIdOut int  out
   ,@strStatus nvarchar(50)  out
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
AND convert(datetime,(convert(varchar, replace(dtmFilledDate,'-','/'), @ConvertYear)),@ConvertYear)  <= convert(datetime,(convert(varchar, replace(@dtmFilledDate,'-','/'), @ConvertYear)),@ConvertYear)
GROUP BY strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,strFutureMonth,dblPrice,dtmFilledDate

INSERT INTO @tblTransRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate)
SELECT @strName,strAccountNumber,@strFutMarketName,@strCommodityCode,
		ft.strBuySell
		, sum(dblBalanceLot) intNoOfContract,
		strFutureMonth,ft.dblPrice,
		CONVERT(VARCHAR,ft.dtmFilledDate, @ConvertYear) dtmFilledDate
FROM vyuRKLFuturePSTransaction f
	JOIN tblRKFutOptTransaction ft on ft.intFutOptTransactionId=f.intFutOptTransactionId
	JOIN tblRKFuturesMonth fmon on fmon.intFutureMonthId=f.intFutureMonthId
	JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=f.intBrokerageAccountId
WHERE ft.intSelectedInstrumentTypeId=1 and ft.intInstrumentTypeId=1
AND f.intFutureMarketId=@intFutureMarketId and f.intCommodityId=@intCommodityId and f.intEntityId = @intBrokerId 
AND f.intBrokerageAccountId=case when isnull(@intBorkerageAccountId,0)=0 then f.intBrokerageAccountId else @intBorkerageAccountId end 
and CONVERT(VARCHAR,ft.dtmFilledDate, @ConvertYear) <= CONVERT(VARCHAR,@dtmFilledDate, @ConvertYear) 
AND isnull(ft.ysnFreezed,0) = 0
GROUP BY ft.strBuySell,ft.dblPrice,fmon.strFutureMonth,convert(varchar, ft.dtmFilledDate, @ConvertYear),strAccountNumber,f.dtmFilledDate


SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,t.intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
	   t.ImportId,t1.Id INTO #impRec
FROM @ImportedRec t
JOIN @tblTransRec t1 on t.strName=t1.strName
	 and t.strAccountNumber=t1.strAccountNumber 
	 and t.strFutMarketName=t1.strFutMarketName 
	 and t.strCommodityCode=t1.strCommodityCode 
	 and t.strBuySell=t1.strBuySell 
	 and t.intNoOfContract=t1.intNoOfContract
	 and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
	 and t.dblPrice=t1.dblPrice 
	 AND  convert(varchar, t.dtmFilledDate, @ConvertYear)= convert(varchar, t1.dtmFilledDate, @ConvertYear)

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
	AND CONVERT(VARCHAR,dtmFilledDate, @ConvertYear) <= CONVERT(VARCHAR,@dtmFilledDate, @ConvertYear)  AND intBrokerageAccountId= case when isnull(@intBorkerageAccountId,0)=0 then intBrokerageAccountId else @intBorkerageAccountId end 
	and intInstrumentTypeId=1  and intSelectedInstrumentTypeId = 1 and isnull(ysnFreezed,0) = 0

END

INSERT INTO tblRKReconciliationBrokerStatement
(intReconciliationBrokerStatementHeaderId,intConcurrencyId,strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,strErrMessage)

SELECT @intReconciliationBrokerStatementHeaderId,1 AS intConcurrencyId,strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,convert(datetime,(convert(varchar, replace(dtmFilledDate,'-','/'), @ConvertYear)),@ConvertYear) , strErrMessage
FROM 
(
	SELECT *,'Failed' AS strErrMessage FROM @ImportedRec WHERE ImportId NOT IN (SELECT ImportId FROM #impRec)
	UNION
	SELECT *,'Failed' AS strErrMessage FROM @tblTransRec WHERE Id NOT IN (SELECT Id FROM #impRec)
	UNION
	SELECT *,'Success' AS strErrMessage FROM @tblTransRec WHERE Id  IN (SELECT Id FROM #impRec)
)t

SELECT @intReconciliationBrokerStatementHeaderIdOut=@intReconciliationBrokerStatementHeaderId,@strStatus=@strStatus

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