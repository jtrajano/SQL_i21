CREATE TABLE [dbo].[tblRKDPRRunLog]
(
	intDPRunLogId INT IDENTITY NOT NULL 
	, intRunNumber INT
	, dtmRunDateTime DATETIME
	, dtmDPRDate DATETIME	
	, strDPRPositionIncludes NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strDPRPositionBy NVARCHAR(50)	COLLATE Latin1_General_CI_AS
	, strDPRPurchaseSale NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strDPRVendorCustomer NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intUserId INT
	CONSTRAINT [PK_tblRKDPRRunLog_intDPRunLogId] PRIMARY KEY ([intDPRunLogId])
)
