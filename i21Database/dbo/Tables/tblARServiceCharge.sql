﻿CREATE TABLE [dbo].[tblARServiceCharge] (
    [intServiceChargeId]		INT             IDENTITY (1, 1) NOT NULL,
    [strServiceChargeCode]		NVARCHAR (2)    COLLATE Latin1_General_CI_AS NOT NULL,
    [strCalculationType]		NVARCHAR (50)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]			NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [dblServiceChargeAPR]		NUMERIC (18, 6) NULL DEFAULT 0,
    [dblPercentage]				NUMERIC (18, 6) NULL DEFAULT 0,
    [dblMinimumCharge]			NUMERIC (18, 6) NULL DEFAULT 0,
	[dblMinimumFinanceCharge]   NUMERIC (18, 6) NULL DEFAULT 0,
    [intGracePeriod]			INT             NULL,
    [ysnAllowCatchUpCharges]	BIT             CONSTRAINT [DF_tblARServiceCharge_ysnAllowCatchUpCharges] DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]			INT             NOT NULL DEFAULT ((0)),
    CONSTRAINT [PK_tblARServiceCharge_intServiceChargeId] PRIMARY KEY CLUSTERED ([intServiceChargeId] ASC),
    CONSTRAINT [UQ_tblARServiceCharge_strServiceChargeCode] UNIQUE NONCLUSTERED ([strServiceChargeCode] ASC)
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Field used to map to Origin',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblARServiceCharge',
    @level2type = N'COLUMN',
    @level2name = N'strServiceChargeCode'