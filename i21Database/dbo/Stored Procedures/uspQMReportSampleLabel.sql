﻿CREATE PROCEDURE [dbo].[uspQMReportSampleLabel] 
(
	@xmlParam NVARCHAR(MAX) = NULL
)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
BEGIN TRY
	DECLARE @ErrMsg			NVARCHAR(MAX)
		  , @intSampleId	INT
		  , @xmlDocumentId	INT

	IF (LTRIM(RTRIM(@xmlParam)) = '')
		BEGIN
			SET @xmlParam = NULL;
		END

	DECLARE @temp_xml_table TABLE 
	(
		fieldname	NVARCHAR(50)
	  , condition	NVARCHAR(20)
	  , [from]		NVARCHAR(50)
	  , [to]		NVARCHAR(50)
	  , [join]		NVARCHAR(10)
	  , begingroup	NVARCHAR(50)
	  , endgroup	NVARCHAR(50)
	  , datatype	NVARCHAR(50)
	)

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT
							  , @xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) 
	WITH 
	(
		fieldname	NVARCHAR(50)
	  , condition	NVARCHAR(20)
	  , [from]		NVARCHAR(50)
	  , [to]		NVARCHAR(50)
	  , [join]		NVARCHAR(10)
	  , begingroup	NVARCHAR(50)
	  , endgroup	NVARCHAR(50)
	  , datatype	NVARCHAR(50)
	)

	SELECT @intSampleId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intSampleId';

	SELECT TOP 1 I.strItemNo
			   , I.strDescription
			   , S.strSampleNumber
			   , DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), S.dtmSampleReceivedDate) AS dtmSampleReceivedDate
			   , CASE WHEN S.intProductTypeId = 11 THEN ISNULL(L.strLotNumber, S.strLotNumber)
					  ELSE ISNULL(L1.strLotNumber, S.strLotNumber)
				 END AS strLotNumber
			   , ISNULL(PL.strParentLotNumber,'') AS strParentLotNumber
			   , ST.strDescription AS strSampleTypeDescription
			   , C.strCategoryCode
			   , @intSampleId AS intSampleId
			   , ISNULL(S.strRefNo,'') AS BPCSPoNumber
			   , ST.strDescription + ', ' + S.strSampleNumber AS strSampleTypeDescandNumber
	FROM tblQMSample S
	JOIN tblQMSampleType ST ON S.intSampleTypeId = ST.intSampleTypeId
	JOIN tblICItem I ON S.intItemId = I.intItemId
	JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
	LEFT JOIN tblICParentLot PL ON PL.intParentLotId = S.intProductValueId AND S.intProductTypeId = 11
	LEFT JOIN tblICLot L ON PL.intParentLotId = L.intParentLotId
	LEFT JOIN tblICLot L1 ON L1.intLotId = S.intProductValueId AND S.intProductTypeId = 6
	WHERE S.intSampleId = @intSampleId

END TRY
BEGIN CATCH
	SET @ErrMsg = 'uspQMReportSampleLabel - ' + ERROR_MESSAGE()

	RAISERROR
	(
		@ErrMsg
	  , 18
	  , 1
	  , 'WITH NOWAIT'
	)
END CATCH