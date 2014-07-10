CREATE TABLE [dbo].[cstGLJournal] (
    [intId] INT NOT NULL,
    CONSTRAINT [PK_cstGLJournal] PRIMARY KEY CLUSTERED ([intId] ASC),
    CONSTRAINT [FK_cstGLJournal_cstGLJournal] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblGLJournal] ([intJournalId]) ON DELETE CASCADE
);

