CREATE TABLE [dbo].[tblGLAccountSegmentMapping] (
    [intAccountSegmentMappingID] INT IDENTITY (1, 1) NOT NULL,
    [intAccountID]               INT NULL,
    [intAccountSegmentID]        INT NULL,
    [intConcurrencyID]           INT NULL,
    CONSTRAINT [PK_tblGLAccountSegmentMapping] PRIMARY KEY CLUSTERED ([intAccountSegmentMappingID] ASC),
    CONSTRAINT [FK_tblGLAccountSegmentMapping_tblGLAccount] FOREIGN KEY ([intAccountID]) REFERENCES [dbo].[tblGLAccount] ([intAccountID]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblGLAccountSegmentMapping_tblGLAccountSegment] FOREIGN KEY ([intAccountSegmentID]) REFERENCES [dbo].[tblGLAccountSegment] ([intAccountSegmentID]) ON DELETE CASCADE
);

