CREATE TABLE [dbo].[tblEntityCredential] (
    [intEntityCredentialId] INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]           INT            NOT NULL,
    [strUserName]           NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strPassword]           NVARCHAR (100) NOT NULL,
    [strApiKey]				NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL, 
    [strApiSecret]			NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL, 
    [ysnApiDisabled]		BIT NULL, 
	[strTFASecretKey]		NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL, 
	[strTFACurrentCode]     NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL, 
	[ysnTFAEnabled]			BIT            DEFAULT ((0)) NULL, 
	[intEntityRoleId]		INT				NULL,
    [intConcurrencyId]      INT            DEFAULT ((1)) NOT NULL
    CONSTRAINT [PK_tblEntityCredential] PRIMARY KEY CLUSTERED ([intEntityCredentialId] ASC),
    CONSTRAINT [FK_tblEntityCredential_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]) ON DELETE CASCADE,
    CONSTRAINT [AK_tblEntityCredential_strUserName] UNIQUE NONCLUSTERED ([strUserName] ASC),
	CONSTRAINT [FK_tblEntityCredential_tblSMUserRole] FOREIGN KEY ([intEntityRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID])
);




