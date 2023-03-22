CREATE PROCEDURE [dbo].[uspRKCustomBasisEntry]
	  @Type NVARCHAR(100)
AS

BEGIN
	IF ISNULL(@Type, '') = ''
	BEGIN 
		RAISERROR ('MISSING TYPE OF BASIS ENTRY. USE ''Forecast'' OR ''Mark to Market''', 16, 1, 'WITH NOWAIT')
		RETURN
	END

	SELECT [Basis Entry Date] = t.dtmM2MBasisDate
		, [Futures Market] = t2.strFutMarketName
		, [Commodity] = t2.strCommodityCode
		, [Item] = t2.strItemNo
		, [Location] = t2.strLocationName
		, [Market Zone] = t2.strMarketZoneCode
		, [Period To] = t2.strPeriodTo
		, [Contract Type P/S] = t2.strContractType
		, [Origin] = t2.strOriginDest
		, [Currency] = t2.strCurrency
		, [Contract/Inventory] = t2.strContractInventory
		, [Cash] = t2.dblCashOrFuture
		, [Basis/Discount] = t2.dblBasisOrDiscount
		, [Weight UOM] = t2.strUnitMeasure
		, [Ratio] = t2.dblRatio
		, [M2M Batch] = t2.strM2MBatch
		, [M2M Date] = t2.dtmM2MDate
	FROM tblRKM2MBasis t
	INNER JOIN vyuRKBasisDetailNotMapping t2
		ON t.intM2MBasisId = t2.intM2MBasisId
	WHERE t.strPricingType = @Type
END