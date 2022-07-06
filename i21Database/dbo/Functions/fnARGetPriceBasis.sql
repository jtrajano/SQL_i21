CREATE FUNCTION [dbo].[fnARGetPriceBasis]
(
	@strPriceBasisDescription	NVARCHAR(100)
)
RETURNS NVARCHAR(10)
AS
BEGIN
	DECLARE @strPriceBasis NVARCHAR(10)

	SET @strPriceBasis = CASE WHEN @strPriceBasisDescription = 'Maximum'
									THEN 'X'
							  WHEN @strPriceBasisDescription = 'Fixed'
									THEN 'F'
							  WHEN @strPriceBasisDescription = 'Inventory Cost + Pct'
									THEN 'C'
							  WHEN @strPriceBasisDescription = 'Inventory Cost + Amt'
									THEN 'A'
							  WHEN @strPriceBasisDescription = 'Sell - Pct'
									THEN 'S'
							  WHEN @strPriceBasisDescription = 'Sell - Amt'
									THEN 'M'
							  WHEN @strPriceBasisDescription = 'Fixed Rack + Amount'
									THEN 'R'
							  WHEN @strPriceBasisDescription = 'Vendor Rack + Amt'
									THEN 'V'
							  WHEN @strPriceBasisDescription = 'Transport Rack + Amt'
									THEN 'T'
							  WHEN @strPriceBasisDescription = 'Link'
									THEN 'L'
							  WHEN @strPriceBasisDescription = 'Origin Rack + Amt'
									THEN 'O'
							  ELSE ''
						 END

	RETURN @strPriceBasis
END
GO