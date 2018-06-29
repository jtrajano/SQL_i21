CREATE TABLE [dbo].[tblGRStorageDiscount]
(
	[intStorageDiscountId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [intCustomerStorageId] INT NOT NULL, 
    [strDiscountCode] NVARCHAR(3) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblGradeReading] DECIMAL(18, 6) NOT NULL, 
    [strCalcMethod] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [dblDiscountAmount] DECIMAL(18, 6) NULL, 
    [strShrinkWhat] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [dblShrinkPercent] DECIMAL(18, 6) NOT NULL,
	[dblDiscountDue] DECIMAL(18, 6) NULL,
	[dblDiscountPaid] DECIMAL(18, 6) NULL, 
    [dtmDiscountPaidDate] DATETIME NULL, 
    [intDiscountScheduleCodeId] INT NOT NULL, 
    CONSTRAINT [PK_tblGRStorageDiscount_intStorageDiscountId] PRIMARY KEY ([intStorageDiscountId]),
	CONSTRAINT [FK_tblGRStorageDiscount_tblGRCustomerStorage_intCustomerStorageId] FOREIGN KEY ([intCustomerStorageId]) REFERENCES [dbo].[tblGRCustomerStorage] ([intCustomerStorageId]) ON DELETE CASCADE, 
)