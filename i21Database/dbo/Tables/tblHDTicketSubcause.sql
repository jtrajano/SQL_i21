CREATE TABLE [dbo].[tblHDTicketSubcause]
(
	[intSubcauseId] [int] IDENTITY(1,1) NOT NULL,
	[intRootCauseId] [int] NOT NULL,
	[strSubcause] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	 CONSTRAINT [PK_tblHDTicketSubcause_intSubcauseId] PRIMARY KEY CLUSTERED ([intSubcauseId] ASC),
	 CONSTRAINT [UQ_tblHDTicketSubcause_intRootCauseId_strSubcause] UNIQUE ([intRootCauseId],[strSubcause])
)
