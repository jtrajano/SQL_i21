﻿CREATE TABLE [dbo].[tblGLAccountSegmentMapping] (
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