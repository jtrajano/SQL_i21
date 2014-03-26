IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMSite]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillMethodId' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillMethodID' AND OBJECT_ID = OBJECT_ID(N'tblTMSite'))
    BEGIN
        EXEC sp_rename 'tblTMSite.intFillMethodID', 'intFillMethodId' , 'COLUMN'
    END
END


IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDevice]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMeterTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intMeterTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intMeterTypeID', 'intMeterTypeId' , 'COLUMN'
    END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDevice]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intInventoryStatusTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intInventoryStatusTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intInventoryStatusTypeID', 'intInventoryStatusTypeId' , 'COLUMN'
    END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDevice]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDeviceTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intDeviceTypeID', 'intDeviceTypeId' , 'COLUMN'
    END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDevice]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intTankTypeID', 'intTankTypeId' , 'COLUMN'
    END
END


IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDevice]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRegulatorTypeId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRegulatorTypeID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intRegulatorTypeID', 'intRegulatorTypeId' , 'COLUMN'
    END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMDevice]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLeaseId' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intLeaseID' AND OBJECT_ID = OBJECT_ID(N'tblTMDevice'))
    BEGIN
        EXEC sp_rename 'tblTMDevice.intLeaseID', 'intLeaseId' , 'COLUMN'
    END
END

