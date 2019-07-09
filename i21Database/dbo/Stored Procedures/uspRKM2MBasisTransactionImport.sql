CREATE PROCEDURE uspRKM2MBasisTransactionImport
	@intM2MBasisId INT

AS

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strErrMessage NVARCHAR(50)

	BEGIN TRAN

	DELETE FROM tblRKM2MBasisTransaction WHERE intM2MBasisId = @intM2MBasisId
	
	INSERT INTO tblRKM2MBasisTransaction (intConcurrencyId
		, intM2MBasisId
		, intFutureMarketId
		, intCommodityId
		, intItemId
		, intCurrencyId
		, dblBasis
		, intUnitMeasureId
		, intMarketZoneId
		, intCompanyLocationId
		, strPeriodTo)
	SELECT 0
		, @intM2MBasisId
		, fm.intFutureMarketId
		, c.intCommodityId
		, it.intItemId
		, cu.intCurrencyID
		, i.dblBasis
		, um.intUnitMeasureId
		, mz.intMarketZoneId
		, cl.intCompanyLocationId
		, i.strPeriodTo
	FROM tblRKM2MTransactionImport i
	JOIN tblRKFutureMarket fm ON fm.strFutMarketName = i.strFutMarketName
	JOIN tblICCommodity c ON c.strCommodityCode = i.strCommodityCode
	JOIN tblICItem it ON it.strItemNo = i.strItemNo
	JOIN tblSMCurrency cu ON cu.strCurrency = i.strCurrency
	JOIN tblICUnitMeasure um ON um.strUnitMeasure = i.strUnitMeasure
	LEFT JOIN tblSMCompanyLocation cl ON cl.strLocationName = i.strLocation
	LEFT JOIN tblARMarketZone mz ON mz.strMarketZoneCode = i.strMarketZone

	UPDATE tblRKM2MBasisDetail
	SET dblBasisOrDiscount = ISNULL(t2.dblBasis, NULL)
	FROM tblRKM2MBasisDetail t1
	LEFT JOIN tblRKM2MBasisTransaction t2 ON t1.intM2MBasisId = t2.intM2MBasisId
		AND t1.intItemId = t2.intItemId AND t1.intCommodityId = t2.intCommodityId AND t1.intFutureMarketId = t2.intFutureMarketId
	WHERE t1.intM2MBasisId = @intM2MBasisId
	
	COMMIT TRAN
	
	SELECT 0 as intCuncurrencyId
		, *
	FROM tblRKSettlementPriceImport_ErrLog
	
	DELETE FROM tblRKM2MTransactionImport
END TRY
BEGIN CATCH
	 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
	 SET @ErrMsg = ERROR_MESSAGE()  
	 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
End Catch