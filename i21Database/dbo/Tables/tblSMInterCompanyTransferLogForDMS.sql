CREATE TABLE tblSMInterCompanyTransferLogForDMS
(
 [intInterCompanyTransferLogId] INT IDENTITY(1,1),
 [intSourceRecordId] INT NULL,
 [intDestinationRecordId] INT NULL,
 [intDestinationCompanyId] INT NULL,
 [dtmDateCreated]  DATETIME NULL,
 CONSTRAINT [PK_tblSMInterCompanyTransferLogForDMS] PRIMARY KEY CLUSTERED ([intInterCompanyTransferLogId] ASC),
 CONSTRAINT [FK_dbo.tblSMInterCompanyTransferLogForDMS_tblSMInterCompany] FOREIGN KEY ([intDestinationCompanyId]) REFERENCES [tblSMInterCompany](intInterCompanyId)
)
