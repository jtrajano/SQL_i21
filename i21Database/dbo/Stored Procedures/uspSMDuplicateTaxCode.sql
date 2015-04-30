CREATE PROCEDURE [dbo].[uspSMDuplicateTaxCode]
	@intTaxCodeId INT,
	@newTaxCodeId INT OUTPUT
AS
BEGIN

	INSERT dbo.tblSMTaxCode([strTaxCode], [intTaxClassId], [strDescription], [strCalculationMethod], [numRate], 
							[strTaxAgency], [strAddress], [strZipCode], [strState], [strCity], [strCountry], [strCounty], 
							[intSalesTaxAccountId], [intPurchaseTaxAccountId], [strTaxableByOtherTaxes], [ysnCheckoffTax])
	SELECT 'DUP: ' + [strTaxCode], [intTaxClassId], [strDescription], [strCalculationMethod], [numRate], 
		   [strTaxAgency], [strAddress], [strZipCode], [strState], [strCity],[strCountry], [strCounty], 
		   [intSalesTaxAccountId], [intPurchaseTaxAccountId], [strTaxableByOtherTaxes], [ysnCheckoffTax]
	FROM dbo.tblSMTaxCode 
	WHERE [intTaxCodeId] = @intTaxCodeId;
	
	SELECT @newTaxCodeId = SCOPE_IDENTITY();

END