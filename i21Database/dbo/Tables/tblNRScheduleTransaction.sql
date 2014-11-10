CREATE TABLE [dbo].[tblNRScheduleTransaction]
(
	[intScheduleTransId] INT NOT NULL IDENTITY, 
    [intScheduleId] INT NULL, 
    [intPaymentNo] INT NULL, 
    [dtmExpectedPayDate] DATETIME NULL, 
    [dblExpectedPayAmt] NUMERIC(18, 6) NULL, 
    [dblPrincipal] NUMERIC(18, 6) NULL, 
    [dblInterest] NUMERIC(18, 6) NULL, 
    [dblBalance] NUMERIC(18, 6) NULL, 
    [dtmPayGeneratedOn] DATETIME NULL, 
    [dtmPaidOn] DATETIME NULL, 
    [dblPayAmt] NUMERIC(18, 6) NULL, 
    [dtmLateFeeGeneratedOn] DATETIME NULL, 
    [dblLateFeeGenerated] NUMERIC(18, 6) NULL, 
    [dtmLateFeePaidOn] DATETIME NULL, 
    [dblLateFeePayAmt] NUMERIC(18, 6) NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblNRScheduleTransaction_intScheduleTransId] PRIMARY KEY ([intScheduleTransId]), 
    CONSTRAINT [FK_tblNRScheduleTransaction_tblNRNoteSchedule_intScheduleId] FOREIGN KEY ([intScheduleId]) REFERENCES [tblNRNoteSchedule]([intScheduleId]) 
)
