﻿CREATE TABLE [dbo].[tblNRNoteFutureTransaction]
(
	[intNoteFutureTransId] INT NOT NULL IDENTITY , 
    [intNoteId] INT NOT NULL, 
    [dtmNoteTranDate] DATETIME NOT NULL, 
    [intNoteTransTypeId] INT NOT NULL, 
    [intTransDays] INT NOT NULL, 
    [dblTransAmount] NUMERIC(18, 6) NOT NULL, 
    [dblPrincipal] NUMERIC(18, 6) NOT NULL, 
    [dblInterestToDate] NUMERIC(18, 6) NOT NULL, 
    [dblUnpaidInterest] NUMERIC(18, 6) NULL, 
    [dblPayOffBalance] NUMERIC(18, 6) NOT NULL, 
    [strInvoiceNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dtmInvoiceDate] DATETIME NULL, 
    [strInvoiceLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strRefNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strBatchNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblAmtAppToPrincipal] NUMERIC(18, 6) NULL, 
    [dblAmtAppToInterest] NUMERIC(18, 6) NULL, 
    [strPayType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dtmAsOfDate] DATETIME NULL, 
    [strCheckNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strTransComments] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL, 
    [strAdjOnPrincOrInt] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strAdjAccountAffected] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intAdjTypeId] INT NULL, 
    [intLastModifiedUserId] INT NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblNRNoteFutureTransaction_intNoteFutureTransId] PRIMARY KEY ([intNoteFutureTransId]), 
   	CONSTRAINT [FK_tblNRNoteFutureTransaction_tblNRNote_intNoteId] FOREIGN KEY ([intNoteId]) REFERENCES [tblNRNote]([intNoteId]) 

	
)
