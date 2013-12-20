CREATE TABLE [dbo].[tblGLCOAAdjustment] (
    [intCOAAdjustmentID] INT            IDENTITY (1, 1) NOT NULL,
    [strCOAAdjustmentID] NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [intUserID]          INT            NULL,
    [dtmDate]            DATETIME       NULL,
    [memNotes]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnposted]          BIT            NULL,
    [intConcurrencyID]   INT            NULL,
    CONSTRAINT [PK_tblGLCOAAdjustment] PRIMARY KEY CLUSTERED ([intCOAAdjustmentID] ASC)
);

