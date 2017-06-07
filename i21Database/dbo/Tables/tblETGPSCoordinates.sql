CREATE TABLE [dbo].[tblETGPSCoordinates](
	[intGPSCoordinatesId] INT IDENTITY(1,1) NOT NULL,
	[strTruckId] NVARCHAR(50) NULL,
	[strDriverId] NVARCHAR(50) NULL,
	[dblLatitude] NUMERIC(9, 6) NOT NULL,
	[dblLongitute] NUMERIC(9, 6) NOT NULL,
	[dtmRecordDate] DATETIME NOT NULL,
	CONSTRAINT [PK_tblETGPSCoordinates_intGPSCoordinatesId] PRIMARY KEY CLUSTERED ([intGPSCoordinatesId] ASC)    
)