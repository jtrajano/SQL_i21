﻿CREATE TABLE [dbo].[tblCTAOP]
(
	intAOPId int IDENTITY(1,1) NOT NULL,
	strYear nvarchar(100) COLLATE Latin1_General_CI_AS  NOT NULL,
	dtmFromDate DATETIME,
	dtmToDate DATETIME,
	intBookId INT,
	intSubBookId INT,	
	intCommodityId INT,
	intCompanyLocationId INT,	
	intConcurrencyId INT NOT NULL, 
	CONSTRAINT PK_tblCTAOP_intAOPId PRIMARY KEY CLUSTERED (intAOPId ASC),
	CONSTRAINT [FK_tblCTAOP_tblCTBook_intBookId] FOREIGN KEY ([intBookId]) REFERENCES [tblCTBook]([intBookId]),
	CONSTRAINT [FK_tblCTAOP_tblCTSubBook_intSubBookId] FOREIGN KEY ([intSubBookId]) REFERENCES [tblCTSubBook]([intSubBookId]),
	CONSTRAINT [FK_tblCTAOP_tblICCommodity_intCommodityId] FOREIGN KEY (intCommodityId) REFERENCES tblICCommodity(intCommodityId),
	CONSTRAINT [FK_tblCTAOP_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY (intCompanyLocationId) REFERENCES tblSMCompanyLocation(intCompanyLocationId),
	CONSTRAINT UQ_tblCTAOP_strYear_dtmFromDate_dtmTodate_intCommodityId_intCompanyLocationId UNIQUE (strYear,dtmFromDate,dtmToDate,intCommodityId,intCompanyLocationId)
)
