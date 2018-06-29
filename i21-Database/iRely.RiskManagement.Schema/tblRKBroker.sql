CREATE TABLE [dbo].[tblRKBroker]
(
	[intBrokerId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NOT NULL, 
	[intEntityId] INT NULL, 
    [intEntityLocationId] INT NULL,   
	[strBrokerName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,   
	[strVendorNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strLocationName] NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL, 
	[strAddress] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
	[strZipCode]NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
	[strCity] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
	[strState] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
	[strCountry] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
	[intPhone] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL , 
	[intFax] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL , 
	[intAltPhone] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL , 
	[strEmail] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,	
	CONSTRAINT [PK_tblRKBroker_intBrokerId] PRIMARY KEY ([intBrokerId])
)
