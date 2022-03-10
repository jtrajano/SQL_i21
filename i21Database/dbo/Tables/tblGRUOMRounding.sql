﻿CREATE TABLE [dbo].[tblGRUOMRounding](
	[intUOMRoundingId] [int] IDENTITY(1,1) NOT NULL,
	[intItemId] [int] NOT NULL,
	[intUnitOfMeasureFromId] [int] NOT NULL,
	[intUnitOfMeasureToId] [int] NOT NULL,
	[intDecimalAdjustment] [int] NOT NULL  DEFAULT 0,
	[ysnFixRounding] [bit] NOT NULL  DEFAULT 0,
	[intConcurrencyId] [int] NOT NULL  DEFAULT 0, 
    CONSTRAINT [PK_tblGRUOMRounding] PRIMARY KEY ([intUOMRoundingId])
) ON [PRIMARY]
GO

CREATE UNIQUE NONCLUSTERED INDEX [tblGRUOMRounding_UniqueKey] ON [dbo].[tblGRUOMRounding]
(
	[intUnitOfMeasureFromId] ASC,
	[intUnitOfMeasureToId] ASC
)
GO

CREATE NONCLUSTERED INDEX [tblGRUOMRounding_intUnitOfMeasureToId] ON [dbo].[tblGRUOMRounding]
(
	[intUnitOfMeasureToId] ASC
)INCLUDE (intDecimalAdjustment,ysnFixRounding)
GO

CREATE NONCLUSTERED INDEX [tblGRUOMRounding_intUnitOfMeasureFromId] ON [dbo].[tblGRUOMRounding]
(
	[intUnitOfMeasureFromId] ASC
)INCLUDE (intDecimalAdjustment,ysnFixRounding)
GO

CREATE NONCLUSTERED INDEX [tblGRUOMRounding_intItemId] ON [dbo].[tblGRUOMRounding]
(
	[intItemId] ASC
)INCLUDE (intUnitOfMeasureToId,intUnitOfMeasureFromId,intDecimalAdjustment,ysnFixRounding)
GO