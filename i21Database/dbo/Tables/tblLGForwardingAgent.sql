CREATE TABLE [dbo].[tblLGForwardingAgent]
(
	[intForwardingAgentId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [strName] NVARCHAR(100) NOT NULL, 
    [strPhone] NVARCHAR(25) NULL, 
    [strEmail] NVARCHAR(75) NULL, 
    [strAddress] NVARCHAR(500) NOT NULL, 
    [strZipCode] NVARCHAR(25) NULL, 
    [strCity] NVARCHAR(75) NULL, 
    [strState] NVARCHAR(75) NULL, 
    [strCountry] NVARCHAR(75) NULL, 
    [strAltPhone] NVARCHAR(25) NULL, 
    [strAltEmail] NVARCHAR(75) NULL, 
    [strMobile] NVARCHAR(25) NULL, 
    [strFax] NVARCHAR(25) NULL, 
    [strWebsite] NVARCHAR(100) NULL, 
    [strContactName] NVARCHAR(100) NULL, 
    [strAccountNumber] NVARCHAR(50) NULL, 
    [strNotes] NVARCHAR(500) NULL, 
    [ysnActive] BIT NOT NULL, 
    
	CONSTRAINT [PK_tblLGForwardingAgent_intForwardingAgentId] PRIMARY KEY ([intForwardingAgentId])
)
