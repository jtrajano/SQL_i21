CREATE PROCEDURE [dbo].[uspSMDuplicateTaxCode]
	@intTaxCodeId INT,
	@newTaxCodeId INT OUTPUT
AS
BEGIN

	DECLARE @intCount NVARCHAR

	SELECT @intCount = COUNT(*) FROM [tblSMTaxCode] WHERE [strTaxCode] LIKE 'DUP: ' + (SELECT [strTaxCode] FROM [dbo].[tblSMTaxCode] WHERE intTaxCodeId = @intTaxCodeId) + '%' 
		--AND [strTaxCode] NOT LIKE '% DUP: ' + (SELECT [strTaxCode] FROM [dbo].[tblSMTaxCode] WHERE intTaxCodeId = @intTaxCodeId)

	INSERT dbo.tblSMTaxCode([strTaxCode],[intTaxClassId],[strDescription],[strTaxAgency],[intTaxAgencyId],[strAddress],
	[strZipCode],[strState],[strCity],[strCountry],[strCounty],	[ysnMatchTaxAddress],[intSalesTaxAccountId],[intPurchaseTaxAccountId],
	[ysnExpenseAccountOverride],[strTaxableByOtherTaxes],[ysnTaxOnly],[ysnCheckoffTax],[intTaxCategoryId],[strStoreTaxNumber],[intPayToVendorId])
	SELECT CASE @intCount WHEN 0 
		   THEN 'DUP: ' + [strTaxCode] 
		   ELSE 'DUP: ' + [strTaxCode] + ' (' + @intCount + ')' END,
	[intTaxClassId],[strDescription],[strTaxAgency],[intTaxAgencyId],[strAddress],[strZipCode],[strState],[strCity],
	[strCountry],[strCounty],[ysnMatchTaxAddress],[intSalesTaxAccountId],[intPurchaseTaxAccountId],[ysnExpenseAccountOverride],
	[strTaxableByOtherTaxes],[ysnTaxOnly],[ysnCheckoffTax],[intTaxCategoryId],[strStoreTaxNumber],[intPayToVendorId]
	FROM dbo.tblSMTaxCode 
	WHERE [intTaxCodeId] = @intTaxCodeId;
	
	SELECT @newTaxCodeId = SCOPE_IDENTITY();

	INSERT INTO tblSMTaxCodeRate([intTaxCodeId], [strCalculationMethod], [intUnitMeasureId], [dblRate], [dtmEffectiveDate])
	SELECT @newTaxCodeId, [strCalculationMethod], [intUnitMeasureId], [dblRate], [dtmEffectiveDate]
	FROM dbo.tblSMTaxCodeRate
	WHERE [intTaxCodeId] = @intTaxCodeId

END