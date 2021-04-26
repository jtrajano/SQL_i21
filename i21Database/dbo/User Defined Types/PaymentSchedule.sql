CREATE TYPE [dbo].[PaymentSchedule] AS TABLE
(
    [intBillId] INT NOT NULL,
	[intTermsId] INT NOT NULL,
	[dtmDueDate] DATETIME,
	[dtmDiscountDate] DATETIME NULL,
	[dblPayment] DECIMAL(18,2),
	[dblDiscount] DECIMAL(18,2),
	[ysnPaid] BIT NOT NULL DEFAULT(0),
	[ysnScheduleDiscountOverride] BIT NOT NULL DEFAULT(0)
)