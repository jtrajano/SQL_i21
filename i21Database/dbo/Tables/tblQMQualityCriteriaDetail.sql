CREATE TABLE [dbo].[tblQMQualityCriteriaDetail]
(
	intQualityCriteriaDetailId	INT NOT NULL IDENTITY, 
	[intConcurrencyId]			INT NULL CONSTRAINT [DF_tblQMQualityCriteriaDetail_intConcurrencyId] DEFAULT 0, 
	intQualityCriteriaId		INT NOT NULL, 

	intPropertyId				INT NOT NULL, 
	dblTargetValue				NUMERIC(18, 6),
	dblMinValue					NUMERIC(18, 6),
	dblMaxValue					NUMERIC(18, 6),
	dblFactorOverTarget			NUMERIC(18, 6),
	dblPremium					NUMERIC(18, 6),
	dblFactorUnderTarget		NUMERIC(18, 6),
	dblDiscount					NUMERIC(18, 6),
	strCostMethod				NVARCHAR(30) COLLATE Latin1_General_CI_AS,
	intCurrencyId				INT,
	intUnitMeasureId			INT,
		
	CONSTRAINT [PK_tblQMQualityCriteriaDetail] PRIMARY KEY (intQualityCriteriaDetailId), 
	CONSTRAINT [FK_tblQMQualityCriteriaDetail_tblQMQualityCriteria] FOREIGN KEY (intQualityCriteriaId) REFERENCES [tblQMQualityCriteria](intQualityCriteriaId) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblQMQualityCriteriaDetail_tblQMProperty] FOREIGN KEY (intPropertyId) REFERENCES [tblQMProperty](intPropertyId),
	CONSTRAINT [FK_tblQMQualityCriteriaDetail_tblSMCurrency] FOREIGN KEY (intCurrencyId) REFERENCES [tblSMCurrency](intCurrencyID),
	CONSTRAINT [FK_tblQMQualityCriteriaDetail_tblICUnitMeasure] FOREIGN KEY (intUnitMeasureId) REFERENCES [tblICUnitMeasure](intUnitMeasureId)
)