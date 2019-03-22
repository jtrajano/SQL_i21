CREATE TABLE [dbo].[tblSMTrustedComputer] (
	[intTrustedComputerId]  INT IDENTITY(1,1) NOT NULL,
	[intEntityId]           INT NULL,
	[strOS]                 NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL,
	[strBrowser]            NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL,
	[strDevice]             NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL,
	[strGeoLocation]        NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strLocation]           NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strToken]              NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[dtmTokenExpiration]    DATETIME DEFAULT (GETDATE()) NULL,
	[dtmLastLogin]          DATETIME DEFAULT (GETDATE()) NULL,
	[intConcurrencyId]      INT NOT NULL, 
	CONSTRAINT [PK_tblSMTrustedComputer] PRIMARY KEY CLUSTERED ([intTrustedComputerId] ASC)
);
