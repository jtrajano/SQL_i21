CREATE PROCEDURE [dbo].[uspRKSettlementPriceImportValidate]

AS

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		, @PreviousErrMsg NVARCHAR(MAX)
		, @mRowNumber INT
		, @strFutureMarket NVARCHAR(50)
		, @strInstrumentType NVARCHAR(50)
		, @dtmPriceDate DATETIME
		, @strFutureMonth NVARCHAR(50)
		, @dblLastSettle NUMERIC(24, 10)
		, @dblLow NUMERIC(24, 10)
		, @dblHigh NUMERIC(24, 10)
		, @strFutComments NVARCHAR(100)
		, @strOptionMonth NVARCHAR(100)
		, @dblStrike NUMERIC(24, 10)
		, @strType NVARCHAR(100)
		, @dblSettle NUMERIC(24, 10)
		, @dblDelta NUMERIC(24, 10)
		, @intFutureMarketId INT
		, @strDateTimeFormat NVARCHAR(50)
		, @ConvertYear INT

	DECLARE @ErrLogs AS TABLE (intImportSettlementPriceErrLogId INT IDENTITY
		, intImportSettlementPriceId INT
		, strPriceDate NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, strFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, strInstrumentType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, strFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, dblLastSettle NUMERIC(24, 10) NULL
		, dblLow NUMERIC(24, 10) NULL
		, dblHigh NUMERIC(24, 10) NULL
		, strFutComments NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, strOptionMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, dblStrike NUMERIC(24, 10) NULL
		, strType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		, dblSettle NUMERIC(24, 10) NULL
		, dblDelta NUMERIC(24, 10)
		, strErrorMsg NVARCHAR(max) COLLATE Latin1_General_CI_AS NULL
		, intConcurrencyId INT NOT NULL)

	SELECT @strDateTimeFormat = strDateTimeFormat FROM tblRKCompanyPreference
	
	IF (ISNULL(@strDateTimeFormat, '') = '')
	BEGIN
		INSERT INTO @ErrLogs(intImportSettlementPriceId, strErrorMsg, intConcurrencyId)
		VALUES (1, 'There is no setup for DateTime Format in Company Configuration - Risk Management tab.', 1)
		
		SELECT intImportSettlementPriceErrLogId
			, intImportSettlementPriceId
			, strPriceDate
			, strFutureMarket
			, strInstrumentType
			, strFutureMonth
			, dblLastSettle
			, dblLow
			, dblHigh
			, strFutComments
			, strOptionMonth
			, dblStrike
			, strType
			, dblSettle
			, dblDelta
			, strErrorMsg
			, intConcurrencyId
		FROM @ErrLogs
		
		GOTO EXIT_ROUTINE
	END
	
	IF (@strDateTimeFormat = 'MM DD YYYY HH:MI' OR @strDateTimeFormat ='YYYY MM DD HH:MI')
		SELECT @ConvertYear = 101
	ELSE IF (@strDateTimeFormat = 'DD MM YYYY HH:MI' OR @strDateTimeFormat ='YYYY DD MM HH:MI')
		SELECT @ConvertYear = 103
		
	SELECT @mRowNumber = MIN(intImportSettlementPriceId) FROM tblRKSettlementPriceImport
	
	DECLARE @counter INT = 1
	WHILE @mRowNumber > 0
	BEGIN
		SELECT @PreviousErrMsg = ''
			, @ErrMsg = ''
			, @strFutureMarket = NULL
			, @strInstrumentType = NULL
			, @dtmPriceDate = NULL
			, @strFutureMonth = NULL
			, @dblLastSettle = NULL
			, @dblLow = NULL
			, @dblHigh = NULL
			, @strFutComments = NULL
			, @strOptionMonth = NULL
			, @dblStrike = NULL
			, @strType = NULL
			, @dblSettle = NULL
			, @dblDelta = NULL
			, @counter = @counter + 1
		
		SELECT @strFutureMarket = strFutureMarket
			, @strInstrumentType = strInstrumentType
			, @strFutureMonth = strFutureMonth
			, @dblLastSettle = dblLastSettle
			, @dblLow = dblLow
			, @dblHigh = dblHigh
			, @strFutComments = strFutComments
			, @strOptionMonth = strOptionMonth
			, @dblStrike = dblStrike
			, @strType = strType
			, @dblSettle = dblSettle
			, @dblDelta = dblDelta
		FROM tblRKSettlementPriceImport
		WHERE intImportSettlementPriceId = @mRowNumber
		
		IF(ISNULL(LTRIM(RTRIM(@strFutureMarket)), '') = '')
		BEGIN
			SET @ErrMsg = ' Future Market is required.'
		END
		
		IF (SELECT COUNT(*) FROM (SELECT DISTINCT (LTRIM(RTRIM(strPriceDate))) dtmPriceDate FROM tblRKSettlementPriceImport where strFutureMarket=@strFutureMarket)t) > 1							
		BEGIN
			IF NOT EXISTS(SELECT * FROM @ErrLogs where strErrorMsg='There are two or more Date/Time combination for Futures Market: ' + @strFutureMarket)
			BEGIN
				INSERT INTO @ErrLogs(intImportSettlementPriceId, strErrorMsg, intConcurrencyId)
				VALUES (1, 'There are two or more Date/Time combination for Futures Market: ' + @strFutureMarket, 1)
			END
		END
		
		IF EXISTS (SELECT DISTINCT intImportSettlementPriceId, COUNT(*) FROM tblRKSettlementPriceImport
					WHERE strFutureMarket = @strFutureMarket AND strFutureMonth = @strFutureMonth AND ISNULL(strFutureMonth, '') <> '' AND strInstrumentType = 'Futures'
					GROUP BY intImportSettlementPriceId HAVING COUNT(*) > 1)
		BEGIN
			IF NOT EXISTS(SELECT * FROM @ErrLogs where strErrorMsg='Multiple entries are available for ' + @strFutureMarket +' - ' + @strFutureMonth +'. Please correct and try again.' )
			BEGIN
				INSERT INTO @ErrLogs(intImportSettlementPriceId,strErrorMsg,intConcurrencyId)
				VALUES (1,'Multiple entries are available for ' + @strFutureMarket +' - ' + @strFutureMonth +'. Please correct and try again.',1)
			END
		END
		
		IF EXISTS (SELECT DISTINCT intImportSettlementPriceId, COUNT(*) FROM tblRKSettlementPriceImport
					WHERE strFutureMarket = @strFutureMarket AND strFutureMonth = @strFutureMonth AND ISNULL(strFutureMonth,'') <> '' AND strInstrumentType = 'Options' AND dblStrike = @dblStrike
					GROUP BY intImportSettlementPriceId HAVING COUNT(*) > 1)
		BEGIN
			IF NOT EXISTS(SELECT * FROM @ErrLogs where strErrorMsg='Multiple entries are available for ' + @strFutureMarket +' - ' + @strFutureMonth +'  - ' + convert(nvarchar,convert(numeric(18,4), @dblStrike)) +'. Please correct and try again.' )
			BEGIN
				INSERT INTO @ErrLogs(intImportSettlementPriceId,strErrorMsg,intConcurrencyId)
				VALUES (1,'Multiple entries are available for ' + @strFutureMarket +' - ' + @strFutureMonth +'  - ' + convert(nvarchar,convert(numeric(18,4), @dblStrike)) +'. Please correct and try again.',1)
			END
		END
		
		BEGIN TRY
			SELECT @dtmPriceDate = CONVERT(DATETIME, strPriceDate, @ConvertYear)
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
		
		SELECT @intFutureMarketId = intFutureMarketId from tblRKFutureMarket where strFutMarketName = @strFutureMarket
		
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
			ELSE IF NOT EXISTS(SELECT * FROM tblRKFuturesMonth WHERE strFutureMonth=replace(@strFutureMonth,'-',' ') AND intFutureMarketId=@intFutureMarketId)
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
			ELSE IF NOT EXISTS(SELECT * FROM tblRKOptionsMonth WHERE strOptionMonth=replace(@strFutureMonth,'-',' ') AND intFutureMarketId=@intFutureMarketId)
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
			INSERT INTO @ErrLogs (intImportSettlementPriceId
				, strPriceDate
				, strFutureMarket
				, strInstrumentType
				, strFutureMonth
				, dblLastSettle
				, dblLow
				, dblHigh
				, strFutComments
				, strOptionMonth
				, dblStrike
				, strType
				, dblSettle
				, dblDelta
				, strErrorMsg
				, intConcurrencyId)
			SELECT intImportSettlementPriceId
				, strPriceDate
				, strFutureMarket
				, strInstrumentType
				, strFutureMonth
				, dblLastSettle
				, dblLow
				, dblHigh
				, strFutComments
				, strOptionMonth
				, dblStrike
				, strType
				, dblSettle
				, dblDelta
				, 'Error at Line No. '  + Convert(nvarchar(50),@counter) + '. ' + @ErrMsg
				, 1
			FROM tblRKSettlementPriceImport
			WHERE intImportSettlementPriceId = @mRowNumber AND strFutureMarket = @strFutureMarket
		END
		ELSE IF	@dtmPriceDate IS NOT NULL AND EXISTS(SELECT * FROM tblRKFuturesSettlementPrice sp JOIN tblRKFutureMarket fm on sp.intFutureMarketId=fm.intFutureMarketId WHERE fm.strFutMarketName= @strFutureMarket AND convert(datetime,dtmPriceDate,@ConvertYear)=convert(datetime,@dtmPriceDate,@ConvertYear))
		BEGIN
			INSERT INTO @ErrLogs (intImportSettlementPriceId
				, strPriceDate
				, strFutureMarket
				, strInstrumentType
				, strFutureMonth
				, dblLastSettle
				, dblLow
				, dblHigh
				, strFutComments
				, strOptionMonth
				, dblStrike
				, strType
				, dblSettle
				, dblDelta
				, strErrorMsg
				, intConcurrencyId)
			SELECT intImportSettlementPriceId
				, strPriceDate
				, strFutureMarket
				, strInstrumentType
				, strFutureMonth
				, dblLastSettle
				, dblLow
				, dblHigh
				, strFutComments
				, strOptionMonth
				, dblStrike
				, strType
				, dblSettle
				, dblDelta
				, 'This record already exists for this Futures Market AND Price Date/Time.'
				, 1
			FROM tblRKSettlementPriceImport
			WHERE intImportSettlementPriceId = @mRowNumber AND strFutureMarket=@strFutureMarket
		END
		
		SELECT @mRowNumber = MIN(intImportSettlementPriceId) FROM tblRKSettlementPriceImport	WHERE intImportSettlementPriceId > @mRowNumber
	END

	SELECT intImportSettlementPriceErrLogId
		, intImportSettlementPriceId
		, strPriceDate
		, strFutureMarket
		, strInstrumentType
		, strFutureMonth
		, dblLastSettle
		, dblLow
		, dblHigh
		, strFutComments
		, strOptionMonth
		, dblStrike
		, strType
		, dblSettle
		, dblDelta
		, strErrorMsg
		, intConcurrencyId
	FROM @ErrLogs
	ORDER BY intImportSettlementPriceId
END TRY
BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH

EXIT_ROUTINE: