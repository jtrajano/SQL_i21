﻿CREATE TABLE [dbo].[tblQMTicketDiscount]
(
	[intTicketDiscountId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NULL, 
    [dblGradeReading] DECIMAL(24, 10) NULL, 
    [strCalcMethod] NVARCHAR COLLATE Latin1_General_CI_AS NULL,
    [strShrinkWhat] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblShrinkPercent] DECIMAL(24, 10) NULL,  
    [dblDiscountAmount] DECIMAL(24, 10) NULL,
    [dblDiscountDue] DECIMAL(24, 10) NULL,
	[dblDiscountPaid] DECIMAL(24, 10) NULL,
    [ysnGraderAutoEntry] BIT NULL, 
    [intDiscountScheduleCodeId] INT NULL,
    [dtmDiscountPaidDate] DATETIME NULL, 	 
    [intTicketId] INT NULL, 
    [intTicketFileId] INT NULL, 
    [strSourceType] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	[intSort] INT NULL ,
	[strDiscountChargeType] NVARCHAR(30)  COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblQMTicketDiscount_intTicketDiscountId] PRIMARY KEY ([intTicketDiscountId]),
	CONSTRAINT [UK_tblQMTicketDiscount_intTicketId_intTicketFileId_strSourceType_intDiscountScheduleCodeId] UNIQUE ([intTicketId],[intTicketFileId],[strSourceType],[intDiscountScheduleCodeId]),
	CONSTRAINT [FK_tblQMTicketDiscount_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [tblSCTicket]([intTicketId]),
	CONSTRAINT [FK_tblQMTicketDiscount_tblGRDiscountScheduleCode_intDiscountScheduleCodeId] FOREIGN KEY ([intDiscountScheduleCodeId]) REFERENCES [tblGRDiscountScheduleCode]([intDiscountScheduleCodeId])
)
GO
CREATE NONCLUSTERED INDEX [IX_tblQMTicketDiscount_intTicketDiscountId] ON [dbo].[tblQMTicketDiscount]([strSourceType]) INCLUDE ([intTicketDiscountId],[intTicketFileId]);
GO
CREATE NONCLUSTERED INDEX [IX_tblQMTicketDiscount_intTicketFiledId_strSourceTYpe] ON [dbo].[tblQMTicketDiscount]([intTicketFileId],[strSourceType]) INCLUDE ([intTicketDiscountId]);
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblQMTicketDiscount_intTicketId_K5_] ON [dbo].[tblQMTicketDiscount]
(
	[intTicketId] ASC,
	[strSourceType] ASC,
	[intTicketDiscountId] ASC,
	[intDiscountScheduleCodeId] ASC,
	[intTicketFileId] ASC
)
INCLUDE([dblGradeReading],[dblShrinkPercent])
GO 