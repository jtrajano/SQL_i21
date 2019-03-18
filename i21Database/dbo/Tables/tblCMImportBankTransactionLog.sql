CREATE TABLE [dbo].[tblCMImportBankTransactionLog] (
    [intImportLogId] [int] NOT NULL IDENTITY(1,1),
    [strBuildNumber] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
    [dtmDate] [datetime] NOT NULL,
    [strFile] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
    [intEntityId] INT NOT NULL,
    [strLogDescription] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] [int] NOT NULL,
    primary key ([intImportLogId])
);
GO
ALTER TABLE [dbo].[tblCMImportBankTransactionLog]  WITH CHECK ADD  CONSTRAINT [tblCMImportBankTransactionLog_tblSMUserSecurity] FOREIGN KEY([intEntityId])
REFERENCES [dbo].[tblSMUserSecurity] ([intEntityId])
GO
ALTER TABLE [dbo].[tblCMImportBankTransactionLog] CHECK CONSTRAINT [tblCMImportBankTransactionLog_tblSMUserSecurity]
GO


