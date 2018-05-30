CREATE PROCEDURE [dbo].[uspAPGetBalance]
	@userId INT,
	@apBalance DECIMAL(18,6) OUTPUT,
	@apGLBalance DECIMAL(18,6) OUTPUT
AS
BEGIN

	DECLARE @ap DECIMAL(18,6);
	DECLARE @gl DECIMAL(18,6);
	DECLARE @log NVARCHAR(100);

	EXEC uspAPBalance @UserId = @userId, @balance = @ap OUT, @logKey = @log OUT;
	EXEC uspAPGLBalance @UserId = @userId, @balance = @gl OUT, @logKey = @log OUT;

	SET @apBalance = @ap;
	SET @apGLBalance = @gl
END