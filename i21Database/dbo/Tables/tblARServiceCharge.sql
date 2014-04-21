CREATE TABLE [dbo].[tblARServiceCharge] (
    [intServiceChargeId]     INT             IDENTITY (1, 1) NOT NULL,
    [intServiceChargeCode]   INT             NOT NULL,
    [strCalculationType]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]         NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblServiceChargeAPR]    NUMERIC (18, 2) NULL,
    [dblPercentage]          NUMERIC (18, 2) NULL,
    [strFrequency]           NVARCHAR (10)   COLLATE Latin1_General_CI_AS NULL,
    [dblMinimumCharge]       NUMERIC (18, 2) NULL,
    [intGracePeriod]         INT             NULL,
    [strAppliedPer]          NVARCHAR (10)   COLLATE Latin1_General_CI_AS NULL,
    [ysnAllowCatchUpCharges] BIT             NULL,
    [intOriginChargeId]      INT             NULL,
    [intConcurrencyId]       INT             NOT NULL,
    CONSTRAINT [PK_tblARServiceCharge] PRIMARY KEY CLUSTERED ([intServiceChargeId] ASC),
    CONSTRAINT [UKintServiceChargeCode] UNIQUE NONCLUSTERED ([intServiceChargeCode] ASC)
);

