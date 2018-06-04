CREATE TABLE [dbo].[tblLGLoadDetail]
(
	[intLoadDetailId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
	[intLoadId] INT NOT NULL, 
	[intVendorEntityId] INT NULL,
	[intVendorEntityLocationId] INT NULL,
	[intCustomerEntityId] INT NULL,
	[intCustomerEntityLocationId] INT NULL,
	[intItemId] INT NULL,
	[intPContractDetailId] INT NULL,	
	[intSContractDetailId] INT NULL,	
	[intPCompanyLocationId] INT NULL,
	[intSCompanyLocationId] INT NULL,
	[dblQuantity] NUMERIC(18, 6) NULL,
	[intItemUOMId] INT NULL,
	[dblGross] NUMERIC(18, 6) NULL,
	[dblTare] NUMERIC(18, 6) NULL,
	[dblNet] NUMERIC(18, 6) NULL,
	[intWeightItemUOMId] INT NULL,
	[strPriceStatus] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[dblUnitPrice] NUMERIC(18, 6) NULL,
	[intPriceCurrencyId] INT NULL,
	[intPriceUOMId] INT NULL,
	[dblAmount] NUMERIC(18,6) NULL,
	[intForexRateTypeId] INT NULL,
	[dblForexRate] NUMERIC(18,6) NULL,
	[intForexCurrencyId] INT NULL,
	[dblForexAmount] NUMERIC(18,6) NULL,
	[dblDeliveredQuantity] NUMERIC(18, 6) NULL,
	[dblDeliveredGross] NUMERIC(18, 6) NULL,
	[dblDeliveredTare] NUMERIC(18, 6) NULL,
	[dblDeliveredNet] NUMERIC(18, 6) NULL,
	[strLotAlias] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strSupplierLotNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[dtmProductionDate]	DATETIME NULL,
	[strScheduleInfoMsg]	NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[ysnUpdateScheduleInfo] [bit] NULL,
	[ysnPrintScheduleInfo] [bit] NULL,
	[strLoadDirectionMsg]	NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[ysnUpdateLoadDirections] [bit] NULL,
	[ysnPrintLoadDirections] [bit] NULL,

	[strVendorReference] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerReference] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intAllocationDetailId] INT NULL,
	[intPickLotDetailId] INT NULL,
	[intPSubLocationId] INT NULL, 
	[intSSubLocationId] INT NULL, 
	[intNumberOfContainers] INT NULL, 
	[strExternalShipmentItemNumber] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strExternalBatchNo] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[ysnNoClaim] BIT,
	[intLoadDetailRefId] INT NULL,

    CONSTRAINT [PK_tblLGLoadDetail] PRIMARY KEY ([intLoadDetailId]),
    CONSTRAINT [FK_tblLGLoadDetail_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblLGLoadDetail_tblEMEntity_intVendorEntityId] FOREIGN KEY ([intVendorEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblLGLoadDetail_tblEMEntityLocation_intVendorEntityLocationId] FOREIGN KEY ([intVendorEntityLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]),
	CONSTRAINT [FK_tblLGLoadDetail_tblEMEntity_intCustomerEntityId] FOREIGN KEY ([intCustomerEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblLGLoadDetail_tblEMEntityLocation_intCustomerEntityLocationId] FOREIGN KEY ([intCustomerEntityLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]),
	CONSTRAINT [FK_tblLGLoadDetail_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblLGLoadDetail_tblCTContractDetail_intPContractDetailId] FOREIGN KEY ([intPContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblLGLoadDetail_tblCTContractDetail_intSContractDetailId] FOREIGN KEY ([intSContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblLGLoadDetail_tblSMCompanyLocation_intPCompanyLocationId] FOREIGN KEY ([intPCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblLGLoadDetail_tblSMCompanyLocation_intSCompanyLocationId] FOREIGN KEY ([intSCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblLGLoadDetail_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblLGLoadDetail_tblICItemUOM_intWeightItemUOMId] FOREIGN KEY ([intWeightItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblLGLoadDetail_tblLGAllocationDetail_intAllocationDetailId] FOREIGN KEY ([intAllocationDetailId]) REFERENCES [tblLGAllocationDetail]([intAllocationDetailId]),
	CONSTRAINT [FK_tblLGLoadDetail_tblLGPickLotDetail_intPickLotDetailId] FOREIGN KEY ([intPickLotDetailId]) REFERENCES [tblLGPickLotDetail]([intPickLotDetailId]),
	CONSTRAINT [FK_tblLGLoadDetail_tblSMCompanyLocationSubLocation_intPSubLocationId] FOREIGN KEY ([intPSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
	CONSTRAINT [FK_tblLGLoadDetail_tblSMCompanyLocationSubLocation_intSSubLocationId] FOREIGN KEY ([intSSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId])
)
GO
--CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_11_2002822197__K9_K1_17_18] ON [dbo].[tblLGLoadDetail]
--(
--	[intPContractDetailId] ASC,
--	[intLoadDetailId] ASC
--)
--INCLUDE ( 	[dblNet],
--	[intWeightItemUOMId]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
--GO

--go

--CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_207_287600363__K3_K1_K9_K13] ON [dbo].[tblLGLoadDetail]
--(
--	[intLoadId] ASC,
--	[intLoadDetailId] ASC,
--	[intPContractDetailId] ASC,
--	[dblQuantity] ASC
--)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
--go

--CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_207_287600363__K9_K3_K13] ON [dbo].[tblLGLoadDetail]
--(
--	[intPContractDetailId] ASC,
--	[intLoadId] ASC,
--	[dblQuantity] ASC
--)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
--go

--CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_207_287600363__K3_K9_K13_K1] ON [dbo].[tblLGLoadDetail]
--(
--	[intLoadId] ASC,
--	[intPContractDetailId] ASC,
--	[dblQuantity] ASC,
--	[intLoadDetailId] ASC
--)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
--go

--CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_207_287600363__K3_K9] ON [dbo].[tblLGLoadDetail]
--(
--	[intLoadId] ASC,
--	[intPContractDetailId] ASC
--)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
--go

CREATE STATISTICS [_dta_stat_287600363_9_13] ON [dbo].[tblLGLoadDetail]([intPContractDetailId], [dblQuantity])
GO

CREATE STATISTICS [_dta_stat_287600363_9_3_1_13] ON [dbo].[tblLGLoadDetail]([intPContractDetailId], [intLoadId], [intLoadDetailId], [dblQuantity])
GO

CREATE NONCLUSTERED INDEX [IX_tblLGLoadDetail_intLoadId] ON [dbo].[tblLGLoadDetail]
(
	[intLoadId] ASC
)
INCLUDE ( 	
	[intLoadDetailId]
	,[intPContractDetailId]
	,[intWeightItemUOMId]
	,[dblNet]
	,[dblQuantity]
) 

GO
CREATE NONCLUSTERED INDEX [IX_tblLGLoadDetail_intLoadDetailId] ON [dbo].[tblLGLoadDetail]
(
	[intLoadDetailId] ASC
)
INCLUDE ( 	
	[intLoadId]
	,[intPContractDetailId]
	,[intWeightItemUOMId]
	,[dblNet]
	,[dblQuantity]
) 
GO
CREATE NONCLUSTERED INDEX [IX_tblLGLoadDetail_intPContractDetailId] ON [dbo].[tblLGLoadDetail]
(
	[intPContractDetailId] ASC
)
INCLUDE ( 	
	[intLoadId]
	,[intLoadDetailId]
	,[intWeightItemUOMId]
	,[dblNet]
	,[dblQuantity]
) 
GO
CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_197_1412916105__K3_K1_K9_10_13_15_16_17_19] ON [dbo].[tblLGLoadDetail]
(
       [intLoadId] ASC,
       [intLoadDetailId] ASC,
       [intPContractDetailId] ASC
)
INCLUDE (     [intSContractDetailId],
       [dblQuantity],
       [dblGross],
       [dblTare],
       [dblNet],
       [dblDeliveredQuantity]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_197_1412916105__K3_K1_K9] ON [dbo].[tblLGLoadDetail]
(
       [intLoadId] ASC,
       [intLoadDetailId] ASC,
       [intPContractDetailId] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_197_1412916105__K35_K1_K10_K3_K13] ON [dbo].[tblLGLoadDetail]
(
	[intPickLotDetailId] ASC,
	[intLoadDetailId] ASC,
	[intSContractDetailId] ASC,
	[intLoadId] ASC,
	[dblQuantity] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_197_1412916105__K1_K10_K3_K13] ON [dbo].[tblLGLoadDetail]
(
	[intLoadDetailId] ASC,
	[intSContractDetailId] ASC,
	[intLoadId] ASC,
	[dblQuantity] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE STATISTICS [_dta_stat_1412916105_9_35_1_10] ON [dbo].[tblLGLoadDetail]([intPContractDetailId], [intPickLotDetailId], [intLoadDetailId], [intSContractDetailId])
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_197_1412916105__K35_K1_K3_K10_K9_K13] ON [dbo].[tblLGLoadDetail]
(
	[intPickLotDetailId] ASC,
	[intLoadDetailId] ASC,
	[intLoadId] ASC,
	[intSContractDetailId] ASC,
	[intPContractDetailId] ASC,
	[dblQuantity] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_197_1412916105__K9_K1_K35_K3_K10_K13] ON [dbo].[tblLGLoadDetail]
(
	[intPContractDetailId] ASC,
	[intLoadDetailId] ASC,
	[intPickLotDetailId] ASC,
	[intLoadId] ASC,
	[intSContractDetailId] ASC,
	[dblQuantity] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_197_1412916105__K3_K1_K9_K13_K10_K35] ON [dbo].[tblLGLoadDetail]
(
	[intLoadId] ASC,
	[intLoadDetailId] ASC,
	[intPContractDetailId] ASC,
	[dblQuantity] ASC,
	[intSContractDetailId] ASC,
	[intPickLotDetailId] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_197_1412916105__K1_K3_K35_K10_K9_K13] ON [dbo].[tblLGLoadDetail]
(
	[intLoadDetailId] ASC,
	[intLoadId] ASC,
	[intPickLotDetailId] ASC,
	[intSContractDetailId] ASC,
	[intPContractDetailId] ASC,
	[dblQuantity] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_197_1412916105__K1_K13_K10_3_35] ON [dbo].[tblLGLoadDetail]
(
	[intLoadDetailId] ASC,
	[dblQuantity] ASC,
	[intSContractDetailId] ASC
)
INCLUDE ( 	[intLoadId],
	[intPickLotDetailId]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_197_1412916105__K1_K13_K10_3] ON [dbo].[tblLGLoadDetail]
(
	[intLoadDetailId] ASC,
	[dblQuantity] ASC,
	[intSContractDetailId] ASC
)
INCLUDE ( 	[intLoadId]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE STATISTICS [_dta_stat_1412916105_1_10_35] ON [dbo].[tblLGLoadDetail]([intLoadDetailId], [intSContractDetailId], [intPickLotDetailId])
GO

CREATE STATISTICS [_dta_stat_1412916105_3_1_10_13] ON [dbo].[tblLGLoadDetail]([intLoadId], [intLoadDetailId], [intSContractDetailId], [dblQuantity])
GO

CREATE STATISTICS [_dta_stat_1412916105_1_9_35_3] ON [dbo].[tblLGLoadDetail]([intLoadDetailId], [intPContractDetailId], [intPickLotDetailId], [intLoadId])
GO

CREATE STATISTICS [_dta_stat_1412916105_35_3_1_10_13] ON [dbo].[tblLGLoadDetail]([intPickLotDetailId], [intLoadId], [intLoadDetailId], [intSContractDetailId], [dblQuantity])
GO

CREATE STATISTICS [_dta_stat_1412916105_1_13_9_10_35] ON [dbo].[tblLGLoadDetail]([intLoadDetailId], [dblQuantity], [intPContractDetailId], [intSContractDetailId], [intPickLotDetailId])
GO