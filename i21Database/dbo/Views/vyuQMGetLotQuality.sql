CREATE VIEW [dbo].[vyuQMGetLotQuality]
	AS 
SELECT intProductValueId AS intLotId
	,intSampleId
	,Moisture
	,Density
	,Color
	,Brightness
	,Thickness
	,Taste
	,(cast((convert(DECIMAL(24, 2), isnull(Brightness, 0)) 
			+ convert(DECIMAL(24, 2), isnull(Color, 0)) 
			+ convert(DECIMAL(24, 2), isnull(Thickness, 0)) 
			+ convert(DECIMAL(24, 2), isnull(Taste, 0)))  
      /(  
            (  
                  CASE   
                        WHEN isnull(CONVERT(DECIMAL(24,2),Brightness), 0) = 0  
                              THEN 0  
                        ELSE 1  
                        END  
                  ) + (  
                  CASE   
                        WHEN isnull(CONVERT(DECIMAL(24,2),Color), 0) = 0  
                              THEN 0  
                        ELSE 1  
                        END  
                  ) + (  
                  CASE   
                        WHEN isnull(CONVERT(DECIMAL(24,2),Thickness), 0) = 0  
                              THEN 0  
                        ELSE 1  
                        END  
                  ) + (  
                  CASE   
                        WHEN isnull(CONVERT(DECIMAL(24,2),Taste), 0) = 0  
                              THEN 0  
                        ELSE 1  
                        END  
                  ) + (  
                  CASE   
                        WHEN isnull(CONVERT(DECIMAL(24,2),Brightness), 0) = 0  
                              AND isnull(CONVERT(DECIMAL(24,2),Color), 0) = 0  
                              AND isnull(CONVERT(DECIMAL(24,2),Thickness), 0) = 0  
                              AND isnull(CONVERT(DECIMAL(24,2),Taste), 0) = 0  
                              THEN 1  
                        ELSE 0  
                        END  
                  )  
                  ) as decimal(24,2))  
            )  
      AS Score
FROM (
	SELECT P.strPropertyName
		,TR.intProductTypeId
		,TR.intProductValueId
		,TR.intSampleId
		,TR.strPropertyValue
	FROM tblQMTestResult TR
	INNER JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
		AND P.strPropertyName IN (
			'Moisture'
			,'Density'
			,'Color'
			,'Brightness'
			,'Thickness'
			,'Taste'
			)
	WHERE TR.intProductTypeId = 6
		AND TR.intSampleId = (
			SELECT MAX(intSampleId)
			FROM tblQMTestResult
			WHERE intProductValueId = TR.intProductValueId
				AND intProductTypeId = 6
			)
	GROUP BY P.strPropertyName
		,TR.intProductTypeId
		,TR.intProductValueId
		,TR.intSampleId
		,strPropertyValue
	) SrcQry
PIVOT(MIN(strPropertyValue) FOR [strPropertyName] IN (
			Moisture
			,Density
			,Color
			,Brightness
			,Thickness
			,Taste
			)) Pvt
