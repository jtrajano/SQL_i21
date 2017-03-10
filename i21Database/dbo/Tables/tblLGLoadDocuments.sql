CREATE TABLE [dbo].[tblLGLoadDocuments]
(
[intLoadDocumentId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intLoadId] INT NOT NULL,
[intDocumentId] INT NOT NULL,
[strDocumentType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[strDocumentNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intOriginal] INT NULL,
[intCopies] INT NULL,
[ysnSent] [bit] NULL,
[dtmSentDate] DATETIME NULL,
[ysnReceived] [bit] NULL,
[dtmReceivedDate] DATETIME NULL,

CONSTRAINT [PK_tblLGLoadDocuments] PRIMARY KEY ([intLoadDocumentId]), 
CONSTRAINT [FK_tblLGLoadDocuments_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]) ON DELETE CASCADE,
CONSTRAINT [FK_tblLGLoadDocuments_tblICDocument_intDocumentId] FOREIGN KEY ([intDocumentId]) REFERENCES [tblICDocument]([intDocumentId])
)
