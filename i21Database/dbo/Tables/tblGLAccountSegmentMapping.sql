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

CREATE TRIGGER [dbo].[trgInsertGLSegmentMapping]
ON [dbo].[tblGLAccountSegmentMapping]
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @i INT

	SELECT @i = intAccountId 
	FROM INSERTED ins JOIN tblGLAccountSegment seg ON ins.intAccountSegmentId = seg.intAccountSegmentId
	JOIN tblGLAccountStructure st ON st.intAccountStructureId = seg.intAccountStructureId
	JOIN tblGLAccountGroup gr ON gr.intAccountGroupId = seg.intAccountGroupId
	WHERE strType = 'Primary' AND strAccountType IN ('Asset', 'Liability', 'Equity')

	IF @i IS NOT NULL
		UPDATE A SET  ysnRevalue = 1  FROM tblGLAccount A  WHERE @i = intAccountId


END

GO