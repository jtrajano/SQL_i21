IF EXISTS(select top 1 1 from sys.procedures where name = 'uspSMImportTax')
	DROP PROCEDURE uspSMImportTax
GO

EXEC
('
	CREATE PROCEDURE [dbo].[uspSMImportTax]
		@taxCode NVARCHAR(100),
		@description NVARCHAR(150) = '''',
		@taxClass NVARCHAR(100) = '''',
		@taxGroup NVARCHAR(100) = '''',
		@taxAgency NVARCHAR(100) = '''',
		@taxAgencyId INT = NULL,
		@address NVARCHAR(250) = '''',
		@zipcode NVARCHAR(20) = '''',
		@state NVARCHAR(50) = '''',
		@city NVARCHAR(50) = '''',
		@country NVARCHAR(50) = '''',
		@county NVARCHAR(50) = '''',
		@matchTaxAddress BIT = 0,
		@salesTaxAccountId INT = NULL,
		@purchaseTaxAccountId INT = NULL,
		@taxableByOtherTaxes NVARCHAR(50) = '''',
		@checkoffTax BIT = 1,
		@taxCategoryId INT = NULL ,
		@storeTaxNumber NVARCHAR(50) = '''',
		@payToVendorId INT = NULL
	AS

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @entityExist INT

	SELECT @entityExist = COUNT(1) FROM tblEMEntity WHERE strName = @taxAgency

	-- Check if vendor is existing ?? if not continue the loop
	IF @entityExist > 0 OR @taxAgency = ''''
	BEGIN
		DECLARE @taxGroupId INT
		DECLARE @taxClassId INT
		DECLARE @taxCodeId INT

		-- Insert Tax Group if not existing -> Save
		IF EXISTS (SELECT TOP 1 1 FROM tblSMTaxGroup WHERE strTaxGroup = @taxGroup)
		BEGIN
			SELECT @taxGroupId = intTaxGroupId FROM tblSMTaxGroup WHERE strTaxGroup = @taxGroup
		END

		IF @taxGroupId IS NULL
		BEGIN
			INSERT INTO tblSMTaxGroup(strTaxGroup, strDescription) VALUES(@taxGroup, @taxGroup)
			SELECT @taxGroupId = SCOPE_IDENTITY();
		END

		-- Insert Tax Class if not existing -> Save
		IF EXISTS (SELECT TOP 1 1 FROM tblSMTaxClass WHERE strTaxClass = @taxClass)
		BEGIN
			SELECT @taxClassId = intTaxClassId FROM tblSMTaxClass WHERE strTaxClass = @taxClass
		END

		IF @taxClassId IS NULL
		BEGIN
			INSERT INTO tblSMTaxClass(strTaxClass) VALUES(@taxClass)
			SELECT @taxClassId = SCOPE_IDENTITY();
		END

		-- Insert Tax Code - Save
		IF EXISTS (SELECT TOP 1 1 FROM tblSMTaxCode WHERE strTaxCode = @taxCode)
		BEGIN
			SELECT @taxCodeId = intTaxCodeId FROM tblSMTaxCode WHERE strTaxCode = @taxCode
		END

		IF @taxCodeId IS NULL
		BEGIN
			INSERT INTO tblSMTaxCode(strTaxCode, intTaxClassId, strDescription, strTaxAgency, strAddress, strZipCode, strState, strCity, strCountry, strCounty, ysnCheckoffTax, strStoreTaxNumber) 
			VALUES(@taxCode, @taxClassId, @description, @taxAgency, @address, @zipcode, @state, @city, @country, @county, @checkoffTax, @storeTaxNumber)

			SELECT @taxCodeId = SCOPE_IDENTITY();
		END

		-- Insert tax code to tax group code -> Save
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMTaxGroupCode WHERE intTaxGroupId = @taxGroupId AND intTaxCodeId = @taxCodeId)
		BEGIN
			INSERT INTO tblSMTaxGroupCode(intTaxGroupId, intTaxCodeId) VALUES(@taxGroupId, @taxCodeId)
		END
	END
')