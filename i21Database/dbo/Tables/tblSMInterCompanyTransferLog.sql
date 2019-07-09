CREATE TABLE tblSMInterCompanyTransferLog
(
 [intInterCompanyTransferLogId] INT IDENTITY(1,1),
 [intSourceRecordId] INT NULL,
 [intDestinationRecordId] INT NULL,
 [dtmDateCreated]  DATETIME NULL,
 [intDestinationCompanyId] INT NULL,
 CONSTRAINT [PK_tblSMInterCompanyTransferLog] PRIMARY KEY CLUSTERED ([intInterCompanyTransferLogId] ASC),
 CONSTRAINT [FK_dbo.tblSMInterCompanyTransferLog_tblSMInterCompany] FOREIGN KEY ([intDestinationCompanyId]) REFERENCES [tblSMInterCompany](intInterCompanyId)
)
