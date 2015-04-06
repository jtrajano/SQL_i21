CREATE TABLE [dbo].[tblEntity] (
    [intEntityId]      INT             IDENTITY (1, 1) NOT NULL,
    [strName]          NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strEmail]         NVARCHAR (75)   COLLATE Latin1_General_CI_AS  NULL,
    [strWebsite]       NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strInternalNotes] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPrint1099]     BIT             NULL,
    [str1099Name]      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [str1099Form]      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [str1099Type]      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strFederalTaxId]  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dtmW9Signed]      DATETIME        NULL,
    [imgPhoto]         VARBINARY (MAX) NULL,
	[strContactNumber]               NVARCHAR (20)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strTitle]         NVARCHAR (35)  COLLATE Latin1_General_CI_AS NULL,
    [strDepartment]    NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [strMobile]        NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strPhone]         NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strPhone2]        NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strEmail2]        NVARCHAR (75)  COLLATE Latin1_General_CI_AS NULL,
    [strFax]           NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [strNotes]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strContactMethod] NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [strTimezone]      NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[intDefaultLocationId]       INT            NULL,
	[ysnActive]        BIT             CONSTRAINT [DF_tblEntity_ysnActive] DEFAULT ((1)) NOT NULL,    	
    [intConcurrencyId] INT             CONSTRAINT [DF__tmp_ms_xx__intCo__5132705A] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [FK_tblEntity_tblEntityLocation] FOREIGN KEY ([intDefaultLocationId]) REFERENCES [tblEntityLocation]([intEntityLocationId]),
    CONSTRAINT [PK_dbo.tblEntity] PRIMARY KEY CLUSTERED ([intEntityId] ASC)
);







