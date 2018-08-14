CREATE PROCEDURE [dbo].[uspSTGetXmlNamespace]
	@intStoreNo INT
	, @strFilePrefix NVARCHAR(20)
	, @strRegisterClass NVARCHAR(50) OUTPUT
	, @strXmlNamespace NVARCHAR(50) OUTPUT
	, @stri21FolderPath NVARCHAR(500) OUTPUT
	, @strFileNamePattern NVARCHAR(500) OUTPUT
	, @ysnSuccess BIT OUTPUT
	, @strStatusMsg NVARCHAR(1000) OUTPUT
AS
BEGIN TRY
	
	SET @strXmlNamespace = ''

	DECLARE @intStoreId AS INT
			, @strPrefix AS NVARCHAR(20)

	SELECT @intStoreId = ST.intStoreId 
		   , @strRegisterClass = R.strRegisterClass
		   , @stri21FolderPath = REPLACE((R.strRegisterInboxPath + RFC.strFolderPath), '/', '\')
		   , @strFileNamePattern = RFC.strFileNamePattern
	FROM tblSTStore ST
	JOIN tblSTRegister R
		ON ST.intRegisterId = R.intRegisterId
	JOIN tblSTRegisterFileConfiguration RFC
		ON R.intRegisterId = RFC.intRegisterId
	WHERE ST.intStoreNo = @intStoreNo
	AND RFC.strFileType = 'Inbound'
	AND RFC.strFilePrefix = @strFilePrefix


	SELECT @strXmlNamespace = strDefaultValue 
	FROM tblSMXMLTagAttribute
	WHERE intImportFileColumnDetailId = (
											SELECT intImportFileColumnDetailId 
											FROM tblSMImportFileColumnDetail
											WHERE intImportFileHeaderId = (
																			SELECT TOP 1 intImportFileHeaderId 
																			FROM tblSTRegisterFileConfiguration
																			WHERE intRegisterId = (
																									SELECT intRegisterId 
																									FROM tblSTStore
																									WHERE intStoreId = @intStoreId
																								  )
																			AND strFileType = 'Inbound'
																			AND strFilePrefix = @strFilePrefix
																		  )
											AND intLevel = 1
											AND intPosition = 0
											AND ysnActive = CAST(1 AS BIT)
										)
	AND intSequence = 2
	AND ysnActive = CAST(1 AS BIT)

	SET @ysnSuccess = CAST(1 AS BIT)
	SET @strStatusMsg = ''
END TRY

BEGIN CATCH
	SET @ysnSuccess = CAST(0 AS BIT)
	SET @strStatusMsg = ERROR_MESSAGE()
END CATCH