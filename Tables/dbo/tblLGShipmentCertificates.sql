CREATE TABLE [dbo].[tblLGShipmentCertificates]
(
[intShipmentCertificateId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intShipmentId] INT NOT NULL,
[intDocumentId] INT NOT NULL,
[strDocumentType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intOriginal] INT NULL,
[intCopies] INT NULL,
[ysnSent] [bit] NULL,
[dtmSentDate] DATETIME NULL,
[ysnReceived] [bit] NULL,
[dtmReceivedDate] DATETIME NULL,

CONSTRAINT [PK_tblLGShipmentCertificates] PRIMARY KEY ([intShipmentCertificateId]), 
CONSTRAINT [FK_tblLGShipmentCertificates_tblLGShipment_intShipmentId] FOREIGN KEY ([intShipmentId]) REFERENCES [tblLGShipment]([intShipmentId]) ON DELETE CASCADE,
CONSTRAINT [FK_tblLGShipmentCertificates_tblICDocument_intDocumentId] FOREIGN KEY ([intDocumentId]) REFERENCES [tblICDocument]([intDocumentId])
)
