CREATE TABLE [dbo].[tblNRNote]
(
	[intNoteId]					INT				IDENTITY (1, 1)	NOT NULL,
	[intCustomerId]				INT				NOT NULL,
	[intDescriptionId]			INT				NOT NULL,
	[intCompanyLocationId]		INT				NULL,	
	[intSchdInterval]			INT				NULL, 
    [intSchdMonthFreq]			INT				NULL, 
    [intSchdYearFreq]			INT				NULL,
    [intSchdGracePeriod]		INT				NULL,
	[intEntityId]				INT				NULL,
	[dtmMaturityDate]			DATETIME		NOT NULL,
	[dtmWriteOffDate]			DATETIME		NULL,
	[dtmSchdStartDate]			DATETIME		NULL, 
    [dtmSchdEndDate]			DATETIME		NULL, 
    [dtmUCCFiledOn]				DATETIME		NULL, 
    [dtmUCCLastRenewalOn]		DATETIME		NULL, 
    [dtmUCCReleasedOn]			DATETIME		NULL, 
	[dblCreditLimit]			NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblInterestRate]			NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblNotePrincipal]			NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblSchdForcePaymentAmt]	NUMERIC(18, 6)	NULL DEFAULT 0, 
	[dblSchdLateFee]			NUMERIC(18, 6)	NULL DEFAULT 0,
	[strNoteNumber]				NVARCHAR(25)	COLLATE Latin1_General_CI_AS NULL,
	[strNoteType]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS NOT NULL,
	[strSchdDescription]		NVARCHAR(255)	COLLATE Latin1_General_CI_AS NULL, 
    [strSchdLateFeeUnit]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL, 
    [strSchdLateAppliedOn]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL, 
	[strUCCFileRefNo]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL, 
	[strUCCComment]				NVARCHAR(255)	COLLATE Latin1_General_CI_AS NULL, 
	[ysnSchdForcePayment]		BIT				NOT NULL CONSTRAINT [DF_tblNRNote_ysnSchdForcePayment] DEFAULT ((0)), 	
	[ysnWriteOff]				BIT				NOT NULL CONSTRAINT [DF_tblNRNote_ysnWriteOff] DEFAULT ((0)),    
	[intConcurrencyId]			INT				NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblNRNote_intNoteId] PRIMARY KEY CLUSTERED ([intNoteId] ASC),
	CONSTRAINT [FK_tblNRNote_tblARCustomer_intCustomerId] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
	CONSTRAINT [FK_tblNRNote_tblNRNoteDescription_intDescriptionId] FOREIGN KEY([intDescriptionId]) REFERENCES [dbo].[tblNRNoteDescription] ([intDescriptionId]), 
	CONSTRAINT [UK_tblNRNote_strNoteNumber] UNIQUE ([strNoteNumber]) 
);

GO
CREATE TRIGGER trgNotesReceivableNumber
ON tblNRNote
AFTER INSERT
AS

DECLARE @inserted TABLE(intNoteId INT, intCompanyLocationId INT, strNoteNumber NVARCHAR(25) COLLATE Latin1_General_CI_AS)
DECLARE @count INT = 0
DECLARE @intNoteId INT
DECLARE @intCompanyLocationId INT
DECLARE @intStartingNumberId INT
DECLARE @NoteId NVARCHAR(50)
DECLARE @intMaxCount INT = 0

INSERT INTO @inserted
SELECT intNoteId, intCompanyLocationId, strNoteNumber FROM INSERTED ORDER BY intNoteId

SELECT TOP 1 @intStartingNumberId = intStartingNumberId 
FROM tblSMStartingNumber 
WHERE strTransactionType = 'Notes Receivable'

WHILE((SELECT TOP 1 1 FROM @inserted WHERE RTRIM(LTRIM(ISNULL(strNoteNumber,''))) = '') IS NOT NULL)
BEGIN	
	SELECT TOP 1 @intNoteId = intNoteId, @intCompanyLocationId = intCompanyLocationId FROM @inserted

	EXEC uspSMGetStartingNumber @intStartingNumberId, @NoteId OUT, @intCompanyLocationId
	
	IF(@NoteId IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM tblNRNote WHERE strNoteNumber = @NoteId)
			BEGIN
				SET @NoteId = NULL
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(strNoteNumber, 5, 10))) FROM tblNRNote
				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = 17
				EXEC uspSMGetStartingNumber @intStartingNumberId, @NoteId OUT, @intCompanyLocationId		
			END
		
		UPDATE tblNRNote
		SET strNoteNumber = @NoteId
		WHERE intNoteId = @intNoteId
	END

	DELETE FROM @inserted
	WHERE intNoteId = @intNoteId
END