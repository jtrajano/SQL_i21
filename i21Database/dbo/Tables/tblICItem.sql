CREATE TABLE [dbo].[tblICItem] (
    [intItemId]                  INT             IDENTITY (1, 1) NOT NULL,
    [strItemNo]                  NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strType]              NVARCHAR(50)              NOT NULL,
    [strDescription]             NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intManufacturerId]          INT             NULL,
    [intBrandId]                 INT             NULL,
    [strStatus]                NVARCHAR(50)              NULL,
    [strModelNo]                 NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [intTrackingId] INT NULL, 
    [strLotTracking] NVARCHAR(50) NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [AK_tblICItem_strItemNo] UNIQUE ([strItemNo]), 
    CONSTRAINT [PK_tblICItem] PRIMARY KEY ([intItemId])
);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intItemId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique key that corresponds to the item number. Origin: agitm-no ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strItemNo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Inventory type (e.g. 1=Inventory Item, 2=Service Item, 3=Finished Goods, 4=Bulk, 5=Pre-Mixes, 6=Raw Materials)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = 'strType';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Item Description. Origin: agitm-desc', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strDescription';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. An item may belong to a manufacturer. Origin: agitm-mfg-id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intManufacturerId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. An item may belong to a brand. Origin: stpbk_brand_name ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intBrandId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status of an item (e.g. 1=Active, 2=Phased Out, 3=Discontinued)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = 'strStatus';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Model number of an item. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strModelNo';
GO