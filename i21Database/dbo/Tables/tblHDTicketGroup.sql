CREATE TABLE [dbo].[tblHDTicketGroup]
(
	[intTicketGroupId] INT             IDENTITY (1, 1) NOT NULL,
    [strGroup] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketGroup] PRIMARY KEY CLUSTERED ([intTicketGroupId] ASC)
)
