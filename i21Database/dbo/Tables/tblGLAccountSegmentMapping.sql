CREATE TABLE [dbo].[tblGLAccountSegmentMapping] (
    [intAccountSegmentMappingId] INT IDENTITY (1, 1) NOT NULL,
    [intAccountId]               INT NULL,
    [intAccountSegmentId]        INT NULL,
    [intConcurrencyId]           INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLAccountSegmentMapping] PRIMARY KEY CLUSTERED ([intAccountSegmentMappingId] ASC),
    CONSTRAINT [FK_tblGLAccountSegmentMapping_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblGLAccountSegmentMapping_tblGLAccountSegment] FOREIGN KEY ([intAccountSegmentId]) REFERENCES [dbo].[tblGLAccountSegment] ([intAccountSegmentId]) 
);
GO

CREATE NONCLUSTERED INDEX [IX_tblGLAccountSegmentMapping_intAccountId]
    ON [dbo].[tblGLAccountSegmentMapping]([intAccountId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblGLAccountSegmentMapping_intAccountSegmentId]
    ON [dbo].[tblGLAccountSegmentMapping]([intAccountSegmentId] ASC);
GO

CREATE NONCLUSTERED INDEX IX_tblGLAccountSegmentMapping_intAccount_intAccountSegmentId
	ON [dbo].[tblGLAccountSegmentMapping] ([intAccountSegmentId])
	INCLUDE ([intAccountId])
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegmentMapping', @level2type=N'COLUMN',@level2name=N'intAccountSegmentMappingId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegmentMapping', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Segment Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegmentMapping', @level2type=N'COLUMN',@level2name=N'intAccountSegmentId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountSegmentMapping', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO

