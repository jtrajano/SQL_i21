CREATE TABLE [dbo].[tblMFWastage]
(
	intWastageId INT NOT NULL IDENTITY,
	intConcurrencyId INT NULL CONSTRAINT DF_tblMFWastage_intConcurrencyId DEFAULT 0,
	intShiftActivityId INT NOT NULL,
	intWastageTypeId INT NOT NULL,
	intBinTypeId INT NOT NULL,
	dblGrossWeight NUMERIC(18, 6) NOT NULL,
	dblTareWeight NUMERIC(18, 6) NOT NULL,
	dblNetWeight NUMERIC(18, 6) NOT NULL,
	intGrossWeightUnitMeasureId INT,
	intWeightUnitMeasureId INT NOT NULL,
	intWorkOrderId INT,
	intItemId INT,
	intStorageLocationId INT,
	intLotId INT,
	strLotAlias NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	intCreatedUserId int NULL,
	dtmCreated datetime NULL CONSTRAINT DF_tblMFWastage_dtmCreated DEFAULT GetDate(),
	intLastModifiedUserId int NULL,
	dtmLastModified datetime NULL CONSTRAINT DF_tblMFWastage_dtmLastModified DEFAULT GetDate(),
		
	CONSTRAINT PK_tblMFWastage PRIMARY KEY (intWastageId), 
	CONSTRAINT FK_tblMFWastage_tblMFShiftActivity FOREIGN KEY (intShiftActivityId) REFERENCES tblMFShiftActivity(intShiftActivityId) ON DELETE CASCADE,
	CONSTRAINT FK_tblMFWastage_tblMFWastageType FOREIGN KEY (intWastageTypeId) REFERENCES tblMFWastageType(intWastageTypeId),
	CONSTRAINT FK_tblMFWastage_tblMFBinType FOREIGN KEY (intBinTypeId) REFERENCES tblMFBinType(intBinTypeId),
	CONSTRAINT FK_tblMFWastage_tblICUnitMeasure_intGrossWeightUnitMeasureId FOREIGN KEY (intGrossWeightUnitMeasureId) REFERENCES tblICUnitMeasure(intUnitMeasureId),
	CONSTRAINT FK_tblMFWastage_tblICUnitMeasure_intWeightUnitMeasureId FOREIGN KEY (intWeightUnitMeasureId) REFERENCES tblICUnitMeasure(intUnitMeasureId),
	CONSTRAINT FK_tblMFWastage_tblMFWorkOrder FOREIGN KEY (intWorkOrderId) REFERENCES tblMFWorkOrder(intWorkOrderId),
	CONSTRAINT FK_tblMFWastage_tblICItem FOREIGN KEY (intItemId) REFERENCES tblICItem(intItemId),
	CONSTRAINT FK_tblMFWastage_tblICStorageLocation FOREIGN KEY (intStorageLocationId) REFERENCES tblICStorageLocation (intStorageLocationId),
	CONSTRAINT FK_tblMFWastage_tblICLot FOREIGN KEY (intLotId) REFERENCES tblICLot(intLotId)
)