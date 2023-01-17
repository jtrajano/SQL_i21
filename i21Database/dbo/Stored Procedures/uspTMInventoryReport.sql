CREATE PROCEDURE [dbo].[uspTMInventoryReport]
AS
BEGIN

    DECLARE @intSiteId int
	
	IF  OBJECT_ID('tempdb..#tempInventoryReport') IS NOT NULL
	DROP TABLE #tempInventoryReport

	CREATE TABLE #tempInventoryReport(
		[Id] INT IDENTITY(1, 1) primary key 
		,[strCustomerNumber] varchar(200)
        ,[strCustomerName] varchar(200)
        ,[strUserName] varchar(200)
        ,[intSiteNumber] int
        ,[strProduct] varchar(200)
        ,[dtmLastInventoryTime] DATETIME
        ,[dblGrossVolume] DECIMAL(18,6)
        ,[dblNetVolume] DECIMAL(18,6)
        ,[dblUllage] DECIMAL(18,6)
        ,[dblTotalCapacity] DECIMAL(18,6)
        ,[dblFullPercent] DECIMAL(18,6)
        ,[dblWaterHeight] DECIMAL(18,6)
	);

	DECLARE DataCursor CURSOR LOCAL FAST_FORWARD
    FOR

   		SELECT distinct B.intSiteId FROM  tblTMTankMonitor B
		

    OPEN DataCursor
	FETCH NEXT FROM DataCursor INTO @intSiteId
    WHILE @@FETCH_STATUS = 0
    BEGIN
		DECLARE @strCustomerName varchar(200)
		DECLARE @intSiteNumber int
		DECLARE @strProduct varchar(200)
		DECLARE @dtmLastInventoryTime DATETIME
		DECLARE @dblGrossVolume DECIMAL(18,6)
		DECLARE @dblNetVolume DECIMAL(18,6)
		DECLARE @dblUllage DECIMAL(18,6)
		DECLARE @dblTotalCapacity DECIMAL(18,6)
		DECLARE @dblFullPercent DECIMAL(18,6)
		DECLARE @dblWaterHeight DECIMAL(18,6)

		SELECT distinct
			 @strCustomerName = C.strName
			,@intSiteNumber = A.intSiteNumber
			,@strProduct = T.strDescription
		FROM tblTMSite A
		INNER JOIN tblTMCustomer B	
			ON A.intCustomerID = B.intCustomerID
		INNER JOIN tblEMEntity C
			ON B.intCustomerNumber = C.intEntityId
		LEFT JOIN tblICItem T
			ON A.intProduct = T.intItemId 
		INNER JOIN tblTMTankMonitor TM
			ON TM.intSiteId = A.intSiteID
		where TM.intSiteId = @intSiteId

		SELECT top 1 @dtmLastInventoryTime = TM.dtmDateTime FROM tblTMSite A INNER JOIN tblTMTankMonitor TM ON TM.intSiteId = A.intSiteID where TM.intSiteId = @intSiteId order by TM.intTankMonitorId desc
		SELECT @dblGrossVolume = sum(TM.dblFuelVolume) FROM tblTMSite A INNER JOIN tblTMTankMonitor TM ON TM.intSiteId = A.intSiteID where TM.intSiteId = @intSiteId 
		SELECT @dblNetVolume = sum(TM.dblTempCompensatedVolume) FROM tblTMSite A INNER JOIN tblTMTankMonitor TM ON TM.intSiteId = A.intSiteID where TM.intSiteId = @intSiteId 
		SELECT @dblUllage = sum(TM.dblUllage) FROM tblTMSite A INNER JOIN tblTMTankMonitor TM ON TM.intSiteId = A.intSiteID where TM.intSiteId = @intSiteId 
		SELECT top 1 @dblTotalCapacity = A.dblTotalCapacity FROM tblTMSite A INNER JOIN tblTMTankMonitor TM ON TM.intSiteId = A.intSiteID where TM.intSiteId = @intSiteId 

		--SELECT (TM.dblFuelVolume) FROM tblTMSite A INNER JOIN tblTMTankMonitor TM ON TM.intSiteId = A.intSiteID where TM.intSiteId = @intSiteId

		SET @dblFullPercent = CASE WHEN @dblTotalCapacity = 0 THEN @dblGrossVolume ELSE @dblGrossVolume/@dblTotalCapacity END
	
		SELECT @dblWaterHeight = sum(TM.dblWaterHeight) FROM tblTMSite A INNER JOIN tblTMTankMonitor TM ON TM.intSiteId = A.intSiteID where TM.intSiteId = @intSiteId 
		
		INSERT INTO #tempInventoryReport
					(strCustomerName,intSiteNumber,strProduct,dtmLastInventoryTime,dblGrossVolume,dblNetVolume,dblUllage,dblTotalCapacity,dblFullPercent,dblWaterHeight)VALUES
					(@strCustomerName,@intSiteNumber,@strProduct,@dtmLastInventoryTime,@dblGrossVolume,@dblNetVolume,@dblUllage,@dblTotalCapacity,@dblFullPercent,@dblWaterHeight)

	 FETCH NEXT FROM DataCursor INTO @intSiteId
    END
    CLOSE DataCursor
	DEALLOCATE DataCursor

	select * from #tempInventoryReport
END