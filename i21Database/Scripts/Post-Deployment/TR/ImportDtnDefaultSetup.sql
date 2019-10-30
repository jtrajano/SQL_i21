DECLARE @strImportSetupName NVARCHAR(100) = NULL

	
SET @strImportSetupName = 'DTN Standard Outbound Invoice CSV Plus (d) Format'

IF NOT EXISTS (SELECT TOP 1 1 FROM tblTRDtnImportSetup WHERE strImportSetupName = @strImportSetupName)
BEGIN
	PRINT ('Deploying - DTN Standard Outbound Invoice CSV Plus (d) Format')

	DECLARE @intImportFileHeaderId_Header INT = NULL
	DECLARE @intImportFileHeaderId_Item INT = NULL

	SELECT @intImportFileHeaderId_Header = intImportFileHeaderId FROM tblSMImportFileHeader 
	WHERE strLayoutTitle = 'DTN Standard Outbound Invoice CSV Plus Header'

	SELECT @intImportFileHeaderId_Item = intImportFileHeaderId FROM tblSMImportFileHeader 
	WHERE strLayoutTitle = 'DTN Standard Outbound Invoice CSV Plus Item'

	IF(@intImportFileHeaderId_Header IS NOT NULL AND @intImportFileHeaderId_Item IS NOT NULL)
	BEGIN
		
		DECLARE @intDtnImportSetupId INT = 1

		SET IDENTITY_INSERT tblTRDtnImportSetup ON

		INSERT INTO tblTRDtnImportSetup (intDtnImportSetupId, strImportSetupName, intConcurrencyId)
		VALUES (@intDtnImportSetupId, @strImportSetupName, 1)

		SET IDENTITY_INSERT tblTRDtnImportSetup OFF

		-- DETAIL
		INSERT INTO tblTRDtnImportSetupDetail (intDtnImportSetupId, strType, intImportFileHeaderId, intConcurrencyId) 
		VALUES (@intDtnImportSetupId, 'Header', @intImportFileHeaderId_Header, 1)

		INSERT INTO tblTRDtnImportSetupDetail (intDtnImportSetupId, strType, intImportFileHeaderId, intConcurrencyId) 
		VALUES (@intDtnImportSetupId, 'Item', @intImportFileHeaderId_Item, 1)

	END

END
GO