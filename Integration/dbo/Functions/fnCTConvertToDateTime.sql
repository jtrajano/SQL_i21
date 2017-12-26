CREATE FUNCTION [dbo].[fnCTConvertToDateTime]
(
	@intDate INT,
	@intTime INT
)
RETURNS DATETIME

AS 
BEGIN
	DECLARE @DateTimeValue varchar(32), @DateValue char(8), @TimeValue char(6)
 
	SELECT @DateValue = LEFT(CASE WHEN ISNULL(@intDate,'19000101') = '0' THEN '19000101' ELSE ISNULL(@intDate,'19000101') END,8) ,
		   @TimeValue = CASE WHEN ISNULL(@intTime,0) = 0 THEN '000000' 
		ELSE 
			CASE WHEN LEN(@intTime) < 6 THEN REPLICATE('0',6 - LEN(@intTime)) + LTRIM(RTRIM(@intTime))
			ELSE LTRIM(RTRIM(@intTime))
			END
		END
	SELECT @DateTimeValue =
	convert(varchar, convert(datetime, @DateValue), 111)
	+ ' ' + substring(@TimeValue, 1, 2)
	+ ':' + substring(@TimeValue, 3, 2)
	+ ':' + substring(@TimeValue, 5, 2)

	RETURN	CONVERT(DATETIME,@DateTimeValue	)
END