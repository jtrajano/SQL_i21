﻿CREATE TABLE [dbo].[tblARCustomerCardFueling] (
    [intCardFuelingId]        INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]             INT            NOT NULL,
    [strNetworkNumber]        NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strCardNumber]           NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strDescription]          NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceCycle]         NVARCHAR (1)   COLLATE Latin1_General_CI_AS NULL,
    [intAccountStatusId]      INT            NULL,
    [strDiscountSchedule]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strRemoteAddOn]          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strExtRemoteAddOn]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strDefaultVehicle]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [ysnCardForOwnUse]        BIT            NOT NULL DEFAULT ((0)),
    [strExpenseAcctForOwnUse] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intTermsId]              INT            NULL,
    [ysnCardLocked]           BIT            NULL,
    [strPinNumber]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [dtmExpiration]           DATETIME       NULL,
    [strValidationCode]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intCardsIssued]          INT            NOT NULL,
    [strLimitCode]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strFuelCode]             NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strTierCode]             NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strOdomCode]             NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strWCCode]               NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]        INT            NOT NULL,
    CONSTRAINT [PK_tblARCardFueling] PRIMARY KEY CLUSTERED ([intCardFuelingId] ASC)
);

