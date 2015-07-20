CREATE TABLE [dbo].[tblQMTicketDiscount]
(
	[intTicketDiscountId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NULL, 
    [strDiscountCode] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
    [strDiscountCodeDescription] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [dblGradeReading] DECIMAL(7, 3) NULL, 
    [strCalcMethod] NVARCHAR COLLATE Latin1_General_CI_AS NULL,
    [strShrinkWhat] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblShrinkPercent] DECIMAL(7, 3) NULL,  
    [dblDiscountAmount] DECIMAL(9, 6) NULL,
    [dblDiscountDue] DECIMAL(18, 6) NULL,
	[dblDiscountPaid] DECIMAL(18, 6) NULL,
    [ysnGraderAutoEntry] BIT NULL, 
    [intDiscountScheduleCodeId] INT NULL,
    [dtmDiscountPaidDate] DATETIME NULL, 	 
    [intTicketId] INT NULL, 
    [intTicketFileId] INT NULL, 
    [strSourceType] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblQMTicketDiscount_intTicketDiscountId] PRIMARY KEY ([intTicketDiscountId]),
	CONSTRAINT [UK_tblQMTicketDiscount_intTicketId_intTicketFileId_intCustomerStorageId_strDiscountCode_strDiscountCodeDescription] UNIQUE ([intTicketId],[intTicketFileId],[strDiscountCode],[strDiscountCodeDescription]), 
	CONSTRAINT [FK_tblQMTicketDiscount_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [tblSCTicket]([intTicketId]),
	CONSTRAINT [FK_tblQMTicketDiscount_tblGRDiscountScheduleCode_intDiscountScheduleCodeId] FOREIGN KEY ([intDiscountScheduleCodeId]) REFERENCES [tblGRDiscountScheduleCode]([intDiscountScheduleCodeId]) 
)
