CREATE TABLE [dbo].[tblSCTicketPool]
(
	[intTicketPoolId] INT NOT NULL  IDENTITY, 
    [strTicketPool] NVARCHAR(5) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intNextTicketNumber] INT NOT NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblSCTicketPool_intTicketPoolId] PRIMARY KEY ([intTicketPoolId]), 
    CONSTRAINT [UK_tblSCTicketPool_strTicketPool] UNIQUE ([strTicketPool])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketPool',
    @level2type = N'COLUMN',
    @level2name = N'intTicketPoolId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Pool',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketPool',
    @level2type = N'COLUMN',
    @level2name = N'strTicketPool'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Next Ticket Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketPool',
    @level2type = N'COLUMN',
    @level2name = 'intNextTicketNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketPool',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'