CREATE TABLE [dbo].tblSCTicketStorageType
(
	[intTicketStorageTypeId] INT NOT NULL IDENTITY , 
    [intStorageNumber] INT NOT NULL, 
    [strStorageDescription] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblSCTicketStorageType_intTicketStorageTypeId] PRIMARY KEY ([intTicketStorageTypeId]), 
    CONSTRAINT [UK_tblSCTicketStorageType_intStorageNumber] UNIQUE ([intStorageNumber])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketStorageType',
    @level2type = N'COLUMN',
    @level2name = 'intTicketStorageTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketStorageType',
    @level2type = N'COLUMN',
    @level2name = 'intStorageNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketStorageType',
    @level2type = N'COLUMN',
    @level2name = 'strStorageDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketStorageType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'