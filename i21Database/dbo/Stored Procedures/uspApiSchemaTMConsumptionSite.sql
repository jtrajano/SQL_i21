CREATE PROCEDURE [dbo].[uspApiSchemaTMConsumptionSite]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS
BEGIN

	DECLARE @tmpBillingType TABLE (
		strBillingType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	)

	DECLARE @tmpClassFill TABLE (
		strClassFill NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	)

	INSERT INTO @tmpBillingType (strBillingType) VALUES ('Tank')
	INSERT INTO @tmpBillingType (strBillingType) VALUES ('Flow Meter')
	INSERT INTO @tmpBillingType (strBillingType) VALUES ('Virtual Meter')

	INSERT INTO @tmpClassFill (strClassFill) VALUES ('No')
	INSERT INTO @tmpClassFill (strClassFill) VALUES ('Product Class')
	INSERT INTO @tmpClassFill (strClassFill) VALUES ('Any Item')

	-- VALIDATE Customer Entity
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
		, strField = 'Customer Entity No'
		, strValue = CS.strCustomerEntityNo
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Customer Entity No ''' + CS.strCustomerEntityNo + ''' in i21 Customers'
	FROM tblApiSchemaTMConsumptionSite CS
	LEFT JOIN tblEMEntity E ON E.strEntityNo = CS.strCustomerEntityNo
	LEFT JOIN tblARCustomer C ON C.intEntityId = E.intEntityId AND C.ysnActive = 1
	LEFT JOIN tblTMCustomer T ON T.intCustomerNumber = E.intEntityId
	WHERE (C.intEntityId IS NULL OR T.intCustomerID IS NULL)
	AND CS.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Billing By
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
		, strField = 'Billing By'
		, strValue = CS.strBillingBy
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Billing By ''' + CS.strBillingBy + ''' in i21 Billing By'
	FROM tblApiSchemaTMConsumptionSite CS
	LEFT JOIN @tmpBillingType B ON B.strBillingType = CS.strBillingBy
	WHERE B.strBillingType IS NULL 
	AND CS.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Driver ID
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
		, strField = 'Driver ID'
		, strValue = CS.strDriverId
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Driver ID ''' + CS.strDriverId + ''' in i21 Drivers'
	FROM tblApiSchemaTMConsumptionSite CS
	LEFT JOIN tblEMEntity E ON E.strEntityNo = CS.strDriverId
	LEFT JOIN [tblEMEntityType] B ON B.intEntityId = E.intEntityId AND B.strType = 'Salesperson'
	WHERE B.intEntityTypeId IS NULL
	AND CS.guiApiUniqueId = @guiApiUniqueId

    -- VALIDATE Route
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
		, strField = 'Route'
		, strValue = CS.strRoute
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Route ''' + CS.strDriverId + ''' in i21 Routes'
	FROM tblApiSchemaTMConsumptionSite CS
	LEFT JOIN tblTMRoute R ON R.strRouteId = CS.strRoute
	WHERE R.intRouteId IS NULL
	AND CS.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Location Name
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
		, strField = 'Location Name'
		, strValue = CS.strLocationName
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Location Name ''' + CS.strLocationName + ''' in i21 Company Locations'
	FROM tblApiSchemaTMConsumptionSite CS
	LEFT JOIN tblSMCompanyLocation C ON C.strLocationName = CS.strLocationName
	WHERE C.intCompanyLocationId IS NULL
	AND CS.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Clock
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
		, strField = 'Clock Number'
		, strValue = CS.strClock
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Clock Number ''' + CS.strClock + ''' in i21 Clocks'
	FROM tblApiSchemaTMConsumptionSite CS
	LEFT JOIN tblTMClock C ON C.strClockNumber = CS.strClock
	WHERE C.intClockID IS NULL
	AND CS.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Account Status Code
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
		, strField = 'Account Status Cocde'
		, strValue = CS.strAccountStatus
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Account Status Cocde ''' + CS.strAccountStatus + ''' in i21 Account Status'
	FROM tblApiSchemaTMConsumptionSite CS
	LEFT JOIN tblARAccountStatus A ON A.strAccountStatusCode = CS.strAccountStatus
	WHERE A.intAccountStatusId IS NULL
	AND CS.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Delivery Term
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
		, strField = 'Delivery Term'
		, strValue = CS.strDeliveryTerm
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Delivery Term ''' + CS.strDeliveryTerm + ''' in i21 Delivery Terms'
	FROM tblApiSchemaTMConsumptionSite CS
	LEFT JOIN tblSMTerm T ON T.strTerm = CS.strDeliveryTerm
	WHERE T.intTermID IS NULL
	AND ISNULL(CS.strDeliveryTerm, '') != ''
	AND CS.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Price Level
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
		, strField = 'Pricing Level'
		, strValue = CS.strPriceLevel
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Pricing Level ''' + CS.strPriceLevel + ''' in i21 Pricing'
	FROM tblApiSchemaTMConsumptionSite CS
	LEFT JOIN tblSMCompanyLocation C ON C.strLocationName = CS.strLocationName
	LEFT JOIN tblSMCompanyLocationPricingLevel P ON P.strPricingLevelName = CS.strPriceLevel AND P.intCompanyLocationId = C.intCompanyLocationId
	WHERE P.intCompanyLocationPricingLevelId IS NULL
	AND ISNULL(CS.strPriceLevel, '') != ''
	AND CS.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Tax Group
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
		, strField = 'Tax Group'
		, strValue = CS.strTaxGroup
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Tax Group ''' + CS.strTaxGroup + ''' in i21 Tax Groups'
	FROM tblApiSchemaTMConsumptionSite CS
	LEFT JOIN tblSMTaxGroup T ON T.strTaxGroup = CS.strTaxGroup
	WHERE T.intTaxGroupId IS NULL
	AND CS.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Class Fill
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
		, strField = 'Class Fill'
		, strValue = CS.strClassFill
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Class Fill ''' + CS.strClassFill + ''' in i21 Class Fills'
	FROM tblApiSchemaTMConsumptionSite CS
	LEFT JOIN @tmpClassFill C ON C.strClassFill = CS.strClassFill
	WHERE C.strClassFill IS NULL
	AND CS.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Item
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
		, strField = 'Item No'
		, strValue = CS.strItemNo
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Item No ''' + CS.strItemNo + ''' in i21 Items'
	FROM tblApiSchemaTMConsumptionSite CS
	LEFT JOIN tblICItem I ON I.strItemNo = CS.strItemNo
	WHERE I.intItemId IS NULL
	AND CS.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Fill Method
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
		, strField = 'Fill Method'
		, strValue = CS.strFillMethod
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Fill Method ''' + CS.strFillMethod + ''' in i21 Fill Methods'
	FROM tblApiSchemaTMConsumptionSite CS
	LEFT JOIN tblTMFillMethod F ON F.strFillMethod = CS.strFillMethod
	WHERE F.intFillMethodId IS NULL
	AND CS.guiApiUniqueId = @guiApiUniqueId

	-- VALIDATE Fill Group
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
		, strField = 'Fill Group Code'
		, strValue = CS.strFillGroup
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Fill Group Code ''' + CS.strFillGroup + ''' in i21 Fill Groups'
	FROM tblApiSchemaTMConsumptionSite CS
	LEFT JOIN tblTMFillGroup F ON F.strFillGroupCode = CS.strFillGroup
	WHERE F.intFillGroupId IS NULL
	AND CS.guiApiUniqueId = @guiApiUniqueId
	AND ISNULL(CS.strFillGroup, '') != ''

	-- VALIDATE Hold Reason
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
		, strField = 'Hold Reason'
		, strValue = CS.strHoldReason
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Hold Reason ''' + CS.strHoldReason + ''' in i21 TM Hold Reasons'
	FROM tblApiSchemaTMConsumptionSite CS
	LEFT JOIN tblTMHoldReason H ON H.strHoldReason = CS.strHoldReason
	WHERE H.intHoldReasonID IS NULL
	AND CS.guiApiUniqueId = @guiApiUniqueId
	AND ISNULL(CS.strHoldReason, '') != ''

	-- VALIDATE Julian Calendar
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
		, strField = 'Julian Calendar'
		, strValue = CS.strJulianCalendar
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Julian Calendar ''' + CS.strJulianCalendar + ''' in i21 Julian Calendars'
	FROM tblApiSchemaTMConsumptionSite CS
	LEFT JOIN tblTMGlobalJulianCalendar JC ON JC.strDescription = CS.strJulianCalendar
	WHERE JC.intGlobalJulianCalendarId IS NULL
	AND CS.guiApiUniqueId = @guiApiUniqueId
	AND ISNULL(CS.strJulianCalendar, '') != ''

	-- CHECK IF ALREADY EXISTS IN CONSUMPTION SITE

	-- PROCESS
	DECLARE @intCustomerId INT = NULL
		, @strBillingType NVARCHAR(100) = NULL	
		, @intDriverId INT = NULL
		, @intRouteId INT = NULL
		, @intCompanyLocationId INT = NULL
		, @intClockId INT = NULL
		, @strAccountStatus NVARCHAR(50) = NULL
		, @intItemId INT = NULL
		, @intFillMethodId INT = NULL
		, @intTermId  INT = NULL
		, @intCompanyLocationPricingLevelId INT = NULL
		, @intTaxGroupId INT = NULL
		, @strClassFill NVARCHAR(100) = NULL
		, @intFillGroupId INT = NULL
		, @intHoldReasonId INT = NULL
		, @intRowNumber INT = NULL
		, @strAddress NVARCHAR(500) = NULL	
		, @strZipCode NVARCHAR(50) = NULL
		, @strCity NVARCHAR(100) = NULL
		, @strState NVARCHAR(100) = NULL
		, @strCountry NVARCHAR(100) = NULL
		, @dblLatitude NUMERIC(18,6) = NULL
		, @dblLongitude NUMERIC(18,6) = NULL
		, @strSequence NVARCHAR(100) = NULL
		, @strFacilityNo NVARCHAR(100) = NULL
		, @dblCapacity NUMERIC(18,6) = NULL
		, @dblReserve NUMERIC(18,6) = NULL
		, @dblPriceAdj NUMERIC(18,6) = NULL
		, @ysnSaleTax BIT = NULL
		, @strRecurringPONo NVARCHAR(200) = NULL
		, @ysnHold BIT = NULL
		, @ysnHoldDDCalc BIT = NULL
		, @strHoldReason NVARCHAR(500) = NULL
		, @dtmHoldStartDate DATETIME = NULL
		, @dtmHoldEndDate DATETIME = NULL
		, @ysnLost BIT = NULL
		, @dtmLostDate DATETIME = NULL
		, @strLostReason NVARCHAR(500) = NULL
		, @intGlobalJulianCalendarId INT = NULL
		, @dtmNextJulianDate DATETIME = NULL
		, @dblSummerDailyRate NUMERIC(18,6) = NULL
		, @dblWinterDailyRate NUMERIC(18,6) = NULL
		, @dblBurnRate NUMERIC(18,6) = NULL
		, @dblPreviousBurnRate NUMERIC(18,6) = NULL
		, @dblDDBetweenDelivery NUMERIC(18,6) = NULL
		, @ysnAdjBurnRate BIT = NULL
		, @ysnPromptFull BIT = NULL
		, @strSiteDescription NVARCHAR(500) = NULL
		, @strSiteNumber NVARCHAR(20) = NULL
		, @strCustomerEntityNo NVARCHAR(100) = NULL
		, @ysnActive BIT = NULL

	DECLARE DataCursor CURSOR LOCAL FAST_FORWARD
    FOR
	SELECT T.intCustomerID AS intCustomerId
		, B.strBillingType AS strBillingType
		, D.intEntityId AS intDriverId
		, R.intRouteId AS intRouteId
		, CL.intCompanyLocationId AS intCompanyLocationId
		, CK.intClockID AS intClockId
		, CS.strAccountStatus AS strAccountStatus
		, I.intItemId AS intItemId
		, FM.intFillMethodId AS intFillMethodId
		, TE.intTermID AS intTermId
		, P.intCompanyLocationPricingLevelId AS intCompanyLocationPricingLevelId
		, TG.intTaxGroupId AS intTaxGroupId
		, CF.strClassFill AS strClassFill
		, FG.intFillGroupId AS intFillGroupId
		, H.intHoldReasonID AS intHoldReasonId
		, CS.intRowNumber
		, CS.strAddress AS strAddress
		, CS.strZipCode AS strZipCode
		, CS.strCity AS strCity
		, CS.strState AS strState
		, CS.strCountry AS strCountry
		, CS.dblLatitude AS dblLatitude
		, CS.dblLongitude AS dblLongitude
		, CS.strSequence AS strSequence
		, CS.strFacilityNo AS strFacilityNo
		, CS.dblCapacity AS dblCapacity
		, CS.dblReserve AS dblReserve
		, CS.dblPriceAdj AS dblPriceAdj
		, CS.ysnSaleTax	AS ysnSaleTax
		, CS.strRecurringPONo AS strRecurringPONo
		, CS.ysnHold AS ysnHold
		, CS.ysnHoldDDCalc AS ysnHoldDDCalc
		, CS.strHoldReason AS strHoldReason
		, CS.dtmHoldStartDate AS dtmHoldStartDate
		, CS.dtmHoldEndDate AS dtmHoldEndDate
		, CS.ysnLost AS ysnLost
		, CS.dtmLostDate AS dtmLostDate
		, CS.strLostReason AS strLostReason
		--, CS.strJulianCalendar AS strJulianCalendar
		, JC.intGlobalJulianCalendarId
		, CS.dtmNextJulianDate AS dtmNextJulianDate
		, CS.dblSummerDailyRate AS dblSummerDailyRate
		, CS.dblWinterDailyRate AS dblWinterDailyRate
		, CS.dblBurnRate AS dblBurnRate
		, CS.dblPreviousBurnRate AS dblPreviousBurnRate
		, CS.dblDDBetweenDelivery AS dblDDBetweenDelivery
		, CS.ysnAdjBurnRate AS ysnAdjBurnRate
		, CS.ysnPromptFull AS ysnPromptFull
		, CS.strSiteDescription AS strSiteDescription
		, CS.strSiteNumber AS strSiteNumber
		, CS.strCustomerEntityNo AS strCustomerEntityNo	
		, CS.ysnActive AS ysnActive
	FROM tblApiSchemaTMConsumptionSite CS
	INNER JOIN tblEMEntity E ON E.strEntityNo = CS.strCustomerEntityNo
	INNER JOIN tblARCustomer C ON C.intEntityId = E.intEntityId AND C.ysnActive = 1
	INNER JOIN tblTMCustomer T ON T.intCustomerNumber = E.intEntityId
	INNER JOIN @tmpBillingType B ON B.strBillingType = CS.strBillingBy
	INNER JOIN tblEMEntity D ON D.strEntityNo = CS.strDriverId
	INNER JOIN [tblEMEntityType] DT ON DT.intEntityId = D.intEntityId AND DT.strType = 'Salesperson'
	INNER JOIN tblTMRoute R ON R.strRouteId = CS.strRoute
	INNER JOIN tblSMCompanyLocation CL ON CL.strLocationName = CS.strLocationName
	INNER JOIN tblTMClock CK ON CK.strClockNumber = CS.strClock
	INNER JOIN tblARAccountStatus A ON A.strAccountStatusCode = CS.strAccountStatus
	INNER JOIN tblICItem I ON I.strItemNo = CS.strItemNo
	INNER JOIN tblTMFillMethod FM ON FM.strFillMethod = CS.strFillMethod
	LEFT JOIN tblSMTerm TE ON TE.strTerm = CS.strDeliveryTerm
	LEFT JOIN tblSMCompanyLocationPricingLevel P ON P.strPricingLevelName = CS.strPriceLevel AND P.intCompanyLocationId = CL.intCompanyLocationId
	LEFT JOIN tblSMTaxGroup TG ON TG.strTaxGroup = CS.strTaxGroup
	LEFT JOIN @tmpClassFill CF ON CF.strClassFill = CS.strClassFill
	LEFT JOIN tblTMFillGroup FG ON FG.strFillGroupCode = CS.strFillGroup
	LEFT JOIN tblTMHoldReason H ON H.strHoldReason = CS.strHoldReason
	LEFT JOIN tblTMGlobalJulianCalendar JC ON JC.strDescription = CS.strJulianCalendar
	--LEFT JOIN tblTMSite ST ON ST.intCustomerID = T.intCustomerID
		-- AND ST.strBillingBy = B.strBillingType
		-- AND ST.intDriverID = D.intEntityId
		-- AND ST.intRouteId = R.intRouteId
		-- AND ST.intLocationId = CL.intCompanyLocationId
		-- AND ST.intClockID = CK.intClockID
		-- AND ST.strAcctStatus = A.strAccountStatusCode
		-- AND ST.intProduct = I.intItemId
		-- AND ST.intFillMethodId = FM.intFillMethodId
		-- AND ISNULL(ST.intDeliveryTermID, 0) = ISNULL(TE.intTermID, 0)
		-- AND ISNULL(ST.intCompanyLocationPricingLevelId, 0) = ISNULL(P.intCompanyLocationPricingLevelId, 0)
		-- AND ISNULL(ST.intTaxStateID, 0) = ISNULL(TG.intTaxGroupId, 0)
		-- AND ISNULL(ST.strClassFillOption, 0) = ISNULL(CF.strClassFill, 0)
		-- AND ISNULL(ST.intFillGroupId, 0) = ISNULL(FG.intFillGroupId, 0)
		-- AND ISNULL(ST.intHoldReasonID, 0) = ISNULL(H.intHoldReasonID, 0)
		-- AND ISNULL(JC.intHoldReasonID, 0) = ISNULL(H.intHoldReasonID, 0)
	WHERE CS.guiApiUniqueId = @guiApiUniqueId
		AND (ISNULL(CS.strDeliveryTerm, '') = '' OR (TE.intTermID IS NOT NULL AND ISNULL(CS.strDeliveryTerm, '') != ''))
		AND (ISNULL(CS.strPriceLevel, '') = '' OR (P.intCompanyLocationPricingLevelId IS NOT NULL AND ISNULL(CS.strPriceLevel, '') != ''))
		AND (ISNULL(CS.strTaxGroup, '') = '' OR (TG.intTaxGroupId IS NOT NULL AND ISNULL(CS.strTaxGroup, '') != ''))
		AND (ISNULL(CS.strClassFill, '') = '' OR (CF.strClassFill IS NOT NULL AND ISNULL(CS.strClassFill, '') != ''))
		AND (ISNULL(CS.strFillGroup, '') = '' OR (FG.intFillGroupId IS NOT NULL AND ISNULL(CS.strFillGroup, '') != ''))
		AND (ISNULL(CS.strHoldReason, '') = '' OR (H.intHoldReasonID IS NOT NULL AND ISNULL(CS.strHoldReason, '') != ''))
		AND (ISNULL(CS.strJulianCalendar, '') = '' OR (JC.intGlobalJulianCalendarId IS NOT NULL AND ISNULL(CS.strJulianCalendar, '') != ''))

	OPEN DataCursor
	FETCH NEXT FROM DataCursor INTO @intCustomerId, @strBillingType, @intDriverId, @intRouteId, @intCompanyLocationId, @intClockId, @strAccountStatus, @intItemId, @intFillMethodId, @intTermId, @intCompanyLocationPricingLevelId, @intTaxGroupId, @strClassFill, @intFillGroupId, @intHoldReasonId, @intRowNumber
		, @strAddress, @strZipCode, @strCity, @strState, @strCountry, @dblLatitude, @dblLongitude, @strSequence, @strFacilityNo, @dblCapacity, @dblReserve, @dblPriceAdj
		, @ysnSaleTax, @strRecurringPONo, @ysnHold, @ysnHoldDDCalc, @strHoldReason, @dtmHoldStartDate, @dtmHoldEndDate
		, @ysnLost, @dtmLostDate, @strLostReason, @intGlobalJulianCalendarId, @dtmNextJulianDate, @dblSummerDailyRate, @dblWinterDailyRate, @dblBurnRate, @dblPreviousBurnRate, @dblDDBetweenDelivery, @ysnAdjBurnRate, @ysnPromptFull
		, @strSiteDescription, @strSiteNumber, @strCustomerEntityNo, @ysnActive
	WHILE @@FETCH_STATUS = 0
    BEGIN
		DECLARE @intSiteId INT = NULL
		SELECT @intSiteId = intSiteID FROM tblTMSite WHERE intCustomerID = @intCustomerId AND intSiteNumber = CONVERT(int,@strSiteNumber)
		
		-- IF ONE OF THE REQUIRED FIELDS FOR ADDRESS IS NULL THEN IT WILL GET THE CUSTOMER ADDRESS
		IF(@strAddress IS NULL OR @strZipCode IS NULL OR @strCity IS NULL OR @strState IS NULL OR @strCountry IS NULL)
		BEGIN
			SELECT @strAddress = vwcus_addr
				, @strCity = vwcus_city
				, @strState = vwcus_state
				, @strZipCode = vwcus_zip
				, @strCountry = vwcus_country 
			FROM tblTMCustomer A
			INNER JOIN vwcusmst C ON C.A4GLIdentity =  A.intCustomerNumber
			WHERE A.intCustomerID = @intCustomerId
		END

		IF(@intSiteId IS NULL) 
		BEGIN
			-- ADD NEW SITE		
			DECLARE @intSiteNumber INT = NULL

			SELECT @intSiteNumber = MAX(intSiteNumber) FROM tblTMSite WHERE intCustomerID = @intCustomerId

			INSERT INTO tblTMSite (intCustomerID
				, strBillingBy
				, intDriverID
				, intRouteId
				, intLocationId
				, intClockID
				, strAcctStatus
				, intProduct
				, intFillMethodId
				, intDeliveryTermID
				, intCompanyLocationPricingLevelId
				, intTaxStateID
				, strClassFillOption
				, intFillGroupId
				, intHoldReasonID
				, intSiteNumber
				
				, ysnActive
				, strDescription
				, strSiteAddress
				, strZipCode
				, strCity
				, strState
				, strCountry
				, dblLatitude
				, dblLongitude
				, strSequenceID
				, strFacilityNumber

				, ysnOnHold
				, ysnHoldDDCalculations
				, dtmOnHoldStartDate
				, dtmOnHoldEndDate
				, ysnLostCustomer
				, dtmLostCustomerDate

				, dblTotalCapacity
				, dblTotalReserve
				, dblPriceAdjustment
				, ysnTaxable
				, strRecurringPONumber

				, intGlobalJulianCalendarId
				, dtmNextDeliveryDate
				, dblSummerDailyUse
				, dblWinterDailyUse
				, dblBurnRate
				, dblPreviousBurnRate
				, dblDegreeDayBetweenDelivery
				, ysnAdjustBurnRate
				, ysnPromptForPercentFull
				
				, guiApiUniqueId
				, intRowNumber)
			VALUES (@intCustomerId
				, @strBillingType
				, @intDriverId
				, @intRouteId
				, @intCompanyLocationId
				, @intClockId
				, @strAccountStatus
				, @intItemId
				, @intFillMethodId
				, @intTermId
				, @intCompanyLocationPricingLevelId
				, @intTaxGroupId
				, @strClassFill
				, @intFillGroupId
				, @intHoldReasonId
				, ISNULL(@intSiteNumber, 0) + 1
				
				, @ysnActive
				, @strSiteDescription
				, @strAddress
				, @strZipCode
				, @strCity
				, @strState
				, @strCountry
				, @dblLatitude
				, @dblLongitude
				, @strSequence
				, @strFacilityNo

				, @ysnHold
				, @ysnHoldDDCalc
				, @dtmHoldStartDate
				, @dtmHoldEndDate
				, @ysnLost
				, @dtmLostDate

				, @dblCapacity
				, @dblReserve
				, @dblPriceAdj
				, @ysnSaleTax
				, @strRecurringPONo

				, @intGlobalJulianCalendarId
				, @dtmNextJulianDate
				, ISNULL(@dblSummerDailyRate, 0)
				, ISNULL(@dblWinterDailyRate, 0)
				, @dblBurnRate
				, @dblPreviousBurnRate
				, @dblDDBetweenDelivery
				, @ysnAdjBurnRate
				, @ysnPromptFull
				
				, @guiLogId
				, @intRowNumber)

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
			-- UPDATE THE EXISTING SITE
			UPDATE tblTMSite SET strBillingBy = @strBillingType
				, intDriverID = @intDriverId
				, intRouteId = @intRouteId
				, intLocationId = @intCompanyLocationId
				, intClockID = @intClockId
				, strAcctStatus = @strAccountStatus
				, intProduct = @intItemId
				, intFillMethodId = @intFillMethodId
				, intDeliveryTermID = @intTermId
				, intCompanyLocationPricingLevelId = @intCompanyLocationPricingLevelId
				, intTaxStateID = @intTaxGroupId
				, strClassFillOption = @strClassFill
				, intFillGroupId = @intFillGroupId
				, intHoldReasonID = @intHoldReasonId

				, ysnActive = @ysnActive
				, strDescription = @strSiteDescription
				, strSiteAddress = @strAddress
				, strZipCode = @strZipCode
				, strCity = @strCity
				, strState = @strState
				, strCountry = @strCountry
				, dblLatitude = @dblLatitude
				, dblLongitude = @dblLongitude
				, strSequenceID = @strSequence
				, strFacilityNumber = @strFacilityNo

				, ysnOnHold = @ysnHold
				, ysnHoldDDCalculations = @ysnHoldDDCalc
				, dtmOnHoldStartDate = @dtmHoldStartDate
				, dtmOnHoldEndDate = @dtmHoldEndDate
				, ysnLostCustomer = @ysnLost
				, dtmLostCustomerDate = @dtmLostDate
				
				, dblTotalCapacity = @dblCapacity
				, dblTotalReserve = @dblReserve
				, dblPriceAdjustment = @dblPriceAdj
				, ysnTaxable = @ysnSaleTax
				, strRecurringPONumber = @strRecurringPONo

				, intGlobalJulianCalendarId = @intGlobalJulianCalendarId
				, dtmNextDeliveryDate = @dtmNextJulianDate
				, dblSummerDailyUse = ISNULL(@dblSummerDailyRate, 0)
				, dblWinterDailyUse = ISNULL(@dblWinterDailyRate, 0)
				, dblBurnRate = @dblBurnRate
				, dblPreviousBurnRate = @dblPreviousBurnRate
				, dblDegreeDayBetweenDelivery = @dblDDBetweenDelivery
				, ysnAdjustBurnRate = @ysnAdjBurnRate
				, ysnPromptForPercentFull = @ysnPromptFull
				, guiApiUniqueId = @guiLogId
				, intRowNumber = @intRowNumber
			WHERE intSiteID = @intSiteId

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
				, strMessage = 'Successfully updated'
		END

		FETCH NEXT FROM DataCursor INTO @intCustomerId, @strBillingType, @intDriverId, @intRouteId, @intCompanyLocationId, @intClockId, @strAccountStatus, @intItemId, @intFillMethodId, @intTermId, @intCompanyLocationPricingLevelId, @intTaxGroupId, @strClassFill, @intFillGroupId, @intHoldReasonId, @intRowNumber
			, @strAddress, @strZipCode, @strCity, @strState, @strCountry, @dblLatitude, @dblLongitude, @strSequence, @strFacilityNo, @dblCapacity, @dblReserve, @dblPriceAdj
			, @ysnSaleTax, @strRecurringPONo, @ysnHold, @ysnHoldDDCalc, @strHoldReason, @dtmHoldStartDate, @dtmHoldEndDate
			, @ysnLost, @dtmLostDate, @strLostReason, @intGlobalJulianCalendarId, @dtmNextJulianDate, @dblSummerDailyRate, @dblWinterDailyRate, @dblBurnRate, @dblPreviousBurnRate, @dblDDBetweenDelivery, @ysnAdjBurnRate, @ysnPromptFull
			, @strSiteDescription, @strSiteNumber, @strCustomerEntityNo, @ysnActive
	END
	CLOSE DataCursor
	DEALLOCATE DataCursor
 
END