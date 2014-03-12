CREATE TABLE [dbo].[tblGLAccountAllocationDetail] (
    [intAccountAllocationDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intAllocatedAccountId]        INT             NOT NULL,
    [intAccountId]                 INT             NOT NULL,
    [strJobId]                     NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
    [dblPercentage]                NUMERIC (10, 2) NULL,
    [intConcurrencyId]             INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLAccountAllocationDetail_1] PRIMARY KEY CLUSTERED ([intAccountAllocationDetailId] ASC),
    CONSTRAINT [FK_tblGLAccountAllocationDetail_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblGLAccountAllocationDetail_tblGLAccount1] FOREIGN KEY ([intAllocatedAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId])
);

