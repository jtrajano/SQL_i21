﻿CREATE TABLE dbo.tblICStagingCommodityActivity
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
	ysnLocationLicensed BIT NULL DEFAULT(0),
	
	CONSTRAINT [PK_tblICStagingCommodityActivity_intId] PRIMARY KEY ([intId]),
)