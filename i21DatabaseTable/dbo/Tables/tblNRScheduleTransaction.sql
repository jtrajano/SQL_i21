CREATE TABLE [dbo].[tblNRScheduleTransaction]
(
	[intScheduleTransId]		INT				IDENTITY(1,1) NOT NULL,
    [intNoteId]					INT				NULL, 
    [intPaymentNo]				INT				NULL, 
    [dtmExpectedPayDate]		DATETIME		NULL, 
	[dtmPayGeneratedOn]			DATETIME		NULL, 
    [dtmPaidOn]					DATETIME		NULL, 
    [dtmLateFeeGeneratedOn]		DATETIME		NULL, 
	[dtmLateFeePaidOn]			DATETIME		NULL,
    [dblExpectedPayAmt]			NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblPrincipal]				NUMERIC(18, 6)	NULL DEFAULT 0,  
    [dblInterest]				NUMERIC(18, 6)	NULL DEFAULT 0, 
    [dblBalance]				NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblPayAmt]					NUMERIC(18, 6)	NULL DEFAULT 0, 
    [dblLateFeeGenerated]		NUMERIC(18, 6)	NULL DEFAULT 0, 
    [dblLateFeePayAmt]			NUMERIC(18, 6)	NULL DEFAULT 0, 
    [intConcurrencyId]			INT				NOT NULL DEFAULT ((0)),
    CONSTRAINT [PK_tblNRScheduleTransaction_intScheduleTransId] PRIMARY KEY ([intScheduleTransId]), 
    CONSTRAINT [FK_tblNRScheduleTransaction_tblNRNote_intNoteId] FOREIGN KEY ([intNoteId]) REFERENCES [tblNRNote]([intNoteId])
)