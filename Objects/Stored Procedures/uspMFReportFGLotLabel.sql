CREATE PROCEDURE uspMFReportFGLotLabel  
 @xmlParam NVARCHAR(MAX) = NULL  
AS  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
BEGIN TRY  
 DECLARE @strErrMsg NVARCHAR(MAX)  
 DECLARE @strLotNo NVARCHAR(100), @xmlDocumentId INT  
  
 IF LTRIM(RTRIM(@xmlParam)) = ''  
  SET @xmlParam = NULL  
  
 DECLARE @temp_xml_table TABLE (  
    [fieldname] NVARCHAR(50),   
    condition NVARCHAR(20),   
    [from] NVARCHAR(50),   
    [to] NVARCHAR(50),   
    [join] NVARCHAR(10),   
    [begingroup] NVARCHAR(50),   
    [endgroup] NVARCHAR(50),   
    [datatype] NVARCHAR(50))  
  
 EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT, @xmlParam  
  
 INSERT INTO @temp_xml_table  
 SELECT *  
 FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)   
 WITH ([fieldname] NVARCHAR(50),   
    condition NVARCHAR(20),   
    [from] NVARCHAR(50),   
    [to] NVARCHAR(50),   
    [join] NVARCHAR(10),   
    [begingroup] NVARCHAR(50),   
    [endgroup] NVARCHAR(50),   
    [datatype] NVARCHAR(50))  
  
 SELECT @strLotNo = [from]  
 FROM @temp_xml_table  
 WHERE [fieldname] = 'strLotNo'  
  
 SELECT TOP 1 L.intLotId,   
     L.strLotNumber,   
     M.intItemId,   
     M.strItemNo AS 'strItemNo',   
     M.strDescription AS 'strItemDescription',   
     L.dblQty QueuedQty,   
     CAST(L.dtmDateCreated AS DATETIME) AS MFG  
 FROM dbo.tblICLot AS L  
 JOIN dbo.tblICItem AS M ON L.intItemId = M.intItemId  
 WHERE L.strLotNumber = @strLotNo  AND L.dblQty > 0
   
END TRY  
  
BEGIN CATCH  
 SET @strErrMsg = 'uspMFReportLotLabel - ' + ERROR_MESSAGE()  
  
 RAISERROR (@strErrMsg, 18, 1, 'WITH NOWAIT')  
END CATCH