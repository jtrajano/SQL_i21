CREATE PROC uspRKM2MBasisTransactionImport
	@intM2MBasisId INT
	, @intUserId INT

AS

BEGIN TRY
	DECLARE @ErrMsg nvarchar(Max)
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
		, intUnitMeasureId)
	SELECT 0
		, @intM2MBasisId
		, fm.intFutureMarketId
		, c.intCommodityId
		, it.intItemId
		, cu.intCurrencyID
		, i.dblBasis
		, um.intUnitMeasureId
	FROM tblRKM2MTransactionImport i
	JOIN tblRKFutureMarket fm ON fm.strFutMarketName = i.strFutMarketName
	JOIN tblICCommodity c ON c.strCommodityCode = i.strCommodityCode
	JOIN tblICItem it ON it.strItemNo = i.strItemNo
	JOIN tblSMCurrency cu ON cu.strCurrency = i.strCurrency
	JOIN tblICUnitMeasure um ON um.strUnitMeasure = i.strUnitMeasure

	UPDATE tblRKM2MBasisDetail
	SET dblBasisOrDiscount = ISNULL(t2.dblBasis, null)
	FROM tblRKM2MBasisDetail t1
	LEFT JOIN tblRKM2MBasisTransaction t2 ON t1.intM2MBasisId = t2.intM2MBasisId
		AND t1.intItemId = t2.intItemId
		AND t1.intCommodityId = t2.intCommodityId
		AND t1.intFutureMarketId = t2.intFutureMarketId
	WHERE t1.intM2MBasisId = @intM2MBasisId
	
	COMMIT TRAN
	
	EXEC uspIPInterCompanyPreStageM2MBasis @intM2MBasisId = @intM2MBasisId
			, @strRowState = 'Modified'
			, @intUserId = @intUserId

	SELECT intCuncurrencyId = 0
		, *
	FROM tblRKM2MTransactionImport
	
	DELETE FROM tblRKM2MTransactionImport
END TRY
BEGIN CATCH
	 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
	 SET @ErrMsg = ERROR_MESSAGE()  
	 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
End Catch