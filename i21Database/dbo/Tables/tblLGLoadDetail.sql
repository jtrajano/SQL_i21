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
CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_11_2002822197__K9_K1_17_18] ON [dbo].[tblLGLoadDetail]
(
	[intPContractDetailId] ASC,
	[intLoadDetailId] ASC
)
INCLUDE ( 	[dblNet],
	[intWeightItemUOMId]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

go

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_207_287600363__K3_K1_K9_K13] ON [dbo].[tblLGLoadDetail]
(
	[intLoadId] ASC,
	[intLoadDetailId] ASC,
	[intPContractDetailId] ASC,
	[dblQuantity] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_207_287600363__K9_K3_K13] ON [dbo].[tblLGLoadDetail]
(
	[intPContractDetailId] ASC,
	[intLoadId] ASC,
	[dblQuantity] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_207_287600363__K3_K9_K13_K1] ON [dbo].[tblLGLoadDetail]
(
	[intLoadId] ASC,
	[intPContractDetailId] ASC,
	[dblQuantity] ASC,
	[intLoadDetailId] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoadDetail_207_287600363__K3_K9] ON [dbo].[tblLGLoadDetail]
(
	[intLoadId] ASC,
	[intPContractDetailId] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
go

CREATE STATISTICS [_dta_stat_287600363_9_13] ON [dbo].[tblLGLoadDetail]([intPContractDetailId], [dblQuantity])
go

CREATE STATISTICS [_dta_stat_287600363_9_3_1_13] ON [dbo].[tblLGLoadDetail]([intPContractDetailId], [intLoadId], [intLoadDetailId], [dblQuantity])
go