CREATE TABLE [dbo].[tblLGShippingInstructionCertificates]
(
[intShippingInstructionCertificateId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intShippingInstructionId] INT NOT NULL,
[intDocumentId] INT NOT NULL,
[strDocumentType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
[intOriginal] INT NULL,
[intCopies] INT NULL,

CONSTRAINT [PK_tblLGShippingInstructionCertificates] PRIMARY KEY ([intShippingInstructionCertificateId]), 
CONSTRAINT [FK_tblLGShippingInstructionCertificates_tblLGShippingInstruction_intShippingInstructionId] FOREIGN KEY ([intShippingInstructionId]) REFERENCES [tblLGShippingInstruction]([intShippingInstructionId]) ON DELETE CASCADE,
CONSTRAINT [FK_tblLGShippingInstructionCertificates_tblICDocument_intDocumentId] FOREIGN KEY ([intDocumentId]) REFERENCES [tblICDocument]([intDocumentId])
)
