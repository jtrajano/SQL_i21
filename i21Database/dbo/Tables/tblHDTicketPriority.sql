CREATE TABLE [dbo].[tblHDTicketPriority]
(
	[intTicketPriorityId] [int] IDENTITY(1,1) NOT NULL,
	[strPriority] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[strIcon] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strFontColor] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strBackColor] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblHDTicketPriority] PRIMARY KEY CLUSTERED ([intTicketPriorityId] ASC),
 CONSTRAINT [UNQ_tblHDTicketPriority] UNIQUE ([strPriority])
)
