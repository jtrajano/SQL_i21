CREATE VIEW vyuSTItemUOMUpcCodeToNumeric
AS
SELECT intItemUOMId
					, intItemId
					, strUpcCode
					, strLongUPCCode
					, CASE 
						WHEN strUpcCode NOT LIKE '%[^0-9]%' 
							THEN CONVERT(NUMERIC(32, 0),CAST(strUpcCode AS FLOAT))
						ELSE NULL
					END AS intUpcCode
					, CASE 
						WHEN strLongUPCCode NOT LIKE '%[^0-9]%' 
							THEN CONVERT(NUMERIC(32, 0),CAST(strLongUPCCode AS FLOAT))
						ELSE NULL
					END AS intLongUpcCode 
				FROM dbo.tblICItemUOM