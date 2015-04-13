CREATE PROCEDURE [dbo].[uspSMDuplicateTaxCode]
	@intTaxCodeId int,
	@strTaxCode NVARCHAR(100) OUTPUT
AS
BEGIN

	DECLARE @newTaxCodeId INT
	DECLARE @newName VARCHAR(100) = CONVERT(nvarchar(MAX), GETDATE(), 20);

	INSERT dbo.tblSMTaxCode([strTaxCode], [intTaxClassId], [strDescription], [strCalculationMethod], [numRate], 
							[strTaxAgency], [strAddress], [strZipCode], [strState], [strCity],
							[strCountry], [strCounty], [intSalesTaxAccountId], [intPurchaseTaxAccountId], [strTaxableByOtherTaxes])
	SELECT [strTaxCode] + ' ' + @newName, [intTaxClassId], [strDescription], [strCalculationMethod], [numRate], 
		   [strTaxAgency], [strAddress], [strZipCode], [strState], [strCity],[strCountry], [strCounty], 
		   [intSalesTaxAccountId], [intPurchaseTaxAccountId], [strTaxableByOtherTaxes]
	FROM dbo.tblSMTaxCode 
	WHERE [intTaxCodeId] = @intTaxCodeId;
	
	SELECT @newTaxCodeId = SCOPE_IDENTITY();

	SELECT @strTaxCode = [strTaxCode] FROM  dbo.tblSMTaxCode WHERE [intTaxCodeId] = @newTaxCodeId

END