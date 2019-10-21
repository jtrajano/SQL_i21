CREATE TABLE [dbo].[tblEMEntitySignature]
(
	[intEntitySignatureId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[intEntityId] INT NOT NULL,
	[intNewMessageSignatureId] INT NULL,
	[intReplyMessageSignatureId] INT NULL,
	[intHelpDeskSignatureId] INT NULL,
	[intElectronicSignatureId] INT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT(1),

	
	CONSTRAINT [FK_tblEMEntitySignature_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblEMEntitySignature_tblSMSignature_intNewMessageSignatureId] FOREIGN KEY ([intNewMessageSignatureId]) REFERENCES [dbo].[tblSMSignature] ([intSignatureId]),
	CONSTRAINT [FK_tblEMEntitySignature_tblSMSignature_intReplyMessageSignatureId] FOREIGN KEY ([intReplyMessageSignatureId]) REFERENCES [dbo].[tblSMSignature] ([intSignatureId]),
	CONSTRAINT [FK_tblEMEntitySignature_tblSMSignature_intHelpDeskSignatureId] FOREIGN KEY ([intHelpDeskSignatureId]) REFERENCES [dbo].[tblSMSignature] ([intSignatureId]),
	CONSTRAINT [FK_tblEMEntitySignature_tblSMSignature_intNElectronicSignatureId] FOREIGN KEY ([intElectronicSignatureId]) REFERENCES [dbo].[tblSMSignature] ([intSignatureId]),


)
