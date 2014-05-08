CREATE TABLE [dbo].[tblARCustomerSpecialPrice] (
    [intSpecialPriceId] INT             IDENTITY (1, 1) NOT NULL,
    [intEntityId]       INT             NOT NULL,
    [strVendorId]       NVARCHAR (15)   COLLATE Latin1_General_CI_AS NULL,
    [strItemNumber]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strClass]          NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strPriceBasis]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strCustomerGroup]  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dblCostToUse]      NUMERIC (18, 6) NULL,
    [dblDeviation]      NUMERIC (18, 6) NULL,
    [strLineNote]       NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [dtmBeginDate]      DATETIME        NOT NULL,
    [dtmEndDate]        DATETIME        NULL,
    [ysnConsignable]    BIT             NOT NULL DEFAULT ((0)),
    [strRackVendorId]   NVARCHAR (15)   COLLATE Latin1_General_CI_AS NULL,
    [strRackItemNumber] NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]  INT             NOT NULL,
    CONSTRAINT [PK_tblARCustomerSpecialPrice] PRIMARY KEY CLUSTERED ([intSpecialPriceId] ASC)
);

