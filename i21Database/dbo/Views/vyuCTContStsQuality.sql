CREATE VIEW [dbo].[vyuCTContStsQuality]

AS 
	SELECT	intSampleId,
			intContractDetailId,
			strSampleNumber,
			strSampleTypeName,
			dblSampleQty,
			strStatus
	FROM	vyuQMSampleList
