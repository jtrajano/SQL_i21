CREATE TABLE [dbo].[tblAPVendorStagingSynergy]
(
	[intVendorStagingId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
	[strVendorId] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] NVARCHAR(100) NULL,
	[strContact] NVARCHAR(100) NULL,
	[ysnUserShipperWeight] BIT NOT NULL DEFAULT(0),
	[intVendorType] INT NOT NULL
)
