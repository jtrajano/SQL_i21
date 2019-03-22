CREATE TABLE [dbo].[tblCTInvPlngReportAttributeValue]
(
	[intInvPlngReportAttributeValueID] INT NOT NULL IDENTITY, 
	[intInvPlngReportMasterID] INT NOT NULL,
	[intReportAttributeID] INT NOT NULL,
	[intItemId] INT NOT NULL,
	[strFieldName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strValue] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblCTInvPlngReportAttributeValue_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblCTInvPlngReportAttributeValue_dtmLastModified] DEFAULT GetDate(),

	CONSTRAINT [PK_tblCTInvPlngReportAttributeValue] PRIMARY KEY ([intInvPlngReportAttributeValueID]),
	CONSTRAINT [FK_tblCTInvPlngReportAttributeValue_tblCTInvPlngReportMaster] FOREIGN KEY ([intInvPlngReportMasterID]) REFERENCES [tblCTInvPlngReportMaster]([intInvPlngReportMasterID]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTInvPlngReportAttributeValue_tblCTReportAttribute] FOREIGN KEY ([intReportAttributeID]) REFERENCES [tblCTReportAttribute]([intReportAttributeID])
)