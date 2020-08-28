CREATE TABLE dbo.tblICStagingCommodityActivity
(
	intId INT NOT NULL IDENTITY(1, 1),
	guidSessionId uniqueidentifier NOT NULL,	
	intCommodityId INT NULL,
	strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dtmDate DATETIME NULL,				
	intCategoryId INT NULL,		
	strCategoryCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,		
	intLocationId INT NULL,		
	strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,		
	strItemUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,			
	
	dblOpeningQty NUMERIC(28, 2) NULL,		
	dblReceivedQty NUMERIC(28, 2) NULL,		
	dblInvoicedQty NUMERIC(28, 2) NULL,		
	dblAdjustments NUMERIC(28, 2) NULL,		
	dblTransfersReceived NUMERIC(28, 2) NULL,
	dblTransfersShipped NUMERIC(28, 2) NULL,	
	dblInTransitInbound NUMERIC(28, 2) NULL,	
	dblInTransitOutbound NUMERIC(28, 2) NULL,
	dblConsumed NUMERIC(28, 2) NULL,		
	dblProduced NUMERIC(28, 2) NULL,			
	dblClosingQty NUMERIC(28, 2) NULL,
	ysnLocationLicensed BIT NULL DEFAULT(0),
	
	CONSTRAINT [PK_tblICStagingCommodityActivity_intId] PRIMARY KEY ([intId]),
)