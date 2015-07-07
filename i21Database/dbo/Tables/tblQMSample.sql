CREATE TABLE [dbo].[tblQMSample]
(
	[intSampleId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMSample_intConcurrencyId] DEFAULT 0, 
	[intSampleTypeId] INT NOT NULL, 
	[strSampleNumber] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intProductTypeId] INT NOT NULL, -- Transaction Type Id
	[intSampleStatusId] INT NOT NULL, 
	[intItemId] INT, -- Inventory Item
	[intItemContractId] INT, -- Contract Item
	[intContractHeaderId] INT, 
	[intContractDetailId] INT, 
	[intShipmentBLContainerId] INT, 
	[intShipmentBLContainerContractId] INT, 
	[intShipmentId] INT, 
	[intShipmentContractQtyId] INT, 
	[intCountryID] INT, -- Origin Id
	[ysnIsContractCompleted] BIT NOT NULL CONSTRAINT [DF_tblQMSample_ysnIsContractCompleted] DEFAULT 0, 
	[intLotStatusId] INT, 
	[intEntityId] INT, -- Party Id
	[strShipmentNumber] NVARCHAR(30) COLLATE Latin1_General_CI_AS,
	[strLotNumber] NVARCHAR(30) COLLATE Latin1_General_CI_AS, 
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
	CONSTRAINT [FK_tblQMSample_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEntity]([intEntityId]) 
)