CREATE PROC uspRKM2MBasisTransactionValidate

AS

BEGIN TRY
DECLARE @ErrMsg nvarchar(Max)
DECLARE @PreviousErrMsg nvarchar(Max)
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
	SELECT @PreviousErrMsg=''

		SET @strFutMarketName	= NULL
		SET @strCommodityCode	= NULL
		SET @strItemNo			= NULL
		SET @strCurrency		= NULL
		SET @strUnitMeasure		= NULL
		SET @dblBasis			= NULL

SELECT @strFutMarketName=strFutMarketName,@strCommodityCode=strCommodityCode, @strItemNo=strItemNo,@strCurrency=strCurrency,
	   @strUnitMeasure=strUnitMeasure,@dblBasis=dblBasis FROM tblRKM2MTransactionImport WHERE intM2MTransactionImportId=@mRowNumber

IF NOT EXISTS(SELECT strFutMarketName FROM tblRKFutureMarket WHERE strFutMarketName =@strFutMarketName)
BEGIN
	INSERT INTO tblRKM2MTransaction_ErrLog (strFutMarketName, strCommodityCode,strItemNo,strCurrency,dblBasis,strUnitMeasure,strErrMessage)
	SELECT strFutMarketName, strCommodityCode,strItemNo,strCurrency,dblBasis,strUnitMeasure,'Invalid market.' FROM  tblRKM2MTransactionImport 
	WHERE strFutMarketName = @strFutMarketName
	
END

IF NOT EXISTS(SELECT * FROM tblICCommodity where strCommodityCode = @strCommodityCode )
BEGIN

	IF NOT EXISTS(SELECT * FROM tblRKM2MTransaction_ErrLog WHERE  strCommodityCode = @strCommodityCode AND  strFutMarketName =@strFutMarketName)
	BEGIN
		INSERT INTO tblRKM2MTransaction_ErrLog (strFutMarketName, strCommodityCode,strItemNo,strCurrency,dblBasis,strUnitMeasure,strErrMessage)
		SELECT strFutMarketName, strCommodityCode,strItemNo,strCurrency,dblBasis,strUnitMeasure, 'Invalid commodity.' FROM tblRKM2MTransactionImport 
		WHERE strCommodityCode = @strCommodityCode and strFutMarketName =@strFutMarketName			
	END
	ELSE
	BEGIN
	SELECT @PreviousErrMsg=strErrMessage FROM tblRKM2MTransaction_ErrLog WHERE strCommodityCode = @strCommodityCode
	UPDATE tblRKM2MTransaction_ErrLog set strErrMessage = @PreviousErrMsg +'Invalid commodity.' WHERE strCommodityCode = @strCommodityCode AND strFutMarketName =@strFutMarketName
	ENd
END	

IF NOT EXISTS(SELECT * FROM tblICItem where strItemNo = @strItemNo )
BEGIN

	IF NOT EXISTS(SELECT * FROM tblRKM2MTransaction_ErrLog WHERE  strItemNo = @strItemNo and  strFutMarketName =@strFutMarketName)
	BEGIN
		INSERT INTO tblRKM2MTransaction_ErrLog (strFutMarketName, strCommodityCode,strItemNo,strCurrency,dblBasis,strUnitMeasure,strErrMessage)
		SELECT strFutMarketName, strCommodityCode,strItemNo,strCurrency,dblBasis,strUnitMeasure, 'Invalid Item.' FROM  tblRKM2MTransactionImport 
		WHERE strItemNo = @strItemNo and strFutMarketName =@strFutMarketName			
	END
	ELSE
	BEGIN

	SELECT @PreviousErrMsg=strErrMessage from tblRKM2MTransaction_ErrLog WHERE strItemNo = @strItemNo
	UPDATE tblRKM2MTransaction_ErrLog set strErrMessage = @PreviousErrMsg +'Invalid Item.' WHERE strItemNo = @strItemNo and strFutMarketName =@strFutMarketName
	ENd
END	

IF NOT EXISTS(SELECT * FROM tblSMCurrency where strCurrency = @strCurrency )
BEGIN

	IF NOT EXISTS(SELECT * FROM tblRKM2MTransaction_ErrLog WHERE  strCurrency = @strCurrency and  strFutMarketName =@strFutMarketName)
	BEGIN
		INSERT INTO tblRKM2MTransaction_ErrLog (strFutMarketName, strCommodityCode,strItemNo,strCurrency,dblBasis,strUnitMeasure,strErrMessage)
		SELECT strFutMarketName, strCommodityCode,strItemNo,strCurrency,dblBasis,strUnitMeasure, 'Invalid currency.' FROM  tblRKM2MTransactionImport 
		WHERE strCurrency = @strCurrency and strFutMarketName =@strFutMarketName			
	END
	ELSE
	BEGIN

	SELECT @PreviousErrMsg=strErrMessage from tblRKM2MTransaction_ErrLog WHERE strCurrency = @strCurrency
	UPDATE tblRKM2MTransaction_ErrLog set strErrMessage = @PreviousErrMsg +'Invalid currency.' WHERE strCurrency = @strCurrency and strFutMarketName =@strFutMarketName
	ENd
END

IF NOT EXISTS(SELECT * FROM tblICUnitMeasure where strUnitMeasure = @strUnitMeasure )
BEGIN

	IF NOT EXISTS(SELECT * FROM tblRKM2MTransaction_ErrLog WHERE  strUnitMeasure = @strUnitMeasure and  strUnitMeasure =@strUnitMeasure)
	BEGIN
		INSERT INTO tblRKM2MTransaction_ErrLog (strFutMarketName, strCommodityCode,strItemNo,strCurrency,dblBasis,strUnitMeasure,strErrMessage)
		SELECT strFutMarketName, strCommodityCode,strItemNo,strCurrency,dblBasis,strUnitMeasure, 'Invalid UOM.' FROM  tblRKM2MTransactionImport 
		WHERE strUnitMeasure = @strUnitMeasure and strFutMarketName =@strFutMarketName			
	END
	ELSE
	BEGIN

	SELECT @PreviousErrMsg=strErrMessage from tblRKM2MTransaction_ErrLog WHERE strUnitMeasure = @strUnitMeasure
	UPDATE tblRKM2MTransaction_ErrLog set strErrMessage = @PreviousErrMsg +'Invalid UOM.' WHERE strUnitMeasure = @strUnitMeasure and strFutMarketName =@strFutMarketName
	ENd
END

IF NOT EXISTS(SELECT * FROM tblICItem i
			  join tblICCommodity c on i.intCommodityId=c.intCommodityId WHERE strItemNo = @strItemNo and strCommodityCode=@strCommodityCode)
BEGIN

	IF NOT EXISTS(SELECT * FROM tblRKM2MTransaction_ErrLog WHERE  strItemNo = @strItemNo and  strFutMarketName =@strFutMarketName)
	BEGIN
		INSERT INTO tblRKM2MTransaction_ErrLog (strFutMarketName, strCommodityCode,strItemNo,strCurrency,dblBasis,strUnitMeasure,strErrMessage)
		SELECT strFutMarketName, strCommodityCode,strItemNo,strCurrency,dblBasis,strUnitMeasure, 'Item ('+strItemNo+') not configure the commodity ('+strCommodityCode+').' FROM  tblRKM2MTransactionImport 
		WHERE strItemNo = @strItemNo and strFutMarketName =@strFutMarketName			
	END
	ELSE
	BEGIN

	SELECT @PreviousErrMsg=strErrMessage from tblRKM2MTransaction_ErrLog WHERE strItemNo = @strItemNo
	UPDATE tblRKM2MTransaction_ErrLog set strErrMessage = @PreviousErrMsg +'Item ('+strItemNo+') not configure the commodity ('+strCommodityCode+').' WHERE strItemNo = @strItemNo and strFutMarketName =@strFutMarketName
	ENd
END



SELECT @mRowNumber = MIN(intM2MTransactionImportId)	FROM tblRKM2MTransactionImport	WHERE intM2MTransactionImportId > @mRowNumber
END

SELECT intTransactionImportErrId,0 as intConcurrencyId,strFutMarketName, strCommodityCode,strItemNo,strCurrency,dblBasis,strUnitMeasure,strErrMessage from tblRKM2MTransaction_ErrLog

DELETE FROM tblRKM2MTransaction_ErrLog
END TRY
BEGIN CATCH
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
End Catch