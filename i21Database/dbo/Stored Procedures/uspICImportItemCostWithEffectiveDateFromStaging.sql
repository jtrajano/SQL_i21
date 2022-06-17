CREATE PROCEDURE uspICImportItemCostWithEffectiveDateFromStaging   
 @strIdentifier NVARCHAR(100)  
 , @ysnAllowOverwrite BIT = 0  
 , @ysnVerboseLog BIT = 1  
 , @intDataSourceId INT = 2  
AS  

--DECLARE @strIdentifier NVARCHAR(100)  ='f557a07e-5bde-425f-8942-1695bd2d56dc'
-- , @ysnAllowOverwrite BIT = 0  
-- , @ysnVerboseLog BIT = 0  
-- , @intDataSourceId INT = 2  


DELETE FROM tblICImportStagingItemCostWithEffectiveDate WHERE strImportIdentifier <> @strIdentifier  
  
;WITH cte AS  
(  
   SELECT *, ROW_NUMBER() OVER(PARTITION BY strItemNo, strLocation, dtmEffectiveDate, dblCost ORDER BY strItemNo, strLocation, dtmEffectiveDate, dblCost) AS RowNumber  
   FROM tblICImportStagingItemCostWithEffectiveDate  
   WHERE strImportIdentifier = @strIdentifier  
)  
DELETE FROM cte WHERE RowNumber > 1;  

DECLARE @intImportLogId INT = (SELECT TOP 1 intImportLogId FROM tblICImportLog WHERE strUniqueId = @strIdentifier)

-------------------------------------------------------------------------  
-- BEGIN Validate records  
-------------------------------------------------------------------------  
BEGIN  
 -- Get the duplicate records  
 DECLARE @tblDuplicateItemNo TABLE(  
   strItemNo NVARCHAR(200)  
  ,intId INT   
 )
 
 INSERT INTO @tblDuplicateItemNo (strItemNo, intId)  
 SELECT strItemNo, intId  
	 FROM  
	 (  
	  SELECT   
	   *  
	   ,RowNumber = ROW_NUMBER() OVER(PARTITION BY strItemNo ORDER BY strItemNo)   
	   ,intId = ROW_NUMBER() OVER(ORDER BY intImportStagingItemCostWithEffectiveDateId)  
	  FROM   
	   tblICImportStagingItemCostWithEffectiveDate  
	  WHERE   
	   strImportIdentifier = @strIdentifier  
	 ) AS DuplicateCounter  

	 WHERE RowNumber > 1  
END   


--Create Log Table
	DECLARE @tblErrorItemCost TABLE(
		intImportStagingItemCostWithEffectiveDateId INT,
		intImportLogId INT,
		strType NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		intRecordNo INT NULL,
		strField NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		strValue NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		strMessage NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		strStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		strAction NVARCHAR(200) COLLATE Latin1_General_CI_AS,
		intConcurrencyId INT

	)
	


-- validate records for logs
BEGIN 
	
	--Check invalid Item no.
	
	INSERT INTO @tblErrorItemCost(intImportStagingItemCostWithEffectiveDateId, intImportLogId, strType, intRecordNo, strField, strValue, strMessage, strStatus, strAction, intConcurrencyId)
	SELECT
	    intImportStagingItemCostWithEffectiveDateId,
		@intImportLogId,
		'Error' AS strType,
		NULL AS intRecordNo,
		'Item No' AS strField,
		strItemNo AS strValue,
		'Invalid Item No' AS strMessage,
		'Failed' AS Status,
		'Skipped' AS strAction,
		1 AS intConcurrencyId
	FROM tblICImportStagingItemCostWithEffectiveDate
	WHERE strImportIdentifier = @strIdentifier
	AND strItemNo NOT IN  ( SELECT strItemNo FROM tblICItem )

	--Check invalid Location.
	
	INSERT INTO @tblErrorItemCost(intImportStagingItemCostWithEffectiveDateId, intImportLogId, strType, intRecordNo, strField, strValue, strMessage, strStatus, strAction, intConcurrencyId)
	SELECT
		intImportStagingItemCostWithEffectiveDateId,
		@intImportLogId,
		'Error' AS strType,
		NULL AS intRecordNo,
		'Location' AS strField,
		strLocation AS strValue,
		'Invalid Location' AS strMessage,
		'Failed' AS Status,
		'Skipped' AS strAction,
		1 AS intConcurrencyId
	FROM tblICImportStagingItemCostWithEffectiveDate
	WHERE strImportIdentifier = @strIdentifier
	AND strLocation NOT IN  ( SELECT b.strLocationName FROM tblICItemLocation a INNER JOIN  tblSMCompanyLocation b ON a.intLocationId = b.intCompanyLocationId)

END

INSERT INTO tblICImportLogDetail(intImportLogId, 
								 strType, 
								 intRecordNo, 
								 strField, 
								 strValue, 
								 strMessage, 
								 strStatus, 
								 strAction, 
								 intConcurrencyId
								 ) 
SELECT intImportLogId, 
       strType, 
	   intRecordNo, 
	   strField, 
	   strValue, 
	   strMessage, 
	   strStatus, 
	   strAction, 
	   intConcurrencyId 

FROM @tblErrorItemCost
-------------------------------------------------------------------------  
-- END Validate records  
-------------------------------------------------------------------------  


IF EXISTS(SELECT * FROM @tblErrorItemCost)
BEGIN select * from tblICImportLog
	UPDATE tblICImportLog SET strDescription = 'Import Finished with Error' WHERE intImportLogId = @intImportLogId
END



CREATE TABLE #tmp (  
   intId INT IDENTITY(1, 1) PRIMARY KEY  
 , intItemId INT NULL  
 , intItemLocationId INT NULL  
 , intCompanyLocationId INT NULL  
 , dblCost NUMERIC(38, 20) NULL  
 , dtmEffectiveDate DATETIME NULL  
 , dtmDateCreated DATETIME NULL  
 , intCreatedByUserId INT NULL  
 ,intImportLogId INT
 ,strType NVARCHAR(200) COLLATE Latin1_General_CI_AS
 ,intRecordNo INT NULL
 ,strField NVARCHAR(200) COLLATE Latin1_General_CI_AS
 ,strValue NVARCHAR(200) COLLATE Latin1_General_CI_AS
 ,strMessage NVARCHAR(200) COLLATE Latin1_General_CI_AS
 ,strStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS
 ,strAction NVARCHAR(200) COLLATE Latin1_General_CI_AS
 ,intConcurrencyId INT
)  
  
INSERT INTO #tmp  
(  
   intItemId      
 , intItemLocationId    
 , intCompanyLocationId  
 , dblCost  
 , dtmEffectiveDate  
 , dtmDateCreated    
 , intCreatedByUserId
 , intImportLogId 
 , strType 
 , intRecordNo 
 , strField 
 , strValue 
 , strMessage 
 , strStatus 
 , strAction 
 , intConcurrencyId




)  
SELECT  
   i.intItemId  AS intItemId
 , il.intItemLocationId  AS intItemLocationId
 , c.intCompanyLocationId  AS intCompanyLocationId
 , s.dblCost  AS dblCost
 , s.dtmEffectiveDate  AS dtmEffectiveDate
 , s.dtmDateCreated  AS dtmDateCreated  
 , s.intCreatedByUserId  AS intCreatedByUserId
 , @intImportLogId AS intImportLogId
 , 'Success' AS strType 
 , NULL AS intRecordNo 
 , '' AS strField 
 , 'Import Successful' AS strValue 
 , CONCAT('Success - Item: ', s.strItemNo, ' ,Location: ', s.strLocation) AS strMessage 
 , 'Success' AS strStatus 
 , 'Import Finished' AS strAction 
 , 1 AS intConcurrencyId

FROM tblICImportStagingItemCostWithEffectiveDate s  
 INNER JOIN tblICItem i ON LOWER(i.strItemNo) = LTRIM(RTRIM(LOWER(s.strItemNo)))   
 INNER JOIN tblSMCompanyLocation c ON LOWER(c.strLocationName) = LTRIM(RTRIM(LOWER(s.strLocation)))  
 INNER JOIN tblICItemLocation il ON il.intLocationId = c.intCompanyLocationId  
  AND il.intItemId = i.intItemId  
WHERE s.strImportIdentifier = @strIdentifier  
AND s.intImportStagingItemCostWithEffectiveDateId NOT IN (SELECT intImportStagingItemCostWithEffectiveDateId FROM @tblErrorItemCost)
  

-- Generate successful import logs..

INSERT INTO tblICImportLogDetail(intImportLogId, 
								 strType, 
								 intRecordNo, 
								 strField, 
								 strValue, 
								 strMessage, 
								 strStatus, 
								 strAction, 
								 intConcurrencyId
								 ) 
SELECT intImportLogId, 
       strType, 
	   intRecordNo, 
	   strField, 
	   strValue, 
	   strMessage, 
	   strStatus, 
	   strAction, 
	   intConcurrencyId 

FROM #tmp

CREATE TABLE #output (  
   intItemIdDeleted INT NULL  
 , strAction NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL  
 , intItemIdInserted INT NULL  
)  
  
;MERGE INTO tblICEffectiveItemCost AS target  
USING  
(  
 SELECT  
   intItemId      
 , intItemLocationId   
 , intCompanyLocationId  
 , dblCost     
 , dtmEffectiveDate  
 , dtmDateCreated    
 , intCreatedByUserId  
 FROM #tmp s  
) AS source   
 ON target.intItemId = source.intItemId  
 AND target.intItemLocationId = source.intItemLocationId  
 AND target.dtmEffectiveCostDate = source.dtmEffectiveDate  
WHEN MATCHED THEN  
 UPDATE SET  
    intItemId     = source.intItemId  
  , intItemLocationId   = source.intItemLocationId  
  , dblCost     = source.dblCost  
  , dtmEffectiveCostDate  = source.dtmEffectiveDate  
  , dtmDateModified   = GETUTCDATE()  
  , intModifiedByUserId    = source.intCreatedByUserId  
  , intImportFlagInternal  = 1  
WHEN NOT MATCHED THEN  
 INSERT  
 (  
    intItemId      
  , intItemLocationId    
  , dblCost    
  , dtmEffectiveCostDate  
  , dtmDateCreated    
  , intCreatedByUserId  
  , intDataSourceId  
  , intImportFlagInternal  
 )  
 VALUES  
 (  
  intItemId      
  , intItemLocationId    
  , dblCost    
  , dtmEffectiveDate     
  , dtmDateCreated    
  , intCreatedByUserId  
  , @intDataSourceId  
  , 1  
 )  
 OUTPUT deleted.intItemId, $action, inserted.intItemId INTO #output;  
  
--EXEC dbo.uspICUpdateItemImportedPricingLevel  
  
---- Logs   
--BEGIN   
-- INSERT INTO tblICImportLogFromStaging (  
--  [strUniqueId]   
--  ,[intRowsImported]   
--  ,[intRowsUpdated]   
-- )  
-- SELECT  
--  @strIdentifier  
--  ,intRowsImported = (SELECT COUNT(*) FROM #output WHERE strAction = 'INSERT')  
--  ,intRowsUpdated = (SELECT COUNT(*) FROM #output WHERE strAction = 'UPDATE')  
--END  


-- Logs   
BEGIN   
 DECLARE   
  @intRowsImported AS INT   
  ,@intRowsUpdated AS INT  
  ,@intRowsSkipped AS INT  
  ,@intRowDuplicates AS INT  
  
 SELECT @intRowsImported = COUNT(*) FROM #output WHERE strAction = 'INSERT'  
 SELECT @intRowsUpdated = COUNT(*) FROM #output WHERE strAction = 'UPDATE'  
 SELECT @intRowDuplicates = COUNT(*) FROM @tblDuplicateItemNo  
 SELECT   
  @intRowsSkipped = ISNULL(@intRowDuplicates, 0) + (COUNT(1) - ISNULL(@intRowsImported, 0) - ISNULL(@intRowsUpdated, 0))  
 FROM   
  tblICImportStagingItemCostWithEffectiveDate s  
 WHERE  
  s.strImportIdentifier = @strIdentifier  
  
 INSERT INTO tblICImportLogFromStaging (  
  [strUniqueId]   
  ,[intRowsImported]   
  ,[intRowsUpdated]   
  ,[intRowsSkipped]  
 )  
 SELECT  
  @strIdentifier  
  ,intRowsImported = ISNULL(@intRowsImported, 0)  
  ,intRowsUpdated = ISNULL(@intRowsUpdated, 0)   
  ,intRowsSkipped = ISNULL(@intRowsSkipped, 0)  
 
END
  
DROP TABLE #tmp  
DROP TABLE #output  
  
DELETE FROM [tblICImportStagingItemCostWithEffectiveDate] WHERE strImportIdentifier = @strIdentifier