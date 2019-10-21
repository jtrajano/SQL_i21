CREATE PROCEDURE uspRKM2MBasisImport

AS

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		, @strErrMessage NVARCHAR(50)
		, @intNewBasisId INT


	BEGIN TRAN
	
	INSERT INTO tblRKM2MBasis (intConcurrencyId
		, dtmM2MBasisDate
		, strPricingType)
	SELECT TOP 1 0
		, GETDATE()
		, strType
	FROM tblRKM2MBasisImport

	SET @intNewBasisId = SCOPE_IDENTITY()

	INSERT INTO tblRKM2MBasisDetail(intConcurrencyId
		, intM2MBasisId
		, intFutureMarketId
		, intCommodityId
		, intItemId
		, intCurrencyId
		, dblBasisOrDiscount
		, intUnitMeasureId
		, intMarketZoneId
		, intCompanyLocationId
		, strPeriodTo)
	SELECT 0
		, @intNewBasisId
		, fm.intFutureMarketId
		, c.intCommodityId
		, it.intItemId
		, cu.intCurrencyID
		, i.dblBasis
		, um.intUnitMeasureId
		, mz.intMarketZoneId
		, cl.intCompanyLocationId
		, i.strPeriodTo
	FROM tblRKM2MBasisImport i
	JOIN tblRKFutureMarket fm ON fm.strFutMarketName = i.strFutMarketName
	JOIN tblICCommodity c ON c.strCommodityCode = i.strCommodityCode
	JOIN tblICItem it ON it.strItemNo = i.strItemNo
	JOIN tblSMCurrency cu ON cu.strCurrency = i.strCurrency
	JOIN tblICUnitMeasure um ON um.strUnitMeasure = i.strUnitMeasure
	LEFT JOIN tblSMCompanyLocation cl ON cl.strLocationName = i.strLocationName
	LEFT JOIN tblARMarketZone mz ON mz.strMarketZoneCode = i.strMarketZone

	COMMIT TRAN
	
	SELECT 0 as intCuncurrencyId
		, *
	FROM tblRKM2MBasisImport
	
	DELETE FROM tblRKM2MBasisImport
END TRY
BEGIN CATCH
	 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
	 SET @ErrMsg = ERROR_MESSAGE()  
	 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
END CATCH