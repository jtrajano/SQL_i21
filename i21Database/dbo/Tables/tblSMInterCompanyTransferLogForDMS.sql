CREATE TABLE tblSMInterCompanyTransferLogForDMS
(
 [intInterCompanyTransferLogId] INT IDENTITY(1,1),
 [intSourceRecordId] INT NULL,
 [intDestinationRecordId] INT NULL,
 [intDestinationCompanyId] INT NULL,
 [strDatabaseName] NVARCHAR(MAX),
 [dtmCreated]  DATETIME NULL,
 CONSTRAINT [PK_tblSMInterCompanyTransferLogForDMS] PRIMARY KEY CLUSTERED ([intInterCompanyTransferLogId] ASC)

)
