CREATE TABLE [dbo].[tblApiSchemaTMClockReading]
(
	intClockReadingId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,

    strClockNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,      -- Clock Number
    dtmReadingDate DATETIME NOT NULL,                                    		-- Reading Date
    intDegreeDay INT NOT NULL,                                           		-- Degree Day
    intAccumulatedDegreeDay INT NOT NULL                                 		-- Accumulated Degree Day
)
