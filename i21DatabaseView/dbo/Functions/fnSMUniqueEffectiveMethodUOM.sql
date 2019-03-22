CREATE FUNCTION [dbo].[fnSMUniqueEffectiveMethodUOM]
(
	@taxCodeId INT,
	@effectiveDate DATETIME,
	@method NVARCHAR(12),
	@oumId INT = NULL
)
RETURNS INT
AS
BEGIN
  DECLARE @retval INT

  IF @method = 'Unit'
  BEGIN
	IF @oumId IS NULL
	BEGIN
		SELECT @retval = COUNT(*) FROM tblSMTaxCodeRate
		WHERE intTaxCodeId = @taxCodeId AND dtmEffectiveDate = @effectiveDate AND strCalculationMethod = @method AND intUnitMeasureId IS NULL
	END
	ELSE
	BEGIN
		SELECT @retval = COUNT(*) FROM tblSMTaxCodeRate
		WHERE intTaxCodeId = @taxCodeId AND dtmEffectiveDate = @effectiveDate AND strCalculationMethod = @method AND intUnitMeasureId = @oumId
	END
  END
  ELSE
  BEGIN
	SELECT @retval = COUNT(*) FROM tblSMTaxCodeRate
	WHERE intTaxCodeId = @taxCodeId AND dtmEffectiveDate = @effectiveDate AND strCalculationMethod = @method
  END

  RETURN @retval
END
