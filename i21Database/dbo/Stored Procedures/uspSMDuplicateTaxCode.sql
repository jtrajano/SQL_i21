CREATE PROCEDURE [dbo].[uspSMDuplicateTaxCode]
	@intTaxCodeId INT,
	@newTaxCodeId INT OUTPUT
AS
BEGIN

	DECLARE @intCount NVARCHAR

	SELECT @intCount = COUNT(*) FROM [tblSMTaxCode] WHERE [strTaxCode] LIKE 'DUP: ' + (SELECT [strTaxCode] FROM [dbo].[tblSMTaxCode] WHERE intTaxCodeId = @intTaxCodeId) + '%' 
		--AND [strTaxCode] NOT LIKE '% DUP: ' + (SELECT [strTaxCode] FROM [dbo].[tblSMTaxCode] WHERE intTaxCodeId = @intTaxCodeId)

	INSERT dbo.tblSMTaxCode([strTaxCode], [intTaxClassId], [strDescription], /*[strCalculationMethod], [numRate], */
							[strTaxAgency], [strAddress], [strZipCode], [strState], [strCity], [strCountry], [strCounty], 
							[intSalesTaxAccountId], [intPurchaseTaxAccountId], [strTaxableByOtherTaxes], [ysnCheckoffTax])
	SELECT CASE @intCount WHEN 0 
		   THEN 'DUP: ' + [strTaxCode] 
		   ELSE 'DUP: ' + [strTaxCode] + ' (' + @intCount + ')' END,
	[intTaxClassId], [strDescription], /*[strCalculationMethod], [numRate], */
	[strTaxAgency], [strAddress], [strZipCode], [strState], [strCity],[strCountry], [strCounty], 
	[intSalesTaxAccountId], [intPurchaseTaxAccountId], [strTaxableByOtherTaxes], [ysnCheckoffTax]
	FROM dbo.tblSMTaxCode 
	WHERE [intTaxCodeId] = @intTaxCodeId;
	
	SELECT @newTaxCodeId = SCOPE_IDENTITY();

	INSERT INTO tblSMTaxCodeRate([intTaxCodeId], [strCalculationMethod], [numRate], [dtmEffectiveDate])
	SELECT @newTaxCodeId, [strCalculationMethod], [numRate], [dtmEffectiveDate]
	FROM dbo.tblSMTaxCodeRate
	WHERE [intTaxCodeId] = @intTaxCodeId

END