CREATE TABLE [dbo].[tblSMInterCompany]
(
 [intInterCompanyId]		INT NOT NULL		IDENTITY,
 [strCompanyName]			NVARCHAR(150)		COLLATE Latin1_General_CI_AS NULL,
 [strDatabaseName]			NVARCHAR(150)		COLLATE Latin1_General_CI_AS NULL,
 [strServerName]			NVARCHAR(150)		COLLATE Latin1_General_CI_AS NULL,
 [strUserName]				NVARCHAR(50)		COLLATE Latin1_General_CI_AS NULL,
 [strPassword]				NVARCHAR(50)		COLLATE Latin1_General_CI_AS NULL,
 [intInterCompanyParentId]  INT					NULL,
 [intConcurrencyId]			INT					NOT NULL
 CONSTRAINT [PK_dbo.tblSMInterCompany] PRIMARY KEY CLUSTERED ([intInterCompanyId] ASC),
 CONSTRAINT [FK_tblSMInterCompany_tblSMInterCompany] FOREIGN KEY ([intInterCompanyParentId]) REFERENCES [dbo].[tblSMInterCompany] ([intInterCompanyId])

)