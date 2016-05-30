GO
PRINT 'START TF tblTFTaxCategory'
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFTaxCategory')
BEGIN
	TRUNCATE TABLE tblTFTaxCategory

DECLARE @intTaxAuthorityId INT

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
IF (@intTaxAuthorityId IS NOT NULL)

BEGIN
	IF NOT EXISTS(SELECT TOP 1 [intTaxAuthorityId] FROM [tblTFTaxCategory] WHERE [intTaxAuthorityId] = @intTaxAuthorityId)
	BEGIN
		INSERT INTO [tblTFTaxCategory]
		(
			[intTaxAuthorityId],[strState],[strTaxCategory]
		)
		VALUES
		(@intTaxAuthorityId,'IN','IN Excise Tax')
		,(@intTaxAuthorityId,'IN','IN Inspection Fee')
		,(@intTaxAuthorityId,'IN','IN Gasoline Use Tax (GUT)')
	END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'OH'
IF (@intTaxAuthorityId IS NOT NULL)

BEGIN
	IF NOT EXISTS(SELECT TOP 1 [intTaxAuthorityId] FROM [tblTFTaxCategory] WHERE [intTaxAuthorityId] = @intTaxAuthorityId)
	BEGIN
		INSERT INTO [tblTFTaxCategory]
		(
			[intTaxAuthorityId],[strState],[strTaxCategory]
		)
		VALUES
		(@intTaxAuthorityId,'OH','OH Excise Tax')

	END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IL'
IF (@intTaxAuthorityId IS NOT NULL)

BEGIN
	IF NOT EXISTS(SELECT TOP 1 [intTaxAuthorityId] FROM [tblTFTaxCategory] WHERE [intTaxAuthorityId] = @intTaxAuthorityId)
	BEGIN
		INSERT INTO [tblTFTaxCategory]
		(
			[intTaxAuthorityId],[strState],[strTaxCategory]
		)
		VALUES
		(@intTaxAuthorityId,'IL','IL Excise Tax')
		,(@intTaxAuthorityId,'IL','IL UST/EIF')

	END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MS'
IF (@intTaxAuthorityId IS NOT NULL)

BEGIN
	IF NOT EXISTS(SELECT TOP 1 [intTaxAuthorityId] FROM [tblTFTaxCategory] WHERE [intTaxAuthorityId] = @intTaxAuthorityId)
	BEGIN
		INSERT INTO [tblTFTaxCategory]
		(
			[intTaxAuthorityId],[strState],[strTaxCategory]
		)
		VALUES
		(@intTaxAuthorityId,'MS','MS Excise Tax')

	END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'US'
IF (@intTaxAuthorityId IS NOT NULL)

BEGIN
	IF NOT EXISTS(SELECT TOP 1 [intTaxAuthorityId] FROM [tblTFTaxCategory] WHERE [intTaxAuthorityId] = @intTaxAuthorityId)
	BEGIN
		INSERT INTO [tblTFTaxCategory]
		(
			[intTaxAuthorityId],[strState],[strTaxCategory]
		)
		VALUES
		(@intTaxAuthorityId,'Federal','Federal Excise Tax')

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
