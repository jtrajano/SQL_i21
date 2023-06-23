CREATE PROCEDURE uspRKM2MBasisImport
	  @intM2MBasisId INT = 0
	, @intUserId INT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		, @strErrMessage NVARCHAR(50)
		, @intNewBasisId INT

	BEGIN TRAN
	
	IF (ISNULL(@intM2MBasisId, 0) = 0)
	BEGIN
		INSERT INTO tblRKM2MBasis (
			  intConcurrencyId
			, dtmM2MBasisDate
			, strPricingType)
		SELECT TOP 1 0
			, GETDATE()
			, strType
		FROM tblRKM2MBasisImport

		SET @intNewBasisId = SCOPE_IDENTITY()
	END
	ELSE 
	BEGIN
		SET @intNewBasisId = @intM2MBasisId

		DELETE FROM tblRKM2MBasisDetail
		WHERE intM2MBasisId = @intNewBasisId
	END

	INSERT INTO tblRKM2MBasisDetail(
	      intConcurrencyId
		, intM2MBasisId
		, intFutureMarketId
		, intCommodityId
		, intItemId
		, intCompanyLocationId
		, intMarketZoneId
		, intOriginPortId
		, intDestinationPortId
		, intCropYearId
		, intStorageLocationId
		, intStorageUnitId
		, strPeriodTo
		, intContractTypeId
		--, intProductTypeId
		--, intGradeId
		--, intProductLineId
		--, strCertification
		--, intMTMPointId
		, intCurrencyId
		, strContractInventory
		, dblCashOrFuture
		, dblBasisOrDiscount
		, dblRatio
		, intUnitMeasureId)
	SELECT intConcurrencyId = 0
		, intM2MBasisId = @intNewBasisId
		, intFutureMarketId = fm.intFutureMarketId
		, intCommodityId = c.intCommodityId
		, intItemId = it.intItemId
		, intCompanyLocationId = cl.intCompanyLocationId
		, intMarketZoneId = mz.intMarketZoneId
		, intOriginPortId = originPort.intCityId
		, intDestinationPortId = destinationPort.intCityId
		, intCropYearId = cropYear.intCropYearId
		, intStorageLocationId = storageLocation.intCompanyLocationSubLocationId
		, intStorageUnitId = storageUnit.intStorageLocationId
		, strPeriodTo = i.strPeriodTo
		, intContractTypeId = ctType.intContractTypeId
		--, intProductTypeId = ProductType.intCommodityAttributeId
		--, intGradeId = Grade.intCommodityAttributeId
		--, intProductLineId = ProductLine.intCommodityProductLineId
		--, strCertification = i.strCertification
		--, intMTMPointId = MTMPoint.intMTMPointId
		, intCurrencyId = cu.intCurrencyID
		, strContractInventory = i.strContractInventory
		, dblCashOrFuture = i.dblCash
		, dblBasisOrDiscount = i.dblBasis
		, dblRatio = i.dblRatio
		, intUnitMeasureId = um.intUnitMeasureId
	FROM tblRKM2MBasisImport i
	JOIN tblICCommodity c ON c.strCommodityCode = i.strCommodityCode
	JOIN tblSMCurrency cu ON cu.strCurrency = i.strCurrency
	JOIN tblICUnitMeasure um ON um.strUnitMeasure = i.strUnitMeasure
	LEFT JOIN tblRKFutureMarket fm ON fm.strFutMarketName = i.strFutMarketName
	LEFT JOIN tblICItem it ON it.strItemNo = i.strItemNo
	LEFT JOIN tblSMCompanyLocation cl ON cl.strLocationName = i.strLocation
	LEFT JOIN tblARMarketZone mz ON mz.strMarketZoneCode = i.strMarketZone
	LEFT JOIN tblSMCity originPort
		ON originPort.strCity = i.strOriginPort
	LEFT JOIN tblSMCity destinationPort
		ON destinationPort.strCity = i.strDestinationPort
	LEFT JOIN tblCTCropYear cropYear
		ON cropYear.intCommodityId = c.intCommodityId 
		AND cropYear.strCropYear = i.strCropYear
	LEFT JOIN tblSMCompanyLocationSubLocation storageLocation
		ON storageLocation.intCompanyLocationId = cl.intCompanyLocationId 
		AND storageLocation.strSubLocationName = i.strStorageLocation
	LEFT JOIN tblICStorageLocation storageUnit
		ON storageUnit.intLocationId = cl.intCompanyLocationId 
		AND storageUnit.intSubLocationId = storageLocation.intCompanyLocationSubLocationId
		AND storageUnit.strName = i.strStorageUnit
	LEFT JOIN tblCTContractType ctType
		ON ctType.strContractType = i.strContractType
	--LEFT JOIN tblICCommodityAttribute ProductType 
	--	ON ProductType.intCommodityId = c.intCommodityId 
	--	AND ProductType.strType = 'ProductType' 
	--	AND ProductType.strDescription = i.strProductType
	--LEFT JOIN tblICCommodityProductLine ProductLine 
	--	ON ProductLine.intCommodityId = c.intCommodityId 
	--	AND ProductLine.strDescription = i.strProductLine
	--LEFT JOIN tblICCommodityAttribute Grade 
	--	ON Grade.intCommodityId = c.intCommodityId 
	--	AND Grade.strType = 'Grade' 
	--	AND Grade.strDescription = i.strGrade
	--LEFT JOIN tblCTMTMPoint MTMPoint 
	--	ON MTMPoint.strMTMPoint = i.strMTMPoint
	--LEFT JOIN tblICCommodityAttribute CLASS
	--	ON CLASS.intCommodityId = c.intCommodityId 
	--	AND  CLASS.strType = 'Class'
	--	AND CLASS.strDescription = i.strClass
	--LEFT JOIN tblICCommodityAttribute REGION
	--	ON REGION.intCommodityId = c.intCommodityId 
	--	AND REGION.strType = 'Region'
	--	AND REGION.strDescription = i.strRegion

	COMMIT TRAN

	IF (ISNULL(@intM2MBasisId, 0) = 0)
	BEGIN
		EXEC uspIPInterCompanyPreStageM2MBasis @intM2MBasisId = @intNewBasisId
			, @strRowState = 'Added'
			, @intUserId = @intUserId
	END
	ELSE
	BEGIN
		EXEC uspIPInterCompanyPreStageM2MBasis @intM2MBasisId = @intM2MBasisId
				, @strRowState = 'Modified'
				, @intUserId = @intUserId
	END

	EXEC dbo.uspSMAuditLog @keyValue = @intNewBasisId		
		, @screenName = 'RiskManagement.view.BasisEntry' 
		, @entityId = @intUserId                   	  
		, @actionType = 'Imported'                         
		, @changeDescription = ''							
		, @fromValue = ''									
		, @toValue = ''										

	SELECT * FROM tblRKM2MBasisImport

	DELETE FROM tblRKM2MBasisImport
END TRY
BEGIN CATCH
	 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
	 SET @ErrMsg = ERROR_MESSAGE()  
	 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
END CATCH