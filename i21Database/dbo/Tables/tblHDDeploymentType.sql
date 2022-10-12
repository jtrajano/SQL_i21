CREATE TABLE [dbo].[tblHDDeploymentType]
(
	[intDeploymentTypeId]					INT IDENTITY(1,1) NOT NULL,
    [strDeploymentType]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]						[int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDDeploymentType_intDeploymentTypeId] PRIMARY KEY CLUSTERED ([intDeploymentTypeId] ASC),
    CONSTRAINT [UQ_tblHDDeploymentType_strDeploymentType] UNIQUE ([strDeploymentType])
)

GO