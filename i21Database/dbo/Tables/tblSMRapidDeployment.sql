CREATE TABLE [dbo].[tblSMRapidDeployment]
(
	[intRapidDeploymentId]  INT IDENTITY (1, 1) NOT NULL,
    [intModuleId]           INT NOT NULL,
    [intConcurrencyId]      INT DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblSMRapidDeployment] PRIMARY KEY CLUSTERED ([intRapidDeploymentId] ASC)
)
