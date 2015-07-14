CREATE TABLE [dbo].[tblQMTicketDiscount]
(
	[intTicketDiscountId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NULL, 
    [strDiscountCode] NVARCHAR(3) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dblGradeReading] DECIMAL(7, 3) NOT NULL, 
    [strCalcMethod] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [dblDiscountAmount] DECIMAL(9, 6) NOT NULL, 
    [strShrinkWhat] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [dblShrinkPercent] DECIMAL(7, 3) NOT NULL, 
    [ysnGraderAutoEntry] BIT NULL, 
    [intDiscountScheduleCodeId] INT NULL, 
    [intConcurrencyId] INT NULL, 
    [intTicketFileId] INT NULL, 
    [strSourceType] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,	
	CONSTRAINT [PK_tblQMTicketDiscount_intTicketDiscountId] PRIMARY KEY ([intTicketDiscountId]),
	CONSTRAINT [UK_tblQMTicketDiscount_intTicketId_strDiscountCode] UNIQUE ([intTicketId],[strDiscountCode]), 
	CONSTRAINT [FK_tblQMTicketDiscount_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [tblSCTicket]([intTicketId]),
	CONSTRAINT [FK_tblQMTicketDiscount_tblGRDiscountScheduleCode_intDiscountScheduleCodeId] FOREIGN KEY ([intDiscountScheduleCodeId]) REFERENCES [tblGRDiscountScheduleCode]([intDiscountScheduleCodeId]) 
)
