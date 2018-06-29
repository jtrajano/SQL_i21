CREATE TABLE [dbo].[tblNRNoteSchedule]
(
	[intScheduleId]				INT				IDENTITY(1,1) NOT NULL, 
    [intNoteId]					INT				NOT NULL, 
    [intGracePeriod]			INT				NULL, 
    [intScheduleInterval]		INT				NULL, 
    [intScheduleMonthFreq]		INT				NULL, 
    [intScheduleYearFreq]		INT				NULL, 
    [dtmStartDate]				DATETIME		NULL, 
    [dtmEndDate]				DATETIME		NULL, 
	[dblForcePaymentAmt]		NUMERIC(18, 6)	NULL DEFAULT 0, 
    [dblLateFee]				NUMERIC(18, 6)	NULL DEFAULT 0, 
    [strLateFeeUnit]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL, 
    [strLateAppliedOn]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL, 
    [strDescription]			NVARCHAR(255)	COLLATE Latin1_General_CI_AS NULL, 
	[ysnForcePayment]			BIT				NOT NULL CONSTRAINT [DF_tblNRNoteSchedule_ysnForcePayment] DEFAULT ((0)), 
    [intConcurrencyId]			INT				NOT NULL DEFAULT ((0)),
    CONSTRAINT [PK_tblNRNoteSchedule_intScheduleId] PRIMARY KEY ([intScheduleId]), 
    CONSTRAINT [FK_tblNRNoteSchedule_tblNRNote_intNoteId] FOREIGN KEY ([intNoteId]) REFERENCES [tblNRNote]([intNoteId]) 
)