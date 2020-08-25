CREATE TABLE dbo.tblICStagingDailyStockPosition
(
	intId INT NOT NULL IDENTITY(1, 1),
	guidSessionId uniqueidentifier NOT NULL,
	intKey INT NOT NULL,		
	intCommodityId INT NULL,
	strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dtmDate DATETIME NULL,				
	intCategoryId INT NULL,		
	strCategoryCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,		
	intLocationId INT NULL,		
	strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,		
	intItemId INT NULL,			
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,			
	strDescription NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,		
	intItemUOMId INT NULL,	
	strItemUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,			
	dblOpeningQty NUMERIC(38, 20) NULL,		
	dblReceivedQty NUMERIC(38, 20) NULL,		
	dblInvoicedQty NUMERIC(38, 20) NULL,		
	dblAdjustments NUMERIC(38, 20) NULL,		
	dblTransfersReceived NUMERIC(38, 20) NULL,
	dblTransfersShipped NUMERIC(38, 20) NULL,	
	dblInTransitInbound NUMERIC(38, 20) NULL,	
	dblInTransitOutbound NUMERIC(38, 20) NULL,
	dblConsumed NUMERIC(38, 20) NULL,		
	dblProduced NUMERIC(38, 20) NULL,			
	dblClosingQty NUMERIC(38, 20) NULL,
	strStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,			
	intConcurrencyId INT NULL,
	dtmDateModified DATETIME NULL,
	dtmDateCreated DATETIME NULL,
	intModifiedByUserId INT NULL,
	intCreatedByUserId INT NULL,
	ysnBuilding BIT NULL,
	CONSTRAINT [PK_tblStagingDailyStockPosition_intId] PRIMARY KEY ([intId]),
)

CREATE NONCLUSTERED INDEX [IX_tblICStagingDailyStockPosition]
	ON [dbo].[tblICStagingDailyStockPosition]([guidSessionId] ASC)
GO

CREATE NONCLUSTERED INDEX [IX_tblICStagingDailyStockPosition_Report]
	ON [dbo].[tblICStagingDailyStockPosition]([ysnBuilding] ASC)
GO