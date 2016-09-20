CREATE PROC uspRKSettlementPriceImport
AS
BEGIN TRY

DECLARE @ErrMsg nvarchar(Max)

DECLARE @strDateTimeFormat nvarchar(50)
DECLARE @ConvertYear int

SELECT @strDateTimeFormat = strDateTimeFormat FROM tblRKCompanyPreference

IF (@strDateTimeFormat = 'MM DD YYYY HH:MI' OR @strDateTimeFormat ='YYYY MM DD HH:MI')
SELECT @ConvertYear=101
ELSE IF (@strDateTimeFormat = 'DD MM YYYY HH:MI' OR @strDateTimeFormat ='YYYY DD MM HH:MI')
SELECT @ConvertYear=103


DECLARE @strMarketValidation1 nvarchar(50)
DECLARE @dtmPriceDate1 nvarchar(50)

IF (SELECT COUNT(*) FROM (SELECT DISTINCT (LTRIM(RTRIM(strFutureMarket))) strFutureMarket 
							FROM tblRKSettlementPriceImport)t) > 1
BEGIN
 RAISERROR('Upload file should contain data for only one market.',16,1)
END
ELSE
BEGIN

	SELECT TOP 1 @strMarketValidation1=ltrim(rtrim(strFutureMarket)) FROM tblRKSettlementPriceImport
	
	if Not Exists(select * from tblRKFutureMarket where strFutMarketName=@strMarketValidation1) 
	BEGIN
		RAISERROR('Invalid market.',16,1)
	END
END

IF (SELECT COUNT(*) FROM (SELECT DISTINCT (LTRIM(RTRIM(dtmPriceDate))) dtmPriceDate 
							FROM tblRKSettlementPriceImport)t) > 1							
BEGIN
 RAISERROR('Upload file should contain data for only one date/time combination.',16,1)
END

SELECT TOP 1  @dtmPriceDate1=(LTRIM(RTRIM(dtmPriceDate)))  FROM tblRKSettlementPriceImport

If 	EXISTS(SELECT * FROM tblRKFuturesSettlementPrice sp
			JOIN tblRKFutureMarket fm on sp.intFutureMarketId=fm.intFutureMarketId 
			WHERE fm.strFutMarketName= @strMarketValidation1 
			AND convert(datetime,dtmPriceDate,@ConvertYear)=convert(datetime,@dtmPriceDate1,@ConvertYear))
			BEGIN
			RAISERROR('A record already exists for this market and date/time.',16,1)
			END

BEGIN TRAN

IF NOT EXISTS(SELECT intImportSettlementPriceId FROM tblRKSettlementPriceImport_ErrLog)
BEGIN
	DECLARE @strMarketValidation nvarchar(50)
	DECLARE @strSettlementDate nvarchar(50)
	DECLARE @intFutureMarketId int
	DECLARE @intFutureSettlementPriceId int = null

	SELECT TOP 1 @strMarketValidation=ltrim(rtrim(strFutureMarket)),@strSettlementDate=convert(datetime,dtmPriceDate,@ConvertYear) FROM tblRKSettlementPriceImport
	SELECT @intFutureMarketId=intFutureMarketId from tblRKFutureMarket where strFutMarketName=@strMarketValidation

	INSERT INTO tblRKFuturesSettlementPrice VALUES(@intFutureMarketId,@strSettlementDate,1)
	SELECT @intFutureSettlementPriceId = scope_Identity()
-- Insert Futures Month settlement Price	
	INSERT INTO tblRKFutSettlementPriceMarketMap (intConcurrencyId,intFutureSettlementPriceId,intFutureMonthId,dblLastSettle,dblLow,dblHigh,strComments)
	SELECT 1,@intFutureSettlementPriceId,intFutureMonthId,dblLastSettle,dblLow,dblHigh,strFutComments FROM tblRKSettlementPriceImport i
	JOIN tblRKFuturesMonth fm on fm.strFutureMonth=replace(i.strFutureMonth ,'-',' ')
	WHERE strInstrumentType='Futures' and intFutureMarketId=@intFutureMarketId

	-- Insert Options Month settlement Price	
	INSERT INTO tblRKOptSettlementPriceMarketMap (intConcurrencyId,intFutureSettlementPriceId,intOptionMonthId,dblStrike,intTypeId,dblSettle,dblDelta,strComments)
	SELECT 1,@intFutureSettlementPriceId,intOptionMonthId,dblStrike,CASE WHEN strType = 'Put' THEN 1 
																		WHEN strType = 'Call' THEN 2 ELSE 0 END,
			  dblSettle,dblDelta,strFutComments FROM tblRKSettlementPriceImport i
	JOIN tblRKOptionsMonth fm on fm.strOptionMonth=replace(i.strFutureMonth ,'-',' ') 
	WHERE strInstrumentType like 'Opt%' and intFutureMarketId=@intFutureMarketId

END

COMMIT TRAN
SELECT  intImportSettlementPriceErrLogId,intImportSettlementPriceId,dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,dblLow,
		dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,strErrorMsg,intConcurrencyId FROM tblRKSettlementPriceImport_ErrLog

DELETE FROM tblRKSettlementPriceImport


END TRY
BEGIN CATCH
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION    
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
End Catch	