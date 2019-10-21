CREATE TABLE [dbo].[tblCTBagMarkLocation]
(
	[intBagMarkLocationId] [int] IDENTITY(1,1) NOT NULL,
	[strBagMarkLocationName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strStartingNumber] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NOT NULL, 
	CONSTRAINT [PK_tblCTBagMarkLocation_intBagMarkLocationId] PRIMARY KEY CLUSTERED ([intBagMarkLocationId] ASC),
	CONSTRAINT [UK_tblCTBagMarkLocation_strBagMarkLocationName] UNIQUE ([strBagMarkLocationName])
)
