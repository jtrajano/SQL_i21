CREATE PROCEDURE [dbo].[uspGRValidateStorageStmtFormNo]
	  @strMode NVARCHAR(100)
	 ,@strFormNumber NVARCHAR(100)
	 ,@StorageStmtValidationmsg NVARCHAR(1000)OUTPUT
AS
BEGIN TRY
	SET NOCOUNT ON
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @HighestUsedFormNo NVARCHAR(MAX)
	SET @StorageStmtValidationmsg = 'Success'
	
	SELECT TOP 1 @HighestUsedFormNo = strFormNumber FROM tblGRStorageStatement ORDER BY strFormNumber DESC
	
	IF @strMode ='new'
	BEGIN
			IF EXISTS(SELECT 1  FROM tblGRStorageStatement WHERE strFormNumber = @strFormNumber)
			BEGIN
				SET @StorageStmtValidationmsg = 'The FormNumber already exist.'
			END
			ELSE IF @strFormNumber < = @HighestUsedFormNo
			BEGIN
				SET @StorageStmtValidationmsg = 'The form number should be greater than the highest used form number '+LTRIM(@HighestUsedFormNo)+'.'
			END
	END
	ELSE IF @strMode ='edit' AND NOT EXISTS(SELECT 1 FROM tblGRStorageStatement WHERE strFormNumber = @strFormNumber)
	BEGIN
			SET @StorageStmtValidationmsg = 'The FormNumber does not exist.'
	END

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = 'uspGRValidateStorageStmtFormNo: ' + @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')	
END CATCH