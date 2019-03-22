CREATE TABLE [dbo].[tblETGPSCoordinates](
	[intGPSCoordinatesId] INT IDENTITY(1,1) NOT NULL,
	[strTruckId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDriverId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblLatitude] NUMERIC(9, 6) NOT NULL,
	[dblLongitude] NUMERIC(9, 6) NOT NULL,
	[dtmRecordDate] DATETIME NOT NULL,
	[intConcurrencyId] INT NOT NULL
	CONSTRAINT [PK_tblETGPSCoordinates_intGPSCoordinatesId] PRIMARY KEY CLUSTERED ([intGPSCoordinatesId] ASC)    
)