﻿CREATE TABLE [dbo].[tblCTContractPlan]
(
	[intContractPlanId] INT IDENTITY(1,1) NOT NULL, 
    [strContractPlan] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intContractTypeId] INT NULL, 
	[intCommodityId] INT NULL, 
	[intPositionId] INT NULL, 
	[intPricingTypeId] INT NULL, 
	[intTermId] INT NULL, 
	[intGradeId] INT NULL, 
	[intWeightId] INT NULL, 
	[dtmStartDate] DATETIME NULL, 
    [dtmEndDate] DATETIME NULL, 
    [ysnMaxPrice] BIT NULL, 
	[ysnUnlimitedQuantity] BIT NULL, 
	[ysnSubstituteItem] BIT NULL, 
    [intItemId] INT NULL, 
    [dblPrice] NUMERIC(18, 6) NULL,
	[intSalespersonId] INT NULL, 
	[intContractTextId] INT NULL, 
	[intAssociationId] INT NULL, 
	[intCropYearId] INT NULL, 
	[intCompanyLocationId] INT NULL, 
	[ysnActive] BIT NULL,
    [intConcurrencyId] INT NOT NULL,
	[intContractBasisId] [INT] NULL,

	CONSTRAINT [PK_tblCTContractPlan_intContractPlanId] PRIMARY KEY CLUSTERED ([intContractPlanId] ASC),
	CONSTRAINT [FK_tblCTContractPlan_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblCTContractPlan_tblSMFreightTerms_intContractBasisId] FOREIGN KEY ([intContractBasisId]) REFERENCES [tblSMFreightTerms]([intFreightTermId]),

	CONSTRAINT [FK_tblCTContractPlan_tblCTAssociation_intAssociationId] FOREIGN KEY (intAssociationId) REFERENCES tblCTAssociation(intAssociationId),
	CONSTRAINT [FK_tblCTContractPlan_tblICCommodity_intCommodityId] FOREIGN KEY (intCommodityId) REFERENCES tblICCommodity(intCommodityId),
	CONSTRAINT [FK_tblCTContractPlan_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY (intCompanyLocationId) REFERENCES tblSMCompanyLocation(intCompanyLocationId),
	CONSTRAINT [FK_tblCTContractPlan_tblCTContractText_intContractTextId] FOREIGN KEY (intContractTextId) REFERENCES tblCTContractText(intContractTextId),
	CONSTRAINT [FK_tblCTContractPlan_tblCTContractType_intContractTypeId] FOREIGN KEY (intContractTypeId) REFERENCES tblCTContractType(intContractTypeId),
	CONSTRAINT [FK_tblCTContractPlan_tblCTCropYear_intCropYearId] FOREIGN KEY (intCropYearId) REFERENCES tblCTCropYear(intCropYearId),
	CONSTRAINT [FK_tblCTContractPlan_tblCTWeightGrade_intGradeId] FOREIGN KEY (intGradeId) REFERENCES tblCTWeightGrade(intWeightGradeId),
	CONSTRAINT [FK_tblCTContractPlan_tblCTPosition_intPositionId] FOREIGN KEY (intPositionId) REFERENCES tblCTPosition(intPositionId),
	CONSTRAINT [FK_tblCTContractPlan_tblCTPricingType_intPricingTypeId] FOREIGN KEY (intPricingTypeId) REFERENCES tblCTPricingType(intPricingTypeId),
	CONSTRAINT [FK_tblCTContractPlan_tblEMEntity_intSalespersonId] FOREIGN KEY (intSalespersonId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [FK_tblCTContractPlan_tblSMTerm_intTermId] FOREIGN KEY (intTermId) REFERENCES tblSMTerm(intTermID),
	CONSTRAINT [FK_tblCTContractPlan_tblCTWeightGrade_intWeightId] FOREIGN KEY (intWeightId) REFERENCES tblCTWeightGrade(intWeightGradeId)
)
