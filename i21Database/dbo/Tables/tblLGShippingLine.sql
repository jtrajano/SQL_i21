CREATE TABLE [dbo].[tblLGShippingLine]
(
	[intShippingLineId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [strName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strPhone] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL, 
    [strEmail] NVARCHAR(75) COLLATE Latin1_General_CI_AS NULL, 
    [strAddress] NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strZipCode] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL, 
    [strCity] NVARCHAR(75) COLLATE Latin1_General_CI_AS NULL, 
    [strState] NVARCHAR(75) COLLATE Latin1_General_CI_AS NULL, 
    [strCountry] NVARCHAR(75) COLLATE Latin1_General_CI_AS NULL, 
    [strAltPhone] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL, 
    [strAltEmail] NVARCHAR(75) COLLATE Latin1_General_CI_AS NULL, 
    [strMobile] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL, 
    [strFax] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL, 
    [strWebsite] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strContactName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strAccountNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strNotes] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL, 
    [ysnActive] BIT NOT NULL, 
    
	CONSTRAINT [PK_tblLGShippingLine_intShippingLineId] PRIMARY KEY ([intShippingLineId])
)
