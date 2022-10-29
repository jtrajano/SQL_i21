﻿CREATE TABLE [dbo].[tblQMSampleInitialBuy]
(
	[intInitialBuyId] INT IDENTITY(1,1) NOT NULL, 
    [intSampleId] INT NOT NULL, 
    [intBuyerId] INT NULL, 
    [strBuyerName] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
    [dblQtyBought] NUMERIC(18, 6) NULL, 
    [intQtyUOMId] INT NULL, 
	[strQtyUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
    [dblPrice] NUMERIC(18, 6) NULL, 
    [intPriceUOMId] INT NULL,
	[strPriceUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	--[intInitialBuyerNo] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblQMSampleInitialBuy] PRIMARY KEY ([intInitialBuyId]),
	CONSTRAINT [FK_tblQMSampleInitialBuy_tblQMSample] FOREIGN KEY ([intSampleId]) REFERENCES [dbo].[tblQMSample] ([intSampleId]),
    CONSTRAINT [FK_tblQMSampleInitialBuy_tblEMEntity_intBuyerId] FOREIGN KEY ([intBuyerId]) REFERENCES [dbo].[tblEMEntity]([intEntityId]),
	--CONSTRAINT [FK_tblQMSampleInitialBuy_tblICUnitMeasure_intQtyUOMId] FOREIGN KEY ([intQtyUOMId]) REFERENCES [dbo].[tblICUnitMeasure] ([intUnitMeasureId]),
	--CONSTRAINT [FK_tblQMSampleInitialBuy_tblICUnitMeasure_intPriceUOMId] FOREIGN KEY ([intPriceUOMId]) REFERENCES [dbo].[tblICUnitMeasure] ([intUnitMeasureId]),
)