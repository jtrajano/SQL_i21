GO
PRINT 'START TF tblTFTaxCriteria'
GO
DECLARE @intTaxAuthorityId INT
		SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
		IF (@intTaxAuthorityId IS NOT NULL)
			BEGIN
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 1 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 1, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 2 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 2, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 3 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 3, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 4 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 4, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 5 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 5, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 6 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 6, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 7 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 7, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 8 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 8, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 9 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 9, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 13 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 13, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 14 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 14, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 15 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 15, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 19 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 19, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 20 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 20, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 21 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 21, 'IN', 'IN Excise Tax Gasoline', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 22 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 22, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 23 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 23, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 24 AND strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(1, 24, 'IN', 'IN Excise Tax Gasoline', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 54 AND strTaxCategory = 'IL Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(6, 54, 'IL', 'IL Excise Tax Diesel Clear', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 83 AND strTaxCategory = 'KY Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(16, 83, 'KY', 'KY Excise Tax Diesel Clear', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 84 AND strTaxCategory = 'MI Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(10, 84, 'MI', 'MI Excise Tax Diesel Clear', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 85 AND strTaxCategory = 'KY Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(16, 85, 'KY', 'KY Excise Tax Diesel Clear', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 46 AND strTaxCategory = 'IN Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(2, 46, 'IN', 'IN Excise Tax Diesel Clear', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 49 AND strTaxCategory = 'IN Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(2, 49, 'IN', 'IN Excise Tax Diesel Clear', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 50 AND strTaxCategory = 'IN Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(2, 50, 'IN', 'IN Excise Tax Diesel Clear', '<> 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 50 AND strTaxCategory = 'IN Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(2, 51, 'IN', 'IN Excise Tax Diesel Clear', '= 0')
				END

				IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCriteria WHERE intReportingComponentId = 56 AND strTaxCategory = 'IN Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCriteria([intTaxCategoryId],[intReportingComponentId],[strState],[strTaxCategory],[strCriteria])
					VALUES(2, 56, 'IN', 'IN Excise Tax Diesel Clear', '= 0')
				END
			END

GO
PRINT 'END TF tblTFTaxCriteria'
GO

GO
PRINT 'START TF Tax Criteria Deployment Note'
GO
DECLARE @tblTempSource TABLE (intReportingComponentId INT, strTaxCategory NVARCHAR(50)  COLLATE Latin1_General_CI_AS)
--IN
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (1, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (2, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (3, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (4, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (5, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (6, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (7, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (8, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (9, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (10, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (11, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (12, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (13, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (14, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (15, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (16, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (17, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (18, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (19, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (20, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (21, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (22, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (23, 'IN Excise Tax Gasoline')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (24, 'IN Excise Tax Gasoline')
--IL
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (54, 'IL Excise Tax Diesel Clear')
--KY
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (83, 'KY Excise Tax Diesel Clear')
--MI
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (84, 'MI Excise Tax Diesel Clear')
--KY
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (85, 'KY Excise Tax Diesel Clear')
--IN
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (46, 'IN Excise Tax Diesel Clear')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (49, 'IN Excise Tax Diesel Clear')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (50, 'IN Excise Tax Diesel Clear')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (51, 'IN Excise Tax Diesel Clear')
INSERT @tblTempSource (intReportingComponentId, strTaxCategory) VALUES (56, 'IN Excise Tax Diesel Clear')

INSERT INTO tblTFDeploymentNote ([strMessage],[strSourceTable],[intRecordId],[strKeyId],[intTaxAuthorityId],[strReleaseNumber],[dtmDateReleaseInstalled])
SELECT 'An obsolete record is detected in Customer database', 'tblTFTaxCriteria', intTaxCriteriaId, 'RC, ' + CONVERT(NVARCHAR(10), intReportingComponentId) + ', ' + strTaxCategory + ' ' + strCriteria, NULL, '', GETDATE() 
FROM tblTFTaxCriteria A WHERE NOT EXISTS (SELECT strTaxCategory FROM @tblTempSource B WHERE A.intReportingComponentId = B.intReportingComponentId AND A.strTaxCategory = B.strTaxCategory)
GO
PRINT 'END TF Tax Criteria Deployment Note'
GO