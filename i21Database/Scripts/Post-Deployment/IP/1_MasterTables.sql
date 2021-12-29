﻿IF NOT EXISTS(SELECT * FROM tblIPServerType WHERE intServerTypeId = 1)
BEGIN
    INSERT INTO tblIPServerType(intServerTypeId,strName)
    VALUES(1,'SQL Server')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPServerType WHERE intServerTypeId = 2)
BEGIN
    INSERT INTO tblIPServerType(intServerTypeId,strName)
    VALUES(2,'Oracle')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPFileType WHERE intFileTypeId = 1)
BEGIN
    INSERT INTO tblIPFileType(intFileTypeId,strName)
    VALUES(1,'Fixed')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPFileType WHERE intFileTypeId = 2)
BEGIN
    INSERT INTO tblIPFileType(intFileTypeId,strName)
    VALUES(2,'Delimited')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPFileType WHERE intFileTypeId = 3)
BEGIN
    INSERT INTO tblIPFileType(intFileTypeId,strName)
    VALUES(3,'Excel')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPFileType WHERE intFileTypeId = 4)
BEGIN
    INSERT INTO tblIPFileType(intFileTypeId,strName)
    VALUES(4,'XML')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPFileType WHERE intFileTypeId = 5)
BEGIN
    INSERT INTO tblIPFileType(intFileTypeId,strName)
    VALUES(5,'IDOC XML')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPDelimiter WHERE intDelimiterId = 44)
BEGIN
    INSERT INTO tblIPDelimiter(intDelimiterId,strName)
    VALUES(44,'Comma')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPDelimiter WHERE intDelimiterId = 58)
BEGIN
    INSERT INTO tblIPDelimiter(intDelimiterId,strName)
    VALUES(58,'Colon')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPDelimiter WHERE intDelimiterId = 59)
BEGIN
    INSERT INTO tblIPDelimiter(intDelimiterId,strName)
    VALUES(59,'Semi-Colon')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPDelimiter WHERE intDelimiterId = 32)
BEGIN
    INSERT INTO tblIPDelimiter(intDelimiterId,strName)
    VALUES(32,'Space')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPDelimiter WHERE intDelimiterId = 9)
BEGIN
    INSERT INTO tblIPDelimiter(intDelimiterId,strName)
    VALUES(9,'Tab')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPDelimiter WHERE intDelimiterId = 152)
BEGIN
    INSERT INTO tblIPDelimiter(intDelimiterId,strName)
    VALUES(152,'Tilde')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPDataType WHERE intDataTypeId = 56)
BEGIN
    INSERT INTO tblIPDataType(intDataTypeId,intServerTypeId,strName)
    VALUES(56,1,'INT')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPDataType WHERE intDataTypeId = 108)
BEGIN
    INSERT INTO tblIPDataType(intDataTypeId,intServerTypeId,strName)
    VALUES(108,1,'NUMERIC')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPDataType WHERE intDataTypeId = 231)
BEGIN
    INSERT INTO tblIPDataType(intDataTypeId,intServerTypeId,strName)
    VALUES(231,1,'NVARCHAR')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPDataType WHERE intDataTypeId = 61)
BEGIN
    INSERT INTO tblIPDataType(intDataTypeId,intServerTypeId,strName)
    VALUES(61,1,'DATETIME')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPDataType WHERE intDataTypeId = 104)
BEGIN
    INSERT INTO tblIPDataType(intDataTypeId,intServerTypeId,strName)
    VALUES(104,1,'BIT')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPScheduleType WHERE intScheduleTypeId = 1)
BEGIN
    INSERT INTO tblIPScheduleType(intScheduleTypeId,strName)
    VALUES(1,'Daily')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPScheduleType WHERE intScheduleTypeId = 2)
BEGIN
    INSERT INTO tblIPScheduleType(intScheduleTypeId,strName)
    VALUES(2,'Weekly')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPScheduleType WHERE intScheduleTypeId = 3)
BEGIN
    INSERT INTO tblIPScheduleType(intScheduleTypeId,strName)
    VALUES(3,'Monthly')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPSQLType WHERE intSQLTypeId = 1)
BEGIN
    INSERT INTO tblIPSQLType(intSQLTypeId,strName)
    VALUES(1,'Table')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPSQLType WHERE intSQLTypeId = 2)
BEGIN
    INSERT INTO tblIPSQLType(intSQLTypeId,strName)
    VALUES(2,'Stored Procedure')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPSQLType WHERE intSQLTypeId = 3)
BEGIN
    INSERT INTO tblIPSQLType(intSQLTypeId,strName)
    VALUES(3,'SQL Statement')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPStepType WHERE intStepTypeId = 0)
BEGIN
    INSERT INTO tblIPStepType(intStepTypeId,strName)
    VALUES(0,'Unassigned')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPStepType WHERE intStepTypeId = 1)
BEGIN
    INSERT INTO tblIPStepType(intStepTypeId,strName)
    VALUES(1,'Execute SQL')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPStepType WHERE intStepTypeId = 2)
BEGIN
    INSERT INTO tblIPStepType(intStepTypeId,strName)
    VALUES(2,'Import File')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPStepType WHERE intStepTypeId = 3)
BEGIN
    INSERT INTO tblIPStepType(intStepTypeId,strName)
    VALUES(3,'Export File')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPStepType WHERE intStepTypeId = 4)
BEGIN
    INSERT INTO tblIPStepType(intStepTypeId,strName)
    VALUES(4,'File Operation')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPStepType WHERE intStepTypeId = 5)
BEGIN
    INSERT INTO tblIPStepType(intStepTypeId,strName)
    VALUES(5,'Database Operation')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPStepType WHERE intStepTypeId = 6)
BEGIN
    INSERT INTO tblIPStepType(intStepTypeId,strName)
    VALUES(6,'Import Compound File')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPStepType WHERE intStepTypeId = 7)
BEGIN
    INSERT INTO tblIPStepType(intStepTypeId,strName)
    VALUES(7,'Export Compound File')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPStepType WHERE intStepTypeId = 8)
BEGIN
    INSERT INTO tblIPStepType(intStepTypeId,strName)
    VALUES(8,'Transform XML')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPStepType WHERE intStepTypeId = 9)
BEGIN
    INSERT INTO tblIPStepType(intStepTypeId,strName)
    VALUES(9,'Send Mail')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPStepType WHERE intStepTypeId = 10)
BEGIN
    INSERT INTO tblIPStepType(intStepTypeId,strName)
    VALUES(10,'Execute External Program')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPStepType WHERE intStepTypeId = 11)
BEGIN
    INSERT INTO tblIPStepType(intStepTypeId,strName)
    VALUES(11,'Delete Log')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPStepType WHERE intStepTypeId = 12)
BEGIN
    INSERT INTO tblIPStepType(intStepTypeId,strName)
    VALUES(12,'Reset Busy Flag')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPStepType WHERE intStepTypeId = 13)
BEGIN
    INSERT INTO tblIPStepType(intStepTypeId,strName)
    VALUES(13,'FTP Operation')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPStepType WHERE intStepTypeId = 14)
BEGIN
    INSERT INTO tblIPStepType(intStepTypeId,strName)
    VALUES(14,'Web Service Call')
END
GO
IF NOT EXISTS(SELECT * FROM tblIPStepType WHERE intStepTypeId = 15)
BEGIN
    INSERT INTO tblIPStepType(intStepTypeId,strName)
    VALUES(15,'i21 Web API Endpoint')
END
UPDATE tblIPStepType SET strName = 'i21 Web API Endpoint' WHERE intStepTypeId = 15 AND strName = 'Web API Endpoint'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblIPCompanyPreference
		)
BEGIN
	INSERT INTO tblIPCompanyPreference (strCommonDataFolderPath)
	SELECT NULL
END
GO
UPDATE tblRKStgMatchPnS
SET ysnPost = 1
WHERE ysnPost IS NULL

UPDATE tblRKStgOptionMatchPnS
SET ysnPost = 1
WHERE ysnPost IS NULL
GO

UPDATE tblIPStep
SET intDeleteFilesPriorTo = 0
WHERE intDeleteFilesPriorTo IS NULL
GO

UPDATE tblIPItemArchive
SET ysnMailSent = 0
WHERE ysnMailSent IS NULL
GO
