
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
		)
	SELECT 9
		,'Item Types Excluded From Cycle Count'
		,5
		,4
		,'Select ''Inventory'' as ValueMember,''Inventory'' as DisplayMember UNION Select ''Finished Good'' as ValueMember,''Finished Good'' as DisplayMember'
END
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
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
		WHERE intAttributeId = 22
		)
BEGIN
	INSERT INTO tblMFAttribute (
		intAttributeId
		,strAttributeName
		,intAttributeDataTypeId
		,intAttributeTypeId
		,strSQL
		)
	SELECT 22
		,'Default Residue Qty'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
END
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
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFAttribute
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
		,'Is Parent Lot'
		,5
		,1
		,'Select ''False'' as ValueMember,''False'' as DisplayMember UNION Select ''True'' as ValueMember,''True'' as DisplayMember'
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