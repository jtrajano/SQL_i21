CREATE TABLE [dbo].[tblGLAccountAllocationDetail] (
    [intAccountAllocationDetailID] INT             IDENTITY (1, 1) NOT NULL,
    [intAllocatedAccountID]        INT             NOT NULL,
    [intAccountID]                 INT             NOT NULL,
    [strJobID]                     NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
    [dblPercentage]                NUMERIC (10, 2) NULL,
    [intConcurrencyID]             INT             CONSTRAINT [DF__tblGLAcco__intCo__695C9DA1] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblGLAccountAllocationDetail_1] PRIMARY KEY CLUSTERED ([intAccountAllocationDetailID] ASC),
    CONSTRAINT [FK_tblGLAccountAllocationDetail_tblGLAccount] FOREIGN KEY ([intAccountID]) REFERENCES [dbo].[tblGLAccount] ([intAccountID]),
    CONSTRAINT [FK_tblGLAccountAllocationDetail_tblGLAccount1] FOREIGN KEY ([intAllocatedAccountID]) REFERENCES [dbo].[tblGLAccount] ([intAccountID])
);

