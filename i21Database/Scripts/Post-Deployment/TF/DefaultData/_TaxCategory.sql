﻿GO
PRINT 'START TF tblTFTaxCategory'
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFTaxCategory')
BEGIN
	DECLARE @intTaxAuthorityId INT

	SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
	IF (@intTaxAuthorityId IS NOT NULL)
	BEGIN

	UPDATE tblSMTaxCode SET intTaxCategoryId = NULL

	-- DROP CONSTRAINTS TO TRUNCATE tblTFReportingComponent
	ALTER TABLE tblSMTaxCode
	DROP CONSTRAINT FK_tblSMTaxCode_tblTFTaxCategory

	TRUNCATE TABLE tblTFTaxCategory
	TRUNCATE TABLE tblTFTaxCriteria

	--ADD FOREIGN KEY BACK
	ALTER TABLE tblSMTaxCode ADD CONSTRAINT
	FK_tblSMTaxCode_tblTFTaxCategory FOREIGN KEY
	( intTaxCategoryId )
	REFERENCES tblTFTaxCategory
	( intTaxCategoryId )

		IF NOT EXISTS(SELECT TOP 1 [intTaxAuthorityId] FROM [tblTFTaxCategory] WHERE [intTaxAuthorityId] = @intTaxAuthorityId)
		BEGIN
			INSERT INTO [tblTFTaxCategory]
			(
				[intTaxAuthorityId],[strState],[strTaxCategory],[intConcurrencyId]
			)
			VALUES
			 (@intTaxAuthorityId,'IN','IN Excise Tax Gasoline', 0)
			,(@intTaxAuthorityId,'IN','IN Excise Tax Diesel Clear', 0)
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
