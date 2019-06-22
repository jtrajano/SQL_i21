CREATE TABLE [dbo].[tblSTUpdateItemDataRevertHolder] (
    [intUpdateItemDataRevertHolderId]     INT IDENTITY (1, 1) NOT NULL,
	[strTableName] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strTableColumnName] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strTableColumnDataType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intPrimaryKeyId] INT NOT NULL,
	[intParentId] INT NULL,
	[intChildId] INT NULL,
	[intCurrentEntityUserId] INT NOT NULL,
	[intItemId] INT NULL,
	[intItemUOMId] INT NULL,
	[intItemLocationId] INT NULL,

	[dtmDateTime] DATETIME NOT NULL,
	[intMassUpdatedRowCount] INT NOT NULL,

	[intCompanyLocationId] INT NOT NULL,
	[strLocation] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strUpc] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strItemDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strChangeDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPreviewOldData] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strPreviewNewData] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NULL,
    CONSTRAINT [PK_tblSTUpdateItemDataRevertHolder] PRIMARY KEY CLUSTERED ([intUpdateItemDataRevertHolderId] ASC)
);
