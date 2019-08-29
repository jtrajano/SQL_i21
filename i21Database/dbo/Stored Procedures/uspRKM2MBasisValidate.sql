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
		, @strErrMessage NVARCHAR(50)

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
			INSERT INTO tblRKM2MBasisImport_ErrLog(strFutMarketName
				, strCommodityCode
				, strItemNo
				, strCurrency
				, dblBasis
				, strUnitMeasure
				, strLocationName
				, strMarketZone
				, strPeriodTo
				, strErrMessage)
			SELECT DISTINCT strFutMarketName
				, strCommodityCode
				, strItemNo
				, strCurrency
				, dblBasis
				, strUnitMeasure
				, strLocationName
				, strMarketZone
				, strPeriodTo
				, 'Invalid Futures Market.'
			FROM tblRKM2MBasisImport
			WHERE strFutMarketName = @strFutMarketName
		END

		IF (ISNULL(@strLocationName, '') <> '')
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCompanyLocation WHERE strLocationName = @strLocationName)
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
				SELECT DISTINCT strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, strLocationName
					, strMarketZone
					, strPeriodTo
					, 'Invalid Location.'
				FROM tblRKM2MBasisImport
				WHERE strLocationName = @strLocationName
			END
		END

		IF (ISNULL(@strMarketZone, '') <> '')
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblARMarketZone WHERE strMarketZoneCode = @strMarketZone)
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
				SELECT DISTINCT strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, strLocationName
					, strMarketZone
					, strPeriodTo
					, 'Invalid Market Zone.'
				FROM tblRKM2MBasisImport
				WHERE strMarketZone = @strMarketZone
			END
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblICCommodity WHERE strCommodityCode = @strCommodityCode)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKM2MBasisImport_ErrLog WHERE strCommodityCode = @strCommodityCode AND strFutMarketName = @strFutMarketName)
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
				SELECT DISTINCT strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, strLocationName
					, strMarketZone
					, strPeriodTo
					, 'Invalid commodity.'
				FROM tblRKM2MBasisImport
				WHERE strCommodityCode = @strCommodityCode AND strFutMarketName = @strFutMarketName
			END
			ELSE
			BEGIN
				SELECT @PreviousErrMsg = strErrMessage
				FROM tblRKM2MBasisImport_ErrLog
				WHERE strCommodityCode = @strCommodityCode
				
				UPDATE tblRKM2MBasisImport_ErrLog
				SET strErrMessage = @PreviousErrMsg + 'Invalid commodity.'
				WHERE strCommodityCode = @strCommodityCode AND strFutMarketName = @strFutMarketName
					AND strErrMessage NOT LIKE '%' + 'Invalid commodity.' + '%'
			END
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItem WHERE strItemNo = @strItemNo)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKM2MBasisImport_ErrLog WHERE strItemNo = @strItemNo AND strFutMarketName = @strFutMarketName)
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
				SELECT DISTINCT strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, strLocationName
					, strMarketZone
					, strPeriodTo
					, 'Invalid Item.'
				FROM tblRKM2MBasisImport
				WHERE strItemNo = @strItemNo AND strFutMarketName = @strFutMarketName
			END
			ELSE
			BEGIN
				SELECT @PreviousErrMsg = strErrMessage
				FROM tblRKM2MBasisImport_ErrLog
				WHERE strItemNo = @strItemNo
				
				UPDATE tblRKM2MBasisImport_ErrLog
				SET strErrMessage = @PreviousErrMsg + 'Invalid Item.'
				WHERE strItemNo = @strItemNo AND strFutMarketName = @strFutMarketName
					AND strErrMessage NOT LIKE '%' + 'Invalid Item.' + '%'
			END
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCurrency WHERE strCurrency = @strCurrency)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKM2MBasisImport_ErrLog WHERE strCurrency = @strCurrency AND strFutMarketName = @strFutMarketName)
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
				SELECT DISTINCT strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, strLocationName
					, strMarketZone
					, strPeriodTo
					, 'Invalid currency.'
				FROM tblRKM2MBasisImport
				WHERE strCurrency = @strCurrency AND strFutMarketName = @strFutMarketName
			END
			ELSE
			BEGIN
				SELECT @PreviousErrMsg = strErrMessage
				FROM tblRKM2MBasisImport_ErrLog
				WHERE strCurrency = @strCurrency
				
				UPDATE tblRKM2MBasisImport_ErrLog
				SET strErrMessage = @PreviousErrMsg + 'Invalid currency.'
				WHERE strCurrency = @strCurrency AND strFutMarketName = @strFutMarketName
					AND strErrMessage NOT LIKE '%' + 'Invalid currency.' + '%'
			END
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblICUnitMeasure WHERE strUnitMeasure = @strUnitMeasure)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKM2MBasisImport_ErrLog WHERE strUnitMeasure = @strUnitMeasure AND strUnitMeasure = @strUnitMeasure)
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
				SELECT DISTINCT strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, strLocationName
					, strMarketZone
					, strPeriodTo
					, 'Invalid UOM.'
				FROM tblRKM2MBasisImport
				WHERE strUnitMeasure = @strUnitMeasure AND strFutMarketName = @strFutMarketName
			END
			ELSE
			BEGIN
				SELECT @PreviousErrMsg = strErrMessage
				FROM tblRKM2MBasisImport_ErrLog
				WHERE strUnitMeasure = @strUnitMeasure

				UPDATE tblRKM2MBasisImport_ErrLog
				SET strErrMessage = @PreviousErrMsg + 'Invalid UOM.'
				WHERE strUnitMeasure = @strUnitMeasure AND strFutMarketName = @strFutMarketName
					AND strErrMessage NOT LIKE '%' + 'Invalid UOM.' + '%'
			END
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItem i
					JOIN tblICCommodity c ON i.intCommodityId = c.intCommodityId
					WHERE strItemNo = @strItemNo AND strCommodityCode = @strCommodityCode)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKM2MBasisImport_ErrLog WHERE strItemNo = @strItemNo AND strCommodityCode = @strCommodityCode)
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
				SELECT DISTINCT strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, strLocationName
					, strMarketZone
					, strPeriodTo
					, 'Item (' + strItemNo + ') not configure the commodity (' + strCommodityCode + ').'
				FROM tblRKM2MBasisImport
				WHERE strItemNo = @strItemNo AND strCommodityCode = @strCommodityCode
			END
			ELSE
			BEGIN
				SELECT @PreviousErrMsg = strErrMessage
				FROM tblRKM2MBasisImport_ErrLog
				WHERE strItemNo = @strItemNo
					AND strCommodityCode = @strCommodityCode

				UPDATE tblRKM2MBasisImport_ErrLog
				SET strErrMessage = @PreviousErrMsg + 'Item (' + strItemNo + ') not configure the commodity (' + strCommodityCode + ').'
				WHERE strItemNo = @strItemNo AND strCommodityCode = @strCommodityCode
					AND strErrMessage NOT LIKE '%' + 'Item (' + strItemNo + ') not configure the commodity (' + strCommodityCode + ').' + '%'
			END
		END

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKCommodityMarketMapping MC
					JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = MC.intFutureMarketId
					JOIN tblICCommodity C ON C.intCommodityId = MC.intCommodityId
					WHERE FM.strFutMarketName = @strFutMarketName AND C.strCommodityCode = @strCommodityCode)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKM2MBasisImport_ErrLog WHERE strFutMarketName = @strFutMarketName AND strCommodityCode = @strCommodityCode)
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
				SELECT DISTINCT strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, strLocationName
					, strMarketZone
					, strPeriodTo
					, 'Future Market (' + strItemNo + ') is not configured for commodity (' + strCommodityCode + ').'
				FROM tblRKM2MBasisImport
				WHERE strItemNo = @strItemNo AND strCommodityCode = @strCommodityCode
			END
			ELSE
			BEGIN
				SELECT @PreviousErrMsg = strErrMessage
				FROM tblRKM2MBasisImport_ErrLog
				WHERE strCommodityCode = @strCommodityCode
					AND strFutMarketName = @strFutMarketName
				
				UPDATE tblRKM2MBasisImport_ErrLog
				SET strErrMessage = @PreviousErrMsg + 'Future Market (' + strItemNo + ') is not configured for commodity (' + strCommodityCode + ').'
				WHERE strCommodityCode = @strCommodityCode AND strFutMarketName = @strFutMarketName
					AND strErrMessage NOT LIKE '%' + 'Future Market (' + strItemNo + ') is not configured for commodity (' + strCommodityCode + ').' + '%'
			END
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