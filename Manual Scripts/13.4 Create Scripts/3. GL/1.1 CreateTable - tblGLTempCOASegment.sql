
IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tempDASTable') DROP TABLE tempDASTable 
IF EXISTS (SELECT top 1 1  FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblGLTempCOASegment') DROP TABLE tblGLTempCOASegment

                                DECLARE @Segments NVARCHAR(MAX)
                                SELECT @Segments = SUBSTRING((SELECT '],[' + strStructureName FROM tblGLAccountStructure WHERE strType <> 'Divider' FOR XML PATH('')),3,200000) + ']'
                                DECLARE @Query NVARCHAR(MAX)
                                SET @Query = 
                                'SELECT A.intAccountID, DAS.* INTO tblGLTempCOASegment FROM tblGLAccount A
                                INNER JOIN (
                                 SELECT *  FROM (
                                   SELECT DISTINCT
                                   A.strAccountID 
                                   ,C.strCode
                                   ,D.strStructureName
                                    from tblGLAccount A INNER JOIN tblGLAccountSegmentMapping B 
                                      ON A.intAccountID = B.intAccountID
                                   INNER JOIN tblGLAccountSegment C
                                    ON B.intAccountSegmentID = C.intAccountSegmentID
                                   INNER JOIN  tblGLAccountStructure D 
                                    ON C.intAccountStructureID = D.intAccountStructureID
                                  ) AS tempTable
                                 PIVOT
                                 (
                                 MIN(strCode)
                                 FOR strStructureName IN (' + @Segments + ')) AS PVT
                                 ) AS DAS
                                ON A.strAccountID = DAS.strAccountID
                                '
								--select @Segments
                                EXEC sp_executesql @Query
                                
