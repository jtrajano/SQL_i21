CREATE TABLE [dbo].[tblEntityNote] (
    [intEntityNoteId]  INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]      INT            NOT NULL,
    [dtmDate]          DATETIME       NULL,
    [dtmTime]          DATETIME       NULL,
    [intDuration]      INT            NULL,
    [strName]          NVARCHAR (100) NULL,
    [strSubject]       NVARCHAR (100) NULL,
    [strNotes]         NVARCHAR (MAX) NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblEntityNotes_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEntityNote] PRIMARY KEY CLUSTERED ([intEntityNoteId] ASC)
);

