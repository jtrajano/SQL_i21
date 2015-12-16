CREATE TABLE [dbo].[tblMFReasonCodeDetail]
(
	intReasonCodeDetailId INT NOT NULL IDENTITY,
	intConcurrencyId INT NULL CONSTRAINT DF_tblMFReasonCodeDetail_intConcurrencyId DEFAULT 0,
	intReasonCodeId INT NOT NULL,
	intManufacturingCellId INT NOT NULL,

	intCreatedUserId int NULL,
	dtmCreated datetime NULL CONSTRAINT DF_tblMFReasonCodeDetail_dtmCreated DEFAULT GetDate(),
	intLastModifiedUserId int NULL,
	dtmLastModified datetime NULL CONSTRAINT DF_tblMFReasonCodeDetail_dtmLastModified DEFAULT GetDate(),
		
	CONSTRAINT PK_tblMFReasonCodeDetail PRIMARY KEY (intReasonCodeDetailId), 
	CONSTRAINT AK_tblMFReasonCodeDetail_intReasonCodeId_intManufacturingCellId UNIQUE (
		intReasonCodeId,
		intManufacturingCellId),
	CONSTRAINT FK_tblMFReasonCodeDetail_tblMFReasonCode FOREIGN KEY (intReasonCodeId) REFERENCES tblMFReasonCode(intReasonCodeId) ON DELETE CASCADE,
	CONSTRAINT FK_tblMFReasonCodeDetail_tblMFManufacturingCell FOREIGN KEY (intManufacturingCellId) REFERENCES tblMFManufacturingCell(intManufacturingCellId)
)