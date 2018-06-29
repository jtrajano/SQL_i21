CREATE TABLE [dbo].[tblARSalespersonNote] (
    [intSalespersonNoteId] INT            IDENTITY (1, 1) NOT NULL,
    [intSalespersonId]     INT            NOT NULL,
    [dtmDate]              DATETIME       NOT NULL,
    [dtmTime]              DATETIME       NOT NULL,
    [intDuration]          INT            NULL,
    [strName]              NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strSubject]           NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strNotes]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]     INT            CONSTRAINT [DF_tblARSalespersonNote_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARSalespersonNote] PRIMARY KEY CLUSTERED ([intSalespersonNoteId] ASC)
);

