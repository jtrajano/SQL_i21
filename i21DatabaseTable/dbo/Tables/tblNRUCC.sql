CREATE TABLE [dbo].[tblNRUCC]
(
	[intUCCId]				INT				IDENTITY(1,1) NOT NULL,
    [intNoteId]				INT				NULL, 
    [dtmFiledOn]			DATETIME		NULL, 
    [dtmLastRenewalOn]		DATETIME		NULL, 
    [dtmReleasedOn]			DATETIME		NULL, 
	[strFileRefNo]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS NULL, 
    [strComment]			NVARCHAR(255)	COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId]		INT				NOT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblNRUCC_intUCCId] PRIMARY KEY ([intUCCId]), 
    CONSTRAINT [FK_tblNRUCC_tblNRNote_intNoteId] FOREIGN KEY ([intNoteId]) REFERENCES [tblNRNote]([intNoteId]) 
)
