CREATE TABLE [dbo].[tblEMEntityCRMInformation]
(
	[intEntityInformationId]	INT NOT NULL IDENTITY(1,1),
	[intEntityId]				INT NOT NULL,
	[intEntityAssociationId]	INT NULL,
	[ysnOutOfAdvertising]		BIT DEFAULT(0) NOT NULL,
	[dtmOutDate]				DATETIME NULL,
	[intConcurrencyId]			INT DEFAULT(0) NOT NULL,

	CONSTRAINT [PK_tblEMEntityCRMInformation] PRIMARY KEY CLUSTERED ([intEntityInformationId]),
	CONSTRAINT [FK_tblEMEntityCRMInformation_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity]([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblEMEntityCRMInformation_tblEMEntity_intEntityAssociationId] FOREIGN KEY ([intEntityAssociationId]) REFERENCES [dbo].[tblEMEntity]([intEntityId]),
)
