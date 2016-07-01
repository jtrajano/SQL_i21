GO
PRINT 'START TF tblTFTaxCategory'
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFTaxCategory')
BEGIN

DECLARE @intTaxAuthorityId INT

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
IF (@intTaxAuthorityId IS NOT NULL)

BEGIN
	IF NOT EXISTS(SELECT TOP 1 [intTaxAuthorityId] FROM [tblTFTaxCategory] WHERE [intTaxAuthorityId] = @intTaxAuthorityId)
	BEGIN
		INSERT INTO [tblTFTaxCategory]
		(
			[intTaxAuthorityId],[strState],[strTaxCategory],[intConcurrencyId]
		)
		VALUES
		(@intTaxAuthorityId,'IN','IN Excise Tax', 0)
		,(@intTaxAuthorityId,'IN','IN Inspection Fee', 0)
		,(@intTaxAuthorityId,'IN','IN Gasoline Use Tax (GUT)', 0)
	END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'OH'
IF (@intTaxAuthorityId IS NOT NULL)

BEGIN
	IF NOT EXISTS(SELECT TOP 1 [intTaxAuthorityId] FROM [tblTFTaxCategory] WHERE [intTaxAuthorityId] = @intTaxAuthorityId)
	BEGIN
		INSERT INTO [tblTFTaxCategory]
		(
			[intTaxAuthorityId],[strState],[strTaxCategory],[intConcurrencyId]
		)
		VALUES
		(@intTaxAuthorityId,'OH','OH Excise Tax', 0)

	END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IL'
IF (@intTaxAuthorityId IS NOT NULL)

BEGIN
	IF NOT EXISTS(SELECT TOP 1 [intTaxAuthorityId] FROM [tblTFTaxCategory] WHERE [intTaxAuthorityId] = @intTaxAuthorityId)
	BEGIN
		INSERT INTO [tblTFTaxCategory]
		(
			[intTaxAuthorityId],[strState],[strTaxCategory],[intConcurrencyId]
		)
		VALUES
		(@intTaxAuthorityId,'IL','IL Excise Tax', 0)
		,(@intTaxAuthorityId,'IL','IL UST/EIF', 0)

	END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'MS'
IF (@intTaxAuthorityId IS NOT NULL)

BEGIN
	IF NOT EXISTS(SELECT TOP 1 [intTaxAuthorityId] FROM [tblTFTaxCategory] WHERE [intTaxAuthorityId] = @intTaxAuthorityId)
	BEGIN
		INSERT INTO [tblTFTaxCategory]
		(
			[intTaxAuthorityId],[strState],[strTaxCategory],[intConcurrencyId]
		)
		VALUES
		(@intTaxAuthorityId,'MS','MS Excise Tax', 0)

	END
END

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'US'
IF (@intTaxAuthorityId IS NOT NULL)

BEGIN
	IF NOT EXISTS(SELECT TOP 1 [intTaxAuthorityId] FROM [tblTFTaxCategory] WHERE [intTaxAuthorityId] = @intTaxAuthorityId)
	BEGIN
		INSERT INTO [tblTFTaxCategory]
		(
			[intTaxAuthorityId],[strState],[strTaxCategory],[intConcurrencyId]
		)
		VALUES
		(@intTaxAuthorityId,'Federal','Federal Excise Tax', 0)

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
