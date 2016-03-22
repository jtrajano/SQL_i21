CREATE VIEW [dbo].[vyuCTContStsQuality]

AS 
	SELECT	intSampleId,
			intContractDetailId,
			strSampleNumber,
			strSampleTypeName,
			dbo.fnCTConvertQuantityToTargetItemUOM(QS.intItemId,QS.intSampleUOMId,LP.intWeightUOMId,dblSampleQty) dblSampleQty,
			strStatus
	FROM	vyuQMSampleList			QS	CROSS	
	APPLY	tblLGCompanyPreference	LP 	
