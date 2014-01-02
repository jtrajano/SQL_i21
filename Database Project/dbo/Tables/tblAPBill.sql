CREATE TABLE [dbo].[tblAPBill] (
    [intBillId]            INT             IDENTITY (1, 1) NOT NULL,
    [intBillBatchId]       INT             NOT NULL,
    [strVendorId]          NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strVendorOrderNumber] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intTermsId]           INT             NOT NULL,
    [intTaxCodeId]         INT             NULL,
    [dtmDate]              DATETIME        NOT NULL,
    [dtmBillDate]          DATETIME        NOT NULL,
    [dtmDueDate]           DATETIME        NOT NULL,
    [intAccountId]         INT             NOT NULL,
    [strDescription]       NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblTotal]             DECIMAL (18, 2) NOT NULL,
    [ysnPosted]            BIT             NOT NULL,
    [ysnPaid]              BIT             NOT NULL,
    [strBillId]            AS              ('BL-'+CONVERT([varchar](5),[intBillId],(0)) collate Latin1_General_CI_AS),
    [dblAmountDue]         DECIMAL (18, 2) NOT NULL,
    CONSTRAINT [PK_dbo.tblAPBill] PRIMARY KEY CLUSTERED ([intBillId] ASC),
    CONSTRAINT [FK_dbo.tblAPBill_dbo.tblAPBillBatch_intBillBatchId] FOREIGN KEY ([intBillBatchId]) REFERENCES [dbo].[tblAPBillBatch] ([intBillBatchId]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_intBillBatchId]
    ON [dbo].[tblAPBill]([intBillBatchId] ASC);

