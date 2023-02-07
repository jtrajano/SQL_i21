CREATE VIEW [dbo].[vyuQMGetBatchControlPoint]    
AS    
	SELECT ControlPoint.intControlPointId
		 , ControlPoint.strControlPointName 
		 , QualitySample.intSampleId
		 , QualitySample.intProductValueId
		 , QualitySample.intProductTypeId
	FROM tblQMSample AS QualitySample
	JOIN tblQMSampleType AS SampleType ON QualitySample.intSampleTypeId = SampleType.intSampleTypeId
	JOIN tblQMControlPoint AS ControlPoint ON SampleType.intControlPointId = ControlPoint.intControlPointId
GO

