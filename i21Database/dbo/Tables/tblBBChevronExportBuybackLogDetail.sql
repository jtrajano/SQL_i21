CREATE TABLE tblBBChevronExportBuybackLogDetail (
    guiId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    guiExportLogId UNIQUEIDENTIFIER NOT NULL,
    intRebateId INT,
    intVendorSetupId INT,
    intProgramId INT,
    dtmExportDate DATETIME NULL,
    strMessage NVARCHAR(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    strVendorName NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    strVendorProgram NVARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)

GO