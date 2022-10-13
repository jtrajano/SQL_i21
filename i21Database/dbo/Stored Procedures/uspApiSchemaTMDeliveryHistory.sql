CREATE PROCEDURE [dbo].[uspApiSchemaTMDeliveryHistory]
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS
BEGIN

		--Validate User Name
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
		FROM tblApiSchemaTMDeliveryHistory CS
			INNER JOIN tblSMUserSecurity US ON CS.strUserName = US.strUserName COLLATE Latin1_General_CI_AS 
			INNER JOIN tblEMEntity E ON E.intEntityId = US.intEntityId
		WHERE (US.intEntityId IS NULL)
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
		FROM tblApiSchemaTMDeliveryHistory CS
			INNER JOIN tblTMSite US ON CS.intSiteNumber = US.intSiteNumber
			INNER JOIN tblTMEvent E ON E.intSiteID = US.intSiteID
		WHERE (US.intSiteNumber IS NULL)
		AND CS.guiApiUniqueId = @guiApiUniqueId

			-- VALIDATE Sales Person ID
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
		, strField = 'Sales person ID'
		, strValue = CS.strDriverName
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Sales Person ID ''' + CS.strSalespersonName + ''' in i21'
	FROM tblApiSchemaTMDeliveryHistory CS
	LEFT JOIN tblEMEntity E ON E.strName = CS.strDriverName COLLATE Latin1_General_CI_AS
	LEFT JOIN [tblEMEntityType] B ON B.intEntityId = E.intEntityId AND B.strType = 'Salesperson'  
	WHERE B.intEntityTypeId IS NULL
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
		, strValue = CS.strDriverName
		, strLogLevel = 'Error'
		, strStatus = 'Failed'
		, intRowNo = CS.intRowNumber
		, strMessage = 'Cannot find the Driver ID ''' + CS.strSalespersonName + ''' in i21'
	FROM tblApiSchemaTMDeliveryHistory CS
	LEFT JOIN tblEMEntity E ON E.strName = CS.strDriverName COLLATE Latin1_General_CI_AS
	LEFT JOIN [tblEMEntityType] B ON B.intEntityId = E.intEntityId AND B.strType = 'Salesperson' COLLATE Latin1_General_CI_AS 
	WHERE B.intEntityTypeId IS NULL
	AND CS.guiApiUniqueId = @guiApiUniqueId

			--Validate Will Call User Name
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
			, strMessage = 'Cannot find the will call user name ''' + CS.strUserName + ''' in i21 '
		FROM tblApiSchemaTMDeliveryHistory CS
			INNER JOIN tblSMUserSecurity US ON CS.strUserName = US.strUserName COLLATE Latin1_General_CI_AS 
			INNER JOIN tblEMEntity E ON E.intEntityId = US.intEntityId
		WHERE (US.intEntityId IS NULL)
		AND CS.guiApiUniqueId = @guiApiUniqueId

	-- PROCESS
	DECLARE @strInvoiceNumber nvarchar(50) = NULL,
			@strBulkPlantNumber nvarchar(50) = NULL,
			@dtmInvoiceDate datetime = NULL,
			@strProductDelivered nvarchar(50) = NULL,
			@dblQuantityDelivered numeric(18, 6) = NULL,
			@intDegreeDayOnDeliveryDate int = NULL,
			@intDegreeDayOnLastDeliveryDate int = NULL,
			@dblBurnRateAfterDelivery numeric (18, 6) = NULL,
			@dblCalculatedBurnRate numeric(18, 6) = NULL,
			@ysnAdjustBurnRate bit = NULL,
			@intElapsedDegreeDaysBetweenDeliveries int = NULL,
			@intElapsedDaysBetweenDeliveries int = NULL,
			@strSeason nvarchar(15) = NULL,
			@dblWinterDailyUsageBetweenDeliveries numeric(18, 6) = NULL,
			@dblSummerDailyUsageBetweenDeliveries numeric (18, 6) = NULL,
			@dblGallonsInTankbeforeDelivery numeric(18, 6) = NULL,
			@dblGallonsInTankAfterDelivery numeric(18, 6) = NULL,
			@dblEstimatedPercentBeforeDelivery numeric(18, 6) = NULL,
			@dblActualPercentAfterDelivery numeric(18, 6) = NULL,
			@dblMeterReading numeric(18, 6) = NULL,
			@dblLastMeterReading numeric(18, 6) = NULL,
			@strUserName nvarchar(50) = NULL,
			@dtmLastUpdated datetime = NULL,
			@intSiteNumber int = NULL,
			@strSalespersonName nvarchar(100) = NULL,
			@dblExtendedAmount numeric(18, 6) = NULL,
			@ysnForReview bit = NULL,
			@dtmMarkForReviewDate datetime = NULL,
			@dblWillCallPercentLeft numeric(18, 6) = NULL,
			@dblWillCallCalculatedQuantity numeric(18, 6) = NULL,
			@dblWillCallDesiredQuantity numeric(18, 6) = NULL,
			@strDriverName nvarchar(100) = NULL,
			@strWillCallProduct nvarchar(350) = NULL,
			@dblWillCallPrice numeric(18, 6) = NULL,
			@strWillCallDeliveryTerm nvarchar(100) = NULL,
			@dtmWillCallRequestedDate datetime = NULL,
			@intWillCallPriority int = NULL,
			@dblWillCallTotal numeric(18, 6) = NULL,
			@strWillCallComments nvarchar(200) = NULL,
			@dtmWillCallCallInDate datetime = NULL,
			@strWillCallUser nvarchar(200) = NULL,
			@ysnWillCallPrinted bit = NULL,
			@dtmWillCallDispatch datetime = NULL,
			@strWillCallOrderNumber nvarchar(50) = NULL,
			@strWillCallContractNumber nvarchar(50) = NULL,
			@dtmWillCallDeliveryDate datetime = NULL,
			@dblWillCallDeliveryQuantity numeric(18, 6) = NULL,
			@dblWillCallDeliveryPrice numeric(18, 6) = NULL,
			@dblWillCallDeliveryTotal numeric(18, 6) = NULL,
			@strInvoiceDetail nvarchar(50) = NULL,
			@dtmSiteLastDelivery datetime = NULL,
			@dblSitePreviousBurnRate numeric(18, 6) = NULL,
			@dblSiteBurnRate numeric(18, 6) = NULL,
			@dtmSiteOnHoldStartDate datetime = NULL,
			@dtmSiteOnHoldEndDate datetime = NULL,
			@ysnSiteHoldDDCalculations bit = NULL,
			@ysnSiteOnHold bit = NULL,
			@dblSiteLastDeliveredGal numeric(18, 6) = NULL,
			@ysnSiteDeliveryTicketPrinted bit = NULL,
			@dblSiteDegreeDayBetweenDelivery numeric(18, 6) = NULL,
			@intSiteNextDeliveryDegreeDay int = NULL,
			@dblSiteLastGalsInTank numeric(18, 6) = NULL,
			@dblSiteEstimatedPercentLeft numeric(18, 6) = NULL,
			@dtmSiteLastReadingUpdate datetime = NULL,
			@ysnMeterReading bit = NULL ,
			@strWillCallRoute nvarchar(50) = NULL,
			@dtmCreatedDate datetime = NULL,
			@ysnWillCallLeakCheckRequired bit = NULL,
			@dblWillCallOriginalPercentLeft numeric(18, 6) = NULL,
			@ysnManualAdjustment bit = NULL,
			@dtmNextDeliveryDate datetime = NULL,
			@dtmRunOutDate datetime = NULL,
			@dtmForecastedDelivery datetime = NULL,
			@intRowNumber INT = NULL,
			@strCustomerEntityNo nvarchar(200) = NULL
	
	DECLARE DataCursor CURSOR LOCAL FAST_FORWARD
    FOR

	select 
		intRowNumber,
		strInvoiceNumber,
		strBulkPlantNumber,
		dtmInvoiceDate,
		strProductDelivered,
		dblQuantityDelivered,
		intDegreeDayOnDeliveryDate,
		intDegreeDayOnLastDeliveryDate,
		dblBurnRateAfterDelivery,
		dblCalculatedBurnRate,
		ysnAdjustBurnRate,
		intElapsedDegreeDaysBetweenDeliveries,
		intElapsedDaysBetweenDeliveries,
		strSeason,
		dblWinterDailyUsageBetweenDeliveries,
		dblSummerDailyUsageBetweenDeliveries,
		dblGallonsInTankbeforeDelivery,
		dblGallonsInTankAfterDelivery,
		dblEstimatedPercentBeforeDelivery,
		dblActualPercentAfterDelivery,
		dblMeterReading,
		dblLastMeterReading,
		strUserName,
		dtmLastUpdated,
		intSiteNumber,
		strSalespersonName,
		dblExtendedAmount,
		ysnForReview,
		dtmMarkForReviewDate,
		dblWillCallPercentLeft,
		dblWillCallCalculatedQuantity,
		dblWillCallDesiredQuantity,
		strDriverName,
		strWillCallProduct,
		dblWillCallPrice,
		strWillCallDeliveryTerm,
		dtmWillCallRequestedDate,
		intWillCallPriority,
		dblWillCallTotal,
		strWillCallComments,
		dtmWillCallCallInDate,
		strWillCallUser,
		ysnWillCallPrinted,
		dtmWillCallDispatch,
		strWillCallOrderNumber,
		strWillCallContractNumber,
		dtmWillCallDeliveryDate,
		dblWillCallDeliveryQuantity,
		dblWillCallDeliveryPrice,
		dblWillCallDeliveryTotal,
		strInvoiceDetail,
		dtmSiteLastDelivery,
		dblSitePreviousBurnRate,
		dblSiteBurnRate,
		dtmSiteOnHoldStartDate,
		dtmSiteOnHoldEndDate,
		ysnSiteHoldDDCalculations,
		ysnSiteOnHold,
		dblSiteLastDeliveredGal,
		ysnSiteDeliveryTicketPrinted,
		dblSiteDegreeDayBetweenDelivery,
		intSiteNextDeliveryDegreeDay,
		dblSiteLastGalsInTank,
		dblSiteEstimatedPercentLeft,
		dtmSiteLastReadingUpdate,
		ysnMeterReading,
		strWillCallRoute,
		dtmCreatedDate,
		ysnWillCallLeakCheckRequired,
		dblWillCallOriginalPercentLeft,
		ysnManualAdjustment,
		dtmNextDeliveryDate,
		dtmRunOutDate,
		dtmForecastedDelivery,
		strCustomerEntityNo
	from  [dbo].[tblApiSchemaTMDeliveryHistory]
		WHERE guiApiUniqueId = @guiApiUniqueId


	OPEN DataCursor
	FETCH NEXT FROM DataCursor INTO @intRowNumber,@strInvoiceNumber,@strBulkPlantNumber,@dtmInvoiceDate,@strProductDelivered,@dblQuantityDelivered,@intDegreeDayOnDeliveryDate,@intDegreeDayOnLastDeliveryDate,@dblBurnRateAfterDelivery,@dblCalculatedBurnRate,
									@ysnAdjustBurnRate,@intElapsedDegreeDaysBetweenDeliveries,@intElapsedDaysBetweenDeliveries,@strSeason,@dblWinterDailyUsageBetweenDeliveries,@dblSummerDailyUsageBetweenDeliveries,@dblGallonsInTankbeforeDelivery,
									@dblGallonsInTankAfterDelivery,@dblEstimatedPercentBeforeDelivery,@dblActualPercentAfterDelivery,@dblMeterReading,@dblLastMeterReading,@strUserName,@dtmLastUpdated,@intSiteNumber,@strSalespersonName,@dblExtendedAmount,
									@ysnForReview,@dtmMarkForReviewDate,@dblWillCallPercentLeft,@dblWillCallCalculatedQuantity,@dblWillCallDesiredQuantity,@strDriverName,@strWillCallProduct,@dblWillCallPrice,@strWillCallDeliveryTerm,@dtmWillCallRequestedDate,
									@intWillCallPriority,@dblWillCallTotal,@strWillCallComments,@dtmWillCallCallInDate,@strWillCallUser,@ysnWillCallPrinted,@dtmWillCallDispatch,@strWillCallOrderNumber,@strWillCallContractNumber,@dtmWillCallDeliveryDate,
									@dblWillCallDeliveryQuantity,@dblWillCallDeliveryPrice,@dblWillCallDeliveryTotal,@strInvoiceDetail,@dtmSiteLastDelivery,@dblSitePreviousBurnRate,@dblSiteBurnRate,@dtmSiteOnHoldStartDate,@dtmSiteOnHoldEndDate,
									@ysnSiteHoldDDCalculations,@ysnSiteOnHold,@dblSiteLastDeliveredGal,@ysnSiteDeliveryTicketPrinted,@dblSiteDegreeDayBetweenDelivery,@intSiteNextDeliveryDegreeDay,@dblSiteLastGalsInTank,@dblSiteEstimatedPercentLeft,
									@dtmSiteLastReadingUpdate,@ysnMeterReading,@strWillCallRoute,@dtmCreatedDate,@ysnWillCallLeakCheckRequired,@dblWillCallOriginalPercentLeft,@ysnManualAdjustment,@dtmNextDeliveryDate,@dtmRunOutDate,@dtmForecastedDelivery,@strCustomerEntityNo

	WHILE @@FETCH_STATUS = 0
    BEGIN
			Declare @intUserID int = NULL
			Declare @intSiteID int = NULL
			Declare @strSalesPersonID varchar(100) =  NULL
			Declare @intWillCallDriverId int = null
			Declare @intWillCallProductId int = null
			Declare @intWillCallDeliveryTermId int = null
			Declare @intWillCallUserId int = null
			Declare @intInvoiceId int = null
			Declare @intWillCallContractId int = null
			Declare @intWillCallRouteId int = null
			Declare @intWillCallDispatchId int = null
			Declare @intCustomerId int = null

			set @intCustomerId = (select T.intCustomerID from tblEMEntity E	INNER JOIN tblARCustomer C ON C.intEntityId = E.intEntityId AND C.ysnActive = 1	INNER JOIN tblTMCustomer T ON T.intCustomerNumber = E.intEntityId where E.strEntityNo = @strCustomerEntityNo)
			set @intUserID	= (SELECT top 1 US.intEntityId FROM tblSMUserSecurity US INNER JOIN tblEMEntity E ON E.intEntityId = US.intEntityId where E.strName = @strUserName)
			set @intSiteID = (select top 1 intSiteID from tblTMSite where intSiteNumber = @intSiteNumber and intCustomerID = @intCustomerId)	
			set @strSalesPersonID =	(select top 1 a.intEntityId from tblEMEntity as a left join tblEMEntityType as b on b.intEntityId = a.intEntityId AND b.strType = 'Salesperson' WHERE b.intEntityTypeId IS NULL and a.strName = @strUserName)
			set @intWillCallDriverId =	(select top 1 a.intEntityId from tblEMEntity as a left join tblEMEntityType as b on b.intEntityId = a.intEntityId AND b.strType = 'Salesperson' WHERE b.intEntityTypeId IS NULL and a.strName = @strUserName)
			set @intWillCallProductId =	(select top 1 intItemId from tblICItem where strDescription = @strWillCallProduct) 	
			set @intWillCallDeliveryTermId = (select top 1 intTermID from tblSMTerm where strTerm = @strWillCallDeliveryTerm)
			set @intWillCallUserId = (SELECT top 1 US.intEntityId FROM tblSMUserSecurity US INNER JOIN tblEMEntity E ON E.intEntityId = US.intEntityId where US.strUserName = @strWillCallUser)
			set @intInvoiceId = (select top 1 intInvoiceId from tblARInvoice where strInvoiceNumber = @strInvoiceNumber)	
			set @intWillCallContractId = (select top 1 intContractHeaderId from tblCTContractHeader where strContractNumber = @strWillCallContractNumber)
			--set @intInvoiceDetailId	= (select top 1 intInvoiceDetailId from tblARInvoiceDetail where intInvoiceId = @intInvoiceId)
			set @intWillCallRouteId = (select intRouteId from dbo.tblLGRoute where strRouteNumber = @strWillCallRoute)
			set @intWillCallDispatchId = (select top 1 intDispatchID from tblTMDispatch where intSiteID = @intSiteID)


            IF (ISNULL(@intSiteID, '') != '' )
            BEGIN

               IF NOT EXISTS(SELECT TOP 1 1 FROM tblApiImportLogDetail WHERE guiApiImportLogId = @guiLogId AND strLogLevel = 'Error' AND intRowNo = @intRowNumber)
                BEGIN

					DECLARE @intDeliveryHistoryID INT = NULL
					select @intDeliveryHistoryID = intDeliveryHistoryID from [dbo].[tblTMDeliveryHistory] where strInvoiceNumber = @strInvoiceNumber and intSiteID = @intSiteID

					IF(@intDeliveryHistoryID IS NULL)
						BEGIN
							-- INSERT Delivery History Header
								INSERT INTO [dbo].[tblTMDeliveryHistory]
									(intConcurrencyId,
										intRowNumber,
										strInvoiceNumber,
										strBulkPlantNumber,
										dtmInvoiceDate,
										strProductDelivered,
										dblQuantityDelivered,
										intDegreeDayOnDeliveryDate,
										intDegreeDayOnLastDeliveryDate,
										dblBurnRateAfterDelivery,
										dblCalculatedBurnRate,
										ysnAdjustBurnRate,
										intElapsedDegreeDaysBetweenDeliveries,
										intElapsedDaysBetweenDeliveries,
										strSeason,
										dblWinterDailyUsageBetweenDeliveries,
										dblSummerDailyUsageBetweenDeliveries,
										dblGallonsInTankbeforeDelivery,
										dblGallonsInTankAfterDelivery,
										dblEstimatedPercentBeforeDelivery,
										dblActualPercentAfterDelivery,
										dblMeterReading,
										dblLastMeterReading,
										intUserID,
										dtmLastUpdated,
										intSiteID,
										strSalesPersonID,
										dblExtendedAmount,
										ysnForReview,
										dtmMarkForReviewDate,
										dblWillCallPercentLeft,
										dblWillCallCalculatedQuantity,
										dblWillCallDesiredQuantity,
										intWillCallDriverId,
										intWillCallProductId,
										dblWillCallPrice,
										intWillCallDeliveryTermId,
										dtmWillCallRequestedDate,
										intWillCallPriority,
										dblWillCallTotal,
										strWillCallComments,
										dtmWillCallCallInDate,
										intWillCallUserId,
										ysnWillCallPrinted,
										dtmWillCallDispatch,
										strWillCallOrderNumber,
										intWillCallContractId,
										dtmWillCallDeliveryDate,
										dblWillCallDeliveryQuantity,
										dblWillCallDeliveryPrice,
										dblWillCallDeliveryTotal,
										dtmSiteLastDelivery,
										dblSitePreviousBurnRate,
										dblSiteBurnRate,
										dtmSiteOnHoldStartDate,
										dtmSiteOnHoldEndDate,
										ysnSiteHoldDDCalculations,
										ysnSiteOnHold,
										dblSiteLastDeliveredGal,
										ysnSiteDeliveryTicketPrinted,
										dblSiteDegreeDayBetweenDelivery,
										intSiteNextDeliveryDegreeDay,
										dblSiteLastGalsInTank,
										dblSiteEstimatedPercentLeft,
										dtmSiteLastReadingUpdate,
										ysnMeterReading,
										intWillCallRouteId,
										intWillCallDispatchId,
										dtmCreatedDate,
										ysnWillCallLeakCheckRequired,
										dblWillCallOriginalPercentLeft,
										ysnManualAdjustment,
										dtmNextDeliveryDate,
										dtmRunOutDate,
										dtmForecastedDelivery,
										guiApiUniqueId)
								VALUES (1,
										@intRowNumber,
										@strInvoiceNumber,
										@strBulkPlantNumber,
										@dtmInvoiceDate,
										@strProductDelivered,
										@dblQuantityDelivered,
										@intDegreeDayOnDeliveryDate,
										@intDegreeDayOnLastDeliveryDate,
										@dblBurnRateAfterDelivery,
										@dblCalculatedBurnRate,
										@ysnAdjustBurnRate,
										@intElapsedDegreeDaysBetweenDeliveries,
										@intElapsedDaysBetweenDeliveries,
										@strSeason,
										@dblWinterDailyUsageBetweenDeliveries,
										@dblSummerDailyUsageBetweenDeliveries,
										@dblGallonsInTankbeforeDelivery,
										@dblGallonsInTankAfterDelivery,
										@dblEstimatedPercentBeforeDelivery,
										@dblActualPercentAfterDelivery,
										@dblMeterReading,
										@dblLastMeterReading,
										@intUserID,
										@dtmLastUpdated,
										@intSiteID,
										@strSalesPersonID,
										@dblExtendedAmount,
										@ysnForReview,
										@dtmMarkForReviewDate,
										@dblWillCallPercentLeft,
										@dblWillCallCalculatedQuantity,
										@dblWillCallDesiredQuantity,
										@intWillCallDriverId,
										@intWillCallProductId,
										@dblWillCallPrice,
										@intWillCallDeliveryTermId,
										@dtmWillCallRequestedDate,
										@intWillCallPriority,
										@dblWillCallTotal,
										@strWillCallComments,
										@dtmWillCallCallInDate,
										@intWillCallUserId,
										@ysnWillCallPrinted,
										@dtmWillCallDispatch,
										@strWillCallOrderNumber,
										@intWillCallContractId,
										@dtmWillCallDeliveryDate,
										@dblWillCallDeliveryQuantity,
										@dblWillCallDeliveryPrice,
										@dblWillCallDeliveryTotal,
										--@strInvoiceDetail,
										@dtmSiteLastDelivery,
										@dblSitePreviousBurnRate,
										@dblSiteBurnRate,
										@dtmSiteOnHoldStartDate,
										@dtmSiteOnHoldEndDate,
										@ysnSiteHoldDDCalculations,
										@ysnSiteOnHold,
										@dblSiteLastDeliveredGal,
										@ysnSiteDeliveryTicketPrinted,
										@dblSiteDegreeDayBetweenDelivery,
										@intSiteNextDeliveryDegreeDay,
										@dblSiteLastGalsInTank,
										@dblSiteEstimatedPercentLeft,
										@dtmSiteLastReadingUpdate,
										@ysnMeterReading,
										@intWillCallRouteId,
										@intWillCallDispatchId,
										@dtmCreatedDate,
										@ysnWillCallLeakCheckRequired,
										@dblWillCallOriginalPercentLeft,
										@ysnManualAdjustment,
										@dtmNextDeliveryDate,
										@dtmRunOutDate,
										@dtmForecastedDelivery,
										@guiApiUniqueId)

								SET @intDeliveryHistoryID = SCOPE_IDENTITY()

								Declare @intInvoiceDetailId int = null
								Declare @dblQtyShipped int = null
								Declare @dblTotal numeric(18, 6) = NULL
								Declare @dblPercentFull numeric(18, 6) = NULL

								DECLARE DataCursor2 CURSOR LOCAL FAST_FORWARD
								FOR
									select
										CS.intInvoiceDetailId,
										CS.dblQtyShipped,
										CS.dblTotal,
										CS.dblPercentFull
									from tblARInvoiceDetail as CS
									WHERE CS.intInvoiceId = @intInvoiceId 


								OPEN DataCursor2
								FETCH NEXT FROM DataCursor2 INTO  @intInvoiceDetailId,@dblQtyShipped,@dblTotal,@dblPercentFull
								WHILE @@FETCH_STATUS = 0
								BEGIN
									
										insert into [dbo].[tblTMDeliveryHistoryDetail](
											strInvoiceNumber,
											dblQuantityDelivered,
											strItemNumber,
											intDeliveryHistoryID,
											intConcurrencyId,
											dblPercentAfterDelivery,
											dblExtendedAmount,
											intInvoiceDetailId
											)
										values(
											@strInvoiceNumber,
											@dblQtyShipped,
											@strProductDelivered,
											@intDeliveryHistoryID,
											1,
											@dblPercentFull,
											@dblTotal,
											@intInvoiceDetailId
											)

									FETCH NEXT FROM DataCursor2 INTO  @intInvoiceDetailId,@dblQtyShipped,@dblTotal,@dblPercentFull
								END
								CLOSE DataCursor2
								DEALLOCATE DataCursor2



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
								-- UPDATE THE EXISTING Delivery History
								update [dbo].[tblTMDeliveryHistory] set strInvoiceNumber = @strInvoiceNumber,
																strBulkPlantNumber = @strBulkPlantNumber,
																dtmInvoiceDate = @dtmInvoiceDate,
																strProductDelivered = @strProductDelivered,
																dblQuantityDelivered = @dblQuantityDelivered,
																intDegreeDayOnDeliveryDate = @intDegreeDayOnDeliveryDate,
																intDegreeDayOnLastDeliveryDate = @intDegreeDayOnLastDeliveryDate,
																dblBurnRateAfterDelivery = @dblBurnRateAfterDelivery,
																dblCalculatedBurnRate = @dblCalculatedBurnRate,
																ysnAdjustBurnRate = @ysnAdjustBurnRate,
																intElapsedDegreeDaysBetweenDeliveries = @intElapsedDegreeDaysBetweenDeliveries,
																intElapsedDaysBetweenDeliveries = @intElapsedDaysBetweenDeliveries,
																strSeason = @strSeason,
																dblWinterDailyUsageBetweenDeliveries = @dblWinterDailyUsageBetweenDeliveries,
																dblSummerDailyUsageBetweenDeliveries = @dblSummerDailyUsageBetweenDeliveries,
																dblGallonsInTankbeforeDelivery = @dblGallonsInTankbeforeDelivery,
																dblGallonsInTankAfterDelivery = @dblGallonsInTankAfterDelivery,
																dblEstimatedPercentBeforeDelivery = @dblEstimatedPercentBeforeDelivery,
																dblActualPercentAfterDelivery = @dblActualPercentAfterDelivery,
																dblMeterReading = @dblMeterReading,
																dblLastMeterReading = @dblLastMeterReading,
																intUserID = @intUserID,
																dtmLastUpdated = @dtmLastUpdated,
																intSiteID = @intSiteID,
																strSalesPersonID = @strSalesPersonID,
																dblExtendedAmount = @dblExtendedAmount,
																ysnForReview = @ysnForReview,
																dtmMarkForReviewDate = @dtmMarkForReviewDate,
																dblWillCallPercentLeft = @dblWillCallPercentLeft,
																dblWillCallCalculatedQuantity = @dblWillCallCalculatedQuantity,
																dblWillCallDesiredQuantity = @dblWillCallDesiredQuantity,
																intWillCallDriverId = @intWillCallDriverId,
																intWillCallProductId = @intWillCallProductId,
																dblWillCallPrice = @dblWillCallPrice,
																intWillCallDeliveryTermId = @intWillCallDeliveryTermId,
																dtmWillCallRequestedDate = @dtmWillCallRequestedDate,
																intWillCallPriority = @intWillCallPriority,
																dblWillCallTotal = @dblWillCallTotal,
																strWillCallComments = @strWillCallComments,
																dtmWillCallCallInDate = @dtmWillCallCallInDate,
																intWillCallUserId = @intWillCallUserId,
																ysnWillCallPrinted = @ysnWillCallPrinted,
																dtmWillCallDispatch = @dtmWillCallDispatch,
																strWillCallOrderNumber = @strWillCallOrderNumber,
																intWillCallContractId = @intWillCallContractId,
																dtmWillCallDeliveryDate = @dtmWillCallDeliveryDate,
																dblWillCallDeliveryQuantity = @dblWillCallDeliveryQuantity,
																dblWillCallDeliveryPrice = @dblWillCallDeliveryPrice,
																dblWillCallDeliveryTotal = @dblWillCallDeliveryTotal,
																dtmSiteLastDelivery = @dtmSiteLastDelivery,
																dblSitePreviousBurnRate = @dblSitePreviousBurnRate,
																dblSiteBurnRate = @dblSiteBurnRate,
																dtmSiteOnHoldStartDate = @dtmSiteOnHoldStartDate,
																dtmSiteOnHoldEndDate = @dtmSiteOnHoldEndDate,
																ysnSiteHoldDDCalculations = @ysnSiteHoldDDCalculations,
																ysnSiteOnHold = @ysnSiteOnHold,
																dblSiteLastDeliveredGal = @dblSiteLastDeliveredGal,
																ysnSiteDeliveryTicketPrinted = @ysnSiteDeliveryTicketPrinted,
																dblSiteDegreeDayBetweenDelivery = @dblSiteDegreeDayBetweenDelivery,
																intSiteNextDeliveryDegreeDay = @intSiteNextDeliveryDegreeDay,
																dblSiteLastGalsInTank = @dblSiteLastGalsInTank,
																dblSiteEstimatedPercentLeft = @dblSiteEstimatedPercentLeft,
																dtmSiteLastReadingUpdate = @dtmSiteLastReadingUpdate,
																ysnMeterReading = @ysnMeterReading,
																intWillCallRouteId= @intWillCallRouteId,
																intWillCallDispatchId=@intWillCallDispatchId,
																dtmCreatedDate = @dtmCreatedDate,
																ysnWillCallLeakCheckRequired = @ysnWillCallLeakCheckRequired,
																dblWillCallOriginalPercentLeft = @dblWillCallOriginalPercentLeft,
																ysnManualAdjustment = @ysnManualAdjustment,
																dtmNextDeliveryDate = @dtmNextDeliveryDate,
																dtmRunOutDate = @dtmRunOutDate,
																dtmForecastedDelivery = @dtmForecastedDelivery
									where intDeliveryHistoryID = @intDeliveryHistoryID
									
									Declare @intInvoiceDetailId2 int = null
									Declare @dblQtyShipped2 int = null
									Declare @dblTotal2 numeric(18, 6) = NULL
									Declare @dblPercentFull2 numeric(18, 6) = NULL

									DECLARE DataCursor3 CURSOR LOCAL FAST_FORWARD
										FOR
											select
												CS.intInvoiceDetailId,
												CS.dblQtyShipped,
												CS.dblTotal,
												CS.dblPercentFull
											from tblARInvoiceDetail as CS
											WHERE CS.intInvoiceId = @intInvoiceId 


										OPEN DataCursor3
										FETCH NEXT FROM DataCursor3 INTO  @intInvoiceDetailId2,@dblQtyShipped2,@dblTotal2,@dblPercentFull2
										WHILE @@FETCH_STATUS = 0
										BEGIN
									
										update [dbo].[tblTMDeliveryHistoryDetail]
												set strInvoiceNumber = @strInvoiceNumber,
												dblQuantityDelivered = @dblQtyShipped2,
												strItemNumber = @strProductDelivered,
												intDeliveryHistoryID = @intDeliveryHistoryID,
												dblPercentAfterDelivery = @dblPercentFull2,
												dblExtendedAmount = @dblTotal2,
												intInvoiceDetailId = @intInvoiceDetailId2
											where intInvoiceDetailId = @intInvoiceDetailId2

											FETCH NEXT FROM DataCursor3 INTO  @intInvoiceDetailId2,@dblQtyShipped,@dblTotal,@dblPercentFull
										END
										CLOSE DataCursor3
										DEALLOCATE DataCursor3

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
						, strMessage = ', Delivery History' +  ' is already exist'
                END
			END
		FETCH NEXT FROM DataCursor INTO @intRowNumber,@strInvoiceNumber,@strBulkPlantNumber,@dtmInvoiceDate,@strProductDelivered,@dblQuantityDelivered,@intDegreeDayOnDeliveryDate,@intDegreeDayOnLastDeliveryDate,@dblBurnRateAfterDelivery,@dblCalculatedBurnRate,
									@ysnAdjustBurnRate,@intElapsedDegreeDaysBetweenDeliveries,@intElapsedDaysBetweenDeliveries,@strSeason,@dblWinterDailyUsageBetweenDeliveries,@dblSummerDailyUsageBetweenDeliveries,@dblGallonsInTankbeforeDelivery,
									@dblGallonsInTankAfterDelivery,@dblEstimatedPercentBeforeDelivery,@dblActualPercentAfterDelivery,@dblMeterReading,@dblLastMeterReading,@strUserName,@dtmLastUpdated,@intSiteNumber,@strSalespersonName,@dblExtendedAmount,
									@ysnForReview,@dtmMarkForReviewDate,@dblWillCallPercentLeft,@dblWillCallCalculatedQuantity,@dblWillCallDesiredQuantity,@strDriverName,@strWillCallProduct,@dblWillCallPrice,@strWillCallDeliveryTerm,@dtmWillCallRequestedDate,
									@intWillCallPriority,@dblWillCallTotal,@strWillCallComments,@dtmWillCallCallInDate,@strWillCallUser,@ysnWillCallPrinted,@dtmWillCallDispatch,@strWillCallOrderNumber,@strWillCallContractNumber,@dtmWillCallDeliveryDate,
									@dblWillCallDeliveryQuantity,@dblWillCallDeliveryPrice,@dblWillCallDeliveryTotal,@strInvoiceDetail,@dtmSiteLastDelivery,@dblSitePreviousBurnRate,@dblSiteBurnRate,@dtmSiteOnHoldStartDate,@dtmSiteOnHoldEndDate,
									@ysnSiteHoldDDCalculations,@ysnSiteOnHold,@dblSiteLastDeliveredGal,@ysnSiteDeliveryTicketPrinted,@dblSiteDegreeDayBetweenDelivery,@intSiteNextDeliveryDegreeDay,@dblSiteLastGalsInTank,@dblSiteEstimatedPercentLeft,
									@dtmSiteLastReadingUpdate,@ysnMeterReading,@strWillCallRoute,@dtmCreatedDate,@ysnWillCallLeakCheckRequired,@dblWillCallOriginalPercentLeft,@ysnManualAdjustment,@dtmNextDeliveryDate,@dtmRunOutDate,@dtmForecastedDelivery,@strCustomerEntityNo
	END
	CLOSE DataCursor
	DEALLOCATE DataCursor
 
END