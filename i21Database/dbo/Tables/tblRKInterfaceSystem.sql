CREATE TABLE [dbo].[tblRKInterfaceSystem]
(
	[intInterfaceSystemId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	[strInterfaceSystem] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strInterfaceSystemURL] NVARCHAR(max) COLLATE Latin1_General_CI_AS NOT NULL,	
	[strSymbolPrefix] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strOpen] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strHigh] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLow] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLastSettle] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLastElement] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblRKInterfaceSystem_intInterfaceSystemId] PRIMARY KEY ([intInterfaceSystemId])
)