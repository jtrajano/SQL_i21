DECLARE @strImportSetupName NVARCHAR(100) = NULL
DECLARE @intImportFileHeaderId_Header INT = NULL
DECLARE @intImportFileHeaderId_Item INT = NULL
DECLARE @intImportFileHeaderId_DefTax INT = NULL
	
SET @strImportSetupName = 'DTN Standard Outbound Invoice CSV Plus (d) Format'

SELECT @intImportFileHeaderId_Header = intImportFileHeaderId FROM tblSMImportFileHeader 
WHERE strLayoutTitle = 'DTN Standard Outbound Invoice CSV Plus Header'

SELECT @intImportFileHeaderId_Item = intImportFileHeaderId FROM tblSMImportFileHeader 
WHERE strLayoutTitle = 'DTN Standard Outbound Invoice CSV Plus Item'

SELECT @intImportFileHeaderId_DefTax = intImportFileHeaderId FROM tblSMImportFileHeader 
WHERE strLayoutTitle = 'DTN Standard Outbound Invoice CSV Deferred Tax'

DECLARE @intDtnImportSetupId INT = 1

IF NOT EXISTS (SELECT TOP 1 1 FROM tblTRDtnImportSetup WHERE strImportSetupName = @strImportSetupName)
BEGIN
	PRINT ('Deploying - DTN Standard Outbound Invoice CSV Plus (d) Format')

	SET IDENTITY_INSERT tblTRDtnImportSetup ON

	INSERT INTO tblTRDtnImportSetup (intDtnImportSetupId, strImportSetupName, intConcurrencyId)
	VALUES (@intDtnImportSetupId, @strImportSetupName, 1)

	SET IDENTITY_INSERT tblTRDtnImportSetup OFF

	IF(@intImportFileHeaderId_Header IS NOT NULL)
	BEGIN
		INSERT INTO tblTRDtnImportSetupDetail (intDtnImportSetupId, strType, intImportFileHeaderId, intConcurrencyId) 
		VALUES (@intDtnImportSetupId, 'Header', @intImportFileHeaderId_Header, 1)
	END

	IF(@intImportFileHeaderId_Item IS NOT NULL)
	BEGIN
		INSERT INTO tblTRDtnImportSetupDetail (intDtnImportSetupId, strType, intImportFileHeaderId, intConcurrencyId) 
		VALUES (@intDtnImportSetupId, 'Item', @intImportFileHeaderId_Item, 1)
	END

	IF(@intImportFileHeaderId_DefTax IS NOT NULL)
	BEGIN
		INSERT INTO tblTRDtnImportSetupDetail (intDtnImportSetupId, strType, intImportFileHeaderId, intConcurrencyId) 
		VALUES (@intDtnImportSetupId, 'DefTax', @intImportFileHeaderId_DefTax, 1)
	END

END
BEGIN

	IF(@intImportFileHeaderId_Header IS NOT NULL)
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblTRDtnImportSetupDetail WHERE intImportFileHeaderId = @intImportFileHeaderId_Header)
		BEGIN
			INSERT INTO tblTRDtnImportSetupDetail (intDtnImportSetupId, strType, intImportFileHeaderId, intConcurrencyId) 
			VALUES (@intDtnImportSetupId, 'Header', @intImportFileHeaderId_Header, 1)
		END
	END

	IF(@intImportFileHeaderId_Item IS NOT NULL)
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblTRDtnImportSetupDetail WHERE intImportFileHeaderId = @intImportFileHeaderId_Item)
		BEGIN
			INSERT INTO tblTRDtnImportSetupDetail (intDtnImportSetupId, strType, intImportFileHeaderId, intConcurrencyId) 
			VALUES (@intDtnImportSetupId, 'Item', @intImportFileHeaderId_Item, 1)
		END
	END

	IF(@intImportFileHeaderId_DefTax IS NOT NULL)
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblTRDtnImportSetupDetail WHERE intImportFileHeaderId = @intImportFileHeaderId_DefTax)
		BEGIN
			INSERT INTO tblTRDtnImportSetupDetail (intDtnImportSetupId, strType, intImportFileHeaderId, intConcurrencyId) 
			VALUES (@intDtnImportSetupId, 'DefTax', @intImportFileHeaderId_DefTax, 1)
		END
	END
END
GO

DECLARE @strImportSetupName NVARCHAR(100) = NULL
DECLARE @intImportFileHeaderId_Header INT = NULL
DECLARE @intImportFileHeaderId_Item INT = NULL
DECLARE @intImportFileHeaderId_DefTax INT = NULL
	
SET @strImportSetupName = 'iRely Enterprise Vendor Invoice Import Format'

SELECT @intImportFileHeaderId_Header = intImportFileHeaderId FROM tblSMImportFileHeader 
WHERE strLayoutTitle = 'iRely Enterprise Vendor Invoice Header'

SELECT @intImportFileHeaderId_Item = intImportFileHeaderId FROM tblSMImportFileHeader 
WHERE strLayoutTitle = 'iRely Enterprise Vendor Invoice Item'

SELECT @intImportFileHeaderId_DefTax = intImportFileHeaderId FROM tblSMImportFileHeader 
WHERE strLayoutTitle = 'iRely Enterprise Vendor Invoice Deferred Tax'

DECLARE @intDtnImportSetupId INT = 2

IF NOT EXISTS (SELECT TOP 1 1 FROM tblTRDtnImportSetup WHERE strImportSetupName = @strImportSetupName)
BEGIN
	PRINT ('Deploying - iRely Enterprise Vendor Invoice Import Format')

	SET IDENTITY_INSERT tblTRDtnImportSetup ON

	INSERT INTO tblTRDtnImportSetup (intDtnImportSetupId, strImportSetupName, intConcurrencyId)
	VALUES (@intDtnImportSetupId, @strImportSetupName, 1)

	SET IDENTITY_INSERT tblTRDtnImportSetup OFF

	IF(@intImportFileHeaderId_Header IS NOT NULL)
	BEGIN
		INSERT INTO tblTRDtnImportSetupDetail (intDtnImportSetupId, strType, intImportFileHeaderId, intConcurrencyId) 
		VALUES (@intDtnImportSetupId, 'Header', @intImportFileHeaderId_Header, 1)
	END

	IF(@intImportFileHeaderId_Item IS NOT NULL)
	BEGIN
		INSERT INTO tblTRDtnImportSetupDetail (intDtnImportSetupId, strType, intImportFileHeaderId, intConcurrencyId) 
		VALUES (@intDtnImportSetupId, 'Item', @intImportFileHeaderId_Item, 1)
	END

	IF(@intImportFileHeaderId_DefTax IS NOT NULL)
	BEGIN
		INSERT INTO tblTRDtnImportSetupDetail (intDtnImportSetupId, strType, intImportFileHeaderId, intConcurrencyId) 
		VALUES (@intDtnImportSetupId, 'DefTax', @intImportFileHeaderId_DefTax, 1)
	END

END
BEGIN

	IF(@intImportFileHeaderId_Header IS NOT NULL)
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblTRDtnImportSetupDetail WHERE intImportFileHeaderId = @intImportFileHeaderId_Header)
		BEGIN
			INSERT INTO tblTRDtnImportSetupDetail (intDtnImportSetupId, strType, intImportFileHeaderId, intConcurrencyId) 
			VALUES (@intDtnImportSetupId, 'Header', @intImportFileHeaderId_Header, 1)
		END
	END

	IF(@intImportFileHeaderId_Item IS NOT NULL)
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblTRDtnImportSetupDetail WHERE intImportFileHeaderId = @intImportFileHeaderId_Item)
		BEGIN
			INSERT INTO tblTRDtnImportSetupDetail (intDtnImportSetupId, strType, intImportFileHeaderId, intConcurrencyId) 
			VALUES (@intDtnImportSetupId, 'Item', @intImportFileHeaderId_Item, 1)
		END
	END

	IF(@intImportFileHeaderId_DefTax IS NOT NULL)
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblTRDtnImportSetupDetail WHERE intImportFileHeaderId = @intImportFileHeaderId_DefTax)
		BEGIN
			INSERT INTO tblTRDtnImportSetupDetail (intDtnImportSetupId, strType, intImportFileHeaderId, intConcurrencyId) 
			VALUES (@intDtnImportSetupId, 'DefTax', @intImportFileHeaderId_DefTax, 1)
		END
	END
END
GO