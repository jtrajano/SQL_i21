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

IF (@strDateTimeFormat = 'MM DD YYYY HH:MI' OR @strDateTimeFormat ='YYYY MM DD HH:MI')
SELECT @ConvertYear=101
ELSE IF (@strDateTimeFormat = 'DD MM YYYY HH:MI' OR @strDateTimeFormat ='YYYY DD MM HH:MI')
SELECT @ConvertYear=103

SELECT @mRowNumber = MIN(intImportSettlementPriceId) FROM tblRKSettlementPriceImport
WHILE @mRowNumber > 0
	BEGIN
	SELECT @PreviousErrMsg=''

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
	

		SELECT @strFutureMarket =strFutureMarket,
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

BEGIN TRY	
	SELECT  @dtmPriceDate=convert(datetime,dtmPriceDate,@ConvertYear) 
	FROM tblRKSettlementPriceImport WHERE intImportSettlementPriceId = @mRowNumber

END TRY
BEGIN CATCH

	INSERT INTO tblRKSettlementPriceImport_ErrLog(intImportSettlementPriceId,dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,
																	  dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,strErrorMsg,intConcurrencyId)
						SELECT intImportSettlementPriceId,null,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,
																  dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,'Invalid price date/time.',1
						FROM  tblRKSettlementPriceImport WHERE intImportSettlementPriceId = @mRowNumber and strFutureMarket=@strFutureMarket

	SET @dtmPriceDate = NULL
END CATCH


IF NOT EXISTS(SELECT * FROM tblRKFutureMarket WHERE strFutMarketName= @strFutureMarket)
BEGIN
	IF NOT EXISTS(SELECT * FROM tblRKSettlementPriceImport_ErrLog where strFutureMarket=@strFutureMarket)
		BEGIN
			INSERT INTO tblRKSettlementPriceImport_ErrLog(intImportSettlementPriceId,dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,
															dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,strErrorMsg,intConcurrencyId)
			SELECT intImportSettlementPriceId,@dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,
														dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,'Invalid market name.',1
			FROM  tblRKSettlementPriceImport WHERE intImportSettlementPriceId = @mRowNumber and strFutureMarket=@strFutureMarket
		END
		ELSE
		BEGIN					
			SELECT @PreviousErrMsg=strErrorMsg from tblRKSettlementPriceImport_ErrLog WHERE intImportSettlementPriceId = @mRowNumber  and strFutureMarket=@strFutureMarket
			UPDATE tblRKSettlementPriceImport_ErrLog set strErrorMsg=@PreviousErrMsg+'Invalid market name.' WHERE intImportSettlementPriceId = @mRowNumber 
				and strFutureMarket=@strFutureMarket
		END
END

	SELECT @intFutureMarketId=intFutureMarketId from tblRKFutureMarket where strFutMarketName=@strFutureMarket

	
	IF @strInstrumentType='Futures'
	BEGIN	

		IF NOT EXISTS(SELECT * FROM tblRKFuturesMonth WHERE strFutureMonth=replace(@strFutureMonth,'-',' ') and intFutureMarketId=@intFutureMarketId)
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblRKSettlementPriceImport_ErrLog where intImportSettlementPriceId=@mRowNumber and strFutureMarket=@strFutureMarket)
				BEGIN
					INSERT INTO tblRKSettlementPriceImport_ErrLog(intImportSettlementPriceId,dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,
																  dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,strErrorMsg,intConcurrencyId)
					SELECT intImportSettlementPriceId,@dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,
															  dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,'Invalid Future Month.',1
					FROM  tblRKSettlementPriceImport WHERE intImportSettlementPriceId = @mRowNumber and strInstrumentType='Futures' and strFutureMarket=@strFutureMarket
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg from tblRKSettlementPriceImport_ErrLog WHERE intImportSettlementPriceId = @mRowNumber  and strFutureMarket=@strFutureMarket
					UPDATE tblRKSettlementPriceImport_ErrLog set strErrorMsg=@PreviousErrMsg+'Invalid Future Month.' WHERE intImportSettlementPriceId = @mRowNumber 
						and strFutureMarket=@strFutureMarket
				END
		END
	END

	ELSE IF @strInstrumentType='Options'
	BEGIN
		
	IF NOT EXISTS(SELECT * FROM tblRKOptionsMonth WHERE strOptionMonth=replace(@strFutureMonth,'-',' ') and intFutureMarketId=@intFutureMarketId)
		BEGIN

			IF NOT EXISTS(SELECT * FROM tblRKSettlementPriceImport_ErrLog where intImportSettlementPriceId=@mRowNumber AND strFutureMarket=@strFutureMarket)
				BEGIN
					INSERT INTO tblRKSettlementPriceImport_ErrLog(intImportSettlementPriceId,dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,
																  dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,strErrorMsg,intConcurrencyId)
					SELECT intImportSettlementPriceId,@dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle,
															  dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,dblSettle,dblDelta,'Invalid Option Month.',1
					FROM  tblRKSettlementPriceImport WHERE intImportSettlementPriceId = @mRowNumber and strInstrumentType='Options' AND strFutureMarket=@strFutureMarket
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg from tblRKSettlementPriceImport_ErrLog WHERE intImportSettlementPriceId = @mRowNumber  
					UPDATE tblRKSettlementPriceImport_ErrLog set strErrorMsg=@PreviousErrMsg+'Invalid Option Month.' WHERE intImportSettlementPriceId = @mRowNumber
										AND strFutureMarket=@strFutureMarket
				END
		END
	END

	
SELECT @mRowNumber = MIN(intImportSettlementPriceId)	FROM tblRKSettlementPriceImport	WHERE intImportSettlementPriceId > @mRowNumber
END

SELECT  intImportSettlementPriceErrLogId,intImportSettlementPriceId,@dtmPriceDate dtmPriceDate,strFutureMarket,strInstrumentType,strFutureMonth,dblLastSettle, dblLow,dblHigh,strFutComments,strOptionMonth,dblStrike,strType,
		dblSettle,dblDelta,strErrorMsg,intConcurrencyId  FROM tblRKSettlementPriceImport_ErrLog

DELETE FROM tblRKSettlementPriceImport_ErrLog
END TRY
BEGIN CATCH
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
End Catch