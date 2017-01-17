CREATE TABLE [dbo].[tblLGETATracking]
( 
  [intETATrackingId] INT IDENTITY(1,1) PRIMARY KEY,
  [intLoadId] INT,
  [strTrackingType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
  [dtmETAPOD] DATETIME NULL,
  [dtmETSPOL] DATETIME NULL,
  [dtmModifiedOn] DATETIME,
  [intConcurrencyId] INT
)