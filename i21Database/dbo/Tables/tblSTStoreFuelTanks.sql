CREATE TABLE [dbo].[tblSTStoreFuelTanks]
(
	[intStoreFuelTankId]		INT				NOT NULL						IDENTITY, 
	[intStoreId]				INT				NOT NULL,
	[intDeviceId]				INT				NULL,
	[strSerialNumber]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL, 
	[intRegisterTankNumber]		INT				NOT NULL,
	[intConcurrencyId]			INT				NOT NULL,
	CONSTRAINT [FK_tblSTStoreFuelTanks_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]), 
	CONSTRAINT [FK_tblSTStoreFuelTanks_tblTMDevice] FOREIGN KEY ([intDeviceId]) REFERENCES [dbo].[tblTMDevice] ([intDeviceId]),
)