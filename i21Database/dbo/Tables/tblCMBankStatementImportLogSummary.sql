CREATE TABLE tblCMBankStatementImportLogSummary
(
    intSummaryId INT IDENTITY(1,1) NOT NULL,
    strBankStatementImportId  NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strTaskCreationResult NVARCHAR(200)COLLATE Latin1_General_CI_AS  NULL,
    strBankTransactionCreationResult NVARCHAR(200)COLLATE Latin1_General_CI_AS  NULL,
    dtmDate DATETIME,
    intConcurrencyId INT NULL,
    CONSTRAINT [PK_tblCMBankStatementImportLogSummary] PRIMARY KEY CLUSTERED 
(
	[intSummaryId] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]