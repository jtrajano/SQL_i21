CREATE TABLE [dbo].[tblQMSampleContractSequence]
(
	intSampleContractSequenceId INT NOT NULL IDENTITY,
	intConcurrencyId INT NULL CONSTRAINT DF_tblQMSampleContractSequence_intConcurrencyId DEFAULT 1,
	intSampleId INT NOT NULL,
	intContractDetailId INT NOT NULL,
	dblQuantity NUMERIC(18, 6),
	intUnitMeasureId INT,
	
	intCreatedUserId INT NULL,
	dtmCreated DATETIME NULL CONSTRAINT DF_tblQMSampleContractSequence_dtmCreated DEFAULT GETDATE(),
	intLastModifiedUserId INT NULL,
	dtmLastModified DATETIME NULL CONSTRAINT DF_tblQMSampleContractSequence_dtmLastModified DEFAULT GETDATE(),
	
	CONSTRAINT [PK_tblQMSampleContractSequence] PRIMARY KEY (intSampleContractSequenceId), 
	CONSTRAINT [FK_tblQMSampleContractSequence_tblQMSample] FOREIGN KEY (intSampleId) REFERENCES [tblQMSample](intSampleId) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblQMSampleContractSequence_tblCTContractDetail] FOREIGN KEY (intContractDetailId) REFERENCES [tblCTContractDetail](intContractDetailId),
	CONSTRAINT [FK_tblQMSampleContractSequence_tblICUnitMeasure] FOREIGN KEY (intUnitMeasureId) REFERENCES [tblICUnitMeasure](intUnitMeasureId)
)
