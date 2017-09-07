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
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLMulticurrencySetting', @level2type=N'COLUMN',@level2name=N'intMulticurrencySettingId' GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Realized Gain Or Loss Basis' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLMulticurrencySetting', @level2type=N'COLUMN',@level2name=N'RealizedGainOrLossBasis' GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Realized Gain Or Loss Futures' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLMulticurrencySetting', @level2type=N'COLUMN',@level2name=N'RealizedGainOrLossFutures' GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Realized Gain Or Loss Cash' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLMulticurrencySetting', @level2type=N'COLUMN',@level2name=N'RealizedGainOrLossCash' GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inventory Offset For Realized Gain Or Loss' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLMulticurrencySetting', @level2type=N'COLUMN',@level2name=N'InventoryOffsetForRealizedGainOrLoss' GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unrealized Gain Or Loss Basis' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLMulticurrencySetting', @level2type=N'COLUMN',@level2name=N'UnrealizedGainOrLossBasis' GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unrealized Gain Or Loss Futures' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLMulticurrencySetting', @level2type=N'COLUMN',@level2name=N'UnrealizedGainOrLossFutures' GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unrealized Gain Or Loss Cash' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLMulticurrencySetting', @level2type=N'COLUMN',@level2name=N'UnrealizedGainOrLossCash' GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Inventory Offset For Unrealized Gain Or Loss' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLMulticurrencySetting', @level2type=N'COLUMN',@level2name=N'InventoryOffsetForUnrealizedGainOrLoss' GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLMulticurrencySetting', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' GO
