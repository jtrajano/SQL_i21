CREATE TABLE [dbo].[tblEntityNote] (
    [intEntityNoteId]  INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]      INT            NOT NULL,
    [dtmDate]          DATETIME       NOT NULL,
    [dtmTime]          DATETIME       NOT NULL,
    [intDuration]      INT            NULL,
	[strUser]       NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strSubject]       NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strNotes]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblEntityNotes_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEntityNote] PRIMARY KEY CLUSTERED ([intEntityNoteId] ASC)
);



