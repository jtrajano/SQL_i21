CREATE TABLE [dbo].[tblAPBillBatches] (
    [intBillBatchId]     INT             IDENTITY (1, 1) NOT NULL,
    [intAccountId]       INT             NOT NULL,
    [ysnPosted]          BIT             DEFAULT ((0)) NULL,
    [strBillBatchNumber] AS              ('BB-'+CONVERT([varchar](5),[intBillBatchId],0) collate Latin1_General_CI_AS),
    [strReference]       NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblTotal]           DECIMAL (18, 2) NOT NULL,
    CONSTRAINT [PK_dbo.tblAPBillBatches] PRIMARY KEY CLUSTERED ([intBillBatchId] ASC)
);



