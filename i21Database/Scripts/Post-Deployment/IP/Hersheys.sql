﻿Go
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPIDOCTag
		WHERE strMessageType = 'PROFIT AND LOSS'
		)
BEGIN
	INSERT INTO tblIPSAPIDOCTag
	SELECT 'PROFIT AND LOSS'
		,'EDI_DC40'
		,'TABNAM'
		,'EDI_DC40'
END
Go
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPIDOCTag
		WHERE strMessageType = 'PO CREATE'
		)
BEGIN
	INSERT INTO tblIPSAPIDOCTag
	SELECT 'PO CREATE'
		,'EDI_DC40'
		,'TABNAM'
		,'EDI_DC40'
END
Go
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPIDOCTag
		WHERE strMessageType = 'PO UPDATE'
		)
BEGIN
	INSERT INTO tblIPSAPIDOCTag
	SELECT 'PO UPDATE'
		,'EDI_DC40'
		,'TABNAM'
		,'EDI_DC40'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPIDOCTag
		WHERE strMessageType = 'GLOBAL'
			AND strTag = 'FEED_READ_DURATION'
		)
BEGIN
	INSERT INTO tblIPSAPIDOCTag
	SELECT 'GLOBAL'
		,''
		,'FEED_READ_DURATION'
		,'15'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPIDOCTag
		WHERE strMessageType = 'GLOBAL'
			AND strTag = 'MESCOD'
		)
BEGIN
	INSERT INTO tblIPSAPIDOCTag
	SELECT 'GLOBAL'
		,''
		,'MESCOD'
		,'I21'
END
GO

UPDATE tblIPCompanyPreference
SET strCommonDataFolderPath = 'E:\i21Integration\'
WHERE IsNULL(strCommonDataFolderPath, '') = ''
GO

UPDATE tblIPCompanyPreference
SET strCustomerCode = 'HE'
WHERE IsNULL(strCustomerCode, '') = ''
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPUOM
		WHERE strSAPUOM = 'KG'
		)
	INSERT INTO tblIPSAPUOM
	SELECT 'KG'
		,'KG'
GO

IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPUOM
		WHERE strSAPUOM = 'LB'
		)
	INSERT INTO tblIPSAPUOM
	SELECT 'LB'
		,'LB'
GO

IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPUOM
		WHERE strSAPUOM = 'TO'
		)
	INSERT INTO tblIPSAPUOM
	SELECT 'TO'
		,'MT'
Go
Go
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPLocation
		WHERE stri21Location = '100-US'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		)
	SELECT '100'
		,'100-US'
GO
Go
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPLocation
		WHERE stri21Location = '100-Coman'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		)
	SELECT '100'
		,'100-Coman'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPLocation
		WHERE stri21Location = '100-MX'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		)
	SELECT '100'
		,'100-MX'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPLocation
		WHERE stri21Location = '100-CA'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		)
	SELECT '100'
		,'100-CA'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPLocation
		WHERE stri21Location = '100-BZ'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		)
	SELECT '100'
		,'100-BZ'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPLocation
		WHERE stri21Location = '100-MAL'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		)
	SELECT '100'
		,'100-MAL'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPLocation
		WHERE stri21Location = '100-CN'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		)
	SELECT '100'
		,'100-CN'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPLocation
		WHERE stri21Location = '130-US'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		)
	SELECT '130'
		,'130-US'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPLocation
		WHERE stri21Location = '130-Coman'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		)
	SELECT '130'
		,'130-Coman'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPLocation
		WHERE stri21Location = '130-MX'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		)
	SELECT '130'
		,'130-MX'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPLocation
		WHERE stri21Location = '130-CA'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		)
	SELECT '130'
		,'130-CA'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPLocation
		WHERE stri21Location = '130-BZ'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		)
	SELECT '130'
		,'130-BZ'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPLocation
		WHERE stri21Location = '130-MAL'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		)
	SELECT '130'
		,'130-MAL'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPLocation
		WHERE stri21Location = '130-CN'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		)
	SELECT '130'
		,'130-CN'
GO
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPProductType
		WHERE stri21ProductType = 'Cocoa Beans'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '700'
		,'Cocoa Beans'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPProductType
		WHERE stri21ProductType = 'Cocoa Butter'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '704'
		,'Cocoa Butter'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPProductType
		WHERE stri21ProductType = 'Cocoa Liquor'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '702'
		,'Cocoa Liquor'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPProductType
		WHERE stri21ProductType = 'Cocoa Powder'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '701'
		,'Cocoa Powder'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPProductType
		WHERE stri21ProductType = 'Palm'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '744'
		,'Palm'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPProductType
		WHERE stri21ProductType = 'Coconut'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '736'
		,'Coconut'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPProductType
		WHERE stri21ProductType = 'CBE'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '744'
		,'CBE'
GO
UPDATE tblSMCountry
SET strISOCode = 'CA'
WHERE strCountry = 'Canada'

UPDATE tblSMCountry
SET strISOCode = 'CH'
WHERE strCountry = 'Switzerland'

--Update tblSMCountry Set strISOCode ='CI'Where strCountry=''
UPDATE tblSMCountry
SET strISOCode = 'DE'
WHERE strCountry = 'Germany'

UPDATE tblSMCountry
SET strISOCode = 'FR'
WHERE strCountry = 'France'

--Update tblSMCountry Set strISOCode ='GH'Where strCountry=''
UPDATE tblSMCountry
SET strISOCode = 'MX'
WHERE strCountry = 'Mexico'

UPDATE tblSMCountry
SET strISOCode = 'MY'
WHERE strCountry = 'Malaysia'

UPDATE tblSMCountry
SET strISOCode = 'PH'
WHERE strCountry = 'Philippines'

UPDATE tblSMCountry
SET strISOCode = 'SG'
WHERE strCountry = 'Singapore'

UPDATE tblSMCountry
SET strISOCode = 'US'
WHERE strCountry = 'United States'
Go
UPDATE tblIPSAPLocation
SET ysnEnabledERPFeed = 0
WHERE stri21Location NOT IN (
		'130-US'
		,'130-Coman'
		)
Go
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPUOM
		WHERE strSAPUOM = 'BG'
		)
	INSERT INTO tblIPSAPUOM
	SELECT 'BG'
		,'BAG'
Go
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPProductType
		WHERE strSAPProductType = '703'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '703'
		,'CBE'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPProductType
		WHERE strSAPProductType = '490'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '490'
		,'Cocoa Butter'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPProductType
		WHERE strSAPProductType = '430'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '430'
		,'Cocoa Butter'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPSAPProductType
		WHERE strSAPProductType = '507'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '507'
		,'Cocoa Powder'
GO
UPDATE tblIPSAPProductType SET stri21ProductType = 'Cocoa Butter' where stri21ProductType = 'Cococa Butter'
GO
