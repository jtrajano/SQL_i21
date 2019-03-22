CREATE TABLE [dbo].[tblSMGlobalSearchConfig]
(
	[intGSConfigId] INT Identity(1,1) NOT NULL ,
	[strType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strQuery] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strNamespace] NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL,
	[strValueField] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDisplayField] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDisplayTitle] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strScreenIcon] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTagFields] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 0, 
	CONSTRAINT [PK_tblSMGlobalSearchConfig] Primary key clustered (intGSConfigId ASC)
)
