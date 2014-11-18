CREATE TABLE [dbo].[tblSCTicketFormat]
(
	[intTicketFormatId] INT NOT NULL IDENTITY, 
    [strTicketFormat] NVARCHAR(25) NOT NULL, 
    [intTicketFormatSelection] INT NOT NULL, 
    [ysnSuppressCompanyName] BIT NULL, 
    [ysnFormFeedEachCopy] BIT NULL, 
    [strTicketHeader] NVARCHAR(396) NULL, 
    [strTicketFooter] NVARCHAR(396) NULL, 
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