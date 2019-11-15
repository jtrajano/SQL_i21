CREATE PROCEDURE uspRKM2MBasisValidate

AS

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		, @PreviousErrMsg NVARCHAR(MAX)
		, @mRowNumber INT
		, @strFutMarketName NVARCHAR(50)
		, @strCommodityCode NVARCHAR(50)
		, @strItemNo NVARCHAR(50)
		, @strCurrency NVARCHAR(50)
		, @dblBasis NUMERIC(18, 6)
		, @strLocationName NVARCHAR(50)
		, @strMarketZone NVARCHAR(50)
		, @strPeriodTo NVARCHAR(50)
		, @strUnitMeasure NVARCHAR(50)

	SELECT @mRowNumber = MIN(intM2MBasisImportId) FROM tblRKM2MBasisImport
	WHILE @mRowNumber > 0
	BEGIN
		SELECT @PreviousErrMsg = ''
			, @strFutMarketName	= NULL
			, @strCommodityCode	= NULL
			, @strItemNo = NULL
			, @strCurrency = NULL
			, @strUnitMeasure = NULL
			, @strLocationName = NULL
			, @strMarketZone = NULL
			, @strPeriodTo = NULL
			, @dblBasis = NULL
		
		SELECT @strFutMarketName = strFutMarketName
			, @strCommodityCode = strCommodityCode
			, @strItemNo = strItemNo
			, @strCurrency = strCurrency
			, @strUnitMeasure = strUnitMeasure
			, @strLocationName = strLocationName
			, @strMarketZone = strMarketZone
			, @strPeriodTo = strPeriodTo
			, @dblBasis = dblBasis
		FROM tblRKM2MBasisImport
		WHERE intM2MBasisImportId = @mRowNumber
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKFutureMarket WHERE strFutMarketName = @strFutMarketName)
		BEGIN
			SET @PreviousErrMsg = 'Invalid Futures Market.'
		END

		IF (ISNULL(@strLocationName, '') <> '')
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCompanyLocation WHERE strLocationName = @strLocationName)
			BEGIN
				SET @PreviousErrMsg += ' Invalid Location.'
			END
		END

		IF (ISNULL(@strMarketZone, '') <> '')
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblARMarketZone WHERE strMarketZoneCode = @strMarketZone)
			BEGIN
				SET @PreviousErrMsg += ' Invalid Market Zone.'
			END
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblICCommodity WHERE strCommodityCode = @strCommodityCode)
		BEGIN
			SET @PreviousErrMsg += 'Invalid commodity.'
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItem WHERE strItemNo = @strItemNo)
		BEGIN
			SET @PreviousErrMsg += ' Invalid Item.'
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCurrency WHERE strCurrency = @strCurrency)
		BEGIN
			SET @PreviousErrMsg += ' Invalid currency.'
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblICUnitMeasure WHERE strUnitMeasure = @strUnitMeasure)
		BEGIN
			SET @PreviousErrMsg += ' Invalid UOM.'
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItem i
					JOIN tblICCommodity c ON i.intCommodityId = c.intCommodityId
					WHERE strItemNo = @strItemNo AND strCommodityCode = @strCommodityCode)
		BEGIN
			SET @PreviousErrMsg += ' Item (' + @strItemNo + ') not configure the commodity (' + @strCommodityCode + ').'
		END

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKCommodityMarketMapping MC
					JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = MC.intFutureMarketId
					JOIN tblICCommodity C ON C.intCommodityId = MC.intCommodityId
					WHERE FM.strFutMarketName = @strFutMarketName AND C.strCommodityCode = @strCommodityCode)
		BEGIN
			SET @PreviousErrMsg += ' Future Market (' + @strItemNo + ') is not configured for commodity (' + @strCommodityCode + ').'
		END

		IF (ISNULL(LTRIM(@PreviousErrMsg), '') <> '')
		BEGIN
			INSERT INTO tblRKM2MBasisImport_ErrLog (strFutMarketName
				, strCommodityCode
				, strItemNo
				, strCurrency
				, dblBasis
				, strUnitMeasure
				, strLocationName
				, strMarketZone
				, strPeriodTo
				, strErrMessage)
			VALUES (@strFutMarketName
				, @strCommodityCode
				, @strItemNo
				, @strCurrency
				, @dblBasis
				, @strUnitMeasure
				, @strLocationName
				, @strMarketZone
				, @strPeriodTo
				, @PreviousErrMsg)
		END
		
		SELECT @mRowNumber = MIN(intM2MBasisImportId) FROM tblRKM2MBasisImport WHERE intM2MBasisImportId > @mRowNumber
	END
	
	SELECT DISTINCT intBasisImportErrId
		, 0 as intConcurrencyId
		, strFutMarketName
		, strCommodityCode
		, strItemNo
		, strCurrency
		, dblBasis
		, strUnitMeasure
		, strErrMessage
		, strLocationName
		, strMarketZone
		, strPeriodTo
	FROM tblRKM2MBasisImport_ErrLog
	
	DELETE FROM tblRKM2MBasisImport_ErrLog
END TRY
BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH