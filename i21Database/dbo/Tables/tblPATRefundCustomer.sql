CREATE TABLE [dbo].[tblPATRefundCustomer]
(
	[intRefundCustomerId] INT NOT NULL IDENTITY, 
    [intRefundId] INT NOT NULL, 
    [intCustomerId] INT NULL, 
	[strStockStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [ysnEligibleRefund] BIT NULL, 
    [intRefundTypeId] INT NULL, 
    [dblCashPayout] NUMERIC(18, 6) NULL, 
    [ysnQualified] BIT NULL, 
    [dblRefundAmount] NUMERIC(18, 6) NULL, 
	[dblNonRefundAmount] NUMERIC(18,6) NULL,
    [dblCashRefund] NUMERIC(18, 6) NULL, 
    [dblEquityRefund] NUMERIC(18, 6) NULL,
	[intBillId] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATRefundCustomer] PRIMARY KEY ([intRefundCustomerId]), 
    CONSTRAINT [FK_tblPATRefundCustomer_tblPATRefund] FOREIGN KEY (intRefundId) REFERENCES [tblPATRefund]([intRefundId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblPATRefundCustomer_tblPATRefundRate] FOREIGN KEY (intRefundTypeId) REFERENCES [tblPATRefundRate]([intRefundTypeId]),
	CONSTRAINT [FK_tblPATRefundCustomer_tblAPBill] FOREIGN KEY (intBillId) REFERENCES [tblAPBill]([intBillId]) ON DELETE SET NULL
)
