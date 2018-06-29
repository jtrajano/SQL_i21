CREATE TABLE [dbo].[tblTMWorkCloseReason] (
    [intCloseReasonID] INT           IDENTITY (1, 1) NOT NULL,
    [strCloseReason]   NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnDefault]       BIT           NULL DEFAULT 0,
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMWorkCloseReason] PRIMARY KEY CLUSTERED ([intCloseReasonID] ASC),
    CONSTRAINT [UQ_tblTMWorkCloseReason_strCloseReason] UNIQUE NONCLUSTERED ([strCloseReason] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkCloseReason',
    @level2type = N'COLUMN',
    @level2name = N'intCloseReasonID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Close Reason',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkCloseReason',
    @level2type = N'COLUMN',
    @level2name = N'strCloseReason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if default data',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkCloseReason',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkCloseReason',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'