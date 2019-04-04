CREATE TABLE [dbo].[tblCTAOPComponent]
(
	intAOPComponentId int IDENTITY(1,1) NOT NULL,
	intAOPDetailId int NOT NULL,
	intBasisItemId INT,
	dblCost NUMERIC(18,6),
	intConcurrencyId INT NOT NULL, 

	CONSTRAINT PK_tblCTAOPComponent_intAOPComponentId PRIMARY KEY CLUSTERED (intAOPComponentId ASC),
	CONSTRAINT FK_tblCTAOPComponent_tblCTAOPDetail_intAOPDetailId FOREIGN KEY (intAOPDetailId) REFERENCES tblCTAOPDetail(intAOPDetailId) ON DELETE CASCADE

)
