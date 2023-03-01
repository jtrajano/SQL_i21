CREATE PROCEDURE [dbo].[uspSTInsertRequiredXMLFileConfigForConsignment]
	@intStoreId		INT
AS
BEGIN

DECLARE		@intRegisterId INT
DECLARE		@strRegisterClass NVARCHAR(30)
DECLARE		@ysnConsignmentStore BIT

SELECT		@intRegisterId = intRegisterId, 
			@ysnConsignmentStore = ysnConsignmentStore
FROM		tblSTStore
WHERE		intStoreId = @intStoreId

IF @intRegisterId IS NULL OR @ysnConsignmentStore = 0
BEGIN
	RETURN
END

SELECT		@strRegisterClass = strRegisterClass
FROM		tblSTRegister 
WHERE		intRegisterId = @intRegisterId

IF @strRegisterClass = 'SAPPHIRE/COMMANDER'
BEGIN
	INSERT INTO tblSTRegisterFileConfiguration
	(
				intRegisterId,
				intImportFileHeaderId,
				strFileType,
				strFilePrefix,
				strFileNamePattern,
				strFolderPath,
				strURICommand,
				strStoredProcedure,
				ysnActive,
				intConcurrencyId
	)
	SELECT	    @intRegisterId as intRegisterId, 
				x.intImportFileHeaderId, 
				'Inbound' as strFileType, 
				x.strFilePrefix, 
				x.strFileNamePattern, 
				'' as strFolderPath, 
				'' as strURICommand,
				x.strStoredProcedure, 
				1 as ysnActive, 
				1 as intConcurrencyId
	FROM		tblSTRegisterSetupDetail x 
	WHERE		x.strImportFileHeaderName IN (	'Commander - Transaction Log Rebate',
										'Commander Department',
										'Commander PLU',
										'Commander Summary',
										'Commander Tax',
										'Commander Tank Monitor',
										'Commander Fuel Totals',
										'Commander App Info',
										'Commander Pop Cfg',
										'Commander Tank',
										'Commander Loyalty',
										'Commander Tier Product',
										'Commander Validate',
										'Commander Category'
										) AND 
				x.intImportFileHeaderId NOT IN (	SELECT		y.intImportFileHeaderId 
													FROM		tblSTRegisterFileConfiguration y
													WHERE		y.intRegisterId = @intRegisterId)

	DELETE FROM		tblSTRegisterFileConfiguration
	WHERE			intRegisterId = @intRegisterId AND
					intImportFileHeaderId IN (	SELECT		intImportFileHeaderId 
												FROM		tblSTRegisterSetupDetail
												WHERE		strImportFileHeaderName = 'Commander FPHose')
END
END