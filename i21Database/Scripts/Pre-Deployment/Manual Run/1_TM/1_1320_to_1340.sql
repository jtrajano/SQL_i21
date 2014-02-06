--tblTMClock
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMClock]') AND type in (N'U')) 
BEGIN
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblAccumulatedWinterClose' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblAccDDWinterClose' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblAccDDWinterClose', 'dblAccumulatedWinterClose' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblJanuaryDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD01' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD01', 'dblJanuaryDailyAverage' , 'COLUMN'
    END
         
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblFebruaryDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD02' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD02', 'dblFebruaryDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblMarchDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD03' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD03', 'dblMarchDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblAprilDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD04' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD04', 'dblAprilDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblMayDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD05' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD05', 'dblMayDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblJuneDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD06' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD06', 'dblJuneDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblJulyDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD07' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD07', 'dblJulyDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblAugustDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD08' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD08', 'dblAugustDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblSeptemberDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD09' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD09', 'dblSeptemberDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblOctoberDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD10' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD10', 'dblOctoberDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblNovemberDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDailyAverageDD11' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD11', 'dblNovemberDailyAverage' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDecemberDailyAverage' AND OBJECT_ID = OBJECT_ID(N'tblTMClock')) AND EXISTS (SELECT * FROM sys.columns WHERE NAME  = N'dblDailyAverageDD12' AND OBJECT_ID = OBJECT_ID(N'tblTMClock'))
    BEGIN
        EXEC sp_rename 'tblTMClock.dblDailyAverageDD12', 'dblDecemberDailyAverage' , 'COLUMN'
    END
     
END
GO
 
-- tblTMDegreeDay
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDegreeDayReading]') AND type in (N'U')) AND EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDDReading]') AND type in (N'U'))
BEGIN
    EXEC sp_rename 'tblTMDDReading', 'tblTMDegreeDayReading'
END
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDegreeDayReading]') AND type in (N'U')) 
BEGIN
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDegreeDayReadingID' AND OBJECT_ID = OBJECT_ID(N'tblTMDegreeDayReading')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDDReadingID' AND OBJECT_ID = OBJECT_ID(N'tblTMDegreeDayReading'))
    BEGIN
        EXEC sp_rename 'tblTMDegreeDayReading.intDDReadingID', 'intDegreeDayReadingID' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intClockLocationID' AND OBJECT_ID = OBJECT_ID(N'tblTMDegreeDayReading')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDDClockLocationID' AND OBJECT_ID = OBJECT_ID(N'tblTMDegreeDayReading'))
    BEGIN
        EXEC sp_rename 'tblTMDegreeDayReading.intDDClockLocationID', 'intClockLocationID' , 'COLUMN'
    END
     
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblAccumulatedDegreeDay' AND OBJECT_ID = OBJECT_ID(N'tblTMDegreeDayReading')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblAccumulatedDD' AND OBJECT_ID = OBJECT_ID(N'tblTMDegreeDayReading'))
    BEGIN
        EXEC sp_rename 'tblTMDegreeDayReading.dblAccumulatedDD', 'dblAccumulatedDegreeDay' , 'COLUMN'
    END
END
GO
-- tblTMDeliveryHistoryDetail
--ALTER TABLE tblTMDeliveryHistoryDetail  
--ALTER COLUMN dblPercentAfterDelivery NUMERIC(18,6) NOT NULL
-- tblTMDispatch
IF EXISTS (SELECT TOP 1 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblTMDispatch_tblTMSite]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblTMDispatch]')) 
BEGIN
    ALTER TABLE [dbo].[tblTMDispatch] 
    DROP CONSTRAINT [FK_tblTMDispatch_tblTMSite]
END
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblTMDispatch_tblTMSite1]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblTMDispatch]'))
BEGIN
    ALTER TABLE [dbo].[tblTMDispatch] WITH CHECK ADD  CONSTRAINT [FK_tblTMDispatch_tblTMSite1] FOREIGN KEY([intSiteID])
    REFERENCES [dbo].[tblTMSite] ([intSiteID])
END
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblTMDispatch_tblTMSite1]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblTMDispatch]'))
BEGIN
    ALTER TABLE [dbo].[tblTMDispatch] CHECK CONSTRAINT [FK_tblTMDispatch_tblTMSite1]
END
GO
-- tblTMEvent
IF EXISTS (SELECT TOP 1 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblTMEvent_tblTMDevice]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblTMEvent]')) 
BEGIN
    ALTER TABLE [dbo].[tblTMEvent]
    DROP CONSTRAINT [FK_tblTMEvent_tblTMDevice]
END
GO
 
-- tblTMEventType
IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnDefault' AND OBJECT_ID = OBJECT_ID(N'tblTMEventType')) 
BEGIN
    ALTER TABLE [dbo].[tblTMEventType]
    ALTER COLUMN ysnDefault bit NOT NULL
END
GO
 
-- tblTMSite
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intClockID' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intClockLocno' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
BEGIN
    EXEC sp_rename 'tblTMSite.intClockLocno', 'intClockID' , 'COLUMN'
END
GO
     
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDegreeDayBetweenDelivery' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblDDBetweenDlvry' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
BEGIN
    EXEC sp_rename 'tblTMSite.dblDDBetweenDlvry', 'dblDegreeDayBetweenDelivery' , 'COLUMN'
END
GO
     
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnPrintDeliveryTicket' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnPrintDlvryTicket' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
BEGIN
    EXEC sp_rename 'tblTMSite.ysnPrintDlvryTicket', 'ysnPrintDeliveryTicket' , 'COLUMN'
END
GO
-- tblTMSyncOutOfRange
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSyncOutOfRangeID' AND OBJECT_ID = OBJECT_ID(N'tblTMSyncOutOfRange')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSyncOutOfRange' AND OBJECT_ID = OBJECT_ID(N'tblTMSyncOutOfRange'))
BEGIN
    EXEC sp_rename 'tblTMSyncOutOfRange.intSyncOutOfRange', 'intSyncOutOfRangeID', 'COLUMN'
END
GO
-- tblTMWork
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMWorkOrder]') AND type in (N'U')) AND EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMWork]') AND type in (N'U'))
BEGIN
    EXEC sp_rename 'tblTMWork', 'tblTMWorkOrder'
END
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intWorkStatusTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMWorkOrder')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intWorkStatusID' AND OBJECT_ID = OBJECT_ID(N'tblTMWorkOrder'))
BEGIN
    EXEC sp_rename 'tblTMWorkOrder.intWorkStatusID', 'intWorkStatusTypeID', 'COLUMN'
END
GO
 
---Update data in tblTMDispatch
    UPDATE tblTMDispatch
    SET intSiteID = intDispatchID
    WHERE isnull(intSiteID, '') = ''
GO
 
 
---Update data in tblTMApplianceType
UPDATE tblTMApplianceType
SET ysnDefault = 0
WHERE ysnDefault IS NULL 
 
GO
-- BEGIN DROP TRASH VIEWS
    /****** Object:  View [dbo].[vwCSSearch]     ******/
    IF OBJECT_ID(N'dbo.vwCSSearch', N'V') IS NOT NULL
    BEGIN
        DROP VIEW dbo.vwCSSearch
    END
    /****** Object:  View [dbo].[vyu_DeliveryFillReport]     ******/
    -- will be recreated on Reports create views 
    IF OBJECT_ID(N'dbo.vyu_DeliveryFillReport', N'V') IS NOT NULL
    BEGIN
        DROP VIEW dbo.vyu_DeliveryFillReport
    END
--END DROP TRASH VIEWS
GO

