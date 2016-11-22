GO
PRINT 'START TF tblTFTaxCategory'
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFTaxCategory')
	BEGIN
		DECLARE @intTaxAuthorityId INT
		SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
		IF (@intTaxAuthorityId IS NOT NULL)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCategory WHERE strTaxCategory = 'IN Excise Tax Gasoline') 
				BEGIN 
					INSERT INTO tblTFTaxCategory([intTaxAuthorityId],[strState],[strTaxCategory])
					VALUES(@intTaxAuthorityId, 'IN','IN Excise Tax Gasoline')
				END
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCategory WHERE strTaxCategory = 'IN Excise Tax Diesel Clear') 
				BEGIN
					INSERT INTO tblTFTaxCategory([intTaxAuthorityId],[strState],[strTaxCategory])
					VALUES(@intTaxAuthorityId, 'IN','IN Excise Tax Diesel Clear')
				END
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCategory WHERE strTaxCategory = 'IN Inspection Fee') 
				BEGIN 
					INSERT INTO tblTFTaxCategory([intTaxAuthorityId],[strState],[strTaxCategory])
					VALUES(@intTaxAuthorityId, 'IN','IN Inspection Fee')
				END
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCategory WHERE strTaxCategory = 'IN Gasoline Use Tax (GUT)') 
				BEGIN
					INSERT INTO tblTFTaxCategory([intTaxAuthorityId],[strState],[strTaxCategory])
					VALUES(@intTaxAuthorityId, 'IN','IN Gasoline Use Tax (GUT)')
				END
		END

		SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IL'
		IF (@intTaxAuthorityId IS NOT NULL)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCategory WHERE strTaxCategory = 'IL Excise Tax Gasoline') 
				BEGIN
					INSERT INTO tblTFTaxCategory([intTaxAuthorityId],[strState],[strTaxCategory])
					VALUES(@intTaxAuthorityId, 'IL','IL Excise Tax Gasoline')
				END
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCategory WHERE strTaxCategory = 'IL Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCategory([intTaxAuthorityId],[strState],[strTaxCategory])
					VALUES(@intTaxAuthorityId, 'IL','IL Excise Tax Diesel Clear')
				END
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCategory WHERE strTaxCategory = 'IL Inspection Fee') 
				BEGIN
					INSERT INTO tblTFTaxCategory([intTaxAuthorityId],[strState],[strTaxCategory])
					VALUES(@intTaxAuthorityId, 'IL','IL Inspection Fee')
				END
		END

		SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MI'
		IF (@intTaxAuthorityId IS NOT NULL)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCategory WHERE strTaxCategory = 'MI Excise Tax Gasoline') 
				BEGIN
					INSERT INTO tblTFTaxCategory([intTaxAuthorityId],[strState],[strTaxCategory])
					VALUES(@intTaxAuthorityId, 'MI','MI Excise Tax Gasoline')
				END
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCategory WHERE strTaxCategory = 'MI Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCategory([intTaxAuthorityId],[strState],[strTaxCategory])
					VALUES(@intTaxAuthorityId, 'MI','MI Excise Tax Diesel Clear')
				END
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCategory WHERE strTaxCategory = 'MI Inspection Fee') 
				BEGIN
					INSERT INTO tblTFTaxCategory([intTaxAuthorityId],[strState],[strTaxCategory])
					VALUES(@intTaxAuthorityId, 'MI','MI Inspection Fee')
				END
		END

		SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'OH'
		IF (@intTaxAuthorityId IS NOT NULL)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCategory WHERE strTaxCategory = 'OH Excise Tax Gasoline') 
				BEGIN
					INSERT INTO tblTFTaxCategory([intTaxAuthorityId],[strState],[strTaxCategory])
					VALUES(@intTaxAuthorityId, 'OH','OH Excise Tax Gasoline')
				END
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCategory WHERE strTaxCategory = 'OH Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCategory([intTaxAuthorityId],[strState],[strTaxCategory])
					VALUES(@intTaxAuthorityId, 'OH','OH Excise Tax Diesel Clear')
				END
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCategory WHERE strTaxCategory = 'OH Inspection Fee') 
				BEGIN
					INSERT INTO tblTFTaxCategory([intTaxAuthorityId],[strState],[strTaxCategory])
					VALUES(@intTaxAuthorityId, 'OH','OH Inspection Fee')
				END
		END

		SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'KY'
		IF (@intTaxAuthorityId IS NOT NULL)
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCategory WHERE strTaxCategory = 'KY Excise Tax Gasoline') 
				BEGIN
					INSERT INTO tblTFTaxCategory([intTaxAuthorityId],[strState],[strTaxCategory])
					VALUES(@intTaxAuthorityId, 'KY','KY Excise Tax Gasoline')
				END
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCategory WHERE strTaxCategory = 'KY Excise Tax Diesel Clear') 
				BEGIN 
					INSERT INTO tblTFTaxCategory([intTaxAuthorityId],[strState],[strTaxCategory])
					VALUES(@intTaxAuthorityId, 'KY','KY Excise Tax Diesel Clear')
				END
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblTFTaxCategory WHERE strTaxCategory = 'KY Inspection Fee') 
				BEGIN
					INSERT INTO tblTFTaxCategory([intTaxAuthorityId],[strState],[strTaxCategory])
					VALUES(@intTaxAuthorityId, 'KY','KY Inspection Fee')
				END
		END

	END
	ELSE
		BEGIN
			PRINT 'Table Not Exist!'
		END
GO
PRINT 'END TF tblTFTaxCategory'
GO

GO
PRINT 'START TF Tax Category Deployment Note'
GO
DECLARE @tblTempSource TABLE (strTaxCategory NVARCHAR(70) COLLATE Latin1_General_CI_AS)
--IN
INSERT @tblTempSource (strTaxCategory) VALUES ('IN Excise Tax Gasoline')
INSERT @tblTempSource (strTaxCategory) VALUES ('IN Excise Tax Diesel Clear')
INSERT @tblTempSource (strTaxCategory) VALUES ('IN Inspection Fee')
INSERT @tblTempSource (strTaxCategory) VALUES ('IN Gasoline Use Tax (GUT)')
--IL
INSERT @tblTempSource (strTaxCategory) VALUES ('IL Excise Tax Gasoline')
INSERT @tblTempSource (strTaxCategory) VALUES ('IL Excise Tax Diesel Clear')
INSERT @tblTempSource (strTaxCategory) VALUES ('IL Inspection Fee')
--MI
INSERT @tblTempSource (strTaxCategory) VALUES ('MI Excise Tax Gasoline')
INSERT @tblTempSource (strTaxCategory) VALUES ('MI Excise Tax Diesel Clear')
INSERT @tblTempSource (strTaxCategory) VALUES ('MI Inspection Fee')
--OH
INSERT @tblTempSource (strTaxCategory) VALUES ('OH Excise Tax Gasoline')
INSERT @tblTempSource (strTaxCategory) VALUES ('OH Excise Tax Diesel Clear')
INSERT @tblTempSource (strTaxCategory) VALUES ('OH Inspection Fee')
--KY
INSERT @tblTempSource (strTaxCategory) VALUES ('KY Excise Tax Gasoline')
INSERT @tblTempSource (strTaxCategory) VALUES ('KY Excise Tax Diesel Clear')
INSERT @tblTempSource (strTaxCategory) VALUES ('KY Inspection Fee')


INSERT INTO tblTFDeploymentNote ([strMessage],[strSourceTable],[intRecordId],[strKeyId],[intTaxAuthorityId],[strReleaseNumber],[dtmDateReleaseInstalled])
SELECT 'An obsolete record is detected in Customer database', 'tblTFTaxCategory', intTaxCategoryId, strTaxCategory, intTaxAuthorityId, '', GETDATE() 
FROM tblTFTaxCategory A WHERE NOT EXISTS (SELECT strTaxCategory FROM @tblTempSource B WHERE A.strTaxCategory = B.strTaxCategory)
GO
PRINT 'END TF Tax Category Deployment Note'
GO