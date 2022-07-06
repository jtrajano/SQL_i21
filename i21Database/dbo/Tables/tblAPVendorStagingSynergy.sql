CREATE TABLE [dbo].[tblAPVendorStagingSynergy]
(
	[intVendorStagingId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
	[strVendorId] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intEntityId] INT NULL,
	[strDescription] NVARCHAR(100) NULL,
	[strContact] NVARCHAR(100) NULL,
	[ysnUserShipperWeight] BIT NOT NULL DEFAULT(0),
	[strVendorType] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[intVendorType] INT DEFAULT(0) NOT NULL,
	[intEntityLocationId] INT DEFAULT(0) NOT NULL,
	[strLocationName] NVARCHAR(50) NOT NULL,
	[dtmCreated] DATETIME NULL,
	[dtmLastModified] DATETIME NULL
)
