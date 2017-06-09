CREATE TABLE tblMFItemOwner (
	intItemOwnerId INT NOT NULL IDENTITY(1, 1)
	,intConcurrencyId INT NULL CONSTRAINT [DF_tblMFItemOwner_intConcurrencyId] DEFAULT 0
	,intItemId INT NULL
	,intOwnerId INT NOT NULL
	,intReceivedLife INT
	,intCustomerLabelTypeId int NULL
	,strPackageType nvarchar(1) COLLATE Latin1_General_CI_AS NULL
	,strManufacturerCode nvarchar(50)COLLATE Latin1_General_CI_AS NULL
	,ysnAllowPartialPallet bit CONSTRAINT [DF_tblMFItemOwner_ysnAllowPartialPallet] Default 1
	,strReportName nvarchar(50)COLLATE Latin1_General_CI_AS NULL
	,strGS1SpecialCode nvarchar(10)COLLATE Latin1_General_CI_AS NULL
	,strFirstBarcodeStart nvarchar(10)COLLATE Latin1_General_CI_AS NULL
	,strFirstBarcodeFollowGTIN nvarchar(10)COLLATE Latin1_General_CI_AS NULL
	,strFirstBarcodeEnd nvarchar(10)COLLATE Latin1_General_CI_AS NULL
	,strSecondBarcodeStart nvarchar(10)COLLATE Latin1_General_CI_AS NULL
	,strSecondBarcodeFollowGrossWeight nvarchar(10)COLLATE Latin1_General_CI_AS NULL
	,strSecondBarcodeEnd nvarchar(10)COLLATE Latin1_General_CI_AS NULL
	,strThirdBarcodeStart nvarchar(10)COLLATE Latin1_General_CI_AS NULL

	,intCreatedUserId [int] NULL
	,dtmCreated [datetime] NULL CONSTRAINT [DF_tblMFItemOwner_dtmCreated] DEFAULT GetDate()
	,intLastModifiedUserId [int] NULL
	,dtmLastModified [datetime] NULL CONSTRAINT [DF_tblMFItemOwner_dtmLastModified] DEFAULT GetDate()

	,CONSTRAINT PK_tblMFItemOwner PRIMARY KEY (intItemOwnerId)
	,CONSTRAINT [AK_tblMFItemOwner_intItemId_intOwnerId] UNIQUE ([intItemId],[intOwnerId])
	,CONSTRAINT FK_tblMFItemOwner_tblICItem FOREIGN KEY (intItemId) REFERENCES tblICItem(intItemId)
	,CONSTRAINT FK_tblMFItemOwner_tblEMEntity FOREIGN KEY (intOwnerId) REFERENCES tblEMEntity(intEntityId)
	,CONSTRAINT FK_tblMFItemOwner_tblMFCustomerLabelType FOREIGN KEY (intCustomerLabelTypeId) REFERENCES tblMFCustomerLabelType(intCustomerLabelTypeId)
	)
