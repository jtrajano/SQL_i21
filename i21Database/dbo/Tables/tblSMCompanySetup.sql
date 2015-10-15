﻿CREATE TABLE [dbo].[tblSMCompanySetup] (
    [intCompanySetupID] INT            IDENTITY (1, 1) NOT NULL,
	[strEin]			NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strCompanyName]    NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strContactName]    NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strAddress]        NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strCounty]         NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strCity]           NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strState]          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strZip]            NVARCHAR (12)  COLLATE Latin1_General_CI_AS NULL,
    [strCountry]        NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strPhone]          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strFax]            NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strWebSite]        NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strEmail]          NVARCHAR (75)  COLLATE Latin1_General_CI_AS NULL,
    [strFederalTaxID]   NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strStateTaxID]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strBusinessType]   NVARCHAR (15)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]  INT            DEFAULT 1 NOT NULL,
    [ysnScreenControlListingUpdated] BIT NULL, 
    CONSTRAINT [PK_tblSMCompanySetup] PRIMARY KEY ([intCompanySetupID]) 
);

