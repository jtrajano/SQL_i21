CREATE TABLE [dbo].[tblCTPutCall](
	[intPutCallId] [int] NOT NULL,
	[strPutCall] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCTPutCall_intPutCallId] PRIMARY KEY ([intPutCallId])
)
