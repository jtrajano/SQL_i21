CREATE TABLE [dbo].[tblTMFillGroup] (
    [intFillGroupId]   INT           IDENTITY (1, 1) NOT NULL,
    [strFillGroupCode] NVARCHAR (6)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]   NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [ysnActive]        BIT           NULL DEFAULT 1,
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMFillGroup] PRIMARY KEY CLUSTERED ([intFillGroupId] ASC),
    CONSTRAINT [UQ_tblTMFillGroup_strFillGroupCode] UNIQUE NONCLUSTERED ([strFillGroupCode] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMFillGroup',
    @level2type = N'COLUMN',
    @level2name = N'intFillGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fill Group Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMFillGroup',
    @level2type = N'COLUMN',
    @level2name = N'strFillGroupCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMFillGroup',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMFillGroup',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMFillGroup',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'