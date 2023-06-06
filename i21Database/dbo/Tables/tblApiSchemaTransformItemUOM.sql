CREATE TABLE [dbo].[tblApiSchemaTransformItemUOM] (
	intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, -- The item number.
	strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, -- The unit of measure.
	dblUnitQty NUMERIC(38, 20) NULL, -- The unit quantity.
	strWeightUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, -- The weight unit of measure.
	strUPCCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, -- The Long UPC.
	strShortUPCCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, -- The Short UPC.
	ysnIsStockUnit NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, -- Check if stock unit.
	ysnAllowPurchase NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, -- Check if allowed purchase.
	ysnAllowSale NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, -- Check if allowed sale.
	dblLength NUMERIC(38, 20) NULL, -- The length.
	dblWidth NUMERIC(38, 20) NULL, -- The width.
	dblHeight NUMERIC(38, 20) NULL, -- The height.
	strDimensionUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, -- The dimension unit of measure.
	dblWeight NUMERIC(38, 20) NULL, -- The weight.
	dblVolume NUMERIC(38, 20) NULL, -- The volume.
	strVolumeUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, -- The volume unit of measure.
	dblMaxQty NUMERIC(38, 20) NULL -- The max quantity.
)
