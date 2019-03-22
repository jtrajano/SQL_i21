CREATE TYPE [dbo].[TFTransactionSummaryItem] AS TABLE(
	[intId] [int] IDENTITY(1,1) NOT NULL,
	[intTransactionSummaryItemId] [int] NULL,
	[strTemplateItemId] [nvarchar](20) NULL
)