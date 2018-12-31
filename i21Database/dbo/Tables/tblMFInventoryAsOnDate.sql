﻿
CREATE TABLE dbo.tblMFInventoryAsOnDate
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
	intParentLotId INT NULL,			
	strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,		
	intLotId INT NULL,			
	strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,	
	strLotAlias NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strSecondaryStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
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
	intConcurrencyId INT NULL,
	dtmDateCreated DATETIME NULL,
	intCreatedByUserId INT,
	strVendorRefNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strWarehouseRefNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strBondStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strContainerNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblMFInventoryAsOnDate_intId] PRIMARY KEY ([intId]),
)


