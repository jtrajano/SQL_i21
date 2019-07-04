CREATE TABLE tblSMInterCompanyTransferLog
(
 [intInterCompanyTransferLogId] int identity(1,1),
 [strType] nvarchar(100) collate Latin1_General_CI_AS  null,
 [intSourceRecordId] int null,
 [intDestinationRecordId] int null,
 [intDestinationCompanyId] int null,
 CONSTRAINT [PK_tblSMInterCompanyTransferLog] PRIMARY KEY CLUSTERED ([intInterCompanyTransferLogId] ASC) ,
 CONSTRAINT [FK_dbo.tblSMInterCompanyTransferLog_tblSMInterCompany] FOREIGN KEY ([intDestinationCompanyId]) REFERENCES [tblSMInterCompany](intInterCompanyId)
)
