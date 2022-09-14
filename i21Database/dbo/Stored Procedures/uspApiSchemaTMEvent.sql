CREATE PROCEDURE [dbo].[uspApiSchemaTMEvent]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS
BEGIN
	-- VALIDATE Event Type
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
			, strField = 'Event Type'
			, strValue = CS.strEventType
			, strLogLevel = 'Error'
			, strStatus = 'Failed'
			, intRowNo = CS.intRowNumber
			, strMessage = 'Cannot find the Event Type ''' + CS.strEventType + ''' in i21 Event type'
		FROM tblApiSchemaTMEvent CS
		LEFT JOIN tblTMEventType E ON E.strEventType  COLLATE Latin1_General_CI_AS = CS.strEventType  COLLATE Latin1_General_CI_AS
		WHERE (E.intEventTypeID IS NULL)
		AND CS.guiApiUniqueId = @guiApiUniqueId

		-- VALIDATE User
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
			, strField = 'User Name'
			, strValue = CS.strUserName
			, strLogLevel = 'Error'
			, strStatus = 'Failed'
			, intRowNo = CS.intRowNumber
			, strMessage = 'Cannot find the user name ''' + CS.strUserName + ''' in i21 '
		FROM tblApiSchemaTMEvent CS
			INNER JOIN tblSMUserSecurity US ON CS.strUserName = US.strUserName COLLATE Latin1_General_CI_AS 
			INNER JOIN tblEMEntity E ON E.intEntityId = US.intEntityId
		WHERE (US.intEntityId IS NULL)
		AND CS.guiApiUniqueId = @guiApiUniqueId

		-- VALIDATE Customer
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
			, strField = 'Customer Name'
			, strValue = CS.strCustomer
			, strLogLevel = 'Error'
			, strStatus = 'Failed'
			, intRowNo = CS.intRowNumber
			, strMessage = 'Cannot find the customer name ''' + CS.strCustomer + ''' in i21 '
		FROM tblTMCustomer TC 
			INNER JOIN tblARCustomer AC ON AC.intEntityId = TC.intCustomerNumber
			INNER JOIN tblEMEntity E ON E.intEntityId = AC.intEntityId
			inner join tblApiSchemaTMEvent CS on CS.strCustomer = E.strName COLLATE Latin1_General_CI_AS 
		WHERE (E.strName IS NULL)
		AND CS.guiApiUniqueId = @guiApiUniqueId

		-- VALIDATE SITE
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
			, strField = 'Site Number'
			, strValue = CS.intSiteNumber
			, strLogLevel = 'Error'
			, strStatus = 'Failed'
			, intRowNo = CS.intRowNumber
			, strMessage = 'Cannot find the site number ''' + CS.intSiteNumber + ''' in i21 '
		FROM tblApiSchemaTMEvent CS
			INNER JOIN tblTMSite US ON CS.intSiteNumber = US.intSiteNumber
			INNER JOIN tblTMEvent E ON E.intSiteID = US.intSiteID
		WHERE (US.intSiteNumber IS NULL)
		AND CS.guiApiUniqueId = @guiApiUniqueId

		-- CHECK IF ALREADY EXISTS IN EVENT

		-- PROCESS

		DECLARE @intRowNumber INT = NULL
		DECLARE @strCustomer nvarchar(100) = NULL
		DECLARE @dtmDate DATETIME = NULL
		DECLARE @strEventType  nvarchar(50) = NULL
		DECLARE @strUserName nvarchar(50) = NULL
		DECLARE @dtmLastUpdated DATETIME = NULL
		DECLARE @strDeviceOwnership NVARCHAR (20) = NULL
		DECLARE @strDeviceSerialNumber NVARCHAR (50) = NULL
		DECLARE @strDeviceType NVARCHAR (70) = NULL
		DECLARE @strDescription NVARCHAR (MAX) = NULL
		DECLARE @intSiteNumber INT = NULL
		DECLARE @strLevel NVARCHAR (20) = NULL
		DECLARE @dtmTankMonitorReading DATETIME = NULL
		DECLARE @strDeviceDescription NVARCHAR (200) = NULL

	DECLARE DataCursor CURSOR LOCAL FAST_FORWARD
    FOR
		select
			CS.intRowNumber,
			CS.strCustomer,
			CS.dtmDate,
			CS.strEventType,
			CS.strUserName,
			CS.dtmLastUpdated,
			CS.strDeviceOwnership,
			CS.strDeviceSerialNumber,
			CS.strDeviceType,
			CS.strDescription,
			CS.intSiteNumber,
			CS.strLevel,
			CS.dtmTankMonitorReading,
			CS.strDeviceDescription
		from tblApiSchemaTMEvent as CS
		 WHERE CS.guiApiUniqueId = @guiApiUniqueId 


    OPEN DataCursor
	FETCH NEXT FROM DataCursor INTO  @intRowNumber,@strCustomer,@dtmDate,@strEventType,@strUserName,@dtmLastUpdated,@strDeviceOwnership,@strDeviceSerialNumber,@strDeviceType,@strDescription,@intSiteNumber,@strLevel,@dtmTankMonitorReading,@strDeviceDescription
    WHILE @@FETCH_STATUS = 0
    BEGIN

			Declare @intSiteID int = NULL
			Declare @intEventTypeID int = NULL
			Declare @intUserID int = NULL
			
			set @intSiteID = (select top 1 intSiteID from tblTMSite where intSiteNumber = @intSiteNumber)
			set @intEventTypeID = (select top 1 intEventTypeID from tblTMEventType where strEventType = @strEventType)
			set @intUserID = (SELECT top 1 US.intEntityId FROM tblSMUserSecurity US INNER JOIN tblEMEntity E ON E.intEntityId = US.intEntityId where E.strName = @strUserName)

            IF(ISNULL(@intSiteID, '') != '' and ISNULL(@intEventTypeID, '') != '' and ISNULL(@intUserID, '') != '')
            BEGIN

               IF NOT EXISTS(SELECT TOP 1 1 FROM tblApiImportLogDetail WHERE guiApiImportLogId = @guiLogId AND strLogLevel = 'Error' AND intRowNo = @intRowNumber)
                BEGIN

                    --DECLARE  @intEventID INT = NULL 

                    -- INSERT ROUTE
					INSERT INTO tblTMEvent ([intConcurrencyId],
						[dtmDate],
						[intEventTypeID],
						[intUserID],
						[dtmLastUpdated],
						[strDeviceOwnership],
						[strDeviceSerialNumber],
						[strDeviceType],
						[strDescription],
						[intSiteID],
						[strLevel],
						[dtmTankMonitorReading],
						[strDeviceDescription])
                    VALUES (1,
						@dtmDate,
						@intEventTypeID,
						@intUserID,
						@dtmLastUpdated,
						@strDeviceOwnership,
						@strDeviceSerialNumber,
						@strDeviceType,
						@strDescription,
						@intSiteID,
						@strLevel,
						@dtmTankMonitorReading,
						@strDeviceDescription)

                    --SET @intEventID = SCOPE_IDENTITY()

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
						, strMessage = @strDescription + ', Site' +  ' is already exist'
                END
            END

        FETCH NEXT FROM DataCursor INTO @intRowNumber,@strCustomer,@dtmDate,@strEventType,@strUserName,@dtmLastUpdated,@strDeviceOwnership,@strDeviceSerialNumber,@strDeviceType,@strDescription,@intSiteNumber,@strLevel,@dtmTankMonitorReading,@strDeviceDescription
    END
    CLOSE DataCursor
	DEALLOCATE DataCursor

END