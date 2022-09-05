CREATE TABLE [dbo].[tblSMRapidDeploymentConfigurationDetail]
(
	[intRapidDeploymentConfigurationDetailId]	INT IDENTITY (1, 1) NOT NULL,
	[intRapidDeploymentConfigurationId]			INT NOT NULL,
	[intParentTaskId]							INT DEFAULT (0) NOT NULL,
	[intSort]									INT NULL,
	[strTask]									NVARCHAR(255) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTaskScreenLink]							NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strTaskScreenParam]						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strHelpManualLink]							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strHelpDeskLink]							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strRelatedVideos]							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strUserDefinedLink]						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strConfigurationNotes]						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strType]									NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strVersion]								NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
	[ysnNotUsed]								BIT DEFAULT (0) NOT NULL,
	[ysnRoot]									BIT DEFAULT (0) NOT NULL,
	[ysnChild]									BIT DEFAULT (0) NOT NULL,
    [intConcurrencyId]							INT DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblSMRapidDeploymentConfigurationDetail] PRIMARY KEY CLUSTERED ([intRapidDeploymentConfigurationDetailId] ASC),
	CONSTRAINT [FK_tblSMRapidDeploymentConfiguration] FOREIGN KEY ([intRapidDeploymentConfigurationId]) REFERENCES [dbo].[tblSMRapidDeploymentConfiguration]([intRapidDeploymentConfigurationId]) ON DELETE CASCADE
)
