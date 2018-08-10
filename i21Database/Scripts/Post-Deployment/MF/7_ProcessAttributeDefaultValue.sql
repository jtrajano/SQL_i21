
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 1
			AND intAttributeTypeId = 4
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,1
		,4
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 2
			AND intAttributeTypeId = 4
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,2
		,4
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 3
			AND intAttributeTypeId = 4
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,3
		,4
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 4
			AND intAttributeTypeId = 4
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,4
		,4
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 5
			AND intAttributeTypeId = 4
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,5
		,4
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 8
			AND intAttributeTypeId = 4
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,8
		,4
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 9
			AND intAttributeTypeId = 4
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,9
		,4
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 17
			AND intAttributeTypeId = 4
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,17
		,4
		,'True'
		,'True'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 19
			AND intAttributeTypeId = 4
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,19
		,4
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 10
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,10
		,2
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 11
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,11
		,2
		,'True'
		,'True'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 13
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,13
		,2
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 14
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,14
		,2
		,'True'
		,'True'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 27
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,27
		,2
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 29
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,29
		,2
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 30
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,30
		,2
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 31
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,31
		,2
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 32
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,32
		,2
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 33
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,33
		,2
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 35
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,35
		,2
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 42
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,42
		,2
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 43
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,43
		,2
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 65
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,65
		,2
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 66
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,66
		,2
		,'0'
		,'0'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 72
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,72
		,2
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 82
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,82
		,2
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 83
			AND intAttributeTypeId = 2
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,83
		,2
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 6
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,6
		,1
		,'1'
		,'Active'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 7
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,7
		,1
		,'True'
		,'True'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 12
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,12
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 15
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,15
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 16
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,16
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 18
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,18
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 20
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,20
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 21
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,21
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 23
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,23
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 24
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,24
		,1
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 25
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,25
		,1
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 26
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,26
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 28
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,28
		,1
		,'True'
		,'True'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 36
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,36
		,1
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 37
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,37
		,1
		,'0'
		,'0'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 38
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,38
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 39
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,39
		,1
		,'True'
		,'True'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 44
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,44
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 45
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,45
		,1
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 46
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,46
		,1
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 71
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,71
		,1
		,'True'
		,'True'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 73
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,73
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 74
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,74
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 75
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,75
		,1
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 76
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,76
		,1
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 77
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,77
		,1
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 78
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,78
		,1
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 79
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,79
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 80
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,80
		,1
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 81
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,81
		,1
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 86
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,86
		,1
		,'True'
		,'True'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 87
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,87
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 88
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,88
		,1
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 90
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,90
		,1
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 91
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,91
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 92
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,92
		,1
		,'True'
		,'True'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 93
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,93
		,1
		,'True'
		,'True'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 94
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,94
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 95
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,95
		,1
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 96
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,96
		,1
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 97
			AND intAttributeTypeId = 1
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,97
		,1
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 56
			AND intAttributeTypeId = 6
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,56
		,6
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 57
			AND intAttributeTypeId = 6
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,57
		,6
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 58
			AND intAttributeTypeId = 6
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,58
		,6
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 59
			AND intAttributeTypeId = 6
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,59
		,6
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 60
			AND intAttributeTypeId = 6
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,60
		,6
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 61
			AND intAttributeTypeId = 6
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,61
		,6
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 62
			AND intAttributeTypeId = 6
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,62
		,6
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 63
			AND intAttributeTypeId = 6
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,63
		,6
		,'True'
		,'True'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 64
			AND intAttributeTypeId = 6
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,64
		,6
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 40
			AND intAttributeTypeId = 3
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,40
		,3
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 41
			AND intAttributeTypeId = 3
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,41
		,3
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 67
			AND intAttributeTypeId = 3
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,67
		,3
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 68
			AND intAttributeTypeId = 3
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,68
		,3
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 47
			AND intAttributeTypeId = 5
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,47
		,5
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 48
			AND intAttributeTypeId = 5
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,48
		,5
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 49
			AND intAttributeTypeId = 5
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,49
		,5
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 50
			AND intAttributeTypeId = 5
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,50
		,5
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 51
			AND intAttributeTypeId = 5
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,51
		,5
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 52
			AND intAttributeTypeId = 5
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,52
		,5
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 53
			AND intAttributeTypeId = 5
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,53
		,5
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 54
			AND intAttributeTypeId = 5
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,54
		,5
		,'True'
		,'True'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 55
			AND intAttributeTypeId = 5
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,55
		,5
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 69
			AND intAttributeTypeId = 5
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,69
		,5
		,'True'
		,'True'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 70
			AND intAttributeTypeId = 5
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,70
		,5
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 84
			AND intAttributeTypeId = 5
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,84
		,5
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 85
			AND intAttributeTypeId = 5
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,85
		,5
		,''
		,''
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 89
			AND intAttributeTypeId = 5
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,89
		,5
		,'False'
		,'False'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFAttributeDefaultValue
		WHERE intAttributeId = 99
			AND intAttributeTypeId = 5
		)
BEGIN
	INSERT INTO tblMFAttributeDefaultValue (
		intConcurrencyId
		,intAttributeId
		,intAttributeTypeId
		,strAttributeDefaultValue
		,strAttributeDisplayValue
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		1
		,99
		,5
		,'1'
		,'Recipe UOM'
		,1
		,GETDATE()
		,1
		,GETDATE()
		)
END
--GO
--IF NOT EXISTS (
--		SELECT 1
--		FROM tblMFAttributeDefaultValue
--		WHERE intAttributeId = 116
--			AND intAttributeTypeId = 5
--		)
--BEGIN
--	INSERT INTO tblMFAttributeDefaultValue (
--		intConcurrencyId
--		,intAttributeId
--		,intAttributeTypeId
--		,strAttributeDefaultValue
--		,strAttributeDisplayValue
--		,intCreatedUserId
--		,dtmCreated
--		,intLastModifiedUserId
--		,dtmLastModified
--		)
--	VALUES (
--		1
--		,116
--		,5
--		,'False'
--		,'False'
--		,1
--		,GETDATE()
--		,1
--		,GETDATE()
--		)
--END

