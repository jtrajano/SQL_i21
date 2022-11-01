CREATE TABLE tblVRChevronExportRebateLogDetail (
    guiId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    guiExportLogId UNIQUEIDENTIFIER NOT NULL,
    intRebateId INT,
    intVendorSetupId INT,
    dtmExportDate DATETIME NULL,
    strMessage NVARCHAR(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    strMarketerName NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    strMarketerRebateNumber NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    strC2RebateAccountNumber NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    dtmDeliveryDate DATETIME NULL,
    strProductCode NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    strPackageCode NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    dblRebateRate NUMERIC(38, 20) NULL,
    dblDeliveredQuantity NUMERIC(38, 20) NULL
)

GO
