CREATE TABLE [dbo].[tblAPVoucherPaymentSchedule]
(
	[intId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[intBillId] INT NOT NULL,
	[intTermsId] INT NOT NULL,
	[dtmDueDate] DATETIME,
	[dtmDiscountDate] DATETIME NULL,
	[dblPayment] DECIMAL(18,2),
	[dblDiscount] DECIMAL(18,2),
	[ysnPaid] BIT NOT NULL DEFAULT(0),
	[ysnScheduleDiscountOverride] BIT NOT NULL DEFAULT(0),
	[ysnReadyForPayment] BIT NOT NULL DEFAULT(0),
	[ysnInPayment] BIT NOT NULL DEFAULT 0,
	[intConcurrencyId] INT NOT NULL DEFAULT 0,
	CONSTRAINT [FK_tblAPVoucherPaymentSchedule_tblAPBill] FOREIGN KEY ([intBillId]) REFERENCES [dbo].[tblAPBill] ([intBillId]) ON DELETE CASCADE
)
