CREATE TABLE [dbo].[tblGLCOAAdjustment] (
    [intCOAAdjustmentId] INT            IDENTITY (1, 1) NOT NULL,
    [strCOAAdjustmentId] NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [intUserId]          INT            NULL,
    [dtmDate]            DATETIME       NULL,
    [memNotes]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnPosted]          BIT            NULL,
    [intConcurrencyId]   INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLCOAAdjustment] PRIMARY KEY CLUSTERED ([intCOAAdjustmentId] ASC)
);

