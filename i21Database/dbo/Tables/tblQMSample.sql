CREATE TABLE [dbo].[tblQMSample]
(
	[intSampleId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMSample_intConcurrencyId] DEFAULT 0, 
	[intSampleTypeId] INT NOT NULL, 
	[strSampleNumber] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intMaterialId] INT NULL, -- Foreign Key
	[intContractHeaderId] INT NULL, -- Foreign Key
	[intContractLineItemId] INT NULL, -- Foreign Key
	[intContainerId] INT NULL, -- Foreign Key
	[intContainerLineItemId] INT NULL, -- Foreign Key
	[intShipmentHeaderId] INT NULL, -- Foreign Key
	[intShipmentLineItemId] INT NULL, -- Foreign Key
	[intOriginId] INT NULL, -- Foreign Key
	[intInvMaterialId] INT NULL, -- Foreign Key
	[strLotNumber] NVARCHAR(30) COLLATE Latin1_General_CI_AS, 
	[strSampleNote] NVARCHAR(512) COLLATE Latin1_General_CI_AS, 
	[intSampleStatusId] INT NOT NULL, 
	[dtmSampleReceivedDate] DATETIME, 
	[dtmTestedOn] DATETIME, 
	[intTestedById] INT NULL, -- Foreign Key
	[strShipmentNumber] NVARCHAR(30) COLLATE Latin1_General_CI_AS,
	[dblSampleQty] NUMERIC(18, 6) NULL, 
	[intSampleUOMId] INT NULL, 
	[dblRepresentingQty] NUMERIC(18, 6) NULL, 
	[intRepresentingUOMId] INT NULL, 
	[intProductTypeId] INT NOT NULL, -- Transaction Type Id
	[ysnIsContractCompleted] BIT NOT NULL CONSTRAINT [DF_tblQMProductType_ysnIsContractCompleted] DEFAULT 0, 
	[intLotStatusMaskId] INT NULL, -- Foreign Key
	[intPartyId] INT NULL, -- Foreign Key
	[strRefNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMSample_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMSample_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMSample] PRIMARY KEY ([intSampleId]), 
	CONSTRAINT [AK_tblQMSample_strSampleNumber] UNIQUE ([strSampleNumber]), 
	CONSTRAINT [FK_tblQMSample_tblQMSampleType] FOREIGN KEY ([intSampleTypeId]) REFERENCES [tblQMSampleType]([intSampleTypeId]), 
	CONSTRAINT [FK_tblQMSample_tblQMSampleStatus] FOREIGN KEY ([intSampleStatusId]) REFERENCES [tblQMSampleStatus]([intSampleStatusId]), 
	CONSTRAINT [FK_tblQMSample_tblICUnitMeasure_intSampleUOMId] FOREIGN KEY ([intSampleUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
	CONSTRAINT [FK_tblQMSample_tblICUnitMeasure_intRepresentingUOMId] FOREIGN KEY ([intRepresentingUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
	CONSTRAINT [FK_tblQMSample_tblQMProductType] FOREIGN KEY ([intProductTypeId]) REFERENCES [tblQMProductType]([intProductTypeId]) 
)