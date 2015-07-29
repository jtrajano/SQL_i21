CREATE TABLE [dbo].[tblWHContainerPreload]
(
	[intPreloadContainerId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NOT NULL,
	[strContainerNo] NVARCHAR(50) NOT NULL,
	[intUnitId] INT NOT NULL,
	[intLotId] INT NOT NULL,
	[strLotCode] NVARCHAR(50),
	[dblQty] NUMERIC(18,6) NOT NULL,
	[intQtyUOMId] INT NOT NULL,
	[ysnWHContainerCreated] BIT DEFAULT 0,
	[intAddressID] INT,
	[dtmProductionDate] DATETIME,
	[strLastUpdateBy] NVARCHAR(50),
	[dtmLastUpdateOn] DATETIME,

	CONSTRAINT [PK_tblWHContainerPreload_intPreloadContainerId] PRIMARY KEY ([intPreloadContainerId])

)
