CREATE TABLE [dbo].[tblLGETATracking]
( 
  [intETATrackingId] INT IDENTITY(1,1) PRIMARY KEY,
  [intLoadId] INT,
  [dtmETAPOD] DATETIME,
  [dtmModifiedOn] DATETIME,
  [intConcurrencyId] INT
)