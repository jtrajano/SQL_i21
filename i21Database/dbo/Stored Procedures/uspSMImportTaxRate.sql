CREATE PROCEDURE [dbo].[uspSMImportTaxRate]
	@taxCode NVARCHAR(100),
	@calculationMethod NVARCHAR(15),
	@unitOfMeasure NVARCHAR(50),
	@rate NUMERIC(18, 6),
	@effectiveDate DATETIME
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

-- Check if vendor is existing ?? if not continue the loop
IF EXISTS (SELECT TOP 1 1 FROM tblSMTaxCode WHERE strTaxCode = @taxCode)
BEGIN
	DECLARE @taxCodeId INT

	SELECT @taxCodeId = intTaxCodeId FROM tblSMTaxCode WHERE strTaxCode = @taxCode

	DECLARE @unitOfMeasureId INT
	SELECT @unitOfMeasureId = intUnitMeasureId FROM tblICUnitMeasure WHERE strUnitMeasure = @unitOfMeasure

	-- Insert tax code rate if not exist
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMTaxCodeRate WHERE intTaxCodeId = @taxCodeId AND strCalculationMethod = @calculationMethod AND dtmEffectiveDate = @effectiveDate)
	BEGIN
		INSERT INTO tblSMTaxCodeRate(intTaxCodeId, strCalculationMethod, intUnitMeasureId, dblRate, dtmEffectiveDate) 
		VALUES(@taxCodeId, @calculationMethod, @unitOfMeasureId, @rate, @effectiveDate)
	END
	-- Update exisiting tax code rate
	ELSE
	BEGIN
		UPDATE tblSMTaxCodeRate SET dblRate = @rate
		WHERE intTaxCodeId = @taxCodeId AND strCalculationMethod = @calculationMethod AND dtmEffectiveDate = @effectiveDate
	END	
END
