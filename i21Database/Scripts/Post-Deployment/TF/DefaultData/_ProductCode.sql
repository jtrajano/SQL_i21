GO
PRINT 'START TF tblTFProductCode'
GO

DECLARE @intTaxAuthorityId INT
DECLARE @tblTempSource TABLE (intTaxAuthorityId INT, strProductCode NVARCHAR(5) COLLATE Latin1_General_CI_AS)

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
IF (@intTaxAuthorityId IS NOT NULL)
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'M00')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'M00', N'Methanol (100%)', N'Gasohol Ethanol Blend', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'M11')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'M11', N'Methanol (11%)', N'Gasohol Ethanol Blend', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '125')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'125', N'Aviation Gasoline', N'Gasohol Ethanol Blend', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '090')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,N'090', N'Additive Miscellaneous', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '248')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,N'248', N'Benzene', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '198')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,N'198', N'Butylene', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '249')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'249', N'ETBE', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '052')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'052', N'Ethane', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '196')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'196', N'Ethylene', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '058')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'058', N'Isobutane', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '265')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'265', N'Methane', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '126')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'126', N'Napthas', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '059')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'059', N'Pentanes, including isopentanes', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '075')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'075', N'Propylene', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '223')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'223', N'Raffinates', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '121')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'121', N'TAME', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '199')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'199', N'Toluene', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '091')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'091', N'Waste Oil', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '076')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'076', N'Xylene', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'B00')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'B00', N'Biodiesel - Undyed (100%)', N'Biodiesel - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'B11')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'B11', N'Biodiesel - Undyed (11%)', N'Biodiesel - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'D00')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'D00', N'Biodiesel - Dyed (100%)', N'Biodiesel - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'D11')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'D11', N'Biodiesel - Dyed (11%)', N'Biodiesel - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '226')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'226', N'High Sulfur Diesel - Dyed', N'Diesel Fuel - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '227')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'227', N'Low Sulfur Diesel - Dyed', N'Diesel Fuel - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '231')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'231', N'No. 1 Diesel - Dyed-MFT', N'Diesel Fuel - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '232')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'232', N'No. 1 Diesel - Dyed-SFT', N'Diesel Fuel - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '153')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'153', N'Diesel Fuel #4- Dyed', N'Diesel Fuel - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '161')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'161', N'Low Sulfur Diesel #1 - Undyed', N'Diesel Fuel - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '167')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'167', N'Low Sulfur Diesel #2 - Undyed', N'Diesel Fuel - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '150')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'150', N'No. 1 Fuel Oil - Undyed', N'Diesel Fuel - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '154')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'154', N'Diesel Fuel #4 - Undyed', N'Diesel Fuel - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '282')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'282', N'High Sulfur Diesel #1 - Undyed', N'Diesel Fuel - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '283')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'283', N'High Sulfur Diesel #2 - Undyed', N'Diesel Fuel - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '224')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'224', N'Compressed Natural Gas (CNG)', N'Natural Gas Products', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '225')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'225', N'Liquid Natural Gas (LNG)', N'Natural Gas Products', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '152')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'152', N'Heating Oil', N'Gasoline', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '130')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'130', N'Jet Fuel', N'Gasoline', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '065')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'065', N'Gasoline', N'Gasoline', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '145')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'145', N'Low Sulfur Kerosene - Undyed- MFT', N'Kerosene - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '146')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'146', N'Low Sulfur Kerosene - Undyed- SFT', N'Kerosene - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '147')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'147', N'High Sulfur Kerosene - Undyed- MFT', N'Kerosene - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '148')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'148', N'High Sulfur Kerosene - Undyed- SFT', N'Kerosene - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '073')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'073', N'Low Sulfur Kerosene - Dyed', N'Kerosene - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '074')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'074', N'High Sulfur Kerosene - Dyed', N'Kerosene - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '061')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'061', N'Natural Gasoline', N'', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '285')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'285', N'Soy Oil', N'', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '100')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'100', N'Transmix - MFT', N'', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '101')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'101', N'Transmix - SFT', N'', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '092')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'092', N'Undefined products - MFT', N'', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '093')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'093', N'Undefined products - SFT', N'', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'E00')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'E00', N'Ethanol (100%) Blended', N'Alcohol', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'E11')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'E11', N'Ethanol (11%) Blended', N'Alcohol', NULL)
			END

			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'M00')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'M11')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '125')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '090')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '248')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '198')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '249')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '052')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '196')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '058')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '265')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '126')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '059')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '075')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '223')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '121')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '199')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '091')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '076')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'B00')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'B11')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'D00')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'D11')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '226')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '227')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '231')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '232')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '153')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '161')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '167')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '150')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '154')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '282')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '283')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '224')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '225')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '152')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '130')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '065')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '145')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '146')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '147')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '148')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '073')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '074')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '061')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '285')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '100')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '101')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '092')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '093')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'E00')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'E11')
	END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'OR'
IF (@intTaxAuthorityId IS NOT NULL)
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'M00')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'M00', N'Methanol (100%)', N'Gasohol Ethanol Blend', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'M11')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'M11', N'Methanol (11%)', N'Gasohol Ethanol Blend', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '125')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'125', N'Aviation Gasoline', N'Gasohol Ethanol Blend', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '090')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,N'090', N'Additive Miscellaneous', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '248')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,N'248', N'Benzene', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '198')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,N'198', N'Butylene', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '249')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'249', N'ETBE', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '052')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'052', N'Ethane', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '196')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'196', N'Ethylene', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '058')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'058', N'Isobutane', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '265')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'265', N'Methane', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '126')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'126', N'Napthas', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '059')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'059', N'Pentanes, including isopentanes', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '075')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'075', N'Propylene', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '223')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'223', N'Raffinates', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '121')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'121', N'TAME', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '199')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'199', N'Toluene', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '091')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'091', N'Waste Oil', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '076')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'076', N'Xylene', N'Blending Components', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'B00')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'B00', N'Biodiesel - Undyed (100%)', N'Biodiesel - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'B11')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'B11', N'Biodiesel - Undyed (11%)', N'Biodiesel - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'D00')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'D00', N'Biodiesel - Dyed (100%)', N'Biodiesel - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'D11')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'D11', N'Biodiesel - Dyed (11%)', N'Biodiesel - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '226')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'226', N'High Sulfur Diesel - Dyed', N'Diesel Fuel - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '227')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'227', N'Low Sulfur Diesel - Dyed', N'Diesel Fuel - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '231')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'231', N'No. 1 Diesel - Dyed-MFT', N'Diesel Fuel - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '232')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'232', N'No. 1 Diesel - Dyed-SFT', N'Diesel Fuel - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '153')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'153', N'Diesel Fuel #4- Dyed', N'Diesel Fuel - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '161')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'161', N'Low Sulfur Diesel #1 - Undyed', N'Diesel Fuel - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '167')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'167', N'Low Sulfur Diesel #2 - Undyed', N'Diesel Fuel - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '150')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'150', N'No. 1 Fuel Oil - Undyed', N'Diesel Fuel - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '154')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'154', N'Diesel Fuel #4 - Undyed', N'Diesel Fuel - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '282')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'282', N'High Sulfur Diesel #1 - Undyed', N'Diesel Fuel - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '283')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'283', N'High Sulfur Diesel #2 - Undyed', N'Diesel Fuel - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '224')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'224', N'Compressed Natural Gas (CNG)', N'Natural Gas Products', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '225')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'225', N'Liquid Natural Gas (LNG)', N'Natural Gas Products', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '152')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'152', N'Heating Oil', N'Gasoline', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '130')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'130', N'Jet Fuel', N'Gasoline', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '065')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'065', N'Gasoline', N'Gasoline', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '145')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'145', N'Low Sulfur Kerosene - Undyed- MFT', N'Kerosene - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '146')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'146', N'Low Sulfur Kerosene - Undyed- SFT', N'Kerosene - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '147')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'147', N'High Sulfur Kerosene - Undyed- MFT', N'Kerosene - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '148')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'148', N'High Sulfur Kerosene - Undyed- SFT', N'Kerosene - Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '073')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'073', N'Low Sulfur Kerosene - Dyed', N'Kerosene - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '074')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'074', N'High Sulfur Kerosene - Dyed', N'Kerosene - Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '061')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'061', N'Natural Gasoline', N'', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '285')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'285', N'Soy Oil', N'', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '100')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'100', N'Transmix - MFT', N'', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '101')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'101', N'Transmix - SFT', N'', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '092')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'092', N'Undefined products - MFT', N'', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '093')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'093', N'Undefined products - SFT', N'', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'E00')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'E00', N'Ethanol (100%) Blended', N'Alcohol', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'E11')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId, N'E11', N'Ethanol (11%) Blended', N'Alcohol', NULL)
			END

		INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'M00')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'M11')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '125')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '090')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '248')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '198')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '249')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '052')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '196')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '058')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '265')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '126')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '059')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '075')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '223')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '121')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '199')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '091')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '076')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'B00')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'B11')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'D00')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'D11')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '226')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '227')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '231')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '232')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '153')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '161')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '167')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '150')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '154')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '282')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '283')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '224')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '225')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '152')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '130')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '065')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '145')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '146')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '147')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '148')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '073')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '074')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '061')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '285')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '100')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '101')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '092')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '093')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'E00')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'E11')
	END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IL'
IF (@intTaxAuthorityId IS NOT NULL)
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '065')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'065','Gasoline','Gasoline Products', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '124')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'124','Gasohol','Gasoline Products', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '123')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'123','Alcohol','Gasoline Products', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'E00')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'E00','Ethanol (100%)','Gasoline Products', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'E11')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'E11','Ethanol (11%)','Gasoline Products', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '091')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'091','Cooking oil/fat (waste oil, etc)','Special Fuel Products -- Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '142')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'142','Kerosene - Undyed','Special Fuel Products -- Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '160')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'160','Diesel Fuel - Undyed','Special Fuel Products -- Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '285')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'285','Soy Oil','Special Fuel Products -- Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'B00')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'B00','Biodiesel - Undyed (100%)','Special Fuel Products -- Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'B11')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'B11','Biodiesel - Undyed (11%)','Special Fuel Products -- Undyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '072')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'072','Kerosene - Dyned','Special Fuel Products -- Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '228')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'228','Diesel Fuel - Dyed','Special Fuel Products -- Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'D00')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'D00','Biodiesel - Dyed (100%)','Special Fuel Products -- Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = 'D11')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'D11','Biodiesel - Dyed (11%)','Special Fuel Products -- Dyed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '073')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'073','Dyed 1-K Reporting Only','Aviation and Other Fuel Products', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '125')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'125','Aviation Gasoline (AvGas)','Aviation and Other Fuel Products', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '130')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'130','Jet Fuel','Aviation and Other Fuel Products', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '145')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'145','Undyed 1-K Reporting Only','Aviation and Other Fuel Products', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '054')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'054','Propane (LP)','Alternative Fuels Products - For On Road Use', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '224')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'224','Compressed Natural Gas (CNG)','Alternative Fuels Products - For On Road Use', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '225')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'225','Liquid Natural Gas (LNG)','Alternative Fuels Products - For On Road Use', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '998')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'998','Motor Fuel Product - (gaseous state)','Other - Use When Your Product Is Not Listed', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '999')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'999','Motor Fuel Product - (liquid state)','Other - Use When Your Product Is Not Listed', NULL)
			END

			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '065')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '124')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '123')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'E00')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'E11')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '091')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '142')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '160')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '285')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'B00')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'B11')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '072')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '228')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'D00')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, 'D11')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '073')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '125')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '130')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '145')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '054')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '224')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '225')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '998')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '999')
	END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MS'
IF (@intTaxAuthorityId IS NOT NULL)
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '065')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'065','Automotive Gasoline','Automotive Gasoline', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '124')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'124','Gasohol','Automotive Gasoline', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '123')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'123','Alcohol','Automotive Gasoline', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '090')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'090','Additives','Automotive Gasoline', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '125')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'125','Aviation Gasoline','Aviation Gasoline', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '228')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'228','Dyed Diesel Fuel','Dyed Diesel & Kerosene', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '072')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'072','Dyed Kerosene','Dyed Diesel & Kerosene', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '142')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'142','Undyed Kerosene','Dyed Diesel & Kerosene', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '290')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'290','Dyed Biodiesel Fuel','Dyed Diesel & Kerosene', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '153')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'153','Dye Added Fuel Oil','Fuel Oil & Other Special Fuels', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '154')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'154','Undyed Fuel Oil','Fuel Oil & Other Special Fuels', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '160')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'160','Undyed Diesel Fuel','Clear Diesel', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '284')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'284','Undyed Biodiesel Fuel','Clear Diesel', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '122')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'122','Blend Stock','Clear Diesel', NULL)
			END
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFProductCode WHERE intTaxAuthorityId = @intTaxAuthorityId AND strProductCode = '130')
			BEGIN
				INSERT INTO [tblTFProductCode]([intTaxAuthorityId],[strProductCode],[strDescription],[strProductCodeGroup],[strNote])
				VALUES(@intTaxAuthorityId,'130','Jet Fuel','Jet Fuel', NULL)
		END

			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '065')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '124')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '123')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '090')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '125')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '228')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '072')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '142')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '290')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '153')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '154')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '160')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '284')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '122')
			INSERT @tblTempSource (intTaxAuthorityId, strProductCode) VALUES (@intTaxAuthorityId, '130')
	END

	INSERT INTO tblTFDeploymentNote ([strMessage],[strSourceTable],[intRecordId],[strKeyId],[intTaxAuthorityId],[strReleaseNumber],[dtmDateReleaseInstalled])
	SELECT 'An obsolete record is detected in Customer database', 'tblTFProductCode', intProductCodeId, strProductCode, intTaxAuthorityId, '', GETDATE() 
	FROM tblTFProductCode A WHERE NOT EXISTS (SELECT intTaxAuthorityId, strProductCode FROM @tblTempSource B WHERE A.strProductCode = B.strProductCode AND A.intTaxAuthorityId = B.intTaxAuthorityId)

GO
PRINT 'END TF tblTFProductCode'
GO



