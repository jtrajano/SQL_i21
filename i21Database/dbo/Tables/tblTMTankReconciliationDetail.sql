CREATE TABLE [dbo].[tblTMTankReconciliationDetail] (
    [intTankReconciliationDetailId]     INT             IDENTITY (1, 1) NOT NULL,
    [intTankReconciliationId]           INT             NOT NULL, 
    [strTankNumber]                     NVARCHAR (1000) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strFuelGradeDescription]           NVARCHAR (1000) COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dtmDate]                           DATETIME        NOT NULL,
    [dblStartVolume]                    NUMERIC (18, 6) DEFAULT 0 NOT NULL,
    [dblDeliveries]                     NUMERIC (18, 6) DEFAULT 0 NOT NULL,
    [dblSales]                          NUMERIC (18, 6) DEFAULT 0 NOT NULL,
    [dblCalculatedInventory]            AS (dblStartVolume + dblDeliveries - dblSales),
    [dblEndVolume]                      NUMERIC (18, 6) DEFAULT 0 NOT NULL,
    [dblBookVariance]                   AS (dblEndVolume - (dblStartVolume + dblDeliveries - dblSales)),
    [dblBookVariancePercentage]         AS CASE WHEN dblEndVolume = 0 
                                            THEN 0
                                            ELSE ((dblEndVolume - (dblStartVolume + dblDeliveries - dblSales)) / dblEndVolume) * 100
                                            END,
    [ysnIncluded]                       BIT             DEFAULT 1 NOT NULL,
    [intConcurrencyId]                  INT             DEFAULT 1 NOT NULL,

    CONSTRAINT [PK_tblTMTankReconciliationDetail] PRIMARY KEY CLUSTERED ([intTankReconciliationDetailId] ASC),
    CONSTRAINT [FK_tblTMTankReconciliationDetail_tblTMTankReconciliation] FOREIGN KEY ([intTankReconciliationId]) REFERENCES [dbo].[tblTMTankReconciliation] ([intTankReconciliationId]),
);
GO