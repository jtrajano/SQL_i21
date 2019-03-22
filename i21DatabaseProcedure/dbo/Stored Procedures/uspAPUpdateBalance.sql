CREATE PROCEDURE [dbo].[uspAPUpdateBalance]
	@userId 	INT,
	@APBalance  DECIMAL(18,6) = NULL,
	@GLBalance  DECIMAL(18,6) = NULL
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	DECLARE @transCount INT;
	DECLARE @CurrentAPBalance DECIMAL(18, 6);
	DECLARE @CurrentGLBalance DECIMAL(18, 6);
	DECLARE @o1 DECIMAL(18,6)
	DECLARE @o2 NVARCHAR(100)
	DECLARE @p1 DECIMAL(18,6)
	DECLARE @p2 NVARCHAR(100)

	SET @transCount = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblAPBalance)
	BEGIN
		INSERT INTO tblAPBalance(dblAPBalance, dblGLBalance, ysnBalance)
		SELECT NULL, NULL, NULL
	END

	SELECT TOP 1 
		@CurrentAPBalance = dblAPBalance,
		@CurrentGLBalance = dblGLBalance
	FROM tblAPBalance

	IF @CurrentAPBalance IS NULL
	BEGIN
		EXEC [uspAPBalance] @userId, @o1 OUTPUT, @o2 OUTPUT	
		
		UPDATE tblAPBalance SET dblAPBalance = @o1
	END

	IF @CurrentGLBalance IS NULL
	BEGIN
		EXEC uspAPGLBalance @userId, @p1 OUTPUT, @p2 OUTPUT	
		
		UPDATE tblAPBalance SET dblGLBalance = @p1
	END

	IF @APBalance IS NULL AND @GLBalance IS NULL
	BEGIN
		EXEC [uspAPBalance] @userId, @o1 OUTPUT, @o2 OUTPUT	
		
		UPDATE tblAPBalance SET dblAPBalance = @o1

			
		EXEC uspAPGLBalance @userId, @p1 OUTPUT, @p2 OUTPUT	
		
		UPDATE tblAPBalance SET dblGLBalance = @p1
	END
	
	IF(@APBalance IS NOT NULL)
	BEGIN
		UPDATE tblAPBalance SET dblAPBalance = dblAPBalance + @APBalance, @CurrentAPBalance = dblAPBalance + @APBalance
	END

	IF(@GLBalance IS NOT NULL)
	BEGIN
		UPDATE tblAPBalance SET dblGLBalance = dblGLBalance + @GLBalance, @CurrentGLBalance = dblGLBalance + @GLBalance
	END

	UPDATE tblAPBalance SET [ysnBalance] = CASE WHEN (dblGLBalance = dblAPBalance) THEN 1 ELSE 0 END

	IF @CurrentAPBalance != @CurrentGLBalance
	BEGIN
		--Double check if really NOT balance using usual script of checking the balance
		EXEC [uspAPBalance] @userId, @o1 OUTPUT, @o2 OUTPUT	
		
		UPDATE tblAPBalance SET dblAPBalance = @o1

		EXEC uspAPGLBalance @userId, @p1 OUTPUT, @p2 OUTPUT	
		
		UPDATE tblAPBalance SET dblGLBalance = @p1

		UPDATE tblAPBalance SET [ysnBalance] = CASE WHEN (dblGLBalance = dblAPBalance) THEN 1 ELSE 0 END

	END

IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH
DECLARE @ErrorSeverity INT,
		@ErrorNumber   INT,
		@ErrorMessage nvarchar(4000),
		@ErrorState INT,
		@ErrorLine  INT,
		@ErrorProc nvarchar(200);
        -- Grab error information from SQL functions
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorNumber   = ERROR_NUMBER()
    SET @ErrorMessage  = ERROR_MESSAGE()
    SET @ErrorState    = ERROR_STATE()
    SET @ErrorLine     = ERROR_LINE()
    SET @ErrorProc     = ERROR_PROCEDURE()
    SET @ErrorMessage  = 'Failed to update the ap balance'
    IF @ErrorState  = 0
    SET @ErrorState = 1
    -- If the error renders the transaction as uncommittable or we have open transactions, we may want to rollback
    IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
    RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

END