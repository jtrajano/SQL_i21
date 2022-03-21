﻿CREATE PROCEDURE [dbo].[uspRKInsertM2MBasisDetails]
	@intM2MBasisId INT
	, @intRowNumbers NVARCHAR(MAX)

AS

DECLARE @tempBasis TABLE(intRowNumber INT
	, strCommodityCode NVARCHAR(50)
	, strItemNo NVARCHAR(50)
	, strOriginDest NVARCHAR(50)
	, strFutMarketName NVARCHAR(50)
	, strFutureMonth NVARCHAR(50)
	, strPeriodTo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strLocationName NVARCHAR(50)
	, strMarketZoneCode NVARCHAR(50)
	, strCurrency NVARCHAR(50)
	, strPricingType NVARCHAR(50)
	, strContractInventory NVARCHAR(50)
	, strContractType NVARCHAR(50)
	, dblCashOrFuture NUMERIC(16, 10)
	, dblBasisOrDiscount NUMERIC(16, 10)
	, dblRatio NUMERIC(16, 10)
	, strUnitMeasure NVARCHAR(50)
	, intCommodityId INT
	, intItemId INT
	, intOriginId INT
	, intFutureMarketId INT
	, intFutureMonthId INT
	, intCompanyLocationId INT
	, intMarketZoneId INT
	, intCurrencyId INT
	, intPricingTypeId INT
	, intContractTypeId INT
	, intUnitMeasureId INT
	, intConcurrencyId INT
	, strMarketValuation NVARCHAR(250)
	, ysnLicensed BIT
	, intBoardMonthId INT
	, strBoardMonth NVARCHAR(50)
	, strOriginPort NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intOriginPortId INT
	, strDestinationPort NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intDestinationPortId INT
	, strCropYear NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intCropYearId INT
	, strStorageLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intStorageLocationId INT
	, strStorageUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intStorageUnitId INT	
)  

INSERT INTO @tempBasis
EXEC uspRKGetM2MBasis

INSERT INTO tblRKM2MBasisDetail (intM2MBasisId
	, intConcurrencyId
	, intCommodityId
	, intItemId
	, strOriginDest
	, intFutureMarketId
	, intFutureMonthId
	, strPeriodTo
	, intCompanyLocationId
	, intMarketZoneId
	, intCurrencyId
	, intPricingTypeId
	, strContractInventory
	, intContractTypeId
	, dblCashOrFuture
	, dblBasisOrDiscount
	, dblRatio
	, intUnitMeasureId
	, intOriginPortId
	, intDestinationPortId
	, intCropYearId
	, intStorageLocationId
	, intStorageUnitId)
SELECT @intM2MBasisId
	, 1
	, intCommodityId
	, intItemId
	, strOriginDest
	, intFutureMarketId
	, intFutureMonthId
	, strPeriodTo
	, intCompanyLocationId
	, intMarketZoneId
	, intCurrencyId
	, intPricingTypeId
	, strContractInventory
	, intContractTypeId
	, dblCashOrFuture
	, dblBasisOrDiscount
	, dblRatio
	, intUnitMeasureId
	, intOriginPortId
	, intDestinationPortId
	, intCropYearId
	, intStorageLocationId
	, intStorageUnitId
FROM @tempBasis
WHERE intRowNumber NOT IN (SELECT * FROM dbo.[fnCommaSeparatedValueToTable](@intRowNumbers))