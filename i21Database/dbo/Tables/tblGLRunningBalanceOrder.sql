
CREATE TABLE [dbo].[tblGLRunningBalanceOrder](
	[intRunningBalanceOrderId] [int] IDENTITY(1,1) NOT NULL,
	[intGLDetailId] [int] NOT NULL,
	[intAccountId] [int] NOT NULL,
	[dtmDate] [datetime] NOT NULL,
	[strTransactionId] NVARCHAR(40) NOT NULL,
	[rowId] [bigint] NULL,
 CONSTRAINT [PK_tblGLRunningBalanceOrder] PRIMARY KEY CLUSTERED 
(
	[intRunningBalanceOrderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
