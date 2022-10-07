CREATE TABLE [dbo].[tblCRMHubspotConfig]
(
	[intHubspotConfigId] INT IDENTITY(1,1) NOT NULL, 
    [strHsClientId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strHsClientSecret] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strHsRedirectUrl] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strHsRefreshToken] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
    CONSTRAINT [PK_tblCRMHubspotConfig] PRIMARY KEY CLUSTERED ([intHubspotConfigId] ASC)
)
