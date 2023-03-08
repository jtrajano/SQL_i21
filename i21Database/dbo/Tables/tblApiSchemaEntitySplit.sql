CREATE TABLE [dbo].[tblApiSchemaEntitySplit] (
    [guiApiUniqueId]				UNIQUEIDENTIFIER NOT NULL,
    [intRowNumber]				    INT NULL,
    [intKey]						INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,

    [strEntityNo]				    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,

	[strSplitNumber]			    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strExceptionCategories]	    NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strFarm]						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strDescription]			    NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strEntityType]				    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strSplitEntityNo]			    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPercent]				    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strOption]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strStorageTypeCode]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL

)