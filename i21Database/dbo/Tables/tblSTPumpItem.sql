﻿CREATE TABLE [dbo].[tblSTPumpItem]
(
	[intStorePumpItemId] INT NOT NULL IDENTITY, 
    [intItemUOMId] INT NOT NULL, 
    [dblPrice] NUMERIC(18, 6) NULL  DEFAULT 0, 
    [intTaxGroupId] int NULL,
    [intConcurrencyId ] INT NOT NULL,
	CONSTRAINT [PK_tblSTPumpItem] PRIMARY KEY ([intStorePumpItemId]),
	CONSTRAINT [FK_tblSTPumpItem_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [dbo].[tblICItemUOM] ([intItemUOMId]),
	CONSTRAINT [FK_tblSTPumpItem_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId])
)
