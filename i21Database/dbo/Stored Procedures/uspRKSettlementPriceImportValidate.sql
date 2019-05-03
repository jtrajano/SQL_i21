﻿CREATE PROC [dbo].[uspRKSettlementPriceImportValidate]
AS
BEGIN TRY

DECLARE @ErrMsg nvarchar(Max)
DECLARE @PreviousErrMsg nvarchar(Max)
DECLARE @mRowNumber INT
DECLARE @strFutureMarket NVARCHAR(50)
DECLARE @strInstrumentType NVARCHAR(50)
DECLARE @dtmPriceDate datetime
DECLARE @strFutureMonth NVARCHAR(50)
DECLARE @dblLastSettle decimal(24,10)
DECLARE @dblLow decimal(24,10)
DECLARE @dblHigh decimal(24,10)
DECLARE @strFutComments NVARCHAR(100)
DECLARE @strOptionMonth NVARCHAR(100)
DECLARE @dblStrike decimal(24,10)
DECLARE @strType NVARCHAR(100)
DECLARE @dblSettle decimal(24,10)
DECLARE @dblDelta decimal(24,10)
DECLARE @intFutureMarketId int
DECLARE @strDateTimeFormat nvarchar(50)
DECLARE @ConvertYear int

SELECT @strDateTimeFormat = strDateTimeFormat FROM tblRKCompanyPreference

IF(ISNULL(@strDateTimeFormat,'') = '')
BEGIN
INSERT INTO tblRKSettlementPriceImport_ErrLog(intImportSettlementPriceId,strErrorMsg,intConcurrencyId)
VALUES (1,'There is no setup for DateTime Format in Company Configuration - Risk Management tab.',1)
SELECT  intImportSettlementPriceErrLogId,intImportSettlementPriceId,@dtmPriceDate dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle, dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,
		dblSettle,dblDelta,strErrorMsg,intConcurrencyId  FROM tblRKSettlementPriceImport_ErrLog

DELETE FROM tblRKSettlementPriceImport_ErrLog
GOTO EXIT_ROUTINE
END


IF (@strDateTimeFormat = 'MM DD YYYY HH:MI' OR @strDateTimeFormat ='YYYY MM DD HH:MI')
SELECT @ConvertYear=101
ELSE IF (@strDateTimeFormat = 'DD MM YYYY HH:MI' OR @strDateTimeFormat ='YYYY DD MM HH:MI')
SELECT @ConvertYear=103

SELECT @mRowNumber = MIN(intImportSettlementPriceId) FROM tblRKSettlementPriceImport

DECLARE @counter INT = 1
WHILE @mRowNumber > 0
	BEGIN
	SELECT @PreviousErrMsg=''
	SET @ErrMsg = ''

	SET @strFutureMarket = null
	SET @strInstrumentType = null
	SET @dtmPriceDate = null
	SET @strFutureMonth = null
	SET @dblLastSettle = null
	SET @dblLow = null
	SET @dblHigh = null
	SET @strFutComments = null
	SET @strOptionMonth = null
	SET @dblStrike = null
	SET @strType = null
	SET @dblSettle = null
	SET @dblDelta = null

	SET @counter = @counter + 1
	

		SELECT  @strFutureMarket =strFutureMarket,
				@strInstrumentType=strInstrumentType,				
				@strFutureMonth =strFutureMonth,
				@dblLastSettle =dblLastSettle,
				@dblLow =dblLow,
				@dblHigh =dblHigh,
				@strFutComments =strFutComments,
				@strOptionMonth =strOptionMonth,
				@dblStrike =dblStrike,
				@strType =strType,
				@dblSettle =dblSettle,
				@dblDelta =dblDelta
		FROM tblRKSettlementPriceImport WHERE intImportSettlementPriceId = @mRowNumber

IF(ISNULL(LTRIM(RTRIM(@strFutureMarket)), '') = '')
BEGIN
	SET @ErrMsg = ' Future Market is required.'
END

IF (SELECT COUNT(*) FROM (SELECT DISTINCT (LTRIM(RTRIM(dtmPriceDate))) dtmPriceDate FROM tblRKSettlementPriceImport where strFutureMarket=@strFutureMarket)t) > 1							
BEGIN
	IF NOT EXISTS(SELECT * FROM tblRKSettlementPriceImport_ErrLog where strErrorMsg='There are two or more Date/Time combination for Futures Market: ' + @strFutureMarket)
	BEGIN
		INSERT INTO tblRKSettlementPriceImport_ErrLog(intImportSettlementPriceId,strErrorMsg,intConcurrencyId)
		VALUES (1,'There are two or more Date/Time combination for Futures Market: ' + @strFutureMarket,1)
	END
END

IF (SELECT COUNT(*) FROM (SELECT DISTINCT intImportSettlementPriceId
							FROM tblRKSettlementPriceImport where strFutureMarket=@strFutureMarket 
							AND strFutureMonth=@strFutureMonth and isnull(strFutureMonth,'') <> '' and strInstrumentType='Futures')t) > 1							
BEGIN
	IF NOT EXISTS(SELECT * FROM tblRKSettlementPriceImport_ErrLog where strErrorMsg='Multiple entries are available for ' + @strFutureMarket +' - ' + @strFutureMonth +'. Please correct and try again.' )
	BEGIN
		INSERT INTO tblRKSettlementPriceImport_ErrLog(intImportSettlementPriceId,strErrorMsg,intConcurrencyId)
		VALUES (1,'Multiple entries are available for ' + @strFutureMarket +' - ' + @strFutureMonth +'. Please correct and try again.',1)
	END
END


IF (SELECT COUNT(*) FROM (SELECT DISTINCT intImportSettlementPriceId
							FROM tblRKSettlementPriceImport where strFutureMarket=@strFutureMarket 
							AND strFutureMonth=@strFutureMonth and isnull(strFutureMonth,'') <> '' 
							AND strInstrumentType='Options' AND dblStrike=@dblStrike)t) > 1							
BEGIN
	IF NOT EXISTS(SELECT * FROM tblRKSettlementPriceImport_ErrLog where strErrorMsg='Multiple entries are available for ' + @strFutureMarket +' - ' + @strFutureMonth +'  - ' + convert(nvarchar,convert(numeric(18,4), @dblStrike)) +'. Please correct and try again.' )
	BEGIN
		INSERT INTO tblRKSettlementPriceImport_ErrLog(intImportSettlementPriceId,strErrorMsg,intConcurrencyId)
		VALUES (1,'Multiple entries are available for ' + @strFutureMarket +' - ' + @strFutureMonth +'  - ' + convert(nvarchar,convert(numeric(18,4), @dblStrike)) +'. Please correct and try again.',1)
	END
END

BEGIN TRY	
	SELECT  @dtmPriceDate=convert(datetime,dtmPriceDate,@ConvertYear) 
	FROM tblRKSettlementPriceImport WHERE intImportSettlementPriceId = @mRowNumber

END TRY
BEGIN CATCH

	SET @ErrMsg = ' Invalid Price Date/Time, format should be in ' + @strDateTimeFormat +' Format.'
	SET @dtmPriceDate = NULL
END CATCH

IF NOT EXISTS(SELECT * FROM tblRKFutureMarket WHERE strFutMarketName= @strFutureMarket) AND ISNULL(@strFutureMarket,'') <> ''
BEGIN
		SET @ErrMsg = @ErrMsg + ' Futures Market does not exist in the system.'
END
	
	SELECT @intFutureMarketId=intFutureMarketId from tblRKFutureMarket where strFutMarketName=@strFutureMarket

	IF(@strInstrumentType NOT IN('Futures','Options'))
	BEGIN
		SET @ErrMsg = @ErrMsg + ' Instrument Type is case sensitive it must be in exact word Futures or Options.'
	END

	IF @strInstrumentType='Futures' AND ISNULL(@intFutureMarketId,0) <> 0
	BEGIN	
		IF(ISNULL(@strFutureMonth,'') <> '' AND PATINDEX('[A-Z][a-z][a-z]-[0-9][0-9]',RTRIM(LTRIM(@strFutureMonth))) = 0)
		BEGIN
			SET @ErrMsg = @ErrMsg + ' Invalid Futures Month, format should be in mmm-yy (Jan-18).'
		END
		ELSE IF NOT EXISTS(SELECT * FROM tblRKFuturesMonth WHERE strFutureMonth=replace(@strFutureMonth,'-',' ') and intFutureMarketId=@intFutureMarketId)
		BEGIN
			SET @ErrMsg = @ErrMsg + ' Futures Month does not exist for Future Market: ' + @strFutureMarket + '.'
		END
	END

	ELSE IF @strInstrumentType='Options' AND ISNULL(@intFutureMarketId,0) <> 0
	BEGIN
		IF(ISNULL(@strFutureMonth,'') <> '' AND PATINDEX('[A-Z][a-z][a-z]-[0-9][0-9]',RTRIM(LTRIM(@strFutureMonth))) = 0)
		BEGIN
			SET @ErrMsg = @ErrMsg + ' Invalid Options Month, format should be in mmm-yy (Jan-18).'
		END
		ELSE IF NOT EXISTS(SELECT * FROM tblRKOptionsMonth WHERE strOptionMonth=replace(@strFutureMonth,'-',' ') and intFutureMarketId=@intFutureMarketId)
		BEGIN
			SET @ErrMsg = @ErrMsg + ' Options Month does not exist for Future Market: ' + @strFutureMarket + '.'
		END

		IF(@strType NOT IN('Call', 'Put'))
		BEGIN
			SET @ErrMsg = @ErrMsg + ' Option Type is case sensitive it must be in exact word Put or Call.'
		END

	END

	IF @ErrMsg <> ''
	BEGIN
			INSERT INTO tblRKSettlementPriceImport_ErrLog(
				intImportSettlementPriceId
				,dtmPriceDate
				,strFutureMarket
				,strInstrumentType
				,strFutureMonth
				,dblLastSettle
				,dblLow
				,dblHigh
				,strFutComments
				,strOptionMonth
				,dblStrike
				,strType
				,dblSettle
				,dblDelta
				,strErrorMsg
				,intConcurrencyId)
			SELECT 
				intImportSettlementPriceId
				,dtmPriceDate
				,strFutureMarket
				,strInstrumentType
				,strFutureMonth
				,dblLastSettle
				,dblLow
				,dblHigh
				,strFutComments
				,strOptionMonth
				,dblStrike
				,strType
				,dblSettle
				,dblDelta
				,'Error at Line No. '  + Convert(nvarchar(50),@counter) + '. ' + @ErrMsg
				,1
			FROM  tblRKSettlementPriceImport 
			WHERE intImportSettlementPriceId = @mRowNumber and strFutureMarket=@strFutureMarket
	END
	ELSE IF	@dtmPriceDate IS NOT NULL AND EXISTS(SELECT * FROM tblRKFuturesSettlementPrice sp JOIN tblRKFutureMarket fm on sp.intFutureMarketId=fm.intFutureMarketId WHERE fm.strFutMarketName= @strFutureMarket AND convert(datetime,dtmPriceDate,@ConvertYear)=convert(datetime,@dtmPriceDate,@ConvertYear))
	BEGIN

		INSERT INTO tblRKSettlementPriceImport_ErrLog(
					intImportSettlementPriceId
					,dtmPriceDate
					,strFutureMarket
					,strInstrumentType
					,strFutureMonth
					,dblLastSettle
					,dblLow
					,dblHigh
					,strFutComments
					,strOptionMonth
					,dblStrike
					,strType
					,dblSettle
					,dblDelta
					,strErrorMsg
					,intConcurrencyId)
				SELECT 
					intImportSettlementPriceId
					,dtmPriceDate
					,strFutureMarket
					,strInstrumentType
					,strFutureMonth
					,dblLastSettle
					,dblLow
					,dblHigh
					,strFutComments
					,strOptionMonth
					,dblStrike
					,strType
					,dblSettle
					,dblDelta
					,'This record already exists for this Futures Market and Price Date/Time.'
					,1
				FROM  tblRKSettlementPriceImport 
				WHERE intImportSettlementPriceId = @mRowNumber and strFutureMarket=@strFutureMarket
	END

	
SELECT @mRowNumber = MIN(intImportSettlementPriceId) FROM tblRKSettlementPriceImport	WHERE intImportSettlementPriceId > @mRowNumber
END

SELECT  intImportSettlementPriceErrLogId,intImportSettlementPriceId,dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle, dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,
		dblSettle,dblDelta,strErrorMsg,intConcurrencyId  FROM tblRKSettlementPriceImport_ErrLog ORDER BY intImportSettlementPriceId

DELETE FROM tblRKSettlementPriceImport_ErrLog
END TRY
BEGIN CATCH
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
End Catch


EXIT_ROUTINE: