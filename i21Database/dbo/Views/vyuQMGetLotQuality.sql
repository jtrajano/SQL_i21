CREATE VIEW [dbo].[vyuQMGetLotQuality]
	AS 
SELECT intProductValueId AS intLotId
	,intSampleId
	,Moisture
	,case when ISNULL(Density,0)='' then 0.0 else isnull(CONVERT(DECIMAL(24,2),Density), 0.0) end AS Density
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
		AND ISNUMERIC(TR.strPropertyValue) = 1
		AND P.strPropertyName IN (
			'Moisture'
			,'Density'
			,'Color'
			,'Brightness'
			,'Thickness'
			,'Taste'
			)
	WHERE TR.intProductTypeId = (CASE WHEN (Select TOP 1 ISNULL(ysnEnableParentLot,0) From tblMFCompanyPreference) = 1 THEN 11 ELSE 6 END)
		AND TR.intSampleId = (
			SELECT MAX(intSampleId)
			FROM tblQMTestResult
			WHERE intProductValueId = TR.intProductValueId
				AND intProductTypeId = (CASE WHEN (Select TOP 1 ISNULL(ysnEnableParentLot,0) From tblMFCompanyPreference) = 1 THEN 11 ELSE 6 END)
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
