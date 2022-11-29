CREATE TABLE [dbo].[tblSCSnapShotTicketDiscount]
(	
	
	[intSnapShotTicketDiscountId] INT NOT NULL IDENTITY,	
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
	CONSTRAINT [PK_tblSCSnapShotTicketDiscount_intSnapShotTicketDiscountId] PRIMARY KEY (intSnapShotTicketDiscountId),	
)