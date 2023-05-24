PRINT '********************** BEGIN - Drop Unused AR Stored Procedures **********************'
GO

-- Incorrect spelling. This will be replaced by uspARPostItemReservation.
IF EXISTS(SELECT TOP 1 1 from sys.procedures WHERE name = 'uspARPostItemResevation')
	DROP PROCEDURE uspARPostItemResevation
GO

PRINT ' ********************** END - Drop Unused AR Stored Procedures **********************'
GO