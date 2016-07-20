CREATE TABLE [dbo].[tblEMEntitySMTPInformation]
(
	[intSMTPInformationId]			INT NOT NULL IDENTITY(1,1),
	[intEntityId]					INT NOT NULL,
	[strFromName]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 		
	[strFromEmail]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 		
	[strSMTPServer]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 		
	[strSMTPPort]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 		
	[strSMTPEncryption]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 		
	[strUserName]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 		
	[strPassword]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 		
	[ysnUseProfileNameAndEmail]		BIT DEFAULT(1),
	[ysnUseGlobalSMTPServer]		BIT DEFAULT(1),
	[ysnRequiresAuthentication]		BIT DEFAULT(1),
	[intConcurrencyId]				INT DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblEMEntitySMTPInformation] PRIMARY KEY CLUSTERED ([intSMTPInformationId] ASC),	
	CONSTRAINT [FK_tblEMEntitySMTPInformation_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE,
)
GO

CREATE NONCLUSTERED INDEX [IX_tblEMEntitySMTPInformation_intEntityId]
    ON [dbo].[tblEMEntitySMTPInformation]([intEntityId] ASC);
