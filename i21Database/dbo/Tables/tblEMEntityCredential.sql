CREATE TABLE [dbo].[tblEMEntityCredential] (
    [intEntityCredentialId] INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]           INT            NOT NULL,
    [strUserName]           NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strPassword]           NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strApiKey]				NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL, 
    [strApiSecret]			NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL, 
    [ysnApiDisabled]		BIT NULL, 
	[strTFASecretKey]		NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL, 
	[strTFACurrentCode]     NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTFACodeNotifMedium] NVARCHAR(50)   COLLATE Latin1_General_CI_AS NULL,
	[ysnTFAEnabled]			BIT            DEFAULT ((0)) NULL,
    [ysnNotEncrypted]       BIT            DEFAULT ((1)) NOT NULL,
    [intConcurrencyId]      INT            DEFAULT ((1)) NOT NULL
    CONSTRAINT [PK_tblEMEntityCredential] PRIMARY KEY CLUSTERED ([intEntityCredentialId] ASC),
    CONSTRAINT [FK_tblEMEntityCredential_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE,
    CONSTRAINT [AK_tblEMEntityCredential_strUserName] UNIQUE NONCLUSTERED ([strUserName] ASC)
);




