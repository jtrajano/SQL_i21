CREATE TABLE [dbo].[tblHDModule]
(
	[intModuleId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketProductId] [int] NOT NULL,
	[intTicketGroupId] [int] NOT NULL,
	[strModule] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[strJIRAProject] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDModule] PRIMARY KEY CLUSTERED ([intModuleId] ASC),
	CONSTRAINT [UNQ_tblHDModule] UNIQUE ([strModule]),
    CONSTRAINT [FK_Module_TicketProduct] FOREIGN KEY ([intTicketProductId]) REFERENCES [dbo].[tblHDTicketProduct] ([intTicketProductId]) on delete cascade,
    CONSTRAINT [FK_Module_TicketGroup] FOREIGN KEY ([intTicketGroupId]) REFERENCES [dbo].[tblHDTicketGroup] ([intTicketGroupId])
)
