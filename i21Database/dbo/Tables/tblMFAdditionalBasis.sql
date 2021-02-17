CREATE TABLE tblMFAdditionalBasis
(
	intAdditionalBasisId INT IDENTITY(1,1) NOT NULL,
	dtmAdditionalBasisDate DATETIME NOT NULL,
	strComment NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intConcurrencyId INT CONSTRAINT [DF_tblMFAdditionalBasis_intConcurrencyId] DEFAULT 0,

	CONSTRAINT [PK_tblMFAdditionalBasis] PRIMARY KEY (intAdditionalBasisId),
	CONSTRAINT [UK_tblMFAdditionalBasis_dtmAdditionalBasisDate] UNIQUE (dtmAdditionalBasisDate)
)
