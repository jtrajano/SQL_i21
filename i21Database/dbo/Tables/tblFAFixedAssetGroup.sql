CREATE TABLE [dbo].[tblFAFixedAssetGroup] (
    [intAssetGroupId]			INT IDENTITY (1, 1) NOT NULL,
	[strGroupCode]	            NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,
	[strGroupDescription]		NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]          INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFAFixedAssetGroup] PRIMARY KEY CLUSTERED ([intAssetGroupId] ASC)
);