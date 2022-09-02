CREATE TABLE [dbo].[tblSMRapidDeploymentConfiguration]
(
	[intRapidDeploymentConfigurationId] INT IDENTITY (1, 1) NOT NULL,
    [intModuleId]                       INT NOT NULL,
    [intEntityId]                       INT NOT NULL,
    [intConcurrencyId]                  INT DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblSMRapidDeploymentConfiguration] PRIMARY KEY CLUSTERED ([intRapidDeploymentConfigurationId] ASC)
)
