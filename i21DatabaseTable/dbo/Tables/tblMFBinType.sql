CREATE TABLE [dbo].[tblMFBinType]
(
	intBinTypeId INT NOT NULL IDENTITY,
	intConcurrencyId INT NULL CONSTRAINT DF_tblMFBinType_intConcurrencyId DEFAULT 0,
	strBinTypeName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	dblTareWeight NUMERIC(18, 6) NOT NULL,
	intTareWeightUnitMeasureId INT NOT NULL,
	intLocationId INT NOT NULL,

	intCreatedUserId int NULL,
	dtmCreated datetime NULL CONSTRAINT DF_tblMFBinType_dtmCreated DEFAULT GetDate(),
	intLastModifiedUserId int NULL,
	dtmLastModified datetime NULL CONSTRAINT DF_tblMFBinType_dtmLastModified DEFAULT GetDate(),
		
	CONSTRAINT PK_tblMFBinType PRIMARY KEY (intBinTypeId),
	CONSTRAINT AK_tblMFBinType_strBinTypeName_intLocationId UNIQUE (strBinTypeName, intLocationId),
	CONSTRAINT FK_tblMFBinType_tblSMCompanyLocation FOREIGN KEY (intLocationId) REFERENCES tblSMCompanyLocation(intCompanyLocationId),
	CONSTRAINT FK_tblMFBinType_tblICUnitMeasure FOREIGN KEY (intTareWeightUnitMeasureId) REFERENCES tblICUnitMeasure(intUnitMeasureId)
)