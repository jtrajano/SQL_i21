CREATE TABLE [dbo].[tblTMHoldReason] (
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    [intHoldReasonID]  INT           IDENTITY (1, 1) NOT NULL,
    [strHoldReason]    NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMHoldReason] PRIMARY KEY CLUSTERED ([intHoldReasonID] ASC),
	CONSTRAINT [UQ_tblTMHoldReason_strHoldReason] UNIQUE NONCLUSTERED ([strHoldReason] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMHoldReason',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMHoldReason',
    @level2type = N'COLUMN',
    @level2name = N'intHoldReasonID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hold Reason',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMHoldReason',
    @level2type = N'COLUMN',
    @level2name = N'strHoldReason'