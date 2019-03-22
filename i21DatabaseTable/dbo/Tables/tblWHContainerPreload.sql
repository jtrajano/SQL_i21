CREATE TABLE [dbo].[tblWHContainerPreload]
(
	[intPreloadContainerId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NOT NULL,
	[strContainerNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intUnitId] INT NOT NULL,
	[intLotId] INT NOT NULL,
	[strLotCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dblQty] NUMERIC(18,6) NOT NULL,
	[intQtyUOMId] INT NOT NULL,
	[ysnWHContainerCreated] BIT DEFAULT 0,
	[intAddressID] INT,
	[dtmProductionDate] DATETIME,
	[strLastUpdateBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dtmLastUpdateOn] DATETIME,

	CONSTRAINT [PK_tblWHContainerPreload_intPreloadContainerId] PRIMARY KEY ([intPreloadContainerId])

)
