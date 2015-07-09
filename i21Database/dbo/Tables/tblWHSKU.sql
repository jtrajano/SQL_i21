﻿CREATE TABLE [dbo].[tblWHSKU]
(
	[intSKUId]	INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NOT NULL,
	[strSKUNo]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intSKUStatusId]	INT NOT NULL,
	[strLotCode]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[dblQty]	NUMERIC(18,6) NOT NULL,
	[dtmReceiveDate]	DATETIME,
	[dtmProductionDate]	DATETIME,
	[intItemId]	INT NOT NULL,
	[intContainerId]	INT NOT NULL,
	[intOwnerId]	INT NOT NULL,
	[intLotId]	INT NOT NULL,
	[intUOMId]	INT NOT NULL,
	[strReasonCode]	NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strComment]	NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intParentSKUId]	INT,
	[strParentSKUNo]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[dblWeightPerUnit]	NUMERIC(18,6) NOT NULL,
	[intWeightPerUnitUOMId]	INT NOT NULL,
	[intUnitsPerLayer]	INT NOT NULL,
	[intLayersPerPallet]	INT NOT NULL,
	[ysnIsSanitized]	BIT,
	[strBatchNo]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 

    CONSTRAINT [PK_tblWHSKU_intSKUId]  PRIMARY KEY ([intSKUId]),	
	CONSTRAINT [UQ_tblWHSKU_strSKUNo] UNIQUE ([strSKUNo]),
	CONSTRAINT [FK_tblWHSKU_tblWHContainer_intContainerId] FOREIGN KEY ([intContainerId]) REFERENCES [tblWHContainer]([intContainerId]), 
	CONSTRAINT [FK_tblWHSKU_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
	CONSTRAINT [FK_tblWHSKU_tblICUnitMeasure_intUOMId] FOREIGN KEY ([intUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
	CONSTRAINT [FK_tblWHSKU_tblARCustomer_intOwnerId] FOREIGN KEY ([intOwnerId]) REFERENCES [tblARCustomer]([intEntityCustomerId]), 
	CONSTRAINT [FK_tblWHSKU_tblWHSKUStatus_intSKUStatusId] FOREIGN KEY ([intSKUStatusId]) REFERENCES [tblWHSKUStatus]([intSKUStatusId]), 

)
