CREATE PROCEDURE [dbo].[uspApiSchemaTMRoute]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS
BEGIN

    DECLARE @strRoute NVARCHAR(200) = NULL
	DECLARE @intRowNumber INT = NULL

	DECLARE DataCursor CURSOR LOCAL FAST_FORWARD
    FOR
    SELECT R.strRoute, R.intRowNumber
    FROM tblApiSchemaTMRoute R
    WHERE R.guiApiUniqueId = @guiApiUniqueId

    OPEN DataCursor
	FETCH NEXT FROM DataCursor INTO @strRoute, @intRowNumber
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY

            IF(ISNULL(@strRoute, '') != '')
            BEGIN

                IF EXISTS(SELECT TOP 1 1 FROM tblTMRoute WHERE strRouteId = @strRoute)
                BEGIN

                    DECLARE  @intRouteId INT = NULL 

                    -- INSERT ROUTE
					INSERT INTO tblTMRoute (strRouteId
                        , intConcurrencyId
                        , guiApiUniqueId
                        , intRowNumber) 
                    VALUES (@strRoute
                        , 1
                        , @guiLogId
						, @intRowNumber)

                    SET @intRouteId = SCOPE_IDENTITY()

					INSERT INTO tblApiImportLogDetail (
						guiApiImportLogDetailId
						, guiApiImportLogId
						, strField
						, strValue
						, strLogLevel
						, strStatus
						, intRowNo
						, strMessage
					)
					SELECT guiApiImportLogDetailId = NEWID()
						, guiApiImportLogId = @guiLogId
						, strField = ''
						, strValue = '' 
						, strLogLevel = 'Success'
						, strStatus = 'Success'
						, intRowNo = @intRowNumber
						, strMessage = 'Successfully added'
                END
                ELSE
                BEGIN
                    INSERT INTO tblApiImportLogDetail (
						guiApiImportLogDetailId
						, guiApiImportLogId
						, strField
						, strValue
						, strLogLevel
						, strStatus
						, intRowNo
						, strMessage
					)
					SELECT guiApiImportLogDetailId = NEWID()
						, guiApiImportLogId = @guiLogId
						, strField = ''
						, strValue = '' 
						, strLogLevel = 'Error'
						, strStatus = 'Failed'
						, intRowNo = @intRowNumber
						, strMessage = @strRoute + ' is already exist'
                END
            END
           
        END TRY
        BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(MAX) = NULL
			SELECT @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO tblApiImportLogDetail (
				guiApiImportLogDetailId
				, guiApiImportLogId
				, strField
				, strValue
				, strLogLevel
				, strStatus
				, intRowNo
				, strMessage
			)
			SELECT guiApiImportLogDetailId = NEWID()
				, guiApiImportLogId = @guiLogId
				, strField = ''
				, strValue = '' 
				, strLogLevel = 'Error'
				, strStatus = 'Failed'
				, intRowNo = @intRowNumber
				, strMessage = 'Error on inserting/updating - ' + @ErrorMessage
		END CATCH

        FETCH NEXT FROM DataCursor INTO @strRoute, @intRowNumber
    END
    CLOSE DataCursor
	DEALLOCATE DataCursor

END