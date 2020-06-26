CREATE TABLE [dbo].[tblRKTempDPRDetailLog]
(
	intTempDPRDetailLogId INT IDENTITY NOT NULL 
	, intRunNumber INT
	, dtmRunDateTime DATETIME
	, dtmDPRDate DATETIME	
	, strDPRPositionIncludes NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strDPRPositionBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strDPRPurchaseSale NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strDPRVendorCustomer NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intUserId INT
	, intSeqNo INT
	, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strContractNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intContractHeaderId INT
	, strInternalTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intFutOptTransactionHeaderId INT
	, strType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strContractEndMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strContractEndMonthNearBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblTotal NUMERIC(24, 10)
	, strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTranType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblNoOfLot NUMERIC(24, 10)
	, dblDelta NUMERIC(24, 10)
	, intBrokerageAccountId INT
	, strInstrumentType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intOrderId INT
	, intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intCategoryId INT
	, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intFutureMarketId INT
	, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intFutureMonthId INT
	, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strDeliveryDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, ysnPreCrush BIT
	, strTransactionReferenceId NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intTransactionReferenceId INT
)