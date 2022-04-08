CREATE TABLE [dbo].[tblTMImportTankReadingDetail]
(
	[intImportTankReadingDetailId] INT IDENTITY(1,1) NOT NULL,
	[intImportTankReadingId] INT NOT NULL,
	[strEsn] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intCustomerId] INT NULL,
	[strCustomerNumber] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intSiteId] INT NULL,
	[dtmReadingDate] DATETIME NULL,
	[ysnValid] BIT NOT NULL,
	[strMessage] NVARCHAR(4000) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT DEFAULT 1 NOT NULL,
	[intRecord] INT NULL,
	CONSTRAINT [PK_tblTMImportTankReadingDetail] PRIMARY KEY CLUSTERED ([intImportTankReadingDetailId] ASC),
	CONSTRAINT [FK_tblTMImportTankReadingDetail_tblTMImportTankReading] FOREIGN KEY ([intImportTankReadingId]) REFERENCES [dbo].[tblTMImportTankReading] ([intImportTankReadingId]),
	CONSTRAINT [FK_tblTMImportTankReadingDetail_tblARCustomer] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
	CONSTRAINT [FK_tblTMImportTankReadingDetail_tblTMSite] FOREIGN KEY ([intSiteId]) REFERENCES [dbo].[tblTMSite] ([intSiteID])
)
