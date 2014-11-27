CREATE TABLE [dbo].[tblSMCompanyLocationAccount]
(
	[intCompanyLocationAccountId] INT NOT NULL PRIMARY KEY IDENTITY, 
	[intCompanyLocationId] INT NOT NULL, 
	[strAccountDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intAccountId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1)
)
GO

CREATE NONCLUSTERED INDEX [IX_tblSMCompanyLocationAccount_intCompanyLocationId]
    ON [dbo].[tblSMCompanyLocationAccount]([intCompanyLocationId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblSMCompanyLocationAccount_intAccountId]
    ON [dbo].[tblSMCompanyLocationAccount]([intAccountId] ASC);
GO