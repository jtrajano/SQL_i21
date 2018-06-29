﻿CREATE TABLE [dbo].[tblSCTicketFormat]
(
	[intTicketFormatId] INT NOT NULL IDENTITY, 
    [strTicketFormat] NVARCHAR(25) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intTicketFormatSelection] INT NOT NULL, 
	[ysnSuppressSplit] BIT NULL,
    [ysnSuppressCompanyName] BIT NULL, 
    [ysnFormFeedEachCopy] BIT NULL, 
    [intSuppressDiscountOptionId] INT NULL, 
    [strTicketHeader] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strTicketFooter] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblSCTicketFormat_intTicketFormatId] PRIMARY KEY ([intTicketFormatId]), 
    CONSTRAINT [UK_tblSCTicketFormat_strTicketFormat] UNIQUE ([strTicketFormat]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketFormat',
    @level2type = N'COLUMN',
    @level2name = N'intTicketFormatId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Format',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketFormat',
    @level2type = N'COLUMN',
    @level2name = N'strTicketFormat'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Format Selection',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketFormat',
    @level2type = N'COLUMN',
    @level2name = N'intTicketFormatSelection'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Suppress Company Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketFormat',
    @level2type = N'COLUMN',
    @level2name = N'ysnSuppressCompanyName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Form Feed Each Copy',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketFormat',
    @level2type = N'COLUMN',
    @level2name = N'ysnFormFeedEachCopy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount and Reading in all report',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketFormat',
    @level2type = N'COLUMN',
    @level2name = 'intSuppressDiscountOptionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Header',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketFormat',
    @level2type = N'COLUMN',
    @level2name = N'strTicketHeader'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Footer',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketFormat',
    @level2type = N'COLUMN',
    @level2name = N'strTicketFooter'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketFormat',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Suppress Split Information',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketFormat',
    @level2type = N'COLUMN',
    @level2name = N'ysnSuppressSplit'
GO