CREATE TABLE [dbo].[tblTMCOBOLLeaseBilling] (
    [strConsumptionSiteCustomerNo] CHAR (10)       NOT NULL,
    [strBillToCustomerNo]          CHAR (10)       NOT NULL,
    [strSiteNumber]                CHAR (4)        NOT NULL,
    [strDeviceSerialNumber]        CHAR (10)       NOT NULL,
    [strBatchNumber]               NUMERIC (3)     NULL,
    [intPostDate]                  NUMERIC (8)     NULL,
    [strLocationNumber]            CHAR (3)        NULL,
    [strItemNumber]                CHAR (13)       NULL,
    [dblTotalQty]                  NUMERIC (13, 4) NULL,
    [dblLeaseAmount]               NUMERIC (11, 2) NULL,
    [strConsolidateDevice]         CHAR (1)        NULL,
    [intDeviceID]                  NUMERIC (8)     NULL,
    [strInvoiceNumber]             CHAR (8)        NULL,
    [strStatus]                    CHAR (50)       NULL,
    [dblBillAmount]                NUMERIC (11, 2) CONSTRAINT [DF_tblTMCOBOLLeaseBilling_dblBillAmount] DEFAULT ((0)) NULL,
    [strSiteTaxable]               CHAR (1)        NULL,
    [strSiteState]                 CHAR (2)        NULL,
    [strSiteLocale1]               CHAR (3)        NULL,
    [strSiteLocale2]               CHAR (3)        NULL,
    CONSTRAINT [PK_tblTMCOBOLLeaseBilling] PRIMARY KEY CLUSTERED ([strConsumptionSiteCustomerNo] ASC, [strBillToCustomerNo] ASC, [strSiteNumber] ASC, [strDeviceSerialNumber] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Consumption Site Customer Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'strConsumptionSiteCustomerNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bill to Customer Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'strBillToCustomerNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'strSiteNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Device Serial Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'strDeviceSerialNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Batch Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'strBatchNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Post Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'intPostDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'strLocationNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'strItemNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'dblTotalQty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lease Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'dblLeaseAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Consolidate Device Option (Y/N)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'strConsolidateDevice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Device ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'intDeviceID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'strInvoiceNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'strStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bill Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'dblBillAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Taxable Option (Y/N)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'strSiteTaxable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'strSiteState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Locale 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'strSiteLocale1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Locale 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMCOBOLLeaseBilling',
    @level2type = N'COLUMN',
    @level2name = N'strSiteLocale2'