
CREATE TABLE [dbo].[tblCFImportTransactionStringVehicleStagingTable](
	[intRowId] int IDENTITY(1,1) NOT NULL,
	[intVehicleId] int NULL,
	[strVehicleNumber] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[intAccountId] int NULL,
	[strGUID] nvarchar(max) COLLATE Latin1_General_CI_AS NULL
) 