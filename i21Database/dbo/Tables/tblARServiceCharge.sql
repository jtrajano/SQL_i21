CREATE TABLE [dbo].[tblARServiceCharge] (
    [intServiceChargeId]     INT             IDENTITY (1, 1) NOT NULL,
    [strServiceChargeCode]   NVARCHAR (2)    COLLATE Latin1_General_CI_AS NOT NULL,
    [strCalculationType]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]         NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [dblServiceChargeAPR]    NUMERIC (18, 2) NULL,
    [dblPercentage]          NUMERIC (18, 2) NULL,
    [strFrequency]           NVARCHAR (10)   COLLATE Latin1_General_CI_AS NULL,
    [dblMinimumCharge]       NUMERIC (18, 2) NULL,
    [intGracePeriod]         INT             NULL,
    [strAppliedPer]          NVARCHAR (10)   COLLATE Latin1_General_CI_AS NULL,
    [ysnAllowCatchUpCharges] BIT             CONSTRAINT [DF__tmp_ms_xx__ysnAl__1EA6F08D] DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]       INT             NOT NULL DEFAULT ((0)),
    CONSTRAINT [PK_tblARServiceCharge] PRIMARY KEY CLUSTERED ([intServiceChargeId] ASC),
    CONSTRAINT [UKstrServiceChargeCode] UNIQUE NONCLUSTERED ([strServiceChargeCode] ASC)
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