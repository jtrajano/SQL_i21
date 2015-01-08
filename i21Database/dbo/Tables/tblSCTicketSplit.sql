CREATE TABLE [dbo].[tblSCTicketSplit]
(
	[intTicketSplitId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NOT NULL, 
    [intCustomerId] INT NOT NULL, 
    [dblSplitPercent] DECIMAL(6, 3) NOT NULL, 
    [strSplitOption] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSCTicketSplit_intTicketSplitId] PRIMARY KEY ([intTicketSplitId]) ,
	CONSTRAINT [FK_tblSCTicketSplit_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [tblSCTicket]([intTicketId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketSplit',
    @level2type = N'COLUMN',
    @level2name = N'intTicketSplitId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketSplit',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketSplit',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Split Percent',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketSplit',
    @level2type = N'COLUMN',
    @level2name = N'dblSplitPercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Split Distribution Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketSplit',
    @level2type = N'COLUMN',
    @level2name = N'strSplitOption'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketSplit',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'