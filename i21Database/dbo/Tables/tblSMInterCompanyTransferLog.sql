CREATE TABLE tblSMInterCompanyTransferLog
(
 [intInterCompanyTransferLogId] int identity(1,1),
 [strType] nvarchar(100) collate Latin1_General_CI_AS  null,
 [intSourceRecordId] int null,
 [intDestinationRecordId] int null,
 CONSTRAINT [PK_tblSMInterCompanyTransferLog] PRIMARY KEY CLUSTERED ([intInterCompanyTransferLogId] ASC) 
)
