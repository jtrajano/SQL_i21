CREATE TABLE [dbo].[tblTMImportTankReading]
(
	[intImportTankReadingId] INT IDENTITY(1,1) NOT NULL,
	[intTankMonitorInterfaceId] INT NOT NULL,
	[intInterfaceTypeId] INT NOT NULL,
	[intUserId] INT NOT NULL,
	[dtmImportDate] DATETIME NOT NULL,
	--[strMessage] NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT DEFAULT 1 NOT NULL,
	CONSTRAINT [PK_tblTMImportTankReading] PRIMARY KEY CLUSTERED ([intImportTankReadingId] ASC)
)
