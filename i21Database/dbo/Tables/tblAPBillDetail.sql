CREATE TABLE [dbo].[tblAPBillDetail] (
    [intBillDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intBillId]       INT             NOT NULL,
    [strDescription]  NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]    INT             NOT NULL,
    [dblTotal]        DECIMAL (18, 6) NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [dblQtyOrdered] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblQtyReceived] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    CONSTRAINT [PK__tblAPBil__DCE2CCF4681FF753] PRIMARY KEY CLUSTERED ([intBillDetailId] ASC) ON [PRIMARY],
    CONSTRAINT [FK_tblAPBillDetail_tblAPBill] FOREIGN KEY ([intBillId]) REFERENCES [dbo].[tblAPBill] ([intBillId]) ON DELETE CASCADE
) ON [PRIMARY];

