CREATE TABLE [dbo].[tblLGTerminal]
(
	[intTerminalId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [strName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strPhone] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL, 
    [strEmail] NVARCHAR(75) COLLATE Latin1_General_CI_AS NULL, 
    [strAddress] NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strCity] NVARCHAR(75) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strState] NVARCHAR(75) COLLATE Latin1_General_CI_AS NULL, 
    [strCountry] NVARCHAR(75) COLLATE Latin1_General_CI_AS NULL, 
    [strMobile] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL, 
    [strFax] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL, 
    [strNotes] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL, 
    
	CONSTRAINT [PK_tblLGTerminal_intTerminalId] PRIMARY KEY ([intTerminalId])
)
