CREATE TYPE [dbo].[TFTerminalControlNumbers] AS TABLE (
	intTerminalControlNumberId INT NOT NULL
	, strTerminalControlNumber NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL
	, strName NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL
	, strAddress NVARCHAR (500) COLLATE Latin1_General_CI_AS NOT NULL
	, strCity NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL
	, dtmApprovedDate DATETIME NULL
	, strZip NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL
	, intMasterId INT NULL
)