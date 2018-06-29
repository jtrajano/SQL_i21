CREATE PROCEDURE  [dbo].[uspFRDValidateDesign]
@intUserId			AS INT,
@successfulCount	AS INT = 0 OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
	
	DELETE tblFRValidateDesign WHERE dtmEntered < DATEADD(day, -1, GETDATE()) OR intUserId = @intUserId;
		
	INSERT INTO tblFRValidateDesign (intDesign,intType,strType,strName,strDescription,intUserId)
		SELECT intDesign, intType, strType, strName, strDescription, @intUserId
		FROM (
			SELECT A.intRowId as intDesign
				,1 as intType
				,'Row Designer' as strType
				,strName = (select tblFRRow.strRowName from tblFRRow WHERE tblFRRow.intRowId = A.intRowId)
				,strDescription = 'Missing Filter Accounts at ID: ' + CAST(A.intRefNo AS NVARCHAR(20))
			FROM tblFRRowDesign A 
			WHERE A.strRowType IN ('Calculation','Cash Flow Activity','Hidden') AND LEN(A.strAccountsUsed) < 5
			UNION
			SELECT B.intRowId as intDesign
				,1 as intType
				,'Row Designer' as strType
				,strName = (select tblFRRow.strRowName from tblFRRow WHERE tblFRRow.intRowId = B.intRowId)
				,strDescription = 'Missing Related Rows at ID: ' + CAST(B.intRefNo AS NVARCHAR(20))
			FROM tblFRRowDesign B 
			WHERE B.strRowType IN ('Total Calculation') AND LEN(B.strRelatedRows) < 1
			UNION
			SELECT C.intColumnId as intDesign
				,2 as intType
				,'Column Designer' as strType
				,strName = (select tblFRColumn.strColumnName from tblFRColumn WHERE tblFRColumn.intColumnId = C.intColumnId)
				,strDescription = 'Missing Budget Code at ID: ' + CAST(C.intRefNo AS NVARCHAR(20))
			FROM tblFRColumnDesign C 
			WHERE C.strColumnType IN ('Budget','GL Trend') AND C.intBudgetCode IS NULL
			UNION
			SELECT D.intColumnId as intDesign
				,2 as intType
				,'Column Designer' as strType
				,strName = (select tblFRColumn.strColumnName from tblFRColumn WHERE tblFRColumn.intColumnId = D.intColumnId)
				,strDescription = 'Missing Segments at ID: ' + CAST(D.intRefNo AS NVARCHAR(20))
			FROM tblFRColumnDesign D 
			WHERE D.strColumnType IN ('Segment Filter') AND LEN(ISNULL(D.strSegmentUsed,'')) < 1
			UNION
			SELECT E.intColumnId as intDesign
				,2 as intType
				,'Column Designer' as strType
				,strName = (select tblFRColumn.strColumnName from tblFRColumn WHERE tblFRColumn.intColumnId = E.intColumnId)
				,strDescription = 'Missing Related Columns at ID: ' + CAST(E.intRefNo AS NVARCHAR(20))
			FROM tblFRColumnDesign E 
			WHERE E.strColumnType IN ('Column Calculation','Ending Balance') AND LEN(ISNULL(E.strColumnFormula,'')) < 1
			UNION
			SELECT F.intColumnId as intDesign
				,2 as intType
				,'Column Designer' as strType
				,strName = (select tblFRColumn.strColumnName from tblFRColumn WHERE tblFRColumn.intColumnId = F.intColumnId)
				,strDescription = 'Missing Start and End Dates at ID: ' + CAST(F.intRefNo AS NVARCHAR(20))
			FROM tblFRColumnDesign F
			WHERE F.strColumnType IN ('Budget','Calculation','Credit','Credit Units','Debit','Debit Units','Segment Filter','GL Trend') AND F.strFilterType = 'Custom' AND F.dtmStartDate IS NULL AND F.dtmEndDate IS NULL
			UNION
			SELECT G.intHeaderId as intDesign
				,3 as intType
				,strType = (select tblFRHeader.strHeaderType from tblFRHeader WHERE tblFRHeader.intHeaderId = G.intHeaderId)
				,strName = (select tblFRHeader.strHeaderName from tblFRHeader WHERE tblFRHeader.intHeaderId = G.intHeaderId)
				,strDescription = 'Missing Column Reference at Detail Description: ' + G.strDescription
			FROM tblFRHeaderDesign G
			WHERE G.strWith IN ('Column') AND G.intColumnRefNo IS NULL
			UNION
			SELECT H.intReportId as intDesign
				,4 as intType
				,'Report Builder' as strType
				,strName = H.strReportName
				,strDescription = 'Missing Row Id'
			FROM tblFRReport H 
			WHERE H.intRowId IS NULL
			UNION
			SELECT I.intReportId as intDesign
				,4 as intType
				,'Report Builder' as strType
				,strName = I.strReportName
				,strDescription = 'Missing Column Id'
			FROM tblFRReport I 
			WHERE I.intColumnId IS NULL
			UNION
			SELECT J.intReportId as intDesign
				,4 as intType
				,'Report Builder' as strType
				,strName = J.strReportName
				,strDescription = 'Kindly check your Segment Filter record details'
			FROM tblFRReport J
			LEFT JOIN tblFRSegmentFilterGroup K ON J.intSegmentCode = K.intSegmentFilterGroupId
			WHERE LEN(K.strFilterString) < 5
		) tmpDesigners
	
	SET @successfulCount = ISNULL(@successfulCount,0) + (SELECT COUNT(*) FROM tblFRValidateDesign WHERE intUserId = @intUserId)
	
END



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------
--DECLARE @intUserId AS INT

--EXEC [dbo].[uspFRDValidateDesign]
--			@intUserId	 = 1,						-- Entity Id			
--			@successfulCount = @intCount OUTPUT		-- OUTPUT PARAMETER THAT RETURNS INVALID DESIGN COUNT
				
--SELECT @successfulCount

