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

