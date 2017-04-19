
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 1
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 1
		,'Process Run Duration'
		,5
		,4
		,'Select strManufacturingProcessRunDurationName as ValueMember,strManufacturingProcessRunDurationName as DisplayMember from tblMFManufacturingProcessRunDuration'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 2
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 2
		,'Container Type'
		,5
		,4
		,'Select strDisplayMember as ValueMember,strDisplayMember as DisplayMember from tblICContainerType'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 3
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 3
		,'Is Container Mandatory'
		,5
		,4
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 4
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 4
		,'Is LotAlias Mandatory'
		,5
		,4
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 5
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 5
		,'Is Reading Entry Mandatory'
		,5
		,4
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 6
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 6
		,'Produce Lot Status'
		,5
		,1
		,'Select convert(varchar,intLotStatusId) as ValueMember,strSecondaryStatus as DisplayMember from tblICLotStatus'
END
Else
Begin
	Update tblMFAttribute Set strSQL='Select convert(varchar,intLotStatusId) as ValueMember,strSecondaryStatus as DisplayMember from tblICLotStatus' Where intAttributeId = 6
End
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 7
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 7
		,'Is Cycle Count Required'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
Else
Begin
	Update tblMFAttribute Set strAttributeName='Is Cycle Count Required' Where intAttributeId = 7
End
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 8
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 8
		,'Are Output Items Cycle Counted'
		,5
		,4
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 9
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		,ysnMultiSelect
		)
	SELECT 9
		,'Item Types Excluded From Cycle Count'
		,5
		,4
		,'Select ''None'' AS ValueMember,''None'' AS DisplayMember UNION SELECT ''Inventory'' as ValueMember,''Inventory'' as DisplayMember UNION Select ''Finished Good'' as ValueMember,''Finished Good'' as DisplayMember UNION Select ''Other Charge'' as ValueMember,''Other Charge'' as DisplayMember'
		,1
END
Else
Begin
	Update tblMFAttribute
	Set strSQL='Select ''None'' AS ValueMember,''None'' AS DisplayMember UNION SELECT ''Inventory'' as ValueMember,''Inventory'' as DisplayMember UNION Select ''Finished Good'' as ValueMember,''Finished Good'' as DisplayMember UNION Select ''Other Charge'' as ValueMember,''Other Charge'' as DisplayMember'
		,ysnMultiSelect=1
	Where intAttributeId = 9
End
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 10
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 10
        ,'Create Blend Requirement From Demand'
        ,5
        ,2
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 11
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 11
        ,'Enable Auto Blend Sheet'
        ,5
        ,2
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 12
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 12
		,'Is Warehouse Release Mandatory'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 13
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 13
        ,'Calculate Blend Bin Size Using Item Density'
        ,5
        ,2
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 14
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 14
        ,'Calculate No Of Blend Sheet Using Blend Bin Size'
        ,5
        ,2
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 15
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 15
		,'GTIN Case Code Mandatory'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 16
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 16
		,'Is Input Quantity Read Only'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 17
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 17
		,'Is Lot No Editable'
		,5
		,4
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 18
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 18
		,'Is Negative Quantity Allowed'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 19
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 19
		,'Is Vendor Lot No Mandatory'
		,5
		,4
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 20
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 20
		,'Is Instant Consumption'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 21
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 21
		,'Is Yield Adjustment Allowed'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
DELETE FROM dbo.tblMFManufacturingProcessAttribute WHERE intAttributeId = 22 
DELETE FROM dbo.tblMFAttribute WHERE intAttributeId = 22 
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 23
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 23
		,'Time based Production'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 24
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 24
		,'Control Point'
		,5
		,1
		,'Select convert(varchar,intControlPointId) as ValueMember,strControlPointName as DisplayMember from tblQMControlPoint Order by intControlPointId'
END
GO
IF EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 25 and strAttributeName='Is Parent Lot'
        )
BEGIN
	DELETE
	FROM dbo.tblMFManufacturingProcessAttribute
	WHERE intAttributeId = 25

	DELETE
	FROM dbo.tblMFAttribute
	WHERE intAttributeId = 25
END
GO
IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttribute
		WHERE intAttributeId = 25
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 25
		,'Sample Type'
		,5
		,1
		,'Select convert(varchar,intSampleTypeId) as ValueMember,strSampleTypeName as DisplayMember from tblQMSampleType Order by strSampleTypeName'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 26
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 26
		,'Is Quality Capture'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 27
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 27
        ,'Enable Kitting'
        ,5
        ,2
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
Go

IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 28
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 28
        ,'All input items mandatory for consumption'
        ,5
        ,1
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 29
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 29
        ,'Recipe Item Validity By Due Date'
        ,5
        ,2
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
Go
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 30
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 30
        ,'Lot Expiry By Due Date'
        ,5
        ,2
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
Go
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 31
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 31
        ,'Show Available Lots By Storage Location'
        ,5
        ,2
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
Go
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 32
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 32
        ,'Show Other Factory Lots'
        ,5
        ,2
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
Go
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 33
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 33
        ,'Add Other Factory Lots To Blend Sheet'
        ,5
        ,2
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
Go
IF EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 34 and strAttributeName='Populate Lot No only for target Item'
        )
BEGIN
	DELETE
	FROM dbo.tblMFManufacturingProcessAttribute
	WHERE intAttributeId = 34

	DELETE
	FROM dbo.tblMFAttribute
	WHERE intAttributeId = 34
END
Go
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 35
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 35
        ,'Pick List Preference'
        ,5
        ,2
        ,0
        ,'select CONVERT(VARCHAR,intPickListPreferenceId) AS ValueMember,strName AS DisplayMember from tblMFPickListPreference'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 36
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 36
        ,'Kit Staging Location'
        ,5
        ,2
        ,0
        ,'select CONVERT(VARCHAR,intStorageLocationId) AS ValueMember,strName AS DisplayMember from tblICStorageLocation'
END
Else
Begin
	Update tblMFAttribute SEt intAttributeTypeId =1 Where intAttributeId = 36
End
GO

IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 37
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        )
    SELECT 37
        ,'Delay Between Creating Pallets'
        ,2
        ,1
END
ELSE
BEGIN
	UPDATE tblMFAttribute SET intAttributeDataTypeId=2,ysnMultiSelect=NULL,strSQL=NULL WHERE intAttributeId = 37
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 38
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 38
		,'Product Case Code Scanning Required at Production'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 39
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 39
		,'Enable Print Label by Default'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 40
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 40
		,'GTIN Case Code Parameter Name'
		,6
		,3
		,''
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 41
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 41
		,'Create SKU/Container on Warehouse Release'
		,5
		,3
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 42
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 42
        ,'Blend Sheet Available Lots Status'
        ,5
        ,2
        ,1
        ,'Select convert(varchar,intLotStatusId) as ValueMember,strSecondaryStatus as DisplayMember from tblICLotStatus Where intLotStatusId in (1,2,3)'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 43
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 43
        ,'Partial Quantity Sub Location'
        ,5
        ,2
        ,0
        ,'select CONVERT(VARCHAR,intCompanyLocationSubLocationId) AS ValueMember,strSubLocationName AS DisplayMember from tblSMCompanyLocationSubLocation Where UPPER(strClassification)=UPPER(''Inventory'')'
END
ELSE
UPDATE tblMFAttribute 
	Set strAttributeName='Partial Quantity Sub Location',
	strSQL='select CONVERT(VARCHAR,intCompanyLocationSubLocationId) AS ValueMember,strSubLocationName AS DisplayMember from tblSMCompanyLocationSubLocation Where UPPER(strClassification)=UPPER(''Inventory'')'
	WHERE intAttributeId = 43
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 44
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 44
        ,'Warehouse Release Lot By Batch'
        ,5
        ,1
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 45
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 45
        ,'Default Storage Bin'
        ,5
        ,1
        ,0
        ,'Select convert(varchar,intStorageLocationId) as ValueMember,strName as DisplayMember from tblICStorageLocation'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 46
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 46
		,'Packaging Category'
		,5
		,1
		,'SELECT strCategoryCode AS ValueMember,strCategoryCode AS DisplayMember FROM tblICCategory'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 47
			
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 47
		,'Process Run Duration'
		,5
		,5
		,'Select strManufacturingProcessRunDurationName as ValueMember,strManufacturingProcessRunDurationName as DisplayMember from tblMFManufacturingProcessRunDuration'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 48
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 48
		,'Container Type'
		,5
		,5
		,'Select strDisplayMember as ValueMember,strDisplayMember as DisplayMember from tblICContainerType'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 49
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 49
		,'Is Container Mandatory'
		,5
		,5
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 50
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 50
		,'Is LotAlias Mandatory'
		,5
		,5
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 51
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 51
		,'Is Reading Entry Mandatory'
		,5
		,5
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 52
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 52
		,'Are Output Items Cycle Counted'
		,5
		,5
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 53
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 53
		,'Item Types Excluded From Cycle Count'
		,5
		,5
		,'Select ''None'' AS ValueMember,''None'' AS DisplayMember UNION SELECT ''Inventory'' as ValueMember,''Inventory'' as DisplayMember UNION Select ''Finished Good'' as ValueMember,''Finished Good'' as DisplayMember UNION Select ''Other Charge'' as ValueMember,''Other Charge'' as DisplayMember'
END
Else
Begin
	Update tblMFAttribute
	Set strSQL='Select ''None'' AS ValueMember,''None'' AS DisplayMember UNION SELECT ''Inventory'' as ValueMember,''Inventory'' as DisplayMember UNION Select ''Finished Good'' as ValueMember,''Finished Good'' as DisplayMember UNION Select ''Other Charge'' as ValueMember,''Other Charge'' as DisplayMember'
		,ysnMultiSelect=1
	Where intAttributeId = 53
end

GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 54
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 54
		,'Is Lot No Editable'
		,5
		,5
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 55
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 55
		,'Is Vendor Lot No Mandatory'
		,5
		,5
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 56
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 56
		,'Process Run Duration'
		,5
		,6
		,'Select strManufacturingProcessRunDurationName as ValueMember,strManufacturingProcessRunDurationName as DisplayMember from tblMFManufacturingProcessRunDuration'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 57
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 57
		,'Container Type'
		,5
		,6
		,'Select strDisplayMember as ValueMember,strDisplayMember as DisplayMember from tblICContainerType'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 58
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 58
		,'Is Container Mandatory'
		,5
		,6
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 59
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 59
		,'Is LotAlias Mandatory'
		,5
		,6
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 60
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 60
		,'Is Reading Entry Mandatory'
		,5
		,6
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 61
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 61
		,'Are Output Items Cycle Counted'
		,5
		,6
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 62
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 62
		,'Item Types Excluded From Cycle Count'
		,5
		,6
		,'Select ''None'' AS ValueMember,''None'' AS DisplayMember UNION SELECT ''Inventory'' as ValueMember,''Inventory'' as DisplayMember UNION Select ''Finished Good'' as ValueMember,''Finished Good'' as DisplayMember'
END

GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 63
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 63
		,'Is Lot No Editable'
		,5
		,6
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 64
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 64
		,'Is Vendor Lot No Mandatory'
		,5
		,6
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 65
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 65
        ,'Allow Auto Refresh'
        ,5
        ,2
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 66
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 66
        ,'Auto Refresh Time Interval In Seconds'
        ,2
        ,2
        ,0
        ,''
END
GO
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 67
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 67
        ,'Schedule Type'
        ,5
        ,3
        ,0
        ,'Select ''Forward Schedule'' as ValueMember,''Forward Schedule'' as DisplayMember UNION Select ''Backward Schedule'' as ValueMember,''Backward Schedule'' as DisplayMember'
END
GO

GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 68
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 68
		,'Blend Category'
		,5
		,3
		,'SELECT strCategoryCode AS ValueMember,strCategoryCode AS DisplayMember FROM tblICCategory'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 69
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 69
		,'Display actual consumption in WM'
		,5
		,5
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
ELSE
BEGIN
	UPDATE dbo.tblMFAttribute SET strAttributeName='Display Actual Consumption in WM' WHERE intAttributeId =69
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 70
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 70
		,'Status for Newly Created Work Order'
		,5
		,5
		,'Select strName As ValueMember, strName As DisplayMember From tblMFWorkOrderStatus Where intStatusId in (1,9,10)'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 71
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 71
		,'Future Date Production Allowed'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 72
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 72
        ,'Direct Transfer To Blend Floor'
        ,5
        ,2
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO

IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 73
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 73
        ,'Show Input Item In Yield View'
        ,5
        ,1
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 74
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 74
		,'Pick List Enabled'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 75
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 75
        ,'Production Staging Location'
        ,5
        ,1
        ,0
        ,'SELECT CONVERT(nvarchar,intStorageLocationId) AS ValueMember,strName AS DisplayMember FROM dbo.tblICStorageLocation SL JOIN dbo.tblICStorageUnitType UT ON SL.intStorageUnitTypeId = UT.intStorageUnitTypeId WHERE UT.strInternalCode = ''PROD_STAGING'''
END
ELSE
BEGIN
	UPDATE dbo.tblMFAttribute SET strSQL='SELECT CONVERT(nvarchar,intStorageLocationId) AS ValueMember,strName AS DisplayMember FROM dbo.tblICStorageLocation SL JOIN dbo.tblICStorageUnitType UT ON SL.intStorageUnitTypeId = UT.intStorageUnitTypeId WHERE UT.strInternalCode = ''PROD_STAGING''' WHERE intAttributeId =75
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 76
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 76
        ,'Staging Location'
        ,5
        ,1
        ,0
        ,'SELECT CONVERT(nvarchar,intStorageLocationId) AS ValueMember,strName AS DisplayMember FROM dbo.tblICStorageLocation SL JOIN dbo.tblICStorageUnitType UT ON SL.intStorageUnitTypeId = UT.intStorageUnitTypeId WHERE UT.strInternalCode = ''STAGING'''
END
ELSE
BEGIN
	UPDATE dbo.tblMFAttribute SET strSQL='SELECT CONVERT(nvarchar,intStorageLocationId) AS ValueMember,strName AS DisplayMember FROM dbo.tblICStorageLocation SL JOIN dbo.tblICStorageUnitType UT ON SL.intStorageUnitTypeId = UT.intStorageUnitTypeId WHERE UT.strInternalCode = ''STAGING''' WHERE intAttributeId =76
END

GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 77
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 77
        ,'Staging Location Type'
        ,5
        ,1
        ,0
        ,'SELECT ''Alternate Staging Location'' AS ValueMember,''Alternate Staging Location'' AS DisplayMember UNION SELECT ''Staging Location'' AS ValueMember,''Staging Location'' AS DisplayMember UNION SELECT ''Production Staging Location'' AS ValueMember,''Production Staging Location'' AS DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 78
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 78
        ,'Category for Ingredient Demand Report'
        ,5
        ,1
        ,1
        ,'SELECT strCategoryCode AS ValueMember,strCategoryCode AS DisplayMember FROM tblICCategory'
END
GO

IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 79
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 79
        ,'Add yield cost to output item'
        ,5
        ,1
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 80
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 80
        ,'Source Location'
        ,5
        ,1
        ,1
        ,'Select CONVERT(nvarchar,intStorageLocationId) as ValueMember,strName as DisplayMember from tblICStorageLocation UNION Select NULL as ValueMember, NULL as DisplayMember  Order by strName'
END
Else
Begin
	Update tblMFAttribute Set strSQL='Select CONVERT(nvarchar,intStorageLocationId) as ValueMember,strName as DisplayMember from tblICStorageLocation UNION Select NULL as ValueMember, NULL as DisplayMember   Order by strName' Where intAttributeId = 80
End
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 81
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 81
        ,'Transfer To Location'
        ,5
        ,1
        ,1
        ,'Select CONVERT(nvarchar,intStorageLocationId) as ValueMember,strName as DisplayMember from tblICStorageLocation UNION Select NULL as ValueMember, NULL as DisplayMember Order by strName'
END
Else
Begin
	Update tblMFAttribute Set strSQL='Select CONVERT(nvarchar,intStorageLocationId) as ValueMember,strName as DisplayMember from tblICStorageLocation UNION Select NULL as ValueMember, NULL as DisplayMember   Order by strName' Where intAttributeId = 81
End
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 82
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 82
        ,'Create Multiple Lots In Blend Production'
        ,5
        ,2
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
Go
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 83
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 83
        ,'Include Kit Staging Location In Pick List'
        ,5
        ,2
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
Go
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 84
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 84
        ,'WIP Sample Mandatory'
        ,5
        ,5
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
ELSE

BEGIN
	UPDATE tblMFAttribute
	SET strAttributeName = 'WIP Sample Mandatory'
	WHERE intAttributeId = 84
END
Go
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 85
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        )
    SELECT 85
        ,'Duration Between WIP Sample in Min'
        ,2
        ,5
END
ELSE

BEGIN
	UPDATE tblMFAttribute
	SET strAttributeName = 'Duration Between WIP Sample in Min'
	WHERE intAttributeId = 85
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttribute
		WHERE intAttributeId = 86
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 86
		,'Feed Time Disabled'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 87
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
		,strSQL
        )
    SELECT 87
        ,'3rd Party Pallets (e.g. iGPS) - Mandatory'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttribute
		WHERE intAttributeId = 88
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		,ysnMultiSelect
		)
	SELECT 88
		,'3rd Party Pallets (e.g. iGPS) Item Id'
		,5
		,1
		,'Select CONVERT(nvarchar,intItemId) as ValueMember,strItemNo as DisplayMember from tblICItem I JOIN tblICCategory C on C.intCategoryId=I.intCategoryId Where C.strCategoryCode =''PM'''
		,1
END
ELSE
BEGIN
	UPDATE tblMFAttribute
	SET ysnMultiSelect=1
	WHERE intAttributeId = 88
END
GO
IF NOT EXISTS (
        SELECT 1
        FROM tblMFAttribute
        WHERE intAttributeId = 89
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
		,strSQL
        )
    SELECT 89
        ,'Compute Gross Weight in Produce Screen'
		,5
		,5
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 90
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 90
        ,'PM Production Staging Location'
        ,5
        ,1
        ,0
        ,'SELECT CONVERT(nvarchar,intStorageLocationId) AS ValueMember,strName AS DisplayMember FROM dbo.tblICStorageLocation SL JOIN dbo.tblICStorageUnitType UT ON SL.intStorageUnitTypeId = UT.intStorageUnitTypeId WHERE UT.strInternalCode = ''PROD_STAGING'''
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 91
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 91
        ,'Warehouse Release Lot By Work Order'
        ,5
        ,1
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 92
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 92
        ,'Pick By Full Pallet'
        ,5
        ,1
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 93
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 93
        ,'Restrict Produce Qty by Cases per Pallet'
        ,5
        ,1
        ,0
        ,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
GO
IF NOT EXISTS (
        SELECT *
        FROM dbo.tblMFAttribute
        WHERE intAttributeId = 94
        )
BEGIN
    INSERT INTO tblMFAttribute (
        intAttributeId
        ,strAttributeName
        ,intAttributeDataTypeId
        ,intAttributeTypeId
        ,ysnMultiSelect
        ,strSQL
        )
    SELECT 94
        ,'Quality Line Chart By'
        ,5
        ,1
        ,0
        ,'SELECT CONVERT(nvarchar,intProductTypeId) AS ValueMember,strProductTypeName AS DisplayMember FROM tblQMProductType WHERE intProductTypeId IN (6,11,12)'
END































