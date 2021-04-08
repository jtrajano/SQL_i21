CREATE FUNCTION [dbo].[fnTRGetFreightSurcharge]
(
	 @strFreightType			NVARCHAR(50)
	,@intCategoryid				INT
	,@intTariffType				INT
	,@dblRate					DECIMAL(18,6)
	,@intMiles					INT
)
RETURNS @result TABLE (
	dblReceiptFreightRate DECIMAL(18,6), 
	dblInvoiceFreightRate DECIMAL(18,6),
	dblSurchargePercentage DECIMAL(18,6), 
	dtmEffectiveDateTime DATETIME,
	intShipViaId INT,
	dtmSurchargeEffectiveDateTime DATETIME
)
AS
BEGIN
	IF(@strFreightType IS NULL)
		RETURN 

	IF @strFreightType = 'Rate'
	BEGIN
		INSERT INTO @result (
			dblReceiptFreightRate, 
			dblInvoiceFreightRate,
			dblSurchargePercentage,
			dtmEffectiveDateTime,
			intShipViaId,
			dtmSurchargeEffectiveDateTime
		)
		 SELECT @dblRate, @dblRate, FS.dblFuelSurcharge, TA.dtmEffectiveDate, TA.intEntityId, FS.dtmEffectiveDate
		 FROM [tblEMEntityTariff] TA INNER JOIN [tblEMEntityTariffCategory] TC on TA.intEntityTariffId = TC.intEntityTariffId			
			LEFT JOIN [tblEMEntityTariffFuelSurcharge] FS ON FS.intEntityTariffId = TC.intEntityTariffId   
	  	 WHERE TC.intCategoryId = @intCategoryid
			AND TA.intEntityTariffTypeId = @intTariffType 
	END 
	ELSE IF @strFreightType = 'Miles'
	BEGIN	
		INSERT INTO @result (
			dblReceiptFreightRate, 
			dblInvoiceFreightRate,
			dblSurchargePercentage, 
			dtmEffectiveDateTime,
			intShipViaId,
			dtmSurchargeEffectiveDateTime
		)
		SELECT TM.dblCostRatePerUnit, TM.dblInvoiceRatePerUnit, FS.dblFuelSurcharge, TA.dtmEffectiveDate, TA.intEntityId, FS.dtmEffectiveDate
		FROM [tblEMEntityTariff] TA
			JOIN [tblEMEntityTariffCategory] TC on TA.intEntityTariffId = TC.intEntityTariffId					   
	  		LEFT JOIN [tblEMEntityTariffMileage] TM on TM.intEntityTariffId = TC.intEntityTariffId
			LEFT JOIN [tblEMEntityTariffFuelSurcharge] FS on FS.intEntityTariffId = TC.intEntityTariffId	
	  	 WHERE (@intMiles >= TM.intFromMiles 
			AND @intMiles <= TM.intToMiles)
	  		AND TC.intCategoryId = @intCategoryid
			AND TA.intEntityTariffTypeId = @intTariffType 
	END

	RETURN
END
