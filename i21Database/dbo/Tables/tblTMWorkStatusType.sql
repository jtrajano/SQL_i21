CREATE TABLE [dbo].[tblTMWorkStatusType] (
    [intWorkStatusID]  INT           IDENTITY (1, 1) NOT NULL,
    [strWorkStatus]    NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnDefault]       BIT           NULL,
    [intConcurrencyId] INT           DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblTMWorkStatus] PRIMARY KEY CLUSTERED ([intWorkStatusID] ASC),
    CONSTRAINT [UQ_tblTMWorkStatusType_strWorkStatus] UNIQUE NONCLUSTERED ([strWorkStatus] ASC)
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkStatusType',
    @level2type = N'COLUMN',
    @level2name = N'intWorkStatusID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Work Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkStatusType',
    @level2type = N'COLUMN',
    @level2name = N'strWorkStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if default data',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkStatusType',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkStatusType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'