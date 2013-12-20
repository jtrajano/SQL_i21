CREATE TABLE [dbo].[tblTMPreferenceCompany] (
    [intConcurrencyID]                 INT             CONSTRAINT [DEF_tblTMPreferenceCompany_intConcurrencyID] DEFAULT ((0)) NULL,
    [strSummitIntegration]             NVARCHAR (10)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMPreferenceCompany_strSummitIntegration] DEFAULT (N'AG') NOT NULL,
    [intPreferenceCompanyID]           INT             IDENTITY (1, 1) NOT NULL,
    [intCeilingBurnRate]               INT             CONSTRAINT [DEF_tblTMPreferenceCompany_intCeilingBurnRate] DEFAULT ((0)) NULL,
    [intFloorBurnRate]                 INT             CONSTRAINT [DEF_tblTMPreferenceCompany_intFloorBurnRate] DEFAULT ((0)) NULL,
    [ysnAllowClassFill]                BIT             CONSTRAINT [DEF_tblTMPreferenceCompany_ysnAllowClassFill] DEFAULT ((0)) NULL,
    [dblDefaultReservePercent]         NUMERIC (18, 6) NULL,
    [strSMTPServer]                    NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strSMTPUsername]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strSMTPPassword]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strFromMail]                      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strFromName]                      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [intMailServerPort]                INT             NULL,
    [ysnEnableAuthentication]          BIT             NULL,
    [ysnEnableSSL]                     BIT             NULL,
    [strLeaseProductNumber]            NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [ysnEnableETracker]                BIT             NULL,
    [strETrackerURL]                   NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [ysnUseDeliveryTermOnCS]           BIT             CONSTRAINT [DF_tblTMPreferenceCompany_ysnUseDeliveryTermOnCS] DEFAULT ((0)) NULL,
    [ysnEnableLeaseBillingAboveMinUse] BIT             CONSTRAINT [DF_tblTMPreferenceCompany_ysnEnableLeaseBillingAboveMinUse] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblTMPreferenceCompany] PRIMARY KEY CLUSTERED ([intPreferenceCompanyID] ASC)
);

