﻿CREATE TABLE [dbo].[tblICItemXref]
(
	[intItemCustomerXrefId] INT NOT NULL IDENTITY , 
    [intItemId] INT NOT NULL, 
    [intLocationId] INT NOT NULL, 
    [strStoreName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intCustomerId] INT NOT NULL, 
    [strCustomerProduct] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strProductDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strPickTicketNotes] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICItemXref] PRIMARY KEY ([intItemCustomerXrefId]), 
    CONSTRAINT [FK_tblICItemXref_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemXref',
    @level2type = N'COLUMN',
    @level2name = N'intItemCustomerXrefId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemXref',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemXref',
    @level2type = N'COLUMN',
    @level2name = N'intLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Store Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemXref',
    @level2type = N'COLUMN',
    @level2name = N'strStoreName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemXref',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Product',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemXref',
    @level2type = N'COLUMN',
    @level2name = N'strCustomerProduct'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Product Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemXref',
    @level2type = N'COLUMN',
    @level2name = N'strProductDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pick Ticket Notes',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemXref',
    @level2type = N'COLUMN',
    @level2name = N'strPickTicketNotes'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemXref',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemXref',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'