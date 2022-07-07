CREATE TABLE [dbo].[tblCMImportBankTransactionLog] (
    [intImportLogId] INT NOT NULL IDENTITY(1,1),
    [strBuildNumber] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
    [dtmDate] DATETIME NOT NULL,
    [strFileName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intEntityId] INT NOT NULL,
    [strLogDescription] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL,
    primary key ([intImportLogId])
);
GO
ALTER TABLE [dbo].[tblCMImportBankTransactionLog]  WITH CHECK ADD  CONSTRAINT [tblCMImportBankTransactionLog_tblSMUserSecurity] FOREIGN KEY([intEntityId])
REFERENCES [dbo].[tblSMUserSecurity] ([intEntityId])
GO
ALTER TABLE [dbo].[tblCMImportBankTransactionLog] CHECK CONSTRAINT [tblCMImportBankTransactionLog_tblSMUserSecurity]
GO


