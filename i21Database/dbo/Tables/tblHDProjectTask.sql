CREATE TABLE [dbo].[tblHDProjectTask]
(
	[intProjectTaskId] [int] IDENTITY(1,1) NOT NULL,
	[intProjectId] [int] NOT NULL,
	[intTicketId] [int] NOT NULL,
	[ysnClosed] [bit] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDProjectTask] PRIMARY KEY CLUSTERED ([intProjectTaskId] ASC),
	CONSTRAINT [UNQ_Project_Ticket] UNIQUE ([intProjectId],[intTicketId]),
    CONSTRAINT [FK_ProjectTask_Project] FOREIGN KEY ([intProjectId]) REFERENCES [dbo].[tblHDProject] ([intProjectId]) on delete cascade,
    CONSTRAINT [FK_ProjectTask_Ticket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]) on delete cascade
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Project Task Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectTask',
    @level2type = N'COLUMN',
    @level2name = N'intProjectTaskId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Project Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectTask',
    @level2type = N'COLUMN',
    @level2name = N'intProjectId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectTask',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectTask',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Closed=1; Open=0;',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProjectTask',
    @level2type = N'COLUMN',
    @level2name = N'ysnClosed'