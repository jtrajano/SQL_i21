
PRINT N'BEGIN Renaming of columns in tblSMSite'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMSite]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillMethodId' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillMethodID' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
    BEGIN
        EXEC sp_rename 'tblTMSite.intFillMethodID', 'intFillMethodId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRouteId' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRouteID' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
    BEGIN
        EXEC sp_rename 'tblTMSite.intRouteID', 'intRouteId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strRouteId' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strRouteID' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
    BEGIN
        EXEC sp_rename 'tblTMSite.strRouteID', 'strRouteId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankTownshipId' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankTownshipID' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
    BEGIN
        EXEC sp_rename 'tblTMSite.intTankTownshipID', 'intTankTownshipId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillGroupId' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillGroupID' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
    BEGIN
        EXEC sp_rename 'tblTMSite.intFillGroupID', 'intFillGroupId' , 'COLUMN'
    END

	/*update null data*/
	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnPrintARBalance' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) 
    BEGIN
        UPDATE tblTMSite SET ysnPrintARBalance = 0 
		WHERE ysnPrintARBalance IS NULL
    END

	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnPrintDeliveryTicket' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) 
    BEGIN
        UPDATE tblTMSite SET ysnPrintDeliveryTicket = 0 
		WHERE ysnPrintDeliveryTicket IS NULL
    END

	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnDeliveryTicketPrinted' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) 
    BEGIN
        UPDATE tblTMSite SET ysnDeliveryTicketPrinted = 0 
		WHERE ysnDeliveryTicketPrinted IS NULL
    END

END
GO
PRINT N'END Renaming of columns in tblSMSite'
GO

PRINT N'BEGIN Renaming of columns in tblTMDevice'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDevice]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRegulatorTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRegulatorTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intRegulatorTypeID', 'intRegulatorTypeId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLeaseId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLeaseID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intLeaseID', 'intLeaseId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblTankSize' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankSize' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intTankSize', 'dblTankSize' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblTankCapacity' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankCapacity' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intTankCapacity', 'dblTankCapacity' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intTankTypeID', 'intTankTypeId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intDeviceTypeID', 'intDeviceTypeId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intInventoryStatusTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intInventoryStatusTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intInventoryStatusTypeID', 'intInventoryStatusTypeId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMeterTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMeterTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intMeterTypeID', 'intMeterTypeId' , 'COLUMN'
    END
END
GO

PRINT N'END Renaming of columns in tblTMDevice'
GO



PRINT N'BEGIN Renaming of columns in tblTMLease'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMLease]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLeaseCodeId' AND OBJECT_ID = OBJECT_ID(N'tblTMLease')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLeaseCodeID' AND OBJECT_ID = OBJECT_ID(N'tblTMLease'))
    BEGIN
        EXEC sp_rename 'tblTMLease.intLeaseCodeID', 'intLeaseCodeId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intBillToCustomerId' AND OBJECT_ID = OBJECT_ID(N'tblTMLease')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intBillToCustomerID' AND OBJECT_ID = OBJECT_ID(N'tblTMLease'))
    BEGIN
        EXEC sp_rename 'tblTMLease.intBillToCustomerID', 'intBillToCustomerId' , 'COLUMN'
    END
END
GO
PRINT N'END Renaming of columns in tblTMLease'
GO



PRINT N'BEGIN Renaming of columns in tblTMEvent'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMEvent]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceId' AND OBJECT_ID = OBJECT_ID(N'tblTMEvent')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceID' AND OBJECT_ID = OBJECT_ID(N'tblTMEvent'))
    BEGIN
        EXEC sp_rename 'tblTMEvent.intDeviceID', 'intDeviceId' , 'COLUMN'
    END
END
GO
PRINT N'END Renaming of columns in tblTMEvent'
GO


PRINT N'BEGIN Renaming of columns in tblTMSiteDevice'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMSiteDevice]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceId' AND OBJECT_ID = OBJECT_ID(N'tblTMSiteDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceID' AND OBJECT_ID = OBJECT_ID(N'tblTMSiteDevice'))
    BEGIN
        EXEC sp_rename 'tblTMSiteDevice.intDeviceID', 'intDeviceId' , 'COLUMN'
    END
END
GO
PRINT N'BEGIN Renaming of columns in tblTMSiteDevice'
GO



PRINT N'BEGIN Renaming of columns in tblTMRoute'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMRoute]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strRouteId' AND OBJECT_ID = OBJECT_ID(N'tblTMRoute')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strRouteID' AND OBJECT_ID = OBJECT_ID(N'tblTMRoute'))
    BEGIN
        EXEC sp_rename 'tblTMRoute.strRouteID', 'strRouteId' , 'COLUMN'
    END
END
GO
PRINT N'END Renaming of columns in tblTMRoute'
GO

PRINT N'BEGIN Renaming of columns in tblTMFillMethod'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMFillMethod]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillMethodId' AND OBJECT_ID = OBJECT_ID(N'tblTMFillMethod')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillMethodID' AND OBJECT_ID = OBJECT_ID(N'tblTMFillMethod'))
    BEGIN
        EXEC sp_rename 'tblTMFillMethod.intFillMethodID', 'intFillMethodId' , 'COLUMN'
    END
END
GO
PRINT N'BEGIN Renaming of columns in tblTMFillMethod'
GO

