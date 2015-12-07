GO
PRINT 'START TF tblTFProductCode'
GO
DECLARE @intTaxAuthorityId INT

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 [intTaxAuthorityId] FROM [tblTFProductCode] WHERE [intTaxAuthorityId] = @intTaxAuthorityId)
	BEGIN
		INSERT INTO [tblTFProductCode]
		(
			[intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup]
		)
		VALUES
		 (@intTaxAuthorityId,'065','Gasoline','Gasoline Products')
		,(@intTaxAuthorityId,'123','Alcohol','Gasoline Products')
		,(@intTaxAuthorityId,'124','Gasohol','Gasoline Products')
		,(@intTaxAuthorityId,'E00','Ethanol (100%)','Gasoline Products')
		,(@intTaxAuthorityId,'E11','Ethanol (11%)','Gasoline Products')
		,(@intTaxAuthorityId,'091','Cooking oil/fat (waste oil, etc)','Special Fuel Products -- Undyed')
		,(@intTaxAuthorityId,'142','Kerosene - Undyed','Special Fuel Products -- Undyed')
		,(@intTaxAuthorityId,'160','Diesel Fuel - Undyed','Special Fuel Products -- Undyed')
		,(@intTaxAuthorityId,'285','Soy Oil','Special Fuel Products -- Undyed')
		,(@intTaxAuthorityId,'B00','Biodiesel - Undyed (100%)','Special Fuel Products -- Undyed')
		,(@intTaxAuthorityId,'B11','Biodiesel - Undyed (11%)','Special Fuel Products -- Undyed')
		,(@intTaxAuthorityId,'072','Kerosene - Dyned','Special Fuel Products -- Dyed')
		,(@intTaxAuthorityId,'228','Diesel Fuel - Dyed','Special Fuel Products -- Dyed')
		,(@intTaxAuthorityId,'D00','Biodiesel - Dyed (100%)','Special Fuel Products -- Dyed')
		,(@intTaxAuthorityId,'D11','Biodiesel - Dyed (11%)','Special Fuel Products -- Dyed')
		,(@intTaxAuthorityId,'073','Dyed 1-K Reporting Only','Aviation and Other Fuel Products')
		,(@intTaxAuthorityId,'125','Aviation Gasoline (AvGas)','Aviation and Other Fuel Products')
		,(@intTaxAuthorityId,'130','Jet Fuel','Aviation and Other Fuel Products')
		,(@intTaxAuthorityId,'145','Undyed 1-K Reporting Only','Aviation and Other Fuel Products')
		,(@intTaxAuthorityId,'054','Propane (LP)','Alternative Fuels Products - For On Road Use')
		,(@intTaxAuthorityId,'123','Alcohol','Alternative Fuels Products - For On Road Use')
		,(@intTaxAuthorityId,'224','Compressed Natural Gas (CNG)','Alternative Fuels Products - For On Road Use')
		,(@intTaxAuthorityId,'225','Liquid Natural Gas (LNG)','Alternative Fuels Products - For On Road Use')
		,(@intTaxAuthorityId,'998','Motor Fuel Product - (gaseous state)','Other - Use When Your Product Is Not Listed')
		,(@intTaxAuthorityId,'999','Motor Fuel Product - (liquid state)','Other - Use When Your Product Is Not Listed')
	END
END

GO
PRINT 'END TF tblTFProductCode'
GO