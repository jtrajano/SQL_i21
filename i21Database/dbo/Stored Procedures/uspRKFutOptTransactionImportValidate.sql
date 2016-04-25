﻿CREATE PROC uspRKFutOptTransactionImportValidate
AS
Begin Try
DECLARE @tblRKFutOptTransactionHeaderId int 
Declare @ErrMsg nvarchar(Max)

DECLARE @mRowNumber INT
DECLARE @strName NVARCHAR(50)
DECLARE @strAccountNumber NVARCHAR(50)
DECLARE @strFutMarketName NVARCHAR(100)
DECLARE @strInstrumentType NVARCHAR(20)
DECLARE @strCommodityCode NVARCHAR(100)
DECLARE @strLocationName NVARCHAR(100)
DECLARE @strSalespersonId NVARCHAR(100)
DECLARE @strCurrency NVARCHAR(100)
DECLARE @strBuySell NVARCHAR(100)
DECLARE @strFutureMonth NVARCHAR(100)
DECLARE @strOptionMonth NVARCHAR(100)
DECLARE @strOptionType NVARCHAR(100)
DECLARE @strStatus NVARCHAR(100)
DECLARE @dtmFilledDate DATETIME
DECLARE @strBook NVARCHAR(100)
DECLARE @strSubBook NVARCHAR(100)
DECLARE @PreviousErrMsg nvarchar(max)

SELECT @mRowNumber = MIN(intFutOptTransactionId) FROM tblRKFutOptTransactionImport

WHILE @mRowNumber > 0
	BEGIN
		SET @strName=NULL
		SET @strAccountNumber=NULL
		SET @strFutMarketName=NULL
		SET @strInstrumentType=NULL
		SET @strCommodityCode=NULL
		SET @strLocationName=NULL
		SET @strSalespersonId=NULL
		SET @strCurrency=NULL
		SET @strBuySell=NULL
		SET @strFutureMonth=NULL
		SET @strOptionMonth =NULL
		SET @strOptionType =NULL
		SET @strStatus =NULL
		SET @dtmFilledDate =NULL
		SET @strBook =NULL
		SET @strSubBook =NULL

		SELECT @strName = strName,@strAccountNumber=strAccountNumber,@strFutMarketName=strFutMarketName, @strInstrumentType=strInstrumentType,@strCommodityCode=strCommodityCode
			,@strLocationName=strLocationName,@strSalespersonId=strSalespersonId,@strCurrency=strCurrency,@strBuySell=strBuySell,@strFutureMonth=strFutureMonth
			,@strOptionMonth=strOptionMonth,@strOptionType=strOptionType,@strStatus=strStatus,@dtmFilledDate=dtmFilledDate,@strBook=strBook,@strSubBook=strSubBook
		FROM tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
		
		SELECT @PreviousErrMsg=''
		IF NOT EXISTS(SELECT * FROM tblEMEntity WHERE strName=@strName)
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber )
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Invalid Broker.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg from tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					UPDATE tblRKFutOptTransactionImport_ErrLog set strErrorMsg=@PreviousErrMsg+'Invalid Broker.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END

		IF NOT EXISTS(SELECT * FROM tblRKBrokerageAccount WHERE strAccountNumber=@strAccountNumber)
		BEGIN
			IF NOT EXISTS(select * from tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber )
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Invalid Account Number.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg from tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					update tblRKFutOptTransactionImport_ErrLog set strErrorMsg=@PreviousErrMsg+'Invalid Account Number.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END

		IF NOT EXISTS(SELECT * FROM tblRKFutureMarket WHERE strFutMarketName=@strFutMarketName)
		BEGIN
			IF NOT EXISTS(select * from tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber )
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Invalid Market.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg from tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					update tblRKFutOptTransactionImport_ErrLog set strErrorMsg=@PreviousErrMsg+'Invalid Market.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END

-- Instrument Type
		IF @strInstrumentType not in('Futures','Options')
		BEGIN
			IF NOT EXISTS(select * from tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Invalid Instrument Type.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg from tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					update tblRKFutOptTransactionImport_ErrLog set strErrorMsg=@PreviousErrMsg+'Invalid Instrument Type.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END
-- Commodity Code
		IF NOT EXISTS(SELECT * FROM tblICCommodity WHERE strCommodityCode=@strCommodityCode)
		BEGIN
			IF NOT EXISTS(select * from tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Invalid Commodity Code.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg from tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					update tblRKFutOptTransactionImport_ErrLog set strErrorMsg=@PreviousErrMsg+'Invalid Commodity Code.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END

-- Location
		IF NOT EXISTS(SELECT * FROM tblSMCompanyLocation WHERE strLocationName=@strLocationName)
		BEGIN
			IF NOT EXISTS(select * from tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Invalid Location.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg from tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					update tblRKFutOptTransactionImport_ErrLog set strErrorMsg=@PreviousErrMsg+'Invalid Location.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END

-- SalespersonId
		IF NOT EXISTS(SELECT * FROM vyuHDSalesPerson WHERE strName=@strSalespersonId)
		BEGIN
			IF NOT EXISTS(select * from tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Invalid Sales Person.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg from tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					update tblRKFutOptTransactionImport_ErrLog set strErrorMsg=@PreviousErrMsg+'Invalid Sales Person.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END
-- Currency
		IF NOT EXISTS(SELECT * FROM tblSMCurrency WHERE strCurrency=@strCurrency)
		BEGIN
			IF NOT EXISTS(select * from tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Invalid Currency.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg from tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					UPDATE tblRKFutOptTransactionImport_ErrLog set strErrorMsg=@PreviousErrMsg+'Invalid Currency.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END

-- BuySell
		IF @strBuySell not in('Buy','Sell')
		BEGIN
			IF NOT EXISTS(select * from tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Invalid Buy/Sell.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg from tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					update tblRKFutOptTransactionImport_ErrLog set strErrorMsg=@PreviousErrMsg+'Invalid Buy/Sell.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END

-- strFutureMonth
		IF NOT EXISTS(SELECT * FROM tblRKFuturesMonth WHERE strFutureMonth=replace(@strFutureMonth,'-',' '))
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Invalid Future Month.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg FROM tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					UPDATE tblRKFutOptTransactionImport_ErrLog SET strErrorMsg=@PreviousErrMsg+'Invalid Future Month.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END

-- Option Month
if @strInstrumentType='Options'
BEGIN
		IF NOT EXISTS(SELECT * FROM tblRKOptionsMonth WHERE strOptionMonth=replace(@strOptionMonth,'-',' ') )
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Invalid Option Month.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg FROM tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					UPDATE tblRKFutOptTransactionImport_ErrLog SET strErrorMsg=@PreviousErrMsg+'Invalid Option Month.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END

-- OptionType
		IF ( @strOptionType not in('Call','Put'))
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Invalid OptionType.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg FROM tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					UPDATE tblRKFutOptTransactionImport_ErrLog SET strErrorMsg=@PreviousErrMsg+'Invalid OptionType.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END
END
-- Status
		IF @strStatus not in('Filled','Unfilled','Cancelled')
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Invalid Status.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg FROM tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					UPDATE tblRKFutOptTransactionImport_ErrLog SET strErrorMsg=@PreviousErrMsg+'Invalid Status.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END

-- Book
if isnull(@strBook,'') <> ''
BEGIN
		IF NOT EXISTS(SELECT * FROM tblCTBook WHERE strBook=@strBook)
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Invalid Book.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg FROM tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					UPDATE tblRKFutOptTransactionImport_ErrLog SET strErrorMsg=@PreviousErrMsg+'Invalid Book.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END
END
--SubBook
if isnull(@strSubBook,'') <> ''
BEGIN
		IF NOT EXISTS(SELECT * FROM tblCTSubBook WHERE strSubBook=@strSubBook)
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Invalid SubBook.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg FROM tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					UPDATE tblRKFutOptTransactionImport_ErrLog SET strErrorMsg=@PreviousErrMsg+'Invalid SubBook.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END
END
		IF NOT EXISTS(SELECT 1
							FROM tblRKFutOptTransactionImport ti
							JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
							JOIN tblRKBrokersAccountMarketMapping am on fm.intFutureMarketId =am.intFutureMarketId
							JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=am.intBrokerageAccountId  
							JOIN tblEMEntity em on ba.intEntityId=em.intEntityId and em.strName=ti.strName
							WHERE intFutOptTransactionId =@mRowNumber)
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Broker is not configured for the market.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg FROM tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					UPDATE tblRKFutOptTransactionImport_ErrLog SET strErrorMsg=@PreviousErrMsg+'Broker is not configured for the market.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END


	IF NOT EXISTS(SELECT 1
						FROM tblRKFutOptTransactionImport ti
						JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
						JOIN tblRKBrokersAccountMarketMapping am on fm.intFutureMarketId =am.intFutureMarketId
						JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=am.intBrokerageAccountId  
						AND ba.intInstrumentTypeId= case when ba.intInstrumentTypeId= 3 then 3 else
								case when ti.strInstrumentType='Futures' then 1
								 when ti.strInstrumentType='Options' then 2 end end
						WHERE intFutOptTransactionId =@mRowNumber)
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Instrument Type is not configured for the market.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg FROM tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					UPDATE tblRKFutOptTransactionImport_ErrLog SET strErrorMsg=@PreviousErrMsg+'Instrument Type is not configured for the market.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END


		IF NOT EXISTS(SELECT 1
						FROM tblRKFutOptTransactionImport ti
						JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
						Join tblRKCommodityMarketMapping mm on mm.intFutureMarketId=fm.intFutureMarketId 
						join tblICCommodity c on c.intCommodityId=mm.intCommodityId and c.strCommodityCode=ti.strCommodityCode
						WHERE intFutOptTransactionId =@mRowNumber)
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Commodity is not configured for the market.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg FROM tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					UPDATE tblRKFutOptTransactionImport_ErrLog SET strErrorMsg=@PreviousErrMsg+'Commodity is not configured for the market.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END

	IF NOT EXISTS(SELECT 1
						FROM tblRKFutOptTransactionImport ti
					JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName
					JOIN tblRKBrokerageAccount ba on ba.strAccountNumber=ti.strAccountNumber  
					join tblRKTradersbyBrokersAccountMapping bam on bam.intBrokerageAccountId=ba.intBrokerageAccountId
					join vyuHDSalesPerson sp on sp.intEntityId=bam.intEntitySalespersonId and sp.strName=ti.strSalespersonId
					WHERE intFutOptTransactionId =@mRowNumber)
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Sales Person is not configured for the market.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg FROM tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					UPDATE tblRKFutOptTransactionImport_ErrLog SET strErrorMsg=@PreviousErrMsg+'Sales Person is not configured for the market.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END

IF NOT EXISTS(SELECT 1
				FROM tblRKFutOptTransactionImport ti
				JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName 
				join tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId and c.strCurrency=ti.strCurrency
				WHERE intFutOptTransactionId =@mRowNumber)
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Currency is not configured for the market.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg FROM tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					UPDATE tblRKFutOptTransactionImport_ErrLog SET strErrorMsg=@PreviousErrMsg+'Currency is not configured for the market.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END

IF NOT EXISTS(SELECT 1
				FROM tblRKFutOptTransactionImport ti
				JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName 
				join tblRKFuturesMonth m on fm.intFutureMarketId=m.intFutureMarketId and m.strFutureMonth=replace(ti.strFutureMonth,'-',' ')
				WHERE intFutOptTransactionId =@mRowNumber)
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Currency is not configured for the market.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg FROM tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					UPDATE tblRKFutOptTransactionImport_ErrLog SET strErrorMsg=@PreviousErrMsg+'Future Month is not configured for the market.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END
if @strInstrumentType='Options'
BEGIN
IF NOT EXISTS(SELECT 1
				FROM tblRKFutOptTransactionImport ti
			JOIN tblRKFutureMarket fm on fm.strFutMarketName=ti.strFutMarketName 
			join tblRKOptionsMonth m on fm.intFutureMarketId=m.intFutureMarketId and m.strOptionMonth=replace(ti.strOptionMonth,'-',' ')
			WHERE intFutOptTransactionId =@mRowNumber)
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblRKFutOptTransactionImport_ErrLog where intFutOptTransactionId=@mRowNumber)
				BEGIN
					INSERT INTO tblRKFutOptTransactionImport_ErrLog(intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg)
					SELECT intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
																	strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,
																	dblStrike,dblPrice,strReference,strStatus,convert(datetime,dtmFilledDate,103),strBook,strSubBook,intConcurrencyId,'Option Month is not configured for the market.'
					FROM  tblRKFutOptTransactionImport WHERE intFutOptTransactionId = @mRowNumber
				END
				ELSE
				BEGIN					
					SELECT @PreviousErrMsg=strErrorMsg FROM tblRKFutOptTransactionImport_ErrLog WHERE intFutOptTransactionId = @mRowNumber  
					UPDATE tblRKFutOptTransactionImport_ErrLog SET strErrorMsg=@PreviousErrMsg+'Option Month is not configured for the market.' WHERE intFutOptTransactionId = @mRowNumber
				END
		END
END
SELECT @mRowNumber = MIN(intFutOptTransactionId)	FROM tblRKFutOptTransactionImport	WHERE intFutOptTransactionId > @mRowNumber
END

SELECT  intFutOptTransactionErrLogId,intFutOptTransactionId,strName,strAccountNumber,strFutMarketName,strInstrumentType,strCommodityCode,strLocationName,
		strSalespersonId,strCurrency,strBrokerTradeNo,strBuySell,intNoOfContract,strFutureMonth,strOptionMonth,strOptionType,dblStrike,dblPrice,strReference,strStatus,
		dtmFilledDate,strBook,strSubBook,intConcurrencyId,strErrorMsg  FROM tblRKFutOptTransactionImport_ErrLog

DELETE FROM tblRKFutOptTransactionImport_ErrLog
END TRY
BEGIN CATCH
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
End Catch	
