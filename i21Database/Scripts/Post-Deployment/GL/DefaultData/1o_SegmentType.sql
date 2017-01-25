﻿/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/


--GL=3146 Add line of business selection to chart of accounts
MERGE 
INTO	dbo.tblGLSegmentType
WITH	(HOLDLOCK) 
AS		SegmentTypeTable
USING	(
select id=1, name='Primary' union all
select id=2, name='Divider' union all
select id=3, name='Location' union all
select id=4, name='Segment' union all
select id=5, name='Line Of Business'
) AS SegmentTypeCodedValues
		ON  SegmentTypeTable.intSegmentTypeId = SegmentTypeCodedValues.id
WHEN MATCHED THEN 
		UPDATE 
		SET 	SegmentTypeTable.strSegmentType = SegmentTypeCodedValues.name
	-- When id is missing, then do an insert. 
WHEN NOT MATCHED THEN
INSERT (
	intSegmentTypeId
	,strSegmentType
	,intConcurrencyId
)
VALUES (
	SegmentTypeCodedValues.id
	,SegmentTypeCodedValues.name
	,1
);
GO

--GL-31477 make segment type location which are named location in account structure
UPDATE tblGLAccountStructure set strType = 'Segment' where  rtrim(lower(strStructureName)) = 'location'
GO