CREATE TABLE [dbo].[tblTMTankReconciliation] (
    [intTankReconciliationId]                   INT             IDENTITY (1, 1) NOT NULL,
    [strReportName]                             NVARCHAR (100)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dtmReportProducedOn]                       DATETIME        NOT NULL,
    [strConsumptionSiteFilter]                  NVARCHAR (100)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strStoresIncluded]                         NVARCHAR (1000) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strStoresIncludedDescription]              NVARCHAR (1000) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strConsumptionSitesIncluded]               NVARCHAR (1000) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strConsumptionSitesIncludedDescription]    NVARCHAR (1000) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dtmDateFrom]                               DATETIME        NOT NULL,
    [dtmDateTo]                                 DATETIME        NOT NULL,
    [intConcurrencyId]                          INT             DEFAULT 1 NOT NULL,

    CONSTRAINT [PK_tblTMTankReconciliation] PRIMARY KEY CLUSTERED ([intTankReconciliationId] ASC)
);
GO