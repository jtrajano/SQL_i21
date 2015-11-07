CREATE TABLE [dbo].[tblCTInvPlngReportMaterial]
(
	[intInvPlngReportMaterialID] INT NOT NULL IDENTITY, 
	[intInvPlngReportMasterID] INT NOT NULL,
	[intItemId] INT NOT NULL,

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblCTInvPlngReportMaterial_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblCTInvPlngReportMaterial_dtmLastModified] DEFAULT GetDate(),

	CONSTRAINT [PK_tblCTInvPlngReportMaterial] PRIMARY KEY ([intInvPlngReportMaterialID]),
	CONSTRAINT [AK_tblCTInvPlngReportMaterial_intInvPlngReportMasterID_intItemId] UNIQUE ([intInvPlngReportMasterID],[intItemId]),
	
	CONSTRAINT [FK_tblCTInvPlngReportMaterial_tblCTInvPlngReportMaster] FOREIGN KEY ([intInvPlngReportMasterID]) REFERENCES [tblCTInvPlngReportMaster]([intInvPlngReportMasterID]) ON DELETE CASCADE
	
)