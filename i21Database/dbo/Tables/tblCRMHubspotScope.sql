CREATE TABLE [dbo].[tblCRMHubspotScope]
(
	[intHubspotScopeId] INT IDENTITY(1,1) NOT NULL, 
    [strScope] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [ysnEnabled] BIT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
    CONSTRAINT [PK_tblCRMHubspotScope] PRIMARY KEY CLUSTERED ([intHubspotScopeId] ASC)
)
