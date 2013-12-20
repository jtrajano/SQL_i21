CREATE TABLE [dbo].[tblGLAccountReallocationDetail] (
    [intAccountReallocationDetailID] INT             IDENTITY (1, 1) NOT NULL,
    [intAccountReallocationID]       INT             NULL,
    [intAccountID]                   INT             NOT NULL,
    [strJobID]                       NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
    [dblPercentage]                  NUMERIC (10, 2) NULL,
    [intConcurrencyID]               INT             CONSTRAINT [DF_tblGLAccountReallocationDetail_intConcurrencyID] DEFAULT ((1)) NULL,
    [dblUnit]                        NUMERIC (18, 6) NULL,
    CONSTRAINT [PK_tblGLAccountReallocationDetail] PRIMARY KEY CLUSTERED ([intAccountReallocationDetailID] ASC),
    CONSTRAINT [FK_tblGLAccountReallocationDetail_tblGLAccount] FOREIGN KEY ([intAccountID]) REFERENCES [dbo].[tblGLAccount] ([intAccountID]),
    CONSTRAINT [FK_tblGLAccountReallocationDetail_tblGLAccountReallocation] FOREIGN KEY ([intAccountReallocationID]) REFERENCES [dbo].[tblGLAccountReallocation] ([intAccountReallocationID])
);

