CREATE TABLE tblMFDemandDetail (
	intDemandDetailId INT NOT NULL IDENTITY
	,intConcurrencyId INT NOT NULL
	,intDemandHeaderId INT NOT NULL
	,intItemId INT NOT NULL
	,intSubstituteItemId INT
	,dtmDemandDate DATETIME NOT NULL
	,dblQuantity NUMERIC(18, 6) NOT NULL
	,intItemUOMId INT NOT NULL
	,intCompanyLocationId INT
	,dtmCreated datetime CONSTRAINT [DF_tblMFDemandDetail_ydtmCreated] DEFAULT GETDATE()
	,ysnPopulatedBySystem BIT CONSTRAINT [DF_tblMFDemandDetail_ysnPopulatedBySystem] DEFAULT 0
	,CONSTRAINT [PK_tblMFDemandDetail] PRIMARY KEY (intDemandDetailId)
	,CONSTRAINT [FK_tblMFDemandDetail_tblMFDemandHeader] FOREIGN KEY (intDemandHeaderId) REFERENCES [tblMFDemandHeader](intDemandHeaderId) ON DELETE CASCADE
	,CONSTRAINT [FK_tblMFDemandDetail_tblICItem_intItemId] FOREIGN KEY (intItemId) REFERENCES [tblICItem](intItemId)
	,CONSTRAINT [FK_tblMFDemandDetail_tblICItem_intSubstituteItemId] FOREIGN KEY (intSubstituteItemId) REFERENCES [tblICItem](intItemId)
	,CONSTRAINT [FK_tblMFDemandDetail_tblICItemUOM_intItemUOMId] FOREIGN KEY (intItemUOMId) REFERENCES [tblICItemUOM](intItemUOMId)
	,CONSTRAINT [FK_tblMFDemandDetail_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY (intCompanyLocationId) REFERENCES [tblSMCompanyLocation](intCompanyLocationId)
	)
