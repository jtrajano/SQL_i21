CREATE TABLE [dbo].[tblNRUCC]
(
	[intUCCId] INT NOT NULL IDENTITY, 
    [intNoteId] INT NULL, 
    [strFileRefNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dtmFiledOn] DATETIME NULL, 
    [dtmLastRenewalOn] DATETIME NULL, 
    [dtmReleasedOn] DATETIME NULL, 
    [strComment] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblNRUCC_intUCCId] PRIMARY KEY ([intUCCId]), 
    CONSTRAINT [FK_tblNRUCC_tblNRNote_intNoteId] FOREIGN KEY ([intNoteId]) REFERENCES [tblNRNote]([intNoteId]) 
)
