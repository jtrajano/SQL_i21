CREATE TABLE [dbo].[tblHDTicketRootCause]
(
	[intRootCauseId] [int] IDENTITY(1,1) NOT NULL,
	[strRootCause] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	 CONSTRAINT [PK_tblHDTicketRootCause_intRootCauseId] PRIMARY KEY CLUSTERED ([intRootCauseId] ASC),
	 CONSTRAINT [UQ_tblHDTicketRootCause_strRootCause] UNIQUE ([strRootCause])
)
