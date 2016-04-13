﻿GO
PRINT 'START TF tblTFProductCode'
GO
DECLARE @intTaxAuthorityId INT

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
IF (@intTaxAuthorityId IS NOT NULL)
DELETE FROM tblTFProductCode
BEGIN
	IF NOT EXISTS(SELECT TOP 1 [intTaxAuthorityId] FROM [tblTFProductCode] WHERE [intTaxAuthorityId] = @intTaxAuthorityId)
	BEGIN
		INSERT INTO [tblTFProductCode]
		(
			[intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote]
		)
		VALUES
		 (@intTaxAuthorityId, N'M00', N'Methanol (100%)', N'Gasohol Ethanol Blend', NULL)
		,(@intTaxAuthorityId, N'M11', N'Methanol (11%)', N'Gasohol Ethanol Blend', NULL)
		,(@intTaxAuthorityId, N'125', N'Aviation Gasoline', N'Gasohol Ethanol Blend', NULL)
		,(@intTaxAuthorityId,N'090', N'Additive Miscellaneous', N'Blending Components', NULL)
		,(@intTaxAuthorityId,N'248', N'Benzene', N'Blending Components', NULL)
		,(@intTaxAuthorityId,N'198', N'Butylene', N'Blending Components', NULL)
		,(@intTaxAuthorityId, N'249', N'ETBE', N'Blending Components', NULL)
		,(@intTaxAuthorityId, N'052', N'Ethane', N'Blending Components', NULL)
		,(@intTaxAuthorityId, N'196', N'Ethylene', N'Blending Components', NULL)
		,(@intTaxAuthorityId, N'058', N'Isobutane', N'Blending Components', NULL)
		,(@intTaxAuthorityId, N'265', N'Methane', N'Blending Components', NULL)
		,(@intTaxAuthorityId, N'126', N'Napthas', N'Blending Components', NULL)
		,(@intTaxAuthorityId, N'059', N'Pentanes, including isopentanes', N'Blending Components', NULL)
		,(@intTaxAuthorityId, N'075', N'Propylene', N'Blending Components', NULL)
		,(@intTaxAuthorityId, N'223', N'Raffinates', N'Blending Components', NULL)
		,(@intTaxAuthorityId, N'121', N'TAME', N'Blending Components', NULL)
		,(@intTaxAuthorityId, N'199', N'Toluene', N'Blending Components', NULL)
		,(@intTaxAuthorityId, N'091', N'Waste Oil', N'Blending Components', NULL)
		,(@intTaxAuthorityId, N'076', N'Xylene', N'Blending Components', NULL)
		,(@intTaxAuthorityId, N'B00', N'Biodiesel - Undyed (100%)', N'Biodiesel - Undyed', NULL)
		,(@intTaxAuthorityId, N'B11', N'Biodiesel - Undyed (11%)', N'Biodiesel - Undyed', NULL)
		,(@intTaxAuthorityId, N'D00', N'Biodiesel - Dyed (100%)', N'Biodiesel - Dyed', NULL)
		,(@intTaxAuthorityId, N'D11', N'Biodiesel - Dyed (11%)', N'Biodiesel - Dyed', NULL)
		,(@intTaxAuthorityId, N'226', N'High Sulfur Diesel - Dyed', N'Diesel Fuel - Dyed', NULL)
		,(@intTaxAuthorityId, N'227', N'Low Sulfur Diesel - Dyed', N'Diesel Fuel - Dyed', NULL)
		,(@intTaxAuthorityId, N'231', N'No. 1 Diesel - Dyed-MFT', N'Diesel Fuel - Dyed', NULL)
		,(@intTaxAuthorityId, N'232', N'No. 1 Diesel - Dyed-SFT', N'Diesel Fuel - Dyed', NULL)
		,(@intTaxAuthorityId, N'153', N'Diesel Fuel #4- Dyed', N'Diesel Fuel - Dyed', NULL)
		,(@intTaxAuthorityId, N'161', N'Low Sulfur Diesel #1 - Undyed', N'Diesel Fuel - Undyed', NULL)
		,(@intTaxAuthorityId, N'167', N'Low Sulfur Diesel #2 - Undyed', N'Diesel Fuel - Undyed', NULL)
		,(@intTaxAuthorityId, N'150', N'No. 1 Fuel Oil - Undyed', N'Diesel Fuel - Undyed', NULL)
		,(@intTaxAuthorityId, N'154', N'Diesel Fuel #4 - Undyed', N'Diesel Fuel - Undyed', NULL)
		,(@intTaxAuthorityId, N'282', N'High Sulfur Diesel #1 - Undyed', N'Diesel Fuel - Undyed', NULL)
		,(@intTaxAuthorityId, N'283', N'High Sulfur Diesel #2 - Undyed', N'Diesel Fuel - Undyed', NULL)
		,(@intTaxAuthorityId, N'224', N'Compressed Natural Gas (CNG)', N'Natural Gas Products', NULL)
		,(@intTaxAuthorityId, N'225', N'Liquid Natural Gas (LNG)', N'Natural Gas Products', NULL)
		,(@intTaxAuthorityId, N'152', N'Heating Oil', N'Gasoline', NULL)
		,(@intTaxAuthorityId, N'130', N'Jet Fuel', N'Gasoline', NULL)
		,(@intTaxAuthorityId, N'065', N'Gasoline', N'Gasoline', NULL)
		,(@intTaxAuthorityId, N'145', N'Low Sulfur Kerosene - Undyed- MFT', N'Kerosene - Undyed', NULL)
		,(@intTaxAuthorityId, N'146', N'Low Sulfur Kerosene - Undyed- SFT', N'Kerosene - Undyed', NULL)
		,(@intTaxAuthorityId, N'147', N'High Sulfur Kerosene - Undyed- MFT', N'Kerosene - Undyed', NULL)
		,(@intTaxAuthorityId, N'148', N'High Sulfur Kerosene - Undyed- SFT', N'Kerosene - Undyed', NULL)
		,(@intTaxAuthorityId, N'073', N'Low Sulfur Kerosene - Dyed', N'Kerosene - Dyed', NULL)
		,(@intTaxAuthorityId, N'074', N'High Sulfur Kerosene - Dyed', N'Kerosene - Dyed', NULL)
		,(@intTaxAuthorityId, N'061', N'Natural Gasoline', N'', NULL)
		,(@intTaxAuthorityId, N'285', N'Soy Oil', N'', NULL)
		,(@intTaxAuthorityId, N'100', N'Transmix - MFT', N'', NULL)
		,(@intTaxAuthorityId, N'101', N'Transmix - SFT', N'', NULL)
		,(@intTaxAuthorityId, N'092', N'Undefined products - MFT', N'', NULL)
		,(@intTaxAuthorityId, N'093', N'Undefined products - SFT', N'', NULL)
		,(@intTaxAuthorityId, N'E00', N'Ethanol (100%) Blended', N'Alcohol', NULL)
		,(@intTaxAuthorityId, N'E11', N'Ethanol (11%) Blended', N'Alcohol', NULL)
	END
END

GO
PRINT 'END TF tblTFProductCode'
GO