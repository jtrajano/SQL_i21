CREATE TABLE [dbo].[tblCTReportAttribute]
(
	[intReportAttributeID] INT NOT NULL, 
	[intReportMasterID] INT NOT NULL,
	[strAttributeName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intDisplayOrder] INT,

	CONSTRAINT [PK_tblCTReportAttribute] PRIMARY KEY ([intReportAttributeID]),
	CONSTRAINT [FK_tblCTReportAttribute_tblCTReportMaster] FOREIGN KEY ([intReportMasterID]) REFERENCES [tblCTReportMaster]([intReportMasterID]) ON DELETE CASCADE
)