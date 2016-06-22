CREATE TABLE [dbo].[tblRKInterfaceSystem]
(
	[intInterfaceSystemId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	[strInterfaceSystem] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strInterfaceSystemURL] NVARCHAR(max) COLLATE Latin1_General_CI_AS NOT NULL	
	CONSTRAINT [PK_tblRKInterfaceSystem_intInterfaceSystemId] PRIMARY KEY ([intInterfaceSystemId])
)