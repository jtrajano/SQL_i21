CREATE TABLE [dbo].[tblSCTicketDiscountLVStaging]
(
	[intTicketDiscountLVStagingId] INT NOT NULL IDENTITY, 
    [dblGradeReading] DECIMAL(24, 10) NULL, 
    [dblShrinkPercent] DECIMAL(24, 10) NULL,  
    [dblDiscountAmount] DECIMAL(24, 10) NULL,
    [dblDiscountDue] DECIMAL(24, 10) NULL,
	[dblDiscountPaid] DECIMAL(24, 10) NULL,
    [dtmDiscountPaidDate] DATETIME NULL, 	 
    [intDiscountScheduleCodeId] INT NULL,
    [intTicketId] INT NULL, 
    [intTicketFileId] INT NULL, 
	[intSort] INT NULL ,
    [ysnGraderAutoEntry] BIT NULL, 
    [strCalcMethod] NVARCHAR COLLATE Latin1_General_CI_AS NULL,
    [strShrinkWhat] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strSourceType] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	[strDiscountChargeType] NVARCHAR(30)  COLLATE Latin1_General_CI_AS NULL,
	[intOriginTicketDiscountId] INT NULL,
	[intConcurrencyId] INT NULL DEFAULT((1)), 
	CONSTRAINT [PK_tblSCTicketDiscountLVStaging_intTicketDiscountLVStagingId] PRIMARY KEY ([intTicketDiscountLVStagingId])
)