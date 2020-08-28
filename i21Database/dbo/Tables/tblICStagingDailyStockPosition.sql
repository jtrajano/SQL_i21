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
	strStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,			
	intConcurrencyId INT NULL,
	dtmDateModified DATETIME NULL,
	dtmDateCreated DATETIME NULL,
	intModifiedByUserId INT NULL,
	intCreatedByUserId INT NULL,
	ysnBuilding BIT NULL,
	CONSTRAINT [PK_tblStagingDailyStockPosition_intId] PRIMARY KEY ([intId]),
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICStagingDailyStockPosition]
	ON [dbo].[tblICStagingDailyStockPosition]([guidSessionId] ASC)
GO

CREATE NONCLUSTERED INDEX [IX_tblICStagingDailyStockPosition_Report]
	ON [dbo].[tblICStagingDailyStockPosition]([ysnBuilding] ASC)
GO