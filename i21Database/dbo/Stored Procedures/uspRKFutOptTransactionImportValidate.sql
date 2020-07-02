CREATE PROCEDURE uspRKFutOptTransactionImportValidate

AS

BEGIN TRY
	DECLARE @tblRKFutOptTransactionHeaderId INT
		, @ErrMsg NVARCHAR(MAX)
		, @strRequiredFieldError NVARCHAR(MAX)
		, @mRowNumber INT
		, @strName NVARCHAR(50)
		, @strAccountNumber NVARCHAR(50)
		, @strFutMarketName NVARCHAR(100)
		, @strInstrumentType NVARCHAR(20)
		, @strCommodityCode NVARCHAR(100)
		, @strLocationName NVARCHAR(100)
		, @strSalespersonId NVARCHAR(100)
		, @strCurrency NVARCHAR(100)
		, @strBuySell NVARCHAR(100)
		, @strBrokerTradeNo NVARCHAR(100)
		, @strFutureMonth NVARCHAR(100)
		, @strOptionMonth NVARCHAR(100)
		, @strOptionType NVARCHAR(100)
		, @strStatus NVARCHAR(100)
		, @dtmFilledDate NVARCHAR(100)
		, @strBook NVARCHAR(100)
		, @strSubBook NVARCHAR(100)
		, @PreviousErrMsg NVARCHAR(MAX)
		, @strCreateDateTime NVARCHAR(100)
		, @strDateTimeFormat NVARCHAR(50)
		, @ConvertYear INT
		, @dblPrice DECIMAL(24, 10) = NULL
		, @dblStrike DECIMAL(24, 10) = NULL
	
	SELECT @strDateTimeFormat = strDateTimeFormat FROM tblRKCompanyPreference

	IF (ISNULL(@strDateTimeFormat, '') = '')
	BEGIN
		INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId, strErrorMsg, intConcurrencyId)
		VALUES (1, 'There is no setup for DateTime Format in Company Configuration - Risk Management tab.', 1)
		
		GOTO EXIT_ROUTINE
	END
	
	IF (SELECT COUNT(ysnOTCOthers)
		FROM (
			SELECT DISTINCT (ISNULL(ysnOTCOthers,0)) ysnOTCOthers FROM tblRKFutOptTransactionImport i
			JOIN tblRKBrokerageAccount b ON b.strAccountNumber = i.strAccountNumber
			JOIN tblEMEntity e ON i.strName = e.strName
		) t) > 1
	BEGIN
		INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId, strErrorMsg, intConcurrencyId)
		VALUES (1, 'File contains mixed instruments.', 1)
		
		GOTO EXIT_ROUTINE
	END
	
	IF (@strDateTimeFormat = 'MM DD YYYY HH:MI' OR @strDateTimeFormat ='YYYY MM DD HH:MI')
		SELECT @ConvertYear = 101
	ELSE IF (@strDateTimeFormat = 'DD MM YYYY HH:MI' OR @strDateTimeFormat ='YYYY DD MM HH:MI')
		SELECT @ConvertYear = 103
	
	SELECT @mRowNumber = MIN(intFutOptTransactionId) FROM tblRKFutOptTransactionImport
	
	DECLARE @counter INT = 1
	WHILE @mRowNumber > 0
	BEGIN
		SELECT @PreviousErrMsg = ''
		SET @ErrMsg = ''
		SET @strRequiredFieldError = ''

		SET @strName = NULL
		SET @strAccountNumber = NULL
		SET @strFutMarketName = NULL
		SET @strInstrumentType = NULL
		SET @strCommodityCode = NULL
		SET @strLocationName = NULL
		SET @strSalespersonId = NULL
		SET @strCurrency = NULL
		SET @strBuySell = NULL
		SET @strFutureMonth = NULL
		SET @strOptionMonth = NULL
		SET @strOptionType = NULL
		SET @strStatus = NULL
		SET @dtmFilledDate = NULL
		SET @strBook = NULL
		SET @strSubBook = NULL
		SET @strCreateDateTime = NULL
		SET @strBrokerTradeNo = NULL
		SET @dblPrice = NULL
		SET @dblStrike = NULL
		SET @counter = @counter + 1
		
		SELECT @strName = strName
			, @strAccountNumber = strAccountNumber
			, @strFutMarketName = strFutMarketName
			, @strInstrumentType = strInstrumentType
			, @strCommodityCode = strCommodityCode
			, @strLocationName = strLocationName
			, @strSalespersonId = strSalespersonId
			, @strCurrency = strCurrency
			, @strBrokerTradeNo = strBrokerTradeNo
			, @strBuySell = strBuySell
			, @strFutureMonth = strFutureMonth
			, @strOptionMonth = strOptionMonth
			, @strOptionType = strOptionType
			, @strStatus = strStatus
			, @dtmFilledDate = strFilledDate
			, @strBook = strBook
			, @strSubBook = strSubBook
			, @strCreateDateTime = strCreateDateTime
			, @dblPrice = dblPrice
			, @dblStrike = dblStrike
		FROM tblRKFutOptTransactionImport
		WHERE intFutOptTransactionId = @mRowNumber
		
		IF(LTRIM(RTRIM(@strInstrumentType)) = '')
		BEGIN
			SET @strRequiredFieldError = 'Instrument Type'
		END

		IF(LTRIM(RTRIM(@strFutMarketName)) = '')
		BEGIN
			SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Futures Market' ELSE 'Futures Market' END
		END

		IF(LTRIM(RTRIM(@strCurrency)) = '')
		BEGIN
			SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Currency' ELSE 'Currency' END
		END

		IF(LTRIM(RTRIM(@strCommodityCode)) = '')
		BEGIN
			SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Commodity' ELSE 'Commodity' END
		END

		IF(LTRIM(RTRIM(@strLocationName)) = '')
		BEGIN
			SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Location' ELSE 'Location' END
		END

		IF(LTRIM(RTRIM(@strName)) = '')
		BEGIN
			SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Broker' ELSE 'Broker' END
		END

		IF(LTRIM(RTRIM(@strAccountNumber)) = '')
		BEGIN
			SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Broker Account' ELSE 'Broker Account' END
		END

		IF(LTRIM(RTRIM(@strSalespersonId)) = '')
		BEGIN
			SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Salesperson' ELSE 'Salesperson' END
		END

		IF(LTRIM(RTRIM(@strBuySell)) = '')
		BEGIN
			SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Buy/Sell' ELSE 'Buy/Sell' END
		END

		IF(LTRIM(RTRIM(@strFutureMonth)) = '')
		BEGIN
			SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Futures Month' ELSE 'Futures Month' END
		END

		IF(@dblPrice IS NULL)
		BEGIN
			SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Price' ELSE 'Price' END
		END

		IF(LTRIM(RTRIM(@strStatus)) = '')
		BEGIN
			SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Status' ELSE 'Status' END
		END

		IF(@dtmFilledDate IS NULL)
		BEGIN
			SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Filled Date' ELSE 'Filled Date' END
		END

		IF(LTRIM(RTRIM(@strInstrumentType)) = 'Options')
		BEGIN
			IF (LTRIM(RTRIM(@strOptionMonth)) = '')
			BEGIN
				SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Option Month' ELSE 'Option Month' END
			END

			IF (LTRIM(RTRIM(@strOptionType)) = '')
			BEGIN
				SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Option Type' ELSE 'Option Type' END
			END

			IF (@dblStrike IS NULL)
			BEGIN
				SET @strRequiredFieldError =  @strRequiredFieldError +  CASE WHEN @strRequiredFieldError <> '' THEN ', Strike' ELSE 'Strike' END
			END
		END

		IF(@strRequiredFieldError <> '')
		BEGIN
			SET @ErrMsg = @strRequiredFieldError + ' is required.'
		END

		IF(LTRIM(RTRIM(@strInstrumentType)) = 'Futures') AND (LTRIM(RTRIM(@strOptionMonth)) <> '' OR LTRIM(RTRIM(@strOptionType)) <> '')
		BEGIN
			SET @ErrMsg = ' Instrument Type: Futures must not have Option Month or Option Type.'
		END
		
		IF @ErrMsg = ''
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblEMEntity WHERE strName = @strName)
			BEGIN
				SET @ErrMsg =  ' Broker does not exists in the system.'
			END
			ELSE
			BEGIN
				DECLARE @intEntityId INT = NULL
				SELECT @intEntityId=intEntityId from tblEMEntity WHERE strName= @strName

				--Broker Trade No already exists in the transactions for the respective Broker
				IF EXISTS(SELECT * FROM tblRKFutOptTransaction WHERE strBrokerTradeNo=@strBrokerTradeNo and intEntityId = @intEntityId and ISNULL(strBrokerTradeNo, '')<>'' and ISNULL(intSelectedInstrumentTypeId,1) in(1,3))
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Broker Trade No already exists.'
				END

				--Broker Trader Number exists in the current batch
				IF EXISTS(SELECT COUNT(strBrokerTradeNo) 
						FROM(
							SELECT strBrokerTradeNo FROM tblRKFutOptTransactionImport 
							WHERE strBrokerTradeNo=@strBrokerTradeNo 
							AND strName=@strName AND ISNULL(strBrokerTradeNo, '')<>'' 
						)T
						HAVING COUNT(strBrokerTradeNo) > 1)
				BEGIN
					SET @ErrMsg = @ErrMsg + ' More than one transaction with the same Broker Trade No exists in the file.'
				END
			END

			IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKFutureMarket fm
						JOIN tblSMCurrency cur ON cur.intCurrencyID = fm.intCurrencyId
						WHERE strFutMarketName = @strFutMarketName AND strCurrency = @strCurrency)
			BEGIN
				SET @ErrMsg = @ErrMsg + ' Currency used must be the Future Market Currency.'
			END

			IF NOT EXISTS(SELECT * FROM tblRKBrokerageAccount WHERE strAccountNumber = @strAccountNumber)
			BEGIN
				SET @ErrMsg = @ErrMsg + ' Broker Account does not exists in the system.'
			END

			IF NOT EXISTS(SELECT * FROM tblRKFutureMarket WHERE strFutMarketName = @strFutMarketName)
			BEGIN
				SET @ErrMsg = @ErrMsg + ' Futures Market does not exists in the system.'
			END
			ELSE
			BEGIN
				DECLARE @NotConfiguredErrMsg NVARCHAR(MAX)
				SET @NotConfiguredErrMsg = ''

				IF EXISTS(SELECT * FROM tblEMEntity WHERE strName = @strName) AND 
					NOT EXISTS(SELECT 1 FROM tblRKFutOptTransactionImport ti
										JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
										JOIN tblRKBrokerageCommission am on  am.intFutureMarketId=fm.intFutureMarketId
										JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=am.intBrokerageAccountId  
										JOIN tblEMEntity em on ba.intEntityId=em.intEntityId and em.strName=ti.strName
										WHERE intFutOptTransactionId =@mRowNumber)
				BEGIN
					SET @NotConfiguredErrMsg = @NotConfiguredErrMsg + ' Broker'
				END
				ELSE 
				BEGIN
					IF EXISTS(SELECT * FROM vyuHDSalesPerson WHERE strName = @strSalespersonId) AND 
					NOT EXISTS(SELECT 1
								FROM tblRKFutOptTransactionImport ti
							JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
							JOIN tblRKBrokerageAccount ba on ba.strAccountNumber=ti.strAccountNumber  
							join tblRKTradersbyBrokersAccountMapping bam on bam.intBrokerageAccountId=ba.intBrokerageAccountId
							join vyuHDSalesPerson sp on sp.intEntityId=bam.intEntitySalespersonId and sp.strName=ti.strSalespersonId
							WHERE intFutOptTransactionId =@mRowNumber)
					AND EXISTS(SELECT * FROM tblEMEntity WHERE strName = @strName) AND 
					NOT EXISTS(SELECT 1 FROM tblRKFutOptTransactionImport ti
										JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
										JOIN tblRKBrokerageCommission am on  am.intFutureMarketId=fm.intFutureMarketId
										JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=am.intBrokerageAccountId  
										JOIN tblEMEntity em on ba.intEntityId=em.intEntityId and em.strName=ti.strName
										WHERE intFutOptTransactionId =@mRowNumber)
					BEGIN
						SET @NotConfiguredErrMsg = @NotConfiguredErrMsg +  CASE WHEN @NotConfiguredErrMsg <> '' THEN ', Salesperson' ELSE ' Salesperson' END
					END
				END

				IF @strInstrumentType IN ('Futures','Options') AND 
					NOT EXISTS(SELECT 1
									FROM tblRKFutOptTransactionImport ti
									JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
									join tblRKBrokerageCommission am on  am.intFutureMarketId=fm.intFutureMarketId
									JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=am.intBrokerageAccountId  
									AND ba.intInstrumentTypeId= case when ba.intInstrumentTypeId= 3 then 3 else
											case when ti.strInstrumentType='Futures' then 1
												when ti.strInstrumentType='Options' then 2 end end
									WHERE intFutOptTransactionId =@mRowNumber)
				BEGIN
					SET @NotConfiguredErrMsg = @NotConfiguredErrMsg +  CASE WHEN @NotConfiguredErrMsg <> '' THEN ', Instrument Type' ELSE ' Instrument Type' END
				END

				IF EXISTS(SELECT * FROM tblICCommodity WHERE strCommodityCode = @strCommodityCode) AND 
					NOT EXISTS(SELECT 1
								FROM tblRKFutOptTransactionImport ti
								JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
								Join tblRKCommodityMarketMapping mm on mm.intFutureMarketId=fm.intFutureMarketId 
								join tblICCommodity c on c.intCommodityId=mm.intCommodityId and c.strCommodityCode=ti.strCommodityCode
								WHERE intFutOptTransactionId =@mRowNumber)
				BEGIN
					SET @NotConfiguredErrMsg = @NotConfiguredErrMsg +  CASE WHEN @NotConfiguredErrMsg <> '' THEN ', Commodity' ELSE ' Commodity' END
				END

				IF EXISTS(SELECT * FROM tblSMCurrency WHERE strCurrency = @strCurrency) AND 
					NOT EXISTS(SELECT 1
						FROM tblRKFutOptTransactionImport ti
						JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName 
						join tblSMCurrency c on c.strCurrency=ti.strCurrency
						WHERE intFutOptTransactionId =@mRowNumber)
				BEGIN
					SET @NotConfiguredErrMsg = @NotConfiguredErrMsg +  CASE WHEN @NotConfiguredErrMsg <> '' THEN ', Currency' ELSE ' Currency' END
				END

				IF @strInstrumentType = 'Futures' AND PATINDEX ('[A-z][a-z][a-z]-[0-9][0-9]',RTRIM(LTRIM(@strFutureMonth))) = 0
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Invalid Futures Month, format should be in mmm-yy (Jan-18).'
				END

				ELSE IF @strInstrumentType = 'Futures' AND 
					NOT EXISTS(SELECT 1
						FROM tblRKFutOptTransactionImport ti
						JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName 
						join tblRKFuturesMonth m on fm.intFutureMarketId=m.intFutureMarketId and m.strFutureMonth=replace(ti.strFutureMonth,'-',' ')
						WHERE intFutOptTransactionId =@mRowNumber)
				BEGIN
					--SET @NotConfiguredErrMsg = @NotConfiguredErrMsg +  CASE WHEN @NotConfiguredErrMsg <> '' THEN ', Futures Month' ELSE ' Futures Month' END
					SET @ErrMsg = 'Futures Month does not exist for Future Market: ' + @strFutMarketName + '.'
				END

				IF @strInstrumentType = 'Options' AND (NOT EXISTS(SELECT * FROM tblRKOptionsMonth WHERE strOptionMonth = REPLACE(@strOptionMonth,'-',' ') COLLATE Latin1_General_CS_AS)
					OR PATINDEX ('[A-z][a-z][a-z]-[0-9][0-9]',RTRIM(LTRIM(@strOptionMonth))) = 0)
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Invalid Options Month, format should be in mmm-yy (Jan-18).'
				END
				ELSE IF @strInstrumentType = 'Options' AND
					NOT EXISTS(SELECT 1
						FROM tblRKFutOptTransactionImport ti
					JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName 
					join tblRKOptionsMonth m on fm.intFutureMarketId=m.intFutureMarketId and m.strOptionMonth=replace(ti.strOptionMonth,'-',' ')
					WHERE intFutOptTransactionId =@mRowNumber)
				BEGIN
					SET @NotConfiguredErrMsg = @NotConfiguredErrMsg +  CASE WHEN @NotConfiguredErrMsg <> '' THEN ', Option Month' ELSE ' Option Month' END
				END

				IF @NotConfiguredErrMsg <> ''
				BEGIN
					SET @ErrMsg = @ErrMsg + @NotConfiguredErrMsg + ' is not configured for Futures Market ' + @strFutMarketName + '.'
				END
			END

			IF @strInstrumentType NOT IN('Futures','Options')
			BEGIN
				SET @ErrMsg = @ErrMsg + ' Instrument Type is case sensitive it must be in exact word Futures or Options.'
			END

			IF NOT EXISTS(SELECT * FROM tblICCommodity WHERE strCommodityCode = @strCommodityCode)
			BEGIN
				SET @ErrMsg = @ErrMsg + ' Commodity Code does not exists in the system.'
			END

			IF NOT EXISTS(SELECT * FROM tblSMCompanyLocation WHERE strLocationName = @strLocationName)
			BEGIN
				SET @ErrMsg = @ErrMsg + ' Location Name does not exists in the system.'
			END

			IF NOT EXISTS(SELECT * FROM vyuHDSalesPerson WHERE strName = @strSalespersonId)
			BEGIN
				SET @ErrMsg = @ErrMsg + ' Salesperson does not exists in the system.'
			END

			IF NOT EXISTS(SELECT * FROM tblSMCurrency WHERE strCurrency = @strCurrency)
			BEGIN
				SET @ErrMsg = @ErrMsg + ' Currency does not exists in the system.'
			END

			IF @strBuySell NOT IN('Buy','Sell')
			BEGIN
				SET @ErrMsg = @ErrMsg + ' Buy/Sell is case sensitive it must be in exact word Buy or Sell.'
			END

			IF @strInstrumentType = 'Options' AND @strOptionType NOT IN('Call','Put')
			BEGIN
				SET @ErrMsg = @ErrMsg + ' Option Type is case sensitive it must be in exact word Put or Call.'
			END

			IF @strStatus NOT IN('Filled','Unfilled','Cancelled')
			BEGIN
				SET @ErrMsg = @ErrMsg + ' Status is case sensitive it must be in exact word Filled, Unfilled or Cancelled.'
			END

			IF @strInstrumentType = 'Options' AND ISNULL(@dblStrike, 0) = 0
			BEGIN
				SET @ErrMsg = @ErrMsg + ' Strike must not be equal to 0.'
			END

			IF ISNULL(@dblPrice, 0) = 0
			BEGIN
				SET @ErrMsg = @ErrMsg + ' Price must not be equal to 0.'
			END

			DECLARE @isValidFilledDate BIT = 0
			BEGIN
				DECLARE @tempStrDate NVARCHAR(100)
				SELECT  @tempStrDate = strFilledDate 
				FROM tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber

				EXEC uspRKStringDateValidate @tempStrDate, @isValidFilledDate OUTPUT

				IF(@isValidFilledDate = 1)
				BEGIN
					SELECT  @dtmFilledDate=convert(datetime,@dtmFilledDate,@ConvertYear)
		
					-- Reconciled Validation 
					IF EXISTS(SELECT 1 FROM  tblRKReconciliationBrokerStatementHeader t
									JOIN tblRKFutureMarket m on t.intFutureMarketId=m.intFutureMarketId
									JOIN tblRKBrokerageAccount b on b.intBrokerageAccountId=t.intBrokerageAccountId
									JOIN tblICCommodity c on c.intCommodityId=t.intCommodityId
									JOIN tblEMEntity e on e.intEntityId= t.intEntityId
								WHERE m.strFutMarketName=strFutMarketName AND b.strAccountNumber=@strAccountNumber
									AND c.strCommodityCode=strCommodityCode AND e.strName=@strName AND ysnFreezed = 1
									AND convert(datetime,dtmFilledDate,@ConvertYear) = convert(datetime,@dtmFilledDate,@ConvertYear))
					BEGIN
						SET @ErrMsg = @ErrMsg + ' The selected filled date already reconciled.'
					END
				END
				ELSE
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Invalid Filled Date, format should be in ' + @strDateTimeFormat + '.'
					SET @dtmFilledDate = NULL
				END
			END

			DECLARE @intBook INT
			SELECT @intBook = intBookId FROM tblCTBook WHERE strBook = @strBook

			IF ISNULL(@strBook, '') <> '' AND ISNULL(@intBook,0) = 0
			BEGIN
				SET @ErrMsg = @ErrMsg + ' Book does not exist in the system.'
			END
	
			IF ISNULL(@strSubBook, '') <> '' AND NOT EXISTS(SELECT * FROM tblCTSubBook WHERE strSubBook = @strSubBook AND intBookId = ISNULL(@intBook,0)) AND ISNULL(@intBook,0) <> 0
			BEGIN
				SET @ErrMsg = @ErrMsg + ' Sub-Book does not exist in Book: ' + @strBook + '.'
			END
			ELSE IF(ISNULL(@strSubBook, '') <> '' AND ISNULL(@strBook, '') = '')
			BEGIN
				SET @ErrMsg = @ErrMsg + ' Book must exists for Sub-Book: ' + @strSubBook + '.'
			END

			DECLARE @isValidmCreateDateTime BIT = 0
			BEGIN
				SELECT @strCreateDateTime = strCreateDateTime 
				FROM tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber

				EXEC uspRKStringDateValidate @strCreateDateTime, @isValidmCreateDateTime OUTPUT

				IF(@isValidmCreateDateTime = 0)
				BEGIN
					SET @ErrMsg = @ErrMsg + ' Invalid Create Date Time, format should be in ' + @strDateTimeFormat + '.'
					SET @strCreateDateTime = NULL
				END
			END
		END

		IF @ErrMsg <> ''
		BEGIN
			INSERT INTO [dbo].[tblRKFutOptTransactionImport_ErrLog]
				   ([intFutOptTransactionId]
				   ,[strName]
				   ,[strAccountNumber]
				   ,[strFutMarketName]
				   ,[strInstrumentType]
				   ,[strCommodityCode]
				   ,[strLocationName]
				   ,[strSalespersonId]
				   ,[strCurrency]
				   ,[strBrokerTradeNo]
				   ,[strBuySell]
				   ,[dblNoOfContract]
				   ,[strFutureMonth]
				   ,[strOptionMonth]
				   ,[strOptionType]
				   ,[dblStrike]
				   ,[dblPrice]
				   ,[strReference]
				   ,[strStatus]
				   ,[strFilledDate]
				   ,[strBook]
				   ,[strSubBook]
				   ,[intConcurrencyId]
				   ,[strErrorMsg]
				   ,[strCreateDateTime])
		
			SELECT 
					[intFutOptTransactionId]
				   ,[strName]
				   ,[strAccountNumber]
				   ,[strFutMarketName]
				   ,[strInstrumentType]
				   ,[strCommodityCode]
				   ,[strLocationName]
				   ,[strSalespersonId]
				   ,[strCurrency]
				   ,[strBrokerTradeNo]
				   ,[strBuySell]
				   ,[dblNoOfContract]
				   ,[strFutureMonth]
				   ,[strOptionMonth]
				   ,[strOptionType]
				   ,[dblStrike]
				   ,[dblPrice]
				   ,[strReference]
				   ,[strStatus]
				   ,[strFilledDate]
				   ,[strBook]
				   ,[strSubBook]
				   ,[intConcurrencyId]
				   ,'Error at Line No. '  + Convert(nvarchar(50),@counter) + '. ' + @ErrMsg
				   ,[strCreateDateTime]	 
			FROM tblRKFutOptTransactionImport 
			WHERE intFutOptTransactionId = @mRowNumber
		END
		
		SELECT @mRowNumber = MIN(intFutOptTransactionId)	FROM tblRKFutOptTransactionImport	WHERE intFutOptTransactionId > @mRowNumber
	END

	EXIT_ROUTINE:

	SELECT intFutOptTransactionErrLogId
		, intFutOptTransactionId
		, strName
		, strAccountNumber
		, strFutMarketName
		, strInstrumentType
		, strCommodityCode
		, strLocationName
		, strSalespersonId
		, strCurrency
		, strBrokerTradeNo
		, strBuySell
		, dblNoOfContract
		, strFutureMonth
		, strOptionMonth
		, strOptionType
		, dblStrike
		, dblPrice
		, strReference
		, strStatus
		, strFilledDate
		, strBook
		, strSubBook
		, intConcurrencyId
		, strErrorMsg
		, strCreateDateTime
	FROM tblRKFutOptTransactionImport_ErrLog
	ORDER BY intFutOptTransactionErrLogId
	
	DELETE FROM tblRKFutOptTransactionImport_ErrLog
END TRY
BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH