CREATE TABLE [dbo].[tblEMEntityCardInformation] (
    [intEntityCardInfoId]	INT			IDENTITY (1, 1) NOT NULL,
    [intEntityId]			INT			NOT NULL,
    [strCreditCardNumber]	NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL,
    [strCardHolderName]		NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL,
    [strCardType]			NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL,
	[strCardExpDate]		NVARCHAR (10)	COLLATE Latin1_General_CI_AS NULL ,
    [strFrequency]			NVARCHAR (10)	COLLATE Latin1_General_CI_AS NOT NULL,
    [strToken]				NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS NULL,
    [strReference]			NVARCHAR(20)	COLLATE Latin1_General_CI_AS NULL,
    [dtmDateCreated]		DATETIME	NULL,
    [dtmTokenExpired]		DATETIME	NULL,
    [intEntityUserId]		INT			NOT NULL,
    [intConcurrencyId]		INT			NOT NULL,
    CONSTRAINT [PK_tblEMEntityCardInformation] PRIMARY KEY CLUSTERED ([intEntityCardInfoId] ASC)
);

