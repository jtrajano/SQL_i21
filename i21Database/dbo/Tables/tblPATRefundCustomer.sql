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
    [dblCashRefund] NUMERIC(18, 6) NULL, 
    [dblEquityRefund] NUMERIC(18, 6) NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATRefundCustomer] PRIMARY KEY ([intRefundCustomerId]), 
    CONSTRAINT [FK_tblPATRefundCustomer_tblPATRefund] FOREIGN KEY (intRefundId) REFERENCES [tblPATRefund]([intRefundId]) ON DELETE CASCADE
)
