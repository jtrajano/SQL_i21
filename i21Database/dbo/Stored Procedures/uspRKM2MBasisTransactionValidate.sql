CREATE PROCEDURE uspRKM2MBasisTransactionValidate

AS

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @PreviousErrMsg NVARCHAR(MAX)
	DECLARE @mRowNumber INT
	DECLARE @strFutMarketName NVARCHAR(50)
	DECLARE @strCommodityCode NVARCHAR(50)
	DECLARE @strItemNo NVARCHAR(50)
	DECLARE @strCurrency NVARCHAR(50)
	DECLARE @dblBasis NUMERIC(18, 6)
	DECLARE @strUnitMeasure NVARCHAR(50)
	DECLARE @strErrMessage NVARCHAR(50)

	SELECT @mRowNumber = MIN(intM2MTransactionImportId) FROM tblRKM2MTransactionImport
	WHILE @mRowNumber > 0
	BEGIN
		SELECT @PreviousErrMsg = ''
			, @strFutMarketName	= NULL
			, @strCommodityCode	= NULL
			, @strItemNo = NULL
			, @strCurrency = NULL
			, @strUnitMeasure = NULL
			, @dblBasis = NULL
		
		SELECT @strFutMarketName = strFutMarketName
			, @strCommodityCode = strCommodityCode
			, @strItemNo = strItemNo
			, @strCurrency = strCurrency
			, @strUnitMeasure = strUnitMeasure
			, @dblBasis = dblBasis
		FROM tblRKM2MTransactionImport
		WHERE intM2MTransactionImportId = @mRowNumber
		
		IF NOT EXISTS(SELECT strFutMarketName FROM tblRKFutureMarket WHERE strFutMarketName = @strFutMarketName)
		BEGIN
			INSERT INTO tblRKM2MTransaction_ErrLog (strFutMarketName
				, strCommodityCode
				, strItemNo
				, strCurrency
				, dblBasis
				, strUnitMeasure
				, strErrMessage)
			SELECT strFutMarketName
				, strCommodityCode
				, strItemNo
				, strCurrency
				, dblBasis
				, strUnitMeasure
				, 'Invalid market.'
			FROM tblRKM2MTransactionImport
			WHERE strFutMarketName = @strFutMarketName
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblICCommodity WHERE strCommodityCode = @strCommodityCode)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKM2MTransaction_ErrLog WHERE strCommodityCode = @strCommodityCode AND strFutMarketName = @strFutMarketName)
			BEGIN
				INSERT INTO tblRKM2MTransaction_ErrLog (strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, strErrMessage)
				SELECT strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, 'Invalid commodity.'
				FROM tblRKM2MTransactionImport
				WHERE strCommodityCode = @strCommodityCode AND strFutMarketName = @strFutMarketName
			END
			ELSE
			BEGIN
				SELECT @PreviousErrMsg = strErrMessage
				FROM tblRKM2MTransaction_ErrLog
				WHERE strCommodityCode = @strCommodityCode
				
				UPDATE tblRKM2MTransaction_ErrLog
				SET strErrMessage = @PreviousErrMsg + 'Invalid commodity.'
				WHERE strCommodityCode = @strCommodityCode AND strFutMarketName = @strFutMarketName
			END
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItem WHERE strItemNo = @strItemNo)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKM2MTransaction_ErrLog WHERE strItemNo = @strItemNo AND strFutMarketName = @strFutMarketName)
			BEGIN
				INSERT INTO tblRKM2MTransaction_ErrLog (strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, strErrMessage)
				SELECT strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, 'Invalid Item.'
				FROM tblRKM2MTransactionImport
				WHERE strItemNo = @strItemNo AND strFutMarketName = @strFutMarketName
			END
			ELSE
			BEGIN
				SELECT @PreviousErrMsg = strErrMessage
				FROM tblRKM2MTransaction_ErrLog
				WHERE strItemNo = @strItemNo
				
				UPDATE tblRKM2MTransaction_ErrLog
				SET strErrMessage = @PreviousErrMsg + 'Invalid Item.'
				WHERE strItemNo = @strItemNo AND strFutMarketName = @strFutMarketName
			END
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCurrency WHERE strCurrency = @strCurrency)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKM2MTransaction_ErrLog WHERE strCurrency = @strCurrency AND strFutMarketName = @strFutMarketName)
			BEGIN
				INSERT INTO tblRKM2MTransaction_ErrLog (strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, strErrMessage)
				SELECT strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, 'Invalid currency.'
				FROM tblRKM2MTransactionImport
				WHERE strCurrency = @strCurrency AND strFutMarketName = @strFutMarketName
			END
			ELSE
			BEGIN
				SELECT @PreviousErrMsg = strErrMessage
				FROM tblRKM2MTransaction_ErrLog
				WHERE strCurrency = @strCurrency
				
				UPDATE tblRKM2MTransaction_ErrLog
				SET strErrMessage = @PreviousErrMsg + 'Invalid currency.'
				WHERE strCurrency = @strCurrency AND strFutMarketName = @strFutMarketName
			END
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblICUnitMeasure WHERE strUnitMeasure = @strUnitMeasure)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKM2MTransaction_ErrLog WHERE strUnitMeasure = @strUnitMeasure AND strUnitMeasure = @strUnitMeasure)
			BEGIN
				INSERT INTO tblRKM2MTransaction_ErrLog (strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, strErrMessage)
				SELECT strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, 'Invalid UOM.'
				FROM tblRKM2MTransactionImport
				WHERE strUnitMeasure = @strUnitMeasure AND strFutMarketName = @strFutMarketName
			END
			ELSE
			BEGIN
				SELECT @PreviousErrMsg = strErrMessage
				FROM tblRKM2MTransaction_ErrLog
				WHERE strUnitMeasure = @strUnitMeasure
				
				UPDATE tblRKM2MTransaction_ErrLog
				SET strErrMessage = @PreviousErrMsg + 'Invalid UOM.'
				WHERE strUnitMeasure = @strUnitMeasure AND strFutMarketName = @strFutMarketName
			END
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItem i
					JOIN tblICCommodity c ON i.intCommodityId = c.intCommodityId
					WHERE strItemNo = @strItemNo AND strCommodityCode = @strCommodityCode)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblRKM2MTransaction_ErrLog WHERE strItemNo = @strItemNo AND strFutMarketName = @strFutMarketName)
			BEGIN
				INSERT INTO tblRKM2MTransaction_ErrLog (strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, strErrMessage)
				SELECT strFutMarketName
					, strCommodityCode
					, strItemNo
					, strCurrency
					, dblBasis
					, strUnitMeasure
					, 'Item (' + strItemNo + ') not configure the commodity (' + strCommodityCode + ').'
				FROM tblRKM2MTransactionImport
				WHERE strItemNo = @strItemNo AND strFutMarketName = @strFutMarketName
			END
			ELSE
			BEGIN
				SELECT @PreviousErrMsg = strErrMessage
				FROM tblRKM2MTransaction_ErrLog
				WHERE strItemNo = @strItemNo
				
				UPDATE tblRKM2MTransaction_ErrLog
				SET strErrMessage = @PreviousErrMsg + 'Item (' + strItemNo + ') not configure the commodity (' + strCommodityCode + ').'
				WHERE strItemNo = @strItemNo AND strFutMarketName = @strFutMarketName
			END
		END
		
		SELECT @mRowNumber = MIN(intM2MTransactionImportId)	FROM tblRKM2MTransactionImport WHERE intM2MTransactionImportId > @mRowNumber
	END
	
	SELECT intTransactionImportErrId
		, 0 as intConcurrencyId
		, strFutMarketName
		, strCommodityCode
		, strItemNo
		, strCurrency
		, dblBasis
		, strUnitMeasure
		, strErrMessage
	FROM tblRKM2MTransaction_ErrLog
	
	DELETE FROM tblRKM2MTransaction_ErrLog
END TRY
BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH