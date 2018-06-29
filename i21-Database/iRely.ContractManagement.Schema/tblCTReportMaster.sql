CREATE TABLE [dbo].[tblCTReportMaster]
(
	[intReportMasterID] INT NOT NULL, 
	[strReportName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 

	CONSTRAINT [PK_tblCTReportMaster] PRIMARY KEY ([intReportMasterID])
)