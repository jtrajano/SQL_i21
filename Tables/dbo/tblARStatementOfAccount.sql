CREATE TABLE [dbo].[tblARStatementOfAccount]
(
	[intStatementId] [int] IDENTITY(1,1) NOT NULL
	, [strEntityNo]  NVARCHAR(25) COLLATE Latin1_General_CI_AS	NULL
	, [dtmLastStatementDate] [datetime] NULL	
	, [dblLastStatement] [numeric](18, 6) NULL DEFAULT ((0)) 
)
