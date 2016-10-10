CREATE TABLE [dbo].[tblQMSample]
(
	[intSampleId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMSample_intConcurrencyId] DEFAULT 0, 
	[intSampleTypeId] INT NOT NULL, 
	[strSampleNumber] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intProductTypeId] INT NOT NULL, -- Transaction Type Id
	[intProductValueId] INT, -- Transaction Object Id
	[intSampleStatusId] INT NOT NULL, 
	[intItemId] INT, -- Inventory Item
	[intItemContractId] INT, -- Contract Item
	[intContractHeaderId] INT, 
	[intContractDetailId] INT, 
	[intShipmentBLContainerId] INT, -- Need to remove later
	[intShipmentBLContainerContractId] INT,  -- Need to remove later
	[intShipmentId] INT,  -- Need to remove later
	[intShipmentContractQtyId] INT,  -- Need to remove later
	[intCountryID] INT, -- Origin Id
	[ysnIsContractCompleted] BIT NOT NULL CONSTRAINT [DF_tblQMSample_ysnIsContractCompleted] DEFAULT 0, 
	[intLotStatusId] INT, 
	[intEntityId] INT, -- Party Id
	[intShipperEntityId] INT, -- Shipper Id
	[strShipmentNumber] NVARCHAR(30) COLLATE Latin1_General_CI_AS,
	[strLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	[strSampleNote] NVARCHAR(512) COLLATE Latin1_General_CI_AS, 
	[dtmSampleReceivedDate] DATETIME, 
	[dtmTestedOn] DATETIME, 
	[intTestedById] INT, -- User Security ID
	[dblSampleQty] NUMERIC(18, 6), 
	[intSampleUOMId] INT, 
	[dblRepresentingQty] NUMERIC(18, 6), 
	[intRepresentingUOMId] INT, 
	[strRefNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[dtmTestingStartDate] DATETIME CONSTRAINT [DF_tblQMSample_dtmTestingStartDate] DEFAULT GetDate(),
	[dtmTestingEndDate] DATETIME CONSTRAINT [DF_tblQMSample_dtmTestingEndDate] DEFAULT GetDate(), 
	[dtmSamplingEndDate] DATETIME CONSTRAINT [DF_tblQMSample_dtmSamplingEndDate] DEFAULT GetDate(), 
	[strSamplingMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[strContainerNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[strMarks] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[intCompanyLocationSubLocationId] INT, 
	[strCountry] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[intItemBundleId] INT, -- Bundle Item
	[intLoadContainerId] INT, 
	[intLoadDetailContainerLinkId] INT, 
	[intLoadId] INT, 
	[intLoadDetailId] INT, 
	[dtmBusinessDate] DATETIME, 
	[intShiftId] INT, 
	[intLocationId] INT, 
	[intInventoryReceiptId] INT, 
	[intWorkOrderId] INT, 
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMSample_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMSample_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMSample] PRIMARY KEY ([intSampleId]), 
	CONSTRAINT [AK_tblQMSample_strSampleNumber] UNIQUE ([strSampleNumber]), 
	CONSTRAINT [FK_tblQMSample_tblQMSampleType] FOREIGN KEY ([intSampleTypeId]) REFERENCES [tblQMSampleType]([intSampleTypeId]), 
	CONSTRAINT [FK_tblQMSample_tblQMProductType] FOREIGN KEY ([intProductTypeId]) REFERENCES [tblQMProductType]([intProductTypeId]), 
	CONSTRAINT [FK_tblQMSample_tblQMSampleStatus] FOREIGN KEY ([intSampleStatusId]) REFERENCES [tblQMSampleStatus]([intSampleStatusId]), 
	CONSTRAINT [FK_tblQMSample_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
	CONSTRAINT [FK_tblQMSample_tblICItemContract] FOREIGN KEY ([intItemContractId]) REFERENCES [tblICItemContract]([intItemContractId]), 
	CONSTRAINT [FK_tblQMSample_tblCTContractHeader] FOREIGN KEY ([intContractHeaderId]) REFERENCES [tblCTContractHeader]([intContractHeaderId]), 
	CONSTRAINT [FK_tblQMSample_tblCTContractDetail] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]), 
	CONSTRAINT [FK_tblQMSample_tblLGShipmentBLContainer] FOREIGN KEY ([intShipmentBLContainerId]) REFERENCES [tblLGShipmentBLContainer]([intShipmentBLContainerId]), 
	CONSTRAINT [FK_tblQMSample_tblLGShipmentBLContainerContract] FOREIGN KEY ([intShipmentBLContainerContractId]) REFERENCES [tblLGShipmentBLContainerContract]([intShipmentBLContainerContractId]), 
	CONSTRAINT [FK_tblQMSample_tblLGShipment] FOREIGN KEY ([intShipmentId]) REFERENCES [tblLGShipment]([intShipmentId]), 
	CONSTRAINT [FK_tblQMSample_tblLGShipmentContractQty] FOREIGN KEY ([intShipmentContractQtyId]) REFERENCES [tblLGShipmentContractQty]([intShipmentContractQtyId]), 
	CONSTRAINT [FK_tblQMSample_tblSMCountry] FOREIGN KEY ([intCountryID]) REFERENCES [tblSMCountry]([intCountryID]), 
	CONSTRAINT [FK_tblQMSample_tblICUnitMeasure_intSampleUOMId] FOREIGN KEY ([intSampleUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
	CONSTRAINT [FK_tblQMSample_tblICUnitMeasure_intRepresentingUOMId] FOREIGN KEY ([intRepresentingUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
	CONSTRAINT [FK_tblQMSample_tblICLotStatus] FOREIGN KEY ([intLotStatusId]) REFERENCES [tblICLotStatus]([intLotStatusId]), 
	CONSTRAINT [FK_tblQMSample_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]), 
	CONSTRAINT [FK_tblQMSample_tblEMEntity_intShipperEntityId] FOREIGN KEY ([intShipperEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblQMSample_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intCompanyLocationSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]), 
    CONSTRAINT [FK_tblQMSample_tblICItem_intItemBundleId] FOREIGN KEY ([intItemBundleId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblQMSample_tblLGLoadContainer] FOREIGN KEY ([intLoadContainerId]) REFERENCES [tblLGLoadContainer]([intLoadContainerId]), 
	CONSTRAINT [FK_tblQMSample_tblLGLoadDetailContainerLink] FOREIGN KEY ([intLoadDetailContainerLinkId]) REFERENCES [tblLGLoadDetailContainerLink]([intLoadDetailContainerLinkId]), 
	CONSTRAINT [FK_tblQMSample_tblLGLoad] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]), 
	CONSTRAINT [FK_tblQMSample_tblLGLoadDetail] FOREIGN KEY ([intLoadDetailId]) REFERENCES [tblLGLoadDetail]([intLoadDetailId]),
	CONSTRAINT [FK_tblQMSample_tblMFShift] FOREIGN KEY ([intShiftId]) REFERENCES tblMFShift([intShiftId]),
	CONSTRAINT [FK_tblQMSample_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES tblSMCompanyLocation([intCompanyLocationId]),
	CONSTRAINT [FK_tblQMSample_tblICInventoryReceipt] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [tblICInventoryReceipt]([intInventoryReceiptId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblQMSample_tblMFWorkOrder] FOREIGN KEY ([intWorkOrderId]) REFERENCES [tblMFWorkOrder]([intWorkOrderId]) ON DELETE CASCADE
)