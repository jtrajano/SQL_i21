Go
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



------- Hershey's Phase II -------
GO
IF NOT EXISTS (
		SELECT 1
		FROM tblIPSAPProductType
		WHERE strSAPProductType = '706'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '706'
		,'Sugar'
GO
IF NOT EXISTS (
		SELECT 1
		FROM tblIPSAPProductType
		WHERE strSAPProductType = '708'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '708'
		,'Corn Sweeteners'
GO
IF NOT EXISTS (
		SELECT 1
		FROM tblIPSAPProductType
		WHERE strSAPProductType = '712'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '712'
		,'Peanuts'
GO
IF NOT EXISTS (
		SELECT 1
		FROM tblIPSAPProductType
		WHERE strSAPProductType = '710'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '710'
		,'Almonds'
GO
IF NOT EXISTS (
		SELECT 1
		FROM tblIPSAPProductType
		WHERE strSAPProductType = '716'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '716'
		,'Dairy'
GO
IF NOT EXISTS (
		SELECT 1
		FROM tblIPSAPProductType
		WHERE strSAPProductType = '717'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '717'
		,'Dairy Blends'
GO
IF NOT EXISTS (
		SELECT 1
		FROM tblIPSAPProductType
		WHERE strSAPProductType = '420'
		)
	INSERT INTO tblIPSAPProductType (
		strSAPProductType
		,stri21ProductType
		)
	SELECT '420'
		,'Palm'
GO

GO
IF NOT EXISTS (
		SELECT 1
		FROM tblIPSAPLocation
		WHERE stri21Location = 'United States'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		,ysnEnabledERPFeed
		)
	SELECT '100'
		,'United States'
		,0
GO
IF NOT EXISTS (
		SELECT 1
		FROM tblIPSAPLocation
		WHERE stri21Location = 'Canada'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		,ysnEnabledERPFeed
		)
	SELECT '101'
		,'Canada'
		,0
GO
IF NOT EXISTS (
		SELECT 1
		FROM tblIPSAPLocation
		WHERE stri21Location = 'Mexico'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		,ysnEnabledERPFeed
		)
	SELECT '102'
		,'Mexico'
		,0
GO
IF NOT EXISTS (
		SELECT 1
		FROM tblIPSAPLocation
		WHERE stri21Location = 'Malaysia'
		)
	INSERT INTO tblIPSAPLocation (
		strSAPLocation
		,stri21Location
		,ysnEnabledERPFeed
		)
	SELECT '632'
		,'Malaysia'
		,0
GO

GO
DECLARE @intCommodityId INT
SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = 'Cocoa'

IF NOT EXISTS (
	SELECT 1 FROM tblIPSAPAccount WHERE intCommodityId = @intCommodityId AND ysnGLAccount = 0
	) AND (ISNULL(@intCommodityId, 0) > 0)
	INSERT INTO tblIPSAPAccount (strSAPAccountNo,intCommodityId,ysnGLAccount)
	SELECT '115501',@intCommodityId,0

IF NOT EXISTS (
	SELECT 1 FROM tblIPSAPAccount WHERE intCommodityId = @intCommodityId AND ysnGLAccount = 1
	) AND (ISNULL(@intCommodityId, 0) > 0)
	INSERT INTO tblIPSAPAccount (strSAPAccountNo,intCommodityId,ysnGLAccount)
	SELECT '439282',@intCommodityId,1
GO

GO
DECLARE @intCommodityId INT
SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = 'Sugar'

IF NOT EXISTS (
	SELECT 1 FROM tblIPSAPAccount WHERE intCommodityId = @intCommodityId AND ysnGLAccount = 0
	) AND (ISNULL(@intCommodityId, 0) > 0)
	INSERT INTO tblIPSAPAccount (strSAPAccountNo,intCommodityId,ysnGLAccount)
	SELECT '115502',@intCommodityId,0

IF NOT EXISTS (
	SELECT 1 FROM tblIPSAPAccount WHERE intCommodityId = @intCommodityId AND ysnGLAccount = 1
	) AND (ISNULL(@intCommodityId, 0) > 0)
	INSERT INTO tblIPSAPAccount (strSAPAccountNo,intCommodityId,ysnGLAccount)
	SELECT '439280',@intCommodityId,1
GO

GO
DECLARE @intCommodityId INT
SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = 'Corn'

IF NOT EXISTS (
	SELECT 1 FROM tblIPSAPAccount WHERE intCommodityId = @intCommodityId AND ysnGLAccount = 0
	) AND (ISNULL(@intCommodityId, 0) > 0)
	INSERT INTO tblIPSAPAccount (strSAPAccountNo,intCommodityId,ysnGLAccount)
	SELECT '115503',@intCommodityId,0

IF NOT EXISTS (
	SELECT 1 FROM tblIPSAPAccount WHERE intCommodityId = @intCommodityId AND ysnGLAccount = 1
	) AND (ISNULL(@intCommodityId, 0) > 0)
	INSERT INTO tblIPSAPAccount (strSAPAccountNo,intCommodityId,ysnGLAccount)
	SELECT '439287',@intCommodityId,1
GO

GO
DECLARE @intCommodityId INT
SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = 'Dairy'

IF NOT EXISTS (
	SELECT 1 FROM tblIPSAPAccount WHERE intCommodityId = @intCommodityId AND ysnGLAccount = 0
	) AND (ISNULL(@intCommodityId, 0) > 0)
	INSERT INTO tblIPSAPAccount (strSAPAccountNo,intCommodityId,ysnGLAccount)
	SELECT '115504',@intCommodityId,0

IF NOT EXISTS (
	SELECT 1 FROM tblIPSAPAccount WHERE intCommodityId = @intCommodityId AND ysnGLAccount = 1
	) AND (ISNULL(@intCommodityId, 0) > 0)
	INSERT INTO tblIPSAPAccount (strSAPAccountNo,intCommodityId,ysnGLAccount)
	SELECT '439284',@intCommodityId,1
GO

GO
DECLARE @intCommodityId INT
SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = 'Wheat'

IF NOT EXISTS (
	SELECT 1 FROM tblIPSAPAccount WHERE intCommodityId = @intCommodityId AND ysnGLAccount = 0
	) AND (ISNULL(@intCommodityId, 0) > 0)
	INSERT INTO tblIPSAPAccount (strSAPAccountNo,intCommodityId,ysnGLAccount)
	SELECT '115507',@intCommodityId,0

IF NOT EXISTS (
	SELECT 1 FROM tblIPSAPAccount WHERE intCommodityId = @intCommodityId AND ysnGLAccount = 1
	) AND (ISNULL(@intCommodityId, 0) > 0)
	INSERT INTO tblIPSAPAccount (strSAPAccountNo,intCommodityId,ysnGLAccount)
	SELECT '439289',@intCommodityId,1
GO

GO
DECLARE @intCommodityId INT
SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = 'Sugar'

IF NOT EXISTS (SELECT 1 FROM tblIPSAPInternalOrder WHERE intCommodityId = @intCommodityId) AND (ISNULL(@intCommodityId, 0) > 0)
BEGIN
	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7053565',@intCommodityId,0

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7053566',@intCommodityId,1

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7053567',@intCommodityId,2

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7053568',@intCommodityId,3
END
GO

GO
DECLARE @intCommodityId INT
SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = 'Corn'

IF NOT EXISTS (SELECT 1 FROM tblIPSAPInternalOrder WHERE intCommodityId = @intCommodityId) AND (ISNULL(@intCommodityId, 0) > 0)
BEGIN
	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7053581',@intCommodityId,0

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7053582',@intCommodityId,1

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7053583',@intCommodityId,2

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7053584',@intCommodityId,3
END
GO

GO
DECLARE @intCommodityId INT
SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = 'Dairy'

IF NOT EXISTS (SELECT 1 FROM tblIPSAPInternalOrder WHERE intCommodityId = @intCommodityId) AND (ISNULL(@intCommodityId, 0) > 0)
BEGIN
	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7053569',@intCommodityId,0

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7053570',@intCommodityId,1

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7053571',@intCommodityId,2

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7053572',@intCommodityId,3
END
GO

GO
DECLARE @intCommodityId INT
SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = 'Wheat'

IF NOT EXISTS (SELECT 1 FROM tblIPSAPInternalOrder WHERE intCommodityId = @intCommodityId) AND (ISNULL(@intCommodityId, 0) > 0)
BEGIN
	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7079042',@intCommodityId,0

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7079043',@intCommodityId,1

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7079044',@intCommodityId,2

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7079045',@intCommodityId,3
END
GO

-- Internal Order No script for Dev Server. Should not run this in Production Server
/*
GO
DECLARE @intCommodityId INT
SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = 'Sugar'

IF NOT EXISTS (SELECT 1 FROM tblIPSAPInternalOrder WHERE intCommodityId = @intCommodityId) AND (ISNULL(@intCommodityId, 0) > 0)
BEGIN
	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7001356',@intCommodityId,0

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7001357',@intCommodityId,1

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7001358',@intCommodityId,2

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7001359',@intCommodityId,3
END
GO

GO
DECLARE @intCommodityId INT
SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = 'Corn'

IF NOT EXISTS (SELECT 1 FROM tblIPSAPInternalOrder WHERE intCommodityId = @intCommodityId) AND (ISNULL(@intCommodityId, 0) > 0)
BEGIN
	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7001360',@intCommodityId,0

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7001361',@intCommodityId,1

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7001362',@intCommodityId,2

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7001363',@intCommodityId,3
END
GO

GO
DECLARE @intCommodityId INT
SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = 'Dairy'

IF NOT EXISTS (SELECT 1 FROM tblIPSAPInternalOrder WHERE intCommodityId = @intCommodityId) AND (ISNULL(@intCommodityId, 0) > 0)
BEGIN
	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7001364',@intCommodityId,0

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7001365',@intCommodityId,1

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7001366',@intCommodityId,2

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7001367',@intCommodityId,3
END
GO

GO
DECLARE @intCommodityId INT
SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = 'Wheat'

IF NOT EXISTS (SELECT 1 FROM tblIPSAPInternalOrder WHERE intCommodityId = @intCommodityId) AND (ISNULL(@intCommodityId, 0) > 0)
BEGIN
	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7079042',@intCommodityId,0

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7079043',@intCommodityId,1

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7079044',@intCommodityId,2

	INSERT INTO tblIPSAPInternalOrder (strSAPInternalOrderNo,intCommodityId,intYearDiff)
	SELECT '7079045',@intCommodityId,3
END
GO
*/
