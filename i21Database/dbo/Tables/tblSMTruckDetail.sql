CREATE TABLE [dbo].[tblSMTruckDetail]
(
	[intTruckDetailId] INT NOT NULL PRIMARY KEY IDENTITY,
	[intTruckId] INT NOT NULL, 
	[strName] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strManufacturer] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strModel] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[dblCapacity] NUMERIC(18, 6) NOT NULL, 
	[intDefaultItemId] INT NULL, 
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [FK_tblSMTruckDetail_tblSMTruck] FOREIGN KEY (intTruckId) REFERENCES tblSMTruck(intTruckId) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMTruckDetail_tblICItem] FOREIGN KEY (intDefaultItemId) REFERENCES tblICItem(intItemId)
)