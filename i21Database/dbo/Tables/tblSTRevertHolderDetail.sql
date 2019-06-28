﻿CREATE TABLE [dbo].[tblSTRevertHolderDetail] (
    [intRevertHolderDetailId]				INT IDENTITY	(1, 1) NOT NULL,
	[intRevertHolderId]						INT				NOT NULL,
	[strTableName]							NVARCHAR(150)	COLLATE Latin1_General_CI_AS NULL,
	[strTableColumnName]					NVARCHAR(150)	COLLATE Latin1_General_CI_AS NULL,
	[strTableColumnDataType]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL,
	[intPrimaryKeyId]						INT				NOT NULL,
	[intParentId]							INT				NULL,
	[intChildId]							INT				NULL,
	[intItemId]								INT				NULL,
	[intItemUOMId]							INT				NULL,
	[intItemLocationId]						INT				NULL,
	[dtmDateModified]						DATETIME		NOT NULL,
	[intCompanyLocationId]					INT				NULL,
	[strLocation]							NVARCHAR(250)	COLLATE Latin1_General_CI_AS NULL,
	[strUpc]								NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL,
	[strItemDescription]					NVARCHAR(250)	COLLATE Latin1_General_CI_AS NULL,
	[strChangeDescription]					NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL,
	[strOldData]							NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL,
	[strNewData]							NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]						INT				NULL DEFAULT ((0))
    CONSTRAINT [PK_tblSTRevertHolderDetail] PRIMARY KEY CLUSTERED ([intRevertHolderDetailId] ASC),
	CONSTRAINT [FK_tblSTRevertHolderDetail_tblSTRevertHolder] FOREIGN KEY ([intRevertHolderId]) REFERENCES [tblSTRevertHolder]([intRevertHolderId]) ON DELETE CASCADE, 
);