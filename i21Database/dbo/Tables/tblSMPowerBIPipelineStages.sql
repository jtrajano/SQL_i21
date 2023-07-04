CREATE TABLE [dbo].[tblSMPowerBIPipelineStages]
(
	[intPowerBIPipelineStagesId]	INT		NOT NULL	IDENTITY, 
	[strPipelineId]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPipeline]					NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDevWorkspaceId]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strTestWorkspaceId]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strProdWorkspaceId]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]				INT		NOT NULL	DEFAULT 1,

	CONSTRAINT [PK_tblSMPowerBIPipelineStages] PRIMARY KEY CLUSTERED ([intPowerBIPipelineStagesId] ASC),
	CONSTRAINT [UC_tblSMPowerBIPipelineStages_strPipelineId_strDevWorkspaceId] UNIQUE ([strPipelineId], [strDevWorkspaceId]),
	CONSTRAINT [UC_tblSMPowerBIPipelineStages_strPipelineId_strTesWorkspaceId] UNIQUE ([strPipelineId], [strTestWorkspaceId]),
	CONSTRAINT [UC_tblSMPowerBIPipelineStages_strPipelineId_strProdWorkspaceId] UNIQUE ([strPipelineId], [strProdWorkspaceId])
)
