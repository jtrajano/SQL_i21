CREATE PROCEDURE [dbo].[uspAPGetBalance]
	@userId INT,
	@dateFrom DATETIME = NULL,
	@dateTo DATETIME = NULL,
	@apBalance DECIMAL(18,6) OUTPUT,
	@apGLBalance DECIMAL(18,6) OUTPUT
AS
BEGIN

	DECLARE @ap DECIMAL(18,6);
	DECLARE @gl DECIMAL(18,6);
	DECLARE @log NVARCHAR(100);

	EXEC uspAPBalance @UserId = @userId, @dateFrom = @dateFrom, @dateTo = @dateTo, @balance = @ap OUT, @logKey = @log OUT;
	EXEC uspAPGLBalance @UserId = @userId, @dateFrom = @dateFrom, @dateTo = @dateTo, @balance = @gl OUT, @logKey = @log OUT;

	IF @ap != @gl
	BEGIN
		INSERT INTO tblAPBalanceLog(
			dtmDate,
			dblAPBalance,
			dblAPGLBalance
		)
		VALUES(GETDATE(), @ap, @gl)
	END
	
	SET @apBalance = @ap;
	SET @apGLBalance = @gl

END