﻿CREATE TABLE [dbo].[tblCTInvPlngReportMaster]
(
	[intInvPlngReportMasterID] INT NOT NULL IDENTITY, 
	[strInvPlngReportName] NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intReportMasterID] INT NOT NULL,
	[intNoOfMonths] INT NOT NULL,
	[ysnIncludeInventory] BIT NOT NULL CONSTRAINT [DF_tblCTInvPlngReportMaster_ysnIncludeInventory] DEFAULT 0, 
	[intCategoryId] INT NOT NULL,
	intCompanyLocationId INT,
	intUnitMeasureId INT,
	intDemandHeaderId INT,
	dtmDate DATETIME,
	intBookId INT,
	intSubBookId INT,
	ysnTest BIT CONSTRAINT [DF_tblCTInvPlngReportMaster_ysnTest] DEFAULT 0,
	strPlanNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	ysnAllItem BIT CONSTRAINT [DF_tblCTInvPlngReportMaster_ysnAllItem] DEFAULT 0,
	strComment NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	ysnPost BIT CONSTRAINT [DF_tblCTInvPlngReportMaster_ysnPost] DEFAULT 0,

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblCTInvPlngReportMaster_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblCTInvPlngReportMaster_dtmLastModified] DEFAULT GetDate(),

	CONSTRAINT [PK_tblCTInvPlngReportMaster] PRIMARY KEY ([intInvPlngReportMasterID]),
	CONSTRAINT [FK_tblCTInvPlngReportMaster_tblCTReportMaster] FOREIGN KEY ([intReportMasterID]) REFERENCES [tblCTReportMaster]([intReportMasterID]),
	CONSTRAINT [FK_tblCTInvPlngReportMaster_tblMFDemandHeader] FOREIGN KEY (intDemandHeaderId) REFERENCES [tblMFDemandHeader](intDemandHeaderId),
	CONSTRAINT [FK_tblCTInvPlngReportMaster_tblCTBook_intBookId] FOREIGN KEY (intBookId) REFERENCES [tblCTBook](intBookId),
	CONSTRAINT [FK_tblCTInvPlngReportMaster_tblCTSubBook_intSubBookId] FOREIGN KEY (intSubBookId) REFERENCES [tblCTSubBook](intSubBookId)
)