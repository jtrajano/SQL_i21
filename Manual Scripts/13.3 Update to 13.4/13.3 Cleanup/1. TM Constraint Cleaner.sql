--select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE = 'FOREIGN KEY'
--select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME like 'tblTM%'

-- TM Constraint Cleaner


declare @TMRec int
select @TMRec = 
( select count(*) from tblTMCOBOLREADSiteLink)
+ ( select count(*) from tblTMCOBOLREADSite)
+ ( select count(*) from tblTMCOBOLLeaseBilling)
+ ( select count(*) from tblTMClock)
+ ( select count(*) from tblTMDeliveryMethod)
+ ( select count(*) from tblTMDeviceType)
+ ( select count(*) from tblTMInventoryStatusType)
+ ( select count(*) from tblTMHoldReason)
+ ( select count(*) from tblTMFillMethod)
+ ( select count(*) from tblTMFillGroup)
+ ( select count(*) from tblTMApplianceType)
+ ( select count(*) from tblTMEventType)
+ ( select count(*) from tblTMWorkToDoItem)
+ ( select count(*) from tblTMDegreeDayReading)
+ ( select count(*) from tblTMEventAutomation)
+ ( select count(*) from tblTMEvent)
+ ( select count(*) from tblTMSite)
+ ( select count(*) from tblTMLease)
+ ( select count(*) from tblTMSiteLink)
+ ( select count(*) from tblTMSiteJulianCalendar)
+ ( select count(*) from tblTMWorkOrder)
+ ( select count(*) from tblTMDeliverySchedule)
+ ( select count(*) from tblTMDispatch)
+ ( select count(*) from tblTMDevice)
+ ( select count(*) from tblTMDeliveryHistory)
+ ( select count(*) from tblTMWorkToDo)
+ ( select count(*) from tblTMDeliveryHistoryDetail)
+ ( select count(*) from tblTMJulianCalendarDelivery)
+ ( select count(*) from tblTMSiteDevice)
+ ( select count(*) from tblTMSiteDeviceLink)
+ ( select count(*) from tblTMDeployedStatus)
+ ( select count(*) from tblTMWorkStatusType)
+ ( select count(*) from tblTMWorkCloseReason)
+ ( select count(*) from tblTMTankType)
+ ( select count(*) from tblTMTankTownship)
+ ( select count(*) from tblTMTankMeasurement)
+ ( select count(*) from tblTMSyncPurged)
+ ( select count(*) from tblTMSyncOutOfRange)
+ ( select count(*) from tblTMSyncFailed)
+ ( select count(*) from tblTMRoute)
+ ( select count(*) from tblTMRegulatorType)
+ ( select count(*) from tblTMPreferenceCompany)
+ ( select count(*) from tblTMPossessionType)
+ ( select count(*) from tblTMMeterType)
+ ( select count(*) from tblTMLeaseCode)
+ ( select count(*) from tblTMCustomer)
+ ( select count(*) from tblTMCOBOLWRITE)

select [TM Record Count] = @TMRec

if (@TMRec = 0)
BEGIN
	--get all GL constraints and drop it all
	select * into #tmpConstraints from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE = 'FOREIGN KEY'
	and TABLE_NAME in (select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_NAME like 'tblTM%')

	declare @tableName nvarchar(100)
	declare @constraintName nvarchar(100)

	while exists(select top 1 1 from #tmpConstraints)
	begin
		select top 1 @tableName= TABLE_NAME, @constraintName = CONSTRAINT_NAME from #tmpConstraints
		exec ('alter table ' +  @tableName + ' drop constraint [' + @constraintName + ']')
		delete from #tmpConstraints where CONSTRAINT_NAME = @constraintName
	end

	drop table #tmpConstraints
END
ELSE
	BEGIN
		-- raise error and tell the installer that we cannot just drop the tables
		RAISERROR('TM has some records.', 16, 1)
	END
