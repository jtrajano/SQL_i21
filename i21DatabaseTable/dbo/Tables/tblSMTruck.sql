CREATE TABLE [dbo].[tblSMTruck]
(
	[intTruckId] INT NOT NULL PRIMARY KEY IDENTITY,
	[strTruckNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1
)