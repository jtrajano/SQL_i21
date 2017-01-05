CREATE TABLE [dbo].[tblGLMulticurrencySetting](
	[intMulticurrencySettingId] [int] IDENTITY(1,1) NOT NULL,
	[RealizedGainOrLossBasis] [int] NULL,
	[RealizedGainOrLossFutures] [int] NULL,
	[RealizedGainOrLossCash] [int] NULL,
	[InventoryOffsetForRealizedGainOrLoss] [int] NULL,
	[UnrealizedGainOrLossBasis] [int] NULL,
	[UnrealizedGainOrLossFutures] [int] NULL,
	[UnrealizedGainOrLossCash] [int] NULL,
	[InventoryOffsetForUnrealizedGainOrLoss] [int] NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblGLMulticurrencyAccountSetting] PRIMARY KEY CLUSTERED 
(
	[intMulticurrencySettingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

