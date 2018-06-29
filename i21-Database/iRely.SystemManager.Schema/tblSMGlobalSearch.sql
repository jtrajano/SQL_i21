CREATE TABLE [dbo].[tblSMGlobalSearch]
(
	[intGSIndexId] INT Identity(1,1) NOT NULL ,
	[strValueField] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strValueData] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDisplayField] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDisplayData] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strNamespace] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDisplayTitle] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strScreenIcon] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSearchCommand] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strUrl] NVARCHAR(255) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTagId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 0, 
	CONSTRAINT [PK_tblSMGlobalSearch] Primary key clustered (intGSIndexId ASC)
)
