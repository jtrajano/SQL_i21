﻿CREATE TABLE [dbo].[tblRKM2MDifferentialBasis]
(
	[intM2MDifferentialBasisId] INT NOT NULL IDENTITY, 
    [intM2MHeaderId] INT NOT NULL, 
    [intCommodityId] INT NULL, 
    [intItemId] INT NULL, 
	[strOriginDest] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intFutureMarketId] INT  NULL, 
    [intFutureMonthId] INT  NULL, 
    [strPeriodTo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intLocationId] INT NULL, 
    [intMarketZoneId] INT NULL, 
    [intCurrencyId] INT NULL, 
    [intPricingTypeId] INT NULL, 
    [strContractInventory] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intContractTypeId] INT NULL, 
    [dblCashOrFuture] NUMERIC(18, 6) NULL, 
    [dblBasisOrDiscount] NUMERIC(18, 6) NULL, 
	[dblRatio] NUMERIC(18, 6) NULL, 
    [intUnitMeasureId] INT NULL, 
    [intM2MBasisDetailId] INT NULL, 
	[intOriginPortId] INT NULL,
	[intDestinationPortId] INT NULL,
	[intCropYearId] INT NULL,
	[intStorageLocationId] INT NULL,
	[intStorageUnitId] INT NULL,
	[intMTMPointId] INT NULL,
	[intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKM2MDifferentialBasis] PRIMARY KEY ([intM2MDifferentialBasisId]), 
    CONSTRAINT [FK_tblRKM2MDifferentialBasis_tblRKM2MHeader] FOREIGN KEY ([intM2MHeaderId]) REFERENCES [tblRKM2MHeader]([intM2MHeaderId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblRKM2MDifferentialBasis_tblRKFutureMarket] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]), 
    CONSTRAINT [FK_tblRKM2MDifferentialBasis_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]), 
    CONSTRAINT [FK_tblRKM2MDifferentialBasis_tblRKFuturesMonth] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]), 
    CONSTRAINT [FK_tblRKM2MDifferentialBasis_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblRKM2MDifferentialBasis_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblRKM2MDifferentialBasis_tblARMarketZone] FOREIGN KEY ([intMarketZoneId]) REFERENCES [tblARMarketZone]([intMarketZoneId]), 
    CONSTRAINT [FK_tblRKM2MDifferentialBasis_tblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]), 
    CONSTRAINT [FK_tblRKM2MDifferentialBasis_tblRKM2MBasisDetail] FOREIGN KEY ([intM2MBasisDetailId]) REFERENCES [tblRKM2MBasisDetail]([intM2MBasisDetailId]),
	CONSTRAINT [FK_tblRKM2MDifferentialBasis_tblSMCity_intOriginPortId] FOREIGN KEY (intOriginPortId) REFERENCES [dbo].[tblSMCity] (intCityId),
	CONSTRAINT [FK_tblRKM2MDifferentialBasis_tblSMCity_intDestinationPortId] FOREIGN KEY (intDestinationPortId) REFERENCES [dbo].[tblSMCity] (intCityId),
	CONSTRAINT [FK_tblRKM2MDifferentialBasis_tblCTCropYear_intCropYearId] FOREIGN KEY (intCropYearId) REFERENCES [dbo].[tblCTCropYear] (intCropYearId),
	CONSTRAINT [FK_tblRKM2MDifferentialBasis_tblSMCompanyLocationSubLocation_intStorageLocationId] FOREIGN KEY (intStorageLocationId) REFERENCES [dbo].[tblSMCompanyLocationSubLocation] (intCompanyLocationSubLocationId),
	CONSTRAINT [FK_tblRKM2MDifferentialBasis_tblICStorageLocation_intStorageUnitId] FOREIGN KEY (intStorageUnitId) REFERENCES [dbo].[tblICStorageLocation] (intStorageLocationId)
)
