CREATE TABLE [dbo].[tblCMEmailEventLogDetail](
	[intEmailEventLogId] [int] NULL,
	[intEmailEventLogDetailId] [int] IDENTITY(1,1) NOT NULL,
	[strStatus] [nvarchar](10)  COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId] [int] NULL,
	[intConcurrencyId] INT NULL
 CONSTRAINT [PK_tblCMEmailEventLogDetail] PRIMARY KEY CLUSTERED 
(
	[intEmailEventLogDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblCMEmailEventLogDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblCMEmailEventLogDetail_tblCMEmailEventLog] FOREIGN KEY([intEmailEventLogId])
REFERENCES [dbo].[tblCMEmailEventLog] ([intEmailEventLogId])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[tblCMEmailEventLogDetail] CHECK CONSTRAINT [FK_tblCMEmailEventLogDetail_tblCMEmailEventLog]
GO


