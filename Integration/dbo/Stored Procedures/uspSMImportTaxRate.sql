IF EXISTS(select top 1 1 from sys.procedures where name = 'uspSMImportTaxRate')
	DROP PROCEDURE uspSMImportTaxRate
GO

EXEC
('

	CREATE PROCEDURE [dbo].[uspSMImportTaxRate]
		@taxCode NVARCHAR(100),
		@calculationMethod NVARCHAR(15),
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

		-- Insert tax code rate if not exist
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMTaxCodeRate WHERE intTaxCodeId = @taxCodeId AND strCalculationMethod = @calculationMethod AND dtmEffectiveDate = @effectiveDate)
		BEGIN
			INSERT INTO tblSMTaxCodeRate(intTaxCodeId, strCalculationMethod, dblRate, dtmEffectiveDate) 
			VALUES(@taxCodeId, @calculationMethod, @rate, @effectiveDate)
		END
		-- Update exisiting tax code rate
		ELSE
		BEGIN
			UPDATE tblSMTaxCodeRate SET dblRate = @rate
			WHERE intTaxCodeId = @taxCodeId AND strCalculationMethod = @calculationMethod AND dtmEffectiveDate = @effectiveDate
		END	
	END

')