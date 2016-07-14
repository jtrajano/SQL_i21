﻿CREATE TABLE [dbo].[tblEMEntity] (
    [intEntityId]      INT             IDENTITY (1, 1) NOT NULL,
    [strName]          NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strEmail]         NVARCHAR (75)   COLLATE Latin1_General_CI_AS  NULL,
    [strWebsite]       NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strInternalNotes] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPrint1099]     BIT             NULL,
    [str1099Name]      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [str1099Form]      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [str1099Type]      NVARCHAR (100)   COLLATE Latin1_General_CI_AS NULL,
    [strFederalTaxId]  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dtmW9Signed]      DATETIME        NULL,
    [imgPhoto]         VARBINARY (MAX) NULL,
	[strContactNumber]               NVARCHAR (20)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strTitle]         NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [strDepartment]    NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [strMobile]        NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strPhone]         NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strPhone2]        NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strEmail2]        NVARCHAR (75)  COLLATE Latin1_General_CI_AS NULL,
    [strFax]           NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strNotes]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strContactMethod] NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [strTimezone]      NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strEntityNo]      NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strContactType]   NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,	
	[intDefaultLocationId]       INT            NULL,
	[ysnActive]        BIT             CONSTRAINT [DF_tblEMEntity_ysnActive] DEFAULT ((1)) NOT NULL,
	[ysnReceiveEmail]  BIT             CONSTRAINT [DF_tblEMEntity_ysnReceiveEmail] DEFAULT ((0)) NOT NULL,
	[strEmailDistributionOption]	NVARCHAR(MAX)	 COLLATE Latin1_General_CI_AS NULL,
    [dtmOriginationDate]      DATETIME        NULL,
    [strPhoneBackUp]         NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
	[intDefaultCountryId]		INT NULL,
	[strDocumentDelivery]	 NVARCHAR (400)  COLLATE Latin1_General_CI_AS NULL,
	[strNickName]			NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
	[strSuffix]				NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,

    [intConcurrencyId] INT             CONSTRAINT [DF__tmp_ms_xx__intCo__5132705A] DEFAULT ((0)) NOT NULL,
	--CONSTRAINT [FK_tblEMEntity_tblEMEntityLocation] FOREIGN KEY ([intDefaultLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]),
	CONSTRAINT [FK_tblSMCountry_tblEMEntity] FOREIGN KEY ([intDefaultCountryId]) REFERENCES [tblSMCountry]([intCountryID]),

    CONSTRAINT [PK_dbo.tblEMEntity] PRIMARY KEY CLUSTERED ([intEntityId] ASC)
);







