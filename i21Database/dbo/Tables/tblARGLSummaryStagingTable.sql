CREATE TABLE [dbo].[tblARGLSummaryStagingTable]
(
	[intAccountId]			INT NULL, 
	[intEntityUserId]		INT NULL,
    [strAccountId]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strAccountCategory]	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
    [dblGLBalance]			NUMERIC(18, 6) NULL, 
    [dblTotalAR]			NUMERIC(18, 6) NULL,
    [dblTotalPrepayments]	NUMERIC(18, 6) NULL,
	[dblTotalReportBalance] NUMERIC(18, 6) NULL
)
