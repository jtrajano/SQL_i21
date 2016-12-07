GO
PRINT 'START TF tblTFTaxCriteria'
GO
DECLARE @intTaxAuthorityId INT
		SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
		IF (@intTaxAuthorityId IS NOT NULL)
			BEGIN
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '1' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '1', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '2' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '2', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '3' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '3', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '4' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '4', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '5' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '5', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '6' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '6', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '7' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '7', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '8' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '8', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '9' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '9', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '13' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '13', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '14' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '14', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '15' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '15', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '19' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '19', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '20' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '20', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '21' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '21', 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '22' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '22', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '23' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '23', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '24' AND strTaxCategory = 'IN Excise Tax Gasoline')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('1', '24', 'IN', 'IN Excise Tax Gasoline', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '83' AND strTaxCategory = 'KY Excise Tax Diesel Clear')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('16', '83', 'KY', 'KY Excise Tax Diesel Clear', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '84' AND strTaxCategory = 'MI Excise Tax Diesel Clear')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('10', '84', 'MI', 'MI Excise Tax Diesel Clear', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '85' AND strTaxCategory = 'KY Excise Tax Diesel Clear')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('16', '85', 'KY', 'KY Excise Tax Diesel Clear', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '46' AND strTaxCategory = 'IN Excise Tax Diesel Clear')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('2', '46', 'IN', 'IN Excise Tax Diesel Clear', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '49' AND strTaxCategory = 'IN Excise Tax Diesel Clear')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('2', '49', 'IN', 'IN Excise Tax Diesel Clear', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '50' AND strTaxCategory = 'IN Excise Tax Diesel Clear')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('2', '50', 'IN', 'IN Excise Tax Diesel Clear', '<> 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '51' AND strTaxCategory = 'IN Excise Tax Diesel Clear')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('2', '51', 'IN', 'IN Excise Tax Diesel Clear', '= 0')
				END
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = '56' AND strTaxCategory = 'IN Excise Tax Diesel Clear')BEGIN
				INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
				VALUES('2', '56', 'IN', 'IN Excise Tax Diesel Clear', '= 0')
				END
			END

GO
PRINT 'END TF tblTFTaxCriteria'
GO
