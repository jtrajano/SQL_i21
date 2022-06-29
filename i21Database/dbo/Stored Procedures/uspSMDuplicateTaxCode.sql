CREATE PROCEDURE [dbo].[uspSMDuplicateTaxCode]
	@intTaxCodeId INT,
	@newTaxCodeId INT OUTPUT
AS
BEGIN

	DECLARE @intCount NVARCHAR
	DECLARE @ysnTexasLoadingFee BIT

	SELECT @intCount = COUNT(*) FROM [tblSMTaxCode] WHERE [strTaxCode] LIKE 'DUP: ' + (SELECT [strTaxCode] FROM [dbo].[tblSMTaxCode] WHERE intTaxCodeId = @intTaxCodeId) + '%' 
		--AND [strTaxCode] NOT LIKE '% DUP: ' + (SELECT [strTaxCode] FROM [dbo].[tblSMTaxCode] WHERE intTaxCodeId = @intTaxCodeId)

	INSERT dbo.tblSMTaxCode([strTaxCode],[intTaxClassId],[strDescription],[strTaxAgency],[intTaxAgencyId],[strAddress],[strZipCode],[strState],[strCity],
	[strCountry],[strCounty],[ysnMatchTaxAddress],[ysnAddToCost],[intSalesTaxAccountId],[intPurchaseTaxAccountId],[ysnExpenseAccountOverride],
	[strTaxableByOtherTaxes],[ysnTaxOnly],[ysnCheckoffTax],[strTaxPoint],[intTaxCategoryId],[strStoreTaxNumber],[intPayToVendorId],[ysnTexasLoadingFee])
	SELECT CASE @intCount WHEN 0 
		   THEN 'DUP: ' + [strTaxCode] 
		   ELSE 'DUP: ' + [strTaxCode] + ' (' + @intCount + ')' END,
	[intTaxClassId],[strDescription],[strTaxAgency],[intTaxAgencyId],[strAddress],[strZipCode],[strState],[strCity],
	[strCountry],[strCounty],[ysnMatchTaxAddress],[ysnAddToCost],[intSalesTaxAccountId],[intPurchaseTaxAccountId],[ysnExpenseAccountOverride],
	[strTaxableByOtherTaxes],[ysnTaxOnly],[ysnCheckoffTax],[strTaxPoint],[intTaxCategoryId],[strStoreTaxNumber],[intPayToVendorId],[ysnTexasLoadingFee]
	FROM dbo.tblSMTaxCode 
	WHERE [intTaxCodeId] = @intTaxCodeId;
	
	SELECT @newTaxCodeId = SCOPE_IDENTITY();
	SELECT @ysnTexasLoadingFee = [ysnTexasLoadingFee] FROM dbo.tblSMTaxCode WHERE intTaxCodeId = @newTaxCodeId
	
	INSERT INTO tblSMTaxCodeRate([intTaxCodeId], [strCalculationMethod], [intUnitMeasureId], [dblRate], [dtmEffectiveDate])
		SELECT @newTaxCodeId, [strCalculationMethod], [intUnitMeasureId], [dblRate], [dtmEffectiveDate]
		FROM dbo.tblSMTaxCodeRate
		WHERE [intTaxCodeId] = @intTaxCodeId

	--WE NEED TO COPY LOADING FEE ONE BY ONE
	IF ISNULL(@ysnTexasLoadingFee, 0) = 0
	BEGIN
		DECLARE @rateCount INT
		DECLARE @updateCount INT = 0
		DECLARE @intTaxCodeRateId INT
		
		DECLARE temp_cursor CURSOR FOR  
		SELECT intTaxCodeRateId FROM tblSMTaxCodeRate
		WHERE @intTaxCodeId = @newTaxCodeId

		OPEN temp_cursor
		FETCH NEXT FROM temp_cursor INTO @intTaxCodeRateId

		WHILE @@FETCH_STATUS = 0   
		BEGIN
			IF ISNULL(@intTaxCodeRateId, 0) <> 0
			BEGIN
				INSERT INTO tblSMTaxCodeRateLoadingFee([intTaxCodeRateId], [dblTotalGalsFrom], [dblTotalGalsTo], [dblGasolineGalsFrom], [dblGasolineGalsTo],
				[dblFeeAmount], [dblIncrementalGals], [dblIncrementalAmount], [intConcurrencyId])
				SELECT 
				[intTaxCodeRateId], [dblTotalGalsFrom], [dblTotalGalsTo], [dblGasolineGalsFrom], [dblGasolineGalsTo],
				[dblFeeAmount], [dblIncrementalGals], [dblIncrementalAmount], [intConcurrencyId]
				FROM tblSMTaxCodeRateLoadingFee
				WHERE intTaxCodeRateId = @intTaxCodeRateId
			END
	
		FETCH NEXT FROM temp_cursor INTO @intTaxCodeRateId
		END   

		CLOSE temp_cursor   
		DEALLOCATE temp_cursor

	END

END