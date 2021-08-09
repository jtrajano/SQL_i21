CREATE TABLE tblCMBankStatementImportLog
(
    intImportBankStatementLogId INT IDENTITY(1,1) NOT NULL,
    strBankStatementImportId  NVARCHAR(40) COLLATE Latin1_General_CI_AS  NULL,
    strDescription NVARCHAR(200)COLLATE Latin1_General_CI_AS  NULL,
    intEntityId INT NULL,
    intTaskCount INT NULL,
    intBTransactionCount INT NULL,
    dtmDate DATETIME NULL,
    dtmCreated DATETIME,
    intTotalImported INT NULL,
    intTotalCount INT NULL,
    intConcurrencyId INT NULL,
    ysnProceeded BIT NULL,
    CONSTRAINT [PK_tblCMBankStatementImportLog] PRIMARY KEY CLUSTERED
(
	[intImportBankStatementLogId] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]