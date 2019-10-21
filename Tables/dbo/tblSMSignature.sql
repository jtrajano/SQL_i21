CREATE TABLE [dbo].[tblSMSignature]
(
	[intSignatureId]		INT											NOT NULL PRIMARY KEY IDENTITY, 
	[strName]				NVARCHAR(50) COLLATE Latin1_General_CI_AS	NOT NULL, 
    [intEntityId]			INT											NOT NULL, 
    [blbDetail]				VARBINARY(MAX)								NULL, 
    [intConcurrencyId]		INT											NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMSignature_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId])
)
