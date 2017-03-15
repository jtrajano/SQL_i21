CREATE TABLE [dbo].[tblLGETATracking]
( 
  [intETATrackingId] INT IDENTITY(1,1) PRIMARY KEY,
  [intLoadId] INT,
  [strTrackingType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
  [dtmETAPOD] DATETIME NULL,
  [strETAPODReasonCode] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
  [dtmETSPOL] DATETIME NULL,
  [strETSPOLReasonCode] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
  [dtmModifiedOn] DATETIME,
  [intConcurrencyId] INT
)