CREATE TABLE [dbo].[tblCTInvPlngReportMaster]
(
	[intInvPlngReportMasterID] INT NOT NULL IDENTITY, 
	[strInvPlngReportName] NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intReportMasterID] INT NOT NULL,
	[intNoOfMonths] INT NOT NULL,
	[ysnIncludeInventory] BIT NOT NULL CONSTRAINT [DF_tblCTInvPlngReportMaster_ysnIncludeInventory] DEFAULT 0, 
	[intCategoryId] INT NOT NULL,
	intCompanyLocationId INT,
	intUnitMeasureId INT,

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblCTInvPlngReportMaster_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblCTInvPlngReportMaster_dtmLastModified] DEFAULT GetDate(),

	CONSTRAINT [PK_tblCTInvPlngReportMaster] PRIMARY KEY ([intInvPlngReportMasterID]),
	CONSTRAINT [FK_tblCTInvPlngReportMaster_tblCTReportMaster] FOREIGN KEY ([intReportMasterID]) REFERENCES [tblCTReportMaster]([intReportMasterID])
)