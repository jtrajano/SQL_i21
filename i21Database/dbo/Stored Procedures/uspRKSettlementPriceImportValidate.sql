CREATE PROC [dbo].[uspRKSettlementPriceImportValidate]
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


IF (SELECT COUNT(*) FROM (SELECT DISTINCT (LTRIM(RTRIM(dtmPriceDate))) dtmPriceDate FROM tblRKSettlementPriceImport where strFutureMarket=@strFutureMarket)t) > 1							
BEGIN
	IF NOT EXISTS(SELECT * FROM tblRKSettlementPriceImport_ErrLog where strErrorMsg='There are two or more Date/Time combination for Futures Market: ' + @strFutureMarket)
	BEGIN
		INSERT INTO tblRKSettlementPriceImport_ErrLog(intImportSettlementPriceId,strErrorMsg,intConcurrencyId)
		VALUES (1,'There are two or more Date/Time combination for Futures Market: ' + @strFutureMarket,1)
	END
END


BEGIN TRY	
	SELECT  @dtmPriceDate=convert(datetime,dtmPriceDate,@ConvertYear) 
	FROM tblRKSettlementPriceImport WHERE intImportSettlementPriceId = @mRowNumber

END TRY
BEGIN CATCH

	--INSERT INTO tblRKSettlementPriceImport_ErrLog(intImportSettlementPriceId,dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,
	--																  dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,strErrorMsg,intConcurrencyId)
	--					SELECT intImportSettlementPriceId,dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,
	--															  dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,'Error at Line No. '  + Convert(nvarchar(50),@counter) + '. Invalid Price Date/Time.',1
	--					FROM  tblRKSettlementPriceImport WHERE intImportSettlementPriceId = @mRowNumber and strFutureMarket=@strFutureMarket


	SET @ErrMsg = ' Invalid Price Date/Time.'
	SET @dtmPriceDate = NULL
END CATCH

IF NOT EXISTS(SELECT * FROM tblRKFutureMarket WHERE strFutMarketName= @strFutureMarket)
BEGIN
	--IF NOT EXISTS(SELECT * FROM tblRKSettlementPriceImport_ErrLog where strFutureMarket=@strFutureMarket)
		--BEGIN
			--INSERT INTO tblRKSettlementPriceImport_ErrLog(intImportSettlementPriceId,dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,
			--												dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,strErrorMsg,intConcurrencyId)
			--SELECT intImportSettlementPriceId,dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,
			--											dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,'Error at Line No. '  + Convert(nvarchar(50),@counter) + '. Invalid Market Name.',1
			--FROM  tblRKSettlementPriceImport WHERE intImportSettlementPriceId = @mRowNumber and strFutureMarket=@strFutureMarket
		--END
		--ELSE
		--BEGIN					
		--	SELECT @PreviousErrMsg=strErrorMsg from tblRKSettlementPriceImport_ErrLog WHERE intImportSettlementPriceId = @mRowNumber  and strFutureMarket=@strFutureMarket
		--	UPDATE tblRKSettlementPriceImport_ErrLog set strErrorMsg=@PreviousErrMsg+'Invalid market name.' WHERE intImportSettlementPriceId = @mRowNumber 
		--		and strFutureMarket=@strFutureMarket
		--END

		SET @ErrMsg = @ErrMsg + ' Invalid Futures Market.'
END

	SELECT @intFutureMarketId=intFutureMarketId from tblRKFutureMarket where strFutMarketName=@strFutureMarket

	
	IF @strInstrumentType='Futures'
	BEGIN	

		IF NOT EXISTS(SELECT * FROM tblRKFuturesMonth WHERE strFutureMonth=replace(@strFutureMonth,'-',' ') and intFutureMarketId=@intFutureMarketId)
		BEGIN
			--IF NOT EXISTS(SELECT * FROM tblRKSettlementPriceImport_ErrLog where intImportSettlementPriceId=@mRowNumber and strFutureMarket=@strFutureMarket)
			--	BEGIN
			--		INSERT INTO tblRKSettlementPriceImport_ErrLog(intImportSettlementPriceId,dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,
			--													  dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,strErrorMsg,intConcurrencyId)
			--		SELECT intImportSettlementPriceId,dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,
			--												  dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,'Invalid Future Month.',1
			--		FROM  tblRKSettlementPriceImport WHERE intImportSettlementPriceId = @mRowNumber and strInstrumentType='Futures' and strFutureMarket=@strFutureMarket
			--	END
			--	ELSE
			--	BEGIN					
			--		SELECT @PreviousErrMsg=strErrorMsg from tblRKSettlementPriceImport_ErrLog WHERE intImportSettlementPriceId = @mRowNumber  and strFutureMarket=@strFutureMarket
			--		UPDATE tblRKSettlementPriceImport_ErrLog set strErrorMsg=@PreviousErrMsg+'Invalid Future Month.' WHERE intImportSettlementPriceId = @mRowNumber 
			--			and strFutureMarket=@strFutureMarket
			--	END

			SET @ErrMsg = @ErrMsg + ' Invalid Futures Month.'
		END
	END

	ELSE IF @strInstrumentType='Options'
	BEGIN
		
	IF NOT EXISTS(SELECT * FROM tblRKOptionsMonth WHERE strOptionMonth=replace(@strFutureMonth,'-',' ') and intFutureMarketId=@intFutureMarketId)
		BEGIN

			--IF NOT EXISTS(SELECT * FROM tblRKSettlementPriceImport_ErrLog where intImportSettlementPriceId=@mRowNumber AND strFutureMarket=@strFutureMarket)
			--	BEGIN
			--		INSERT INTO tblRKSettlementPriceImport_ErrLog(intImportSettlementPriceId,dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,
			--													  dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,strErrorMsg,intConcurrencyId)
			--		SELECT intImportSettlementPriceId,dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,
			--												  dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,'Invalid Option Month.',1
			--		FROM  tblRKSettlementPriceImport WHERE intImportSettlementPriceId = @mRowNumber and strInstrumentType='Options' AND strFutureMarket=@strFutureMarket
			--	END
			--	ELSE
			--	BEGIN					
			--		SELECT @PreviousErrMsg=strErrorMsg from tblRKSettlementPriceImport_ErrLog WHERE intImportSettlementPriceId = @mRowNumber  
			--		UPDATE tblRKSettlementPriceImport_ErrLog set strErrorMsg=@PreviousErrMsg+'Invalid Option Month.' WHERE intImportSettlementPriceId = @mRowNumber
			--							AND strFutureMarket=@strFutureMarket
			--	END

			SET @ErrMsg = @ErrMsg + ' Invalid Option Month.'
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
