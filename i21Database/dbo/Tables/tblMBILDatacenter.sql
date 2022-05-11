CREATE TABLE [dbo].[tblMBILDatacenter]
(
	[intDatabaseId] [int] IDENTITY NOT NULL,
	[strCustomer] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL, 
	[strDatabase] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL, 
	[strDriver] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL, 
	[dtmCreated] [datetime] NULL,
	[intCustomerId] [int] NULL,
	[intDriverId] [int] NULL,
	[strDBLink] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL, 
	[strAppVersion] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL, 
	[intConcurrencyId] [int] NULL,
	CONSTRAINT [PK_tblMBILDatacenter] PRIMARY KEY ([intDatabaseId])
)