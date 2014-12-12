CREATE TABLE [dbo].[tblTMCOBOLPRICE] (
    [CustomerNumber]       CHAR (10)       CONSTRAINT [DEF_tblTMCOBOLPRICE_CustomerNumber] DEFAULT ((0)) NOT NULL,
    [SiteNumber]           CHAR (4)        CONSTRAINT [DEF_tblTMCOBOLPRICE_SiteNumber] DEFAULT ((0)) NOT NULL,
    [Price]        DECIMAL (18, 6) CONSTRAINT [DEF_tblTMCOBOLPRICE_TotalCapacity] DEFAULT ((0)) NOT NULL,
	[LastUpdateDate]        CHAR (8) CONSTRAINT [DEF_tblTMCOBOLPRICE_LastUpdateDate] DEFAULT (('00000000')) NOT NULL,
	[LastUpdateTime]        CHAR (8) CONSTRAINT [DEF_tblTMCOBOLPRICE_LastUpdateTime] DEFAULT (('00000000')) NOT NULL,
);

