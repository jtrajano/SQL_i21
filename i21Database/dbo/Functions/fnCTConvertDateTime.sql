CREATE FUNCTION [dbo].[fnCTConvertDateTime]
(
	@dtmDate DATETIME,
	@strDirection NVARCHAR(15),	-- "TOUTCDATE" - Convert from the given date to UTC date "TOSERVERDATE" - Convert from the given date to Server date
	@ysnDateOnly BIT
)
RETURNS DATETIME
AS
BEGIN


	DECLARE @date DATETIME

	IF UPPER(@strDirection) ='TOUTCDATE'
	BEGIN
		SELECT @date = DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), @dtmDate)
	END
	ELSE IF UPPER(@strDirection) = 'TOSERVERDATE'
	BEGIN
		SELECT @date = DATEADD(hh, DATEDIFF(hh, GETUTCDATE(), GETDATE()), @dtmDate)
	END
	ELSE
	BEGIN
		SET @date = @dtmDate
	END

	IF @ysnDateOnly = 1
	BEGIN
		SET @date = dbo.fnRemoveTimeOnDate(@date)
	END
	
	RETURN @date
END