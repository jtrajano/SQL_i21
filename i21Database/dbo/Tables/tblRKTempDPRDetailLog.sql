CREATE TABLE [dbo].[tblRKTempDPRDetailLog]
(
	intTempDPRDetailLogId INT IDENTITY NOT NULL 
	, intRunNumber INT
	, dtmRunDateTime DATETIME
	, dtmDPRDate DATETIME	
	, strDPRPositionIncludes NVARCHAR(50)	
	, strDPRPositionBy NVARCHAR(50)	
	, strDPRPurchaseSale NVARCHAR(50)	
	, strDPRVendorCustomer NVARCHAR(200)	
	, intUserId INT
	, intSeqNo INT
	, strCommodityCode NVARCHAR(200) 
	, strContractNumber NVARCHAR(200) 
	, intContractHeaderId INT
	, strInternalTradeNo NVARCHAR(200) 
	, intFutOptTransactionHeaderId INT
	, strType NVARCHAR(50) 
	, strLocationName NVARCHAR(100) 
	, strContractEndMonth NVARCHAR(50) 
	, strContractEndMonthNearBy NVARCHAR(50) 
	, dblTotal NUMERIC(24, 10)
	, strUnitMeasure NVARCHAR(50) 
	, strAccountNumber NVARCHAR(100) 
	, strTranType NVARCHAR(100) 
	, dblNoOfLot NUMERIC(24, 10)
	, dblDelta NUMERIC(24, 10)
	, intBrokerageAccountId INT
	, strInstrumentType NVARCHAR(50) 
	, strEntityName NVARCHAR(100) 
	, intOrderId INT
	, intItemId INT
	, strItemNo NVARCHAR(100) 
	, intCategoryId INT
	, strCategory NVARCHAR(100) 
	, intFutureMarketId INT
	, strFutMarketName NVARCHAR(100)
	, intFutureMonthId INT
	, strFutureMonth NVARCHAR(100)
	, strDeliveryDate NVARCHAR(50)
	, strBrokerTradeNo NVARCHAR(100)
	, strNotes NVARCHAR(100)
	, ysnPreCrush BIT
	, strTransactionReferenceId NVARCHAR(100)
	, intTransactionReferenceId INT
	, intTransactionReferenceDetailId INT
	CONSTRAINT [PK_tblRKTempDPRDetailLog_intTempDPRDetailLogId] PRIMARY KEY ([intTempDPRDetailLogId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblRKTempDPRDetailLog_forDPR]
	ON [dbo].[tblRKTempDPRDetailLog] ([intRunNumber])
	INCLUDE ([strType],[dblTotal])

GO