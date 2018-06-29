CREATE TYPE [dbo].[TFFilingPackets] AS TABLE (
	intFilingPacketId INT NOT NULL
	, strFormCode NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	, strScheduleCode NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL
	, strType NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL
	, ysnStatus BIT NULL
	, intMasterId INT NULL
	, intFrequency INT NOT NULL
)