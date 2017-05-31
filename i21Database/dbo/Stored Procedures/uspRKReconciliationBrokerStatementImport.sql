CREATE PROC [dbo].[uspRKReconciliationBrokerStatementImport]
     @dtmFilledDate datetime,
     @intFutureMarketId   int,
     @intCommodityId      int ,
     @intBrokerId  int ,
     @intBorkerageAccountId     int=null,
     @intReconciliationBrokerStatementHeaderIdOut int  out
   ,@strStatus nvarchar(50)  OUT
AS
--mm dd -yyy
--declare   @dtmFilledDate datetime = '02/16/2017',
--       @intFutureMarketId   int = 5,
--       @intCommodityId      int =7,
--       @intBrokerId  int =1443,
--       @intBorkerageAccountId     int=2,
--       @intReconciliationBrokerStatementHeaderIdOut int,  
--       @strStatus nvarchar(50)  
    
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

DECLARE @tblFinalRec TABLE
(
       [ImportId] INT,
       [strName] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,       
       [strAccountNumber] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
       [strFutMarketName] nvarchar(30) COLLATE Latin1_General_CI_AS NULL,
       [strCommodityCode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
       [strBuySell] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
       [intNoOfContract] int,
       [strFutureMonth] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,     
       [dblPrice] decimal(24,10) , 
       [dtmFilledDate] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
       [strStatus] nvarchar(200) COLLATE Latin1_General_CI_AS NULL
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
ORDER BY strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,strFutureMonth,dblPrice,dtmFilledDate

INSERT INTO @tblTransRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate)
SELECT strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell, sum(intNoOfContract) intNoOfContract,strFutureMonth,dblPrice,
CONVERT(VARCHAR,@dtmFilledDate, @ConvertYear) dtmFilledDate 
FROM (SELECT e.strName,strAccountNumber,fm.strFutMarketName,
       case when f.intInstrumentTypeId = 1 then 'Futures' 
               when f.intInstrumentTypeId =2 then  'Options' 
       end as strInstrumentType,
              strCommodityCode, l.strLocationName,
              strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,fmon.strFutureMonth,dblPrice,strReference,strStatus,
              dtmFilledDate
FROM tblRKFutOptTransaction f
join tblEMEntity e on e.intEntityId=f.intEntityId
join tblRKBrokerageAccount ba on ba.intBrokerageAccountId=f.intBrokerageAccountId and f.intInstrumentTypeId = 1
join tblRKFutureMarket fm on fm.intFutureMarketId=f.intFutureMarketId
join tblICCommodity c on c.intCommodityId=f.intCommodityId
JOIN tblSMCompanyLocation l on l.intCompanyLocationId=f.intLocationId
JOIN tblSMCurrency cur on cur.intCurrencyID=f.intCurrencyId
JOIN tblRKFuturesMonth fmon on fmon.intFutureMonthId=f.intFutureMonthId
WHERE 
f.intFutureMarketId=@intFutureMarketId and f.intCommodityId=@intCommodityId and f.intEntityId = @intBrokerId 
AND CONVERT(VARCHAR,f.dtmFilledDate, @ConvertYear) = CONVERT(VARCHAR,@dtmFilledDate, @ConvertYear)  
and f.intBrokerageAccountId=case when isnull(@intBorkerageAccountId,0)=0 then f.intBrokerageAccountId else @intBorkerageAccountId end 
and
isnull(f.ysnFreezed,0) = 0
)t
GROUP BY strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,strFutureMonth,dblPrice         
INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,t.intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.ImportId,'Success'
FROM @ImportedRec t
JOIN @tblTransRec t1 on t.strName=t1.strName
       and t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
        and t.intNoOfContract=t1.intNoOfContract
        and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear)

delete from  @ImportedRec  where ImportId in (select t1.ImportId from  @ImportedRec t1
                                                                             JOIN @tblFinalRec t on t.strName=t1.strName
                                                                              and t.strAccountNumber=t1.strAccountNumber 
                                                                                  and t.strFutMarketName=t1.strFutMarketName 
                                                                                  and t.strCommodityCode=t1.strCommodityCode 
                                                                                  and t.strBuySell=t1.strBuySell 
                                                                                  and t.intNoOfContract=t1.intNoOfContract
                                                                                  and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
                                                                                  and t.dblPrice=t1.dblPrice 
                                                                                  AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear))

delete from  @tblTransRec  where Id in (select t1.Id from  @tblTransRec t1
                                                                           JOIN @tblFinalRec t on t.strName=t1.strName
                                                                              and t.strAccountNumber=t1.strAccountNumber 
                                                                                  and t.strFutMarketName=t1.strFutMarketName 
                                                                                  and t.strCommodityCode=t1.strCommodityCode 
                                                                                  and t.strBuySell=t1.strBuySell 
                                                                                  and t.intNoOfContract=t1.intNoOfContract
                                                                                  and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
                                                                                  and t.dblPrice=t1.dblPrice 
                                                                                  AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear))



INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,isnull(t.intNoOfContract,0) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.ImportId,'Contract mismatch. Broker statement has  : '+convert(nvarchar,isnull(t.intNoOfContract,0))+' and i21 has: 0 . Difference : '+ convert(nvarchar,t.intNoOfContract) +' '
FROM @ImportedRec t where convert (datetime, '1 '+t.strFutureMonth) not in(select convert (datetime, '1 '+t1.strFutureMonth) from @tblTransRec t1 )              


INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.Id,'Contract mismatch. Broker statement has  : 0 and i21 has: '+convert(nvarchar,isnull(t.intNoOfContract,0))+'. Difference : '+convert(nvarchar,t.intNoOfContract) +' '
FROM @tblTransRec t where convert (datetime, '1 '+t.strFutureMonth) not in(select convert (datetime, '1 '+t1.strFutureMonth) from @ImportedRec t1 )
  
delete from  @ImportedRec   where convert (datetime, '1 '+strFutureMonth) not in(select convert (datetime, '1 '+t1.strFutureMonth) from @tblTransRec t1 ) 

delete from  @tblTransRec where convert (datetime, '1 '+strFutureMonth) not in(select convert (datetime, '1 '+t1.strFutureMonth) from @ImportedRec t1 )



INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)-isnull(t1.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.ImportId,'Contract mismatch. Broker statement has: '+convert(nvarchar,isnull(t.intNoOfContract,0))+' and i21 has: '+convert(nvarchar,isnull(t1.intNoOfContract,0))+'. Difference : '+convert(nvarchar,(abs(isnull(t.intNoOfContract,0)-isnull(t1.intNoOfContract,0)))) +' '
FROM @ImportedRec t
LEFT JOIN @tblTransRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
        --and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear)

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)-isnull(t1.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.Id,'Contract mismatch. Broker statement has: '+convert(nvarchar,isnull(t1.intNoOfContract,0))+' and i21 has: '+convert(nvarchar,isnull(t.intNoOfContract,0))+'. Difference : '+convert(nvarchar,(abs(isnull(t1.intNoOfContract,0)-isnull(t.intNoOfContract,0)))) +' '
FROM @tblTransRec t
LEFT JOIN @ImportedRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
        --and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear)

delete from  @ImportedRec  where ImportId in (select t1.ImportId from  @ImportedRec t1
                                                                             JOIN @tblFinalRec t on t.strName=t1.strName
                                                                              WHERE t.strAccountNumber=t1.strAccountNumber 
                                                                                  and t.strFutMarketName=t1.strFutMarketName 
                                                                                  and t.strCommodityCode=t1.strCommodityCode 
                                                                                  and t.strBuySell=t1.strBuySell 
                                                                                  --and t.intNoOfContract=t1.intNoOfContract
                                                                              and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
                                                                                  and t.dblPrice=t1.dblPrice 
                                                                                  AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear))

delete from  @tblTransRec  where Id in (select t1.Id from  @tblTransRec t1
                                                                           JOIN @tblFinalRec t on t.strName=t1.strName
                                                                              WHERE t.strAccountNumber=t1.strAccountNumber 
                                                                                  and t.strFutMarketName=t1.strFutMarketName 
                                                                                  and t.strCommodityCode=t1.strCommodityCode 
                                                                                  and t.strBuySell=t1.strBuySell 
                                                                                  --and t.intNoOfContract=t1.intNoOfContract
                                                                              and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
                                                                                  and t.dblPrice=t1.dblPrice 
                                                                                  AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear))

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,isnull(t.intNoOfContract,0) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.ImportId,'Contract mismatch. Broker statement has  : '+convert(nvarchar,isnull(t.intNoOfContract,0))+' and i21 has: 0 . Difference : '+ convert(nvarchar,t.intNoOfContract) +' '
FROM @ImportedRec t
LEFT JOIN @tblTransRec t1 on t.strName=t1.strName
       where t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        --and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear)

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.Id,'Contract mismatch. Broker statement has  : 0 and i21 has: '+convert(nvarchar,isnull(t.intNoOfContract,0))+'. Difference : '+convert(nvarchar,t.intNoOfContract) +' '
FROM @tblTransRec t
LEFT JOIN @ImportedRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        --and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear)

delete from  @ImportedRec  where ImportId in (select t1.ImportId from  @ImportedRec t1
                                                                             JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        --and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear))

delete from  @tblTransRec  
              where Id in (select t1.Id from  @tblTransRec t1
                                  JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        --and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear))

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,isnull(t.intNoOfContract,0) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.ImportId,'Contract mismatch. Broker statement has  : '+convert(nvarchar,isnull(t.intNoOfContract,0))+' and i21 has: 0 . Difference : '+ convert(nvarchar,t.intNoOfContract) +' '
FROM @ImportedRec t
LEFT JOIN @tblTransRec t1 on t.strName=t1.strName
       where t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        --and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear)

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.Id,'Contract mismatch. Broker statement has  : 0 and i21 has: '+convert(nvarchar,isnull(t.intNoOfContract,0))+'. Difference : '+convert(nvarchar,t.intNoOfContract) +' '
FROM @tblTransRec t
LEFT JOIN @ImportedRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        --and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear)

delete from  @ImportedRec  where ImportId in (select t1.ImportId from  @ImportedRec t1
                                                                             JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        --and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear))

delete from  @tblTransRec  
              where Id in (select t1.ImportId from @tblTransRec t
LEFT JOIN @ImportedRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        --and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear))

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,isnull(t.intNoOfContract,0) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.ImportId,'Contract mismatch. Broker statement has  : '+convert(nvarchar,isnull(t.intNoOfContract,0))+' and i21 has: 0 . Difference : '+ convert(nvarchar,t.intNoOfContract) +' '
FROM @ImportedRec t
LEFT JOIN @tblTransRec t1 on t.strName=t1.strName
       where t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear)

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.Id,'Contract mismatch. Broker statement has  : 0 and i21 has: '+convert(nvarchar,isnull(t.intNoOfContract,0))+'. Difference : '+convert(nvarchar,t.intNoOfContract) +' '
FROM @tblTransRec t
LEFT JOIN @ImportedRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear)

delete from  @ImportedRec  where ImportId in (select t1.ImportId from  @ImportedRec t1
                                                                             JOIN @tblFinalRec t on t.strName=t1.strName
       where t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear))

delete from  @tblTransRec  
              where Id in (select t1.Id from  @tblTransRec t1
                                  JOIN @tblFinalRec t on t.strName=t1.strName
       where t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear))


INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,isnull(t.intNoOfContract,0) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.ImportId,'Contract mismatch. Broker statement has  : '+convert(nvarchar,isnull(t.intNoOfContract,0))+' and i21 has: 0 . Difference : '+ convert(nvarchar,t.intNoOfContract) +' '
FROM @ImportedRec t
LEFT JOIN @tblTransRec t1 on t.strName=t1.strName
       where t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        --and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear)

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.Id,'Contract mismatch. Broker statement has  : 0 and i21 has: '+convert(nvarchar,isnull(t.intNoOfContract,0))+'. Difference : '+convert(nvarchar,t.intNoOfContract) +' '
FROM @tblTransRec t
LEFT JOIN @ImportedRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        --and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear)

delete from  @ImportedRec  where ImportId in (select t1.ImportId from  @ImportedRec t1
                                                                             JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        --and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear))

delete from  @tblTransRec  
              where Id in (select t1.ImportId from  @tblTransRec t
LEFT JOIN @ImportedRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        --and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear))

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,isnull(t.intNoOfContract,0) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.ImportId,'Contract mismatch. Broker statement has  : '+convert(nvarchar,isnull(t.intNoOfContract,0))+' and i21 has: 0 . Difference : '+ convert(nvarchar,t.intNoOfContract) +' '
FROM @ImportedRec t
LEFT JOIN @tblTransRec t1 on t.strName=t1.strName
       where t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear)

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.Id,'Contract mismatch. Broker statement has  : 0 and i21 has: '+convert(nvarchar,isnull(t.intNoOfContract,0))+'. Difference : '+convert(nvarchar,t.intNoOfContract) +' '
FROM @tblTransRec t
LEFT JOIN @ImportedRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear)

delete from  @ImportedRec  where ImportId in (select t1.ImportId from  @ImportedRec t1
                                                                             JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear))

delete from  @tblTransRec  
              where Id in (select t1.Id from  @tblTransRec t1
                                  JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        AND  convert (datetime,t.dtmFilledDate, @ConvertYear)= convert (datetime,convert(varchar, t1.dtmFilledDate, @ConvertYear), @ConvertYear))

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,isnull(t.intNoOfContract,0) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.ImportId,'Contract mismatch. Broker statement has  : '+convert(nvarchar,isnull(t.intNoOfContract,0))+' and i21 has: 0 . Difference : '+ convert(nvarchar,t.intNoOfContract) +' '
FROM @ImportedRec t
LEFT JOIN @tblTransRec t1 on t.strName=t1.strName
       where t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        --and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.Id,'Contract mismatch. Broker statement has  : 0 and i21 has: '+convert(nvarchar,isnull(t.intNoOfContract,0))+'. Difference : '+convert(nvarchar,t.intNoOfContract) +' '
FROM @tblTransRec t
LEFT JOIN @ImportedRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        --and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        
delete from  @ImportedRec  where ImportId in (select t1.ImportId from  @ImportedRec t1
                                                                             JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        --and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice)

delete from  @tblTransRec  
              where Id in (select t1.Id from  @tblTransRec t1
                                  JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        --and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice)

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,isnull(t.intNoOfContract,0) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.ImportId,'Contract mismatch. Broker statement has  : '+convert(nvarchar,isnull(t.intNoOfContract,0))+' and i21 has: 0 . Difference : '+ convert(nvarchar,t.intNoOfContract) +' '
FROM @ImportedRec t
LEFT JOIN @tblTransRec t1 on t.strName=t1.strName
       where t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        --and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        --and t.dblPrice=t1.dblPrice 
        

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.Id,'Contract mismatch. Broker statement has  : 0 and i21 has: '+convert(nvarchar,isnull(t.intNoOfContract,0))+'. Difference : '+convert(nvarchar,t.intNoOfContract) +' '
FROM @tblTransRec t
LEFT JOIN @ImportedRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        --and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        --and t.dblPrice=t1.dblPrice 
        
delete from  @ImportedRec  where ImportId in (select t1.ImportId from  @ImportedRec t1
                                                                             JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        --and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth)) 
        --and t.dblPrice=t1.dblPrice 

delete from  @tblTransRec  
              where Id in (select t1.Id from  @tblTransRec t1
                                  JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        --and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) )
        --and t.dblPrice=t1.dblPrice 

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,isnull(t.intNoOfContract,0) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.ImportId,'Contract mismatch. Broker statement has  : '+convert(nvarchar,isnull(t.intNoOfContract,0))+' and i21 has: 0 . Difference : '+ convert(nvarchar,t.intNoOfContract) +' '
FROM @ImportedRec t
LEFT JOIN @tblTransRec t1 on t.strName=t1.strName
       where t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        --and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.Id,'Contract mismatch. Broker statement has  : 0 and i21 has: '+convert(nvarchar,isnull(t.intNoOfContract,0))+'. Difference : '+convert(nvarchar,t.intNoOfContract) +' '
FROM @tblTransRec t
LEFT JOIN @ImportedRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        --and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        
delete from  @ImportedRec  where ImportId in (select t1.ImportId from  @ImportedRec t1
                                                                             JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        --and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice) 

delete from  @tblTransRec  
              where Id in (select t1.Id from  @tblTransRec t1
                                  JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        --and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice )

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,isnull(t.intNoOfContract,0) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.ImportId,'Contract mismatch. Broker statement has  : '+convert(nvarchar,isnull(t.intNoOfContract,0))+' and i21 has: 0 . Difference : '+ convert(nvarchar,t.intNoOfContract) +' '
FROM @ImportedRec t
LEFT JOIN @tblTransRec t1 on t.strName=t1.strName
       where t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        --and t.dblPrice=t1.dblPrice 
        

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.Id,'Contract mismatch. Broker statement has  : 0 and i21 has: '+convert(nvarchar,isnull(t.intNoOfContract,0))+'. Difference : '+convert(nvarchar,t.intNoOfContract) +' '
FROM @tblTransRec t
LEFT JOIN @ImportedRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
       -- and t.dblPrice=t1.dblPrice 
        
delete from  @ImportedRec  where ImportId in (select t1.ImportId from  @ImportedRec t1
                                                                             JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract) 

delete from  @tblTransRec  
              where Id in (select t1.Id from  @tblTransRec t1
                                  JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
        and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract)

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,isnull(t.intNoOfContract,0) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.ImportId,'Contract mismatch. Broker statement has  : '+convert(nvarchar,isnull(t.intNoOfContract,0))+' and i21 has: 0 . Difference : '+ convert(nvarchar,t.intNoOfContract) +' '
FROM @ImportedRec t
LEFT JOIN @tblTransRec t1 on t.strName=t1.strName
       where t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
       -- and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.Id,'Contract mismatch. Broker statement has  : 0 and i21 has: '+convert(nvarchar,isnull(t.intNoOfContract,0))+'. Difference : '+convert(nvarchar,t.intNoOfContract) +' '
FROM @tblTransRec t
LEFT JOIN @ImportedRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
       -- and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice 
        
delete from  @ImportedRec  where ImportId in (select t1.ImportId from  @ImportedRec t1
                                                                             JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
       -- and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice) 

delete from  @tblTransRec  
              where Id in (select t1.Id from  @tblTransRec t1
                                  JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
       -- and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        and t.dblPrice=t1.dblPrice)

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,isnull(t.intNoOfContract,0) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.ImportId,'Contract mismatch. Broker statement has  : '+convert(nvarchar,isnull(t.intNoOfContract,0))+' and i21 has: 0 . Difference : '+ convert(nvarchar,t.intNoOfContract) +' '
FROM @ImportedRec t
LEFT JOIN @tblTransRec t1 on t.strName=t1.strName
       where t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
       -- and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        --and t.dblPrice=t1.dblPrice 
        

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.Id,'Contract mismatch. Broker statement has  : 0 and i21 has: '+convert(nvarchar,isnull(t.intNoOfContract,0))+'. Difference : '+convert(nvarchar,t.intNoOfContract) +' '
FROM @tblTransRec t
LEFT JOIN @ImportedRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
       -- and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        --and t.dblPrice=t1.dblPrice 
        
delete from  @ImportedRec  where ImportId in (select t1.Id from  @ImportedRec t
LEFT JOIN @tblTransRec t1 on t.strName=t1.strName
       where t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
       -- and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) )

delete from  @tblTransRec  
              where Id in (select t1.ImportId from  @tblTransRec t
LEFT JOIN @ImportedRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
       -- and t.strBuySell=t1.strBuySell 
       --and t.intNoOfContract=t1.intNoOfContract
       and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth))        

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,isnull(t.intNoOfContract,0) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.ImportId,'Contract mismatch. Broker statement has  : '+convert(nvarchar,isnull(t.intNoOfContract,0))+' and i21 has: 0 . Difference : '+ convert(nvarchar,t.intNoOfContract) +' '
FROM @ImportedRec t
LEFT JOIN @tblTransRec t1 on t.strName=t1.strName
       where t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
       -- and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        --and t.dblPrice=t1.dblPrice 
        

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.Id,'Contract mismatch. Broker statement has  : 0 and i21 has: '+convert(nvarchar,isnull(t.intNoOfContract,0))+'. Difference : '+convert(nvarchar,t.intNoOfContract) +' '
FROM @tblTransRec t
LEFT JOIN @ImportedRec t1 on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
       -- and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract
       --and convert (datetime, '1 '+t.strFutureMonth) = convert (datetime, '1 '+t1.strFutureMonth) 
        --and t.dblPrice=t1.dblPrice 
        
delete from  @ImportedRec  where ImportId in (select t1.ImportId from  @ImportedRec t1
                                                                             JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
       -- and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract) 

delete from  @tblTransRec  
              where Id in (select t1.Id from  @tblTransRec t1
                                  JOIN @tblFinalRec t on t.strName=t1.strName
       WHERE t.strAccountNumber=t1.strAccountNumber 
        and t.strFutMarketName=t1.strFutMarketName 
        and t.strCommodityCode=t1.strCommodityCode 
       -- and t.strBuySell=t1.strBuySell 
       and t.intNoOfContract=t1.intNoOfContract)

INSERT INTO @tblFinalRec (strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,ImportId,strStatus)
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.ImportId,'Contract mismatch. i21 has  : 0 and Broker statement has : '+convert(nvarchar,isnull(t.intNoOfContract,0))+'. Difference : '+convert(nvarchar,t.intNoOfContract) +' '
FROM @ImportedRec t
UNION
SELECT t.strName,t.strAccountNumber,t.strFutMarketName,t.strCommodityCode,t.strBuySell,abs(isnull(t.intNoOfContract,0)) intNoOfContract,t.strFutureMonth,t.dblPrice,t.dtmFilledDate,
          t.Id,'Contract mismatch. Broker statement has  : 0 and i21 has: '+convert(nvarchar,isnull(t.intNoOfContract,0))+'. Difference : '+convert(nvarchar,t.intNoOfContract) +' '
FROM @tblTransRec t

DELETE FROM @ImportedRec
DELETE FROM @tblTransRec

BEGIN TRANSACTION    

     DECLARE @intReconciliationBrokerStatementHeaderId INT

IF EXISTS(SELECT 1 FROM @tblFinalRec where strStatus <> 'Success' )
BEGIN

     INSERT INTO tblRKReconciliationBrokerStatementHeader
       (intConcurrencyId,dtmReconciliationDate,dtmFilledDate,intEntityId,intBrokerageAccountId,intFutureMarketId,intCommodityId,strImportStatus,strComments,ysnFreezed)
     SELECT 1 AS intConcurrencyId
     ,GETDATE() AS dtmReconciliationDate
     ,@dtmFilledDate AS dtmFilledDate
     ,@intBrokerId AS intEntityId
     ,@intBorkerageAccountId as intBorkerageAccountId
     ,@intFutureMarketId AS intFutureMarketId
     ,@intCommodityId AS intCommodityId
     ,'Failed'  AS ysnImportStatus
     ,'' AS strComments
	 ,0 as ysnFreezed
     SET @intReconciliationBrokerStatementHeaderId=SCOPE_IDENTITY()
     SET @strStatus = 'Failed'
END  
ELSE
BEGIN

     INSERT INTO tblRKReconciliationBrokerStatementHeader
       (intConcurrencyId,dtmReconciliationDate,dtmFilledDate,intEntityId,intBrokerageAccountId,intFutureMarketId,intCommodityId,strImportStatus,strComments,ysnFreezed)
     SELECT 1 AS intConcurrencyId
     ,GETDATE() AS dtmReconciliationDate
     ,@dtmFilledDate AS dtmFilledDate
     ,@intBrokerId AS intEntityId
     ,@intBorkerageAccountId as intBorkerageAccountId
     ,@intFutureMarketId AS intFutureMarketId
     ,@intCommodityId AS intCommodityId
     ,'Success'  AS ysnImportStatus
     ,'' AS strComments
	 ,1 as ysnFreezed
     SET @intReconciliationBrokerStatementHeaderId=SCOPE_IDENTITY()
     SET @strStatus = 'Success'

     UPDATE tblRKFutOptTransaction set ysnFreezed=1 
    where intFutureMarketId=@intFutureMarketId and intCommodityId=@intCommodityId and intEntityId = @intBrokerId 
     AND CONVERT(VARCHAR,dtmFilledDate, @ConvertYear) = CONVERT(VARCHAR,@dtmFilledDate, @ConvertYear)  AND intBrokerageAccountId= case when isnull(@intBorkerageAccountId,0)=0 then intBrokerageAccountId else @intBorkerageAccountId end 
     and intInstrumentTypeId=1  and intSelectedInstrumentTypeId = 1 and isnull(ysnFreezed,0) = 0

END


INSERT INTO tblRKReconciliationBrokerStatement
(intReconciliationBrokerStatementHeaderId,intConcurrencyId,strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,dtmFilledDate,strErrMessage)
SELECT distinct @intReconciliationBrokerStatementHeaderId ,1 AS intConcurrencyId,strName,strAccountNumber,strFutMarketName,strCommodityCode,strBuySell,intNoOfContract,strFutureMonth,dblPrice,convert(datetime,(convert(varchar, replace(dtmFilledDate,'-','/'), @ConvertYear)),@ConvertYear) , strStatus
FROM @tblFinalRec

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