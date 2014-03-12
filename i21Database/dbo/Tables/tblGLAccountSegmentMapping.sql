CREATE TABLE [dbo].[tblGLAccountSegmentMapping] (
    [intAccountSegmentMappingId] INT IDENTITY (1, 1) NOT NULL,
    [intAccountId]               INT NULL,
    [intAccountSegmentId]        INT NULL,
    [intConcurrencyId]           INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLAccountSegmentMapping] PRIMARY KEY CLUSTERED ([intAccountSegmentMappingId] ASC),
    CONSTRAINT [FK_tblGLAccountSegmentMapping_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblGLAccountSegmentMapping_tblGLAccountSegment] FOREIGN KEY ([intAccountSegmentId]) REFERENCES [dbo].[tblGLAccountSegment] ([intAccountSegmentId]) ON DELETE CASCADE
);

