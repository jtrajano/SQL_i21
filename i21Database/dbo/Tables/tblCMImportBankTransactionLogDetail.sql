create table [dbo].[tblCMImportBankTransactionLogDetail] (
    [intImportLogDetailId] [int] NOT NULL IDENTITY(1,1),
    [intImportLogId] [int] NOT NULL,
    [strTransactionId] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL,
	[ysnPosted] [bit] NULL,
	[intTransactionId] [int] NULL,
	[intLineNo] [int] NULL,
	[intBankTransactionTypeId] [int] NULL,
    primary key ([intImportLogDetailId])
);
GO
ALTER TABLE [dbo].[tblCMImportBankTransactionLogDetail] 
ADD CONSTRAINT [tblCMImportBankTransactionLogDetail_tblCMImportBankTransactionLog] 
FOREIGN KEY ([intImportLogId]) 
REFERENCES [dbo].[tblCMImportBankTransactionLog]([intImportLogId]) ON DELETE CASCADE;
GO
