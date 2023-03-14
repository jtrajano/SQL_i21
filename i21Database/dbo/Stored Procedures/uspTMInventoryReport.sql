CREATE PROCEDURE [dbo].[uspTMInventoryReport]
AS
BEGIN

    DECLARE @intSiteId int
	
	IF  OBJECT_ID('tempdb..#tempInventoryReport') IS NOT NULL
	DROP TABLE #tempInventoryReport

	CREATE TABLE #tempInventoryReport(
		[Id] INT IDENTITY(1, 1) primary key 
		,[dblFullPercent] varchar(50)
		--,[dblFullPercent] DECIMAL(18,1)
        ,[strLocation] varchar(200)
        ,[strSiteNumber] varchar(50)
        ,[strProduct] varchar(200)
        ,[dtmLastInventoryTime] DATETIME
        ,[dblGrossVolume] DECIMAL(18,6)
        ,[dblNetVolume] DECIMAL(18,6)
        ,[dblUllage] DECIMAL(18,6)
        ,[dblTotalCapacity] DECIMAL(18,6)
        ,[dblWaterHeight] DECIMAL(18,6)
	);

	DECLARE DataCursor CURSOR LOCAL FAST_FORWARD
    FOR

   		SELECT distinct B.intSiteId FROM  tblTMTankMonitor B
		

    OPEN DataCursor
	FETCH NEXT FROM DataCursor INTO @intSiteId
    WHILE @@FETCH_STATUS = 0
    BEGIN

		DECLARE @dblFullPercent DECIMAL(18,1)
		DECLARE @strLocationName varchar(200)
		DECLARE @strSiteNumber varchar(200)
		DECLARE @strProduct varchar(200)
		DECLARE @dtmLastInventoryTime DATETIME
		DECLARE @dblGrossVolume DECIMAL(18,6)
		DECLARE @dblNetVolume DECIMAL(18,6)
		DECLARE @dblUllage DECIMAL(18,6)
		DECLARE @dblTotalCapacity DECIMAL(18,6)
		DECLARE @dblWaterHeight DECIMAL(18,6)

		SELECT distinct
			@strSiteNumber = '0000' + CAST(A.intSiteNumber AS varchar(10)) 
			,@strProduct = T.strItemNo
			,@strLocationName = location.strLocationName
		FROM tblTMSite A
		INNER JOIN tblTMCustomer B	
			ON A.intCustomerID = B.intCustomerID
		INNER JOIN tblEMEntity C
			ON B.intCustomerNumber = C.intEntityId
		LEFT JOIN tblICItem T
			ON A.intProduct = T.intItemId 
		INNER JOIN tblTMTankMonitor TM
			ON TM.intSiteId = A.intSiteID
		JOIN tblSMCompanyLocation location ON location.intCompanyLocationId = A.intLocationId
		where TM.intSiteId = @intSiteId

		SELECT top 1 @dtmLastInventoryTime = TM.dtmDateTime FROM tblTMSite A INNER JOIN tblTMTankReading TM ON TM.intSiteId = A.intSiteID where TM.intSiteId = @intSiteId order by TM.intTankReadingId desc
		SELECT top 1 @dblGrossVolume = TM.dblFuelVolume FROM tblTMSite A INNER JOIN tblTMTankReading TM ON TM.intSiteId = A.intSiteID where TM.intSiteId = @intSiteId order by TM.intTankReadingId desc
		SELECT top 1 @dblNetVolume = TM.dblTempCompensatedVolume FROM tblTMSite A INNER JOIN tblTMTankReading TM ON TM.intSiteId = A.intSiteID where TM.intSiteId = @intSiteId order by TM.intTankReadingId desc
		SELECT top 1 @dblUllage = TM.dblUllage FROM tblTMSite A INNER JOIN tblTMTankReading TM ON TM.intSiteId = A.intSiteID where TM.intSiteId = @intSiteId order by TM.intTankReadingId desc
		SELECT top 1 @dblTotalCapacity = A.dblTotalCapacity FROM tblTMSite A INNER JOIN tblTMTankReading TM ON TM.intSiteId = A.intSiteID where TM.intSiteId = @intSiteId order by TM.intTankReadingId desc

		--SELECT (TM.dblFuelVolume) FROM tblTMSite A INNER JOIN tblTMTankMonitor TM ON TM.intSiteId = A.intSiteID where TM.intSiteId = @intSiteId

		SET @dblFullPercent = CASE WHEN @dblTotalCapacity = 0 THEN @dblGrossVolume ELSE @dblGrossVolume/@dblTotalCapacity END
	
		SELECT @dblWaterHeight = TM.dblWaterHeight FROM tblTMSite A INNER JOIN tblTMTankReading TM ON TM.intSiteId = A.intSiteID where TM.intSiteId = @intSiteId order by TM.intTankReadingId desc
		print @strSiteNumber
		INSERT INTO #tempInventoryReport
					(dblFullPercent,strLocation,strSiteNumber,strProduct,dtmLastInventoryTime,dblGrossVolume,dblNetVolume,dblUllage,dblTotalCapacity,dblWaterHeight)VALUES
					(CAST(@dblFullPercent AS varchar),@strLocationName,@strSiteNumber,@strProduct,@dtmLastInventoryTime,@dblGrossVolume,@dblNetVolume,@dblUllage,@dblTotalCapacity,@dblWaterHeight)

	 FETCH NEXT FROM DataCursor INTO @intSiteId
    END
    CLOSE DataCursor
	DEALLOCATE DataCursor

	select * from #tempInventoryReport
END