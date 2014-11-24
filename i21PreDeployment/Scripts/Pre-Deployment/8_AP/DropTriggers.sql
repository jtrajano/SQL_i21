GO
IF EXISTS (SELECT name FROM sysobjects
      WHERE name = 'trgBillRecordNumber' AND type = 'TR')
   DROP TRIGGER trgBillRecordNumber
GO