CREATE TABLE [dbo].[tblGLAccountReallocationDetail] (
    [intAccountReallocationDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intAccountReallocationId]       INT             NULL,
    [intAccountId]                   INT             NOT NULL,
    [strJobId]                       NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
    [dblPercentage]                  NUMERIC (10, 2) NULL,
    [intConcurrencyId]               INT             DEFAULT 1 NOT NULL,
    [dblUnit]                        NUMERIC (18, 6) NULL,
    CONSTRAINT [PK_tblGLAccountReallocationDetail] PRIMARY KEY CLUSTERED ([intAccountReallocationDetailId] ASC),
    CONSTRAINT [FK_tblGLAccountReallocationDetail_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblGLAccountReallocationDetail_tblGLAccountReallocation] FOREIGN KEY ([intAccountReallocationId]) REFERENCES [dbo].[tblGLAccountReallocation] ([intAccountReallocationId])
);

