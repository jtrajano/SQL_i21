CREATE PROCEDURE [dbo].[uspSMCreateAttachmentFromFile]
	@transactionId INT,
	@fileName NVARCHAR(500),
	@fileExtension NVARCHAR(100),
	@filePath NVARCHAR(500),
	@screenNamespace NVARCHAR(500),
	@useDocumentWatcher BIT = 0,
	@throwError BIT = 1,
	@attachmentId INT OUTPUT,
	@error NVARCHAR(1000) = NULL OUTPUT 
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	BEGIN TRY
		
		--client side supported files, removed .3gp, .3g2, .xml due to mime comma value
		DECLARE @validExtension NVARCHAR(MAX) = N'aac,abw,arc,avi,azw,bin,bmp,bz,bz2,csh,css,csv,doc,docx,eot,epub,gz,gif,html,htm,ico,ics,jar,jpeg,jpg,js,json,jsonld,midi,mid,mjs,mp3,mpeg,mpkg,odp,ods,odt,oga,ogv,ogx,opus,otf,png,pdf,php,ppt,pptx,rar,rtf,sh,svg,swf,tar,tiff,tif,ts,ttf,txt,vsd,wav,weba,webm,webp,woff,woff2,xhtml,xls,xlsx,xml,xul,zip,3gp,3g2,7z'
		DECLARE @validExtesionMime NVARCHAR(MAX) = N'
			audio/aac,
			application/x-abiword,
			application/x-freearc,
			video/x-msvideo,
			application/vnd.amazon.ebook,
			application/octet-stream,
			application/octet-stream,
			image/bmp,
			application/x-bzip,
			application/x-bzip2,
			application/x-csh,
			text/css,
			text/csv,
			application/msword,
			application/vnd.openxmlformats-officedocument.wordprocessingml.document,
			application/vnd.ms-fontobject,
			application/epub+zip,
			application/gzip,
			image/gif,
			text/html,
			text/html,
			image/vnd.microsoft.icon,
			text/calendar,
			application/java-archive,
			image/jpeg,
			text/javascript,
			application/json,
			application/ld+json,
			audio/midi audio/x-midi,
			audio/midi audio/x-midi,
			text/javascript,
			audio/mpeg,
			video/mpeg,
			application/vnd.apple.installer+xml,
			application/vnd.oasis.opendocument.presentation,
			application/vnd.oasis.opendocument.spreadsheet,
			application/vnd.oasis.opendocument.text,
			audio/ogg,
			video/ogg,
			application/ogg,
			audio/opus,
			font/otf,
			image/png,
			application/pdf,
			application/php,
			application/vnd.ms-powerpoint,
			application/vnd.openxmlformats-officedocument.presentationml.presentation,
			application/x-rar-compressed,
			application/rtf,
			application/x-sh,
			image/svg+xml,
			application/x-shockwave-flash,
			application/x-tar,
			image/tiff,
			image/tiff,
			video/mp2t,
			font/ttf,
			text/plain,
			application/vnd.visio,
			audio/wav,
			audio/webm,
			video/webm,
			image/webp,
			font/woff,
			font/woff2,
			application/xhtml+xml,
			application/vnd.ms-excel,
			application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,
			application/xml text/xml,
			application/vnd.mozilla.xul+xml,
			application/zip,
			video/3gpp audio/3gpp,
			video/3gpp2 audio/3gpp2,
			application/x-7z-compressed
		'
		
		DECLARE @transCount INT = @@TRANCOUNT
		DECLARE @Exists INT
		DECLARE @fullFilePath NVARCHAR(1000)
		DECLARE @fileContent VARBINARY(max)
		DECLARE @sql NVARCHAR(MAX)
		DECLARE @ParamDefinition NVARCHAR(250) = N'@paramOut VARBINARY(MAX) OUTPUT'
		DECLARE @uploadId INT
		DECLARE @fileIdentifier NVARCHAR(100) = NEWID()
		DECLARE @screenId INT
		DECLARE @recordId INT
		DECLARE @fileTypeMime NVARCHAR(500)
		DECLARE @namespace NVARCHAR(500)

		IF @transCount = 0 BEGIN TRANSACTION

			--------------------------------------------------CREATE FILE TYPE TABLES--------------------------------------------------
			IF OBJECT_ID('tempdb..#TempFileExtension') IS NOT NULL
				DROP TABLE #TempFileExtension
			IF OBJECT_ID('tempdb..#TempFileExtensionMime') IS NOT NULL
				DROP TABLE #TempFileExtensionMime

			CREATE TABLE #TempFileExtension (
				[RowNum] [int] IDENTITY (1, 1) NOT NULL ,
				[Description] [nvarchar] (500) NOT NULL
			)

			CREATE TABLE #TempFileExtensionMime (
				[RowNum] [int] IDENTITY (1, 1) NOT NULL ,
				[Description] [nvarchar] (500) NOT NULL
			)

			INSERT INTO #TempFileExtension
			SELECT Item FROM dbo.fnSplitString(@validExtension, ',')

			INSERT INTO #TempFileExtensionMime
			SELECT Item FROM dbo.fnSplitString(@validExtesionMime, ',')

			--SELECT a.RowNum, a.Description, REPLACE(RTRIM(LTRIM(b.Description)), CHAR(9), '')
			--FROM #TempFileExtension a 
			--LEFT OUTER JOIN #TempFileExtensionMime b On a.RowNum = b.RowNum
			
			--------------------------------------------------VALIDATION PROCESS--------------------------------------------------

			--check if record exists
			IF NOT EXISTS(SELECT 1 FROM tblSMTransaction WHERE intTransactionId = ISNULL(@transactionId, 0))
			BEGIN
				SET @error =  'Transaction does not exists.';
				IF @throwError = 1
				BEGIN
					RAISERROR(@error, 16, 1);
				END
				RETURN;
			END

			--check if file extension is valid
			IF ISNULL(@fileExtension, '') = ''
			BEGIN
				SET @error =  'File extension is empty.';
				IF @throwError = 1
				BEGIN
					RAISERROR(@error, 16, 1);
				END
				RETURN;
			END
			SET @fileExtension = REPLACE(@fileExtension, '.', '')
			IF NOT EXISTS(SELECT TOP 1 1 FROM #TempFileExtension WHERE LOWER([Description]) = LOWER(@fileExtension))
			BEGIN
				SET @error =  'Invalid file extension.';
				IF @throwError = 1
				BEGIN
					RAISERROR(@error, 16, 1);
				END
				RETURN;
			END

			--check if file name exist
			IF ISNULL(@fileName, '') = ''
			BEGIN
				SET @error =  'File name is empty.';
				IF @throwError = 1
				BEGIN
					RAISERROR(@error, 16, 1);
				END
				RETURN;
			END

			------------------------------------------------SP PROCESS ONLY------------------------------------------------
			IF ISNULL(@useDocumentWatcher, 0) = 0
			BEGIN
				
				--check if file path exist
				IF ISNULL(@filePath, '') = ''
				BEGIN
					SET @error =  'File path is empty.';
					IF @throwError = 1
					BEGIN
						RAISERROR(@error, 16, 1);
					END
					RETURN;
				END

				--check if file exist
				EXEC master..xp_sprintf @fullFilePath OUTPUT, '%s\%s.%s', @filePath, @fileName, @fileExtension
				--SELECT @fullFilePath = FORMATMESSAGE('%s\%s.%s', @filePath, @fileName, @fileExtension); 

				IF ISNULL(@fullFilePath, '') = ''
				BEGIN
					SET @error =  'Invalid file path.';
					IF @throwError = 1
					BEGIN
						RAISERROR(@error, 16, 1);
					END
					RETURN;
				END

				EXEC master..xp_fileexist @fullFilePath, @Exists OUT
				IF ISNULL(@Exists, 0) = 0
				BEGIN
					EXEC xp_sprintf @error OUTPUT, 'Cannot find the file %s.%s in the path %s', @fileName, @fileExtension, @filePath
					IF @throwError = 1
					BEGIN
						RAISERROR(@error, 16, 1);
					END
					RETURN;
				END
			

				--------------------------------------------------UPLOAD--------------------------------------------------
				SET @sql = N'SET @paramOut = (SELECT * FROM  OPENROWSET(BULK N''' + @fullFilePath + ''', SINGLE_BLOB) AS import)'
				EXEC sp_executesql @sql, @ParamDefinition, @paramOut = @fileContent OUTPUT;

				IF ISNULL(DATALENGTH(@fileContent), 0) = 0
				BEGIN

					SET @error =  'No file to upload.';
					IF @throwError = 1
					BEGIN
						RAISERROR(@error, 16, 1);
					END
					RETURN;
				END

				SELECT @screenId = intScreenId, @recordId = intRecordId FROM tblSMTransaction WHERE intTransactionId = @transactionId
				SELECT @fileTypeMime = REPLACE(RTRIM(LTRIM(b.Description)), CHAR(9), '') 
					FROM #TempFileExtension a  
					LEFT OUTER JOIN #TempFileExtensionMime b On a.RowNum = b.RowNum 
					WHERE LOWER(a.[Description]) = LOWER(@fileExtension)
				SELECT @namespace = strNamespace FROM tblSMScreen WHERE intScreenId = @screenId

				IF ISNULL(@screenNamespace, '') <> ''
				BEGIN
					SET @namespace = @screenNamespace
				END

				INSERT INTO tblSMUpload (
					strFileIdentifier
					, blbFile
					, dtmDateUploaded
					, intConcurrencyId
				)
				VALUES (
					@fileIdentifier
					, @fileContent
					, GETDATE()
					, 1
				)

				SELECT @uploadId = SCOPE_IDENTITY()

				INSERT INTO tblSMAttachment (
						strName
					, strFileType
					, strFileIdentifier
					, strScreen	
					, strRecordNo
					, dtmDateModified
					, intSize
					, intConcurrencyId
					,intTransactionId
				)
				VALUES (
					@fileName + '.' + @fileExtension
					, @fileTypeMime
					, @fileIdentifier
					, @namespace
					, @recordId
					, GETDATE()
					, DATALENGTH(@fileContent)
					, 1
					,@transactionId
				)
				
				SET @attachmentId = SCOPE_IDENTITY()

				UPDATE tblSMUpload SET intAttachmentId = @attachmentId WHERE intUploadId = @uploadId
			END
			------------------------------------------------DOCUMENT WACTHER PROCESS------------------------------------------------
			ELSE
			BEGIN
				-- check if file exist
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMNewDocument WHERE strName = @fileName + '.' + @fileExtension AND ysnForAttachment = 1 AND ysnPending = 1)
				BEGIN
					EXEC xp_sprintf @error OUTPUT, 'Cannot find the file %s.%s in the Document Watcher (tblSMNewDocument)', @fileName, @fileExtension
					IF @throwError = 1
					BEGIN
						RAISERROR(@error, 16, 1);
					END
					RETURN;
				END

				SELECT @screenId = intScreenId, @recordId = intRecordId FROM tblSMTransaction WHERE intTransactionId = @transactionId
				SELECT @namespace = strNamespace FROM tblSMScreen WHERE intScreenId = @screenId
				SELECT @uploadId = intUploadId FROM tblSMNewDocument WHERE strName = @fileName + '.' + @fileExtension AND ysnForAttachment = 1 AND ysnPending = 1

				IF ISNULL(@screenNamespace, '') <> ''
				BEGIN
					SET @namespace = @screenNamespace
				END

				--save to attachment
				INSERT INTO tblSMAttachment (
						strName
					, strFileType
					, strFileIdentifier
					, strScreen	
					, strRecordNo
					, dtmDateModified
					, intSize
					, intEntityId
					, intConcurrencyId
					,intTransactionId
				)
				SELECT doc.strName
					, doc.strType
					, upload.strFileIdentifier
					, @namespace
					, @recordId
					, GETDATE()
					, doc.intSize
					, doc.intEntityId
					, 1
					,@transactionId
				FROM tblSMNewDocument doc 
				INNER JOIN tblSMUpload upload ON doc.intUploadId = upload.intUploadId
				WHERE doc.intUploadId = @uploadId
				
				SET @attachmentId = SCOPE_IDENTITY()

				UPDATE tblSMUpload SET intAttachmentId = @attachmentId WHERE intUploadId = @uploadId
				UPDATE tblSMNewDocument SET ysnPending = 0 WHERE intUploadId = @uploadId
			END

			



		IF @transCount = 0 COMMIT TRANSACTION


	END TRY
	BEGIN CATCH
		DECLARE @ErrorSeverity INT,
				@ErrorNumber   INT,
				@ErrorMessage nvarchar(4000),
				@ErrorState INT,
				@ErrorLine  INT,
				@ErrorProc nvarchar(200);

		-- Grab error information from SQL functions
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorNumber   = ERROR_NUMBER()
		SET @ErrorMessage  = ERROR_MESSAGE()
		SET @ErrorState    = ERROR_STATE()
		SET @ErrorLine     = ERROR_LINE()

		IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION

		SET @error = @ErrorMessage;
		IF @throwError = 1
		BEGIN
			RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
		END
	END CATCH
END