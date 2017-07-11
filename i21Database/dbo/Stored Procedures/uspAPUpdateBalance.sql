CREATE PROCEDURE [dbo].[uspAPUpdateBalance]
	@APBalance  DECIMAL(18,6) = null,
	@GLBalance  DECIMAL(18,6) = null
AS

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblAPBalance)
	BEGIN
		INSERT INTO tblAPBalance(dblAPBalance, dblGLBalance, ysnBalance)
		SELECT NULL, NULL, NULL
	END
	DECLARE @CurrentAPBalance DECIMAL(18, 6)
	DECLARE @CurrentGLBalance DECIMAL(18, 6)

	SELECT TOP 1 @CurrentAPBalance = dblAPBalance,
			@CurrentGLBalance = dblGLBalance
		FROM tblAPBalance

	IF @CurrentAPBalance IS NULL
	BEGIN

		
		declare @o1 DECIMAL(18,6)
		declare @o2 NVARCHAR(100)
		exec [uspAPBalance] 1, @o1 output, @o2 output	
		
		UPDATE tblAPBalance SET dblAPBalance = @o1

	END

	IF @CurrentGLBalance IS NULL
	BEGIN

		
		declare @p1 DECIMAL(18,6)
		declare @p2 NVARCHAR(100)
		exec uspAPGLBalance 1, @p1 output, @p2 output	
		
		UPDATE tblAPBalance SET dblGLBalance = @p1

	END

	IF(@APBalance is not null)
	BEGIN
		UPDATE tblAPBalance SET dblAPBalance = dblAPBalance + @APBalance
	END

	IF(@GLBalance is not null)
	BEGIN
		UPDATE tblAPBalance SET dblGLBalance = dblGLBalance + @GLBalance
	END

	UPDATE tblAPBalance SET [ysnBalance] = CASE WHEN (dblGLBalance = dblAPBalance) THEN 1 ELSE 0 END

RETURN 0
