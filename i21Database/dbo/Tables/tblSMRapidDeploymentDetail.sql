CREATE TABLE [dbo].[tblSMRapidDeploymentDetail]
(
	[intRapidDeploymentDetailId]  INT IDENTITY (1, 1) NOT NULL,
	[intRapidDeploymentId]  INT NOT NULL,
	[intParentTaskId]		INT DEFAULT (0) NOT NULL,
	[strTask]				NVARCHAR(255) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTaskScreenLink]		NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strHelpManualLink]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strHelpDeskLink]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strRelatedVideos]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strUserDefinedLink]	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strConfigurationNotes]	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intUserAssignedId]		INT NULL,
	[intUserCompletedId]	INT NULL,
	[strStatus]				NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[strType]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strVersion]			NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
	[ysnNotUsed]			BIT DEFAULT (0) NOT NULL,
	[ysnChild]				BIT DEFAULT (0) NOT NULL,
    [intConcurrencyId]      INT DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_tblSMRapidDeploymentDetail] PRIMARY KEY CLUSTERED ([intRapidDeploymentDetailId] ASC),
	CONSTRAINT [FK_tblSMRapidDeployment] FOREIGN KEY ([intRapidDeploymentId]) REFERENCES [dbo].[tblSMRapidDeployment](intRapidDeploymentId) ON DELETE CASCADE
)
