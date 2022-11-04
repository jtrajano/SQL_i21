CREATE TABLE [dbo].[tblCRMHubspotConfig]
(
	[intHubspotConfigId] INT IDENTITY(1,1) NOT NULL, 
    [strHsClientId] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strHsClientSecret] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strHsInstallationUrl] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strHsTokenUrl] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strHsApiUrl] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strHsi21RedirectUrl] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strHsi21AuthorizeUrl] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strHsRefreshToken] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strScopesId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
    CONSTRAINT [PK_tblCRMHubspotConfig] PRIMARY KEY CLUSTERED ([intHubspotConfigId] ASC)
)
