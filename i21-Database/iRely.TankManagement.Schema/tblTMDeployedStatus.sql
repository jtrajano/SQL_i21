CREATE TABLE [dbo].[tblTMDeployedStatus] (
    [intConcurrencyId]    INT           DEFAULT 1 NOT NULL,
    [intDeployedStatusID] INT           IDENTITY (1, 1) NOT NULL,
    [strDeployedStatus]   NVARCHAR (50) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMDeployedStatus_strDeployedStatus] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMDeployedStatus] PRIMARY KEY CLUSTERED ([intDeployedStatusID] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeployedStatus',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeployedStatus',
    @level2type = N'COLUMN',
    @level2name = N'intDeployedStatusID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deployed Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeployedStatus',
    @level2type = N'COLUMN',
    @level2name = N'strDeployedStatus'