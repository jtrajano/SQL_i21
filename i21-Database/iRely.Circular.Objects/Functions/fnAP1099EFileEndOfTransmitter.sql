CREATE FUNCTION [dbo].[fnAP1099EFileEndOfTransmitter]
(
	@totalPayer INT
)
RETURNS NVARCHAR(1500)
AS
BEGIN
	DECLARE @endOfTransmitter NVARCHAR(1500)

	SELECT
		@endOfTransmitter = 
		'F'
		+ REPLICATE('0',8 - LEN(CAST(@totalPayer AS NVARCHAR(16)))) + CAST(@totalPayer AS NVARCHAR(16))
		+ REPLICATE('0',21)
		+ SPACE(19)
		+ SPACE(8)
		+ SPACE(442)
		+ REPLICATE('0',8) -- 500-507
		+ SPACE(241)
		+ SPACE(2)


	RETURN @endOfTransmitter;
END
