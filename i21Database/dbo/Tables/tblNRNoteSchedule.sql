CREATE TABLE [dbo].[tblNRNoteSchedule]
(
	[intScheduleId] INT NOT NULL IDENTITY, 
    [intNoteId] INT NOT NULL, 
    [strDescription] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL, 
    [ysnForcePayment] BIT NULL, 
    [dblForcePaymentAmt] NUMERIC(18, 6) NULL, 
    [intScheduleInterval] INT NULL, 
    [intScheduleMonthFreq] INT NULL, 
    [intScheduleYearFreq] INT NULL, 
    [dtmStartDate] DATETIME NULL, 
    [dtmEndDate] DATETIME NULL, 
    [dblLateFee] NUMERIC(18, 6) NULL, 
    [strLateFeeUnit] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strLateAppliedOn] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intGracePeriod] INT NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblNRNoteSchedule_intScheduleId] PRIMARY KEY ([intScheduleId]), 
    CONSTRAINT [FK_tblNRNoteSchedule_tblNRNote_intNoteId] FOREIGN KEY ([intNoteId]) REFERENCES [tblNRNote]([intNoteId]) 
)
